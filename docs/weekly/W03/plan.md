## W03 — plan sesji D1–D5

### Kontekst tygodnia
- **Cel tygodnia:** Zaprojektować topologię sieciową dev dla całego projektu (VPC, subnety, adresacja).
- **WhyNow:** Hosting, RDS, ECS, ALB i endpointy będą zależne od tej decyzji — bez projektu sieci nie da się sensownie ruszyć z Terraform w W04.
- **Outcome (wg roadmapy):** Diagram + tabela subnetów + decyzje kosztowe (NAT).
- **DoD (skrót):** Topologia gotowa do implementacji w Terraform.

### Założenia czasowe
- 5 sesji po **1.5h** (D1–D5).
- Fokus: **design tylko** — brak Terraform/kodu. Artefakty: ADR, diagram, tabela CIDR, notatki.

---

## D1 (1.5h) — CIDR VPC i subnety: założenia i szkic (W03-T01, początek)
- [ ] Przeczytać sekcję `W03` w `docs/roadmap/aws-course-roadmap-operational-0-24.md` (cel, DoD, pułapki).
- [ ] Przypomnieć sobie limity VPC/subnetów AWS (min. /28 na subnet, max /16 na VPC, rezerwowane adresy w subnetach).
- [ ] Zdefiniować założenia dev-only: jeden region, min. 2 AZ (np. eu-central-1a, eu-central-1b).
- [ ] Wybrać CIDR dla VPC (np. 10.0.0.0/16 lub mniejszy, z uwzględnieniem ewentualnego peeringu/VPN w przyszłości).
- [ ] Rozpocząć tabelę subnetów: public vs private, po min. jednym w każdej AZ; zapisać zakresy CIDR bez konfliktów.
- [ ] Zanotować pułapki z roadmapy: za mały CIDR, mieszanie public/private.

**Cel D1:** mieć wybrany CIDR VPC i szkic tabeli subnetów (public/private × 2 AZ).

---

## D2 (1.5h) — Tabela subnetów i rozmieszczenie komponentów (W03-T01 dokończenie, W03-T02)
- [ ] Dokończyć tabelę subnetów: wszystkie zakresy CIDR, brak nakładania się, nazewnictwo (np. public-a, private-a, public-b, private-b).
- [ ] Zweryfikować: tabela nie zawiera konfliktów CIDR (Verification z roadmapy).
- [ ] Rozmieścić komponenty z projektu kursowego w subnetach:
  - ALB → subnety publiczne (obie AZ),
  - ECS (Fargate) → subnety prywatne (obie AZ),
  - RDS → subnety prywatne (obie AZ),
  - VPC Endpoints (Gateway/Interface) — świadomość, gdzie będą (np. private),
  - Lambda (jeśli VPC) — gdzie umieścić lub notatka „na razie bez VPC”.
- [ ] Uzupełnić tabelę o kolumnę „Komponenty” lub osobny diagram rozmieszczenia.
- [ ] Zapisać wynik w `docs/diagrams/vpc-dev.md` (tabela + krótki opis) lub w ADR.

**Cel D2:** tabela subnetów gotowa; każdy komponent ma przypisany typ subnetu (Verification).

---

## D3 (1.5h) — ADR: kompromis NAT dev-only (W03-T03)
- [ ] Opisać w ADR-0004 (lub osobnym szkicu) trade-off:
  - **1 NAT Gateway** (jedna AZ): niższy koszt, SPOF, wystarczający dla dev-only.
  - **NAT per AZ** (HA): wyższy koszt, brak SPOF, typowy dla prod.
- [ ] Zdecydować i udokumentować wybór dla środowiska dev (roadmapa: dev-only → świadoma optymalizacja kosztów).
- [ ] Dodać sekcję „Consequences” w ADR: co się zmieni, gdy kiedyś będzie prod (np. dodanie drugiego NAT).
- [ ] Uzupełnić `docs/adr/ADR-0004-vpc-dev-topology.md`: kontekst, decyzja CIDR/subnety, decyzja NAT, diagram/tabela (odniesienie).

**Cel D3:** ADR opisuje trade-off koszt/HA dla NAT i zawiera jasną decyzję na dev.

---

## D4 (1.5h) — Diagram przepływu ruchu public → private (W03-T04)
- [ ] Narysować (ASCII/Mermaid lub opis kroków) przepływ ruchu:
  - Internet → IGW → ALB (public subnets) → ECS (private subnets),
  - ECS / RDS w private → ruch do internetu/AWS APIs → NAT Gateway → IGW.
- [ ] Uwzględnić w diagramie lub w notatce: gdzie jest NAT (w której AZ), jak route tables kierują ruch.
- [ ] Dodać diagram do `docs/diagrams/vpc-dev.md` lub do ADR-0004.
- [ ] Sprawdzić, że nic nie „wisi w powietrzu” — każdy komponent ma określony typ subnetu i kierunek ruchu.

**Cel D4:** diagram przepływu ruchu (public → private i wyjście z private) jest udokumentowany.

---

## D5 (1.5h) — Weryfikacja DoD W03 i podsumowanie
- [ ] Przejrzeć kryteria DoD z roadmapy: „Topologia gotowa do implementacji w Terraform”.
- [ ] Checklist Verification:
  - [ ] Tabela subnetów nie zawiera konfliktów CIDR,
  - [ ] Każdy komponent ma przypisany typ subnetu,
  - [ ] ADR opisuje trade-off koszt/HA (NAT).
- [ ] Uzupełnić `docs/lessons/W03-summary.md`: co zaprojektowano, kluczowe decyzje, pułapki na które uważać.
- [ ] Uzupełnić `docs/weekly/W03/evidence.md` i `summary.md`.
- [ ] Zaktualizować `docs/weekly/index.md` przy domykaniu tygodnia (status, next step na W04).

**Cel D5:** DoD spełniony, evidence i summary gotowe, gotowość do W04 (Terraform network-core).
