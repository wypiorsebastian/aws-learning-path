---
name: evidence-and-dod-auditor
description: Sprawdza zgodność wykonanych tasków i evidence z DoD tygodnia oraz wskazuje luki przed domknięciem pracy. Użyj przed /week-finish albo po większym tasku.
---

# Evidence and DoD Auditor

Skill do kontroli jakości postępu tygodnia względem roadmapy i artefaktów.

## When to Use

- Przed `/week-finish`.
- Po ukończeniu kluczowego taska `P1`.
- Gdy nie masz pewności, czy tydzień jest realnie domknięty.
- Gdy chcesz szybko zobaczyć luki w evidence i verification.

## Instructions

- Odczytaj sekcję tygodnia `Wxx` w roadmapie.
- Odczytaj pliki tygodnia:
  - `tasks.md`
  - `evidence.md`
  - `summary.md` (jeśli istnieje)
- Porównaj:
  - DoD vs status tasków
  - Evidence oczekiwane vs evidence dostępne
  - Outcome tygodnia vs rzeczywiste artefakty
- Wygeneruj raport:
  - spełnione
  - niespełnione
  - częściowo spełnione
  - brakujące dowody
  - ryzyka domknięcia tygodnia
- Jeśli braki są małe, zaproponuj krótką checklistę domykającą (30–60 min).
- Nie generuj kodu; skup się na ocenie, dokumentacji i planie domknięcia.
