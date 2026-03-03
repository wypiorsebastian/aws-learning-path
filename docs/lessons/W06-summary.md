# W06 — Terraform backend + foundations + network-core (skrót)

## Cel tygodnia

Bootstrappować backend S3 (use_lockfile), skonfigurować go w envs/dev i zaimplementować moduł network-core. Apply w W07.

## Terraform basics — skrót

### Provider

- **Co:** W `provider "aws" { region = var.region }` konfigurujemy dostawcę usług (AWS).
- **Po co:** Terraform wie, z którym regionem i kontem rozmawia; credentials z AWS CLI / zmiennych środowiskowych (np. `AWS_PROFILE`).
- **Kiedy:** W każdym katalogu z konfiguracją (root module); w modułach zwykle nie powtarzamy providera (dziedziczy z root).

### Variables i outputs

- **Variables:** `variable "name" { type = string, default = "..." }` — wejścia do modułu lub do root; można nadpisać przez `terraform.tfvars` lub `-var`.
- **Outputs:** `output "name" { value = resource.attr }` — wartości na zewnątrz (konsola, inne moduły, `terraform_remote_state`).
- **Po co:** Konfiguracja parametryzowana; moduły zwracają np. `vpc_id`, `subnet_ids` do wyższego poziomu.

### Moduły

- **Co:** `module "network_core" { source = "../../modules/network-core"; vpc_cidr = var.vpc_cidr }` — wywołanie innego katalogu z zasobami.
- **Po co:** Reużycie (network-core, network-endpoints); root w envs/dev tylko łączy moduły i przekazuje zmienne.
- **Input/output:** Moduł ma `variables.tf` i `outputs.tf`; root przekazuje variables i odbiera outputs.

### Komendy

- **terraform init:** Pobiera providery i (gdy jest backend) konfiguruje backend; wymagane po clone lub zmianie backendu.
- **terraform fmt:** Formatuje pliki `.tf` (spójny styl).
- **terraform validate:** Sprawdza składnię i podstawową spójność (np. odwołania do zasobów).
- **terraform plan:** Pokazuje plan zmian (bez apply); wymaga init i poprawnej konfiguracji (w tym backendu).
- **terraform apply:** Wykonuje plan (tworzy/zmienia/usuwa zasoby); zapisuje state w backendzie (S3 przy envs/dev).

### Backend S3 (envs/dev)

- **bucket:** Z bootstrapu (`terraform output -raw s3_bucket_name`).
- **key:** np. `dev/terraform.tfstate`.
- **use_lockfile = true:** Lock przez plik `.tflock` w S3 (Terraform ≥1.10); brak DynamoDB.
- **Pierwszy init:** `terraform init -backend-config=backend.dev.hcl` po utworzeniu `backend.dev.hcl` z bucket i region.

## W06-T01 / W06-T02 — co zrobiono

- **T01:** Bootstrap S3 w `infra/terraform/bootstrap/`; runbook `docs/runbooks/terraform-backend-bootstrap.md`.
- **T02:** envs/dev z `backend.tf` (key, use_lockfile), `backend.dev.hcl.example`, provider, variables, versions; init z `-backend-config=backend.dev.hcl` po uzupełnieniu bucketu.

## Następny krok (W06-T03)

Implementacja modułu `network-core` w `infra/terraform/modules/network-core/` i wywołanie go z `envs/dev/main.tf`.
