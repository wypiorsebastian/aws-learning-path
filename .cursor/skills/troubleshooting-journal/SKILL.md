---
name: troubleshooting-journal
description: Formalizuje problemy techniczne do notatek troubleshootingowych (objaw, hipotezy, diagnostyka, root cause, fix, prevention). Użyj przy błędach AWS/Terraform/.NET/deploy/networking/IAM.
---

# Troubleshooting Journal

Skill do zapisywania i porządkowania problemów technicznych tak, aby budować bazę wiedzy z realnych błędów.

## When to Use

- Gdy pojawia się błąd podczas deployu, plan/apply, uruchamiania aplikacji lub konfiguracji AWS.
- Gdy task jest zablokowany (`BLOCKED`).
- Gdy chcesz zachować ślad myślenia diagnostycznego i lessons learned.
- Gdy problem może wrócić w kolejnych tygodniach.

## Instructions

- Najpierw zbierz fakty:
  - objaw,
  - kontekst,
  - co dokładnie robiłeś,
  - co jest wynikiem obserwowalnym.
- Oddziel hipotezy od faktów.
- Utwórz plik w `docs/troubleshooting/` z identyfikatorem:
  - `TRB-Wxx-NNN-<slug>.md`
- Użyj struktury:
  - Objaw
  - Kontekst
  - Hipotezy
  - Kroki diagnostyczne
  - Wyniki testów
  - Root cause (jeśli potwierdzony)
  - Fix
  - Jak poznam, że działa
  - Jak zapobiec
- Jeśli root cause nie jest jeszcze znany, zaznacz status `w toku`.
- Dodaj referencje do tygodnia i taska w `docs/weekly/Wxx/log.md`.
- Wpis powinien pomagać odtworzyć tok diagnozy po tygodniach/miesiącach.
- Nie generuj kodu naprawczego bez wyraźnej prośby.
