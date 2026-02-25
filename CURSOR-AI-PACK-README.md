# Cursor AI Pack — AWS/.NET Learning Project

To jest starter pack do projektu szkoleniowego AWS dla senior .NET developera (Azure → AWS, DevOps-ready).

## Co zawiera
- `.cursor/rules/*.mdc` — reguły pracy agenta (mentor mode, roadmapa, weekly artifacts, guardrails)
- `.cursor/commands/*.md` — komendy slash do pracy tygodniowej i taskowej
- `.cursor/skills/**/SKILL.md` — skille do orkiestracji tygodnia, wyjaśniania, troubleshootingu, audytu DoD, ADR
- `docs/weekly/index.md` + szablony plików tygodniowych

## Ważne założenia
- komunikacja po polsku,
- projekt szkoleniowy (learning-by-building),
- roadmapa jako source of truth,
- brak generowania kodu bez wyraźnej prośby użytkownika.

## Zalecany start
1. Skopiuj pliki do repo.
2. Upewnij się, że roadmapa istnieje pod ścieżką:
   - `docs/roadmap/aws-course-roadmap-operational-0-24.md`
3. Otwórz Cursor i sprawdź, czy rules/skills są widoczne.
4. Uruchom:
   - `/week-start W00`

## Jeśli chcesz rozszerzyć pakiet
- dodaj reguły per język / per framework,
- dodaj command do generowania `docs/weekly/Wxx/` z gotowych templatek,
- dodaj dodatkowy skill do review dokumentacji / repo cleanup.
