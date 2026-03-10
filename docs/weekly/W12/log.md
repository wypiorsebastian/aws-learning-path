# W12 — log tygodnia

Wpisy chronologiczne. Format: data/czas (opcjonalnie) | TaskId | opis.

---

2025-03-10 | W12-T01 | Utworzono Dockerfile i .dockerignore dla orders-api (`src/orders-api/`). Multi-stage (sdk:10.0 + aspnet:10.0), pinned digests, non-root USER, port 8080. Analiza best practices w `docs/lessons/W12-dockerfile-design-orders-api.md`. Weryfikacja: `docker build --platform linux/amd64 -t orders-api:local -f src/orders-api/Dockerfile src/orders-api` OK; `curl localhost:8080/health` → 200.

2025-03-10 | W12-T02 | ECR: dwa osobne repozytoria (catalog-api dla App Runner, orders-api dla Fargate). Dodano `module "ecr_orders_api"` w envs/dev/main.tf (ten sam moduł ecr, repository_name = "orders-api", lifecycle keep last 5). Output `ecr_orders_api_url`. Apply: użytkownik wykonuje `terraform apply`.
