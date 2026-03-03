## W05 — log tygodnia

Log wpisów chronologicznie; każdy wpis z datą/czasem i powiązanym TaskId.

---

- **2026-02-26** — Zaplanowano tydzień W05 (plan D1–D5) zgodnie z roadmapą: teoria Gateway vs Interface vs PrivateLink, projekt modułu `network-endpoints` (Gateway/Interface + Flow Logs) oraz rozszerzenie runbooku network-smoke-tests. _TaskId: —_

- **2026-02-26** — Spisano teorię VPC Endpoints: porównanie Gateway vs Interface vs PrivateLink, model endpoint-first vs NAT jako fallback oraz tabelę „kiedy który endpoint” dla głównych scenariuszy (ECS/Lambda → S3/DynamoDB/Secrets/SSM/zewnętrzne API) w `docs/lessons/W05-endpoints-design.md`. _TaskId: W05-T01_

- **2026-02-26** — Zaprojektowano moduł `network-endpoints` dla Gateway Endpoints S3/DynamoDB: wykorzystanie outputów `network-core` (`vpc_id`, `private_route_table_id`), variables/outputs oraz integrację z route table private w `docs/lessons/W05-endpoints-design.md`. _TaskId: W05-T02_

- **2026-02-26** — Zaprojektowano VPC Flow Logs dla VPC dev (zakres, destination, filtr, retention) oraz ich miejsce w module `network-endpoints` w `docs/lessons/W05-endpoints-design.md`. _TaskId: W05-T03_

- **2026-02-26** — Zaprojektowano Interface Endpoints dla Secrets Manager i SSM: subnety (`private-a`/`private-b`), dedykowany SG endpointów, ustawienia private DNS oraz integrację z outputami `network-core` (`private_subnet_ids`) w `docs/lessons/W05-endpoints-design.md`. _TaskId: W05-T04_

- **2026-02-26** — Rozszerzono `docs/runbooks/network-smoke-tests.md` o checklisty diagnostyczne dla VPC Endpoints (Gateway/Interface) i VPC Flow Logs (jak używać logów w troubleshooting). _TaskId: W05-T05_

