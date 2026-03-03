## W04 — log tygodnia

Log wpisów chronologicznie; każdy wpis z datą/czasem i powiązanym TaskId.

---

- **2026-02-26** — Utworzono model przepływu ruchu dla VPC dev: inwentarz elementów, scenariusze A1–C2 (Internet→ALB→ECS, wewnętrzny RDS, endpoint-first, NAT fallback), macierz przepływu, synteza route tables i SG/NACL w `docs/lessons/W04-traffic-models.md`. _TaskId: W04-T01_

- **2026-02-26** — Zaprojektowano moduł `network-core`: lista zasobów AWS (VPC, subnety, IGW, NAT, route tables), variables, outputs przygotowane pod W05 (private_route_table_id, private_subnet_ids) i moduły ALB/ECS/RDS/Lambda, struktura katalogów, naming/tagowanie, opis integracji z W05 network-endpoints w `docs/lessons/W04-network-core-module-design.md`. _TaskId: W04-T02_

- **2026-02-26** — Zaprojektowano baseline SG (sg_alb, sg_app, sg_rds) i NACL: tabela reguł ingress/egress spójna z modelami ruchu, rekomendacja domyślnego VPC NACL w dev, notatka o przyszłym hardeningu (Opcja B) w `docs/lessons/W04-sg-nacl-baseline.md`. _TaskId: W04-T03_

- **2026-02-26** — Utworzono checklisty diagnostyczne: routing vs SG vs NACL — objawy 502/504, brak wyjścia do Internetu, ECS↔RDS, Lambda w VPC; szybka checklista; przykładowe komendy AWS CLI w `docs/runbooks/network-smoke-tests.md`. _TaskId: W04-T04_

