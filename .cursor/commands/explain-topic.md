# /explain-topic

Wyjaśnij temat techniczny w trybie mentora / wykładowcy, bez skrótów myślowych.

## Input
- temat (np. `IAM trust policy vs permissions policy`)
- opcjonalnie: `WEEK_ID` i `TASK_ID` (dla kontekstu)

## Zrób
1. Jeśli podano `WEEK_ID/TASK_ID`, najpierw odczytaj kontekst z plików tygodnia.
2. Wyjaśnij temat w formacie:
   - problem, który ten mechanizm rozwiązuje
   - model mentalny
   - jak to działa pod maską (krok po kroku)
   - jak poznać, że działa (operacyjnie)
   - typowe błędy / antywzorce
   - gdzie to występuje w naszym projekcie
3. Jeśli temat wiąże się z bieżącym tygodniem, wskaż konkretny wpływ na taski.

## Ważne
- Odpowiedź po polsku.
- Bez „skrótów myślowych” i bez analogii, jeśli nie są potrzebne.
