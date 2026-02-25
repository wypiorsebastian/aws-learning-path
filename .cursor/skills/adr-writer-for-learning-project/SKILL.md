---
name: adr-writer-for-learning-project
description: Tworzy techniczne ADR-y dla projektu szkoleniowego AWS/.NET (decyzje architektoniczne, hosting, security, IaC, data, workflow). Użyj gdy pojawia się realny wybór z konsekwencjami.
---

# ADR Writer for Learning Project

Skill do zapisywania decyzji architektonicznych i operacyjnych w formie krótkich, ale technicznych ADR.

## When to Use

- Gdy wybierasz między usługami lub podejściami (np. App Runner vs ECS, RDS vs DynamoDB use-case, Secrets Manager vs SSM).
- Gdy decyzja wpływa na kolejne tygodnie roadmapy.
- Gdy chcesz zostawić ślad „dlaczego tak”, a nie tylko „co zostało zrobione”.
- Gdy użytkownik prosi o przygotowanie ADR.

## Instructions

- Numeruj ADR-y sekwencyjnie: `ADR-0001`, `ADR-0002`, ...
- Zapisuj w `docs/adr/ADR-XXXX-<slug>.md`
- ADR ma być:
  - konkretny,
  - osadzony w kontekście projektu,
  - opisujący kompromisy,
  - użyteczny na rozmowie technicznej.
- Użyj struktury:
  - Status
  - Kontekst
  - Problem / Decision Driver
  - Opcje
  - Decyzja
  - Konsekwencje
  - Wpływ na kolejne tygodnie
  - Weryfikacja / rollback (jeśli dotyczy)
- Jeśli decyzja została podjęta z powodów kosztowych (`dev-only`), zaznacz to wprost.
- Jeśli decyzja jest tymczasowa (na etap nauki), zaznacz „tymczasowy kompromis”.
- Nie generuj kodu bez wyraźnej prośby użytkownika.
