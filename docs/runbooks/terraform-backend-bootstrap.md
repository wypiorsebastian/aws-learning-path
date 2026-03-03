# Runbook — bootstrap Terraform backend (S3)

## Przeznaczenie

- Jednorazowe utworzenie bucketu S3 dla Terraform state przed pierwszym użyciem głównej konfiguracji (`envs/dev`).
- Backend state musi istnieć przed `terraform init` w `envs/dev`; bootstrap realizujemy osobną konfiguracją Terraform z **local state**.
- Lock stanu: natywny S3 (`use_lockfile = true` w backendzie envs/dev), bez DynamoDB (Terraform ≥1.10).

## Kluczowe fakty

- **Lokalizacja bootstrapu:** `infra/terraform/bootstrap/`
- **Backend bootstrapu:** local (domyślny); nie używamy S3 do przechowywania stanu bootstrapu.
- **Wymagania:** Terraform ≥1.0, provider AWS ~> 5.0; poświadczenia AWS (np. profil `swpr-dev`).
- **Bucket:** versioning włączony, encryption SSE-S3, block public access; nazwa: `{project}-{env}-terraform-state-{account_id}`.
- **Key:** ścieżka do pliku state w bucketcie (np. `dev/terraform.tfstate` lub `dev/platform/terraform.tfstate`); definiuje separację środowisk i stacków — razem z bucketem w pliku `backend.dev.hcl`.
- **IAM dla CI/CD (W08):** rola pipeline potrzebuje tylko S3 (GetObject, PutObject, DeleteObject na state i na plik `.tflock`).

## Jak to działa pod maską

- **Co robimy:** Uruchamiamy `terraform apply` w `infra/terraform/bootstrap/` → tworzy się bucket S3 z versioning, encryption i block public access.
- **Po co:** Główna konfiguracja (`envs/dev`) w `backend "s3"` wymaga istniejącego bucketu; bez bootstrapu jest problem „kurka i jajka”.
- **Jak poznać, że działa:** `terraform output` w bootstrapie zwraca `s3_bucket_name` i `region`; w konsoli AWS widać bucket z włączonym versioning i szyfrowaniem.

## Operacyjny flow

1. **Co robimy:** Ustawiamy profil AWS (np. `export AWS_PROFILE=swpr-dev`).
2. **Po co:** Provider AWS wymaga poświadczeń.
3. **Jak poznać, że działa:** `aws sts get-caller-identity --profile swpr-dev` zwraca konto i rolę.

4. **Co robimy:** Przechodzimy do katalogu bootstrap i uruchamiamy `terraform init`.
5. **Po co:** Pobranie providera i przygotowanie local state.
6. **Jak poznać, że działa:** Komunikat „Terraform has been successfully initialized!”.

7. **Co robimy:** Uruchamiamy `terraform plan` (opcjonalnie), potem `terraform apply`.
8. **Po co:** Utworzenie bucketu S3 (jeśli nie istnieje) lub potwierdzenie, że stan jest aktualny.
9. **Jak poznać, że działa:** `terraform output s3_bucket_name` zwraca nazwę bucketu; w konsoli AWS bucket ma versioning i encryption.

10. **Co robimy:** Zapisujemy outputy (np. `terraform output -json`) — będą potrzebne do konfiguracji backendu w `envs/dev` (bucket, region; `use_lockfile = true` ustawiane w backendzie, nie w bootstrapie).

### Pierwszy init w envs/dev (po bootstrapie)

1. **Co robimy:** W katalogu `infra/terraform/bootstrap/` uruchamiamy `terraform output -raw s3_bucket_name` i kopiujemy wynik.
2. **Po co:** Nazwa bucketu jest potrzebna w pliku konfiguracji backendu.
3. **Jak poznać, że działa:** Wypisana zostaje nazwa bucketu (np. `orderflow-dev-terraform-state-123456789012`).

4. **Co robimy:** W `infra/terraform/envs/dev/` kopiujemy `backend.dev.hcl.example` do `backend.dev.hcl` i uzupełniamy: **bucket** (nazwa z kroku 1), **key** (ścieżka pliku state w bucketcie), **region** (np. `eu-central-1`).
5. **Po co:** Terraform nie pozwala na zmienne w bloku `backend`; bucket, region i key podajemy przez `-backend-config`. **Key** definiuje, gdzie w bucketcie leży plik state (i ewentualny `.tflock`) — to podstawa separacji env/stack (np. `dev/terraform.tfstate` dla jednego stacku w dev, albo `dev/platform/terraform.tfstate`, `dev/app/terraform.tfstate` przy wielu stackach).
6. **Jak poznać, że działa:** Plik `backend.dev.hcl` zawiera linie `bucket = "..."`, `key = "dev/terraform.tfstate"` (lub przyjętą konwencję, np. `dev/platform/terraform.tfstate`), `region = "eu-central-1"`.

7. **Co robimy:** Uruchamiamy `terraform init -backend-config=backend.dev.hcl` w `infra/terraform/envs/dev/`.
8. **Po co:** Inicjalizacja backendu S3 i providera; state będzie przechowywany w S3 z lockiem (`.tflock`).
9. **Jak poznać, że działa:** Komunikat „Successfully configured the backend "s3"!”; `terraform state list` (pusty lub z zasobami).

## Pułapki

- **Brak poświadczeń:** `Error: No valid credential sources found` → ustaw `AWS_PROFILE` lub skonfiguruj AWS CLI.
- **Bucket już istnieje:** Jeśli bucket został wcześniej utworzony (np. ręcznie lub z innego katalogu), zaimportuj go do state lub użyj tego samego kodu bootstrapu — Terraform dopasuje stan do istniejącego bucketu.
- **Usunięcie bucketu:** Przed `terraform destroy` bucket musi być pusty; opcjonalnie dodaj `force_destroy = true` w `aws_s3_bucket`, aby Terraform mógł opróżnić bucket przy destroy.
- **CI/CD (W08):** Rola dla GitHub Actions musi mieć uprawnienia S3 do bucketu (state + plik `.tflock`); DynamoDB nie jest używane.

## Wymagania IAM dla roli CI/CD (W08)

- **S3 (least privilege):**
  - `s3:GetObject`, `s3:PutObject`, `s3:DeleteObject` — na prefix pliku state (np. `dev/terraform.tfstate`) oraz na pliki lock `.tflock` (Terraform ≥1.10 z `use_lockfile = true` tworzy `dev/terraform.tfstate.tflock` obok pliku state).
  - `s3:ListBucket` — na bucket (wymagane przy operacjach na obiektach).
- **Brak DynamoDB** — przy `use_lockfile = true` lock jest plikiem w S3, nie tabelą DynamoDB.
- Szczegóły: `docs/runbooks/iam-role-matrix.md` (wiersz „GitHub Actions (CI/CD)”); `docs/adr/ADR-0003-iam-role-strategy.md`.

## Powiązane dokumenty

- **Design sieci (W04):** `docs/lessons/W04-network-core-module-design.md`, `docs/lessons/W04-traffic-models.md`, `docs/lessons/W04-sg-nacl-baseline.md`
- **Smoke tests sieci:** `docs/runbooks/network-smoke-tests.md` — diagnostyka po deployu VPC
