## Struktura katalogów Terraform

- **`infra/terraform/modules/*`** – moduły współdzielone:
  - zawierają wyłącznie logikę zasobów,
  - nie wiedzą, w jakim środowisku są używane (parametry przychodzą z `envs/*`),
  - mogą być użyte wielokrotnie w różnych rootach.

- **`infra/terraform/envs/<env>`** – root per środowisko (np. `dev`, w przyszłości `stage`, `prod`):
  - opisują konkretne środowisko (region, prefix nazw, parametry modułów),
  - nie zawierają „gołych” zasobów AWS, które mogłyby być modułami.


## Konwencja plików w `envs/<env>`

W każdym katalogu środowiska przyjmujemy prosty szkielet:

- `main.tf` – root:
  - konfiguracja providera (`aws`),
  - `locals` (np. `name_prefix`),
  - wywołania modułów z `infra/terraform/modules/*`.
- `variables.tf` – deklaracje zmiennych środowiska (np. `region`).
- (opcjonalnie) `backend.<env>.hcl` / `backend.ci.hcl` – konfiguracja backendu na potrzeby CI.


## Zasada „root per env, logika w modułach”

- Cała „ciężka” logika (`aws_*`, złożone zależności) żyje w modułach w `modules/*`.
- Root w `envs/<env>`:
  - konfiguruje środowisko (region, prefix, parametry),
  - instancjonuje moduły, przekazując im wartości,
  - dzięki temu można łatwo dodać kolejne środowisko, kopiując strukturę `dev` i zmieniając tylko wartości (`name_prefix`, `region`, itp.).


## Przykład: `envs/dev/main.tf`

W środowisku `dev` root:

- ustawia provider z `var.region`,
- definiuje `local.name_prefix = "orderflow-dev"`,
- używa modułów:
  - `modules/network-core` – sieć bazowa (VPC, subnety, NAT, trasy),
  - `modules/network-endpoints` – endpointy VPC + flow logs,
  - `modules/ecr` – repozytoria obrazów (`catalog-api`, `orders-api`),
  - `modules/apprunner` – serwis App Runner dla `catalog-api`.

Dzięki temu kolejne środowisko (np. `stage`) będzie mogło:

- skopiować strukturę `main.tf` z `dev`,
- zmienić tylko:
  - `local.name_prefix` (np. na `orderflow-stage`),
  - wartości zmiennych (np. `region`, rozmiary/limity),
- zachowując te same moduły i ten sam workflow Terraform.


## Szkielet dla kolejnych środowisk (`stage`, `prod`)

Dla nowych environmentów trzymamy ten sam układ katalogów i plików jak w `dev`:

```text
infra/terraform/envs/
  dev/
    main.tf
    variables.tf
    versions.tf
    backend.tf
    outputs.tf
  stage/
    main.tf
    variables.tf
    versions.tf
    backend.tf
    outputs.tf
  prod/
    main.tf
    variables.tf
    versions.tf
    backend.tf
    outputs.tf
```

- **`main.tf` (stage/prod)**:
  - kopia struktury z `dev`,
  - inny `local.name_prefix` (np. `orderflow-stage`, `orderflow-prod`),
  - ewentualnie inne wartości parametrów modułów (np. `desired_count`, rozmiary itp.).
- **`variables.tf`**:
  - przynajmniej `variable "region"` (`default` może być inny niż w `dev`, albo w ogóle bez default).
- **`versions.tf`**:
  - zwykle identyczne jak w `dev` (te same wersje Terraform i providera).
- **`backend.tf`**:
  - wspólna definicja backendu `s3` (bez twardych wartości),
  - konkretne `bucket`/`key`/`region` dostarczane z pliku backend.<env>.hcl lub backend.ci.hcl.
- **`outputs.tf`**:
  - export tylko tych wartości modułów, które są potrzebne z zewnątrz (URL‑e, ID zasobów itp.).

Konwencja backendów (przykład dla CI/GitHub Actions):

- `dev` używa klucza stanu `key = "dev/terraform.tfstate"`,
- `stage` będzie używać `key = "stage/terraform.tfstate"`,
- `prod` będzie używać `key = "prod/terraform.tfstate"`.

Workflowy Terraform w CI mogą być rozszerzane przez:

- ustawienie `TF_WORKING_DIR` na odpowiedni katalog (`infra/terraform/envs/stage`, `infra/terraform/envs/prod`),
- zapis odpowiedniego `backend.ci.hcl` z właściwym `key`.

