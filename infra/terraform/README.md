# Terraform — OrderFlow AWS Lab

Infrastruktura jako kod (IaC) dla projektu OrderFlow AWS Lab. Środowisko: **dev-only** (konto `swpr-dev`, region `eu-central-1`).

## Struktura katalogów

```
infra/terraform/
├── bootstrap/           # Jednorazowy bootstrap: bucket S3 dla Terraform state
├── modules/             # Moduły Terraform (reużywalne)
│   ├── _standards.md    # Konwencje: variables, outputs, tagging (ADR-0002)
│   ├── network-core/    # VPC, subnety, IGW, NAT, route tables, SG
│   └── network-endpoints/  # (W07) Gateway + Interface VPC Endpoints
└── envs/
    └── dev/             # Konfiguracja środowiska dev
        ├── backend.tf   # Backend S3 (partial config)
        ├── backend.dev.hcl.example  # Przykład konfiguracji backendu
        ├── main.tf      # Provider + wywołania modułów
        ├── variables.tf
        └── versions.tf
```

## Przepływ pracy

### 1. Bootstrap (jednorazowo)

Przed pierwszym użyciem `envs/dev` trzeba utworzyć bucket S3 dla stanu Terraform.

- **Dokumentacja:** `docs/runbooks/terraform-backend-bootstrap.md`
- **Lokalizacja:** `infra/terraform/bootstrap/`
- **Kroki:** `cd bootstrap` → `terraform init` → `terraform apply` → zapisz output `s3_bucket_name`

### 2. Konfiguracja backendu w envs/dev

1. Skopiuj `backend.dev.hcl.example` do `backend.dev.hcl` (plik w `.gitignore`).
2. Uzupełnij `bucket` — nazwa z bootstrapu (`terraform output -raw s3_bucket_name`).
3. Ustaw `key` (np. `dev/terraform.tfstate`) i `region` (np. `eu-central-1`).

### 3. Init, plan, apply

```bash
export AWS_PROFILE=swpr-dev   # lub alias aws-dev

cd infra/terraform/envs/dev
terraform init -backend-config=backend.dev.hcl
terraform fmt
terraform validate
terraform plan
# terraform apply  # W07 — po implementacji modułu network-endpoints
```

### 4. Weryfikacja

- `terraform state list` — zasoby w stanie
- `terraform plan` — brak driftu (po apply)

## Moduły

| Moduł | Opis | Konsumuje |
|-------|------|-----------|
| **network-core** | VPC, subnety, IGW, NAT, route tables, SG | — |
| **network-endpoints** (W07) | Gateway (S3, DynamoDB), Interface (Secrets, SSM), Flow Logs | outputy network-core |

## Powiązane dokumenty

- **Design sieci:** `docs/lessons/W04-network-core-module-design.md`, `docs/lessons/W04-traffic-models.md`, `docs/lessons/W04-sg-nacl-baseline.md`
- **Endpoints (W05):** `docs/lessons/W05-endpoints-design.md`
- **Konwencje modułów:** `modules/_standards.md`
- **Bootstrap:** `docs/runbooks/terraform-backend-bootstrap.md`
- **Smoke tests sieci:** `docs/runbooks/network-smoke-tests.md`
