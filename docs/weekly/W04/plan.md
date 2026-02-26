## W04 — plan sesji D1–D5

### Kontekst tygodnia
- **Cel tygodnia:** Rozpocząć implementację VPC w Terraform i zrozumieć przepływy ruchu (routing, NAT, SG, NACL) na bazie designu z W03.
- **WhyNow:** Bez poprawnie zaprojektowanego routingu, IGW/NAT oraz podstawowych reguł SG/NACL troubleshooting w kolejnych tygodniach (endpoints, ECS, RDS, deploye) będzie chaotyczny.
- **Outcome (wg roadmapy):** `terraform plan` dla podstaw sieci (moduł `network-core`).
- **DoD (skrót):** Plan (architektura i IaC) jest spójny i zrozumiały; baza pod implementację/uruchomienie `network-core`.

### Założenia czasowe
- 5 sesji po **1.5h** (D1–D5).
- Fokus: zrozumienie **routing/IGW/NAT/SG/NACL** i przygotowanie sensownego planu/konstrukcji modułu `network-core`.  
  Generowanie samego kodu Terraform nastąpi tylko, jeśli o to wyraźnie poprosisz (zgodnie z regułą projektu).

---

## D1 (1.5h) — Modele przepływu ruchu (W04-T01)
- [ ] Przeczytać sekcję `W04` w `docs/roadmap/aws-course-roadmap-operational-0-24.md` (cel, DoD, pułapki).
- [ ] Przejrzeć `docs/diagrams/vpc-dev.md` (szczególnie sekcję „Przepływ ruchu (W03-T04)”).
- [ ] Na bazie roadmapy i diagramu spisać (w notatce / szkicu lekcji W04) modele przepływu:
  - Internet → IGW → ALB → ECS/Lambda (private),
  - ECS/Lambda → NAT → AWS APIs / Internet,
  - ECS/Lambda → VPC Endpoints (świadomość, że to temat W05, ale routing już teraz ma to uwzględniać).
- [ ] Zaznaczyć w notatce, które elementy są **stateful** (SG), a które **stateless** (NACL, routing).

**Cel D1:** mieć spisane, jasne modele przepływu ruchu, które staną się podstawą do projektowania route tables i reguł SG/NACL.

---

## D2 (1.5h) — Szkic modułu `network-core` (bez kodu) (W04-T02 — design)
- [ ] Na bazie W03 i W04 wypisać, co ma zawierać moduł `network-core` (na poziomie koncepcji, nie kodu):
  - VPC (CIDR z W03),
  - subnets (public/private w 2 AZ),
  - IGW,
  - route tables i ich asociacje (public/private vs IGW/NAT),
  - NAT Gateway (1 szt. w `public-a`),
  - podstawowe tagowanie.
- [ ] Zaprojektować strukturę modułu na papierze / w notatce:
  - wejścia (np. CIDR, lista AZ, parametry dot. NAT),
  - wyjścia (np. IDs VPC, subnetów, route tables).
- [ ] Zapisać szkic struktury katalogów/plików (np. `infra/terraform/modules/network-core/*`) — nadal na poziomie opisu, bez generowania HCL.

**Cel D2:** mieć opisany, spójny plan modułu `network-core`, gotowy do implementacji w Terraform, gdy zdecydujesz się na generowanie kodu.

---

## D3 (1.5h) — SG i NACL: baseline i tabelka (W04-T03 przygotowanie)
- [ ] Przypomnieć różnice:
  - Security Group vs NACL (stateful vs stateless, ingress/egress, poziom zastosowania).
- [ ] Zaprojektować „baseline”:
  - min. 1 SG dla ALB (otwarty tylko na potrzebne porty z Internetu),
  - SG dla ECS/Lambdy (przyjmujący ruch tylko z ALB / z określonych źródeł),
  - SG dla RDS (przyjmujący ruch tylko z ECS/Lambdy).
- [ ] Naszkicować minimalne NACL dla subnetów public/private:
  - prosty wariant „allow all” (z anotacją, że to baseline dev) vs bardziej restrykcyjny wariant do przyszłego hardeningu.
- [ ] Zapisać tabelkę SG/NACL (np. w osobnej notatce lub szkicu pod przyszłą „tabelę SG/NACL” z roadmapy).

**Cel D3:** wiedzieć, jakie SG/NACL będą potrzebne i jakie mają mieć role — tak, by ich dodanie w Terraform (W04-T03) było mechaniczne.

---

## D4 (1.5h) — Checklisty diagnostyczne: routing vs SG vs NACL (W04-T04)
- [ ] Na bazie modeli przepływu ruchu i SG/NACL ułożyć checklistę troubleshootingową:
  - pytania typu: „czy ruch dochodzi do ALB?”, „czy route table prywatnego subnetu kieruje do NAT?”, „czy SG pozwala na dany port?”, „czy NACL nie blokuje ephemeral ports?”.
- [ ] Zapisać checklistę w formie kroków diagnostycznych (np. do docelowego `docs/runbooks/network-smoke-tests.md` lub notatki W04).
- [ ] Dodać przykłady typowych symptomów:
  - 502/504 na ALB,
  - brak odpowiedzi z aplikacji w ECS,
  - time-out przy wyjściu do Internetu z ECS.

**Cel D4:** mieć konkretną checklistę, która pomoże diagnozować problemy z siecią, gdy `network-core` będzie już zaimplementowany.

---

## D5 (1.5h) — Podsumowanie tygodnia i przygotowanie pod `terraform plan`
- [ ] Przejrzeć DoD z roadmapy dla W04:
  - `terraform fmt`,
  - `terraform validate`,
  - `terraform plan` bez błędów składni/logiki.
- [ ] Zidentyfikować, czego jeszcze brakuje, żeby móc uruchomić `terraform plan` (np. brak faktycznych plików HCL, brak backendu state, brak zmiennych).
- [ ] Uzupełnić:
  - `docs/weekly/W04/evidence.md` — co jest gotowe (modele, szkic modułu, SG/NACL, checklista) i co będzie evidence po uruchomieniu Terraforma,
  - `docs/weekly/W04/summary.md` — co zostało zaprojektowane/ustalone.
- [ ] Jeśli zdecydujesz się w tym tygodniu poprosić o wygenerowanie kodu Terraform:
  - zaplanować mini-task na uruchomienie `terraform fmt/validate/plan` na module `network-core`.

**Cel D5:** mieć pełną dokumentację i plan pod `network-core`, tak aby wejście w realne `terraform plan` (czy to w W04, czy w kolejnym kroku) było proste i świadome.

