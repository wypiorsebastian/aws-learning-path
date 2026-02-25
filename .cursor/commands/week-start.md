# /week-start

Uruchom start tygodnia nauki dla wskazanego `Wxx` na podstawie roadmapy.

## Input
- `WEEK_ID` (np. `W03`)

## Zrób
1. Odczytaj sekcję `WEEK_ID` z pliku:
   - `docs/roadmap/aws-course-roadmap-operational-0-24.md`
2. Wyciągnij:
   - cel tygodnia,
   - WhyNow,
   - DoD,
   - Evidence,
   - listę zadań bazowych.
3. Utwórz folder:
   - `docs/weekly/{WEEK_ID}/`
4. Utwórz (jeśli nie istnieją) pliki:
   - `plan.md`
   - `tasks.md`
   - `log.md`
   - `evidence.md`
   - `questions.md`
   - `summary.md`
5. Wygeneruj szczegółowy plan D1–D5 (1.5h każda sesja) w `plan.md`.
6. Rozbij zadania z roadmapy na taski z ID `WEEK_ID-T01..` i zapisz w `tasks.md`.
7. Ustaw status tygodnia jako `W_TRAKCIE` w `docs/weekly/index.md`.
8. W odpowiedzi opisz:
   - co jest celem tygodnia,
   - co jest MVP tygodnia,
   - jaka jest pierwsza rzecz do zrobienia teraz.

## Ważne
- Nie generuj kodu.
- Skup się na dokumentacji, planie i statusach.
