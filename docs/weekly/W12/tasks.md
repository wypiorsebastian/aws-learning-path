## W12 — taski tygodnia

### Kontekst

- **WeekId:** `W12`
- **Cel tygodnia:** Przygotować kontenery i registry pod ECS/Fargate — obrazy .NET w ECR z GitHub Actions (OIDC).
- **Outcome:** Min. 1 serwis budowany i pushowany automatycznie do ECR; ECR z lifecycle policy; runbook build/push.
- **Uwaga:** Zgodnie z zasadami projektu — kod generowany tylko na wyraźną prośbę; ten plik definiuje zakres i kroki.

---

## Taski bazowe z roadmapy

### W12-T01 — Ustandaryzuj Dockerfile dla API/worker (template)

- **TaskId:** `W12-T01`
- **Status:** `DONE`
- **Priorytet:** `P1`
- **Typ:** `Coding`
- **Cel:** Mieć wspólny szablon Dockerfile (multi-stage) dla API i opcjonalnie worker; port 8080, health endpoint.
- **Estymata:** 45m
- **Input:** Projekty z W09 (catalog-api, orders-api, order-worker); wymagania ECS (port, health).
- **Kroki:**
  1. Ustandaryzować Dockerfile dla wybranego API (lub uzupełnić istniejący z W10): multi-stage, `dotnet publish`, port 8080.
  2. Upewnić się, że start command i port są zgodne z ECS (np. zmienna PORT).
  3. Opcjonalnie: osobny szablon dla order-worker (jeśli inny entrypoint).
  4. Weryfikacja: `docker build`, `docker run`, `curl localhost:8080/health`.
- **Verification:** Kontener startuje; GET `/health` zwraca 200.
- **Evidence:** Ścieżka do Dockerfile; output `docker run` / `curl`.

---

### W12-T02 — Utwórz ECR repo + lifecycle policy

- **TaskId:** `W12-T02`
- **Status:** `DONE`
- **Priorytet:** `P1`
- **Typ:** `IaC`
- **Cel:** ECR repository w Terraform z polityką usuwania starych obrazów (lifecycle policy).
- **Estymata:** 30m
- **Input:** Moduł `ecr` (lub nowy); envs/dev.
- **Kroki:**
  1. Utworzyć/rozszerzyć moduł Terraform: `aws_ecr_repository`, opcjonalnie `aws_ecr_lifecycle_policy` (np. keep last 10 images).
  2. Wywołać moduł z envs/dev dla repozytoriów potrzebnych w W12/W13 (np. catalog-api, orders-api).
  3. `terraform apply`; zapisać URI repozytorium (output).
- **Verification:** Repo widoczne w konsoli ECR; lifecycle policy aktywna.
- **Evidence:** Output `terraform output`; screenshot ECR.

---

### W12-T03 — Pipeline build/push image do ECR (OIDC)

- **TaskId:** `W12-T03`
- **Status:** `TODO`
- **Priorytet:** `P1`
- **Typ:** `CI/CD`
- **Cel:** Workflow GitHub Actions: build obrazu, tag (np. commit SHA), push do ECR z użyciem OIDC (bez static keys).
- **Estymata:** 45m
- **Input:** W08 (OIDC role); W12-T01 (Dockerfile); W12-T02 (ECR repo).
- **Kroki:**
  1. Workflow: checkout → configure AWS credentials (OIDC) → login to ECR → docker build → tag → push.
  2. Tag: commit SHA (np. `sha-${GITHUB_SHA::7}`) lub branch + SHA.
  3. Uruchomić workflow (push do main lub manual); sprawdzić obraz w ECR.
- **Verification:** Obraz w ECR z tagem; logi workflow bez błędów.
- **Evidence:** Link do udanego runu; listing ECR tags.

---

### W12-T04 — Runbook build/push + troubleshooting image build

- **TaskId:** `W12-T04`
- **Status:** `TODO`
- **Priorytet:** `P2`
- **Typ:** `Docs`
- **Cel:** Runbook: jak budować lokalnie, jak push przez pipeline, typowe błędy (arch, port, auth ECR).
- **Estymata:** 30m
- **Input:** Doświadczenie z T01–T03.
- **Kroki:**
  1. Sekcja: build lokalny (`docker build`), wymagania (Dockerfile path, context).
  2. Sekcja: pipeline (trigger, OIDC, tagowanie).
  3. Sekcja: troubleshooting (arch mismatch, ECR auth, port w aplikacji).
- **Verification:** Runbook pozwala powtórzyć build/push i zdiagnozować typowe problemy.
- **Evidence:** `docs/runbooks/ecr-build-push.md` (lub zgodna z konwencją repo).
