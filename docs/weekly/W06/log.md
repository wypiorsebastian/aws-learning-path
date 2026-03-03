## W06 — log tygodnia

Log wpisów chronologicznie; każdy wpis z datą/czasem i powiązanym TaskId.

---

- **2026-02-26** — Start tygodnia W06. Przeczytana sekcja W06 z roadmapy. _TaskId: —_
- **2026-03-02** — W06-T01 DONE: konfiguracja bootstrap S3 w `infra/terraform/bootstrap/` (versioning, encryption, block public access); utworzono runbook `docs/runbooks/terraform-backend-bootstrap.md`. Bucket do weryfikacji lokalnie: `AWS_PROFILE=swpr-dev terraform apply` w bootstrap. _TaskId: W06-T01_
- **2026-03-02** — W06-T02 DONE: utworzono `infra/terraform/envs/dev/` z backend.tf (S3, key, use_lockfile), backend.dev.hcl.example, versions.tf, variables.tf, main.tf (provider); rozszerzono runbook o init envs/dev; utworzono `docs/lessons/W06-summary.md` (Terraform basics). _TaskId: W06-T02_
- **2026-03-02** — W06-T03 DONE: moduł `network-core` (VPC, subnety, IGW, NAT, route tables, SG); wywołanie w envs/dev/main.tf; terraform init/validate/plan OK. _TaskId: W06-T03_
- **2026-03-02** — W06-T04 DONE: utworzono `infra/terraform/modules/_standards.md` z konwencjami variables, locals, outputs, tagging (ADR-0002); network-core spójny ze standardem. _TaskId: W06-T04_
- **2026-03-02** — W06-T05 DONE: utworzono `infra/terraform/README.md` (struktura, przepływ pracy); uzupełniono runbook bootstrap (IAM least privilege, .tflock, odwołania W04, network-smoke-tests). _TaskId: W06-T05_
