# Dodanie uprawnień ECR push do roli GitHub Actions (OIDC)

## Przeznaczenie

Rola używana przez GitHub Actions (OIDC) do Terraform ma też obsłużyć **build i push obrazu catalog-api do ECR**. Ten runbook opisuje, jak dołączyć do tej roli politykę umożliwiającą push do repozytorium `catalog-api`.

**Rola:** ta sama, której ARN jest w zmiennej `AWS_GITHUB_ACTIONS_ROLE_ARN` (środowisko `dev`) — w runbooku Terraform OIDC nazywana `GitHubActionsRole`.

---

## Polityka

Plik **`docs/runbooks/iam-policy-github-actions-ecr-push.json`** zawiera politykę z:

- **ecr:GetAuthorizationToken** — wymagane do `docker login` do ECR (bez ograniczenia zasobu).
- Na repozytorium **catalog-api**:  
  `BatchCheckLayerAvailability`, `GetDownloadUrlForLayer`, `BatchGetImage`, `PutImage`, `InitiateLayerUpload`, `UploadLayerPart`, `CompleteLayerUpload`.

Jeśli Twoje konto AWS ma inne ID niż `292187657518`, w pliku JSON zamień ten identyfikator w `Resource` na własny.

---

## Sposób 1: Konsola AWS

1. Zaloguj się do AWS (konto dev).
2. IAM → **Roles** → wyszukaj rolę użytą przez GitHub (np. **GitHubActionsRole**).
3. Otwórz rolę → zakładka **Permissions** → **Add permissions** → **Create inline policy**.
4. Zakładka **JSON** → usuń domyślny fragment i wklej zawartość pliku **`iam-policy-github-actions-ecr-push.json`**.
5. **Next** → nazwa polityki np. **GitHubActionsECRPushCatalogApi** → **Create policy**.
6. Wróć do roli i upewnij się, że nowa polityka jest na liście (inline).

---

## Sposób 2: AWS CLI

Z katalogu głównego repo (gdzie jest `docs/runbooks/`):

```bash
# Nazwa roli — dostosuj, jeśli używasz innej (np. GitHubActionsTerraformDevRole)
ROLE_NAME="GitHubActionsRole"

# Dołączenie polityki inline do roli (użyj ścieżki do pliku)
aws iam put-role-policy \
  --role-name "$ROLE_NAME" \
  --policy-name "GitHubActionsECRPushCatalogApi" \
  --policy-document file://docs/runbooks/iam-policy-github-actions-ecr-push.json
```

Wymagane: skonfigurowany profil/kredensiale AWS z uprawnieniami `iam:PutRolePolicy` na tę rolę.

---

## Weryfikacja

1. W IAM → rola → **Permissions**: powinna być polityka (inline) **GitHubActionsECRPushCatalogApi**.
2. Uruchom workflow **catalog-api — Build & Push to ECR** (ręcznie lub przez push do `master` ze zmianą w `src/catalog-api/**`).
3. W logach workflowu krok **Push image to ECR** powinien zakończyć się sukcesem (brak `AccessDenied`).

---

## Pułapki

- **Inna nazwa roli** — jeśli w GitHub jest ustawiony ARN innej roli niż `GitHubActionsRole`, dołącz politykę do tej roli, której ARN jest w `vars.AWS_GITHUB_ACTIONS_ROLE_ARN`.
- **Inny region** — polityka w pliku jest na `eu-central-1`; przy innym regionie zmień w `Resource` w JSON.
- **Nowe repozytorium ECR** — dla kolejnych serwisów (np. orders-api) dodaj analogiczną politykę z osobnym `Resource` na `arn:aws:ecr:...:repository/orders-api` lub rozszerz listę zasobów.
