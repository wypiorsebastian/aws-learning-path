## W08 — taski tygodnia

### Kontekst

- **WeekId:** `W08`
- **Cel tygodnia:** Uruchomić pipeline IaC dla Terraform przez GitHub Actions + OIDC, bez statycznych kluczy AWS.
- **Outcome:** Pipeline Terraform działa przez OIDC (PR: `plan`, `main`/manual: `apply`), z zawężoną trust policy i minimalnymi uprawnieniami.
- **Uwaga:** Agent nie wykonuje operacji na infrastrukturze ani nie modyfikuje bezpośrednio ustawień IAM/CI — przygotowuje plan, dokumentację i strukturę plików; realne zmiany w AWS/GitHub wykonuje użytkownik.

---

## Taski bazowe z roadmapy

### W08-T01 — Utwórz OIDC provider i IAM role dla GitHub Actions

- **TaskId:** `W08-T01`
- **Status:** `TODO`
- **Priorytet:** `P1`
- **Typ:** `Security`
- **Cel:** Skonfigurować w AWS OIDC provider i IAM role dla GitHub Actions, z zawężoną trust policy i minimalnym zakresem uprawnień potrzebnym Terraformowi.
- **Estymata:** 60m
- **Input:**
  - Roadmapa — sekcja W08 (Metadane tygodnia, Zadania, Pułapki).
  - Konto AWS dev (ID konta, region, dotychczasowe zasady IAM).
  - Informacje o repozytorium GitHub (owner/repo, docelowa gałąź, strategia PR).
- **Kroki:**
  1. Zweryfikować, czy OIDC provider `token.actions.githubusercontent.com` już istnieje w koncie; jeśli tak, ocenić możliwość współdzielenia.
  2. Zaprojektować trust policy dla roli Terraform:
     - warunek na `aud` (GitHub),
     - warunek na `sub` (konkretne repo + gałąź/event),
     - ewentualne dodatkowe warunki bezpieczeństwa.
  3. Zaprojektować policy uprawnień dla roli:
     - dostęp do bucketu S3 z remote state (tylko wymagane operacje),
     - dostęp do zasobów zarządzanych przez aktualne moduły (network-core, network-endpoints itp.),
     - brak uprawnień wykraczających poza zakres Terraform dla dev.
  4. Utworzyć/uzupełnić w AWS:
     - OIDC provider,
     - rolę IAM z powyższą trust policy i policy uprawnień.
  5. Zanotować ARN roli i podstawowe parametry w dokumentacji (bez wrażliwych danych).
- **Verification:** Z poziomu AWS widać poprawnie skonfigurowanego providera i rolę; w testowym wywołaniu z GitHub Actions (lub narzędziem diagnostycznym) `AssumeRoleWithWebIdentity` kończy się sukcesem.
- **Evidence:** 
  - Fragment (zanonimizowanej) trust policy z warunkami `aud`/`sub`.
  - Opis lub screenshot zasobu IAM role i OIDC provider.
  - Link do testowego runu workflow, który pokazał udane uzyskanie tymczasowych poświadczeń.

---

### W08-T02 — Workflow `terraform plan` na PR

- **TaskId:** `W08-T02`
- **Status:** `TODO`
- **Priorytet:** `P1`
- **Typ:** `CI/CD`
- **Cel:** Przygotować workflow GitHub Actions, który dla PR z infrastrukturą wykonuje `terraform plan` z użyciem OIDC roli z W08-T01.
- **Estymata:** 30m
- **Input:**
  - W08-T01 ukończony (istnieje rola IAM i OIDC provider).
  - Struktura repo (`infra/terraform/envs/dev`, moduły z W06–W07).
  - Ustalenia z D1–D2 dotyczące docelowego przepływu i bezpieczeństwa.
- **Kroki:**
  1. Zdecydować, jakie typy PR uruchamiają workflow (np. zmiany w `infra/terraform/**` do `main`).
  2. Zaplanować konfigurację joba:
     - permissions: przyznanie `id-token` i `contents` dla joba,
     - pobranie kodu repo,
     - użycie OIDC do wywołania roli IAM z W08-T01.
  3. Zaplanować sekwencję kroków Terraform:
     - `terraform init` z backendem S3,
     - `terraform validate`,
     - `terraform plan` dla `envs/dev`.
  4. Zdecydować, jak publikować wynik planu (logi, artefakt, ewentualny komentarz na PR).
  5. Utworzyć plik workflow `.github/workflows/terraform-plan.yml` zgodnie z powyższym planem (implementacja po stronie użytkownika).
- **Verification:** Dla testowego PR workflow:
  - startuje automatycznie,
  - z powodzeniem uzyskuje tymczasowe poświadczenia przez OIDC,
  - wykonuje `terraform plan` bez błędów autoryzacji.
- **Evidence:**
  - Link do definiującego pliku workflow w repo.
  - Link/ID udanego runu z logami pokazującymi `plan`.

---

### W08-T03 — Workflow `terraform apply` na `main` (kontrolowany)

- **TaskId:** `W08-T03`
- **Status:** `TODO`
- **Priorytet:** `P1`
- **Typ:** `CI/CD`
- **Cel:** Przygotować bezpieczny workflow `terraform apply` dla dev, uruchamiany z `main` (lub manualnie), korzystający z OIDC.
- **Estymata:** 30m
- **Input:**
  - W08-T01, W08-T02 ukończone.
  - Polityka branch protection / environments w repo.
  - Ustalenia dotyczące częstotliwości i sposobu deployu dev.
- **Kroki:**
  1. Wybrać model wyzwalania:
     - automatycznie na merge do `main`, lub
     - manualnie (`workflow_dispatch`) z parametrami (np. `confirm=true`).
  2. Zaprojektować zabezpieczenia:
     - użycie tego samego OIDC flow i roli co w `plan`,
     - wymuszenie manualnego approvala (GitHub Environments lub inny mechanizm),
     - ograniczenie zakresu działania do dev (np. katalog `infra/terraform/envs/dev`).
  3. Zaplanować sekwencję kroków Terraform:
     - `terraform init`,
     - opcjonalny `terraform plan` jako sanity check,
     - `terraform apply` z wyraźnym oznaczeniem środowiska.
  4. Utworzyć plik workflow `.github/workflows/terraform-apply.yml` zgodnie z powyższym planem (implementacja po stronie użytkownika).
- **Verification:** Testowy run `apply`:
  - wymaga przewidzianego gate’a (merge/approval),
  - kończy się sukcesem, wykonując `terraform apply` przez OIDC,
  - nie korzysta z żadnych statycznych kluczy AWS ani sekretów z access key/secret.
- **Evidence:**
  - Link do pliku workflow w repo.
  - Link/ID udanego runu z logami pokazującymi `apply`.

---

### W08-T04 — Runbook pipeline IaC + troubleshooting OIDC

- **TaskId:** `W08-T04`
- **Status:** `TODO`
- **Priorytet:** `P2`
- **Typ:** `Docs`
- **Cel:** Udokumentować pipeline IaC (plan + apply) i typowe problemy z OIDC / IAM w formie runbooka operacyjnego.
- **Estymata:** 30m
- **Input:**
  - Wyniki W08-T01..T03 (działające workflowy, trust policy, logi).
  - Doświadczenia z W02 (IAM) i W06–W07 (Terraform).
  - Dokumentacja AWS IAM OIDC + GitHub Actions OIDC.
- **Kroki:**
  1. Opisać przeznaczenie pipeline’u: co dokładnie robi, dla jakiego środowiska, w jakich sytuacjach go używamy.
  2. Opisać operacyjny flow:
     - PR → `terraform plan`,
     - merge/main/manual → `terraform apply`.
  3. Opisać, jak rozpoznać, że pipeline działa poprawnie (jakie logi, jakie efekty w AWS).
  4. Wypisać typowe problemy i troubleshooting:
     - błędny `sub`/`aud`,
     - brak uprawnień do S3 / zasobów,
     - źle ustawione permissions workflowa.
  5. Dodać sekcję „Pułapki i dobre praktyki” (np. zawężanie trust policy, least privilege).
- **Verification:** Na podstawie samego runbooka da się:
  - wyjaśnić, jak działa pipeline,
  - przeprowadzić podstawową diagnostykę problemów z OIDC/permissions.
- **Evidence:**
  - Plik runbooka w `docs/runbooks/*` (nazwa zgodna z przyjętą konwencją, np. `terraform-pipeline-oidc.md`).
  - Odniesienia w `docs/weekly/W08/evidence.md`.

---

## Verification (zbiorczy checklist z roadmapy)

- [ ] Workflow assume-role przez OIDC działa (rola IAM z W08-T01 przyjmuje tożsamość z GitHub Actions).
- [ ] `terraform plan` w CI działa na PR (W08-T02).
- [ ] `terraform apply` działa na merge / manual dispatch (W08-T03), bez statycznych kluczy AWS.

## Evidence (zbiorczy z roadmapy)

- `docs/lessons/W08-summary.md`
- Logi workflow (linki/przykładowe runy dla `plan` i `apply`).
- Fragment trust policy (zanonimizowany) pokazujący zawężenie do repo/branch.

