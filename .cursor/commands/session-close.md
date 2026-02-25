# /session-close

Zamknij sesję dzienną i zapisz stan roboczy.

## Input
- `WEEK_ID`
- `DAY_ID`

## Zrób
1. Odczytaj `tasks.md` i `log.md` dla tygodnia.
2. Zapisz krótkie podsumowanie sesji w `log.md`:
   - co zrobiono
   - co nie weszło
   - blokery
   - decyzje
3. Wskaż `Next step (1)` na następną sesję (mały, konkretny krok startowy).
4. Jeśli odkryto temat do nauki:
   - dopisz do `questions.md`.
5. Zwróć krótkie podsumowanie sesji.
