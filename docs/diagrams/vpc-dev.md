## VPC dev — adresacja i subnety

### Kontekst
- Środowisko: konto `swpr-dev`, region `eu-central-1` (dev-only).
- VPC dev jest wspólna dla całego projektu `OrderFlow AWS Lab` i powinna być stabilna w czasie (ADR-0002 — stała VPC, efemeryczne drogie zasoby).
- Projektowana pod: ALB, ECS Fargate, RDS, VPC Endpoints (gateway/interface), opcjonalnie Lambdy w VPC.

### CIDR VPC
- **VPC CIDR:** `10.0.0.0/16`
- **Uzasadnienie:**
  - unikanie pułapki „za mały CIDR” (roadmapa W03 — możliwość dodawania kolejnych subnetów / AZ bez zmiany VPC),
  - czytelny zakres, łatwy do opisania i utrzymania,
  - wystarczający zapas adresów dla dev-only przy zachowaniu prostoty.

### Subnety (W03-T01)

Tabela subnetów zaprojektowana tak, aby:
- mieć min. 2 AZ (wymóg roadmapy),
- mieć osobne subnety public i private w każdej AZ,
- zostawić przestrzeń na przyszłe rozszerzenia (dodatkowe subnety / trzecia AZ) bez zmiany istniejących zakresów.

| Nazwa subnetu | AZ             | CIDR         | Typ     | Przeznaczenie (wysoki poziom)              |
|---------------|----------------|--------------|---------|---------------------------------------------|
| public-a      | eu-central-1a  | 10.0.1.0/24  | public  | ALB, ewentualny bastion/NAT                 |
| public-b      | eu-central-1b  | 10.0.2.0/24  | public  | ALB                                         |
| private-a     | eu-central-1a  | 10.0.11.0/24 | private | ECS, RDS, VPC Endpoints (gateway/interface) |
| private-b     | eu-central-1b  | 10.0.12.0/24 | private | ECS, RDS, VPC Endpoints (gateway/interface) |

Notatki:
- zakresy /24 są dużo większe niż absolutne minimum, ale w dev pozwalają komfortowo zmieścić ENI od ECS/RDS/endpointów bez myślenia o każdym adresie,
- przerwa między 10.0.2.0/24 a 10.0.11.0/24 zostawia miejsce na:
  - dodatkowe subnety (np. dedykowane DB, trzecia AZ),
  - eksperymenty z innymi wariantami segmentacji,
  - bez konieczności zmiany już używanych zakresów.

Ta tabela spełnia kryterium W03-T01: **tabela subnetów nie zawiera konfliktów CIDR** i jest gotowa jako wejście do:
- W03-T02 (rozmieszczenie komponentów),
- W04 (Terraform moduł `network-core` — definicja VPC i subnetów).

---

## Rozmieszczenie komponentów (W03-T02)

Rozmieszczenie głównych komponentów projektu w zaprojektowanych subnetach, zgodnie z przyjętymi założeniami:
- Lambda w VPC (private subnety), bo korzysta z prywatnych zasobów (np. RDS),
- wspólne private subnety dla ECS, RDS, endpointów i Lambdy w dev,
- model ruchu **endpoint-first, NAT jako fallback** (Gateway/Interface Endpoints tam, gdzie to ma sens, NAT dla reszty).

| Komponent                               | Typ ruchu / rola                | Subnet(y)                                              | Uwagi                                                                 |
|-----------------------------------------|----------------------------------|--------------------------------------------------------|-----------------------------------------------------------------------|
| ALB (publiczny ingress)                | Wejście HTTP/HTTPS z Internetu  | `public-a` (10.0.1.0/24), `public-b` (10.0.2.0/24)    | Klasyczny front door: ALB w public subnets w 2 AZ                     |
| ECS Fargate (tasks)                    | Backend / worker                | `private-a` (10.0.11.0/24), `private-b` (10.0.12.0/24)| Ruch przychodzący z ALB, wychodzący do RDS, SQS/SNS, S3, usług AWS    |
| RDS PostgreSQL                         | Baza danych                     | `private-a`, `private-b`                              | W dev współdzieli private z ECS/endpointami; subnet group = te 2 subnety |
| Lambda `payment-callback` w VPC        | Serverless w VPC                | `private-a`, `private-b`                              | Potrzebuje dostępu do RDS/privates; wychodzi do usług AWS po endpointach/NAT |
| Gateway Endpoint S3                    | Storage / artefakty             | Route tables dla subnetów private                     | Ruch do S3 z private nie przechodzi przez NAT ani Internet            |
| Gateway Endpoint DynamoDB              | NoSQL                           | Route tables dla subnetów private                     | Jak wyżej, dla DynamoDB                                              |
| Interface Endpoint Secrets Manager     | Sekrety                         | ENI w `private-a` i `private-b`                       | Pobieranie secretów przez ECS/Lambdę po prywatnym IP (PrivateLink)   |
| Interface Endpoint SSM Parameter Store | Konfiguracja / parametry        | ENI w `private-a` i `private-b`                       | Parametry konfiguracyjne, wzorzec analogiczny do Secrets Manager      |
| NAT Gateway                            | Fallback do Internetu           | `public-a` (10.0.1.0/24)                              | Jedna AZ w dev (szczegóły i trade-off w W03-T03 / ADR-0004)           |

Model ruchu (wysoki poziom):
- Internet → IGW → ALB w `public-a`/`public-b` → ECS/Lambda w `private-a`/`private-b`.
- ECS/Lambda → RDS po prywatnych IP w private subnetach.
- ECS/Lambda → S3/DynamoDB przez Gateway Endpoints (bez NAT/Internetu).
- ECS/Lambda → Secrets Manager/SSM przez Interface Endpoints (PrivateLink).
- Inny ruch wychodzący z private (usługi bez endpointu, ogólne Internet) → NAT Gateway w `public-a`.

---

## Przepływ ruchu (W03-T04)

Poniżej opis przepływu ruchu dla głównych ścieżek w topologii dev.

### 1. Ruch przychodzący z Internetu do aplikacji

1. Klient (przeglądarka, Postman, inny system) wykonuje żądanie HTTP(S) na publiczny DNS/URL ALB.
2. Ruch trafia do **Internet Gateway (IGW)** przypiętego do VPC.
3. Route table subnetów `public-a` / `public-b` kieruje ruch do **ALB** osadzonych w tych subnetach.
4. ALB na podstawie reguł listenerów i target group:
   - rozkłada ruch między **zadania ECS Fargate** w `private-a` / `private-b`,
   - opcjonalnie kieruje ruch do **Lambdy w VPC** (np. przez target typu Lambda, jeśli będzie użyta w tym scenariuszu).

Efekt: ruch z Internetu nigdy nie trafia bezpośrednio do private subnetów; zawsze przechodzi przez IGW → ALB w public subnets → ECS/Lambda w private.

### 2. Ruch wewnętrzny z ECS/Lambdy do RDS

1. ECS task lub Lambda w VPC (w `private-a` / `private-b`) nawiązuje połączenie do endpointu RDS.
2. DNS endpointu RDS rozwiązuje się do **prywatnego IP** w VPC (subnet group private-a/b).
3. Ruch idzie wewnątrz VPC:
   - z ENI ECS/Lambdy w private-a/b,
   - do ENI instancji/bazy RDS w tych samych subnetach private.

Ten ruch nie wychodzi poza VPC, nie korzysta z IGW ani NAT; jest to czysty ruch prywatny w sieci VPC.

### 3. Ruch z ECS/Lambdy do usług AWS z endpointami (endpoint-first)

#### 3.1 S3 / DynamoDB (Gateway Endpoints)

1. ECS/Lambda w private wykonuje operację na S3 lub DynamoDB (np. zapis/odczyt).
2. Zapytanie jest kierowane do publicznego DNS usługi, ale:
   - dzięki **Gateway Endpointom** przypiętym do route tables subnetów private,
   - ruch do prefiksów S3/DynamoDB trafia do wewnętrznej sieci AWS, a nie do Internetu/NAT.

Efekt: brak wykorzystania NAT dla S3/DynamoDB; ruch jest prywatny w ramach infrastruktury AWS.

#### 3.2 Secrets Manager / SSM (Interface Endpoints)

1. ECS/Lambda w private odczytuje sekret lub parametr (Secrets Manager / SSM).
2. DNS usługi rozwiązuje się do **prywatnego adresu ENI** Interface Endpointu w `private-a` / `private-b`.
3. Ruch idzie z ENI ECS/Lambdy do ENI endpointu w tym samym subnecie/AZ (lub sąsiednim w tej samej VPC).

Efekt: znów brak wyjścia przez NAT/Internet; ruch do sekrety/konfig jest całkowicie prywatny.

### 4. Ruch wychodzący do Internetu (fallback przez NAT)

1. ECS/Lambda w private chce skomunikować się z usługą bez endpointu (np. zewnętrzne API, usługa AWS bez VPC Endpointu).
2. Route table private-a/b ma domyślną trasę `0.0.0.0/0` skierowaną na **NAT Gateway** w `public-a`.
3. Ruch z private-a przechodzi do NAT w public-a lokalnie w tej samej AZ; ruch z private-b przechodzi cross-AZ do NAT w public-a.
4. NAT Gateway wysyła ruch do Internetu przez IGW, zachowując prywatne IP zasobów w private (NAT source).

Efekt: wszystko, co nie jest obsłużone przez VPC Endpoints, przechodzi przez NAT (zgodnie z modelem endpoint-first, NAT jako fallback).


