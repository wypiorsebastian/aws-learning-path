## W03 — log tygodnia

Log wpisów chronologicznie; każdy wpis z datą/czasem i powiązanym TaskId.

---

<!-- Przykład:
- **2025-02-26 10:00** — Start tygodnia W03. Przeczytana sekcja W03 z roadmapy. _TaskId: —_
-->

- **2026-02-26 00:00** — Zaprojektowano CIDR VPC `10.0.0.0/16` oraz subnety public/private w 2 AZ; tabela zapisana w `docs/diagrams/vpc-dev.md`. _TaskId: W03-T01_

- **2026-02-26 00:00** — Rozmieszczono ALB, ECS, RDS, Lambdę oraz VPC Endpoints (Gateway S3/DynamoDB, Interface Secrets Manager/SSM) na subnetach zgodnie z modelem endpoint-first, NAT jako fallback; opis w `docs/diagrams/vpc-dev.md`. _TaskId: W03-T02_

- **2026-02-26 00:00** — Utworzono ADR-0004 opisujący strategię NAT dla VPC dev (kompromis 1 NAT vs NAT per AZ vs brak NAT) z decyzją: 1 NAT w jednej AZ + endpoint-first, NAT jako fallback; plik `docs/adr/ADR-0004-vpc-dev-topology.md`. _TaskId: W03-T03_

- **2026-02-26 00:00** — Uzupełniono opis przepływu ruchu (Internet → ALB → ECS/Lambda w private, wyjście z private przez VPC Endpoints lub NAT) w `docs/diagrams/vpc-dev.md`. _TaskId: W03-T04_
