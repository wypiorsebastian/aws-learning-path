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
  - `docs/adr/ADR-0003-iam-role-strategy.md`,
  - `docs/lessons/W02-summary.md`.

---

### Zebrane evidence

- Notatka IAM fundamentals (W02-T01):
  - `docs/lessons/W02-iam-users-roles-policies-trust.md` — opis IAM user vs role, identity/resource-based policies, trust policy oraz STS i sesje tymczasowe, z odniesieniem do local dev, CI/CD (GitHub Actions) i workloadów (ECS/Lambda).
- Matryca ról (W02-T02):
  - `docs/runbooks/iam-role-matrix.md` — tabela ról: local developer, GitHub Actions (OIDC), ECS task role, Lambda execution role (principal, trust, permission scope, usage); sekcje: uproszczenia dev-only, jak sprawdzić, pułapki.
- Zasada brak long-lived keys w CI/CD (W02-T03):
  - `docs/adr/ADR-0003-iam-role-strategy.md` — strategia ról IAM, OIDC-first: uzasadnienie (rotacja, wyciek, blast radius), flow GitHub Actions → OIDC → STS → rola, zasady praktyczne (brak access keys dla CI/CD, wszystkie workflowy przez OIDC), powiązanie z `iam-role-matrix.md`.
- Lekcja tygodnia (evidence roadmapy):
  - `docs/lessons/W02-summary.md` — krótkie podsumowanie W02 (cel, co zrobiono, wnioski, evidence).

