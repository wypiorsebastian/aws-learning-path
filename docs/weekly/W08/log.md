## W08 — log tygodnia

Log wpisów chronologicznie; każdy wpis z datą/czasem i powiązanym TaskId.

---

- **2026-03-05** — Start W08. Przeczytana sekcja W08 z roadmapy. Cel: pipeline Terraform przez GitHub OIDC (plan + apply bez statycznych kluczy). _TaskId: —_
- **2026-03-05** — W08-T01: utworzona instrukcja OIDC w `docs/runbooks/github-actions-oidc-aws.md`; użytkownik skonfigurował OIDC provider i rolę IAM w AWS, trust policy doprecyzowana (aud + sub, w tym environment:dev). _TaskId: W08-T01_
- **2026-03-05** — W08-T02: dodany workflow `terraform-plan.yml` (trigger PR + workflow_dispatch), backend z vars, OIDC; po poprawkach trust policy (environment:dev) i zmiennej TF_BACKEND_BUCKET w env dev — plan w CI przeszedł. _TaskId: W08-T02_
- **2026-03-05** — W08-T03: dodany workflow `terraform-apply.yml` (push na master + workflow_dispatch); apply w CI zakończony sukcesem (m.in. CloudWatch log group i Flow Log utworzone po usunięciu istniejącego log group). _TaskId: W08-T03_
- **2026-03-05** — W08-T04: utworzony runbook `docs/runbooks/terraform-pipeline-oidc.md` (architektura, flow, pain pointy, troubleshooting). _TaskId: W08-T04_
- **2026-03-05** — Ulepszenia pipeline: pinowanie Terraform 1.9.0, cache providerów, ARN roli w zmiennej `AWS_GITHUB_ACTIONS_ROLE_ARN`; stretch na W09: plan w komentarzu PR. _TaskId: —_
