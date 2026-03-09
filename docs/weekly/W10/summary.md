## W10 — podsumowanie tygodnia

Podsumowanie po W10 (`/week-finish`). Skrót: co zrobiono, kluczowe decyzje, pułapki, następny krok.

---

- **Cel tygodnia (z roadmapy):** Uzyskać pierwszy działający endpoint .NET w AWS — wdrożyć catalog-api lub orders-api do App Runner.
- **DoD:** **częściowo spełniony** (endpoint działa, logi i ECR/App Runner są skonfigurowane, ale brakuje pełnego runbooka deployu i formalnego evidence)
- **Status:** **PARTIAL**

### Co osiągnięto

- Przygotowano **Dockerfile** dla `catalog-api` (multi-stage, sdk:10.0 + aspnet:10.0, port 8080, non-root `USER $APP_UID`, pinned digests; `.dockerignore` zawęża kontekst builda). Lokalny `docker build/run` oraz `curl http://localhost:8080/health` → 200.
- Rozszerzono infrastrukturę Terraform o moduły **`ecr`** i **`apprunner`** oraz włączono je w `envs/dev/main.tf` (`ecr_catalog_api`, `apprunner_catalog_api` + outputs dla URL ECR i App Runner).
- Skonfigurowano workflow GitHub Actions **`catalog-api — Build & Push to ECR`** z OIDC (rola GitHubActionsRole) i nadano roli minimalne uprawnienia ECR (runbook + JSON policy); obraz `catalog-api` jest budowany i pushowany do ECR bez lokalnych kredensiali.
- Uruchomiono serwis **App Runner** dla `catalog-api` (ECR jako source, port 8080, health check `/health`); `/health` odpowiada, a logi aplikacyjne są widoczne w log groupie `.../application`.
- Dodano **structured logging** w `catalog-api` z Serilog (CompactJsonFormatter) oraz własny middleware logujący każde uderzenie w endpoint (`LogSource="Application"`, `EventType="EndpointHit"` + log startu `EventType="Startup"`), co pozwala w CloudWatch łatwo odróżnić logi aplikacyjne od `[AppRunner]`.
- Utworzono runbook **`docs/runbooks/dev-daily-cleanup.md`** z codziennymi skryptami: usuwanie serwisu App Runner, czyszczenie obrazów ECR i logów CloudWatch (w tym Flow Logs) bez niszczenia sieci Terraform.

### Co nie dowiezione / luki względem roadmapy

- Taski **W10-T02–T04** pozostają w statusie `TODO` — brak formalnego domknięcia w `tasks.md` oraz brak pełnego evidence dla deployu App Runner (URL serwisu, przykładowy `curl https://.../health`, opis logów i env vars).
- Nie powstał dedykowany runbook **`docs/runbooks/apprunner-deploy.md`** (opis kroków: Terraform → build/push → App Runner → troubleshooting) ani `docs/lessons/W10-summary.md` z podsumowaniem lekcji o App Runner.
- Brak udokumentowanego redeployu po zmianie kodu (`build → push → auto-deploy App Runner`) jako osobnego smoke testu w evidence.

### Root cause problemów / opóźnień

- Świadome **rozszerzenie zakresu** tygodnia z prostego „klikowego” deployu App Runner do pełnego łańcucha **Terraform (ECR + App Runner) + GitHub Actions (build/push) + IAM (OIDC + ECR)** — więcej pracy infrastrukturalnej niż przewidywała roadmapa na W10.
- Część czasu pochłonęło debugowanie ról IAM i workflowu pushującego do ECR (uprawnienia ECR dla roli OIDC) oraz zrozumienie podziału logów App Runner (`service` vs `application`).

### Lessons learned

- App Runner jest wygodnym, zarządzanym hostingiem dla .NET, ale **pierwszy deploy często kończy się `CREATE_FAILED`**, jeśli obraz nie jest jeszcze dostępny w ECR — to normalny etap, który trzeba świadomie obsłużyć (najpierw ECR, potem App Runner).
- Logi App Runner dzielą się na **`service`** (logi platformy, health checks `[AppRunner]`) i **`application`** (stdout aplikacji); structured logging z dodatkowymi polami (`LogSource`, `EventType`) znacząco ułatwia analizę ruchu i problemów.
- Integracja **GitHub Actions + OIDC + ECR** pozwala całkowicie uniknąć lokalnych access key — wszystkie buildy/pushe powinny docelowo przechodzić przez pipeline.
- Dla środowiska dev sensownie jest mieć osobny runbook do **selektywnego cleanupu** (App Runner, ECR, logi) zamiast codziennego `terraform destroy`, który niszczy całą sieć.

### Next actions (W11 / catch-up)

- **Domknąć W10-T02–T04 jako catch-up na początku W11:**
  - dopisać evidence w `docs/weekly/W10/evidence.md` (URL App Runner, przykładowy `curl https://.../health`, opis logów i użytych env vars),
  - utworzyć `docs/runbooks/apprunner-deploy.md` na bazie obecnej konfiguracji (Terraform + workflow build/push + troubleshooting CREATE_FAILED),
  - opcjonalnie dodać krótką notatkę z porównaniem App Runner vs Beanstalk (może trafić do materiałów W11).
- **Rozpocząć W11:**
  - `W11-T01` — spisać model odpowiedzialności Elastic Beanstalk i porównać go do tego, co już wiesz o App Runner (shared vs fully managed).

### Portfolio bullets (1–3)

- **App Runner + ECR + Terraform/GitHub Actions:** Skonteneryzowałem `.NET 10` API (`catalog-api`) i wdrożyłem je do AWS App Runner, używając Terraform (moduły `ecr` i `apprunner`) oraz GitHub Actions z OIDC do budowy i pushu obrazów do ECR.
- **Observability:** Zaprojektowałem structured logging dla API (Serilog → CloudWatch) z rozróżnieniem logów platformowych (`service`) i aplikacyjnych (`application`) oraz śledzeniem uderzeń w endpointy (`EndpointHit`, `Startup`).
- **Operacje dev-only:** Przygotowałem runbook `dev-daily-cleanup` do codziennego sprzątania środowiska dev (App Runner, ECR, logi) bez niszczenia sieci Terraform, co obniża koszty i upraszcza pracę laboratoryjną.
