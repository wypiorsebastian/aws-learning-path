## W07 — taski tygodnia

### Kontekst

- **WeekId:** `W07`
- **Cel tygodnia:** Zaimplementować moduł `network-endpoints` (na bazie designu W05) i wykonać pełny deploy warstwy sieciowej do dev.
- **Outcome:** Sieć dev z endpointami istnieje; `terraform state list` pokazuje zasoby; gotowość pod CI/CD (W08).
- **Uwaga:** Pierwszy manual apply = walidacja infra (100% pewność przed pipeline). Agent nie wykonuje operacji na infrastrukturze — tylko plan, analizy, dokumentacja.

---

## Taski bazowe z roadmapy

### W07-T01 — Zaimplementuj moduł network-endpoints (Gateway S3/DynamoDB, Interface Secrets/SSM, Flow Logs)

- **TaskId:** `W07-T01`
- **Status:** `DONE`
- **Priorytet:** `P1`
- **Typ:** `IaC`
- **Cel:** Zaimplementować moduł Terraform `network-endpoints` zgodnie z designem W05.
- **Estymata:** 45m
- **Input:**
  - `docs/lessons/W05-endpoints-design.md`
  - outputy modułu `network-core` (vpc_id, private_route_table_id, private_subnet_ids, sg_ecs_id)
- **Kroki:**
  1. Gateway Endpoints: S3, DynamoDB (powiązanie z private_route_table_id)
  2. SG sg_endpoints (ingress z sg_app:443)
  3. Interface Endpoints: Secrets Manager, SSM (private_dns_enabled = true)
  4. VPC Flow Logs (CloudWatch Logs)
- **Verification:** `terraform plan` pokazuje wszystkie zasoby modułu.
- **Evidence:** Pliki HCL w `infra/terraform/modules/network-endpoints/*`.

---

### W07-T02 — Zintegruj network-endpoints z network-core w envs/dev

- **TaskId:** `W07-T02`
- **Status:** `DONE`
- **Priorytet:** `P1`
- **Typ:** `IaC`
- **Cel:** Dodać wywołanie modułu network-endpoints w envs/dev; przekazać outputy network_core jako zmienne.
- **Estymata:** 15m
- **Input:**
  - Moduł network-endpoints (W07-T01)
  - `envs/dev/main.tf` (istniejące wywołanie network_core)
- **Kroki:**
  1. Dodać `module "network_endpoints" { source = "../../modules/network-endpoints"; ... }`
  2. Przekazać vpc_id, private_route_table_id, private_subnet_ids, sg_app_id z `module.network_core.*`
- **Verification:** `terraform init`, `terraform validate`, `terraform plan` bez błędów.
- **Evidence:** Zmiany w `envs/dev/main.tf`.

---

### W07-T03 — terraform apply dla network stack (network-core + network-endpoints)

- **TaskId:** `W07-T03`
- **Status:** `TODO`
- **Priorytet:** `P1`
- **Typ:** `Deploy`
- **Cel:** Wykonać pierwszy manual apply — walidacja infra w AWS (100% pewność przed pipeline).
- **Estymata:** 45m
- **Input:**
  - W07-T01, W07-T02 ukończone
  - `AWS_PROFILE=swpr-dev` (lub alias aws-dev)
- **Kroki:**
  1. `terraform plan` — weryfikacja przed apply
  2. `terraform apply` — wykonuje użytkownik (nie agent)
  3. Weryfikacja: `terraform state list`; zasoby w konsoli AWS
  4. `terraform plan` po apply — brak driftu
- **Verification:** Zasoby VPC, endpointów i Flow Logs widoczne w AWS; plan stabilny.
- **Evidence:** Fragment outputu `terraform state list`; screenshot/opis zasobów w konsoli.
- **Uwaga:** ADR-0002 — koszt NAT/endpoints/Flow Logs; cleanup po sesji.

---

### W07-T04 — Runbook: smoke tests sieci po deployu

- **TaskId:** `W07-T04`
- **Status:** `DONE`
- **Priorytet:** `P1`
- **Typ:** `Docs/Verification`
- **Cel:** Rozszerzyć runbook `network-smoke-tests.md` o VPC Endpoints i Flow Logs.
- **Estymata:** 30m
- **Input:**
  - `docs/runbooks/network-smoke-tests.md` (istniejący)
  - `docs/lessons/W05-endpoints-design.md`
- **Kroki:**
  1. Dodać sekcję: weryfikacja Gateway Endpoints (S3, DynamoDB)
  2. Dodać sekcję: weryfikacja Interface Endpoints (Secrets Manager, SSM)
  3. Dodać sekcję: Flow Logs w CloudWatch
  4. Checklisty diagnostyczne
- **Verification:** Runbook pozwala zweryfikować deploy ręcznie.
- **Evidence:** `docs/runbooks/network-smoke-tests.md` rozszerzony.

---

### W07-T05 — Uzupełnij docs/lessons/W07-summary.md

- **TaskId:** `W07-T05`
- **Status:** `DONE`
- **Priorytet:** `P2`
- **Typ:** `Docs`
- **Cel:** Udokumentować co zostało wdrożone, pułapki, gotowość pod W08.
- **Estymata:** 15m
- **Input:**
  - Wyniki W07-T01..T04
- **Kroki:**
  1. Opisać: Gateway Endpoints (S3, DynamoDB), Interface Endpoints (Secrets, SSM), Flow Logs
  2. Pułapki: private DNS, SG endpoints, koszty
  3. Następny krok: W08 (pipeline)
- **Verification:** W07-summary.md istnieje i jest spójny z wykonanym zakresem.
- **Evidence:** `docs/lessons/W07-summary.md`.

---

## Verification (zbiorczy checklist z roadmapy)

- [ ] `terraform state list` pokazuje zasoby network-core i network-endpoints
- [ ] Zasoby VPC, endpointów i Flow Logs widoczne w AWS
- [ ] `terraform plan` po apply nie pokazuje driftu (lub drift wyjaśniony)
- [ ] Smoke tests sieci (runbook) wykonane lub udokumentowane

## Evidence (zbiorczy z roadmapy)

- `docs/lessons/W07-summary.md`
- `docs/runbooks/network-smoke-tests.md` (rozszerzony)
- `infra/terraform/modules/network-endpoints/*`
- `envs/dev/main.tf` (wywołanie network_endpoints)
