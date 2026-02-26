## W02 — taski tygodnia

### Kontekst
- **WeekId:** `W02`
- **Cel tygodnia:** Zrozumieć model uprawnień AWS (users, roles, policies, trust) i przygotować matrycę ról dla projektu.
- **Outcome:** Matryca ról IAM (dev, CI/CD, workloady) oraz spisane zasady użycia IAM w projekcie (w tym brak long-lived keys w CI/CD).

---

## Taski bazowe z roadmapy

### W02-T01 — Notatka: IAM users vs roles vs policies vs trust
- **TaskId:** `W02-T01`
- **Status:** `DONE`
- **Priorytet:** `P1`
- **Typ:** `Theory/Docs`
- **Cel:** Spisać klarowną notatkę, która wyjaśnia różnice między IAM user, IAM role, policies (identity/resource-based) oraz trust policy, z naciskiem na typowe use-case w projekcie.
- **Estymata:** 45m
- **Input:**
  - Sekcja `W02` w `docs/roadmap/aws-course-roadmap-operational-0-24.md`.
  - Dokumentacja AWS IAM (podstawowe pojęcia, STS, trust vs permission policy).
- **Kroki:**
  1. Przeczytać metadane tygodnia W02, w szczególności DoD i pułapki.
  2. Zebrać definicje: IAM user, IAM role, identity-based policy, resource-based policy, trust policy.
  3. Opisać, jak AWS ewaluje uprawnienia (principal → policies → efekt).
  4. Wypisać typowe scenariusze użycia user vs role, szczególnie dla dev i CI/CD.
  5. Dodać sekcję o STS i sesjach tymczasowych (wysoki poziom).
- **Verification:**
  - Po przeczytaniu notatki potrafisz własnymi słowami wyjaśnić różnicę user/role/policy/trust.
  - Umiesz wskazać, gdzie w projekcie będziesz używać users, a gdzie roles.
- **Evidence:**
  - Notatka (np. `docs/lessons/W02-iam-users-roles-policies-trust.md` lub sekcja w `docs/lessons/W02-summary.md`).
  - Wpis w `docs/weekly/W02/log.md` z numerem taska.

---

### W02-T02 — Matryca ról: local dev / GitHub Actions / ECS task / Lambda execution
- **TaskId:** `W02-T02`
- **Status:** `DONE`
- **Priorytet:** `P1`
- **Typ:** `Design/Docs`
- **Cel:** Zaprojektować matrycę ról IAM dla głównych person w projekcie (developer, CI/CD, workloady), z opisanym trust, permission scope i usage.
- **Estymata:** 45m
- **Input:**
  - Wyniki pracy z `W02-T01` (notatka o users/roles/policies/trust).
  - Roadmapa (sekcja W02, artefakt `docs/runbooks/iam-role-matrix.md`).
  - Założenia cost-guardrails i dev-only z W01.
- **Kroki:**
  1. Zdefiniować listę principal: local developer, GitHub Actions (OIDC), ECS task role, Lambda execution role.
  2. Dla każdej pozycji określić:
     - trust policy (kto może przyjąć rolę),
     - permission scope (jakie usługi / zasoby są potrzebne),
     - usage (w jakim kontekście rola będzie używana).
  3. Zapisać matrycę w formie tabeli w `docs/runbooks/iam-role-matrix.md` (lub szkicu, jeśli dokument nie istnieje).
  4. Zanotować wszelkie uproszczenia wynikające z tego, że środowisko jest dev-only.
- **Verification:**
  - Dla każdej persony potrafisz wskazać konkretną rolę IAM, jej trust i zasięg uprawnień.
  - Matryca pozwala szybko zobaczyć, **która rola** jest używana przez **który komponent** i **do czego**.
- **Evidence:**
  - Zaktualizowany `docs/runbooks/iam-role-matrix.md`.
  - Wpis w `docs/weekly/W02/log.md` z numerem taska.

---

### W02-T03 — Zasada: brak long-lived keys w CI/CD
- **TaskId:** `W02-T03`
- **Status:** `DONE`
- **Priorytet:** `P1`
- **Typ:** `Docs/Security`
- **Cel:** Spisać zasadę bezpieczeństwa, że CI/CD (GitHub Actions) nie używa long-lived access keys, tylko krótkie sesje (OIDC → STS), oraz co to oznacza operacyjnie dla projektu.
- **Estymata:** 30m
- **Input:**
  - Roadmapa (sekcja W02, odniesienie do OIDC-first).
  - Notatka z `W02-T01` o STS i sesjach.
- **Kroki:**
  1. Opisać, dlaczego long-lived keys w CI/CD są problemem (rotacja, wyciek, blast radius).
  2. Zmapować podejście OIDC-first: GitHub Actions → OIDC → rola IAM → tymczasowe poświadczenia.
  3. Zapisać zasady praktyczne (na poziomie projektu), np.:
     - nie tworzymy access keys dla użytkowników technicznych pod CI/CD,
     - wszystkie workflowy używają OIDC do assume role.
  4. Odnieść tę zasadę do matrycy ról z `W02-T02`.
- **Verification:**
  - Potrafisz wytłumaczyć, jak pipeline uzyska dostęp do AWS **bez** long-lived keys.
  - Zasada jest na tyle jasna, że możesz się na nią powołać w kolejnych tygodniach (Terraform, CI/CD).
- **Evidence:**
  - Krótki dokument/sekcja (np. w `ADR-0003-iam-role-strategy.md` lub osobnej notatce).
  - Wpis w `docs/weekly/W02/log.md` z numerem taska.

---

### W02-T04 — Minimalne przykłady policy (S3 read-only, SQS producer)
- **TaskId:** `W02-T04`
- **Status:** `TODO`
- **Priorytet:** `P2`
- **Typ:** `Security/Docs`
- **Cel:** Przygotować minimalne przykłady policies dla typowych ról: odczyt z S3 (read-only) oraz wysyłanie wiadomości do SQS (producer), tak aby móc je później zaadaptować w Terraform/konfiguracji ról.
- **Estymata:** 30m
- **Input:**
  - Dokumentacja AWS IAM dla S3 i SQS (przykładowe policies).
  - Matryca ról z `W02-T02`.
- **Kroki:**
  1. Zidentyfikować typowe uprawnienia dla:
     - S3 read-only (lista obiektów, odczyt, ewentualnie ograniczenie do prefiksu/bucketa),
     - SQS producer (wysłanie wiadomości, ewentualnie odczyt atrybutów kolejki).
  2. Na podstawie dokumentacji przygotować zwięzłe, least-privilege przykłady policies (wysoki poziom, bez twardych ARN jeśli jeszcze nie istnieją zasoby).
  3. Zaznaczyć, do których ról z matrycy potencjalnie będą przypięte te policies.
  4. Zanotować, jak sprawdzisz poprawność tych policies w przyszłości (np. przez testowe wywołania CLI / aplikacji).
- **Verification:**
  - Masz dwa przykładowe policies, które można łatwo przenieść do Terraform lub konsoli IAM.
  - Rozumiesz, jakie dokładnie uprawnienia daje każda z policies.
- **Evidence:**
  - Fragmenty policies (np. w `docs/runbooks/iam-role-matrix.md`, `ADR-0003-iam-role-strategy.md` lub osobnej notatce).
  - Wpis w `docs/weekly/W02/log.md` z numerem taska.

