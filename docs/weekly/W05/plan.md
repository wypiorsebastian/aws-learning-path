## W05 — plan sesji D1–D5

### Kontekst tygodnia
- **Cel tygodnia:** Zrozumieć VPC Endpoints, PrivateLink i VPC Flow Logs oraz zaprojektować moduł `network-endpoints` gotowy do implementacji w W07.
- **WhyNow:** To element „networking+” i fundament pod bezpieczeństwo oraz koszty — chcemy świadomie korzystać z prywatnego dostępu do usług AWS, zanim w W06/W07 wejdziemy w realny Terraform dla sieci.
- **Outcome (wg roadmapy):** Design modułu `network-endpoints` (Gateway S3/DynamoDB, Interface Secrets/SSM, Flow Logs) + notatka „kiedy który endpoint”.
- **DoD (skrót):** Rozumiesz różnice Gateway vs Interface vs PrivateLink, masz zaprojektowany moduł `network-endpoints` spójny z outputami `network-core` oraz wiesz, kiedy użyć którego endpointu.

### Założenia czasowe
- 5 sesji po **1.5h** (D1–D5).
- Fokus: **teoria + design**, bez generowania HCL, zgodnie z regułą projektu „no code bez wyraźnej prośby”.

---

## D1 (1.5h) — Teoria: Gateway Endpoint vs Interface Endpoint vs PrivateLink (W05-T01)
- [ ] Przeczytać sekcję `W05` w `docs/roadmap/aws-course-roadmap-operational-0-24.md` (cel, DoD, pułapki).
- [ ] Na bazie W03/W04 przypomnieć sobie model endpoint-first, NAT jako fallback (ADR-0004, `docs/diagrams/vpc-dev.md`, `docs/lessons/W04-traffic-models.md`).
- [ ] Spisać porównanie:
  - czym różni się Gateway Endpoint od Interface Endpoint (poziom routingu vs ENI + SG),
  - co to jest PrivateLink w szerszym sensie (usługa wystawiana jako endpoint),
  - jakie są konsekwencje kosztowe (Gateway „za darmo”, Interface płatny per AZ + data).
- [ ] Zbudować tabelkę „Gateway vs Interface vs PrivateLink vs NAT” z typowymi use-case’ami.

**Cel D1:** mieć klarowną notatkę z teorią endpoints, która stanie się pierwszą częścią `docs/lessons/W05-endpoints-design.md`.

---

## D2 (1.5h) — Projekt modułu `network-endpoints` (Gateway S3/DynamoDB) (W05-T02, część 1)
- [ ] Na bazie `docs/lessons/W04-network-core-module-design.md` wypisać, z jakich outputów `network-core` skorzysta moduł `network-endpoints`:
  - `vpc_id`,
  - `private_route_table_id`,
  - `private_subnet_ids` (dla interface endpointów w kolejnej sesji).
- [ ] Zaprojektować część modułu odpowiedzialną za **Gateway Endpoints**:
  - S3 i DynamoDB jako `aws_vpc_endpoint` typu `Gateway`,
  - powiązanie z route table private (`private_route_table_id`),
  - zasady tagowania (spójne z ADR-0002).
- [ ] Spisać variables/outputs tej części modułu (bez kodu), np. `enable_s3_gateway_endpoint`, `enable_dynamodb_gateway_endpoint`.

**Cel D2:** mieć opisaną część modułu `network-endpoints` dla Gateway Endpoints, spójną z routingiem z W04.

---

## D3 (1.5h) — Projekt modułu `network-endpoints` (Interface + Flow Logs) (W05-T02/T03)
- [ ] Zaprojektować część modułu odpowiedzialną za **Interface Endpoints**:
  - Secrets Manager i SSM Parameter Store jako `aws_vpc_endpoint` typu `Interface`,
  - `subnet_ids` = `private_subnet_ids` z `network-core`,
  - własny SG endpointów (ingress z `sg_app`, egress do usług AWS),
  - decyzja dot. `private_dns_enabled` (domyślnie `true`).
- [ ] Zaprojektować **VPC Flow Logs** (W05-T03):
  - zakres (VPC vs wybrane subnety),
  - destination (CloudWatch Logs vs S3) i retention,
  - czy logujemy `ACCEPT`, `REJECT`, czy `ALL`.
- [ ] Dopisać variables/outputs dla Interface Endpoints i Flow Logs (np. `enable_flow_logs`, `flow_logs_destination_type`).

**Cel D3:** mieć kompletny opis modułu `network-endpoints` (Gateway + Interface + Flow Logs), gotowy jako input do HCL w W07.

---

## D4 (1.5h) — „Kiedy który endpoint?” + wpływ na troubleshooting (W05-T01/T04/T05)
- [ ] Na bazie modeli ruchu z W04 i projektu endpointów z D2/D3 zbudować tabelę:
  - scenariusz (np. ECS → S3, ECS → DynamoDB, ECS → Secrets, ECS → SQS, ECS → zewnętrzne API),
  - ścieżka sieciowa (Gateway EP, Interface EP, NAT),
  - uzasadnienie (bezpieczeństwo, koszt, prostota).
- [ ] Zidentyfikować typowe błędy konfiguracyjne endpointów:
  - brak wpisu w route table dla Gateway,
  - wyłączone `private_dns` dla Interface,
  - zbyt restrykcyjny SG endpointu,
  - brak Flow Logs przy debugowaniu „czemu nie działa”.
- [ ] Zaplanować, jak rozszerzyć `docs/runbooks/network-smoke-tests.md` o sekcje dla endpointów i Flow Logs (W05-T05).

**Cel D4:** mieć spójną notatkę „kiedy który endpoint” i listę pułapek, gotową do umieszczenia w `W05-endpoints-design.md` i runbooku.

---

## D5 (1.5h) — Podsumowanie W05, evidence i przygotowanie pod W06/W07
- [ ] Przejrzeć DoD z roadmapy dla W05:
  - rozumiesz Gateway vs Interface Endpoint,
  - design modułu `network-endpoints` jest spójny z outputami `network-core`,
  - Flow Logs są zaprojektowane (destination, retention).
- [ ] Upewnić się, że:
  - `docs/lessons/W05-endpoints-design.md` zawiera teorię, projekt modułu i tabelę „kiedy który endpoint”,
  - `docs/runbooks/network-smoke-tests.md` ma rozszerzenie pod endpointy i Flow Logs.
- [ ] Uzupełnić:
  - `docs/weekly/W05/evidence.md` — dowody dla W05-T01..T05,
  - `docs/weekly/W05/summary.md` — co zostało zaprojektowane/ustalone i jak to zasila W06/W07.

**Cel D5:** mieć domknięty tydzień W05 jako **design-only** i gotowy input do implementacji Terraform w W06/W07.

