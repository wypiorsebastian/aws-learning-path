# Runbook — matryca ról IAM dla OrderFlow AWS Lab

## Przeznaczenie

- Ten dokument jest **źródłem prawdy** dla ról IAM używanych w projekcie OrderFlow AWS Lab:
  - kto (principal) korzysta z jakiej roli,
  - kto może przyjąć daną rolę (trust),
  - jaki jest zakres uprawnień (permission scope),
  - w jakim kontekście rola jest używana (usage).
- Adresat: developer i przyszły maintainer projektu; służy do projektowania policies, debugowania dostępu i zachowania least privilege.
- Powiązane: `docs/lessons/W02-iam-users-roles-policies-trust.md`, `docs/adr/ADR-0003-iam-role-strategy.md`.

---

## Matryca ról

| Principal / Rola (koncepcyjna) | Trust (kto może przyjąć rolę) | Permission scope (high-level) | Usage |
|--------------------------------|-------------------------------|-------------------------------|--------|
| **Local developer** | IAM user (lub w przyszłości federacja/SSO) — tożsamość ludzka z konta `swpr-dev`. | Szeroki dostęp dev: konsola, CLI, Terraform (odczyt/zapis stanu, zarządzanie zasobami w dev), ECR, CloudWatch, IAM (odczyt/limitowany zapis). W praktyce: to, czego potrzebuje jedna osoba do nauki i operacji na jednym koncie dev. | Praca lokalna: `aws` CLI z profilem `swpr-dev`, ręczny `terraform plan/apply`, debug w konsoli, eksperymenty. |
| **GitHub Actions (CI/CD)** | OIDC: tylko token z GitHub Actions dla **konkretnego repo** (i opcjonalnie branch, np. `main`). Principal: `sts.amazonaws.com` + Condition na `token.actions.githubusercontent.com`, claim `sub` (repo, branch). | Least privilege pod Terraform: S3 (bucket stanu: get/put/delete obiektów), DynamoDB (tabela locków stanu — jeśli używana), operacje na zasobach zarządzanych przez Terraform w dev (ECR, ECS, IAM, VPC itd.). Brak dostępu do zasobów poza zakresem pipeline’u. | Workflowy GitHub Actions: `terraform plan` na PR, `terraform apply` na merge do main (lub manual dispatch). Żadnych long-lived keys w secrets. |
| **ECS task role** (np. `order-flow-ecs-task-role`) | Serwis ECS: `ecs-tasks.amazonaws.com` (Fargate) z warunkiem `SourceArn` na klaster ECS. Trust: tylko ECS może assume tej roli dla uruchomionych tasków. | Dostęp aplikacji w kontenerze: SQS (SendMessage, ReceiveMessage, DeleteMessage — kolejki OrderFlow), S3 (GetObject, PutObject), RDS (via SG; credentials z Secrets Manager/SSM — rola do odczytu secretów), CloudWatch Logs (PutLogEvents), ewentualnie SNS/EventBridge. Można rozdzielić role per serwis (orders-api, order-worker) dla least privilege. | Uruchomione taski ECS Fargate: aplikacje .NET (orders-api, payments-api, catalog-api, order-worker); SDK używa credential chain z metadanych taska. |
| **Lambda execution role** (np. `order-flow-lambda-payment-callback`) | Serwis Lambda: `lambda.amazonaws.com` z warunkiem `SourceArn` na funkcję. Trust: tylko ta funkcja Lambda może używać roli. | Minimum pod funkcję: CloudWatch Logs (PutLogEvents), ewentualnie SQS/SNS/DynamoDB jeśli callback ich używa. Dla `payment-callback`: typowo logs + ewentualnie zapis do DynamoDB lub SQS. | Funkcja Lambda `payment-callback` (.NET 10) za API Gateway; rola przypisana jako execution role. |

---

## Uproszczenia dev-only

- **Jedno konto, jeden region:** wszystkie role są w koncie `swpr-dev`, region przyjęty dla projektu (np. `eu-central-1`).
- **Local developer:** nie rozdzielamy na tym etapie ról „read-only” vs „write” — jedna tożsamość dev ma szeroki zakres pod naukę i operacje.
- **ECS:** można zacząć od jednej roli task wspólnej dla wszystkich serwisów; przy wzroście złożoności warto rozdzielić role per serwis (np. order-worker: SQS + S3; API: SQS + RDS + S3).
- **Trust policy vs permission policy:** w matrycy „Trust” opisuje, **kto może wejść w rolę**; „Permission scope” to **co rola może zrobić** (identity-based policies przypięte do roli).

---

## Jak to sprawdzić

- **Local developer:** `aws sts get-caller-identity --profile swpr-dev` — zwraca ARN usera lub assumed-role; potwierdza, z jakiej tożsamości korzystasz.
- **GitHub Actions:** udany run workflow z krokiem assume-role (OIDC); w logach widać, że job używa credentials z roli CI/CD.
- **ECS task:** aplikacja w kontenerze wywołuje AWS API (np. SQS, S3); brak błędów `AccessDenied` przy operacjach objętych permission scope roli.
- **Lambda:** funkcja wykonuje się bez błędów IAM przy dostępie do dozwolonych zasobów (logi, DynamoDB, SQS — w zależności od policy).

---

## Pułapki

- **Mylenie trust policy z permission policy:** trust = „kto może przyjąć rolę”; permission = „co rola może zrobić”. Oba są potrzebne i muszą być spójne.
- **Zbyt szeroka trust policy (OIDC):** np. dopuszczenie dowolnego repo lub branch zwiększa blast radius przy wycieku tokena; zawęź do konkretnego repo i (opcjonalnie) branchy.
- **Jedna rola ECS dla wszystkiego:** na start OK w dev; przy wielu serwisach lepiej role per serwis, żeby ograniczyć skutki kompromitacji jednego komponentu.
