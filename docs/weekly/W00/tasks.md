## W00 — taski tygodnia

### Kontekst
- **WeekId:** `W00`
- **Cel tygodnia:** Zdefiniować projekt, repo, standard pracy i artefakty dokumentacyjne.
- **Outcome:** Repo-szkielet + roadmapa + szablony dokumentacji; repo gotowe do startu W01.

---

## Taski bazowe z roadmapy

### W00-T01 — Opis projektu w README
- **TaskId:** `W00-T01`
- **Status:** `DONE`
- **Priorytet:** `P1`
- **Typ:** `Design`
- **Cel:** Opisać projekt `OrderFlow AWS Lab` w `README.md`, tak aby nowa osoba mogła zrozumieć cel, kontekst i zakres kursu.
- **Estymata:** 45m
- **Input:**
  - Sekcja „Opis projektu kursowego — OrderFlow AWS Lab” w roadmapie.
  - Sekcje „Cel kursu” i „Cele końcowe (Course Outcomes)”.
- **Kroki:**
  1. Przeczytać sekcje 2–3 roadmapy (cel kursu, opis projektu).
  2. Wypisać główne cele projektu i rolę `OrderFlow AWS Lab` jako nośnika nauki.
  3. Uzupełnić `README.md` o:
     - krótki opis domeny (orders, payments, catalog, async processing),
     - główne komponenty docelowe (API, worker, lambdy, Terraform, CI/CD),
     - sposób używania roadmapy i tygodniowych artefaktów.
  4. Zapisać w `docs/weekly/W00/log.md` krótką notatkę z decyzjami (jak opisano projekt).
- **Verification:**
  - README wyjaśnia *po co* jest projekt i jak wpisuje się w kurs.
  - Po przeczytaniu README można wytłumaczyć projekt osobie trzeciej w 1–2 minutach.
- **Evidence:**
  - Zaktualizowany `README.md`.
  - Wpis w `docs/weekly/W00/log.md` z numerem taska.

---

### W00-T02 — Szablony lessons i troubleshooting
- **TaskId:** `W00-T02`
- **Status:** `DONE`
- **Priorytet:** `P1`
- **Typ:** `Docs`
- **Cel:** Utworzyć szablony `docs/lessons/_template.md` i `docs/troubleshooting/_template.md` zgodnie z roadmapą i regułami dokumentacyjnymi projektu.
- **Estymata:** 45m
- **Input:**
  - Sekcja 9.1 i 9.2 roadmapy (szablony).
  - Zasady dokumentacji z `.cursor/rules/04-documentation-style-pl.mdc`.
- **Kroki:**
  1. Skopiować treść szablonu tygodniowego podsumowania z roadmapy do `docs/lessons/_template.md`.
  2. Zaprojektować `docs/troubleshooting/_template.md` z sekcjami:
     - Objaw
     - Kontekst
     - Root cause
     - Diagnoza (kroki)
     - Fix
     - Jak poznam, że działa
     - Jak zapobiec
  3. Sprawdzić, że oba pliki są po polsku i mają spójny styl.
  4. Dodać wpis do `docs/weekly/W00/log.md` z numerem taska i krótkim opisem.
- **Verification:**
  - Oba szablony są gotowe do kopiowania dla kolejnych tygodni/incidentów.
  - Struktura szablonów zgadza się z roadmapą i regułami dokumentacji.
- **Evidence:**
  - Pliki `docs/lessons/_template.md` i `docs/troubleshooting/_template.md` w repo.
  - Wpis w `docs/weekly/W00/log.md`.

---

### W00-T03 — Szkielet solution .NET 10
- **TaskId:** `W00-T03`
- **Status:** `DONE`
- **Priorytet:** `P1`
- **Typ:** `Coding/Setup`
- **Cel:** Utworzyć solution `OrderFlow.sln` z placeholder projektami .NET 10, które będą używane w kolejnych tygodniach.
- **Estymata:** 30m
- **Input:**
  - Sekcja 3 („Opis projektu kursowego”) z listą docelowych komponentów.
  - Zainstalowane lokalnie .NET 10 SDK.
- **Kroki:**
  1. Zaplanować minimalny zestaw projektów startowych (np. 1–2 API + 1 worker; reszta może dojść później).
  2. Utworzyć solution `OrderFlow.sln`.
  3. Utworzyć placeholder projekty .NET 8 i dodać je do solution.
  4. Uruchomić `dotnet build` na całym solution.
  5. Zalogować wyniki i podjęte decyzje (jakie projekty powstały) w `docs/weekly/W00/log.md`.
- **Verification:**
  - `dotnet build` przechodzi lokalnie dla całego solution.
  - Struktura solution jest zgodna z kierunkiem z roadmapy (APIs + worker).
- **Evidence:**
  - Output `dotnet build` (np. fragment w `docs/weekly/W00/evidence.md` lub `docs/lessons/W00-summary.md`).
  - Wpis w `docs/weekly/W00/log.md`.

---

### W00-T04 — ADR zakresu kursu
- **TaskId:** `W00-T04`
- **Status:** `DONE`
- **Priorytet:** `P2`
- **Typ:** `Docs`
- **Cel:** Utworzyć `docs/adr/ADR-0001-course-scope.md`, który formalnie opisze zakres kursu i projektu.
- **Estymata:** 30m
- **Input:**
  - Sekcja „Cel kursu” i „Cele końcowe” w roadmapie.
  - Lista tygodni `W00–W24`.
- **Kroki:**
  1. Zdefiniować problem/konkretną decyzję: jaki jest zakres kursu i projektu `OrderFlow AWS Lab`.
  2. Opisać kontekst (profil uczestnika, horyzont czasowy, dev-only, IaC, CI/CD).
  3. Wypisać decyzje: co obejmuje kurs (usługi AWS, .NET, Terraform, GitHub Actions) oraz co jest poza zakresem.
  4. Dodać sekcję „Konsekwencje” (co ta decyzja oznacza dla dalszej roadmapy).
  5. Zalogować zakończenie taska w `docs/weekly/W00/log.md`.
- **Verification:**
  - ADR jasno opisuje scope kursu i można do niego odwołać się w kolejnych tygodniach.
  - Dokument zawiera sekcje typowego ADR (kontekst, decyzja, konsekwencje).
- **Evidence:**
  - Plik `docs/adr/ADR-0001-course-scope.md` w repo.
  - Wpis w `docs/weekly/W00/log.md`.

