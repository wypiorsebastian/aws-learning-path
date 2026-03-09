## Runbook — codzienne sprzątanie środowiska dev

### Przeznaczenie
- Zbiór **praktycznych skryptów bash** do szybkiego sprzątania środowiska `dev` po sesji nauki:
  - App Runner (catalog-api),
  - obrazy w ECR,
  - logi CloudWatch (App Runner + Flow Logs).
- Nie rusza sieci tworzonej przez Terraform (`network-core`, `network-endpoints`) — to dalej robi `terraform destroy` / `terraform apply`.

### Założenia
- Konto: **dev**, region: **`eu-central-1`**.
- Profil AWS CLI: `swpr-dev` (z runbooka `aws-local-setup.md`).
- Serwis App Runner: `orderflow-dev-catalog-api`.
- Repozytorium ECR: `catalog-api` w koncie `292187657518`.

> **Uwaga — destrukcyjne:** Każda sekcja zawiera operacje usuwające zasoby / logi. Zawsze upewnij się, że działasz na właściwym koncie i regionie.

---

## 1. Ustawienie profilu i regionu

```bash
export AWS_PROFILE=swpr-dev
export AWS_REGION=eu-central-1
```

Możesz dodać to do `~/.bashrc` lub osobnego skryptu, jeśli używasz tego często.

---

## 2. App Runner — usunięcie serwisu catalog-api

> **Kiedy używać:** gdy chcesz przestać płacić za runtime App Runner i wyczyścić serwis, ale **nie** usuwać VPC / sieci.

### 2.1 Znajdź ARN serwisu

```bash
aws apprunner list-services \
  --region "$AWS_REGION" \
  --query "ServiceSummaryList[?ServiceName=='orderflow-dev-catalog-api'].ServiceArn" \
  --output text
```

Skopiuj wynik (ARN) do zmiennej:

```bash
export APPRUNNER_SERVICE_ARN="$(aws apprunner list-services \
  --region "$AWS_REGION" \
  --query \"ServiceSummaryList[?ServiceName=='orderflow-dev-catalog-api'].ServiceArn\" \
  --output text)"
echo "$APPRUNNER_SERVICE_ARN"
```

### 2.2 Usuń serwis

```bash
aws apprunner delete-service \
  --region "$AWS_REGION" \
  --service-arn "$APPRUNNER_SERVICE_ARN"
```

> **Efekt:** App Runner przestaje działać i nie nalicza kosztów compute. Przy kolejnym `terraform apply` serwis zostanie odtworzony z kodu.

---

## 3. ECR — usunięcie obrazów catalog-api (dev)

> **Kiedy używać:** gdy chcesz wyczyścić obrazy dev (np. po wielu eksperymentach). **Nie** usuwa repozytorium — tylko obrazy.

### 3.1 Lista obrazów

```bash
aws ecr list-images \
  --region "$AWS_REGION" \
  --repository-name catalog-api \
  --query 'imageIds[*]' \
  --output json
```

### 3.2 Usuń wszystkie obrazy (dev-only)

```bash
aws ecr batch-delete-image \
  --region "$AWS_REGION" \
  --repository-name catalog-api \
  --image-ids "$(aws ecr list-images \
    --region "$AWS_REGION" \
    --repository-name catalog-api \
    --query 'imageIds[*]' \
    --output json)"
```

> **Efekt:** repozytorium `catalog-api` zostaje, ale jest puste. Następny run workflowu `catalog-api — Build & Push to ECR` znów wypełni je obrazem.

---

## 4. CloudWatch Logs — logi App Runner (service + application)

> **Kiedy używać:** gdy logi App Runner zaśmiecają widok lub chcesz wyczyścić historię testów.

### 4.1 Znajdź log groupy App Runner

```bash
aws logs describe-log-groups \
  --region "$AWS_REGION" \
  --log-group-name-prefix "/aws/apprunner" \
  --query "logGroups[?contains(logGroupName, 'orderflow-dev-catalog-api')].logGroupName" \
  --output text
```

Zobaczysz zwykle dwa log groupy:

- `/aws/apprunner/orderflow-dev-catalog-api/<id>/service`
- `/aws/apprunner/orderflow-dev-catalog-api/<id>/application`

### 4.2 Usuń log groupy (dev-only)

```bash
for lg in $(aws logs describe-log-groups \
  --region "$AWS_REGION" \
  --log-group-name-prefix "/aws/apprunner/orderflow-dev-catalog-api" \
  --query "logGroups[].logGroupName" \
  --output text); do
  echo "Deleting log group: $lg"
  aws logs delete-log-group --region "$AWS_REGION" --log-group-name "$lg"
done
```

> **Efekt:** kasujesz historię logów. Przy następnym deployu App Runner utworzy log groupy ponownie.

---

## 5. CloudWatch Logs — Flow Logs VPC (tylko logi)

> **Ważne:** same Flow Logs (zasób `aws_flow_log`) są definiowane w Terraform w module `network-endpoints`.  
> **Nie usuwamy zasobu Terraform** tym skryptem — tylko **log groupy** w CloudWatch, żeby wyczyścić historię / ograniczyć clutter.

### 5.1 Znajdź log groupy Flow Logs

Typowe nazwy (zależnie od konfiguracji modułu): zaczynają się od `/aws/vpc-flow-logs/` albo zawierają `orderflow-dev-vpc-flow-logs`.

```bash
aws logs describe-log-groups \
  --region "$AWS_REGION" \
  --log-group-name-prefix "/aws/vpc-flow-logs" \
  --query "logGroups[].logGroupName" \
  --output text
```

Jeśli użyłeś innego prefixu w module, wyszukaj po fragmencie:

```bash
aws logs describe-log-groups \
  --region "$AWS_REGION" \
  --log-group-name-prefix "/" \
  --query "logGroups[?contains(logGroupName, 'orderflow-dev') && contains(logGroupName, 'flow')].logGroupName" \
  --output text
```

### 5.2 Usuń log groupy Flow Logs (tylko logi)

```bash
for lg in $(aws logs describe-log-groups \
  --region "$AWS_REGION" \
  --log-group-name-prefix "/aws/vpc-flow-logs" \
  --query "logGroups[].logGroupName" \
  --output text); do
  echo "Deleting Flow Logs log group: $lg"
  aws logs delete-log-group --region "$AWS_REGION" --log-group-name "$lg"
done
```

> **Efekt:** kasujesz dotychczasowe logi Flow Logs. Sam zasób `aws_flow_log` nadal istnieje; przy kolejnym ruchu w VPC CloudWatch utworzy log groupy ponownie (jeśli tak jest skonfigurowany).

---

## 6. Pełne zniszczenie środowiska dev (opcjonalne)

> To **nie jest** codzienny krok, ale dla porządku:

Jeśli chcesz zniszczyć całą infrastrukturę dev (VPC, subnety, endpoints, itp.), użyj Terraform:

```bash
export AWS_PROFILE=swpr-dev
export AWS_REGION=eu-central-1

cd infra/terraform/envs/dev
terraform init -backend-config=backend.dev.hcl
terraform destroy
```

> **Uwaga:** to usuwa całą sieć dev. Zwykle w tygodniach kursu zamiast `destroy` korzystamy z runbooka powyżej, żeby sprzątać tylko warstwę aplikacyjną i logi.

