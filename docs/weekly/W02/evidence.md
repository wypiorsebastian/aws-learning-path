## W02 — evidence

> Zbieraj tu konkretne dowody wykonania pracy z tygodnia W02 (IAM fundamentals, matryca ról, zasady bezpieczeństwa).

### Przykładowe elementy evidence
- Fragmenty / zrzuty:
  - struktury notatki `W02-T01` (users, roles, policies, trust policy, STS),
  - fragment matrycy ról z `docs/runbooks/iam-role-matrix.md` (principal, trust, permission scope, usage),
  - opis zasady „brak long-lived keys w CI/CD” (odniesienie do OIDC → STS → rola IAM),
  - przykładowe snippets policies dla:
    - S3 read-only,
    - SQS producer.
- Linki/referencje do kluczowych plików:
  - `docs/runbooks/iam-role-matrix.md`,
  - `ADR-0003-iam-role-strategy.md` (gdy powstanie),
  - `docs/lessons/W02-summary.md`.

---

### Zebrane evidence

- Notatka IAM fundamentals (W02-T01):
  - `docs/lessons/W02-iam-users-roles-policies-trust.md` — opis IAM user vs role, identity/resource-based policies, trust policy oraz STS i sesje tymczasowe, z odniesieniem do local dev, CI/CD (GitHub Actions) i workloadów (ECS/Lambda).

