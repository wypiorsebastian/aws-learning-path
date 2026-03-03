## W06 — podsumowanie tygodnia

Podsumowanie wypełniane na końcu tygodnia lub przy domykaniu (`/week-finish`). Skrót: co zrobiono, kluczowe decyzje, pułapki, następny krok.

---

- **Cel tygodnia (z roadmapy):** Bootstrappować remote state (S3 + natywny lock use_lockfile), skonfigurować backend i zaimplementować moduł `network-core`.
- **DoD:** Backend S3 (use_lockfile) skonfigurowany; Terraform foundations zrozumiane; moduł network-core istnieje i przechodzi `fmt/validate/plan`.
- **Status:** **DONE** (2026-03-02)
- **Wykonane taski:** W06-T01 (bootstrap S3), W06-T02 (backend envs/dev, W06-summary), W06-T03 (moduł network-core), W06-T04 (_standards.md), W06-T05 (README, runbook bootstrap).
- **Artefakty:** `infra/terraform/bootstrap/`, `envs/dev/`, `modules/network-core/` (main, variables, outputs, versions, security), `modules/_standards.md`, `infra/terraform/README.md`, `docs/runbooks/terraform-backend-bootstrap.md`, `docs/lessons/W06-summary.md`.
- **Wnioski / pułapki:** Terraform wymaga `AWS_PROFILE` (lub alias `aws-dev`); init/plan bez poświadczeń nie przejdą. SG: użycie `aws_vpc_security_group_*` unika cyklicznych zależności między sg_alb, sg_app, sg_rds. NACL: świadomie używamy domyślnego NACL VPC (design W04).
- **Następny krok:** W07 — moduł `network-endpoints`, integracja z network-core, `terraform apply` sieci do dev.
