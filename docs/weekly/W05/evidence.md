## W05 — evidence

Dowody wykonania zadań i spełnienia DoD. Roadmapa oczekuje: notatki o Gateway vs Interface vs PrivateLink, projekt modułu `network-endpoints` oraz zaktualizowany runbook network-smoke-tests.

---

### W05-T01 — Porównanie: Gateway Endpoint vs Interface Endpoint vs PrivateLink
- **Oczekiwane:** Klarowna notatka z teorią VPC Endpoints (Gateway, Interface, PrivateLink) oraz ich miejscem w modelu endpoint-first, NAT jako fallback.
- **Link / opis:** `docs/lessons/W05-endpoints-design.md` — sekcja teorii i tabela „Gateway vs Interface vs PrivateLink vs NAT” z typowymi scenariuszami (ECS/Lambda → S3/DynamoDB/Secrets/SSM/zewnętrzne API).

### W05-T02 — Projekt modułu `network-endpoints`: Gateway S3/DynamoDB, trasy w route table
- **Oczekiwane:** Opis modułu `network-endpoints` dla Gateway Endpointów S3/DynamoDB, wykorzystujący outputy `network-core` i integrujący się z route table subnetów private.
- **Link / opis:** `docs/lessons/W05-endpoints-design.md` — sekcja „Projekt modułu network-endpoints (Gateway)”, zawierająca listę zasobów, variables/outputs oraz opis powiązania z `private_route_table_id`.

### W05-T03 — Projekt VPC Flow Logs (gdzie, co logować)
- **Oczekiwane:** Projekt VPC Flow Logs dla VPC dev (zakres, destination, filtr, retention) z uwzględnieniem guardrails kosztowych.
- **Link / opis:** `docs/lessons/W05-endpoints-design.md` — sekcja „VPC Flow Logs — design”, opisująca zakres logowania, destination (CloudWatch/S3), filtr i sposób włączenia/wyłączenia w module.

### W05-T04 — Projekt interface endpointów (Secrets Manager/SSM): subnets, SG
- **Oczekiwane:** Opis architektury Interface Endpointów dla Secrets Manager i SSM: subnety, SG, ustawienia Private DNS, integracja z `network-core`.
- **Link / opis:** `docs/lessons/W05-endpoints-design.md` — sekcja „Interface Endpoints (Secrets/SSM)”, opisująca subnety (`private-a`/`private-b`), dedykowany SG endpointów oraz `private_dns_enabled`.

### W05-T05 — Uzupełnienie network smoke tests o checklisty pod endpointy
- **Oczekiwane:** Rozszerzenie `docs/runbooks/network-smoke-tests.md` o checklisty diagnostyczne dla endpointów (Gateway/Interface) i Flow Logs.
- **Link / opis:** `docs/runbooks/network-smoke-tests.md` — nowe sekcje oznaczone jako W05 (endpointy i Flow Logs) oraz zaktualizowana szybka checklista.

### DoD
- **Kryterium:** 
  - Rozumiesz różnice Gateway vs Interface Endpoint vs PrivateLink.
  - Design modułu `network-endpoints` jest spójny z outputami `network-core` (`vpc_id`, `private_route_table_id`, `private_subnet_ids`).
  - Flow Logs są zaprojektowane (destination, filtr, retention) i uwzględnione w runbooku troubleshootingowym.
- **Potwierdzenie:** Spełnione — dokument `docs/lessons/W05-endpoints-design.md` zawiera teorię Gateway vs Interface vs PrivateLink, szczegółowy projekt modułu `network-endpoints` (Gateway S3/DynamoDB, Interface Secrets/SSM, VPC Flow Logs) oparty na outputach `network-core`, a `docs/runbooks/network-smoke-tests.md` zostało rozszerzone o checklisty diagnostyczne dla endpointów i Flow Logs; na tej bazie można w W07 mechanicznie zaimplementować moduł `network-endpoints` w Terraform.

