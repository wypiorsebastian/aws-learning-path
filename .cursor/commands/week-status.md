# /week-status

Pokaż aktualny status tygodnia i DoD.

## Input
- `WEEK_ID` (np. `W08`)

## Zrób
1. Odczytaj:
   - `docs/weekly/{WEEK_ID}/tasks.md`
   - `docs/weekly/{WEEK_ID}/evidence.md`
   - `docs/weekly/{WEEK_ID}/log.md`
   - odpowiednią sekcję `WEEK_ID` w roadmapie
2. Zrób podsumowanie:
   - ile tasków `DONE / W_TRAKCIE / BLOCKED / TODO / SKIPPED`
   - status realizacji DoD (co spełnione, co nie)
   - brakujące evidence
   - aktywny task
   - blocker (jeśli jest)
3. Zasugeruj jeden konkretny `Next step (1)`.

## Format odpowiedzi
- Krótki dashboard + lista braków do domknięcia.
