## W00 — plan sesji D1–D5

### Kontekst tygodnia
- **Cel tygodnia:** Zdefiniować projekt, repo, standard pracy i artefakty dokumentacyjne.
- **WhyNow:** Bez tego później zniknie kontekst i spójność.
- **Outcome (wg roadmapy):** Repo-szkielet + roadmapa + szablony dokumentacji; repo gotowe do startu W01.

### Założenia czasowe
- 5 sesji po **1.5h** (D1–D5).
- W tym tygodniu **nie implementujemy jeszcze AWS/Terraform**, skupiamy się na szkielecie repo i dokumentacji.

---

## D1 (1.5h) — Roadmapa, repo i README
- [ ] Przeczytać sekcję `W00` w `docs/roadmap/aws-course-roadmap-operational-0-24.md` i upewnić się, że rozumiem cel tygodnia.
- [ ] Zweryfikować, że repo lokalne jest gotowe do pracy (Git zainicjowany, podstawowa struktura katalogów).
- [ ] Opracować pierwszą wersję opisu projektu **OrderFlow AWS Lab** w `README.md`:
  - cel projektu,
  - kontekst uczestnika (senior .NET, Azure → AWS),
  - wysokopoziomowy zakres kursu (zakres usług AWS, .NET, Terraform/CI-CD).
- [ ] Zaplanować, jakie sekcje będą w finalnym README (architektura, uruchomienie, linki do dokumentacji).

**Cel D1:** mieć jasny opis *po co* jest projekt i jak roadmapa przekłada się na repo.

---

## D2 (1.5h) — Szablony lekcji i troubleshooting
- [ ] Utworzyć plik `docs/lessons/_template.md` na podstawie sekcji „Szablon tygodniowego podsumowania” z roadmapy.
- [ ] Utworzyć plik `docs/troubleshooting/_template.md` zgodnie z wytycznymi z roadmapy (sekcje: Objaw, Kontekst, Root cause, Diagnoza, Fix, Jak poznam, że działa, Jak zapobiec).
- [ ] Upewnić się, że szablony są napisane po polsku i trzymają się standardu dokumentacyjnego repo.
- [ ] Dodać krótką notatkę w `docs/roadmap/` lub innym miejscu, gdzie będą linki do szablonów (opcjonalnie, jeśli będzie potrzebne).

**Cel D2:** mieć gotowe szablony, które będą używane przez kolejne tygodnie (lessons + troubleshooting).

---

## D3 (1.5h) — Szkielet rozwiązań .NET
- [ ] Zaplanować strukturę rozwiązania `.NET 8` dla `OrderFlow AWS Lab` (solution + projekty API/worker).
- [ ] Utworzyć `OrderFlow.sln` oraz placeholder projekty (bez szczegółowej implementacji logiki biznesowej).
- [ ] Zweryfikować lokalnie, że `dotnet build` przechodzi dla całego solution.
- [ ] Zanotować w `docs/weekly/W00/log.md` krótką informację o podjętych decyzjach dotyczących nazw projektów i struktury.

**Cel D3:** mieć lokalnie budujące się solution `.NET 8`, które będzie podstawą pod kolejne tygodnie.

---

## D4 (1.5h) — ADR zakresu kursu
- [ ] Przeczytać ponownie globalne cele kursu (sekcja „Cel kursu” w roadmapie).
- [ ] Utworzyć `docs/adr/ADR-0001-course-scope.md` opisujący:
  - zakres techniczny kursu (AWS, .NET, Terraform, CI/CD),
  - cel projektu z punktu widzenia portfolio i rozmów rekrutacyjnych,
  - założenia kosztowe (`dev-only`),
  - decyzje, czego świadomie **nie** robimy w tej fazie.
- [ ] Związać ADR z roadmapą (referencje do odpowiednich sekcji).

**Cel D4:** mieć formalny ADR, który jasno definiuje scope kursu i projektu.

---

## D5 (1.5h) — Domknięcie W00 i weryfikacja DoD
- [ ] Upewnić się, że wszystkie zadania W00 z roadmapy mają stan zgodny z rzeczywistością.
- [ ] Zweryfikować kryteria DoD tygodnia W00:
  - [ ] `dotnet build` przechodzi lokalnie.
  - [ ] Repo ma strukturę katalogów zgodną z roadmapą.
  - [ ] README opisuje projekt, cel i zakres kursu.
- [ ] Uzupełnić `docs/lessons/W00-summary.md` (na bazie szablonu) — podsumowanie tygodnia.
- [ ] Zaktualizować `docs/weekly/index.md` (status W00, next step na W01).

**Cel D5:** zamknąć tydzień W00 jako „repo gotowe do rozpoczęcia tygodnia 1”.

