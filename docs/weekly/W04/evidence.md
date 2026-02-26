## W04 — evidence

Dowody wykonania zadań i spełnienia DoD. Roadmapa oczekuje: `terraform fmt/validate/plan` dla modułu `network-core` oraz tabeli SG/NACL.

---

### W04-T01 — Modele przepływu ruchu
- **Oczekiwane:** Notatka opisująca scenariusze ruchu (Internet→ALB→ECS/Lambda, ECS→NAT→AWS APIs) na bazie topologii z W03.
- **Link / opis:** _(do uzupełnienia po wykonaniu)_

### W04-T02 — Szkic modułu `network-core`
- **Oczekiwane:** Opis modułu (jakie zasoby obejmuje, jakie ma wejścia/wyjścia, jak będzie wyglądała struktura katalogów/plików Terraform).
- **Link / opis:** _(do uzupełnienia po wykonaniu)_

### W04-T03 — Baseline SG i NACL
- **Oczekiwane:** Tabela SG/NACL (nazwa, rola, przypięte zasoby, główne reguły) spójna z modelami ruchu.
- **Link / opis:** _(do uzupełnienia po wykonaniu)_

### W04-T04 — Checklisty diagnostyczne
- **Oczekiwane:** Checklista kroków diagnostycznych: routing vs SG vs NACL, z typowymi symptomami i możliwymi przyczynami.
- **Link / opis:** _(do uzupełnienia po wykonaniu)_

### DoD
- **Kryterium:** Plan dla modułu `network-core` jest spójny i zrozumiały; po ewentualnej implementacji Terraform powinien przejść `fmt/validate/plan` bez błędów.
- **Potwierdzenie:** _(do uzupełnienia przy week-finish W04, po ocenie względem roadmapy)_

