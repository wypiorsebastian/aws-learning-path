## W02 — dziennik pracy

> Notuj tutaj krótkie wpisy z każdej sesji (czas, TaskId, co zostało zrobione / decyzje) dla tygodnia W02.

### Wzór wpisu
- `2026-03-xx hh:mm` — `W02-T0x` — krótki opis wykonanej pracy / decyzji.

---

### Wpisy

- `2026-02-25 00:40` — `W02-T01` — przygotowano notatkę `docs/lessons/W02-iam-users-roles-policies-trust.md` opisującą różnice między IAM user/role, identity/resource-based policy, trust policy oraz rolę STS i sesji tymczasowych w kontekście projektu.
- `2026-02-25` — `W02-T02` — utworzono `docs/runbooks/iam-role-matrix.md`: matryca ról (principal, trust, permission scope, usage) dla local developer, GitHub Actions (OIDC), ECS task role, Lambda execution role; dopisano uproszczenia dev-only, jak weryfikować i pułapki.
- `2026-02-25` — `W02-T03` — utworzono `docs/adr/ADR-0003-iam-role-strategy.md`: zasada OIDC-first i brak long-lived keys w CI/CD; uzasadnienie (rotacja, wyciek, blast radius), flow GitHub Actions → OIDC → STS → rola, zasady praktyczne i powiązanie z matrycą ról.

