# Moduł `network-core` — szczegółowa dokumentacja

## 1. Po co istnieje moduł `network-core`

Moduł `network-core` jest **fundamentem sieci dev**:

- tworzy **VPC**, subnety, bramy, routing i bazowe Security Groups,
- jest **jedynym miejscem**, w którym definiujemy „twardą” topologię sieci:
  - adresację (`10.0.0.0/16`, podziały na subnety),
  - które subnety są publiczne, a które prywatne,
  - którędy wychodzi ruch (`IGW`, `NAT Gateway`, route tables),
  - jaki jest bazowy model bezpieczeństwa (`sg_alb`, `sg_app`, `sg_rds`).

Wszystkie kolejne elementy (endpointy, ALB, ECS, RDS, Lambda) **doklejają się** do tej warstwy, ale jej nie zmieniają.

**Azure analogia:**  
`network-core` to odpowiednik modułu, który tworzy:

- VNet + subnety,
- NAT Gateway + UDR,
- NSG dla frontu, aplikacji i bazy.

---

## 2. Struktura modułu

Lokalizacja: `infra/terraform/modules/network-core/`

- `versions.tf` — wersje Terraform i providera AWS.
- `variables.tf` — wejścia modułu (CIDR, AZ, prefix nazw, tagi).
- `main.tf` — VPC, subnety, IGW, NAT, route tables, associations.
- `security.tf` — trzy Security Groups (`sg_alb`, `sg_app`, `sg_rds`) i reguły.
- `outputs.tf` — identyfikatory VPC, subnetów, route tables, SG (do użycia przez inne moduły, np. `network-endpoints`).

Każdy z tych plików jest mały i ma jedno główne zadanie — to jest celowe, żeby łatwo się po nich poruszać.

---

## 3. `versions.tf` — wymagania modułu

```hcl
terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}
```

**Po co:**

- Gwarantuje, że:
  - używasz Terraform w wersji co najmniej 1.0 (spójne z resztą repo),
  - używasz providera AWS w gałęzi 5.x (API providera jest stabilne, współgra z resztą modułów).
- Dzięki temu:
  - `terraform init` wie, jaką wersję providera pobrać,
  - unikasz subtelnych różnic między starymi a nowymi wersjami providera (np. inne nazwy pól, deprecations).

---

## 4. `variables.tf` — wejścia modułu

Najważniejsze zmienne:

- `vpc_cidr` (`string`, domyślnie `"10.0.0.0/16"`)
  - zakres adresów dla VPC.
  - **Dlaczego /16:** wystarczająco dużo miejsca na subnety i przyszłe rozszerzenia, bez ryzyka „skończyły się adresy”.
- `azs` (`list(string)`, domyślnie `["eu-central-1a", "eu-central-1b"]`)
  - lista AZ, w których tworzymy subnety.
  - **Dlaczego 2 AZ:** uczysz się multi-AZ, ale nie komplikujesz sobie życia trzecią AZ.
- `public_subnet_cidrs` (`list(string)`, domyślnie `["10.0.1.0/24", "10.0.2.0/24"]`)
  - CIDR-y publicznych subnetów.
  - **Publiczne = z IGW i możliwością publicznych IP** (np. ALB, NAT).
- `private_subnet_cidrs` (`list(string)`, domyślnie `["10.0.11.0/24", "10.0.12.0/24"]`)
  - CIDR-y prywatnych subnetów.
  - **Prywatne = brak publicznych IP, ruch wychodzący przez NAT**.
- `enable_nat_gateway` (`bool`, domyślnie `true`)
  - czy tworzyć NAT Gateway.
  - w dev chcemy go mieć (realistyczny scenariusz), ale mieć możliwość wyłączenia, gdyby kiedyś trzeba było.
- `single_nat` (`bool`, domyślnie `true`)
  - placeholder na przyszłość (1 NAT vs NAT per AZ).
- `name_prefix` (`string`, domyślnie `"orderflow-dev"`)
  - prefix nazw zasobów (`orderflow-dev-vpc`, `orderflow-dev-public-a`, itp.).
- `tags` (`map(string)`, domyślnie `{}`)
  - dodatkowe tagi, które zostaną zmergowane z `common_tags`.
- `app_port` (`number`, domyślnie `8080`)
  - port aplikacji (ALB → ECS/Lambda), używany w SG.

**Dlaczego tak:**

- wartości domyślne pozwalają „postawić” całą sieć bez podawania parametrów,
- ale w razie potrzeby możesz:
  - zmienić CIDR, AZ, nazwę prefixu,
  - wyłączyć NAT (np. w jakimś specjalnym labie).

---

## 5. `main.tf` — VPC, subnety, IGW, NAT, routing

### 5.1 `locals.common_tags`

```hcl
locals {
  common_tags = merge(var.tags, {
    Project   = "OrderFlow-AWS-Lab"
    Env       = "dev"
    ManagedBy = "terraform"
    Module    = "network-core"
  })
}
```

- **Cel:** Spójne tagowanie zasobów (wg ADR-0002).
- Dzięki temu:
  - w AWS Console możesz łatwo filtrować zasoby po `Project`, `Env`, `Module`,
  - w billingu widzisz, ile kosztuje moduł `network-core`.

### 5.2 VPC

```hcl
resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = merge(local.common_tags, {
    Name = "${var.name_prefix}-vpc"
  })
}
```

- **Po co:**
  - VPC to „kontener” sieci — odpowiednik VNet.
  - `enable_dns_hostnames` i `enable_dns_support` są włączone, żeby:
    - ECS/Lambda/RDS mogły używać DNS,
    - VPC Endpoints z Private DNS działały poprawnie.

### 5.3 Subnety publiczne

`aws_subnet.public_a` i `aws_subnet.public_b`:

- w AZ `a` i `b`,
- `map_public_ip_on_launch = true`.

**Po co:**

- to tutaj wylądują:
  - IGW (logicznie),
  - NAT Gateway,
  - ALB (w przyszłości),
- każdy ENI w tym subnecie może dostać publiczne IP (np. ENI ALB).

### 5.4 Subnety prywatne

`aws_subnet.private_a` i `aws_subnet.private_b`:

- w AZ `a` i `b`,
- `map_public_ip_on_launch = false`.

**Po co:**

- to tutaj będą:
  - ECS tasks,
  - RDS,
  - Lambda z VPC,
  - ENI interface endpointów (Secrets/SSM).
- prywatne = brak bezpośredniego wejścia z Internetu.

### 5.5 IGW, NAT, route tables

**IGW:**

```hcl
resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id
  ...
}
```

- łączy publiczne subnety z Internetem.

**NAT Gateway:**

```hcl
resource "aws_nat_gateway" "this" {
  count = var.enable_nat_gateway ? 1 : 0

  allocation_id = aws_eip.nat[0].id
  subnet_id     = aws_subnet.public_a.id
  ...
}
```

- siedzi w `public-a`,
- private subnety wychodzą na Internet przez NAT.

**Route tables:**

- publiczna:
  - `local` dla `10.0.0.0/16`,
  - `0.0.0.0/0 → IGW`.
- prywatna:
  - `local` dla `10.0.0.0/16`,
  - `0.0.0.0/0 → NAT`.

**Dlaczego tak:**

- publiczne subnety muszą mieć bezpośredni dostęp do Internetu (ALB, NAT),
- prywatne subnety mają wyjście przez NAT:
  - pozwala to im korzystać z Internetu / usług publicznych (np. SQS, zewn. API),
  - ale same nie są routowane z Internetu.

### 5.6 Route table associations

- każdemu subnetowi przypisujemy jedną route table:
  - `public-a/b` → publiczna RT,
  - `private-a/b` → prywatna RT.

Bez tego:

- subnet korzystałby z **main route table** (domyślnej), co byłoby niejawne i trudniejsze do zrozumienia.

---

## 6. `security.tf` — Security Groups

### 6.1 `sg_alb` — ALB (front door)

- Ingress:
  - `0.0.0.0/0:80,443` — HTTP/HTTPS z Internetu.
- Egress:
  - do `sg_app` na `app_port` (np. 8080).

**Po co:**

- ALB jest jedynym miejscem, które przyjmuje ruch z Internetu,
- ruch z ALB do aplikacji w private jest ograniczony:
  - tylko na konkretny port,
  - tylko do SG aplikacyjnego (`sg_app`), a nie „wszędzie”.

**Azure analogia:**  
NSG przypięty do subnetu/ENI Application Gateway z allow z Internetu na 80/443 i egress do backend poola.

### 6.2 `sg_app` — ECS/Lambda

- Ingress:
  - z `sg_alb` na `app_port`,
- Egress:
  - do `sg_rds:5432`,
  - do `0.0.0.0/0:80,443` (wyjście do NAT/endpointów),
  - (logicznie) do SG endpointów (w module `network-endpoints` obsługujemy to z drugiej strony).

**Po co:**

- aplikacje przyjmują ruch **tylko** z ALB (nie z Internetu bezpośrednio),
- mogą:
  - rozmawiać z bazą danych,
  - wychodzić do usług AWS i Internetu (przez NAT/endpointy),
  - wysyłać logi, sięgać do SQS/SNS itd.

### 6.3 `sg_rds` — baza danych

- Ingress:
  - wyłącznie z `sg_app:5432`.

**Po co:**

- baza jest całkowicie schowana:
  - brak ruchu z Internetu,
  - brak ruchu z ALB,
  - jedyne źródło ruchu to warstwa aplikacji.

**Azure analogia:**  
NSG dla Azure SQL/PostgreSQL, który wpuszcza tylko ruch z podsieci aplikacyjnej / NSG aplikacyjnego.

---

## 7. `outputs.tf` — co moduł wystawia na zewnątrz

Najważniejsze outputy:

- `vpc_id` — ID VPC.
- `vpc_cidr` — CIDR VPC.
- `public_subnet_ids`, `private_subnet_ids` oraz wersje per AZ (`*_id_a`, `*_id_b`).
- `public_route_table_id`, `private_route_table_id` — potrzebne m.in. dla Gateway Endpointów.
- `nat_gateway_id`, `igw_id` — referencje/billing/debug.
- `sg_alb_id`, `sg_ecs_id`, `sg_rds_id` — do użycia przez moduły aplikacyjne i `network-endpoints`.

**Po co:**

- modułu `network-endpoints` **nie interesuje**, jak dokładnie zbudowana jest sieć,
- chce tylko:
  - znać `vpc_id`,
  - wiedzieć, która route table jest „private”,
  - znać prywatne subnety i SG aplikacyjny,
- dlatego `network-core` wystawia to jako outputy.

---

## 8. Jak używamy `network-core` w `envs/dev`

W `infra/terraform/envs/dev/main.tf`:

```hcl
module "network_core" {
  source = "../../modules/network-core"

  vpc_cidr             = "10.0.0.0/16"
  azs                  = ["eu-central-1a", "eu-central-1b"]
  public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnet_cidrs = ["10.0.11.0/24", "10.0.12.0/24"]
  name_prefix          = "orderflow-dev"
  enable_nat_gateway   = true
  tags                 = {}
}
```

- `envs/dev` nie definiuje VPC/subnetów/routingu samodzielnie,
- jedynie:
  - ustawia wartości wejściowe,
  - „składa” moduły (`network-core`, `network-endpoints`, później inne).

**Zysk:**

- jeden moduł `network-core` może być użyty:
  - w dev (`orderflow-dev`),
  - w przyszłym `test`/`qa` (`orderflow-qa`),
  - z innymi prefixami/namiarami, bez duplikowania kodu.

---

## 9. Podsumowanie — jak o tym myśleć

Jeśli po miesiącu przerwy chcesz szybko odzyskać obraz:

1. **VPC = pudło** z adresem `10.0.0.0/16`.
2. W środku masz:
   - dwa publiczne subnety (`10.0.1.0/24`, `10.0.2.0/24`) na ALB/NAT,
   - dwa prywatne subnety (`10.0.11.0/24`, `10.0.12.0/24`) na aplikacje/bazy/endpointy.
3. Publiczne mają trasę do **IGW**, prywatne do **NAT**.
4. SG tworzą prosty graf:
   - Internet → `sg_alb` → `sg_app` → `sg_rds`,
   - `sg_app` wychodzi na świat (przez NAT/endpointy) i do usług AWS.
5. Wszystko jest zamknięte w **moduł `network-core`**, który:
   - dostaje parametry (CIDR, AZ, prefix),
   - wystawia outputy (IDs VPC/subnetów/SG),
   - jest używany przez `envs/dev` i inne moduły.

Reszta sieci (endpointy, aplikacje) **tylko dokłada się** do tego szkieletu; nie musi znać jego szczegółów, zna tylko outputy.

