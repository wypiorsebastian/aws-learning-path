# /week-finish

Domknij tydzień, porównaj wykonanie do DoD i przygotuj podsumowanie.

## Input
- `WEEK_ID` (np. `W08`)

## Zrób
1. Odczytaj pliki tygodnia (`tasks`, `log`, `evidence`, `summary`) i sekcję `WEEK_ID` w roadmapie.
2. Oceń DoD tygodnia:
   - spełnione / niespełnione / częściowo
3. Uzupełnij `docs/weekly/{WEEK_ID}/summary.md`:
   - co osiągnięto
   - co nie dowiezione
   - root cause problemów / opóźnień
   - lessons learned
   - next actions
   - portfolio bullets (1–3)
4. Zaktualizuj `docs/weekly/index.md`:
   - status tygodnia (`DONE` lub `PARTIAL`)
   - następny tydzień / następny krok
5. Jeśli są `BLOCKED` taski, wypisz je jawnie w podsumowaniu.
6. W odpowiedzi pokaż checklistę domknięcia tygodnia.

## Ważne
- Nie generuj kodu.
- Jeśli brakuje evidence, wskaż to wprost.
