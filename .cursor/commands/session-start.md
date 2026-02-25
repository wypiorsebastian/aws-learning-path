# /session-start

Rozpocznij sesję dzienną (1.5h) dla danego tygodnia.

## Input
- `WEEK_ID` (np. `W12`)
- `DAY_ID` (`D1`..`D5`)

## Zrób
1. Odczytaj:
   - `docs/weekly/{WEEK_ID}/plan.md`
   - `docs/weekly/{WEEK_ID}/tasks.md`
   - `docs/weekly/{WEEK_ID}/log.md`
2. Zaproponuj plan sesji:
   - 1 cel sesji
   - 2–3 taski max
   - timebox per task
   - verification
   - expected artifact output
3. Wskaż:
   - co jest najważniejsze dziś
   - czego dziś nie robić (aby nie rozproszyć uwagi)
4. Dopisz wpis startowy do `log.md`.

## Ważne
- Plan ma być realistyczny na 1.5h.
- Priorytet: utrzymanie kontroli nad tygodniem.
