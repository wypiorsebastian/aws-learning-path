# /task-note

Dodaj notatkę roboczą do taska (obserwacja, decyzja, komenda, wynik, problem).

## Input
- `TASK_ID`
- treść notatki

## Zrób
1. Dopisz wpis do `docs/weekly/Wxx/log.md` z timestampem i `TASK_ID`.
2. Jeśli notatka wygląda na problem techniczny / diagnostyczny:
   - zaproponuj użycie `/troubleshoot-capture`.
3. Jeśli notatka zawiera decyzję architektoniczną:
   - zaproponuj `/adr-new`.

## Format wpisu
- Timestamp
- TaskId
- Typ wpisu (`NOTE` / `DECISION` / `OBSERVATION` / `CMD_RESULT`)
- Treść
