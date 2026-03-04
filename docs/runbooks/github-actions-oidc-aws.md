# GitHub Actions ↔ AWS OIDC — konfiguracja krok po kroku

## Przeznaczenie

Instrukcja krok po kroku, jak skonfigurować **zaufanie OIDC pomiędzy GitHub Actions a AWS**:
- po stronie **AWS**: Identity Provider + rola IAM z trust policy,
- po stronie **GitHub**: repozytorium przygotowane do używania OIDC (bez statycznych kluczy).

Docelowy use-case: pipeline Terraform (plan/apply) z W08, ale instrukcja jest ogólna i nadaje się też pod inne joby CI.

---

## Kluczowe fakty

- GitHub Actions nie przechowuje access key/secret — zamiast tego wystawia **token OIDC**, który AWS może zweryfikować.
- W AWS konfigurujemy:
  - **Identity Provider** (`https://token.actions.githubusercontent.com`),
  - **rolę IAM**, która ufa temu providerowi tylko dla **konkretnych repo/branchy**.
- GitHub Actions musi:
  - mieć w jobie **permissions: `id-token`** (co najmniej `read`/`write`),
  - zawołać AWS STS (`AssumeRoleWithWebIdentity`) z otrzymanym tokenem OIDC.
- Bez poprawnej **trust policy** (warunki na `aud`/`sub`) AWS po cichu odrzuci żądanie i nie przydzieli tymczasowych poświadczeń.

---

## Jak to działa pod maską (wysoki poziom)

1. Job GitHub Actions startuje i (jeśli ma permissions) pobiera **token OIDC** z `token.actions.githubusercontent.com`.
2. Job woła AWS STS `AssumeRoleWithWebIdentity`, przekazując:
   - token OIDC,
   - ARN roli IAM w AWS.
3. AWS:
   - weryfikuje podpis i ważność tokenu,
   - sprawdza, czy `iss`, `aud` i `sub` z tokenu pasują do **trust policy** roli,
   - jeśli tak → zwraca **tymczasowe klucze** (`AccessKeyId`, `SecretAccessKey`, `SessionToken`) powiązane z rolą.
4. W ramach tej sesji job może wykonywać operacje w AWS zgodne z **policy uprawnień** roli (np. S3, Terraform, itp.).

---

## Operacyjny flow — skrót

1. Zebrać dane o repo i środowisku.
2. Skonfigurować w AWS:
   - Identity Provider OIDC (jeśli jeszcze nie istnieje),
   - rolę IAM z odpowiednią trust policy + policy uprawnień.
3. Skonfigurować w GitHub:
   - upewnić się, że repo ma odpowiednie uprawnienia dla jobów,
   - przygotować workflow (później) z permissions `id-token` i użyciem roli.
4. Przetestować połączenie:
   - prosty job, który wywoła `sts:GetCallerIdentity` i pokaże, jaką rolę faktycznie przyjął.

Poniżej szczegółowe kroki.

---

## 1. Prerekwizyty i dane wejściowe

Przed startem przygotuj:

- **AWS:**
  - konto dev, w którym będą działać pipeline’y,
  - uprawnienia do zarządzania IAM (tworzenie Identity Provider i ról).
- **GitHub:**
  - nazwę **owner** (organizacja lub użytkownik),
  - nazwę **repo**,
  - docelową **gałąź** (np. `main`), na której będą joby `plan/apply`,
  - informację, czy workflow ma działać też na PR (inne wartości `sub`).

Zapisz sobie w notatce:

- `OWNER`: np. `wypiorsebastian`,
- `REPO`: np. `aws-learning-path`,
- docelowe gałęzie: np. `main`, ewentualnie patterny dla PR.

---

## 2. Konfiguracja AWS — Identity Provider OIDC

### 2.1. Sprawdź, czy provider już istnieje

1. Wejdź w AWS Console → usługę **IAM**.
2. W menu po lewej wybierz **Identity providers**.
3. Sprawdź, czy jest provider z:
   - **Type:** `OpenID Connect`,
   - **Provider URL / Issuer:** `https://token.actions.githubusercontent.com`.
4. Jeśli taki provider istnieje i jest używany przez inne role:
   - zanotuj jego **ARN**,
   - upewnij się, że niczego nie kasujesz ani nie nadpisujesz.

### 2.2. Utwórz provider, jeśli go nie ma

Jeśli nie ma providera dla GitHub:

1. W IAM → **Identity providers** kliknij **Add provider**.
2. Ustaw:
   - **Provider type:** `OpenID Connect`,
   - **Provider URL:** `https://token.actions.githubusercontent.com`,
   - **Audience:** `sts.amazonaws.com` (najczęstsze ustawienie używane przez GitHub).
3. Zatwierdź utworzenie providera.
4. Zanotuj:
   - nazwę providera,
   - jego ARN.

Przykładowy snippet AWS CLI (tworzenie providera — wartości wypełnij zgodnie z aktualną konfiguracją i dokumentacją AWS/GitHub):

```bash
aws iam create-open-id-connect-provider \
  --url "https://token.actions.githubusercontent.com" \
  --client-id-list "sts.amazonaws.com" \
  --thumbprint-list "THUMBPRINT_Z_DOKUMENTACJI" \
  --tags Key=Name,Value="github-oidc-provider"
```

Gdzie:
- `THUMBPRINT_Z_DOKUMENTACJI` — aktualny odcisk certyfikatu root CA używanego przez `token.actions.githubusercontent.com` (sprawdź w dokumentacji AWS dla GitHub OIDC; wartości mogą się zmieniać w czasie),
- tag `Name` jest opcjonalny, ale pomaga w identyfikacji providera.

---

## 3. Konfiguracja AWS — rola IAM dla GitHub Actions

### 3.1. Zaprojektuj, kto ma móc przyjąć rolę (trust policy)

Musisz określić:

- **które joby** z GitHub Actions będą mogły użyć roli:
  - jakie **repo**,
  - jaka **gałąź** (np. tylko `main` i/lub PR),
  - czy ograniczasz do konkretnych eventów (PR/push).

Standardowo używa się claimu **`sub`** z tokenu OIDC, który GitHub ustawia wg wzorca:

- dla PR: mniej więcej `repo:OWNER/REPO:pull_request`,
- dla push na gałąź: `repo:OWNER/REPO:ref:refs/heads/main`.

W trust policy chcesz dążyć do warunków typu:

- `iss` = `https://token.actions.githubusercontent.com`,
- `aud` = `sts.amazonaws.com`,
- `sub` = dopasowane do Twojego repo i gałęzi (np. `repo:OWNER/REPO:ref:refs/heads/main`).

### 3.2. Utwórz rolę IAM

1. W IAM przejdź do **Roles** → **Create role**.
2. W **Trusted entity type** wybierz:
   - `Web identity`,
   - jako provider wybierz utworzony wcześniej provider OIDC (GitHub).
3. W **Audience** wybierz `sts.amazonaws.com`.
4. W części **Permissions**:
   - na razie możesz:
     - dołączyć tymczasowo szersze uprawnienia do testów (np. read-only na konto),
     - docelowo ograniczyć do:
       - dostępu do bucketu S3 z Terraform state,
       - zasobów zarządzanych przez Terraform w dev.
5. Nazwij rolę czytelnie, np. `GitHubActionsTerraformDevRole`.
6. Utwórz rolę.

Przykładowy snippet AWS CLI (tworzenie roli z trust policy trzymaną w osobnym pliku):

1. Przygotuj plik `trust-policy.json` z zaufaniem do GitHub Actions dla wybranego repo/gałęzi:

```bash
cat > trust-policy.json << 'EOF'
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "arn:aws:iam::ACCOUNT_ID:oidc-provider/token.actions.githubusercontent.com"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "token.actions.githubusercontent.com:aud": "sts.amazonaws.com"
        },
        "StringLike": {
          "token.actions.githubusercontent.com:sub": [
            "repo:OWNER/REPO:ref:refs/heads/main",
            "repo:OWNER/REPO:pull_request"
          ]
        }
      }
    }
  ]
}
EOF
```

2. Utwórz rolę na podstawie tej trust policy:

```bash
aws iam create-role \
  --role-name "GitHubActionsTerraformDevRole" \
  --assume-role-policy-document file://trust-policy.json
```

Gdzie:
- `ACCOUNT_ID` — ID Twojego konta AWS (bez myślników),
- `OWNER` / `REPO` — odpowiadają wartościom z GitHub (np. `wypiorsebastian` / `aws-learning-path`),
- listę wartości `sub` możesz zawęzić/rozszerzyć (np. tylko `main`, tylko PR) zgodnie z polityką bezpieczeństwa.

### 3.3. Dostosuj trust policy ręcznie

Po utworzeniu roli:

1. Wejdź w szczegóły roli → zakładka **Trust relationships**.
2. Edytuj trust policy tak, aby:
   - `Principal` wskazywał na Twój provider OIDC,
   - w `Condition` były warunki:
     - `StringEquals` dla `token.actions.githubusercontent.com:aud` = `sts.amazonaws.com`,
     - `StringLike` lub `StringEquals` dla `token.actions.githubusercontent.com:sub` dopasowujące:
       - np. dla `main`: `repo:OWNER/REPO:ref:refs/heads/main`,
       - opcjonalnie dla PR: `repo:OWNER/REPO:pull_request`.
3. Zapisz zmiany.

Na tym etapie rola:
- **ufa** tylko tokenom z GitHub Actions z Twojego repo (i ewentualnie wybranych gałęzi),
- może być użyta przez STS `AssumeRoleWithWebIdentity`.

### 3.4. Dostosuj policy uprawnień (least privilege)

1. W zakładce **Permissions** roli dodaj/edytuj:
   - osobną policy dla dostępu do:
     - bucketu S3 z backendem Terraform (akcje typu `GetObject`, `PutObject`, `ListBucket`),
     - zasobów VPC / network, którymi zarządza Terraform (akcje `ec2:*` zawężone do potrzeb).
2. Na początek możesz zacząć od nieco szerszego zakresu (ale nadal nie-admin), a potem zawężać po tym, jak zobaczysz realne błędy „AccessDenied” w logach Terraform.

Zanotuj ARN roli — będzie potrzebny w konfiguracji workflow GitHub.

---

## 4. Konfiguracja GitHub — przygotowanie repo do OIDC

Na tym etapie **nie tworzymy jeszcze pełnego workflow Terraform** (to część W08-T02/T03). Chodzi o upewnienie się, że repo potrafi pobrać token OIDC i użyć roli.

### 4.1. Uprawnienia workflowów (repo-level)

1. Wejdź w GitHub → Twoje repo.
2. Przejdź do **Settings** → **Actions** → **General**.
3. W sekcji **Workflow permissions**:
   - zapewnij, że workflowy mają co najmniej:
     - `Read and write permissions` (lub skonfiguruj per-workflow),
     - zaznaczoną opcję, która pozwala na używanie **OIDC** (w nowszym UI: „Allow GitHub Actions to create and use OIDC tokens” lub podobny toggle).

(Dokładne nazwy mogą się nieco różnić w czasie, ale szukaj opcji związanych z **OIDC tokens** w sekcji Actions).

### 4.2. Przygotowanie prostego workflow testowego (wysoki poziom)

W ramach W08-T01 warto mieć **tymczasowy workflow testowy**, który:

- ma ustawione permissions:
  - `id-token: write`,
  - `contents: read`.
- w jobie:
  - pobiera token OIDC,
  - wywołuje `AssumeRoleWithWebIdentity` na Twojej roli,
  - wykonuje np. `sts:GetCallerIdentity` i wypisuje wynik w logach.

Ponieważ w tym tygodniu **nie generujemy jeszcze konkretnego YAML workflow**, trzymaj się następującego wzorca konfiguracyjnego (do ręcznego użycia przy tworzeniu workflowu):

- w sekcji **permissions** joba ustaw:
  - `id-token: write`,
  - `contents: read`.
- w kroku konfigurującym AWS użyj:
  - ARN roli, którą utworzyłeś w AWS,
  - region konta dev,
  - standardowy mechanizm OIDC (np. akcję `aws-actions/configure-aws-credentials` lub własny skrypt).

Szczegółowy YAML dla Terraform powstanie w taskach **W08-T02 / W08-T03**.

---

## 5. Test połączenia — sprawdzenie, że OIDC działa

Gdy masz:
- skonfigurowany Identity Provider w AWS,
- rolę IAM z poprawną trust policy,
- prosty workflow testowy z permissions `id-token`,

wykonaj test:

1. Uruchom workflow testowy (np. na `workflow_dispatch` albo push do testowej gałęzi).
2. Poczekaj na wykonanie joba.
3. Wejdź w logi joba i sprawdź:
   - czy krok konfigurujący AWS nie rzuca błędów `AccessDenied` / `InvalidIdentityToken`,
   - wynik `sts:GetCallerIdentity` — powinien pokazywać ARN **Twojej roli**, nie użytkownika IAM.
4. Jeśli pojawiają się błędy:
   - **InvalidIdentityToken** → sprawdź `iss` i `aud` w trust policy,
   - **AccessDenied**/`AccessDeniedException` w STS → sprawdź `sub` w trust policy (czy dopasowuje repo/gałąź),
   - błędy dostępu do zasobów AWS (np. S3) → doprecyzuj policy uprawnień roli.

Po udanym teście możesz przejść do kolejnych tasków W08:
- **W08-T02** — workflow `terraform plan` na PR,
- **W08-T03** — workflow `terraform apply` na `main` / manualny gate.

---

## Pułapki

- **Niedopasowany `sub`** — najczęstszy problem; jeśli w trust policy wpiszesz inny wzorzec niż to, co GitHub realnie wysyła, STS po prostu odrzuci token.
- **Brak `id-token` w permissions joba** — bez tego GitHub nie wystawi tokenu OIDC, nawet jeśli wszystko w AWS jest poprawne.
- **Zbyt szeroka trust policy** — kuszące jest wpisanie patternu dopuszczającego „wszystko”; unikaj tego w środowiskach, gdzie ważne jest bezpieczeństwo.
- **Zbyt wąskie permissions w policy** — Terraform lub inne narzędzia mogą zgłaszać `AccessDenied`; traktuj to jako sygnał do precyzyjnego doprecyzowania policy, zamiast dodawać admina.

