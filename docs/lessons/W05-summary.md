## W05 — VPC Endpoints, PrivateLink, Flow Logs — podsumowanie lekcji

### Cel lekcji
- Zrozumieć różnice między Gateway Endpoint, Interface Endpoint i PrivateLink w kontekście VPC dev.
- Zaprojektować moduł Terraform `network-endpoints` (Gateway S3/DynamoDB, Interface Secrets/SSM, VPC Flow Logs) spójny z modułem `network-core`.
- Przygotować materiał, który pozwoli w W07 mechanicznie zaimplementować moduł `network-endpoints` oraz efektywnie debugować problemy sieciowe z użyciem Flow Logs.

### Najważniejsze wnioski
- **Gateway Endpoint vs Interface Endpoint vs NAT:**
  - Gateway Endpoint (S3/DynamoDB) działa na poziomie route tables, nie ma własnego SG, nie generuje stałego kosztu i powinien być używany zawsze, gdy usługa go wspiera i ruch pochodzi z private subnetów.
  - Interface Endpoint (Secrets/SSM) tworzy ENI w subnetach private, ma własny SG i opcjonalny Private DNS; jest płatny per endpoint per AZ, więc w dev wybieramy minimalny zestaw endpointów.
  - NAT pozostaje fallbackiem oraz ścieżką do usług bez endpointu i do zewnętrznych API; dzięki endpointom znacząco ograniczamy ruch przez NAT.
- **Projekt modułu `network-endpoints`:**
  - Moduł konsumuje outputy `network-core` (`vpc_id`, `private_route_table_id`, `private_subnet_ids`, `sg_app_id`) i tworzy:
    - Gateway Endpoints dla S3/DynamoDB (powiązane z route table private),
    - Interface Endpoints dla Secrets/SSM (ENI w private-a/b, dedykowany SG endpointów, Private DNS),
    - VPC Flow Logs (VPC-level, domyślnie do CloudWatch Logs, z konfigurowalną retencją i traffic_type).
  - Zdefiniowano zmienne/outputs modułu tak, aby późniejsze HCL było mechaniczne do napisania.
- **Flow Logs jako narzędzie troubleshootingowe:**
  - Flow Logs pomagają potwierdzić, czy ruch faktycznie idzie przez NAT czy endpointy oraz czy jest `ACCEPT` czy `REJECT`.
  - W dev domyślnie wystarczy logowanie `ACCEPT` z krótką retencją; `ALL` warto włączać tylko tymczasowo na czas dogłębnej diagnostyki.

### Jak to zasila kolejne tygodnie
- W06: implementacja `network-core` dostarczy realne outputy (`vpc_id`, `private_route_table_id`, `private_subnet_ids`) pod moduł `network-endpoints`.
- W07: na bazie tego designu powstanie kod HCL modułu `network-endpoints`; po `terraform apply` będzie można:
  - zweryfikować, że ruch do S3/DynamoDB idzie przez Gateway Endpoints,
  - sprawdzić, że ECS/Lambda korzystają z Secrets/SSM po prywatnym IP przez Interface Endpoints,
  - użyć VPC Flow Logs jako standardowego narzędzia troubleshootingowego dla sieci.

