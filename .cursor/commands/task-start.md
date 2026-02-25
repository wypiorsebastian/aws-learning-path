# /task-start

Rozpocznij pracę nad taskiem i przygotuj mini-plan wykonania.

## Input
- `TASK_ID` (np. `W08-T03`)

## Zrób
1. Znajdź tydzień na podstawie `TASK_ID` i odczytaj:
   - `docs/weekly/Wxx/tasks.md`
   - `docs/weekly/Wxx/log.md`
   - `docs/weekly/Wxx/plan.md`
2. Ustaw status taska na `W_TRAKCIE`.
3. Dopisz wpis do `log.md` (start taska, timestamp).
4. Wygeneruj mini-plan:
   - cel taska
   - kroki (3–7)
   - verification
   - evidence do zebrania
   - ryzyka / typowe pułapki
5. W odpowiedzi pokaż mini-plan i `Next step (1)`.

## Ważne
- Nie generuj kodu bez wyraźnej prośby użytkownika.
