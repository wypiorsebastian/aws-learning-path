# W02 — lekcja: IAM fundamentals i matryca ról

## Cel tygodnia
- Zrozumieć model uprawnień AWS (users, roles, policies, trust) i zaprojektować matrycę ról dla projektu (least privilege, OIDC-first).

## Co zrobiłem
- Notatka IAM: user vs role, identity-based vs resource-based policy, trust policy, STS i sesje tymczasowe.
- Matryca ról w runbooku: local developer, GitHub Actions (OIDC), ECS task role, Lambda execution role (principal, trust, permission scope, usage).
- ADR-0003: zasada „brak long-lived keys w CI/CD”, flow OIDC → STS, zasady praktyczne.

## Co działa
- Wyjaśnienie user/role/policy/trust i projekt ról gotowy do użycia w Terraform i W08 (OIDC). Matryca = źródło prawdy dla ról.

## Wnioski
- Trust policy (kto może wejść w rolę) vs permission policy (co rola może zrobić) — rozdzielenie kluczowe przy OIDC i ECS/Lambda.
- CI/CD tylko przez OIDC (bez access keys w secrets); szczegóły w ADR-0003 i runbooku.

## Evidence
- `docs/lessons/W02-iam-users-roles-policies-trust.md`, `docs/runbooks/iam-role-matrix.md`, `docs/adr/ADR-0003-iam-role-strategy.md`.
