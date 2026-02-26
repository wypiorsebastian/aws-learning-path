## W03 — taski tygodnia

### Kontekst
- **WeekId:** `W03`
- **Cel tygodnia:** Zaprojektować topologię sieciową dev dla całego projektu (VPC, subnety, adresacja).
- **Outcome:** Diagram + tabela subnetów + decyzje kosztowe (NAT); topologia gotowa do implementacji w Terraform.

---

## Taski bazowe z roadmapy

### W03-T01 — Zdefiniuj CIDR VPC i subnety (public/private, min. 2 AZ)
- **TaskId:** `W03-T01`
- **Status:** `DONE`
- **Priorytet:** `P1`
- **Typ:** `Design`
- **Cel:** Przygotować CIDR dla VPC oraz tabelę subnetów (public i private w minimum dwóch AZ) bez konfliktów adresowych.
- **Estymata:** 60m
- **Input:**
  - Sekcja `W03` w `docs/roadmap/aws-course-roadmap-operational-0-24.md`.
  - Limity AWS (rozmiar subnetu min. /28, adresy zarezerwowane, max VPC /16).
  - Założenie dev-only: jeden region, min. 2 AZ.
- **Kroki:**
  1. Wybrać CIDR VPC (np. 10.0.0.0/16).
  2. Podzielić przestrzeń na subnety public i private w każdej AZ (np. public-a, private-a, public-b, private-b).
  3. Spisać tabelę: nazwa subnetu, AZ, CIDR, typ (public/private).
  4. Zweryfikować brak nakładania się zakresów.
- **Verification:** Tabela subnetów nie zawiera konfliktów CIDR (checklist z roadmapy).
- **Evidence:** Tabela w `docs/diagrams/vpc-dev.md` lub w `docs/adr/ADR-0004-vpc-dev-topology.md`; wpis w `log.md`.

---

### W03-T02 — Rozmieść komponenty (ALB, ECS, RDS, endpoints, Lambda VPC if needed)
- **TaskId:** `W03-T02`
- **Status:** `DONE`
- **Priorytet:** `P1`
- **Typ:** `Design`
- **Cel:** Przypisać każdemu komponentowi projektu (ALB, ECS, RDS, VPC Endpoints, ewentualnie Lambda w VPC) typ subnetu i AZ.
- **Estymata:** 30m
- **Input:**
  - Tabela subnetów z W03-T01.
  - Lista komponentów: ALB, ECS Fargate, RDS, VPC Endpoints (Gateway/Interface), Lambda (jeśli w VPC).
- **Kroki:**
  1. ALB → subnety publiczne (obie AZ).
  2. ECS (Fargate) → subnety prywatne (obie AZ).
  3. RDS → subnety prywatne (obie AZ).
  4. VPC Endpoints — gdzie będą (np. subnety prywatne); świadomość Gateway vs Interface.
  5. Lambda — decyzja: na razie bez VPC czy w private; zapisać.
  6. Uzupełnić tabelę lub diagram kolumną „Komponenty”.
- **Verification:** Każdy komponent ma przypisany typ subnetu (checklist z roadmapy).
- **Evidence:** Zaktualizowana tabela/diagram w `docs/diagrams/vpc-dev.md` lub ADR; wpis w `log.md`.

---

### W03-T03 — Opisz kompromis dev-only: 1 NAT vs HA NAT per AZ
- **TaskId:** `W03-T03`
- **Status:** `DONE`
- **Priorytet:** `P1`
- **Typ:** `ADR`
- **Cel:** Udokumentować w ADR trade-off między jednym NAT Gateway a NAT per AZ oraz uzasadnić wybór dla dev-only.
- **Estymata:** 30m
- **Input:**
  - Roadmapa W03 (pułapki, koszt, dev-only).
  - Dobra praktyka: w prod zwykle NAT per AZ; w dev często jeden NAT ze względu na koszt.
- **Kroki:**
  1. Opisać opcję: 1 NAT (jedna AZ) — koszt, SPOF, wystarczające dla dev.
  2. Opisać opcję: NAT per AZ — HA, wyższy koszt.
  3. Zdecydować i zapisać decyzję dla środowiska dev.
  4. Dodać consequences (np. przy przejściu do prod — dodanie drugiego NAT).
- **Verification:** ADR opisuje trade-off koszt/HA (checklist z roadmapy).
- **Evidence:** `docs/adr/ADR-0004-vpc-dev-topology.md` (sekcja NAT); wpis w `log.md`.

---

### W03-T04 — Uzupełnij diagram przepływu ruchu (public → private)
- **TaskId:** `W03-T04`
- **Status:** `DONE`
- **Priorytet:** `P2`
- **Typ:** `Docs`
- **Cel:** Udokumentować przepływ ruchu: Internet → ALB (public) → ECS (private) oraz wyjście z private (NAT → IGW / AWS APIs).
- **Estymata:** 30m
- **Input:**
  - Tabela subnetów i rozmieszczenie komponentów (W03-T01, W03-T02).
  - Decyzja NAT z W03-T03.
- **Kroki:**
  1. Narysować lub opisać krok po kroku: ruch przychodzący (Internet → IGW → ALB w public → ECS w private).
  2. Narysować lub opisać: ruch wychodzący z private (ECS/RDS → NAT Gateway → IGW lub VPC Endpoints).
  3. Umieścić diagram/opis w `docs/diagrams/vpc-dev.md` lub w ADR-0004.
- **Verification:** Diagram/opis jest spójny z tabelą subnetów i decyzjami NAT.
- **Evidence:** Diagram/opis w `docs/diagrams/vpc-dev.md` lub ADR; wpis w `log.md`.

---

## Verification (zbiorczy checklist z roadmapy)
- [ ] Tabela subnetów nie zawiera konfliktów CIDR
- [ ] Każdy komponent ma przypisany typ subnetu
- [ ] ADR opisuje trade-off koszt/HA (NAT)

## Evidence (zbiorczy z roadmapy)
- `docs/lessons/W03-summary.md`
- `docs/adr/ADR-0004-vpc-dev-topology.md`
- Diagram + tabela CIDR (w `docs/diagrams/vpc-dev.md` lub w ADR)
