## W02 — podsumowanie tygodnia

#### Cel tygodnia
- Zrozumieć model uprawnień AWS (IAM users, roles, policies, trust, STS) i przygotować matrycę ról dla projektu (dev, CI/CD, workloady), zgodnie z zasadą least privilege i OIDC-first.

#### Co zrobiłem
- _do uzupełnienia po zakończeniu tygodnia W02; opisz tutaj zrealizowane taski `W02-T01..T04` i główne decyzje._

#### Co działa
- _podsumuj, co realnie działa po W02 (np. matryca ról, zrozumienie trust vs permission policy, zasada braku long-lived keys)._

#### Co nie działało / problemy
- _zapisz napotkane problemy (np. niejasności w dokumentacji IAM, trudności z modelowaniem ról) i jak je rozwiązałeś albo co wymaga dalszego researchu._

#### Smoke tests (W02)
- [ ] Potrafię własnymi słowami wyjaśnić:
  - różnicę między IAM user a IAM role,
  - różnicę między trust policy a permission policy,
  - jak STS wydaje tymczasowe poświadczenia dla roli.
- [ ] Potrafię wskazać w matrycy ról:
  - rolę dla local dev,
  - rolę dla GitHub Actions (OIDC),
  - rolę dla przykładowego workloadu (ECS/Lambda).
- [ ] Potrafię wskazać, gdzie w projekcie będzie użyta zasada „brak long-lived keys w CI/CD”.

#### Evidence (odniesienia)
- _wypisz tutaj najważniejsze artefakty/evidence z tygodnia W02, np.:_
- `docs/weekly/W02/evidence.md` — zebrane dowody (notatki, matryca ról, policy snippets).
- `docs/runbooks/iam-role-matrix.md` — matryca ról IAM dla projektu.
- `ADR-0003-iam-role-strategy.md` — strategia ról IAM (gdy powstanie).
- `docs/lessons/W02-summary.md` — lekcje wyniesione z tygodnia W02.

