# Terraform IaC pipeline (GitHub Actions + OIDC) — dev

## Przeznaczenie

Ten runbook opisuje **pełny pipeline Terraform dla środowiska dev** w repozytorium `wypiorsebastian/aws-learning-path`, oparty o:

- **GitHub Actions** (`terraform-plan.yml` i `terraform-apply.yml`),
- **OIDC do AWS** (bez statycznych kluczy w sekretach),
- **GitHub Environments** (środowisko `dev` z konfiguracją backendu state),
- moduły `network-core` i `network-endpoints` w `infra/terraform/`.

Docelowy cel (W08): PR → **`terraform plan`** w CI, merge / ręczne wywołanie → **`terraform apply`** w CI, zawsze z użyciem OIDC i bez access key/secret.

---

## Architektura pipeline’u

- **Repo:** `wypiorsebastian/aws-learning-path`
- **Środowisko:** `dev` (VPC, endpoints, Flow Logs)
- **Terraform stack:** `infra/terraform/envs/dev`
- **Backend state:** S3 bucket `orderflow-dev-terraform-state-292187657518`, key `dev/terraform.tfstate`, region `eu-central-1`
- **OIDC rola w AWS:** `GitHubActionsRole` w koncie `292187657518`
- **GitHub Environments:** `dev` — przechowuje zmienną `TF_BACKEND_BUCKET`
- **Workflowy:**
  - `terraform-plan.yml` — job `terraform-plan-dev`
  - `terraform-apply.yml` — job `terraform-apply-dev`

Relacje:

- Workflow **plan** używa OIDC + roli `GitHubActionsRole` do wykonania `terraform init/validate/plan`.
- Workflow **apply** używa **tej samej roli OIDC**, tego samego backendu S3 i wykonuje `terraform init/plan/apply`.
- Oba workflowy są przypięte do **environment `dev`**, które dostarcza konfigurację backendu (`TF_BACKEND_BUCKET`) i może wymagać manualnych approvali.

---

## Operacyjny flow

### 1. `terraform plan` (dev)

- Trigger:
  - `workflow_dispatch` (ręcznie z Actions), **lub**
  - `pull_request` do `main` (w planie docelowo) ze zmianami w `infra/terraform/**`.
- Kroki:
  1. Checkout repo.
  2. Zapisanie `backend.ci.hcl` z:
     - `bucket = TF_BACKEND_BUCKET` (z environment `dev`),
     - `key = "dev/terraform.tfstate"`,
     - `region = AWS_REGION`.
  3. Konfiguracja AWS credentials via OIDC (rola `GitHubActionsRole`).
  4. `terraform init -backend-config=backend.ci.hcl`.
  5. `terraform validate`.
  6. `terraform plan` (bez zapisu planu do pliku — tylko logi).

**Oczekiwany efekt:** w logach workflowa widzisz pełny plan dla sieci dev (VPC, subnets, endpoints, Flow Logs itd.), bez błędów autoryzacji lub backendu.

### 2. `terraform apply` (dev)

- Trigger:
  - `workflow_dispatch` (manualne odpalenie z Actions na gałęzi `master`),
  - opcjonalnie `push` na `master` ze zmianami w `infra/terraform/**` (obecnie skonfigurowane).
- Kroki:
  1. Checkout repo.
  2. Zapisanie `backend.ci.hcl` (jak w planie).
  3. Konfiguracja AWS credentials via OIDC (ta sama rola).
  4. `terraform init -backend-config=backend.ci.hcl`.
  5. `terraform plan` (sanity check w CI).
  6. `terraform apply -auto-approve` (świadomie, bo to **dev**).

**Oczekiwany efekt:** w logach widzisz:

- `Apply complete! Resources: N added, 0 changed, 0 destroyed.`,
- brak błędów typu `InvalidIdentityToken`, `AccessDenied`, `ResourceAlreadyExistsException`.

---

## Jak to działa pod maską

### OIDC (GitHub → AWS)

- GitHub Actions generuje **token OIDC** z issuerem `https://token.actions.githubusercontent.com`.
- Akcja `aws-actions/configure-aws-credentials@v4`:
  - pobiera token OIDC z audience `sts.amazonaws.com`,
  - wykonuje `AssumeRoleWithWebIdentity` na roli `GitHubActionsRole`.
- Rola `GitHubActionsRole` ma trust policy (w uproszczeniu):
  - `Principal.Federated`: `arn:aws:iam::292187657518:oidc-provider/token.actions.githubusercontent.com`
  - `Condition.StringEquals`:
    - `token.actions.githubusercontent.com:aud = sts.amazonaws.com`
  - `Condition.StringLike`:
    - `token.actions.githubusercontent.com:sub` = jedno z:
      - `repo:wypiorsebastian/aws-learning-path:ref:refs/heads/master`
      - `repo:wypiorsebastian/aws-learning-path:ref:refs/heads/main`
      - `repo:wypiorsebastian/aws-learning-path:pull_request`
      - `repo:wypiorsebastian/aws-learning-path:environment:dev`

Dzięki temu:

- tylko **to repo** i **te wydarzenia** (master/main/PR/environment `dev`) mogą przyjąć rolę,
- inne workflowy / forki nie dostaną dostępu do konta dev.

### Backend Terraform w CI vs lokalnie

- W repo `backend.tf` definiuje tylko typ backendu:

```hcl
terraform {
  backend "s3" {
    use_lockfile = true
  }
}
```

- **Lokalnie** użytkownik ma:
  - `backend.dev.hcl` (skopiowany z `backend.dev.hcl.example`) z:
    - `bucket`, `key`, `region`,
  - uruchamia `terraform init -backend-config=backend.dev.hcl`.
- **W CI** workflow zapisuje `backend.ci.hcl` na podstawie zmiennej `TF_BACKEND_BUCKET` i `AWS_REGION`, a potem:
  - `terraform init -backend-config=backend.ci.hcl`.

Dzięki temu:

- nazwa bucketu nie jest trwale wpisana w repo (może być inna per konto / środowisko),
- w CI **nie ma żadnych sekretów** z access key/secret — wszystko idzie przez OIDC + S3 backend.

---

## Konfiguracja krok po kroku

### 1. AWS — OIDC provider + rola IAM (skrót)

Szczegóły są w `docs/runbooks/github-actions-oidc-aws.md`. Najważniejsze elementy:

- Identity Provider:
  - URL: `https://token.actions.githubusercontent.com`
  - Audience: `sts.amazonaws.com`
- Rola `GitHubActionsRole`:
  - trust policy z:
    - `aud = sts.amazonaws.com`
    - `sub` zawężone do repo i eventów (jak wyżej),
  - permissions:
    - S3 backend (bucket `orderflow-dev-terraform-state-292187657518` + key dev),
    - działania wymagane przez moduły sieciowe.

### 2. GitHub — environment i zmienne

1. Settings → **Environments** → utwórz / skonfiguruj środowisko **`dev`**.
2. W środowisku `dev`:
   - dodaj zmienną **`TF_BACKEND_BUCKET`** = `orderflow-dev-terraform-state-292187657518`.
   - opcjonalnie: ustaw **Required reviewers**, jeśli chcesz approval przed apply w dev.

Workflowy (`terraform-plan` i `terraform-apply`) mają:

```yaml
environment: dev
```

więc korzystają z tych zmiennych i ewentualnych gate’ów.

### 3. GitHub — workflow `terraform-plan.yml`

Główne elementy (logika):

- `on:`
  - `workflow_dispatch` — ręczne uruchomienie,
  - `pull_request` do `main` ze zmianą w `infra/terraform/**` (docelowo).
- `permissions:`:
  - `id-token: write`
  - `contents: read`
- Job:
  - `environment: dev`
  - kroki:
    1. Checkout.
    2. `Write backend config for CI` — zapis `backend.ci.hcl` z bucket/key/region.
    3. `Configure AWS credentials via OIDC` — rola `GitHubActionsRole`.
    4. `Setup Terraform`.
    5. `terraform init -backend-config=backend.ci.hcl`.
    6. `terraform validate`.
    7. `terraform plan`.

### 4. GitHub — workflow `terraform-apply.yml`

Główne elementy (logika):

- `on:`
  - `workflow_dispatch`
  - `push` na `master` ze zmianą w `infra/terraform/**`.
- `permissions:` takie same jak w plan.
- Job:
  - `environment: dev`
  - kroki:
    1. Checkout.
    2. `Write backend config for CI`.
    3. `Configure AWS credentials via OIDC` (ta sama rola).
    4. `Setup Terraform`.
    5. `terraform init -backend-config=backend.ci.hcl`.
    6. `terraform plan` (sanity check).
    7. `terraform apply -auto-approve -no-color`.

---

## Jak poznać, że wszystko działa

**Po stronie CI (GitHub Actions):**

- W obu workflowach:
  - krok **Configure AWS credentials via OIDC** ma status „Success” i log `Authenticated as assumedRoleId ...:GitHubActions`.
  - brak błędów `InvalidIdentityToken`, `AccessDenied`, `Not authorized to perform sts:AssumeRoleWithWebIdentity`.
- W `terraform-plan`:
  - `terraform init` przechodzi (backend S3 skonfigurowany),
  - `terraform plan` pokazuje oczekiwane zmiany.
- W `terraform-apply`:
  - `terraform init` przechodzi,
  - `terraform plan` pokazuje spójny plan,
  - `terraform apply` kończy się `Apply complete! ...`.

**Po stronie AWS:**

- W S3:
  - w bucketcie `orderflow-dev-terraform-state-292187657518` istnieje obiekt `dev/terraform.tfstate`.
- W VPC:
  - zasoby z modułów `network-core` i `network-endpoints` są utworzone (VPC, subnets, IGW, NAT, endpoints, Flow Logs itp.).
- W CloudWatch Logs:
  - istnieje log group `orderflow-dev-vpc-flow-logs`,
  - pojawiają się logi z Flow Logs (po ruchu sieciowym).

---

## Pain pointy i troubleshooting z W08

### 1. `Not authorized to perform sts:AssumeRoleWithWebIdentity`

**Objaw:** krok `Configure AWS credentials via OIDC` wielokrotnie loguje `Assuming role with OIDC`, po czasie rzuca błąd `Not authorized to perform sts:AssumeRoleWithWebIdentity`.

**Przyczyny, które wystąpiły:**

- Brak **warunku na `aud`** w trust policy (token miał `aud = sts.amazonaws.com`, ale rola nie weryfikowała tego).
- Za wąski / niepasujący **`sub`**:
  - najpierw trust policy z patternem `repo:wypiorsebastian/aws-learning-path:*` (za szeroka, ale działająca),
  - potem zawężenie do `ref:refs/heads/main` / `pull_request`,
  - po dodaniu `environment: dev` token zaczął mieć `sub = repo:wypiorsebastian/aws-learning-path:environment:dev`, więc nie pasował.

**Jak naprawiliśmy:**

- Trust policy roli `GitHubActionsRole` dostała:
  - `StringEquals` na `token.actions.githubusercontent.com:aud = sts.amazonaws.com`,
  - `StringLike` na `token.actions.githubusercontent.com:sub` zawierające:
    - `ref:refs/heads/master` (domyślna gałąź repo),
    - `ref:refs/heads/main` (na przyszłość),
    - `pull_request`,
    - `environment:dev`.

**Wzorzec ogólny:**

- Jeśli OIDC działał i nagle przestał po zmianie triggera (np. dodaniu environment), **pierwsze miejsce do sprawdzenia to `sub` w trust policy**:
  - dopasować do realnej wartości z CloudTrail (`AssumeRoleWithWebIdentity`),
  - dodać brakujące patterny.

### 2. `Missing Required Value` — backend S3 (`bucket`, `key`)

**Objaw:** `terraform init` w CI zwraca:

- `The attribute "bucket" is required by the backend.`
- `The attribute "key" is required by the backend.`

**Przyczyna:**

- W repo `backend.tf` zawiera tylko:

```hcl
terraform {
  backend "s3" {
    use_lockfile = true
  }
}
```

- Lokalnie brak problemu, bo użytkownik miał `backend.dev.hcl` (niecommitowany) i wołał `terraform init -backend-config=backend.dev.hcl`.
- W CI init był wywoływany **bez** `-backend-config`, więc backend nie znał `bucket` i `key`.

**Jak naprawiliśmy:**

- W obu workflowach dodaliśmy krok `Write backend config for CI`, który generuje `backend.ci.hcl` z:
  - `bucket = "${{ vars.TF_BACKEND_BUCKET }}"`,
  - `key = "dev/terraform.tfstate"`,
  - `region = "${{ env.AWS_REGION }}"`.
- `terraform init` wywoływany jest z `-backend-config=backend.ci.hcl`.

**Wzorzec ogólny:**

- Jeśli backend S3 jest parametryzowany przez plik `.hcl` (lokalny), w CI **trzeba odtworzyć ten plik na podstawie zmiennych / secrets**.

### 3. `ResourceAlreadyExistsException` — CloudWatch Logs log group

**Objaw:** podczas pierwszego `terraform apply` (lokalnie lub w CI) błąd:

- `ResourceAlreadyExistsException: The specified log group already exists`

**Przyczyna:**

- W AWS istniał już log group `orderflow-dev-vpc-flow-logs` (utworzony ręcznie / z wcześniejszych eksperymentów),
- Terraform próbował stworzyć **taki sam** log group, bo w state go jeszcze nie było.

**Ścieżki rozwiązania:**

- **Na szybko (dev / lab):**
  - usunąć log group w AWS:

```bash
aws logs delete-log-group \
  --log-group-name orderflow-dev-vpc-flow-logs \
  --region eu-central-1
```

  - ponownie uruchomić `terraform apply` (Terraform stworzy log group od zera).

- **Bardziej „enterprise”:**
  - zaimportować istniejący log group do state:

```bash
cd infra/terraform/envs/dev
terraform init -backend-config=backend.dev.hcl   # lokalnie
terraform import \
  'module.network_endpoints.aws_cloudwatch_log_group.vpc_flow_logs[0]' \
  orderflow-dev-vpc-flow-logs
```

  - dopiero potem `terraform apply`.

**Wzorzec ogólny:**

- Jeżeli Terraform próbuje utworzyć zasób, który już istnieje w AWS, masz wybór:
  - **usunąć** istniejący zasób (dev / lab),  
  - albo **zaimportować** go do state (prod / ważne środowiska).

---

## Pułapki i dobre praktyki

- **OIDC i trust policy:**
  - Zawsze weryfikuj **`aud`** (`sts.amazonaws.com`) i **`sub`** (repo + event).
  - Po zmianie triggerów (PR → environment, main → master) aktualizuj patterny `sub`.
  - Unikaj za szerokiego `sub` typu `repo:OWNER/REPO:*` w środowiskach innych niż lab.

- **Backend state:**
  - Trzymaj konfigurację backendu w jednym miejscu (lokalnie `backend.dev.hcl`, w CI `backend.ci.hcl` generowany z environment).
  - Nie commituj plików z pełnymi nazwami bucketów, jeśli planujesz reużywać repo w innym koncie.

- **Apply w CI:**
  - W dev dopuszczalne jest `-auto-approve`, ale:
    - rozważ manualny gate (environment approval) dla apply,
    - ogranicz joba do konkretnego katalogu (`infra/terraform/envs/dev`).

- **Import vs. manual cleanup:**
  - W środowisku naukowym / dev często szybciej jest **usunąć zasób** i pozwolić Terraformowi go odtworzyć.
  - W środowiskach krytycznych preferuj **`terraform import`** zamiast ręcznego usuwania.

---

## Checklist operacyjny (dev)

- [ ] W IAM istnieje provider OIDC `token.actions.githubusercontent.com` z `aud = sts.amazonaws.com`.
- [ ] Rola `GitHubActionsRole` ma trust policy:
  - [ ] `aud = sts.amazonaws.com`,
  - [ ] `sub` zawiera `ref:refs/heads/master`, `pull_request`, `environment:dev`.
- [ ] W GitHub → Environments istnieje `dev` z:
  - [ ] zmienną `TF_BACKEND_BUCKET = orderflow-dev-terraform-state-292187657518`,
  - [ ] (opcjonalnie) required reviewers dla apply.
- [ ] Workflow `Terraform Plan (dev)`:
  - [ ] przechodzi `Configure AWS credentials via OIDC`,
  - [ ] `terraform init` + `validate` + `plan` działają bez błędów.
- [ ] Workflow `Terraform Apply (dev)`:
  - [ ] wymaga zakładanego gate’a (manual / merge),
  - [ ] `terraform apply` kończy się sukcesem,
  - [ ] w AWS widać zasoby dev zgodne z planem (VPC, endpoints, Flow Logs).

