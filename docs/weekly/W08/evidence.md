## W08 — evidence

Dowody wykonania zadań i spełnienia DoD. Roadmapa oczekuje: pipeline Terraform przez OIDC; plan w CI na PR; apply na merge/manual; runbook + troubleshooting.

---

### W08-T01 — OIDC provider i IAM role
- **Oczekiwane:** Provider OIDC w AWS, rola z trust policy (aud, sub); udane assume-role z GitHub Actions.
- **Link / opis:** Konfiguracja wykonana po stronie użytkownika (AWS IAM). Trust policy zawiera `StringEquals` na `token.actions.githubusercontent.com:aud = sts.amazonaws.com` oraz `StringLike` na `sub` (repo, ref:master/main, pull_request, environment:dev). Instrukcja krok po kroku: `docs/runbooks/github-actions-oidc-aws.md`. Dowód: logi workflowów z krokiem „Authenticated as assumedRoleId ...:GitHubActions”.

### W08-T02 — Workflow terraform plan
- **Oczekiwane:** Workflow uruchamia plan w CI; OIDC działa; plan widoczny w logach.
- **Link / opis:** `.github/workflows/terraform-plan.yml` — trigger workflow_dispatch + pull_request (main), environment dev, backend.ci.hcl z vars.TF_BACKEND_BUCKET, OIDC, cache providerów, Terraform 1.9.0. Udane runy potwierdzone w dyskusji (plan: 38 to add, potem plan: 2 to add po częściowym apply).

### W08-T03 — Workflow terraform apply
- **Oczekiwane:** Workflow apply w CI (merge/manual); bez statycznych kluczy.
- **Link / opis:** `.github/workflows/terraform-apply.yml` — trigger workflow_dispatch + push na master (paths: infra/terraform/**), ten sam wzorzec OIDC/backend/cache. Apply zakończony sukcesem (Apply complete! Resources: 2 added).

### W08-T04 — Runbook pipeline + troubleshooting
- **Oczekiwane:** Runbook z flow, konfiguracją i pain pointami OIDC/backend/zasobów.
- **Link / opis:** `docs/runbooks/terraform-pipeline-oidc.md` — architektura, operacyjny flow plan/apply, konfiguracja krok po kroku, „Pain pointy i troubleshooting” (AssumeRoleWithWebIdentity, backend bucket/key, ResourceAlreadyExistsException log group), pułapki i checklista.

### DoD (roadmapa)
- **Kryterium:** PR generuje plan, merge uruchamia apply (manual gate opcjonalnie).
- **Potwierdzenie:** DoD spełniony. Plan w CI działa (PR do main + workflow_dispatch); apply działa na push na master oraz workflow_dispatch. Wszystko przez OIDC, bez access key/secret. Opcjonalnie: `docs/lessons/W08-summary.md` można dodać jako skrót lekcji (obecnie podsumowanie w `docs/weekly/W08/summary.md`).
