# /adr-new

Utwórz ADR dla decyzji architektonicznej / operacyjnej w projekcie szkoleniowym.

## Input
- tytuł decyzji
- kontekst (1–3 zdania)
- opcjonalnie: `WEEK_ID` i `TASK_ID`

## Zrób
1. Nadaj kolejny numer ADR (`ADR-000x`).
2. Utwórz plik w `docs/adr/ADR-000x-<slug>.md`.
3. Użyj szablonu ADR projektu szkoleniowego:
   - Status
   - Kontekst
   - Problem
   - Opcje
   - Decyzja
   - Konsekwencje
   - Wpływ na kolejne tygodnie
   - Weryfikacja / rollback (jeśli dotyczy)
4. Jeśli podano `WEEK_ID/TASK_ID`, dodaj referencję w `log.md` i `tasks.md`.

## Ważne
- To ma być techniczny ADR, nie ogólnik.
- Opisz kompromisy i dlaczego decyzja jest sensowna „teraz”.
