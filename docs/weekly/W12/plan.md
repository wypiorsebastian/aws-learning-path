# W12 — plan tygodnia

## Cel tygodnia (z roadmapy)

Przygotować **kontenery i registry pod ECS/Fargate** — obrazy .NET budowane i pushowane do ECR z GitHub Actions (OIDC).

## WhyNow

- ECS Fargate (W13) wymaga obrazów w ECR; bez sprawnego build/push workflow nie da się wdrożyć orders-api na ECS.
- W10 dał doświadczenie z kontenerem (catalog-api na App Runner); W12 ustandaryzuje Dockerfile i zautomatyzuje push do ECR.

## DoD (z roadmapy)

- **Min. 1 serwis budowany i pushowany automatycznie do ECR.**
- `docker build` lokalnie działa.
- Pipeline pushuje obraz do ECR (np. tag commit SHA).
- ECR ma politykę retencji / cleanup (lifecycle policy).

## MVP tygodnia

- **W12-T01:** Ustandaryzowany Dockerfile (template dla API/worker).
- **W12-T02:** ECR repo + lifecycle policy (Terraform).
- **W12-T03:** Pipeline build/push image do ECR (GitHub Actions, OIDC).
- **W12-T04 (P2):** Runbook build/push + troubleshooting image build.

## Pułapki (z roadmapy)

- **Tagowanie `latest`** — unikać jako jedynego tagu; preferować commit SHA lub semver.
- **Arch mismatch** — build na Mac/ARM vs Fargate (x86); multi-platform lub explicit platform.
- **Zły port** — aplikacja musi nasłuchiwać na porcie oczekiwanym przez ECS (np. 8080).
- **ECR storage** — ustawić lifecycle policy, żeby nie płacić za stare warstwy.

## Prereq

- W09 — działające API/worker lokalnie (orders-api, catalog-api, order-worker).
- W08 — GitHub Actions + OIDC do AWS (rola do assume dla pipeline’u).
- W10 (opcjonalnie) — doświadczenie z Dockerfile dla App Runner.

---

## Plan D1–D5 (po 1.5h każda sesja)

### D1 (1.5h) — Dockerfile template (W12-T01)

- [ ] Ustandaryzować Dockerfile dla API (multi-stage: build + runtime).
- [ ] Port 8080 (lub zmienna PORT), health endpoint dostępny.
- [ ] Opcjonalnie: szablon dla order-worker.
- [ ] Zweryfikować lokalnie: `docker build`, `docker run`, `curl localhost:8080/health`.
- **Output:** Działający Dockerfile w repo; weryfikacja lokalna.

### D2 (1.5h) — ECR repo + lifecycle (W12-T02)

- [ ] Moduł Terraform `ecr` (repo, lifecycle policy — np. keep last N images).
- [ ] Apply w envs/dev; zapisać URI repozytorium.
- [ ] **Output:** ECR repo istnieje; lifecycle policy włączona.

### D3 (1.5h) — Pipeline build/push (W12-T03)

- [ ] Workflow: checkout → assume OIDC role → login ECR → build → tag (commit SHA) → push.
- [ ] Wybrać min. 1 serwis (np. catalog-api lub orders-api) do pierwszego pushu.
- [ ] Zweryfikować: po merge/trigger obraz pojawia się w ECR z tagiem.
- **Output:** Obraz w ECR z tagiem; logi workflow OK.

### D4 (1.5h) — Runbook + evidence (W12-T04)

- [ ] Runbook: build lokalny, push przez pipeline, typowe błędy (arch, port, auth).
- [ ] Uzupełnić evidence: screenshot/listing ECR tags, link do workflow run.
- [ ] **Output:** `docs/runbooks/ecr-build-push.md` (lub podobna nazwa); evidence.

### D5 (1.5h) — Podsumowanie i DoD

- [ ] `docs/lessons/W12-summary.md`: co zrobione, pułapki, następny krok (W13 ECS).
- [ ] `docs/weekly/W12/summary.md`: status tasków, uwagi.
- [ ] Przegląd DoD: min. 1 serwis pushowany do ECR, lifecycle policy, runbook.
