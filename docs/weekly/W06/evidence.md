## W06 — evidence

Dowody wykonania zadań i spełnienia DoD. Roadmapa oczekuje: backend S3 (use_lockfile) skonfigurowany; moduł `network-core` istnieje; `terraform fmt`, `terraform validate`, `terraform plan` bez błędów.

---

### W06-T01 — Bootstrap S3
- **Oczekiwane:** Bucket S3 istnieje; bucket ma versioning, encryption, block public access; runbook bootstrapu.
- **Link / opis:** Konfiguracja Terraform w `infra/terraform/bootstrap/` (S3, versioning, encryption, block public access). Runbook: `docs/runbooks/terraform-backend-bootstrap.md`. Weryfikacja bucketu: uruchom lokalnie `AWS_PROFILE=swpr-dev terraform apply` w `infra/terraform/bootstrap/` (jeśli bucket już istnieje, plan będzie pusty); `terraform output s3_bucket_name`.

### W06-T02 — Backend config + Terraform basics
- **Oczekiwane:** `envs/dev/backend.tf` skonfigurowany; `terraform init` używa backend S3; notatka Terraform basics w `docs/lessons/W06-summary.md`.
- **Link / opis:** `infra/terraform/envs/dev/backend.tf` (key, use_lockfile); `backend.dev.hcl.example`; provider i variables w main.tf/variables.tf; runbook rozszerzony o init envs/dev. Notatka: `docs/lessons/W06-summary.md`. Weryfikacja: skopiuj `backend.dev.hcl.example` → `backend.dev.hcl`, wstaw bucket z bootstrap output, uruchom `terraform init -backend-config=backend.dev.hcl` w envs/dev.

### W06-T03 — Implementacja modułu `network-core`
- **Oczekiwane:** Pliki HCL w `infra/terraform/modules/network-core/*` (VPC, subnets, IGW, NAT, route tables, SG); `terraform fmt/validate/plan` przechodzi.
- **Link / opis:** `infra/terraform/modules/network-core/` (main.tf, variables.tf, outputs.tf, versions.tf, security.tf); wywołanie modułu w `envs/dev/main.tf`. Weryfikacja: `AWS_PROFILE=swpr-dev terraform init/validate/plan` — 27 zasobów do utworzenia.

### W06-T04 — Standard _standards.md
- **Oczekiwane:** Plik `infra/terraform/modules/_standards.md` z konwencjami variables, locals, outputs, tagging.
- **Link / opis:** `infra/terraform/modules/_standards.md` — struktura plików, naming (name_prefix), tagowanie (ADR-0002), variables, outputs, locals. Moduł `network-core` spójny ze standardem (bez zmian).

### W06-T05 — README + runbook bootstrap
- **Oczekiwane:** `infra/terraform/README.md` opisujące strukturę i sposób użycia; `docs/runbooks/terraform-backend-bootstrap.md` z procedurą bootstrapu i IAM pod CI/CD.
- **Link / opis:** `infra/terraform/README.md` — struktura katalogów (bootstrap, modules, envs/dev), przepływ pracy (bootstrap → init → plan → apply), tabela modułów, odwołania do W04, runbooku, smoke tests. `docs/runbooks/terraform-backend-bootstrap.md` — rozszerzono sekcję IAM (least privilege, .tflock), dodano odwołania do W04-*, network-smoke-tests, ADR-0003.

### DoD
- **Kryterium:** Backend S3 (use_lockfile) skonfigurowany; Terraform foundations zrozumiane; moduł network-core istnieje i przechodzi `fmt/validate/plan`.
- **Potwierdzenie:** DoD spełniony (2026-03-02). Wszystkie 5 tasków DONE. `terraform init/validate/plan` z `AWS_PROFILE=swpr-dev` przechodzą; plan: 27 zasobów network-core.
