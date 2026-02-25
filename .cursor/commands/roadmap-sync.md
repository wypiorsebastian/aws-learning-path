# /roadmap-sync

Porównaj stan tygodniowych artefaktów z roadmapą i pokaż rozjazdy.

## Input
- `WEEK_ID` (opcjonalne; jeśli brak, użyj aktywnego tygodnia z `docs/weekly/index.md`)

## Zrób
1. Odczytaj roadmapę (`WEEK_ID`) i pliki tygodniowe.
2. Porównaj:
   - taski z roadmapy vs taski w `tasks.md`
   - DoD z roadmapy vs evidence / statusy
   - outcome/evidence expectations vs realne artefakty
3. Przygotuj raport:
   - zgodne
   - brakujące
   - dodatkowe (stretch)
   - ryzyka dla domknięcia tygodnia
4. Jeśli użytkownik poprosi, zaktualizuj `plan.md` i `tasks.md` (bez generowania kodu).

## Ważne
- Nie zmieniaj roadmapy bez wyraźnej potrzeby i jawnego opisu zmiany.
