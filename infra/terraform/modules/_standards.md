# Konwencje Terraform — moduły OrderFlow AWS Lab

Dokument definiuje standardy dla modułów Terraform w projekcie `OrderFlow AWS Lab`.  
**Input:** `docs/lessons/W04-network-core-module-design.md`, `docs/adr/ADR-0002-cost-guardrails-dev.md`.  
**Wzorzec referencyjny:** moduł `network-core`.

---

## 1. Struktura plików modułu

| Plik | Przeznaczenie |
|------|---------------|
| `main.tf` | Zasoby główne (VPC, subnety, IGW, NAT, route tables, associations, itp.) |
| `variables.tf` | Wejścia modułu — wszystkie parametry z zewnątrz |
| `outputs.tf` | Wyjścia dla root/envs i innych modułów |
| `versions.tf` | `required_version`, `required_providers` (np. aws ~> 5.0) |
| `security.tf` | Opcjonalnie — Security Groups, gdy moduł zarządza SG |
| `locals.tf` | Opcjonalnie — przy większej ilości locals; zwykle `locals` w `main.tf` |

**Moduł referencyjny:** `modules/network-core/` — main.tf, variables.tf, outputs.tf, versions.tf, security.tf.

---

## 2. Nazewnictwo (name_prefix)

- **Zmienna:** `name_prefix` (string), np. `orderflow-dev`.
- **Wzorzec nazw zasobów:** `{name_prefix}-{zasób}`.

### Sufiksy zasobów (wzorzec z network-core)

| Typ zasobu | Sufiks | Przykład |
|------------|--------|----------|
| VPC | `-vpc` | `orderflow-dev-vpc` |
| Subnety public | `-public-a`, `-public-b` | `orderflow-dev-public-a` |
| Subnety private | `-private-a`, `-private-b` | `orderflow-dev-private-a` |
| Route table public | `-public-rt` | `orderflow-dev-public-rt` |
| Route table private | `-private-rt` | `orderflow-dev-private-rt` |
| Internet Gateway | `-igw` | `orderflow-dev-igw` |
| NAT Gateway | `-nat` | `orderflow-dev-nat` |
| EIP dla NAT | `-nat-eip` | `orderflow-dev-nat-eip` |
| SG ALB | `-alb-sg` | `orderflow-dev-alb-sg` |
| SG ECS/Lambda | `-ecs-sg` | `orderflow-dev-ecs-sg` |
| SG RDS | `-rds-sg` | `orderflow-dev-rds-sg` |

Każdy moduł powinien przyjmować `name_prefix` i stosować go konsekwentnie we wszystkich zasobach.

---

## 3. Tagowanie (zgodnie z ADR-0002)

### Tagi obowiązkowe (dla każdego zasobu)

| Tag | Wartość | Źródło |
|-----|---------|--------|
| `Project` | `OrderFlow-AWS-Lab` | Stała |
| `Env` | `dev` | Stała dla środowiska dev |
| `ManagedBy` | `terraform` | Stała |
| `Module` | Nazwa modułu (np. `network-core`) | Stała w module |
| `Name` | Opisowa nazwa zasobu (np. `{name_prefix}-vpc`) | Indywidualna per zasób |

### Tagi opcjonalne (ADR-0002 — cost guardrails)

| Tag | Opis | Użycie |
|-----|------|--------|
| `Owner` | Właściciel / uczestnik | Opcjonalnie; ułatwia accountability |
| `TTL` | Czas życia (np. `session`, `week`, `temporary`) | Opcjonalnie; dla drogich zasobów — świadomy cleanup |

### Wzorzec locals

```hcl
locals {
  common_tags = merge(var.tags, {
    Project   = "OrderFlow-AWS-Lab"
    Env       = "dev"
    ManagedBy = "terraform"
    Module    = "network-core"  # nazwa modułu
  })
}
```

### Użycie w zasobie

```hcl
resource "aws_vpc" "this" {
  # ...
  tags = merge(local.common_tags, {
    Name = "${var.name_prefix}-vpc"
  })
}
```

- `var.tags` — mapa przekazana z root; pozwala dodać np. `Owner`, `TTL`.
- `merge` — tagi z `var.tags` mogą nadpisać wartości, jeśli potrzeba.

---

## 4. Variables

- **Każda zmienna:** `description`, `type`, sensowny `default` (o ile możliwe).
- **Zmienne wspólne we wszystkich modułach:**
  - `name_prefix` (string) — prefix nazw zasobów.
  - `tags` (map(string), default `{}`) — tagi bazowe do merge z common_tags.
- **Zmienne specyficzne modułu:** vpc_cidr, azs, subnet_cidrs, enable_*, itp.

### Przykład

```hcl
variable "name_prefix" {
  description = "Prefix w nazwach zasobów (np. orderflow-dev)"
  type        = string
  default     = "orderflow-dev"
}

variable "tags" {
  description = "Tagi bazowe (Project, Env itp.); będą zmergowane z common_tags w module"
  type        = map(string)
  default     = {}
}
```

---

## 5. Outputs

- **Każdy output:** `description` z informacją o konsumencie (np. „— dla ALB”, „— W05 doda trasy do tej route table”).
- **Nazwy po angielsku**, deskryptywne.
- **Konsumenci:** root (envs/dev), inne moduły (np. network-endpoints korzysta z `private_route_table_id`, `private_subnet_ids`).

### Przykład

```hcl
output "private_route_table_id" {
  description = "ID route table private — W05 doda trasy Gateway Endpoint (S3, DynamoDB)"
  value       = aws_route_table.private.id
}
```

---

## 6. Locals

- **common_tags** — zawsze w module; merge z `var.tags`.
- **Inne locals** — gdy upraszczają logikę (np. listy ID subnetów). Przy małej ilości można trzymać w `main.tf`.

---

## 7. Powiązane dokumenty

- `docs/lessons/W04-network-core-module-design.md` — design modułu network-core.
- `docs/adr/ADR-0002-cost-guardrails-dev.md` — cost guardrails, tagowanie, cleanup.
- `docs/runbooks/terraform-network-core-workbook.md` — instrukcja budowy modułu network-core.
