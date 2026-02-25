# /troubleshoot-capture

Utwórz uporządkowaną notatkę troubleshootingową na podstawie problemu.

## Input
- `WEEK_ID`
- opcjonalnie `TASK_ID`
- opis problemu / objawu

## Zrób
1. Nadaj identyfikator wpisu: `TRB-{WEEK_ID}-NNN-<slug>`
2. Utwórz plik w:
   - `docs/troubleshooting/`
3. Wypełnij strukturę:
   - Objaw
   - Kontekst
   - Hipotezy
   - Kroki diagnostyczne
   - Wyniki testów
   - Root cause
   - Fix
   - Jak poznam, że działa
   - Jak zapobiec
4. Dodaj link/odniesienie do tego wpisu w `docs/weekly/{WEEK_ID}/log.md`.
5. Jeśli powiązano `TASK_ID`, dopisz referencję w `tasks.md`.

## Ważne
- Nie udawaj root cause, jeśli jeszcze nie jest znany.
- Rozdzielaj fakty od hipotez.
