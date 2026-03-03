# Terraform / IaC dla sieci — jak to działa i jak tego używać

## 1. Cel dokumentu

Ten dokument tłumaczy **jak jest zorganizowana infrastruktura sieciowa w Terraform**:

- jak podzieliliśmy kod na moduły (`network-core`, `network-endpoints`),
- jak działa katalog `envs/dev`,
- jak wygląda pełna procedura:
  - bootstrap bucketu S3 na state,
  - przygotowanie backendu,
  - `init` / `validate` / `plan` / `apply`,
  - co zrobić po przerwie, żeby **bezpiecznie odtworzyć środowisko**.

Założenie: jesteś doświadczonym .NET devem z Azure, ale **Terraform + AWS** chcesz mieć opisane krok po kroku, bez skrótów myślowych.

---

## 2. Struktura katalogów IaC

Lokalizacja główna: `infra/terraform/`

```text
infra/terraform/
├── bootstrap/            # Jednorazowy bootstrap: bucket S3 dla Terraform state
├── modules/              # Moduły Terraform (reużywalne)
│   ├── _standards.md     # Konwencje: variables, outputs, tagging (ADR-0002)
│   ├── network-core/     # VPC, subnety, IGW, NAT, route tables, SG
│   └── network-endpoints/# Gateway + Interface Endpoints, VPC Flow Logs
└── envs/
    └── dev/              # Konfiguracja środowiska dev (root module)
        ├── backend.tf    # backend \"s3\" (partial config, use_lockfile = true)
        ├── backend.dev.hcl.example # przykład pliku backend-config
        ├── versions.tf   # wymagania Terraform/AWS
        ├── variables.tf  # zmienne root (np. region)
        └── main.tf       # provider + wywołania modułów
```

**W skrócie:**

- `bootstrap/` — osobny, mały projekt Terraform, który tworzy **bucket S3 na state** (z versioning, encryption, block public access).
- `modules/` — „biblioteka” modułów, które możesz używać w różnych env:
  - `network-core` — szkielet sieci,
  - `network-endpoints` — endpointy + Flow Logs.
- `envs/dev/` — „root module”, który:
  - konfiguruje backend S3,
  - konfiguruję providera AWS,
  - składa moduły (`network-core`, `network-endpoints`) w pełne środowisko dev.

**Azure analogia:**  
To tak, jakbyś miał:

- osobny projekt ARM/Bicep/TF do stworzenia storage account na state,
- folder `modules` z Bicep modules (VNet, Endpoints),
- folder `envs/dev` z głównym template’m, który łączy moduły w konkretną instancję środowiska.

---

## 3. Bootstrap backendu S3 (jednorazowo)

Opisany szerzej w `docs/runbooks/terraform-backend-bootstrap.md`. Tu skrót z uzasadnieniem.

### 3.1 Dlaczego osobny bootstrap?

Problem „kurka i jajka”:

- żeby używać **backendu S3** w `envs/dev`, **bucket S3 musi już istnieć**,
- żeby stworzyć bucket S3 „ręcznie”, musiałbyś klikać w konsoli AWS,
- chcemy, żeby **wszystko było w Terraform**, więc:
  - mały projekt `bootstrap/` tworzy bucket z **local state**,
  - dopiero potem `envs/dev` używa tego bucketu jako backendu.

### 3.2 Co tworzy `bootstrap/`

Pliki:

- `main.tf`:
  - provider AWS (`region` z `variables.tf`),
  - `aws_s3_bucket.terraform_state` z:
    - włączonym **versioningiem**,
    - włączonym **SSE-S3** (szyfrowanie),
    - włączonym **block public access**.
- `variables.tf`:
  - `project` (np. `orderflow`),
  - `env` (np. `dev`),
  - `region` (np. `eu-central-1`).
- `outputs.tf`:
  - `s3_bucket_name` (nazwa bucketu),
  - `region`.

Nazwa bucketu:

- konwencja:
  - `{project}-{env}-terraform-state-{account_id}`,
  - np. `orderflow-dev-terraform-state-123456789012`.

### 3.3 Jak uruchomić bootstrap (manualnie)

W swoim terminalu:

```bash
export AWS_PROFILE=swpr-dev   # lub inny profil z dostępem do konta dev
cd infra/terraform/bootstrap
terraform init
terraform plan
terraform apply
terraform output s3_bucket_name
```

**Co sprawdzić po apply:**

- w konsoli AWS:
  - bucket istnieje,
  - ma włączony versioning i encryption,
  - ma włączony block public access.

**Dlaczego to ważne:**

- backend S3 to **źródło prawdy** stanu Terraform:
  - jeśli zgubisz lokalny katalog, możesz odtworzyć wszystko ze state,
  - możesz pracować z kilkoma maszynami / pipeline’ami bez rozjazdów,
  - `use_lockfile = true` zapewnia lock plikowy `.tflock` w S3 (bez DynamoDB).

---

## 4. Backend w `envs/dev` (S3 + use_lockfile)

W `infra/terraform/envs/dev/backend.tf`:

```hcl
terraform {
  backend "s3" {
    use_lockfile = true
  }
}
```

To jest **partial configuration**:

- mówi, że:
  - backendem jest `s3`,
  - używamy plikowego locka `.tflock` w bucketcie,
- ale **nie mówi**, jaki bucket/key/region — to podamy z zewnątrz przez `-backend-config`.

Przykład pliku `backend.dev.hcl.example`:

```hcl
bucket = "orderflow-dev-terraform-state-PODAJ_ACCOUNT_ID"
key    = "dev/terraform.tfstate"
region = "eu-central-1"
```

Procedura:

1. Skopiuj:

```bash
cd infra/terraform/envs/dev
cp backend.dev.hcl.example backend.dev.hcl
```

2. Wstaw:
   - `bucket` — z outputu bootstrapu,
   - `key` — ścieżkę do pliku state (np. `dev/terraform.tfstate`),
   - `region` — np. `eu-central-1`.
3. Uruchom:

```bash
terraform init -backend-config=backend.dev.hcl
```

**Dlaczego tak:**

- Terraform **nie pozwala** parametryzować `backend` zmiennymi wejściowymi,
- `-backend-config` to standardowy sposób przekazania danych specyficznych dla środowiska/secrets (bucket, key),
- `backend.dev.hcl` jest w `.gitignore`:
  - nie commitujesz nazwy bucketu konkretnego konta,
  - każdy może mieć swój bucket (własne konto), używając tego samego kodu.

---

## 5. Moduły vs root module (envs/dev)

### 5.1 Dlaczego moduły?

Chcemy:

- oddzielić **logikę sieci** od **konkretnego środowiska**,
- móc:
  - użyć tej samej sieci w innych env (np. `qa`, `test`) z innym `name_prefix`,
  - rozwijać moduły (`network-core`, `network-endpoints`) niezależnie od root module,
  - mieć czytelny kod — każdy plik robi jedną rzecz.

### 5.2 Co robi `envs/dev/main.tf`

```hcl
provider "aws" {
  region = var.region
}

module "network_core" {
  source = "../../modules/network-core"
  ...
}

module "network_endpoints" {
  source = "../../modules/network-endpoints"

  vpc_id                 = module.network_core.vpc_id
  private_route_table_id = module.network_core.private_route_table_id
  private_subnet_ids     = module.network_core.private_subnet_ids
  sg_app_id              = module.network_core.sg_ecs_id

  name_prefix = "orderflow-dev"
  tags        = {}
}
```

Root module:

- konfiguruje **provider** (region, profil przez `AWS_PROFILE`),
- wywołuje moduły i wiąże je przez outputy/wejścia:
  - `network-core` tworzy VPC + subnety + SG,
  - `network-endpoints` bierze outputy `network-core` i tworzy endpointy/Flow Logs.

**Azure analogia:**  
Główny Bicep, który:

- deklaruje `targetScope = 'subscription' / 'resourceGroup'`,
- wywołuje moduły `vnet.bicep`, `endpoints.bicep`,
- przekazuje im parametry i zbiera outputy.

---

## 6. Codzienny flow pracy z Terraformem (dev-only)

Załóżmy, że backend już jest skonfigurowany (`terraform init` wykonany).

### 6.1 Pełna sesja (odświeżenie po przerwie)

1. **Ustaw profil AWS:**

```bash
export AWS_PROFILE=swpr-dev   # lub alias aws-dev
```

2. **Przejdź do root module:**

```bash
cd infra/terraform/envs/dev
```

3. **Sformatuj kod:**

```bash
terraform fmt
```

4. **Sprawdź konfigurację:**

```bash
terraform validate
```

5. **Plan:**

```bash
terraform plan -no-color
```

- upewniasz się, że:
  - Terraform widzi tylko oczekiwane zmiany (albo brak zmian),
  - nie ma zaskoczeń (destroy czegoś, czego nie chciałeś ruszać).

6. **Apply** (tylko jeśli chcesz zmienić infrastrukturę):

```bash
terraform apply -no-color
```

W W07 **pierwszy `apply` robisz ręcznie** (walidacja sieci).  
Od W08 planowane jest przejście na CI/CD (GitHub Actions + OIDC), gdzie:

- PR → `terraform plan` w CI,
- merge / manual trigger → `terraform apply` w CI.

### 6.2 Co sprawdzić po `apply`

- `terraform state list`:
  - powinieneś widzieć:
    - zasoby `module.network_core.*`,
    - zasoby `module.network_endpoints.*`.
- w konsoli AWS:
  - VPC, subnety, IGW, NAT,
  - Gateway Endpoints S3/DynamoDB,
  - Interface Endpoints Secrets/SSM,
  - CloudWatch log group i strumienie Flow Logs.

---

## 7. Jak bezpiecznie zrobić cleanup (zgodnie z ADR-0002)

Kosztowe elementy:

- NAT Gateway,
- Interface Endpoints,
- Flow Logs (CloudWatch Logs storage),
- w przyszłości RDS/ECS itd.

Zasada z ADR-0002 („learning-first z guardrails”):

- drogie zasoby:
  - **tworzymy na czas ćwiczenia/tygodnia**,
  - potem **świadomie usuwamy** lub wyłączamy moduł.

Scenariusze:

1. **Krótka przerwa (kilka dni):**
   - możesz zostawić sieć włączoną,
   - ale miej świadomość kosztu NAT/endpointów/Flow Logs.
2. **Dłuższa przerwa (tygodnie/miesiące):**
   - rozważ:
     - `terraform destroy` w `envs/dev`,
     - albo tymczasowe usunięcie modułu `network_endpoints` z `main.tf` i `apply`,
   - *zanim to zrobisz*:
     - zrób notatkę w `evidence.md` i `log.md` tygodnia,
     - upewnij się, że stan w S3 jest spójny.

**Kluczowa myśl:**  
Zawsze możesz odtworzyć środowisko z kodu + state’a.  
Treat Terraform as **jedyna prawda o infrastrukturze**.

---

## 8. Najczęstsze pułapki i jak ich unikać

### 8.1 `Error: No valid credential sources found`

- Problem: brak poświadczeń AWS.
- Rozwiązanie:
  - `export AWS_PROFILE=swpr-dev`,
  - `aws sts get-caller-identity` → upewnij się, że działa,
  - dopiero potem `terraform init/plan/apply`.

### 8.2 Zmiana backendu po `init`

- Jeśli zmienisz:
  - nazwę bucketu,
  - `key` w `backend.dev.hcl`,
- Terraform może wymagać:
  - ponownego `terraform init -backend-config=backend.dev.hcl`,
  - ewentualnie migracji stanu (na tym etapie raczej tego nie robisz).

### 8.3 „Dryf” między stanem a rzeczywistością

- Jeśli coś usuniesz/ręcznie zmienisz w konsoli AWS:
  - `terraform plan` pokaże różnice,
  - czasem trzeba:
    - zaakceptować je przez `apply`,
    - lub `terraform import` (gdy dodałeś coś ręcznie, ale chcesz to objąć Terraformem).

Na tym etapie kursu:

- **nie** bawimy się w importy/migracje,
- przy drastycznych rozjazdach:
  - lepiej zrobić przemyślany `destroy` i odtworzyć środowisko z kodu.

---

## 9. Gdzie szukać dalszych informacji

- Topologia sieci:
  - `docs/network/00-network-topology-overview.md`
- Moduły:
  - `docs/network/01-module-network-core.md`
  - `docs/network/02-module-network-endpoints.md`
- Design:
  - `docs/lessons/W04-network-core-module-design.md`
  - `docs/lessons/W05-endpoints-design.md`
  - `docs/lessons/W04-W05-network-architecture-overview.md`
- Runbooki:
  - `docs/runbooks/terraform-backend-bootstrap.md`
  - `docs/runbooks/network-smoke-tests.md`

Jeśli kiedykolwiek zgubisz się po przerwie:

1. Zacznij od `docs/network/00-network-topology-overview.md` (big picture).
2. Zajrzyj do dokumentacji modułów (01/02).
3. Na końcu przeczytaj ten plik, żeby przypomnieć sobie **jak** tym zarządzać Terraformem operacyjnie.

