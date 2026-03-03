## W07 — evidence

Dowody wykonania zadań i spełnienia DoD. Roadmapa oczekuje: network-core + network-endpoints wdrożone; terraform plan stabilny; smoke tests udokumentowane.

---

### W07-T01 — Moduł network-endpoints
- **Oczekiwane:** Pliki HCL w `infra/terraform/modules/network-endpoints/*` (Gateway S3/DynamoDB, Interface Secrets/SSM, Flow Logs).
- **Link / opis:** `infra/terraform/modules/network-endpoints/` — moduł zawiera definicje Gateway Endpointów (S3, DynamoDB), Interface Endpointów (Secrets, SSM) oraz VPC Flow Logs (CloudWatch Logs + IAM role/policy).

### W07-T02 — Integracja w envs/dev
- **Oczekiwane:** Wywołanie `module "network_endpoints"` w `envs/dev/main.tf` z outputów network_core.
- **Link / opis:** `infra/terraform/envs/dev/main.tf` — dodany blok `module "network_endpoints"` korzystający z outputów `module.network_core` (`vpc_id`, `private_route_table_id`, `private_subnet_ids`, `sg_ecs_id`).

### W07-T03 — terraform apply
- **Oczekiwane:** Zasoby w AWS; `terraform state list`; plan po apply bez driftu.
- **Link / opis:** Ręcznie wykonane `terraform apply` w `infra/terraform/envs/dev` z `AWS_PROFILE=swpr-dev` (pierwszy pełny deploy sieci). Po apply: `terraform state list` lokalnie pokazuje zasoby `module.network_core.*` i `module.network_endpoints.*`; ponowny `terraform plan` lokalnie nie pokazuje istotnego driftu.

### W07-T04 — Runbook smoke tests
- **Oczekiwane:** `docs/runbooks/network-smoke-tests.md` rozszerzony o VPC Endpoints i Flow Logs.
- **Link / opis:** `docs/runbooks/network-smoke-tests.md` — dodane sekcje 2.6 (Gateway Endpoints S3/DynamoDB), 2.7 (Interface Endpoints Secrets/SSM) oraz uzupełniona checklista o Flow Logs.

### W07-T05 — W07-summary
- **Oczekiwane:** `docs/lessons/W07-summary.md` — co wdrożono, pułapki, gotowość pod W08.
- **Link / opis:** `docs/lessons/W07-summary.md` — opisuje wdrożone endpointy i Flow Logs, zaobserwowane pułapki (opisy SG, istniejąca log group, koszty) oraz gotowość pod W08 (pipeline IaC).

### DoD
- **Kryterium:** network-core + network-endpoints wdrożone; terraform plan po apply bez driftu; smoke tests udokumentowane.
- **Potwierdzenie:** DoD spełniony (2026-03-02). Moduł `network-core` i `network-endpoints` wdrożone w dev (pierwszy manualny `terraform apply`); lokalny `terraform state list`/`plan` po apply potwierdzają stabilny stan; runbook `network-smoke-tests.md` rozszerzony o VPC Endpoints i Flow Logs.
