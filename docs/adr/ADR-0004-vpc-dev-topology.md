# ADR-0004 — Topologia VPC dev i strategia NAT

- **Status:** Proposed  
- **Data:** 2026-02-26  
- **Kontekst:** Projekt `OrderFlow AWS Lab` w środowisku `dev-only` na koncie `swpr-dev` (region `eu-central-1`), zgodnie z ADR-0001 (zakres kursu) i ADR-0002 (cost guardrails).

---

## 1. Kontekst

- VPC dev:
  - CIDR: `10.0.0.0/16`,
  - min. 2 AZ: `eu-central-1a`, `eu-central-1b`,
  - subnety:
    - public-a: `10.0.1.0/24` (eu-central-1a),
    - public-b: `10.0.2.0/24` (eu-central-1b),
    - private-a: `10.0.11.0/24` (eu-central-1a),
    - private-b: `10.0.12.0/24` (eu-central-1b).
- Komponenty:
  - ALB (publiczny ingress) w `public-a`/`public-b`,
  - ECS Fargate (API/worker) w `private-a`/`private-b`,
  - RDS PostgreSQL w `private-a`/`private-b`,
  - Lambda `payment-callback` w VPC (private-a/b),
  - VPC Endpoints:
    - Gateway: S3, DynamoDB,
    - Interface: Secrets Manager, SSM Parameter Store.
- Guardrails kosztowe (ADR-0002):
  - środowisko jest **dev-only**, bez SLA/HA produkcyjnego,
  - drogie zasoby mają być **efemeryczne** (stawiane na czas ćwiczeń, potem niszczone),
  - VPC dev jest **stałym szkieletem**; moduły dla NAT/RDS/ECS mają być włączane/wyłączane IaC.

W tym kontekście trzeba zdecydować o **strategii NAT Gateway**: jeden NAT vs NAT per AZ.

---

## 2. Problem / drivery decyzji

Chcemy:
- mieć **realistyczny model sieci** pod ECS/RDS/Lambdę w private subnetach,
- zrozumieć typowy kompromis koszt vs HA przy NAT Gateway,
- jednocześnie:
  - **nie przepalić budżetu** dev (ADR-0002),
  - zachować możliwość łatwego „przeskalowania” do wariantu produkcyjnego w przyszłości.

Kluczowe drivery:
- **Koszt stały NAT Gateway** (płatny godzinowo, niezależnie od ruchu).
- **Dostępność / HA**:
  - NAT w jednej AZ = potencjalny SPOF dla ruchu wychodzącego z private w innej AZ,
  - NAT w każdej AZ = brak cross-AZ hopów, lepsza dostępność i mniejsze opóźnienia.
- **Złożoność IaC**:
  - więcej NAT = bardziej złożone moduły, więcej route tables/association,
  - dla dev chcemy prosty, czytelny design.

---

## 3. Opcje

### Opcja A — Jeden NAT Gateway (jedna AZ)

- Architektura:
  - 1 × NAT Gateway, np. w `public-a` (eu-central-1a),
  - private subnety w obu AZ kierują ruch „do Internetu” przez ten jeden NAT (cross-AZ dla private-b).
- Zalety:
  - niższy koszt stały (płacimy za 1 NAT, nie 2),
  - prostsza implementacja (mniej modułów/szasocjacji route tables),
  - w pełni wystarczające dla **dev-only** i jednostanowiskowego kursu.
- Wady:
  - SPOF dla ruchu wychodzącego (awaria AZ z NAT-em = utrata wyjścia na świat),
  - cross-AZ traffic z private-b do NAT w public-a (dodatkowe opóźnienia i koszt ruchu między AZ).

### Opcja B — NAT per AZ (HA)

- Architektura:
  - 2 × NAT Gateway: w `public-a` i `public-b`,
  - private-a routuje do NAT w public-a, private-b do NAT w public-b.
- Zalety:
  - brak cross-AZ dla ruchu wychodzącego (lepsze opóźnienia, mniejszy koszt,
  - brak pojedynczego punktu awarii na warstwie NAT (jeśli jedna AZ padnie, druga nadal działa).
- Wady:
  - ~2× koszt stały NAT (płacimy za 2 NAT-y 24/7),
  - wyższa złożoność Terraform (więcej zasobów, route tables).

### Opcja C — Brak NAT (tylko VPC Endpoints)

- Teoretycznie możliwe:
  - całkowite oparcie się na VPC Endpoints (Gateway + Interface) do wszystkich potrzebnych usług AWS,
  - brak dostępu do ogólnego Internetu z private subnetów.
- Zalety:
  - brak kosztu NAT,
  - ruch do usług AWS idzie po prywatnej sieci.
- Wady:
  - **niepraktyczne** dla realnego środowiska (brak dostępu do publicznych API, update’ów, rejestrów itp.),
  - **sprzeczne z celem edukacyjnym** (chcemy też rozumieć rolę NAT i jego relację do endpointów),
  - i tak ponosimy koszt Interface Endpointów.

Ze względu na cel kursu Opcja C jest traktowana jako ciekawostka architektoniczna, a nie realny wybór.

---

## 4. Decyzja

W środowisku **dev-only** wybieramy:

> **Opcja A — Jeden NAT Gateway w jednej AZ (np. `public-a`), z natychmiastowym odciążeniem przez VPC Endpoints (Endpoint-first, NAT jako fallback).**

Konkretnie:
- Tworzymy **1 × NAT Gateway** w subnecie `public-a` (eu-central-1a).
- Route tables subnetów:
  - `private-a` i `private-b` kierują domyślny ruch do Internetu (`0.0.0.0/0`) na ten NAT.
- Ruch do wybranych usług AWS **nie** przechodzi przez NAT:
  - S3, DynamoDB → Gateway Endpoints (wiązane z route tables private),
  - Secrets Manager, SSM → Interface Endpoints (ENI w private-a/b).

Status decyzji: **Proposed → do oznaczenia jako Accepted po pierwszym uruchomieniu sieci w Terraform (W04/W05).**

---

## 5. Uzasadnienie

### 5.1 Dlaczego 1 NAT (a nie 2)?

- **Guardrails kosztowe (ADR-0002):**
  - NAT jest zasobem o stałym koszcie godzinowym; podwojenie liczby NAT-ów w dev nie daje wymiernej korzyści przy pojedynczym uczestniku kursu,
  - środowisko nie ma wymogów SLA/HA produkcyjnego, celem jest nauka i portfolio.
- **Cel edukacyjny:**
  - kurs ma pokazać *kompromis* między kosztem a HA, a nie od razu replikować pełne prod HA,
  - 1 NAT + VPC Endpoints pozwala przećwiczyć:
    - kiedy ruch idzie przez NAT,
    - kiedy omijamy NAT dzięki endpointom (Gateway/Interface),
    - co by się zmieniło, gdyby dorzucić drugi NAT.
- **Prostota na start:**
  - mniej zasobów do ogarnięcia w pierwszym podejściu do Terraform `network-core`,
  - łatwiejsze debugowanie ewentualnych problemów z routingiem.

### 5.2 Dlaczego nie „bez NAT, tylko endpointy”?

- Potrzebny jest choć jeden **wyjściowy kanał do Internetu** dla:
  - update’ów, rejestrów, ewentualnych zewnętrznych API,
  - scenariuszy, gdzie nie mamy (jeszcze) endpointów dla danej usługi AWS.
- Całkowity brak NAT utrudniałby:
  - naukę różnic między ruchem „przez NAT” a „przez endpoint”,
  - realistyczne scenariusze (w większości projektów NAT jednak istnieje).

---

## 6. Konsekwencje

### 6.1 Pozytywne

- **Koszty dev** są pod kontrolą:
  - płacimy za 1 NAT, a nie za 2,
  - znaczną część ruchu do AWS (S3, DynamoDB, Secrets, SSM) kierujemy po VPC Endpoints.
- **Architektura jest realistyczna:**
  - ECS/Lambda w private, RDS w private, ingress przez ALB w public,
  - NAT pełni rolę „wyjścia na świat”, jak w wielu realnych projektach.
- **Łatwe przejście do wariantu prod:**
  - dodanie drugiego NAT w `public-b` + aktualizacja route tables dla `private-b` jest prostym rozszerzeniem modułów Terraform,
  - można to potraktować jako osobny „hardening task” w późniejszych tygodniach.

### 6.2 Negatywne / ryzyka (świadomie zaakceptowane)

- **SPOF ruchu wychodzącego**:
  - awaria AZ z NAT-em (public-a) = utrata ruchu wychodzącego z obu private subnetów,
  - dla dev-only jest to akceptowalne (oznacza co najwyżej przerwanie ćwiczeń do czasu naprawy).
- **Cross-AZ traffic**:
  - ruch z `private-b` do Internetu/NAT będzie przechodził między AZ,
  - generuje to niewielki dodatkowy koszt i opóźnienie, ale w dev nie jest to problemem.

---

## 7. Wpływ na Terraform i kolejne tygodnie

- W04 (`network-core`):
  - moduł powinien:
    - tworzyć 1 NAT Gateway w `public-a`,
    - skonfigurować route tables dla `private-a`/`private-b` tak, by `0.0.0.0/0` wskazywało na ten NAT,
    - dodać miejsce/parametry na łatwe rozszerzenie do „NAT per AZ” (np. feature flag lub parametr).
- W05 (`network-endpoints`):
  - moduł endpointów powinien:
    - dodać Gateway Endpoints dla S3 i DynamoDB,
    - dodać Interface Endpoints dla Secrets Manager i SSM (ENI w private-a/b),
    - zaktualizować runbooki tak, aby pokazywały, że ruch do tych usług nie przechodzi już przez NAT.
- Hardening (później, np. W22+):
  - można dodać zadanie „Przejście z 1 NAT do NAT per AZ” jako symulację „podniesienia dev do standardów prod”.

---

## 8. Weryfikacja

- NAT Gateway istnieje w `public-a`, a route tables private-a/private-b kierują `0.0.0.0/0` na ten NAT.
- VPC Endpoints (S3, DynamoDB, Secrets, SSM) są skonfigurowane zgodnie z projektem (W05).
- Ruch do S3/DynamoDB/Secrets/SSM nie pojawia się jako ruch przez NAT (do potwierdzenia w późniejszym tygodniu za pomocą metryk/billingu/logów).

