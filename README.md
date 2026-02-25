# OrderFlow AWS Lab

## Cel projektu

OrderFlow AWS Lab to projekt szkoleniowy dla doświadczonego developera .NET, który zna już Azure i chce w praktyczny sposób wejść w świat AWS. Zamiast oderwanych przykładów budujemy jeden spójny system e‑commerce (orders + payments), na którym przećwiczymy kluczowe usługi AWS, IaC oraz CI/CD.

Celem projektu jest:
- zrozumienie, jak projektować i wdrażać aplikacje .NET (obecnie target `net10.0`) w AWS,
- zbudowanie portfolio‑ready repozytorium, które można pokazać na rozmowie technicznej,
- rozszerzenie profilu w stronę DevOps / Cloud Engineer (Terraform, GitHub Actions, observability, security).

## Dla kogo jest ten projekt

Repo jest zaprojektowane dla:
- **senior .NET developera** (C# / .NET 10+),
- który ma już doświadczenie z chmurą (np. Azure),
- i chce świadomie przenieść swoje kompetencje na AWS, bez „kursu od zera”.

Założenia:
- pracujemy w trybie **dev‑only** (świadome ograniczanie kosztów),
- kładziemy duży nacisk na **infrastrukturę, bezpieczeństwo, networking i operacyjność**, a nie tylko na sam kod aplikacyjny.

## Zakres techniczny (wysoki poziom)

Projekt obejmuje praktyczną pracę z:

- **AWS**
  - IAM, KMS, Secrets Manager, SSM Parameter Store
  - VPC, subnety, routing, NAT, SG, NACL, VPC Endpoints / PrivateLink
  - Hosting .NET: App Runner, Elastic Beanstalk, ECS Fargate, Lambda + API Gateway
  - S3, RDS PostgreSQL, DynamoDB
  - SQS, SNS, EventBridge
  - CloudWatch (logs, metrics, alarms), CloudTrail (awareness)

- **.NET 10**
  - kilka usług Web API (`orders-api`, `payments-api`, `catalog-api`),
  - worker do przetwarzania asynchronicznego (`order-worker`),
  - Lambda `.NET 10` do obsługi callbacków płatności,
  - health endpointy, structured logging, podstawy observability.

- **IaC / CI-CD**
  - Terraform (modularna struktura `modules/` + `envs/dev/`),
  - GitHub Actions z OIDC do AWS (bez statycznych kluczy),
  - pipeline’y:
    - IaC (`plan` + `apply`),
    - build/push obrazów do ECR,
    - deploy ECS / Lambdy.

## Architektura / komponenty — szkic

Docelowo repo będzie zawierać m.in.:

- `src/orders-api` – API do obsługi zamówień,
- `src/payments-api` – API powiązane z płatnościami,
- `src/catalog-api` – prosty katalog produktów,
- `src/workers/order-worker` – worker do asynchronicznego przetwarzania zamówień,
- `src/lambdas/payment-callback` – Lambda do obsługi callbacków płatniczych,
- `infra/terraform` – moduły infrastruktury (VPC, ECS, RDS, S3, kolejki, itp.),
- `.github/workflows` – pipeline’y CI/CD,
- `docs/*` – roadmapa, tygodniowe podsumowania, ADR, runbooki, troubleshooting.

Szczegółowa struktura będzie rozwijana stopniowo, tydzień po tygodniu, zgodnie z roadmapą.

## Jak używać tego repo w trakcie kursu

Głównym źródłem prawdy jest roadmapa:

- `docs/roadmap/aws-course-roadmap-operational-0-24.md`

Każdy tydzień (`W00`–`W24`) ma swoje artefakty w:

- `docs/weekly/Wxx/` (plan, taski, log, evidence, pytania, summary),

Dzienna praca odbywa się w rytmie:

- **Wybierz tydzień** (np. `W03`), odczytaj jego sekcję z roadmapy.
- **Pracuj w cyklu**: plan sesji (D1–D5) → implementacja → weryfikacja (smoke tests) → notatki (lessons, troubleshooting).
- **Zapisuj decyzje** w ADR (`docs/adr/*`) i runbookach (`docs/runbooks/*`), żeby repo było gotowe jako materiał na rozmowę techniczną.

Tydzień `W00` (ten, od którego zaczynasz) skupia się na:
- zdefiniowaniu projektu i kontekstu w `README.md`,
- przygotowaniu szablonów dokumentacji (lessons, troubleshooting),
- utworzeniu szkicu solution `.NET 10`,
- zdefiniowaniu zakresu kursu w pierwszym ADR.

