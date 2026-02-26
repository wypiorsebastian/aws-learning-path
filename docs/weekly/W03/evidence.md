## W03 — evidence

Dowody wykonania zadań i spełnienia DoD. Odniesienie do roadmapy: Evidence = diagram + tabela CIDR, W03-summary, ADR-0004.

---

### W03-T01 — CIDR VPC i subnety
- **Oczekiwane:** Tabela subnetów (nazwa, AZ, CIDR, typ) bez konfliktów.
- **Link / opis:** Zdefiniowano VPC `10.0.0.0/16` oraz subnety `public-a`/`public-b` (`10.0.1.0/24`, `10.0.2.0/24`) i `private-a`/`private-b` (`10.0.11.0/24`, `10.0.12.0/24`) w 2 AZ, bez konfliktów CIDR — tabela w `docs/diagrams/vpc-dev.md`.

### W03-T02 — Rozmieszczenie komponentów
- **Oczekiwane:** Tabela lub diagram z przypisaniem ALB/ECS/RDS/endpoints/Lambda do subnetów.
- **Link / opis:** Rozmieszczenie ALB, ECS, RDS, Lambdy w VPC oraz Gateway/Interface Endpoints opisane w sekcji „Rozmieszczenie komponentów (W03-T02)” w `docs/diagrams/vpc-dev.md` (model endpoint-first, NAT jako fallback).

### W03-T03 — ADR NAT (1 vs HA)
- **Oczekiwane:** `docs/adr/ADR-0004-vpc-dev-topology.md` z sekcją decyzji NAT i trade-off.
- **Link / opis:** `docs/adr/ADR-0004-vpc-dev-topology.md` — opisano trzy opcje (1 NAT, NAT per AZ, brak NAT), z wyborem „1 NAT w jednej AZ + endpoint-first, NAT jako fallback” dla dev-only oraz konsekwencjami koszt/HA.

### W03-T04 — Diagram przepływu ruchu
- **Oczekiwane:** Diagram lub opis w `docs/diagrams/vpc-dev.md` (public → private, wyjście przez NAT).
- **Link / opis:** Opis przepływu ruchu (Internet → IGW → ALB → ECS/Lambda w private; ECS/Lambda → RDS; ruch do usług AWS przez endpointy lub NAT) w sekcji „Przepływ ruchu (W03-T04)” w `docs/diagrams/vpc-dev.md`.

### DoD
- **Kryterium:** Topologia gotowa do implementacji w Terraform.
- **Potwierdzenie:** Spełnione — CIDR i subnety VPC są zdefiniowane bez konfliktów, komponenty (ALB, ECS, RDS, Lambda, VPC Endpoints) mają przypisane subnety, strategia NAT jest udokumentowana w ADR-0004, a przepływy ruchu są opisane w `docs/diagrams/vpc-dev.md`; na tej bazie można projektowo rozpocząć implementację modułu `network-core` w Terraform.
