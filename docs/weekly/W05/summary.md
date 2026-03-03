## W05 — podsumowanie tygodnia

Podsumowanie tygodnia W05 (`VPC Endpoints, PrivateLink, Flow Logs — design i teoria`) względem roadmapy i DoD.

---

- **Cel tygodnia (z roadmapy):** Zrozumieć VPC Endpoints, PrivateLink i VPC Flow Logs oraz zaprojektować moduł `network-endpoints` gotowy do implementacji w W07.
- **DoD:** Rozumiesz Gateway vs Interface Endpoint; design modułu `network-endpoints` jest spójny z outputami `network-core`; Flow Logs są zaprojektowane (destination, retention) i osadzone w runbooku.
- **Status:** **DONE** (wszystkie taski W05-T01..T05 zrealizowane zgodnie z roadmapą).

### Co osiągnięto
- Opracowano teorię i porównanie:
  - Gateway Endpoint vs Interface Endpoint vs PrivateLink vs NAT,
  - wpływ na routing (route tables vs ENI + SG) i DNS (Private DNS),
  - konsekwencje kosztowe w kontekście dev-only i guardrails z ADR-0002.
- Zaprojektowano moduł `network-endpoints`:
  - Gateway Endpoints dla S3 i DynamoDB powiązane z `private_route_table_id` z `network-core`,
  - Interface Endpoints dla Secrets Manager i SSM z ENI w `private-a`/`private-b`, dedykowanym SG endpointów i włączonym Private DNS,
  - zmienne/outputs modułu spójne z outputami `network-core` (`vpc_id`, `private_route_table_id`, `private_subnet_ids`, `sg_app_id`).
- Zaprojektowano VPC Flow Logs:
  - zakres na poziomie VPC dev, destination domyślnie CloudWatch Logs z krótką retencją,
  - parametr `traffic_type` (ACCEPT/REJECT/ALL) z rekomendacją użycia `ACCEPT` na co dzień i `ALL` w trybie diagnostycznym,
  - zmienne konfiguracyjne (`enable_flow_logs`, destination/retention) jako część modułu `network-endpoints`.
- Rozszerzono runbook `network-smoke-tests`:
  - nowe sekcje dla problemów z Gateway Endpointami (S3/DynamoDB) i Interface Endpointami (Secrets/SSM),
  - dodano Flow Logs jako standardowy krok diagnostyczny w szybkiej checkliście.

### Wnioski / pułapki
- Endpointy znacząco zmniejszają ruch przez NAT i poprawiają bezpieczeństwo, ale:
  - Gateway Endpointy działają tylko dla wybranych usług (S3/DynamoDB) i wymagają poprawnych tras w route table,
  - Interface Endpointy są płatne per AZ, więc w dev warto ograniczyć się do minimalnego zestawu (Secrets/SSM).
- Private DNS dla Interface Endpointów upraszcza konfigurację aplikacji, ale:
  - wymaga świadomości, że publiczne hostname’y usług zaczynają rozwiązywać się do prywatnych IP w VPC,
  - wyłączenie Private DNS to scenariusz „advanced/hardening”, a nie wariant bazowy.
- Flow Logs są bardzo pomocne w diagnostyce, ale:
  - generują koszty i wymagają sensownej retencji,
  - trzeba pamiętać o zmianie `traffic_type` na `ALL` tylko na czas intensywnego debugowania.

### Następny krok
- **W06:** Terraform foundations + implementacja modułu `network-core` w HCL, tak aby outputy (`vpc_id`, `private_route_table_id`, `private_subnet_ids`) były dostępne dla modułu `network-endpoints`.
- **W07:** Implementacja modułu `network-endpoints` zgodnie z tym designem oraz weryfikacja w praktyce:
  - że ruch do S3/DynamoDB nie idzie przez NAT,
  - że Secrets/SSM działają przez Interface Endpoints,
  - że Flow Logs dostarczają użytecznych danych do troubleshooting’u.

