# ADR-0003 — Strategia ról IAM i zasada OIDC-first (brak long-lived keys w CI/CD)

- **Status:** Accepted  
- **Data:** 2026-02-25  
- **Kontekst:** W02 — IAM fundamentals; projekt OrderFlow AWS Lab z CI/CD w GitHub Actions i hostingiem w ECS/Lambda. Źródło prawdy dla ról: `docs/runbooks/iam-role-matrix.md`.

---

## 1. Kontekst

- Projekt używa GitHub Actions do Terraform (plan na PR, apply na main) oraz w przyszłości do build/deploy aplikacji .NET.
- Aby pipeline mógł operować na AWS (Terraform state, tworzenie zasobów), potrzebuje **poświadczeń AWS**.
- Dwa główne podejścia:
  - **Long-lived credentials:** IAM user z access key + secret w repo secrets — prosty w setupie, ale obciążony ryzykami.
  - **OIDC + assume role:** GitHub wystawia krótkotrwały token OIDC, AWS STS na jego podstawie wydaje tymczasowe poświadczenia roli — bez kluczy w secrets.
- ADR-0001 już zadeklarował: „CI/CD: GitHub Actions z OIDC do AWS (bez statycznych kluczy)”. Ten ADR formalizuje **dlaczego** i **jak** to realizujemy oraz zasady operacyjne.

---

## 2. Problem: dlaczego long-lived keys w CI/CD są problemem

- **Rotacja:** Klucze trzeba regularnie wymieniać; w praktyce często się tego nie robi, więc żyją latami.
- **Wyciek:** Klucz w repo secrets, w logach workflowu, w forkach lub przy copy-paste może trafić do niepowołanych; jeden wyciek = pełny dostęp do wszystkiego, na co pozwala policy, aż do ręcznej rewokacji.
- **Blast radius:** Jeden skompromitowany klucz daje dostęp do całego zakresu uprawnień usera (np. całe konto dev). Nie da się ograniczyć „tylko do tego workflowu” ani „tylko na 15 minut”.
- **Audit:** Trudniej powiązać konkretną operację z konkretnym runem (user jest współdzielony); przy OIDC każda sesja ma kontekst (repo, branch, job).

Dlatego w tym projekcie **nie używamy long-lived access keys dla CI/CD**.

---

## 3. Decyzja: OIDC-first, tylko tymczasowe sesje dla pipeline’u

### 3.1 Podejście

- Wszystkie workflowy GitHub Actions, które potrzebują dostępu do AWS, **używają OIDC do assume roli IAM**.
- Żadne **access key / secret access key** IAM usera nie są przechowywane w GitHub Secrets ani w żadnym innym miejscu związanym z pipeline’em.
- Pipeline uzyskuje dostęp w następujący sposób:
  1. **GitHub Actions** w trakcie joba requestuje token OIDC od GitHuba (endpoint `oidc.token`).
  2. **AWS STS** `AssumeRoleWithWebIdentity`: workflow przekazuje ten token do AWS; AWS weryfikuje go względem IAM OIDC Identity Provider (dla `token.actions.githubusercontent.com`).
  3. **Trust policy roli CI/CD** określa, które żądania są akceptowane (np. tylko repo `owner/repo-name`, opcjonalnie branch `ref:refs/heads/main`).
  4. Po weryfikacji **STS wydaje tymczasowe poświadczenia** (AccessKeyId, SecretAccessKey, SessionToken) z krótkim TTL (np. 1h).
  5. Workflow używa tych poświadczeń do wywołań AWS (np. `terraform plan` / `apply`); po zakończeniu joba credentials wygasają.

### 3.2 Korzyści

- Brak sekretów długoterminowych w repo; w razie wycieku tokena OIDC ma on krótki czas życia i ograniczony kontekst.
- Możliwość zawężenia trust policy do konkretnego repo (i branch), co ogranicza blast radius.
- Zgodność z dobrymi praktykami AWS i GitHub (OIDC dla Actions) oraz z matrycą ról (W02-T02).

---

## 4. Zasady praktyczne (na poziomie projektu)

- **Nie tworzymy IAM userów ani access keys „dla CI/CD”.** Pipeline nie loguje się jako żaden IAM user z long-lived keys.
- **Wszystkie workflowy wymagające dostępu do AWS** używają kroku assume-role przez OIDC (np. `aws-actions/configure-aws-credentials@v4` z `role-to-assume` i `web-identity-token`).
- **Trust policy roli dla GitHub Actions** zawężamy co najmniej do konkretnego repozytorium; zalecane zawężenie do branchy (np. `main`, `develop`) lub środowisk (environments), żeby uniknąć assume roli z forków lub dowolnego brancha.
- **Permission scope roli CI/CD** utrzymujemy w duchu least privilege: tylko to, co potrzebne do Terraform (S3 state, DynamoDB lock, zarządzanie zasobami w dev). Szczegóły w `docs/runbooks/iam-role-matrix.md`.

---

## 5. Powiązanie z matrycą ról

- W matrycy ról (`docs/runbooks/iam-role-matrix.md`) wiersz **GitHub Actions (CI/CD)** opisuje:
  - **Trust:** OIDC, tylko token z GitHub Actions dla konkretnego repo (i opcjonalnie branch).
  - **Permission scope:** least privilege pod Terraform (S3, DynamoDB, operacje na zasobach w dev).
  - **Usage:** workflowy `terraform plan` na PR, `terraform apply` na main; żadnych long-lived keys w secrets.
- Ta zasada jest spójna z pozostałymi wierszami matrycy: local developer może używać IAM usera (lub w przyszłości SSO), ECS/Lambda używają ról serwisowych — tylko CI/CD jest explicite „OIDC-only, zero long-lived keys”.

---

## 6. Konsekwencje

- W W08 (GitHub Actions + OIDC do AWS) implementujemy OIDC provider w AWS i rolę z trust policy; workflowy używają wyłącznie assume-role przez OIDC.
- W dokumentacji i runbookach odwołujemy się do tej zasady przy każdym temacie „jak pipeline łączy się z AWS”.
- W razie potrzeby dodania innego CI (np. inny provider) — preferujemy mechanizm federacji/OIDC zamiast wpisywania access keys do secrets.
