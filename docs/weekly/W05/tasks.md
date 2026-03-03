## W05 — taski tygodnia

### Kontekst
- **WeekId:** `W05`
- **Cel tygodnia:** Zrozumieć VPC Endpoints, PrivateLink i VPC Flow Logs oraz zaprojektować moduł `network-endpoints` gotowy do implementacji w W07.
- **Outcome:** Notatka „Gateway vs Interface vs PrivateLink”, projekt modułu `network-endpoints` (Gateway S3/DynamoDB, Interface Secrets/SSM, Flow Logs) oraz zaktualizowany runbook network-smoke-tests.

---

## Taski bazowe z roadmapy

### W05-T01 — Porównanie: Gateway Endpoint vs Interface Endpoint vs PrivateLink
- **TaskId:** `W05-T01`
- **Status:** `DONE`
- **Priorytet:** `P1`
- **Typ:** `Theory/Docs`
- **Cel:** Zrozumieć różnice między Gateway Endpoint, Interface Endpoint i PrivateLink (w tym koszt, routing, bezpieczeństwo) oraz osadzić je w modelu endpoint-first, NAT jako fallback.
- **Estymata:** 45m
- **Input:**
  - Sekcja `W05` w `docs/roadmap/aws-course-roadmap-operational-0-24.md`.
  - Modele ruchu i topologia VPC z W03/W04 (`docs/diagrams/vpc-dev.md`, `docs/lessons/W04-traffic-models.md`).
- **Kroki:**
  1. Zebrać definicje i cechy Gateway Endpoint, Interface Endpoint, PrivateLink.
  2. Opisać ich wpływ na routing (route tables vs ENI + SG) i DNS.
  3. Porównać model kosztowy (Gateway „za darmo” vs Interface płatny per AZ + data).
  4. Zbudować tabelę „Gateway vs Interface vs PrivateLink vs NAT” z typowymi use-case’ami (ECS→S3, ECS→DynamoDB, ECS→Secrets/SSM, ECS→zewnętrzne API).
- **Verification:** Istnieje notatka z klarownym porównaniem i tabelą use-case’ów.
- **Evidence:** Sekcje „Teoria” i „Kiedy który endpoint” w `docs/lessons/W05-endpoints-design.md`.

---

### W05-T02 — Projekt modułu `network-endpoints`: Gateway S3/DynamoDB, trasy w route table
- **TaskId:** `W05-T02`
- **Status:** `DONE`
- **Priorytet:** `P1`
- **Typ:** `IaC/Design`
- **Cel:** Zaprojektować moduł Terraform `network-endpoints` odpowiedzialny za Gateway Endpoints S3/DynamoDB i ich integrację z route table subnetów private, w oparciu o outputy modułu `network-core`.
- **Estymata:** 45m
- **Input:**
  - Opis modułu `network-core` w `docs/lessons/W04-network-core-module-design.md`.
  - Roadmapa W05 (zakres i DoD).
- **Kroki:**
  1. Zidentyfikować outputy `network-core` potrzebne modułowi `network-endpoints` (min. `vpc_id`, `private_route_table_id`).
  2. Zaprojektować resources dla Gateway Endpointów S3 i DynamoDB oraz sposób powiązania ich z `private_route_table_id`.
  3. Zdefiniować variables (np. `enable_s3_gateway_endpoint`, `enable_dynamodb_gateway_endpoint`, `tags`) i outputs (IDs endpointów).
  4. Opisać strukturę katalogów/plików modułu `infra/terraform/modules/network-endpoints/*` (bez generowania HCL).
- **Verification:** Możesz słownie opisać, jak moduł `network-endpoints` tworzy Gateway Endpoints i jak korzysta z outputów `network-core`.
- **Evidence:** Sekcja „Projekt modułu network-endpoints (Gateway)” w `docs/lessons/W05-endpoints-design.md`.

---

### W05-T03 — Projekt VPC Flow Logs (gdzie, co logować)
- **TaskId:** `W05-T03`
- **Status:** `DONE`
- **Priorytet:** `P1`
- **Typ:** `Observability/Design`
- **Cel:** Zaprojektować VPC Flow Logs dla VPC dev tak, aby wspierały troubleshooting sieci (w tym endpointów) przy akceptowalnych kosztach.
- **Estymata:** 30m
- **Input:**
  - Guardrails kosztowe z `docs/adr/ADR-0002-cost-guardrails-dev.md`.
  - Modele przepływu ruchu z W04.
- **Kroki:**
  1. Zdecydować zakres Flow Logs (poziom VPC vs wybrane subnety) w dev.
  2. Wybrać destination (CloudWatch Logs vs S3) oraz politykę retencji.
  3. Zdecydować filtr logów (`ACCEPT` vs `REJECT` vs `ALL`) i powiązać to z typowymi scenariuszami diagnostycznymi.
  4. Opisać, jak Flow Logs będą włączane/wyłączane w module `network-endpoints` (variables, tagowanie).
- **Verification:** Istnieje opis projektu Flow Logs oraz decyzje dot. destination/retencji i filtra.
- **Evidence:** Sekcja „VPC Flow Logs — design” w `docs/lessons/W05-endpoints-design.md`.

---

### W05-T04 — Projekt interface endpointów (Secrets Manager/SSM): subnets, SG
- **TaskId:** `W05-T04`
- **Status:** `DONE`
- **Priorytet:** `P2`
- **Typ:** `Security/Design`
- **Cel:** Zaprojektować Interface Endpoints dla Secrets Manager i SSM Parameter Store (subnety, SG, DNS) w taki sposób, aby ECS/Lambda mogły korzystać z nich po prywatnym IP.
- **Estymata:** 30m
- **Input:**
  - Modele ruchu i SG z W04 (`docs/lessons/W04-traffic-models.md`, `docs/lessons/W04-sg-nacl-baseline.md`).
  - Roadmapa W05 (pułapki: Private DNS, SG endpointów, koszt).
- **Kroki:**
  1. Wybrać subnety dla Interface Endpointów (ENI w `private-a` i `private-b`).
  2. Zaprojektować osobny SG dla endpointów (ingress z `sg_app`, egress do usług AWS).
  3. Zdecydować ustawienie `private_dns_enabled` (domyślnie `true`) i opisać, co się stanie po jego wyłączeniu.
  4. Wpleść endpointy w projekt modułu `network-endpoints` (variables, outputs, integracja z `private_subnet_ids`).
- **Verification:** Istnieje opis architektury Interface Endpointów (subnety, SG, DNS) spójny z modelami ruchu i security baseline.
- **Evidence:** Sekcja „Interface Endpoints (Secrets/SSM)” w `docs/lessons/W05-endpoints-design.md`.

---

### W05-T05 — Uzupełnienie network smoke tests o checklisty pod endpointy
- **TaskId:** `W05-T05`
- **Status:** `DONE`
- **Priorytet:** `P2`
- **Typ:** `Docs/Runbook`
- **Cel:** Rozszerzyć `docs/runbooks/network-smoke-tests.md` o checklisty diagnostyczne specyficzne dla VPC Endpoints i Flow Logs.
- **Estymata:** 15m
- **Input:**
  - Istniejący runbook z W04 (`docs/runbooks/network-smoke-tests.md`).
  - Projekt endpointów i Flow Logs z W05-T01..T04.
- **Kroki:**
  1. Dodać sekcje diagnostyczne dla problemów z Gateway Endpointami (np. ECS→S3 idzie przez NAT albo 403).
  2. Dodać sekcje dla Interface Endpointów (DNS, SG endpointu, private DNS).
  3. Opisać, jak użyć VPC Flow Logs w troubleshooting (jakie filtry, czego szukać).
  4. Uaktualnić szybką checklistę tak, aby endpointy/Flow Logs były naturalnym krokiem diagnostyki.
- **Verification:** Runbook zawiera konkretne checklisty dla endpointów i Flow Logs.
- **Evidence:** Nowe sekcje w `docs/runbooks/network-smoke-tests.md` (oznaczone jako W05).

---

## Verification (zbiorczy checklist z roadmapy)
- [ ] Notatka „kiedy który endpoint” (Gateway vs Interface vs PrivateLink) istnieje i odnosi się do naszych scenariuszy.
- [ ] Projekt modułu `network-endpoints` jest spójny z outputami `network-core` (`private_route_table_id`, `private_subnet_ids`, `vpc_id`).
- [ ] Projekt VPC Flow Logs opisuje destination i retention oraz to, co logujemy.

## Evidence (zbiorczy z roadmapy)
- `docs/lessons/W05-summary.md`
- `docs/lessons/W05-endpoints-design.md`
- `docs/runbooks/network-smoke-tests.md` (rozszerzony o endpointy i Flow Logs)

