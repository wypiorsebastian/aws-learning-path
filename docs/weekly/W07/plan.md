# W07 — plan tygodnia

## Cel tygodnia (z roadmapy)

Zaimplementować moduł `network-endpoints` (na bazie designu W05) i wykonać pełny deploy warstwy sieciowej do dev. Pierwszy manual apply — walidacja infra przed pipeline (W08).

## WhyNow

- Backend S3 (use_lockfile) gotowy z W06
- Design z W05 gotowy
- Pierwszy realny apply — sieć w AWS; po walidacji można spokojnie pracować nad pipeline (W08)

## DoD

- network-core + network-endpoints wdrożone
- `terraform plan` po apply bez driftu (lub drift wyjaśniony)
- Smoke tests sieci udokumentowane

## MVP tygodnia

Moduł `network-endpoints` wdrożony; sieć dev (VPC + endpointy + Flow Logs) w AWS; runbook smoke tests gotowy.

---

## Plan D1–D5 (po 1.5h każda sesja)

### D1 (1.5h) — Moduł network-endpoints: struktura i Gateway Endpoints

**Cel:** Utworzyć szkielet modułu i zaimplementować Gateway Endpoints (S3, DynamoDB).

- [ ] Utworzyć folder `infra/terraform/modules/network-endpoints/`
- [ ] Pliki: `versions.tf`, `variables.tf`, `main.tf` (szkielet)
- [ ] Zaimplementować Gateway Endpoint S3 (`com.amazonaws.eu-central-1.s3`)
- [ ] Zaimplementować Gateway Endpoint DynamoDB (`com.amazonaws.eu-central-1.dynamodb`)
- [ ] Powiązanie z `private_route_table_id` z network-core
- **Input:** `docs/lessons/W05-endpoints-design.md` sekcja 3
- **Output:** Gateway Endpoints w planie (bez apply)
- **Weryfikacja:** `terraform plan` w envs/dev (po integracji w D2) pokazuje S3 i DynamoDB endpointy

---

### D2 (1.5h) — Integracja network-endpoints w envs/dev + Interface Endpoints

**Cel:** Zintegrować moduł w envs/dev i zaimplementować Interface Endpoints (Secrets Manager, SSM).

- [ ] Dodać `module "network_endpoints"` w `envs/dev/main.tf` — przekazać vpc_id, private_route_table_id, private_subnet_ids, sg_ecs_id z outputów network_core
- [ ] Zaimplementować SG `sg_endpoints` (ingress z sg_app:443)
- [ ] Zaimplementować Interface Endpoint Secrets Manager
- [ ] Zaimplementować Interface Endpoint SSM Parameter Store
- [ ] Private DNS enabled = true dla obu
- **Input:** `docs/lessons/W05-endpoints-design.md` sekcja 4
- **Output:** Integracja działa; plan pokazuje Gateway + Interface Endpoints
- **Weryfikacja:** `terraform plan` bez błędów zależności

---

### D3 (1.5h) — Flow Logs + outputs + terraform apply

**Cel:** Dodać Flow Logs, outputs modułu i wykonać pierwszy manual apply (walidacja infra).

- [ ] Zaimplementować VPC Flow Logs (destination: CloudWatch Logs)
- [ ] Utworzyć IAM role dla Flow Logs (jeśli wymagane)
- [ ] Dodać outputs: `s3_gateway_endpoint_id`, `dynamodb_gateway_endpoint_id`, `secretsmanager_interface_endpoint_id`, `ssm_interface_endpoint_id`
- [ ] `terraform apply` — ręczny deploy (walidacja 100% pewności przed pipeline)
- **Input:** `docs/lessons/W05-endpoints-design.md` sekcja 5
- **Output:** Zasoby w AWS; `terraform state list` pokazuje network-core + network-endpoints
- **Weryfikacja:** Zasoby widoczne w konsoli AWS; `terraform plan` po apply bez driftu
- **Uwaga:** Apply wykonuje użytkownik (nie agent); ADR-0002: koszt NAT/endpoints/Flow Logs — cleanup po sesji

---

### D4 (1.5h) — Runbook: smoke tests sieci

**Cel:** Rozszerzyć runbook `network-smoke-tests.md` o scenariusze VPC Endpoints i Flow Logs.

- [ ] Przeczytać `docs/runbooks/network-smoke-tests.md` (istniejący baseline)
- [ ] Dodać sekcję: weryfikacja Gateway Endpoints (S3, DynamoDB) — routing przez endpoint
- [ ] Dodać sekcję: weryfikacja Interface Endpoints (Secrets Manager, SSM) — Private DNS, connectivity
- [ ] Dodać sekcję: Flow Logs — sprawdzenie logów w CloudWatch
- [ ] Checklisty diagnostyczne dla typowych problemów (private DNS, SG endpoints)
- **Input:** W04-traffic-models, W05-endpoints-design
- **Output:** `docs/runbooks/network-smoke-tests.md` rozszerzony
- **Weryfikacja:** Runbook pozwala zweryfikować deploy ręcznie

---

### D5 (1.5h) — W07-summary, evidence, domknięcie tygodnia

**Cel:** Uzupełnić dokumentację i zamknąć tydzień.

- [ ] Utworzyć `docs/lessons/W07-summary.md` — co wdrożono, pułapki (private DNS, SG endpoints, koszty), gotowość pod W08
- [ ] Zaktualizować `evidence.md`, `log.md` dla W07
- [ ] Weryfikacja DoD: network-core + network-endpoints wdrożone, plan stabilny, smoke tests udokumentowane
- [ ] `/week-finish 07` — domknięcie tygodnia

---

## Pułapki (z roadmapy)

- **Private DNS** dla interface endpoint — upewnić się, że `private_dns_enabled = true`
- **SG endpointów** — ingress z sg_app (ECS/Lambda) na 443
- **Koszt** — NAT, endpoints, Flow Logs generują koszt; ADR-0002: cleanup po sesji

## Następny krok (W08)

Pipeline GitHub Actions + OIDC — wszystkie kolejne deploye przez CI/CD.
