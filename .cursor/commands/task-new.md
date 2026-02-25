# /task-new

Dodaj nowy task do tygodnia i nadaj mu identyfikator.

## Input
- `WEEK_ID` (np. `W08`)
- opis taska (1–3 zdania)
- opcjonalnie: `Priorytet` (`P1/P2/P3`)
- opcjonalnie: `Typ` (np. `Docs`, `Theory`, `IaC`, `Troubleshooting`)

## Zrób
1. Odczytaj `docs/weekly/{WEEK_ID}/tasks.md`.
2. Nadaj kolejny numer taska w formacie `{WEEK_ID}-Tnn`.
3. Dodaj wpis taska z polami:
   - TaskId
   - Status (`TODO`)
   - Priorytet
   - Typ
   - Cel
   - Estymata
   - Dependencies
   - Verification
   - Evidence
   - Notes
4. W odpowiedzi zwróć:
   - nowy `TaskId`
   - proponowaną estymatę
   - minimalne kryterium ukończenia.
