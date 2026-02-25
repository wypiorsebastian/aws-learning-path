## W00 — dziennik pracy

> Notuj tutaj krótkie wpisy z każdej sesji (czas, TaskId, co zostało zrobione / decyzje).

### Wzór wpisu
- `2026-02-25 20:15` — `W00-T01` — krótki opis wykonanej pracy / decyzji.

---

### Wpisy

- `2026-02-25 00:00` — `W00-T01` — przygotowano pierwszą wersję README.md z opisem projektu OrderFlow AWS Lab, kontekstem uczestnika, zakresem technicznym kursu oraz sposobem używania roadmapy i plików tygodniowych.
- `2026-02-25 00:05` — `W00-T02` — rozpoczęto pracę nad szablonami docs/lessons/_template.md i docs/troubleshooting/_template.md zgodnie z roadmapą i standardem dokumentacji.
- `2026-02-25 00:15` — `W00-T02` — utworzono szablony docs/lessons/_template.md (tygodniowe podsumowanie) oraz docs/troubleshooting/_template.md (notatki troubleshootingowe) zgodne z roadmapą (sekcje 9.1 i 9.2).
- `2026-02-25 00:20` — `W00-T03` — rozpoczęto pracę nad szkieletem solution .NET 8 (OrderFlow.sln i minimalny zestaw projektów startowych).
- `2026-02-25 00:25` — `W00-T03` — utworzono bazową strukturę katalogów src/*, infra/terraform/*, .github/workflows oraz pustą solucję OrderFlow.sln (bez projektów, do uzupełnienia w kolejnych tygodniach).
- `2026-02-25 00:30` — `W00-T04` — rozpoczęto pracę nad ADR-0001-course-scope.md (zakres kursu, profil uczestnika, dev-only, IaC, CI/CD).
- `2026-02-25 00:35` — `W00-T04` — utworzono docs/adr/ADR-0001-course-scope.md opisujący kontekst kursu, zakres techniczny (in scope / out of scope) oraz konsekwencje decyzji dla roadmapy W00–W24.
- `2026-02-25 00:40` — `W00-D01` — podsumowanie sesji: zrealizowano W00-T01 (README), W00-T02 (szablony lessons/troubleshooting), W00-T04 (ADR zakresu kursu), częściowo W00-T03 (struktura katalogów i pusta solucja bez projektów). Brak blockerów; decyzja: projekty .NET tworzymy dopiero przy realnych taskach funkcjonalnych. Next step: wybrać pierwszy projekt API (np. orders-api) do utworzenia w solucji i zrealizować pełny W00-T03 (projekty + dotnet build).
- `2026-02-25 00:45` — `W00-D02` — start sesji; fokus na utworzeniu projektu orders-api (.NET 8) w src/orders-api, dodaniu go do OrderFlow.sln i uruchomieniu dotnet build w ramach domknięcia W00-T03.

