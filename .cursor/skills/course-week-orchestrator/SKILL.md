---
name: course-week-orchestrator
description: Orkiestruje start, prowadzenie i domknięcie tygodnia nauki na podstawie roadmapy projektu AWS/.NET. Użyj gdy rozpoczynasz tydzień, wracasz po przerwie albo chcesz zsynchronizować tygodniowe artefakty z roadmapą.
---

# Course Week Orchestrator

Skill do zarządzania tygodniami (`W00..W24`) w projekcie szkoleniowym opartym o roadmapę i artefakty tygodniowe.

## When to Use

- Gdy użytkownik zaczyna nowy tydzień nauki (`/week-start`).
- Gdy trzeba rozbić tydzień na taski `Wxx-Tyy`.
- Gdy trzeba wygenerować lub zsynchronizować pliki `docs/weekly/Wxx/*`.
- Gdy użytkownik wraca po przerwie i trzeba odzyskać kontekst.
- Gdy zamykasz tydzień i oceniasz DoD (`/week-finish` / `/roadmap-sync`).

## Instructions

- Zawsze zacznij od odczytu roadmapy:
  - `docs/roadmap/aws-course-roadmap-operational-0-24.md`
- Traktuj roadmapę jako source of truth dla:
  - celu tygodnia,
  - WhyNow,
  - DoD,
  - Evidence,
  - zadań bazowych.
- Twórz i utrzymuj folder tygodnia:
  - `docs/weekly/Wxx/`
- Minimalny zestaw plików tygodnia:
  - `plan.md`
  - `tasks.md`
  - `log.md`
  - `evidence.md`
  - `questions.md`
  - `summary.md`
- Każdy task musi mieć identyfikator:
  - `Wxx-T01`, `Wxx-T02`, ...
- Utrzymuj lekką nawigację w:
  - `docs/weekly/index.md`
- Przy starcie tygodnia definiuj:
  - **MVP tygodnia** (minimum do zaliczenia),
  - **stretch goals** (opcjonalne).
- Przy planowaniu D1–D5 pilnuj realizmu (1.5h / sesja).
- Przy domykaniu tygodnia porównuj wykonanie do DoD, a nie do „subiektywnego wrażenia”.
- Jeśli brakuje evidence, wskaż to wprost i zaproponuj brakujące kroki.
- Nie generuj kodu bez wyraźnej prośby użytkownika.
