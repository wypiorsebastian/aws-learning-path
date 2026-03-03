## W03–W05 — Podsumowanie fazy planowania (architektura + topologia sieci)

### 1. Cel dokumentu i kontekst

Celem tego dokumentu jest:

- **Scalenie całej fazy planowania z W03–W05** w jedną, spójną architekturę rozwiązania.
- **Opisanie pełnej topologii sieci**: jakie zasoby sieciowe AWS wybraliśmy, jak są połączone, jak przepływa ruch.
- **Wyjaśnienie „jak to działa” na poziomie mechaniki** — w stylu podręcznikowym, bez skrótów myślowych, z odniesieniami do analogii z Azure tam, gdzie to pomaga.

Zakładam, że:

- znasz dobrze **koncepcje z Azure** (VNet, subnet, NSG, UDR, NAT Gateway, Private Endpoint, Application Gateway),
- w AWS chcesz zrozumieć **konkretne odpowiedniki** i to, jak **działają razem** w Twoim projekcie.

---

### 2. Workloads – z czego składa się nasze rozwiązanie

Na bazie ADR-0001 i roadmapy, `OrderFlow AWS Lab` ma następujące typy workloads:

#### 2.1 Workloads synchroniczne (HTTP/API)

- **`orders-api` (ECS Fargate)**  
  - .NET Web API obsługujący operacje na zamówieniach (tworzenie, odczyt, status).
  - Wystawiony do Internetu przez **Application Load Balancer (ALB)**.
- **`payments-api` (ECS Fargate)**  
  - API odpowiedzialne za obsługę płatności, integrację z bramką płatniczą.
  - Również za ALB – klient (browser/Postman/system) nie widzi bezpośrednio ECS, tylko ALB.
- **`catalog-api` (ECS Fargate)**  
  - API do odczytu danych katalogowych (produkty, ceny, itp.).
  - Również wystawione za ALB.

**Azure analogia:**  
To jest odpowiednik **App Service / AKS z Application Gateway + WAF**.  
ALB tutaj pełni rolę „front doora” dla ruchu HTTP(S), dokładnie jak **Application Gateway** w Azure.

#### 2.2 Workloads asynchroniczne

- **`order-worker` (ECS Fargate)**  
  - Worker obsługujący zdarzenia asynchroniczne (np. z SQS).
  - Nie jest wystawiony publicznie — pracuje w tle, konsumując kolejki/zapisując do bazy.

#### 2.3 Workload serverless

- **`payment-callback` (AWS Lambda w VPC)**  
  - Funkcja .NET, która odbiera **callback z zewnętrznej bramki płatniczej**.
  - Typowy scenariusz:
    - bramka płatnicza uderza w **API Gateway** (albo dedykowy endpoint),
    - API Gateway wywołuje Lambdę,
    - Lambda działa **w VPC**, bo potrzebuje dostępu do RDS/DynamoDB/secretów.
  - Lambda nie jest wystawiona „goło” do Internetu – **zawsze stoi przed nią front-door** (API Gateway).

**Azure analogia:**  
To jest odpowiednik **Azure Functions** z **VNet Integration**, wywoływanych przez **API Management** albo bezpośrednio z publicznego endpointu — ale i tak zwykle z jakimś „frontem” (APIM).

#### 2.4 Warstwa danych i integracji

- **RDS PostgreSQL (baza relacyjna)**  
  - Hostuje dane transakcyjne (orders/payments).
  - Działa w **private subnetach**, nigdy nie jest publicznie wystawiona.
- **DynamoDB (baza NoSQL)**  
  - Dane, które lepiej czują się w modelu klucz-wartość / dokumentowym.
  - Dostęp **z naszych workloads przez VPC Gateway Endpoint**, bez NAT/Internetu.
- **S3**  
  - Storage dla logów, artefaktów, eksportów.
  - Dostęp z VPC przez **Gateway Endpoint S3**.
- **SQS / SNS / EventBridge**  
  - Kolejki i bus zdarzeń między `orders-api`, `order-worker`, Lambdami itd.
  - Na starcie dostęp do nich idzie przez **NAT Gateway** (bez dedykowanych endpointów).
- **Secrets Manager / SSM Parameter Store**  
  - Sekrety (connection strings, API keys) i parametry konfiguracyjne.
  - Dostęp **tylko po prywatnym IP** przez **Interface Endpoints** (PrivateLink).

#### 2.5 Observability

- **CloudWatch Logs / Metrics / Alarms**  
  - Logi aplikacyjne, logi infrastruktury, metryki.
- **VPC Flow Logs**  
  - Logi przepływów sieciowych w VPC (kto z kim, port, ACCEPT/REJECT).

---

### 3. Architektura wysokiego poziomu – „od klienta do bazy”

Możesz o tym myśleć tak:

1. **Klient (Internet)** uderza w **publiczny DNS ALB**.
2. **ALB**:
   - terminacja TLS (HTTPS),
   - routowanie do odpowiedniego API (orders/payments/catalog) w **ECS Fargate w private subnetach**.
3. **ECS Fargate**:
   - wykonuje logikę biznesową,
   - sięga do **RDS** (relacyjnie) oraz **DynamoDB** (NoSQL),
   - korzysta z **S3** (pliki), **SQS/SNS/EventBridge** (asynchronicznie),
   - używa **Secrets/SSM** do konfiguracji.
4. **Worker `order-worker`**:
   - konsumuje kolejki (SQS) i zdarzenia (EventBridge),
   - aktualizuje RDS/DynamoDB.
5. **Lambda `payment-callback`**:
   - jest wywoływana przez **API Gateway** jako reakcja na callback bramki płatniczej,
   - działa w **VPC** (private subnety), korzysta z RDS/Dynamo/Secrets/SSM.

Całość jest „włożona” w **jedną VPC dev**, w jednym regionie, w **dwóch AZ** (dla nauki multi-AZ, ale bez pełnych wymogów HA).

---

### 4. Topologia sieci – overview

Na podstawie `docs/diagrams/vpc-dev.md`, W03, W04, W05:

#### 4.1 VPC i subnety

- **VPC dev**:
  - CIDR: `10.0.0.0/16`  
    (duży, wygodny zakres, żeby nie wpaść w pułapkę „za małego CIDR”).
- **Subnety**:
  - `public-a` — `10.0.1.0/24` (AZ `eu-central-1a`) – ALB, NAT.
  - `public-b` — `10.0.2.0/24` (AZ `eu-central-1b`) – ALB.
  - `private-a` — `10.0.11.0/24` (AZ `eu-central-1a`) – ECS, RDS, Lambda, Interface EP.
  - `private-b` — `10.0.12.0/24` (AZ `eu-central-1b`) – ECS, RDS, Lambda, Interface EP.

**Azure analogia:**  
To jest jak **jedna VNet** z kilkoma **subnetami** (public/private) w różnych **Availability Zones** (odpowiednik „stref dostępności”).

#### 4.2 Bramy i routing

- **Internet Gateway (IGW)**  
  - „Drzwi” VPC do Internetu.
  - Route table publicznych subnetów ma trasę `0.0.0.0/0 → IGW`.
- **NAT Gateway (1 szt.)**  
  - W subnecie `public-a`.
  - Private subnety (`private-a/b`) mają domyślną trasę `0.0.0.0/0 → NAT`.
  - Dzięki temu **private** mogą wychodzić do Internetu, ale same nie są routowane z Internetu.

**Azure analogia:**  
- IGW ≈ „domyślna brama” z VNet do Internetu (w Azure to jest raczej wbudowana usługa, ale na poziomie „Internet” w UDR).  
- NAT Gateway ≈ **Azure NAT Gateway** przypięty do subnetu.

#### 4.3 Route Tables

- **Public route table**:
  - `local` dla VPC (10.0.0.0/16),
  - `0.0.0.0/0 → IGW`.
- **Private route table**:
  - `local` dla VPC,
  - prefiksy S3/DynamoDB → **Gateway Endpoints** (W05),
  - `0.0.0.0/0 → NAT Gateway`.

To jest odpowiednik **User Defined Routes** w Azure (UDR) – świadomie ustawiasz, którędy wychodzi ruch z danego subnetu.

#### 4.4 Security Groups (SG) – stateful firewall na poziomie ENI

Bazowy zestaw:

- **`sg_alb`**:
  - Ingress:
    - `0.0.0.0/0:80,443` (HTTP/HTTPS z Internetu),
  - Egress:
    - do `sg_app` na port aplikacji (np. 80/8080).
- **`sg_app`** (ECS/Lambda):
  - Ingress:
    - z `sg_alb` na port aplikacji (np. 80/8080),
  - Egress:
    - do `sg_rds:5432` (Postgres),
    - `0.0.0.0/0:80,443` (ruch wychodzący do AWS APIs, NAT),
    - do ENI Interface Endpointów (Secrets/SSM).
- **`sg_rds`**:
  - Ingress:
    - z `sg_app:5432`,
  - Egress:
    - do `sg_app` (lub `0.0.0.0/0` dla powrotu).

**Azure analogia:**  
SG ≈ **Network Security Group (NSG)**, ale:
- SG jest **stateful** (jak NSG),
- reguła egress automatycznie pozwala na odpowiedź (return traffic).

#### 4.5 NACL – stateless filtr na poziomie subnetu

- W dev **bazowo używamy domyślnego NACL** (allow-all).
- Alternatywnie opisany jest **bardziej restrykcyjny wariant** (w przyszłości), ale na teraz świadomie go nie włączamy, żeby:
  - nie komplikować nauki,
  - nie zabić się na „ephemeral ports”.

**Azure analogia:**  
NACL to coś na poziomie **firewalla subnetowego**, bardziej „stateless” niż NSG.  
W praktyce większość projektów (też w AWS) opiera się głównie na SG/NSG, a NACL jest dodatkową warstwą – dokładnie jak u nas.

#### 4.6 VPC Endpoints (Gateway i Interface)

Zgodnie z W05:

- **Gateway Endpoints**:
  - **S3** i **DynamoDB**,
  - powiązane z **private route table**,
  - trasy `prefix S3/DynamoDB → vpce-...`,
  - ruch do S3/DynamoDB **nie idzie przez NAT/Internet**, tylko prywatną siecią AWS.
- **Interface Endpoints (PrivateLink)**:
  - **Secrets Manager** i **SSM Parameter Store**,
  - tworzą **ENI w private-a/b**, z przypiętym SG (`sg_endpoints`),
  - z włączonym **Private DNS** – publiczny hostname (np. `secretsmanager.eu-central-1.amazonaws.com`) rozwiązuje się do prywatnego IP w VPC.

**Azure analogia:**  
- Gateway Endpoint ≈ **Azure Storage/Dynamo Private Endpoint**, ale bardziej na poziomie „routingu do serwisu po prywatnym peeringu”.  
- Interface Endpoint ≈ klasyczny **Private Endpoint** do PaaS (np. Key Vault, Storage) – prywatne IP w Twojej sieci, DNS przekierowujący na to IP.

#### 4.7 VPC Flow Logs

- Włączone (docelowo) na poziomie **VPC**.
- Destination:
  - domyślnie **CloudWatch Logs** z krótką retencją (np. 7–14 dni).
- `traffic_type`:
  - **`ACCEPT`** na co dzień (widzimy, co przechodzi),
  - tymczasowo **`ALL`** w trybie głębokiego debugowania.

**Azure analogia:**  
To jest odpowiednik **NSG Flow Logs** + **VNet Flow Logs** (w Network Watcher), z możliwością analizy np. przez Log Analytics.

---

### 5. Dlaczego nie łączymy się „bezpośrednio” z Lambdą / ECS / RDS?

To jest kluczowe pytanie.

#### 5.1 Wejście z Internetu – dlaczego ALB / API Gateway?

**Scenariusz ECS (orders/payments/catalog):**

- Nie wystawiasz **bezpośrednio ENI ECS** do Internetu, bo:
  - musiałbyś dać im publiczne IP,
  - to utrudnia skalowanie (każdy task ma swój adres),
  - tracisz centralne miejsce na:
    - TLS/HTTPS terminację,
    - health checki, routing, ewentualnie WAF,
    - logowanie na poziomie wejścia.
- Zamiast tego:
  - wystawiasz **jeden lub kilka ALB** w subnetach publicznych,
  - ECS tasks żyją w subnetach private, a ALB routuje do nich po prywatnych IP.

**Azure analogia:**  
To jest dokładnie pattern: **Application Gateway + backend pool w AKS / App Service w subnetach private**.

**Scenariusz Lambda:**

- Lambda ma **własny publiczny endpoint** (przez AWS API), ale:
  - zwykle nie chcesz, żeby dowolny klient z Internetu miał go „na wierzchu”,
  - lepiej mieć **API Gateway** jako front-door:
    - zarządzanie autoryzacją, throttlingiem, wersjonowaniem API,
    - integracja z WAF, logami, itp.
- Dlatego:
  - internet → **API Gateway (public)** → Lambda (w VPC),
  - a nie internet → Lambda bezpośrednio.

**Azure analogia:**  
Jak **APIM** wystawiający funkcje **Azure Functions** lub Web Appy.

#### 5.2 Dlaczego RDS jest w private?

- Baza danych powinna być:
  - **niewidoczna z Internetu**,
  - dostępna tylko z określonych warstw aplikacyjnych (ECS/Lambda).
- Umieszczenie RDS w private subnetach, z SG „wpuszczającym” tylko `sg_app` na porcie `5432`, gwarantuje:
  - brak publicznego endpointu,
  - kontrolę na poziomie SG (stateful firewall),
  - łatwy debugging (wiemy dokładnie, kto „może gadać” z bazą).

**Azure analogia:**  
**Azure SQL** albo **PostgreSQL Flexible Server** wirtualnie w prywatnym VNet/subnecie z dostępem tylko przez peering/VNet Integration – bez publicznego IP.

#### 5.3 Dlaczego VPC Endpoints zamiast „zawsze NAT”?

**Bez endpointów**:

- Wszystko, co wychodzi z private subnetów do:
  - S3, DynamoDB, Secrets, SSM, SQS, itp.
- Musi przejść przez:
  - private → NAT Gateway → IGW → publiczny endpoint usługi.

**Z endpointami**:

- Dla S3/DynamoDB:
  - ruch idzie do **Gateway Endpointów** – zostaje w prywatnej infrastrukturze AWS, nie dotyka IGW/NAT.
- Dla Secrets/SSM:
  - ruch idzie do ENI Interface Endpointów w private subnetach.

Zalety:

- **Bezpieczeństwo**:
  - brak wychodzenia do „publicznego Internetu” dla kluczowych usług (storage, sekrety),
  - trudniej zrobić np. exfiltration danych, jeśli NACL/SG są ustawione rozsądnie.
- **Koszt**:
  - mniej ruchu przez NAT (który jest płatny).
- **Spójność**:
  - wszystko, co jest „infrastrukturą runtime” (sekrety, konfig, storage) jest dostępne po prywatnych IP.

**Azure analogia:**  
**Private Endpoints** do Storage/Key Vault/Config, zamiast wystawiania ruchu przez publiczny Internet.

---

### 6. Szczegółowa ścieżka ruchu – jak to wszystko współpracuje

#### 6.1 Ruch przychodzący (Internet → ALB → ECS/Lambda)

1. Klient uderza w **DNS ALB** (`myapp-dev-alb-xyz.eu-central-1.elb.amazonaws.com` lub własny CNAME).
2. Ruch trafia przez **Internet Gateway** do subnetów `public-a/b`.
3. **ALB**:
   - patrzy na reguły listenera (np. `/orders`, `/payments`, `/catalog`),
   - wybiera odpowiednią target group (np. tasks `orders-api` w ECS),
   - równoważy ruch między zadaniami ECS w `private-a/b`.
4. ECS tasks:
   - odbierają request,
   - wykonują logikę,
   - jeśli trzeba, odwołują się do RDS/DynamoDB/S3/Secrets/SSM.

Jeżeli ALB ma target typu **Lambda** (też możliwe):

- ALB → Lambda w VPC (ale w naszym projekcie raczej traktujemy Lambdę jako callback za API Gateway).

#### 6.2 Ruch ECS/Lambda → RDS (wewnętrzny)

1. ECS task lub Lambda w VPC (ENI w `private-a/b`) otwiera połączenie do endpointu RDS.
2. DNS RDS rozwiązuje się do **prywatnego IP** w `private-a/b`.
3. Ruch idzie **w całości wewnątrz VPC** (bez IGW/NAT).
4. SG:
   - `sg_app` ma egress do `sg_rds:5432`,
   - `sg_rds` ma ingress z `sg_app:5432`.

#### 6.3 Ruch ECS/Lambda → S3/DynamoDB (Gateway Endpoints)

1. ECS/Lambda wywołuje operację na S3/DynamoDB (np. zapis pliku, odczyt rekordu).
2. DNS wskazuje **standardowy endpoint usługi** (np. `s3.eu-central-1.amazonaws.com`).
3. **Route table private** ma trasy do prefix list S3/Dynamo:
   - `prefix S3 → Gateway Endpoint S3`,
   - `prefix DynamoDB → Gateway Endpoint DynamoDB`.
4. Ruch idzie nie do NAT, tylko:
   - private → Gateway Endpoint → usługa wewnątrz AWS.

#### 6.4 Ruch ECS/Lambda → Secrets / SSM (Interface Endpoints)

1. ECS/Lambda potrzebuje sekretu/parametru.
2. DNS dla `secretsmanager.eu-central-1.amazonaws.com` / `ssm.eu-central-1.amazonaws.com`:
   - dzięki Private DNS rozwiązuje się do **prywatnego IP ENI endpointu** w `private-a/b`.
3. Ruch:
   - ENI ECS/Lambda → ENI endpointu (w tym samym subnecie / AZ),
   - dalej wewnętrzną infrastrukturą AWS do usługi.

#### 6.5 Ruch ECS/Lambda → inne usługi AWS / zewnętrzne API (NAT)

Dla usług bez endpointu (np. SQS/SNS/CloudWatch/ECR na start) i zewnętrznych API:

1. ECS/Lambda wysyła request na standardowy publiczny endpoint.
2. Route table private nie ma specjalnej trasy → ruch trafia na:
   - `0.0.0.0/0 → NAT Gateway`.
3. NAT:
   - tłumaczy IP źródłowe na swoje publiczne IP,
   - wysyła ruch przez IGW do Internetu.
4. Odpowiedzi wracają przez IGW → NAT → private (na porty efemeryczne, które SG/NACL muszą przepuszczać).

---

### 7. Podsumowanie: jakie elementy sieciowe i dlaczego

**Lista kluczowych elementów i ich rola:**

- **VPC** – izolacja sieci (odpowiednik VNet).
- **Subnets public/private** – segmentacja na warstwy (ingress vs workloads + dane).
- **IGW** – brama do Internetu dla publicznych zasobów (ALB, NAT).
- **NAT Gateway** – wyjście z private do Internetu/AWS APIs bez wystawiania private na zewnątrz.
- **Route Tables** – definicja ścieżek (local, IGW, NAT, Gateway Endpoints).
- **Security Groups** – stateful firewall na poziomie ENI (ALB/ECS/Lambda/RDS/Endpoints).
- **NACL** – subnet-level stateless filtr (w dev w trybie „allow-all”).
- **Gateway Endpoints (S3/DynamoDB)** – prywatny, „tańszy” i bezpieczniejszy dostęp do storage/NoSQL.
- **Interface Endpoints (Secrets/SSM)** – PrivateLink do usług zarządzających sekretami i konfiguracją.
- **ALB** – front-door HTTP(S) dla ECS APIs (orders/payments/catalog).
- **API Gateway (koncepcyjnie dla Lambdy)** – front-door HTTP(S) dla callbacków płatności.
- **VPC Flow Logs** – narzędzie do obserwacji i debugowania ruchu sieciowego.

Wszystko to jest już **zaprojektowane w W03–W05** na poziomie:

- adresacji,
- routing/IGW/NAT,
- SG/NACL,
- endpoints,
- runbooków.

W W06/W07 będziemy „tylko” przekładać ten design na Terraform (`network-core`, `network-endpoints`) i weryfikować w praktyce, że ruch idzie dokładnie tymi ścieżkami, które tu opisaliśmy.

