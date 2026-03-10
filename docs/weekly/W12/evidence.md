# W12 — evidence

Dowody wykonania DoD i tasków (zgodnie z roadmapą).

## Z roadmapy

- **Evidence:** Image tags w ECR (np. commit SHA); workflow logs; screenshot/listing ECR tags.
- **Docs:** `docs/lessons/W12-summary.md`.
- **Runbook:** build/push + troubleshooting image build.

## Checklist evidence

- [x] **W12-T01:** Dockerfile orders-api: `src/orders-api/Dockerfile`, `.dockerignore`; analiza w `docs/lessons/W12-dockerfile-design-orders-api.md`; weryfikacja build + /health OK
- [x] **W12-T02:** ECR repo orders-api: moduł `ecr_orders_api` w envs/dev/main.tf, output `ecr_orders_api_url`, lifecycle keep last 5
- [ ] ECR repo widoczne po `terraform apply` (Terraform output / konsola)
- [ ] Lifecycle policy włączona (screenshot lub opis)
- [ ] Min. 1 obraz w ECR z tagiem (np. commit SHA)
- [ ] Link do udanego runu workflow build/push
- [ ] Runbook: `docs/runbooks/ecr-build-push.md` (lub zgodna nazwa)
- [ ] Lekcja: `docs/lessons/W12-summary.md`

## Uwagi

_(uzupełnij w trakcie tygodnia)_
