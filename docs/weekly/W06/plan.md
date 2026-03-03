## W06 — plan sesji D1–D5

### Kontekst tygodnia
- **Cel tygodnia:** Bootstrappować remote state (S3 + natywny lock `use_lockfile`) zgodnie z best practices, skonfigurować backend i zaimplementować moduł `network-core` (VPC, subnets, IGW, NAT, route tables, SG, NACL).
- **WhyNow:** Design z W04/W05 gotowy; wyjście z fazy planowania — infrastruktura pod CI/CD (state + lock) musi istnieć przed pierwszym apply; brak migracji, brak błędów z local state.
- **Outcome (wg roadmapy):** Remote state działa od dnia 1; moduł `network-core` zaimplementowany; `terraform fmt/validate/plan` bez błędów; gotowość do apply w W07.
- **DoD (skrót):** Backend S3 (use_lockfile) skonfigurowany; Terraform foundations zrozumiane; moduł network-core istnieje i przechodzi `fmt/validate/plan` (apply w W07).

### Założenia czasowe
- 5 sesji po **1.5h** (D1–D5).
- Fokus: **bootstrap backend → konfiguracja → Terraform basics + implementacja** modułu `network-core` na bazie designu z W04.

---

## D1 (1.5h) — Bootstrap S3 (W06-T01)

- [ ] Przeczytać sekcję W06 w `docs/roadmap/aws-course-roadmap-operational-0-24.md` (cel, DoD, pułapki).
- [ ] **Bootstrap bucket S3** dla Terraform state:
  - versioning,
  - encryption (SSE-S3),
  - block public access.
- [ ] Lock stanu: natywny S3 (`use_lockfile = true` w backendzie envs/dev) — plik `.tflock` w bucketcie; Terraform ≥1.10; DynamoDB nie jest używane.
- [ ] Zapisać procedurę w `docs/runbooks/terraform-backend-bootstrap.md` (kroki manual lub osobna Terraform config z local state).
- [ ] Zweryfikować: bucket istnieje; bucket ma versioning, encryption, block public access.

**Cel D1:** mieć działający backend S3 gotowy pod Terraform (lock przez use_lockfile) — best practices enterprise.

---

## D2 (1.5h) — Backend config + Terraform basics (W06-T02)

- [ ] Skonfigurować backend `"s3"` w `infra/terraform/envs/dev/`:
  - `bucket`, `key`, `region`, `use_lockfile = true`.
  - Użyć `backend-config` lub partial configuration jeśli wartości z zewnątrz.
- [ ] Uruchomić `terraform init` — zweryfikować, że backend S3 jest aktywny.
- [ ] Uporządkować wiedzę o Terraform:
  - provider AWS, variables, outputs, moduły,
  - `fmt`, `validate`, `plan` — co robią i kiedy je używać.
- [ ] Zapisać notatkę w `docs/lessons/W06-summary.md`.

**Cel D2:** `terraform init` w envs/dev używa backend S3; `terraform state list` działa (pusty state OK); podstawy Terraform uporządkowane.

---

## D3 (1.5h) — Implementacja modułu `network-core` — część 1 (VPC, subnets, IGW, NAT, route tables) (W06-T03)

- [ ] Utworzyć strukturę `infra/terraform/modules/network-core/` (main.tf, variables.tf, outputs.tf, versions.tf).
- [ ] Zaimplementować w `main.tf`:
  - `aws_vpc` (CIDR 10.0.0.0/16, enable_dns_hostnames, enable_dns_support),
  - `aws_subnet` (4 subnety: public-a/b, private-a/b),
  - `aws_internet_gateway`, `aws_eip`, `aws_nat_gateway` (w public-a),
  - `aws_route_table` (public: 0.0.0.0/0 → IGW; private: 0.0.0.0/0 → NAT),
  - `aws_route_table_association`, `aws_route`.
- [ ] Dodać wywołanie modułu w `envs/dev/main.tf`.
- [ ] Uruchomić `terraform init`, `fmt`, `validate` — naprawić błędy składni.

**Cel D3:** moduł `network-core` z VPC, subnetami, IGW, NAT i route tables; `terraform validate` przechodzi.

---

## D4 (1.5h) — Implementacja modułu `network-core` — część 2 (SG, standards, tagging) (W06-T03 / W06-T04)

- [ ] Dodać baseline Security Groups (sg_alb, sg_app, sg_rds) zgodnie z W04.
- [ ] Zastosować standards: variables, locals (tagi), outputs zgodnie z designem W04.
- [ ] Tagowanie zgodnie z ADR-0002: `Project`, `Env`, `ManagedBy`, `Module`, `Name`.
- [ ] Utworzyć `infra/terraform/modules/_standards.md` (W06-T04).
- [ ] Uruchomić `terraform plan` — przejrzeć output, upewnić się, że brak błędów logicznych.

**Cel D4:** moduł `network-core` kompletny; `terraform plan` przechodzi; standardy udokumentowane.

---

## D5 (1.5h) — README, runbook IAM, evidence (W06-T05)

- [ ] Utworzyć `infra/terraform/README.md`:
  - struktura (modules/, envs/dev/),
  - bootstrap → init → plan → (W07) apply,
  - odwołania do designu i runbooków.
- [ ] Uzupełnić `docs/runbooks/terraform-backend-bootstrap.md`:
  - procedura bootstrapu,
  - wymagania IAM dla roli CI/CD w W08 (S3 least privilege, w tym plik `.tflock`).
- [ ] Uzupełnić `docs/lessons/W06-summary.md` — co zrobione, pułapki, gotowość pod W07.
- [ ] Zaktualizować `docs/weekly/W06/evidence.md`, `log.md`.
- [ ] Zweryfikować, że outputy `network-core` są gotowe pod `network-endpoints` (W07): `private_route_table_id`, `private_subnet_ids`, `vpc_id`, `sg_*_id`.

**Cel D5:** tydzień domknięty; evidence gotowy; moduł `network-core` jako input do W07 (network-endpoints + apply).
