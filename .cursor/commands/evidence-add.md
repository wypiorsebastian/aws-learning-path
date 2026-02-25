# /evidence-add

Dodaj dowód wykonania do `evidence.md` i powiąż go z taskiem.

## Input
- `TASK_ID`
- opis evidence (np. wynik komendy, log, screenshot path, URL, artefakt)
- opcjonalnie: co to potwierdza

## Zrób
1. Odczytaj `docs/weekly/Wxx/evidence.md`.
2. Dopisz wpis z polami:
   - Timestamp
   - TaskId
   - EvidenceType
   - Evidence
   - Potwierdza
3. Jeśli task nie ma uzupełnionego pola `Evidence`, zaktualizuj `tasks.md`.
4. W odpowiedzi podaj, czy evidence jest wystarczające do zamknięcia taska.
