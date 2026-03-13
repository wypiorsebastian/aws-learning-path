# W12 — Projekt workflowów Build & Push do ECR

Propozycja wzorcowego workflowu dla orders-api z reużywalnym workflowem pod inne serwisy (catalog-api, payments-api, itd.).

---

## Źródła

- **[GitHub Actions — Workflow syntax](https://docs.github.com/en/actions/reference/workflows-and-actions/workflow-syntax)** — `on.workflow_call`, `inputs`, `permissions`, `paths`/`branches`, konteksty.
- **[.NET DevOps — GitHub Actions](https://learn.microsoft.com/en-us/dotnet/devops/github-actions-overview)** — składnia workflowu, events, secrets.
- **[AWS IAM — OIDC federation](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_providers_oidc.html)** — brak long-lived credentials; token JWT wymieniany na temporary credentials; rola z trust policy na GitHub OIDC.
- **[ECS Render Task Definition](https://github.com/marketplace/actions/amazon-ecs-render-task-definition-action-for-github-actions)** — na później (W13+): wstawianie URI obrazu do task definition przed deployem.

---

## Cele

1. **W12-T03:** Build obrazu orders-api i push do ECR (OIDC, bez static keys).
2. **Reużywalność:** Jeden wspólny workflow „build + push do ECR” wywoływany z workflowów per-serwis.
3. **Tagowanie:** Commit SHA (reproducibility) + opcjonalnie `latest` (dev).
4. **Platforma:** `linux/amd64` (Fargate); jawnie w buildzie.

---

## Architektura

### Opcja przyjęta: Reusable Workflow + workflowy wywołujące

| Plik | Rola |
|------|------|
| `.github/workflows/build-push-ecr.yml` | **Reusable workflow** (`on: workflow_call`). Inputs: repozytorium ECR, ścieżka Dockerfile, kontekst builda, region. Kroki: checkout → OIDC → ECR login → build (z platformą) → tag (sha + latest) → push. |
| `.github/workflows/orders-api-ecr-push.yml` | **Wywołujący** — trigger na `push` (paths: `src/orders-api/**`) i `workflow_dispatch`; wywołuje `build-push-ecr` z parametrami dla orders-api. |
| (później) `catalog-api-ecr-push.yml` | Można przerobić na wywołanie `build-push-ecr` z parametrami catalog-api (refaktor opcjonalny). |

**Dlaczego nie jeden workflow z matrix?**  
Matrix (np. service: [catalog-api, orders-api]) wymuszałby budowanie wszystkich serwisów przy każdej zmianie w jednym z pathów albo skomplikowane `paths`/`if`. Workflow per-serwis + reusable job daje: trigger tylko przy zmianach w `src/orders-api/**`, czytelne nazwy w Actions, łatwe dodawanie kolejnego serwisu (kopiuj plik, zmień inputs).

**Dlaczego reusable workflow, a nie composite action?**  
Workflow_call pozwala na osobną widoczną „run” w zakładce Actions dla każdego serwisu i przejrzyste przekazanie inputs (repo, Dockerfile, context). Composite action wymagałby jednego jobu wywołującego action z wieloma parametrami i mniej czytelnego podziału odpowiedzialności.

---

## Zależności (OIDC)

- **Rola IAM:** Trust policy na OIDC provider GitHub (`token.actions.githubusercontent.com`), condition na `sub` (repo, branch). Rola musi mieć uprawnienia: `ecr:GetAuthorizationToken` oraz na konkretne repo ECR: `ecr:BatchCheckLayerAvailability`, `ecr:PutImage`, `ecr:InitiateLayerUpload`, `ecr:UploadLayerPart`, `ecr:CompleteLayerUpload`.
- **Zmienna repozytorium:** `vars.AWS_GITHUB_ACTIONS_ROLE_ARN` (w environment „dev” lub na poziomie repo). Reusable workflow używa tej samej zmiennej (wywołanie jest w kontekście tego samego repo).

---

## Tagowanie obrazów

- **`sha-<short_sha>`** — np. `sha-a1b2c3d` (pierwsze 7 znaków `GITHUB_SHA`). Do deployów z deterministyczną wersją i rollbacku.
- **`latest`** — wygoda w dev (task definition może wskazywać `:latest`). Lifecycle policy ECR i tak ogranicza liczbę obrazów.

Oba tagi są pushowane w jednym jobie (build raz, tag dwa razy, push dwa razy).

---

## Kolejny krok (W13+): ECS deploy

Deploy do ECS (Fargate) można dodać jako osobny job lub osobny workflow (np. `orders-api-ecs-deploy.yml`), który:
- zależy od udanego build-push (np. `workflow_run` po `orders-api-ecr-push` albo ręczny trigger z inputem `image_tag`),
- używa `aws-actions/amazon-ecs-render-task-definition` z URI obrazu z ECR,
- wywołuje `aws-actions/amazon-ecs-deploy-task-definition`.

Na W12 ograniczamy się do build + push; ECS deploy pozostaje na W13/W15.

---

## Dodanie kolejnego serwisu (np. payments-api)

1. Skopiuj `.github/workflows/orders-api-ecr-push.yml` jako np. `payments-api-ecr-push.yml`.
2. Zmień `name`, `on.push.paths` oraz w `with`: `ecr_repository`, `dockerfile_path`, `context_path` na wartości dla nowego serwisu.
3. W Terraform (envs/dev) dodaj moduł `ecr_<serwis>` i output URL repozytorium.
4. Upewnij się, że rola OIDC ma uprawnienia ECR na nowe repozytorium (policy na `arn:aws:ecr:region:account:repository/<ecr_repository>`).

---

## Weryfikacja

- Push do `master` w `src/orders-api/**` uruchamia workflow.
- W zakładce Actions: „orders-api — Build & Push to ECR” (lub nazwa wywołującego workflow).
- W ECR w repozytorium `orders-api`: obrazy z tagami `sha-<xxx>` i `latest`.
- Logi: brak błędów OIDC/ECR; build z `--platform linux/amd64`.
