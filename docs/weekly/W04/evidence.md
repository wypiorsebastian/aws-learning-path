## W04 — evidence

Dowody wykonania zadań i spełnienia DoD. Po aktualizacji roadmapy W04 jest tygodniem **design-only**: oczekiwane są modele przepływu ruchu, projekt modułu `network-core`, tabela SG/NACL oraz checklisty diagnostyczne (bez implementacji Terraform).

---

### W04-T01 — Modele przepływu ruchu
- **Oczekiwane:** Notatka opisująca scenariusze ruchu (Internet→ALB→ECS/Lambda, ECS→NAT→AWS APIs) na bazie topologii z W03.
- **Link / opis:** `docs/lessons/W04-traffic-models.md` — inwentarz elementów (sieć, komponenty, usługi AWS), scenariusze A1–C2, macierz przepływu, synteza route tables, stateful vs stateless, pułapki.

### W04-T02 — Szkic modułu `network-core`
- **Oczekiwane:** Opis modułu (jakie zasoby obejmuje, jakie ma wejścia/wyjścia, jak będzie wyglądała struktura katalogów/plików Terraform).
- **Link / opis:** `docs/lessons/W04-network-core-module-design.md` — zasoby AWS, variables, outputs (gotowe pod W05 network-endpoints i moduły ALB/ECS/RDS/Lambda), struktura katalogów, naming/tagowanie, integracja z W05.

### W04-T03 — Baseline SG i NACL
- **Oczekiwane:** Tabela SG/NACL (nazwa, rola, przypięte zasoby, główne reguły) spójna z modelami ruchu.
- **Link / opis:** `docs/lessons/W04-sg-nacl-baseline.md` — sg_alb, sg_app, sg_rds (reguły ingress/egress), rekomendacja NACL: domyślny VPC NACL w dev (Opcja A) + notatka o Opcji B (własny NACL) dla przyszłego hardeningu.

### W04-T04 — Checklisty diagnostyczne
- **Oczekiwane:** Checklista kroków diagnostycznych: routing vs SG vs NACL, z typowymi symptomami i możliwymi przyczynami.
- **Link / opis:** `docs/runbooks/network-smoke-tests.md` — kolejność diagnostyki (routing → SG → NACL), objawy 502/504, brak wyjścia do Internetu, ECS↔RDS, Lambda w VPC, szybka checklista, przykładowe komendy AWS CLI.

### DoD
- **Kryterium:** Design sieci (modele ruchu, projekt modułu `network-core`, tabela SG/NACL, checklisty diagnostyczne) jest spójny i zrozumiały oraz gotowy jako input do implementacji w W06.
- **Potwierdzenie:** Spełnione — `docs/lessons/W04-traffic-models.md` opisuje spójne z W03 modele ruchu; `docs/lessons/W04-network-core-module-design.md` definiuje odpowiedzialności, wejścia/wyjścia i strukturę modułu `network-core` (gotową pod W05/W06/W07); `docs/lessons/W04-sg-nacl-baseline.md` zawiera tabelę SG/NACL zgodną z modelami ruchu; `docs/runbooks/network-smoke-tests.md` dostarcza checklist diagnostycznych routing/SG/NACL. Na tej bazie implementacja Terraform w W06 może być przeprowadzona mechanicznie.

