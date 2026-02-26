## W03 — podsumowanie tygodnia

Podsumowanie tygodnia W03 (`VPC, subnety, adresacja`) względem roadmapy i DoD.

---

- **Cel tygodnia (z roadmapy):** Zaprojektować topologię sieciową dev dla całego projektu (VPC, subnety, adresacja).
- **DoD:** Topologia gotowa do implementacji w Terraform (CIDR, subnety, rozmieszczenie komponentów, decyzja NAT, przepływ ruchu).
- **Status:** **DONE** (wszystkie taski W03-T01..T04 zrealizowane zgodnie z roadmapą).

### Co osiągnięto
- Zaprojektowano VPC dev:
  - CIDR `10.0.0.0/16`,
  - 2 AZ (`eu-central-1a`, `eu-central-1b`) z subnetami public/private (`public-a/b`, `private-a/b`), bez konfliktów CIDR.
- Rozmieszczono główne komponenty:
  - ALB w subnetach publicznych,
  - ECS Fargate, RDS PostgreSQL, Lambda w VPC w subnetach prywatnych,
  - VPC Endpoints: Gateway (S3, DynamoDB) i Interface (Secrets Manager, SSM) w modelu endpoint-first, NAT jako fallback.
- Udokumentowano strategię NAT:
  - ADR-0004 z analizą 1 NAT vs NAT per AZ vs brak NAT,
  - decyzja: 1 NAT Gateway w jednej AZ (`public-a`) + odciążenie przez VPC Endpoints.
- Opisano przepływ ruchu:
  - Internet → IGW → ALB (public) → ECS/Lambda (private),
  - ruch wewnętrzny ECS/Lambda → RDS,
  - ruch do usług AWS przez Gateway/Interface Endpoints lub (w fallbacku) NAT.

### Co nie zostało dowiezione / otwarte kwestie
- Brak zadań w statusie `BLOCKED` lub `TODO` — wszystkie taski W03 są wykonane.
- Świadomie pozostawiono:
  - brak pełnego multi-AZ HA w dev (topologia to umożliwia, ale nie jest wymagane na tym etapie),
  - status ADR-0004 jako `Proposed` do formalnego oznaczenia `Accepted` po pierwszym `terraform plan/apply` w W04/W05.

### Root cause problemów / opóźnień
- Brak istotnych blokad w tym tygodniu; decyzje (np. 1 NAT vs NAT per AZ, Lambda w VPC, endpoint-first) były podejmowane świadomie w dialogu z roadmapą, ADR-0001 i ADR-0002.

### Lessons learned
- Projektowanie VPC dev wymaga od razu myślenia o:
  - przestrzeni adresowej z zapasem (uniknięcie „za małego CIDR”),
  - podziale na public/private i docelowych komponentach (ALB, ECS, RDS, Lambda, endpoints),
  - kosztach stałych (NAT) i możliwościach ich redukcji przez VPC Endpoints.
- Model **endpoint-first, NAT jako fallback** jest naturalnym kompromisem:
  - bezpieczeństwo (brak internetu dla ruchu do S3/DynamoDB/Secrets/SSM),
  - kontrola kosztów NAT,
  - zachowanie elastyczności dla pozostałego ruchu.
- Dobrze opisany ADR (tu: NAT) ułatwia późniejsze „podniesienie” dev do standardów prod (np. dodanie drugiego NAT) bez przebudowy całej topologii.

### Next actions (poza W03)
- W04:
  - Zaimplementować moduł `network-core` w Terraform na bazie zaprojektowanej topologii (VPC, subnety, IGW, route tables, NAT).
  - Zweryfikować routing w praktyce (`terraform plan`, później testy connectivity).
- W05:
  - Dodać moduł `network-endpoints` (Gateway/Interface) i zweryfikować, że ruch do wybranych usług AWS nie idzie przez NAT.
- Przy domknięciu W04/W05:
  - Oznaczyć ADR-0004 jako `Accepted`, jeśli implementacja będzie zgodna z decyzją.

### Portfolio bullets (1–3)
- Zaprojektowałem topologię VPC dev w AWS (2 AZ, public/private subnets, ALB, ECS, RDS, Lambda w VPC) z myślą o przyszłej implementacji w Terraform.
- Zdefiniowałem strategię NAT dla środowiska dev (1 NAT + endpoint-first, NAT jako fallback) i udokumentowałem kompromis koszt vs HA w formalnym ADR.
- Udokumentowałem przepływy ruchu (Internet → ALB → ECS/Lambda, ruch do RDS i usług AWS przez VPC Endpoints) w formie diagramu/deskrypcji, gotowe jako input do modułów `network-core` i `network-endpoints`.

