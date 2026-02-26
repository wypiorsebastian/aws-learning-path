## W04 — taski tygodnia

### Kontekst
- **WeekId:** `W04`
- **Cel tygodnia:** Rozpocząć implementację VPC w Terraform i zrozumieć przepływy ruchu (routing, IGW, NAT, SG, NACL).
- **Outcome:** Przygotowany i zrozumiały plan dla modułu `network-core` oraz (docelowo) `terraform plan` dla podstaw sieci.

---

## Taski bazowe z roadmapy

### W04-T01 — Modele przepływu ruchu (Internet→ALB→ECS, ECS→NAT→AWS APIs)
- **TaskId:** `W04-T01`
- **Status:** `TODO`
- **Priorytet:** `P1`
- **Typ:** `Theory/Docs`
- **Cel:** Spisać i uporządkować modele przepływu ruchu w projektowanej VPC, które będą podstawą dla routingu i SG/NACL.
- **Estymata:** 45m
- **Input:**
  - Sekcja `W04` w `docs/roadmap/aws-course-roadmap-operational-0-24.md`.
  - Diagramy i opis z `docs/diagrams/vpc-dev.md` (W03-T04).
- **Kroki:**
  1. Zebrać z roadmapy i diagramu główne ścieżki ruchu (Internet→ALB→ECS/Lambda, ECS→NAT→AWS APIs).
  2. Spisać je jako scenariusze (wejście, ścieżka routingu, SG, NACL).
  3. Zaznaczyć, gdzie w przyszłości „wchodzą w grę” VPC Endpoints (W05), ale bez implementacji.
- **Verification:** Powstaje klarowna notatka/scenariusze przepływów, do których można się odwołać projektując route tables i SG/NACL.
- **Evidence:** Notatka (np. w `docs/lessons/W04-summary.md` lub osobny plik) + wpis w `log.md`.

---

### W04-T02 — Szkic modułu `network-core` (VPC, subnets, IGW, route tables)
- **TaskId:** `W04-T02`
- **Status:** `TODO`
- **Priorytet:** `P1`
- **Typ:** `IaC/Design`
- **Cel:** Zaprojektować strukturę i odpowiedzialności modułu Terraform `network-core` (bez konieczności generowania kodu, dopóki tego nie zażądasz).
- **Estymata:** 60m
- **Input:**
  - W03 — zaprojektowany CIDR i subnety (`docs/diagrams/vpc-dev.md`).
  - Sekcja W04 (Outcome, Artefakty) w roadmapie.
- **Kroki:**
  1. Wypisać zasoby, które ma obejmować moduł `network-core` (VPC, subnets, IGW, NAT, route tables + associations, tagi).
  2. Zaplanować interface modułu: wejścia (CIDR, lista AZ, parametry NAT), wyjścia (ID VPC, subnetów, route tables, NAT).
  3. Opisać strukturę katalogów/plików (np. `infra/terraform/modules/network-core/*`) i zasady naming/tagowania.
  4. (Opcjonalnie, jeśli poprosisz o kod) — rozpocząć implementację HCL, tak aby możliwe było `terraform plan`.
- **Verification:** Możesz słownie opisać, co robi moduł `network-core` i jakie ma wejścia/wyjścia; implementacja kodu jest mechaniczna na bazie opisu.
- **Evidence:** Opis modułu (np. sekcja w `docs/lessons/W04-summary.md` lub osobny dokument projektowy) + wpis w `log.md`.

---

### W04-T03 — Baseline SG i NACL pod VPC dev
- **TaskId:** `W04-T03`
- **Status:** `TODO`
- **Priorytet:** `P1`
- **Typ:** `IaC/Security/Design`
- **Cel:** Zaprojektować minimalny, sensowny zestaw Security Groups i NACL dla VPC dev (ALB, ECS/Lambda, RDS, subnety public/private).
- **Estymata:** 30m
- **Input:**
  - Modele przepływu ruchu z W04-T01.
  - Roadmapa (pułapki: NACL blokujące ephemeral ports).
- **Kroki:**
  1. Zdefiniować SG dla ALB, ECS/Lambdy i RDS (kto do kogo może się łączyć, na jakich portach).
  2. Zaprojektować prosty baseline NACL dla subnetów public/private (np. wariant dev-friendly + notatka o przyszłym hardeningu).
  3. Spisać tabelę SG/NACL (np. nazwa, typ, do czego przypięte, główne reguły).
  4. (Opcjonalnie, przy implementacji) — zmapować to na zasoby Terraform.
- **Verification:** Tabela SG/NACL jest spójna z modelami ruchu i jasno opisuje, co ma być dozwolone/odrzucone.
- **Evidence:** Tabela/nota w `docs/lessons/W04-summary.md` lub osobnym pliku + wpis w `log.md`.

---

### W04-T04 — Checklisty diagnostyczne: routing vs SG vs NACL
- **TaskId:** `W04-T04`
- **Status:** `TODO`
- **Priorytet:** `P2`
- **Typ:** `Docs/Runbook`
- **Cel:** Przygotować checklistę diagnostyczną do debugowania problemów sieciowych (routing, SG, NACL) dla VPC dev.
- **Estymata:** 15m
- **Input:**
  - Modele przepływu ruchu (W04-T01).
  - Zaprojektowane SG/NACL (W04-T03).
- **Kroki:**
  1. Wypisać kroki „kiedy coś nie działa”: co sprawdzić w kolejności (ALB, targety, route tables, SG, NACL).
  2. Dodać przykładowe objawy i możliwe przyczyny (np. 502/504 na ALB, brak wyjścia do Internetu z ECS).
  3. Zaplanować docelowe miejsce na tę checklistę (np. `docs/runbooks/network-smoke-tests.md` zgodnie z roadmapą; na razie szkic).
- **Verification:** Checklista jest konkretna, można ją przejść krok po kroku przy realnym błędzie.
- **Evidence:** Notatka/checklista (np. jako szkic `network-smoke-tests`) + wpis w `log.md`.

---

## Verification (zbiorczy checklist z roadmapy)
- [ ] `terraform fmt`
- [ ] `terraform validate`
- [ ] `terraform plan` dla `network-core` bez błędów składni/logiki

## Evidence (zbiorczy z roadmapy)
- `docs/lessons/W04-summary.md`
- plan output (fragmenty kluczowe) — gdy kod Terraform będzie istniał i zostanie uruchomiony
- tabela SG/NACL

