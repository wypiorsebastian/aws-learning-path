# W08 — plan tygodnia

## Cel tygodnia (z roadmapy)

Uruchomić pipeline IaC dla Terraform tak, aby GitHub Actions korzystał z OIDC i **nie wymagał statycznych kluczy AWS**.

## WhyNow

- Po W07 mamy ręcznie zweryfikowaną infrastrukturę sieciową (network-core + network-endpoints) w dev.
- Kolejne deploymenty powinny być **powtarzalne i wykonywane z CI/CD**, a nie lokalnie z laptopa.
- To dobry moment, żeby zabetonować wzorzec: **GitHub Actions → OIDC → IAM role → Terraform**, zamiast access key/secret.

## DoD

- PR z infrastrukturą Terraform uruchamia workflow, który wykonuje `terraform plan` przez OIDC.
- Merge (lub świadomie uruchomiony workflow) wykonuje `terraform apply` przez OIDC, bez statycznych kluczy.
- Trust policy IAM jest zawężona do konkretnego repo/branch i podstawowych warunków bezpieczeństwa.

## MVP tygodnia

Minimalne zaliczenie tygodnia to:

- Skonfigurowany OIDC provider i IAM role dla GitHub Actions w koncie AWS dev.
- Działający workflow `plan` na PR, który:
  - uzyskuje tymczasowe poświadczenia przez OIDC,
  - wykonuje `terraform init/validate/plan` na stacku `envs/dev`,
  - **nie** używa żadnych statycznych kluczy AWS.
- Działający workflow `apply` na `main` (lub przez manualne wywołanie), korzystający z tej samej roli.

Stretch (opcjonalne) na ten tydzień:

- Uporządkowany runbook z troubleshootingiem OIDC (typowe błędy w trust policy / `sub` / permissions).
- Drobne usprawnienia bezpieczeństwa (np. zawężenie ról/permissions do minimalnego zakresu).

---

## Plan D1–D5 (po 1.5h każda sesja)

### D1 (1.5h) — Rozkminienie modelu OIDC + wymagania

**Cel:** Zrozumieć dokładnie, jak wygląda przepływ GitHub Actions → OIDC → AWS STS → Terraform i jakie są wymagania na trust policy oraz permissions.

- [ ] Przeczytać sekcję W08 w roadmapie (`aws-course-roadmap-operational-0-24.md`) i notatki z W02/W07 nt. IAM.
- [ ] Zidentyfikować docelowe repo/branch (`owner/repo`, `refs/heads/main`, ewentualnie patterns dla PR).
- [ ] Spisać docelowy kształt trust policy:
  - jakiego `aud` oczekujemy,
  - jakie `sub` (repo + branch / event),
  - jakie dodatkowe warunki (np. `token.actions.githubusercontent.com:sub`).
- [ ] Spisać minimalny zakres uprawnień dla roli Terraform (S3 backend, VPC/network, ewentualnie inne moduły).
- [ ] Zanotować pytania/niejasności w `docs/weekly/W08/questions.md`.
- **Input:** Roadmapa W08, aktualny stan infra (W06–W07), dokumentacja AWS IAM OIDC + GitHub Actions OIDC.
- **Output:** Krótka notatka / szkic trust policy i uprawnień roli.
- **Weryfikacja:** Model przepływu jest jasny „na papierze”; wiadomo, jakie warunki będą w trust policy i jakie policy będzie dołączone.

---

### D2 (1.5h) — OIDC provider + IAM role dla GitHub Actions (W08-T01)

**Cel:** Skonfigurować w AWS OIDC provider i IAM role dla GitHub Actions (zawężona trust policy, least privilege).

- [ ] Sprawdzić, czy w koncie AWS dev istnieje już OIDC provider dla GitHub (`token.actions.githubusercontent.com`); jeśli tak, zweryfikować, czy można go współdzielić.
- [ ] Zaprojektować i zapisać trust policy dla roli Terraform:
  - warunek na `aud`,
  - warunek na `sub` dla konkretnego repo (i ewentualnie brancha lub środowiska),
  - inne warunki zgodnie z best practices.
- [ ] Zaprojektować i zapisać policy uprawnień:
  - dostęp do bucketu S3 z remote state (tylko wymagane operacje),
  - dostęp do zasobów wymaganych przez aktualne moduły (network-core, network-endpoints),
  - brak nadmiarowych uprawnień administracyjnych.
- [ ] Wykonać w konsoli/CLI: utworzenie/aktualizację OIDC provider i roli (operacja po stronie użytkownika, nie agenta).
- **Input:** Wyniki z D1, konto AWS dev, design z roadmapy.
- **Output:** OIDC provider i IAM role skonfigurowane w AWS; trust policy i policy zapisane jako fragmenty do cytowania (bez sekretów).
- **Weryfikacja:** Z poziomu AWS widać poprawnie utworzonego providera i rolę; trust policy zawiera oczekiwane warunki `aud`/`sub`.

---

### D3 (1.5h) — Workflow `terraform plan` na PR (W08-T02)

**Cel:** Przygotować workflow CI, który na każde PR z infrastrukturą wykonuje `terraform plan` przez OIDC.

- [ ] Zaplanować trigger workflow (PR do gałęzi głównej / wybranych branchy).
- [ ] Zaplanować kroki:
  - przyznanie uprawnień `id-token` i `contents` dla joba,
  - uzyskanie tokenu OIDC od GitHub Actions,
  - wywołanie `assume-role` dla roli z W08-T01,
  - `terraform init/validate/plan` w `infra/terraform/envs/dev`.
- [ ] Ustalić sposób prezentacji wyniku planu (logi, artefakt, ewentualnie komentarz na PR).
- [ ] Utworzyć plik workflow w repo (`.github/workflows/terraform-plan.yml`) z powyższymi krokami (implementacja po stronie użytkownika).
- **Input:** OIDC role z W08-T01, aktualna struktura katalogów `infra/terraform/*`, roadmapa.
- **Output:** Zdefiniowany workflow `plan` (plik w repo), gotowy do pierwszego testowego PR.
- **Weryfikacja:** Testowe PR z infrastrukturą uruchamia workflow; w logach widać udane uzyskanie tymczasowych poświadczeń i wykonanie `terraform plan`.

---

### D4 (1.5h) — Workflow `terraform apply` na `main` (W08-T03)

**Cel:** Przygotować kontrolowany workflow do `terraform apply` na środowisku dev, wyzwalany z `main` (lub manualnie).

- [ ] Zdecydować model wyzwalania:
  - automatycznie na merge do `main`, lub
  - manualnie (`workflow_dispatch`) z parametrami (np. `approve=true`).
- [ ] Zaplanować zabezpieczenia:
  - ten sam OIDC flow i rola co w `plan`,
  - ewentualny manualny approval / environment protection w GitHub,
  - ograniczenie do wybranego katalogu/stacka (`envs/dev`).
- [ ] Zaplanować kroki joba:
  - `terraform init` z backendem S3,
  - `terraform plan` (opcjonalnie, jako sanity check),
  - `terraform apply` z wyraźnie oznaczonym environmentem.
- [ ] Utworzyć plik workflow w repo (`.github/workflows/terraform-apply.yml`) według powyższego planu (implementacja po stronie użytkownika).
- **Input:** W08-T01, W08-T02; polityki bezpieczeństwa repo (branch protection, environments).
- **Output:** Zdefiniowany workflow `apply` (plik w repo), gotowy do testu na kontrolowanym merge / manualnym uruchomieniu.
- **Weryfikacja:** Testowy run `apply` kończy się sukcesem; w logach widać poprawne użycie OIDC i brak błędów autoryzacji.

---

### D5 (1.5h) — Runbook + domknięcie dokumentacji (W08-T04)

**Cel:** Uporządkować wiedzę o pipeline IaC i OIDC w formie runbooka oraz uzupełnić artefakty tygodnia.

- [ ] Utworzyć / uzupełnić `docs/runbooks/terraform-pipeline-oidc.md` (lub inny uzgodniony plik) zgodnie z roadmapą:
  - przeznaczenie runbooka,
  - operacyjny flow (PR → plan, merge/manual → apply),
  - jak rozpoznać, że wszystko działa,
  - typowe błędy i troubleshooting (OIDC, trust policy, permissions).
- [ ] Uzupełnić `docs/weekly/W08/evidence.md` konkretnymi artefaktami (linki do workflow, fragment trust policy bez wrażliwych danych).
- [ ] Zaktualizować `docs/weekly/W08/log.md` o wykonane sesje D1–D5.
- [ ] Przygotować zarys `docs/weekly/W08/summary.md` pod `/week-finish` (co zrobiono, decyzje, pułapki).
- **Input:** Dziennik z D1–D4, logi workflow, roadmapa W08.
- **Output:** Runbook i artefakty tygodnia w spójnym stanie.
- **Weryfikacja:** Na podstawie samego runbooka inżynier jest w stanie:
  - uruchomić pipeline od zera, oraz
  - zdiagnozować typowe problemy z OIDC/permissions.

---

## Pułapki (z roadmapy + doprecyzowanie)

- **Błędny `sub` claim** — najczęstszy problem; brak dopasowania pomiędzy tym, co wysyła GitHub (`repo:owner/name:ref`) a tym, co wpisano w trust policy, powoduje nieme odrzucanie żądań.
- **Zbyt szeroka trust policy** — kuszące „naprawienie” błędów przez dopuszczenie wszystkich repo/branchy; trzeba tego unikać i świadomie zawężać warunki.
- **Nadmiarowe permissions** — rola Terraform powinna mieć tylko te uprawnienia, które są potrzebne aktualnym modułom (S3 backend, networking itd.), a nie pełne admin.
- **Brak rozdzielenia plan/apply** — plan na PR i apply na `main` (lub z manualnym gate’em) to podstawowy pattern bezpieczeństwa.

## Następny krok (po W08)

Po spełnieniu DoD W08 kolejnym krokiem będzie W09 — szkielet aplikacji .NET i podstawowy CI, już korzystający z wypracowanych wzorców OIDC/GitHub Actions.

