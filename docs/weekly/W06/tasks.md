## W06 — taski tygodnia

### Kontekst
- **WeekId:** `W06`
- **Cel tygodnia:** Bootstrappować remote state (S3 + natywny lock plikowy `use_lockfile`) zgodnie z best practices, skonfigurować backend i zaimplementować moduł `network-core` (VPC, subnets, IGW, NAT, route tables, SG, NACL).
- **Outcome:** Remote state działa od dnia 1; moduł `network-core` zaimplementowany; `terraform fmt/validate/plan` bez błędów; gotowość do apply w W07.

---

## Taski bazowe z roadmapy

### W06-T01 — Bootstrap bucket S3 dla Terraform state (enterprise)

- **TaskId:** `W06-T01`
- **Status:** `DONE`
- **Priorytet:** `P1`
- **Typ:** `IaC`
- **Cel:** Utworzyć bucket S3 dla Terraform backend zgodnie z best practices (versioning, encryption, block public access). Lock stanu: natywny S3 (`use_lockfile = true`, plik `.tflock` w bucketcie; Terraform ≥1.10).
- **Estymata:** 45m
- **Input:**
  - Sekcja W06 w `docs/roadmap/aws-course-roadmap-operational-0-24.md`
  - Dokumentacja Terraform S3 backend (use_lockfile)
- **Kroki:**
  1. Utworzyć bucket S3 dla state: włącz versioning, SSE-S3 (encryption), block public access.
  2. Zapisać procedurę w `docs/runbooks/terraform-backend-bootstrap.md` (bootstrap może być manual lub osobna konfiguracja Terraform z local state).
  3. Zweryfikować: bucket istnieje; bucket ma versioning i encryption.
- **Verification:** Bucket S3 istnieje; bucket ma versioning, encryption, block public access.
- **Evidence:** Bucket w konsoli AWS; `docs/runbooks/terraform-backend-bootstrap.md`.

---

### W06-T02 — Skonfiguruj backend "s3" w envs/dev; Terraform basics

- **TaskId:** `W06-T02`
- **Status:** `DONE`
- **Priorytet:** `P1`
- **Typ:** `IaC`
- **Cel:** Skonfigurować backend S3 w Terraform (bucket, key, region, `use_lockfile = true`) oraz uporządkować wiedzę o podstawach Terraform.
- **Estymata:** 30m
- **Input:**
  - Wynik W06-T01 (bucket)
  - Dokumentacja Terraform backend "s3" (use_lockfile)
- **Kroki:**
  1. Utworzyć `infra/terraform/envs/dev/backend.tf` (lub `backend` block w main) z: `bucket`, `key`, `region`, `use_lockfile = true`.
  2. Użyć `backend-config` lub partial configuration jeśli wartości z zewnątrz.
  3. Uruchomić `terraform init` — zweryfikować, że backend S3 jest aktywny.
  4. Uporządkować wiedzę o: provider AWS, variables, outputs, moduły, `fmt/validate/plan` (zapisać w `docs/lessons/W06-summary.md`).
- **Verification:** `terraform init` w envs/dev powoduje użycie backendu S3; `terraform state list` działa (pusty state OK).
- **Evidence:** `envs/dev/backend.tf`; fragment outputu `terraform init`; notatka w W06-summary.md.

---

### W06-T03 — Zaimplementuj moduł `network-core` (VPC, subnets, IGW, NAT, route tables, SG)

- **TaskId:** `W06-T03`
- **Status:** `DONE`
- **Priorytet:** `P1`
- **Typ:** `IaC`
- **Cel:** Zaimplementować w HCL moduł Terraform `network-core` zgodnie z designem z W04 (VPC, subnets, IGW, NAT, route tables, baseline SG).
- **Estymata:** 60m
- **Input:**
  - `docs/lessons/W04-network-core-module-design.md`
  - `docs/lessons/W04-sg-nacl-baseline.md`
  - `docs/diagrams/vpc-dev.md`, ADR-0004
- **Kroki:**
  1. Utworzyć strukturę `infra/terraform/modules/network-core/` (main.tf, variables.tf, outputs.tf, versions.tf).
  2. Zaimplementować VPC, subnets (public-a/b, private-a/b), IGW, EIP, NAT Gateway, route tables, associations, routes.
  3. Zaimplementować baseline SG (sg_alb, sg_app, sg_rds) zgodnie z W04-T03.
  4. Zaimplementować variables i outputs zgodnie z designem W04 (gotowe pod W05/W07).
  5. Dodać wywołanie modułu w `envs/dev/main.tf` i uruchomić `terraform init`, `fmt`, `validate`, `plan`.
- **Verification:** `terraform fmt`, `terraform validate`, `terraform plan` przechodzą bez błędów składni/logiki.
- **Evidence:** Pliki HCL w `infra/terraform/modules/network-core/*`; fragmenty outputu planu.

---

### W06-T04 — Ustal standard variables.tf, locals.tf, outputs.tf, tagging; modules/_standards.md

- **TaskId:** `W06-T04`
- **Status:** `DONE`
- **Priorytet:** `P1`
- **Typ:** `IaC/Docs`
- **Cel:** Udokumentować konwencje Terraform dla projektu (variables, locals, outputs, tagging) w pliku `modules/_standards.md`.
- **Estymata:** 30m
- **Input:**
  - Design W04 (variables, outputs),
  - ADR-0002 (tagging: Project, Env, ManagedBy, Module, Name).
- **Kroki:**
  1. Spisać konwencje: naming (name_prefix, zasoby), tagging (mapa wspólna), struktura plików modułu.
  2. Opisać wzorce dla variables (typ, default, description), locals (wspólne tagi), outputs (opis, konsument).
  3. Utworzyć `infra/terraform/modules/_standards.md` z tymi konwencjami.
  4. Zastosować je w module `network-core`.
- **Verification:** `_standards.md` istnieje i jest spójny z implementacją network-core.
- **Evidence:** `infra/terraform/modules/_standards.md`.

---

### W06-T05 — infra/terraform/README.md + docs/runbooks/terraform-backend-bootstrap.md

- **TaskId:** `W06-T05`
- **Status:** `DONE`
- **Priorytet:** `P2`
- **Typ:** `Docs`
- **Cel:** Przygotować README dla katalogu `infra/terraform/` oraz uzupełnić runbook bootstrapu (procedura, IAM pod CI/CD w W08).
- **Estymata:** 30m
- **Input:**
  - Struktura katalogów z designu W04,
  - Wynik W06-T01 (runbook bootstrapu — draft),
  - ADR-0003, `docs/runbooks/iam-role-matrix.md` (IAM pod CI/CD).
- **Kroki:**
  1. Opisać strukturę: `modules/network-core`, `envs/dev`, planowane `modules/network-endpoints`.
  2. Opisać kroki: bootstrap (odnośnik do runbooku), `terraform init`, `plan`, (W07) `apply`.
  3. Uzupełnić `docs/runbooks/terraform-backend-bootstrap.md`: procedura bootstrapu, wymagania IAM dla roli CI/CD (S3 — least privilege, w tym plik `.tflock`).
  4. Dodać odwołania do `docs/lessons/W04-*`, `docs/runbooks/network-smoke-tests.md`.
- **Verification:** README pozwala nowemu czytelnikowi zrozumieć strukturę i uruchomić plan; runbook opisuje bootstrap i IAM.
- **Evidence:** `infra/terraform/README.md`; `docs/runbooks/terraform-backend-bootstrap.md`.

---

## Verification (zbiorczy checklist z roadmapy)

- [x] Bucket S3 istnieje; bucket ma versioning, encryption, block public access
- [x] `terraform init` w `envs/dev` używa backend S3
- [x] `terraform fmt`
- [x] `terraform validate`
- [x] `terraform plan` dla network-core bez błędów składni/logiki

## Evidence (zbiorczy z roadmapy)

- `docs/lessons/W06-summary.md`
- `docs/runbooks/terraform-backend-bootstrap.md`
- `infra/terraform/modules/network-core/*` (pliki HCL)
- `infra/terraform/README.md`, `modules/_standards.md`
