## W02 — podsumowanie tygodnia

#### Cel tygodnia
- Zrozumieć model uprawnień AWS (IAM users, roles, policies, trust, STS) i przygotować matrycę ról dla projektu (dev, CI/CD, workloady), zgodnie z zasadą least privilege i OIDC-first.

#### Co zrobiłem
- **W02-T01 (DONE)** — Notatka IAM: `docs/lessons/W02-iam-users-roles-policies-trust.md` — różnice user/role, identity-based vs resource-based policy, trust policy, STS i sesje tymczasowe, scenariusze (local dev, GitHub Actions, ECS/Lambda), pułapki.
- **W02-T02 (DONE)** — Matryca ról: `docs/runbooks/iam-role-matrix.md` — tabela principal, trust, permission scope, usage dla local developer, GitHub Actions (OIDC), ECS task role, Lambda execution role; uproszczenia dev-only, jak sprawdzić, pułapki.
- **W02-T03 (DONE)** — Zasada OIDC-first: `docs/adr/ADR-0003-iam-role-strategy.md` — brak long-lived keys w CI/CD, uzasadnienie (rotacja, wyciek, blast radius), flow GitHub → OIDC → STS → rola, zasady praktyczne, powiązanie z matrycą.
- **W02-T04 (P2)** — Minimalne przykłady policy (S3 read-only, SQS producer): w tym cyklu **nie zrealizowane**; można uzupełnić później w runbooku (sekcja z JSON policies).

#### Co działa
- Notatka IAM pozwala wyjaśnić własnymi słowami user/role/policy/trust i STS.
- Matryca ról jest źródłem prawdy: widać, która rola dla kogo, jaki trust i scope; można się na nią powołać przy Terraform i W08 (OIDC).
- ADR-0003 formalizuje zasadę „zero long-lived keys w CI/CD” — pipeline będzie realizowany w W08 przez OIDC.

#### Co nie działało / problemy
- Brak istotnych problemów technicznych. Świadoma decyzja: trust policy vs permission policy opisane w notatce i matrycy, żeby uniknąć typowej pomyłki.

#### Co nie dowiezione
- **docs/lessons/W02-summary.md** — uzupełniony poniżej (krótka lekcja tygodnia), aby zamknąć evidence z roadmapy.
- **Przykładowe policy snippets (S3 read-only, SQS producer)** — brak w repo (task W02-T04 P2 nie wykonany); można dodać w kolejnym kroku do `iam-role-matrix.md` lub osobnej notatki.

#### Ocena DoD
- **Spełnione.** Uczestnik potrafi wyjaśnić user/role/policy/trust (notatka + matryca) i zaprojektował role projektu (matryca + ADR). Verification z roadmapy: `iam-role-matrix.md` zawiera principal, trust, permission scope, usage — tak; ADR opisuje strategię least privilege i OIDC-first — tak.

#### Root cause / opóźnienia
- Brak. Tydzień zrealizowany w założonym zakresie (T01–T03). T04 (P2) celowo pominięty w tym domknięciu.

#### Lessons learned
- Rozdzielenie trust policy (kto może wejść w rolę) od permission policy (co rola może zrobić) usuwa confusion przy projektowaniu ról i przy W08 (OIDC).
- Matryca w jednym miejscu (runbook) ułatwia późniejsze przypinanie policies do konkretnych ról w Terraform.

#### Next actions
- W08: implementacja OIDC + rola dla GitHub Actions (trust policy z matrycy, permission scope pod Terraform).
- Opcjonalnie: uzupełnić W02-T04 (policy snippets S3/SQS) w runbooku przy pierwszym użyciu ról ECS/Lambda.

#### Portfolio bullets (1–3)
- Zaprojektowana matryca ról IAM dla projektu (local dev, CI/CD OIDC, ECS, Lambda) z trust i permission scope oraz runbookiem i ADR.
- Sformułowana i udokumentowana zasada OIDC-first (brak long-lived keys w CI/CD) z uzasadnieniem i flow GitHub → STS.
- Udokumentowane podstawy IAM (user/role/policy/trust, STS) w formie notatki pod dalsze tygodnie (Terraform, W08).

#### Evidence (odniesienia)
- `docs/weekly/W02/evidence.md` — zebrane dowody.
- `docs/lessons/W02-iam-users-roles-policies-trust.md` — notatka IAM.
- `docs/runbooks/iam-role-matrix.md` — matryca ról.
- `docs/adr/ADR-0003-iam-role-strategy.md` — strategia OIDC-first.
- `docs/lessons/W02-summary.md` — lekcja tygodnia (poniżej).
