## W02 — IAM: users vs roles vs policies vs trust

### Przeznaczenie
- Notatka dla senior .NET developera, który zna Azure AD / RBAC, ale chce precyzyjnie zrozumieć model uprawnień w AWS (IAM) pod kątem dalszych tygodni (Terraform, GitHub Actions, ECS, Lambda).

### Kluczowe fakty
- **IAM user** to tożsamość długoterminowa przypisana do osoby lub (historycznie) konta technicznego, która może mieć hasło do konsoli i/lub access keys.
- **IAM role** to tożsamość **do przyjmowania czasowo** (assume role) — nie ma własnych long-lived credentials, tylko działa w oparciu o tymczasowe sesje (STS).
- **Identity-based policy** (policy przypięta do usera/roli/grupy) opisuje, **co ta tożsamość może zrobić** (actions na resources).
- **Resource-based policy** (np. na S3, SQS, KMS) opisuje, **kto może coś zrobić na danym zasobie**.
- **Trust policy** roli to specjalny dokument JSON, który mówi **kto może przyjąć tę rolę** (principal) — nie definiuje uprawnień do zasobów.
- Uprawnienia końcowe to wynik ewaluacji: **principal (user/role) + wszystkie przypięte identity-based policies + resource-based policies + warunki (Condition)**.
- AWS STS (Security Token Service) wydaje **tymczasowe poświadczenia sesyjne** (session credentials) na podstawie trust policy i mechanizmu uwierzytelnienia (np. konsola, AWS CLI, OIDC z GitHub Actions).

---

### Jak to działa pod maską — model IAM

#### 1. IAM user
- Reprezentuje długotrwałą tożsamość w ramach jednego konta AWS:
  - może mieć login do konsoli AWS (hasło + MFA),
  - może mieć parę **access key ID / secret access key** do użycia przez CLI/SDK.
- Do usera przypinasz:
  - identity-based policies (bezpośrednio lub przez grupy),
  - opcjonalnie może on **assume role** (wejść w rolę), jeśli trust policy tej roli na to pozwala.
- W nowoczesnych projektach **odchodzi się od users z long-lived keys** na rzecz ról, SSO i federacji (Azure AD / IdP), ale users nadal istnieją (np. break-glass, legacy, bardzo proste konta dev).

#### 2. IAM role
- Rola nie ma hasła ani stałych access keys.
- Aby z niej skorzystać, **jakaś tożsamość musi ją przyjąć** („assume role”):
  - użytkownik/konto z tego samego konta AWS,
  - tożsamość federowana z zewnętrznego IdP (np. Azure AD, GitHub OIDC),
  - inna usługa AWS (np. ECS task execution role, Lambda execution role).
- Role mają:
  - **trust policy** — kto może wejść w rolę (principal),
  - **identity-based policies** — co posiadacz roli może zrobić (actions/resources/conditions).
- AWS STS na podstawie trust policy wydaje **tymczasowy token** (session credentials) z TTL (np. 15 minut, 1h, 12h), który jest używany przez CLI/SDK.

#### 3. Identity-based policy
- Dokument JSON przypięty **do tożsamości** (user, role, grupa).
- Składa się z:
  - `Effect` — `Allow` lub `Deny`,
  - `Action` — operacje (np. `s3:GetObject`, `sqs:SendMessage`),
  - `Resource` — na czym (ARN zasobu, `*`, wzorce),
  - `Condition` — dodatkowe warunki (np. IP, tagi, czas, źródło OIDC).
- AWS dla danego żądania:
  1. Zbiera wszystkie identity-based policies (user + grupy + rola, jeśli tożsamość jest w roli).
  2. Zbiera resource-based policies na zasobach, które są dotknięte żądaniem.
  3. Ewaluacja:
     - start: `implicit deny`,
     - jeśli jest **jakiekolwiek Allow** → potencjalnie dozwolone,
     - jeśli pojawi się jawne `Deny` → zawsze blokuje, niezależnie od innych `Allow`.

#### 4. Resource-based policy
- Przypięta **do zasobu**, np.:
  - S3 bucket policy,
  - SQS queue policy,
  - KMS key policy,
  - API Gateway resource policy.
- Zawiera:
  - `Principal` — kto może wywoływać operacje na tym zasobie,
  - `Action`, `Resource`, `Condition` (jak w identity-based).
- Typowe use-case:
  - zezwolenie innemu kontu AWS na dostęp do S3/SQS,
  - zezwolenie określonemu serwisowi (np. CloudFront, EventBridge) na publikację do SQS/SNS.

#### 5. Trust policy (rola)
- Trust policy to **specjalny przypadek resource-based policy**, który jest przypięty do roli IAM.
- Odpowiada na pytanie: **„kto może przyjąć tę rolę?”**
  - `Principal` — np. `sts.amazonaws.com` + warunek OIDC, inne konto AWS, serwis ECS/Lambda.
  - `Action` — zwykle `sts:AssumeRole` / `sts:AssumeRoleWithWebIdentity`.
  - `Condition` — np. dopasowanie `aud`/`sub` z tokena OIDC GitHuba, ograniczenia kont źródłowych.
- Trust policy **nie opisuje uprawnień do zasobów** — to robią identity-based policies przypięte do roli.

---

### Operacyjny flow — jak AWS decyduje „czy wolno”

Załóżmy, że:
- masz użytkownika (lub federowaną tożsamość), który wykonuje operację przez CLI/SDK,
- chcesz wykonać np. `s3:GetObject` na konkretnym buckecie.

Wysoki poziom działania:
1. **Uwierzytelnienie**:
   - albo bezpośrednio jako IAM user (access key + secret),
   - albo jako sesja z roli IAM (STS assume role, np. z GitHuba przez OIDC),
   - albo jako tożsamość usługi (Lambda/ECS z przypiętą execution role).
2. **Identyfikacja principal**:
   - AWS określa, jaka to tożsamość (ARN usera lub ARN roli + session name).
3. **Zebranie policies**:
   - wszystkie identity-based policies przypięte do usera/roli/grup,
   - resource-based policies na zasobach (np. S3 bucket policy).
4. **Ewaluacja**:
   - start: `implicit deny`,
   - sprawdzenie, czy istnieje jakiekolwiek `Allow` dla `[principal, action, resource]` spełniające `Condition`,
   - jeśli tak, sprawdzenie, czy gdziekolwiek istnieje `Deny` dla tego samego zestawu → `Deny` wygrywa.
5. **Decyzja**:
   - jeśli jest efektywne `Allow` bez nadpisującego `Deny` → operacja przechodzi,
   - w przeciwnym razie → `AccessDenied`.

Ważne:
- **Trust policy** bierze udział wcześniej (w momencie assume role), a nie przy każdym pojedynczym żądaniu do S3/SQS.
- Przy samym żądaniu do usługi liczą się już **identity-based policies roli** + resource-based policies zasobu.

---

### Typowe scenariusze: user vs role (w kontekście tego projektu)

#### Local developer
- W tym projekcie:
  - lokalny dev najpewniej korzysta z:
    - profilu CLI (`swpr-dev`) skonfigurowanego w W01,
    - lub w przyszłości z federacji (np. IdP → rola w AWS).
- Możliwe podejścia:
  - prostsze: IAM user `seba-dev` z przypiętą policy (kąt dev, ma dostęp do eksperymentów),
  - nowocześniejsze: użytkownik federowany (SSO) przyjmujący rolę `DeveloperRole`.
- Dla lokalnego dev istotne jest:
  - dobra widoczność, **z jakiej tożsamości** korzystasz (`aws sts get-caller-identity`),
  - jasne odseparowanie ról: np. rola „developer-eksperymentalna” vs rola „admin-infra”.

#### GitHub Actions (CI/CD)
- Nie chcemy long-lived keys w repo / secrets.
- Podejście OIDC-first:
  - workflow GHA uzyskuje token OIDC z GitHuba,
  - AWS STS na podstawie **trust policy roli** weryfikuje ten token (aud, sub, repo, branch),
  - jeśli warunki są spełnione → wystawia tymczasowe session credentials dla roli CI/CD.
- Tu kluczowe są:
  - **trust policy roli CI/CD** — dopuszcza tylko określone żądania OIDC z określonych repo/branchy,
  - **identity-based policies roli CI/CD** — ograniczają, co pipeline może modyfikować (np. tylko konkretny S3, tylko określone zasoby Terraform).

#### ECS task / Lambda execution
- Każdy workload (task ECS, funkcja Lambda) ma przypisaną **execution role**:
  - trust policy: pozwala ECS/Lambda na assume tej roli,
  - identity-based policies: opisują, do jakich zasobów workload ma dostęp (np. SQS, S3, DynamoDB).
- Kluczowy wzorzec:
  - **aplikacja nie ma własnych kluczy**, tylko korzysta z roli,
  - w kodzie .NET działa standardowa credential chain (SDK sam znajduje role credentials w środowisku).

---

### STS i sesje tymczasowe (wysoki poziom)

#### Po co STS
- Rozwiązuje problem:
  - jak dać aplikacji / sesji CLI uprawnienia **na ograniczony czas**,
  - bez generowania i ręcznego zarządzania long-lived keys.

#### Jak to działa w skrócie
- Klient (user, IdP, serwis) woła STS:
  - `AssumeRole`, `AssumeRoleWithWebIdentity`, `AssumeRoleWithSAML`, itp.
- STS:
  1. Sprawdza trust policy roli:
     - czy `Principal` i `Condition` dopuszczają tę tożsamość,
  2. Jeśli tak, generuje **tymczasowe poświadczenia**:
     - `AccessKeyId`, `SecretAccessKey`, `SessionToken`,
     - z określonym czasem życia (TTL).
- Klient używa tych danych do kolejnych wywołań API (np. S3, SQS) tak, jakby to był zwykły access key, ale:
  - są one ważne tylko przez określony czas,
  - są powiązane z konkretną rolą i kontekstem (session name, external id, itp.).

#### Różnica vs long-lived keys
- Long-lived keys:
  - żyją, dopóki ich nie skasujesz/nie zrotujesz,
  - łatwiej o wyciek, trudniej o rotację,
  - po wycieku atakujący ma długoterminowy dostęp.
- STS session credentials:
  - wygasają po TTL,
  - można je w razie potrzeby unieważnić przez zmianę trust/policies,
  - mniejszy blast radius w razie wycieku (szczególnie przy krótkim TTL).

---

### Pułapki / antywzorce (ważne dla W02)

- **Mylenie trust policy z permission policy**:
  - trust policy → „kto może wejść w rolę”,
  - identity-based policy roli → „co ta rola może zrobić po wejściu”.
- **Dawanie uprawnień userom zamiast rolom**:
  - w nowoczesnych projektach preferujemy:
    - tożsamości ludzkie → federacja/SSO + role,
    - tożsamości techniczne (aplikacje, CI/CD) → role z trust policy (STS/OIDC),
  - długoterminowy IAM user z szerokimi uprawnieniami to antywzorzec.
- **Zbyt szerokie policies (`"*"` wszędzie)**:
  - ułatwia start, ale utrudnia późniejsze cięcie uprawnień,
  - ciężko potem zbudować mentalny model „co kto może”.
- **Brak zrozumienia resource-based policies**:
  - łatwo przeoczyć, że dostęp jest nadany „od strony zasobu” (np. bucket policy),
  - debug staje się trudny: „dlaczego to działa / nie działa, mimo że rola wydaje się poprawna?”.
- **Mix wielu źródeł uprawnień**:
  - user ma policy A,
  - grupa ma policy B,
  - rola dodaje policy C,
  - zasób ma resource-based policy D,
  - trudniej wtedy ocenić efektywny zestaw uprawnień — trzeba patrzeć całościowo.

---

### Jak poznam, że rozumiem ten model (smoke test W02-T01)

Po tej notatce powinieneś być w stanie:
- Własnymi słowami wytłumaczyć:
  - różnicę między IAM user i IAM role,
  - różnicę między trust policy a permission policy,
  - jak STS wydaje tymczasowe poświadczenia i dlaczego to lepsze dla CI/CD niż long-lived keys.
- Odpowiedzieć na pytania:
  - z jakiej tożsamości korzystasz lokalnie (u Ciebie) i jak to zweryfikować (`aws sts get-caller-identity`),
  - jak pipeline GitHub Actions może uzyskać dostęp do AWS bez static keys,
  - jaką rolę będzie mieć ECS task / Lambda i co ją różni od usera.

---

### Dalej (co będzie wykorzystane w kolejnych taskach W02)

- **W02-T02** (matryca ról):
  - na podstawie tego modelu zdefiniujesz konkretne role:
    - dla local dev,
    - dla GitHub Actions (OIDC),
    - dla ECS task / Lambda.
  - potrzebujesz jasno rozdzielić: principal (trust) i permission scope (policies).
- **W02-T03** (brak long-lived keys w CI/CD):
  - wykorzystasz STS + OIDC i trust policy roli CI/CD,
  - zasada: żadnych access keys w secrets repo dla pipeline’ów.
- **W02-T04** (policy snippets):
  - zbudujesz minimalne, konkretne przykłady policies (S3 read-only, SQS producer),
  - przypiszesz je do ról z matrycy z W02-T02.

