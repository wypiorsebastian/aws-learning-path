# /task-done

Zamknij task i dopilnuj verification + evidence.

## Input
- `TASK_ID`

## Zrób
1. Odczytaj wpis taska w `tasks.md`.
2. Sprawdź czy pola `Verification` i `Evidence` są uzupełnione.
3. Jeśli nie:
   - poproś o brakujące informacje lub wstaw placeholders do uzupełnienia.
4. Ustaw status taska na `DONE`.
5. Dopisz wpis końcowy do `log.md` (timestamp + wynik).
6. Zasugeruj następny task do uruchomienia.

## Format odpowiedzi
- co zostało ukończone
- czy verification/evidence są kompletne
- następny krok
