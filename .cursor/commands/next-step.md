# /next-step

Pomóż odzyskać kontekst i wskaż jeden konkretny krok startowy.

## Input
- opcjonalnie `WEEK_ID` lub `TASK_ID`

## Zrób
1. Jeśli brak inputu:
   - odczytaj `docs/weekly/index.md` i znajdź aktywny tydzień / aktywny task.
2. Odczytaj:
   - `plan.md`
   - `tasks.md`
   - `log.md`
3. Zwróć:
   - krótki status (gdzie jesteśmy)
   - `Next step (1)` na 15–30 min
   - `Po tym kroku zrób...` (drugi krok opcjonalnie)
4. Jeśli jest blocker, nie ignoruj go — zaproponuj działanie diagnostyczne.

## Ważne
- Odpowiedź ma redukować przeciążenie i dawać jasny start.
