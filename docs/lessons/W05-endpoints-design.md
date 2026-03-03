## W05 — VPC Endpoints, PrivateLink i Flow Logs — design modułu `network-endpoints`

Design modułu Terraform `network-endpoints` dla VPC dev projektu OrderFlow AWS Lab (env `dev-only`), na bazie:

- topologii VPC z W03 (`docs/diagrams/vpc-dev.md`),
- modeli przepływu ruchu z W04 (`docs/lessons/W04-traffic-models.md`),
- projektu modułu `network-core` (`docs/lessons/W04-network-core-module-design.md`),
- guardrails kosztowych (ADR-0002) i strategii NAT (ADR-0004 — endpoint-first, NAT jako fallback).

Moduł `network-endpoints` będzie implementowany w W07; ten dokument jest **wyłącznie designem** (bez HCL).

---

## 1. Teoria — Gateway Endpoint vs Interface Endpoint vs PrivateLink vs NAT (W05-T01)

### 1.1 Definicje

- **Gateway Endpoint**:
  - Specjalny typ VPC Endpointu, który:
    - jest „wstrzykiwany” do **route table** jako trasa dla prefiksów danej usługi (np. S3, DynamoDB),
    - nie tworzy własnych ENI, nie ma Security Group,
    - istnieje na poziomie **VPC + route tables**.
  - Obsługuje tylko wybrane usługi (m.in. **S3, DynamoDB**).
  - Koszt:
    - brak opłaty godzinowej za sam endpoint,
    - płacimy za standardowy ruch do usługi (np. S3) — zwykle i tak ponoszony.

- **Interface Endpoint**:
  - Typ VPC Endpointu, który:
    - tworzy **ENI** (Elastic Network Interface) w subnetach (zwykle private),
    - ma własne **Security Group**,
    - opcjonalnie włącza **Private DNS** (rekordy DNS dla usługi wskazują na prywatne IP ENI).
  - Obsługuje wiele usług (np. **Secrets Manager, SSM, CloudWatch Logs, ECR, SQS**, itd.).
  - Koszt:
    - opłata **per endpoint per AZ** (stała, godzinowa),
    - opłata za ruch przez endpoint (per GB).

- **PrivateLink (szersze pojęcie)**:
  - Mechanizm prywatnej komunikacji pomiędzy VPC a usługą:
    - usługą AWS,
    - własną aplikacją wystawioną jako endpoint service,
    - usługą partnera.
  - Na poziomie VPC widzimy to właśnie jako **Interface Endpoint**.
  - W tym projekcie:
    - korzystamy z PrivateLink „pośrednio”, przez Interface Endpoints usług AWS (Secrets/SSM),
    - **nie** wystawiamy własnych usług jako endpoint service (to temat na później).

- **NAT Gateway** (dla porównania):
  - Brama wyjściowa z private subnetów do Internetu / publicznych endpointów.
  - Koszt stały (godzinowy) + koszt ruchu; brak świadomości usług AWS (widzi tylko IP/domeny).

### 1.2 Wpływ na routing i DNS

- **Gateway Endpoint**:
  - Routing:
    - do route table dodawana jest trasa typu `prefix S3/DynamoDB → vpce-xxxx` (endpoint),
    - ruch do tych prefiksów **nie idzie przez NAT/IGW**, tylko przez prywatną sieć AWS.
  - DNS:
    - aplikacja używa standardowego DNS (np. `s3.eu-central-1.amazonaws.com`),
    - AWS sam mapuje go na odpowiednie prefiksy, które trafiają do endpointu.

- **Interface Endpoint**:
  - Routing:
    - ruch do docelowej usługi idzie po VPC local (do ENI endpointu),
    - dodatkowej trasy w route table zwykle nie trzeba (poza default/local).
  - DNS:
    - przy włączonym **Private DNS**:
      - publiczny hostname usługi (np. `secretsmanager.eu-central-1.amazonaws.com`) rozwiązuje się do prywatnego IP ENI endpointu,
      - aplikacja nie wie, że używa endpointu — po prostu korzysta z DNS.
    - przy wyłączonym Private DNS:
      - trzeba korzystać ze specjalnego endpointowego DNS (np. `vpce-xxxx-secretsmanager.eu-central-1.vpce.amazonaws.com`),
      - większa złożoność po stronie aplikacji/konfiguracji.

### 1.3 Koszt i konsekwencje (dev-only, ADR-0002)

- Gateway Endpoint (S3/DynamoDB):
  - idealny do ciągłego użycia w dev:
    - brak kosztu stałego endpointu,
    - bezpieczeństwo (ruch nie wychodzi do Internetu),
    - oszczędność NAT (mniej ruchu przez NAT Gateway).
- Interface Endpoint (Secrets/SSM):
  - koszt stały per endpoint + data:
    - w dev decydujemy się na **minimalny zestaw** endpointów:
      - Secrets Manager,
      - SSM Parameter Store,
    - inne (np. SQS, ECR) traktujemy na razie jako „nice to have”.
  - endpointy są **efemeryczne**:
    - mogą być utrzymywane razem z głównym środowiskiem dev,
    - ale przy dłuższej przerwie w kursie mogą być czasowo niszczone Terraformem (zgodnie z ADR-0002).
- NAT Gateway:
  - dzięki endpointom:
    - ruch do S3/DynamoDB/Secrets/SSM **nie obciąża NAT**,
    - NAT jest fallbackiem oraz ścieżką do usług bez endpointu i do Internetu.

---

## 2. Projekt modułu `network-endpoints` — overview (W05-T02/T03/T04)

### 2.1 Odpowiedzialność modułu

Moduł `network-endpoints` tworzy w VPC dev:

- **Gateway Endpoints**:
  - S3 (obowiązkowo, z możliwością wyłączenia),
  - DynamoDB (obowiązkowo, z możliwością wyłączenia).
- **Interface Endpoints**:
  - Secrets Manager,
  - SSM Parameter Store.
- **VPC Flow Logs**:
  - logi przepływów na poziomie VPC (lub wybranych subnetów),
  - wysyłane do CloudWatch Logs lub S3 (w zależności od konfiguracji).

Moduł **nie** tworzy:

- żadnych aplikacyjnych zasobów (ECS, Lambda, RDS),
- NAT Gateway ani IGW (to `network-core`),
- innych endpointów (SQS, ECR, CloudWatch) — mogą być dodane później jako rozszerzenie.

### 2.2 Zależność od modułu `network-core`

Moduł `network-endpoints` korzysta z outputów `network-core` (zdefiniowanych w W04):

- `vpc_id` — potrzebne do wszystkich endpointów i Flow Logs,
- `private_route_table_id` — potrzebne do Gateway Endpointów (S3, DynamoDB),
- `private_subnet_ids` (ew. `private_subnet_id_a`, `private_subnet_id_b`) — ENI Interface Endpointów,
- (opcjonalnie) `tags` bazowe (Project, Env, ManagedBy, Module).

Zasada: `network-endpoints` **nie modyfikuje** modułu `network-core`, tylko konsumuje jego outputy.

---

## 3. Gateway Endpoints — design (S3, DynamoDB) (W05-T02)

### 3.1 Zasoby i powiązania

Gateway Endpoints dla:

- **S3**:
  - `service_name`: `com.amazonaws.eu-central-1.s3`,
  - `vpc_endpoint_type`: `Gateway`,
  - powiązanie z `private_route_table_id` zwróconym przez `network-core`.
- **DynamoDB**:
  - `service_name`: `com.amazonaws.eu-central-1.dynamodb`,
  - `vpc_endpoint_type`: `Gateway`,
  - również powiązanie z `private_route_table_id`.

Routing:

- route table private po utworzeniu endpointów będzie miała:
  - trasy „local” (10.0.0.0/16),
  - trasy do prefiksów S3/DynamoDB → Gateway Endpoint,
  - domyślną trasę `0.0.0.0/0 → NAT` (fallback).

### 3.2 Proponowane variables i outputs (Gateway)

Przykładowe **variables** na poziomie designu:

- `enable_s3_gateway_endpoint` (bool, default `true`),
- `enable_dynamodb_gateway_endpoint` (bool, default `true`),
- `vpc_id` (string, wymagane),
- `private_route_table_id` (string, wymagane),
- `tags` (map(string), default `{}`).

Przykładowe **outputs**:

- `s3_gateway_endpoint_id` (string),
- `dynamodb_gateway_endpoint_id` (string).

### 3.3 Zasady tagowania (spójne z ADR-0002)

- `Project` = `OrderFlow-AWS-Lab`,
- `Env` = `dev`,
- `ManagedBy` = `terraform`,
- `Module` = `network-endpoints`,
- `Name` = np. `orderflow-dev-s3-gateway-endpoint`, `orderflow-dev-dynamodb-gateway-endpoint`.

---

## 4. Interface Endpoints — design (Secrets Manager, SSM) (W05-T04)

### 4.1 Subnety i SG endpointów

- ENI Interface Endpointów będą umieszczone w:
  - `private-a` (10.0.11.0/24),
  - `private-b` (10.0.12.0/24),
  - czyli w subnetach, w których działają ECS/Lambda.
- Dla endpointów tworzymy **dedykowaną Security Group**:
  - np. `sg_endpoints`,
  - ingress:
    - allow z `sg_app` (ECS/Lambda) na port 443,
  - egress:
    - allow `0.0.0.0/0:443` (komunikacja z usługą AWS; w praktyce wewnętrzna sieć AWS).

### 4.2 Private DNS

- Domyślnie włączamy `private_dns_enabled = true` dla obu endpointów:
  - aplikacje korzystają z publicznych hostname’ów usług:
    - `secretsmanager.eu-central-1.amazonaws.com`,
    - `ssm.eu-central-1.amazonaws.com`,
  - DNS w VPC zwraca prywatne IP ENI endpointu.
- Wyłączenie `private_dns_enabled`:
  - wymagałoby korzystania z endpoint-specific hostname’ów (`vpce-xxxx...`),
  - jest **świadomie odkładane** jako scenariusz „hardening / advanced”.

### 4.3 Zasoby Interface Endpointów

Interface Endpoints:

- **Secrets Manager**:
  - `service_name`: `com.amazonaws.eu-central-1.secretsmanager`,
  - `vpc_endpoint_type`: `Interface`,
  - `subnet_ids`: `private_subnet_ids` z `network-core`,
  - `security_group_ids`: `[sg_endpoints]`,
  - `private_dns_enabled`: `true`.
- **SSM Parameter Store**:
  - `service_name`: `com.amazonaws.eu-central-1.ssm`,
  - reszta analogicznie do Secrets Manager.

### 4.4 Proponowane variables i outputs (Interface)

Variables:

- `enable_secretsmanager_interface_endpoint` (bool, default `true`),
- `enable_ssm_interface_endpoint` (bool, default `true`),
- `vpc_id` (string),
- `private_subnet_ids` (list(string)),
- `sg_app_id` (string) — SG aplikacyjna ECS/Lambda (źródło ruchu),
- `tags` (map(string)).

Outputs:

- `secretsmanager_interface_endpoint_id` (string),
- `ssm_interface_endpoint_id` (string),
- `endpoints_security_group_id` (string).

---

## 5. VPC Flow Logs — design (W05-T03)

### 5.1 Zakres i destination

Zakres (dev-only):

- w pierwszym kroku:
  - **Flow Logs na poziomie VPC** — obejmują cały ruch w VPC dev,
  - to prostsze operacyjnie niż wybiórcze włączanie per subnet.
- W przyszłości (opcjonalnie):
  - możliwość przejścia na poziom subnetów (np. tylko private) dla bardziej granularnej analizy.

Destination:

- Domyślnie:
  - **CloudWatch Logs**:
    - prostsze ad hoc troubleshooting,
    - łatwa integracja z CloudWatch Logs Insights.
- Alternatywnie:
  - **S3**:
    - tańsze przy dużej ilości logów,
    - wymaga dodatkowego narzędzia do analizy (Athena, zewnętrzne narzędzia).

Dla dev-only, przy relatywnie małym ruchu, wybieramy:

- Flow Logs → **CloudWatch Logs** z krótką retencją (np. 7–14 dni).

### 5.2 Co logujemy: ACCEPT vs REJECT vs ALL

Filtr:

- Początkowo:
  - `ACCEPT`:
    - widzimy, jaki ruch „przechodzi” (w tym ruch przez endpointy/NAT),
    - wystarczające do większości analiz „co się faktycznie dzieje”.
- W przypadku problemów:
  - można tymczasowo przełączyć na `ALL`:
    - widoczność też dla pakietów odrzuconych (np. przez NACL/SG),
    - kosztowo droższe, więc traktowane jako tryb diagnostyczny.

### 5.3 Integracja z modułem `network-endpoints`

Zmienne konfiguracyjne (propozycja):

- `enable_flow_logs` (bool, default `true`),
- `flow_logs_destination_type` (string: `"cloudwatch"` lub `"s3"`),
- `flow_logs_log_group_name` (string, gdy `cloudwatch`),
- `flow_logs_s3_bucket_arn` (string, gdy `s3`),
- `flow_logs_retention_in_days` (number, np. 7),
- `flow_logs_traffic_type` (string: `"ACCEPT"` / `"REJECT"` / `"ALL"`).

Flow Logs mogą być tworzone w tym samym module (`network-endpoints`), ponieważ:

- korzystają z `vpc_id` (jak endpointy),
- są logicznie powiązane z widocznością ruchu i troubleshootingiem endpointów.

---

## 6. Tabela „kiedy który endpoint?” (W05-T01/D4)

Poniższa tabela mapuje nasze główne scenariusze na sposób dostępu do usług:

```
Scenariusz                           │ Ścieżka sieciowa                        │ Mechanizm               │ Uzasadnienie
─────────────────────────────────────┼──────────────────────────────────────────┼────────────────────────┼────────────────────────────────────────────────────────────
ECS/Lambda (private) → S3           │ private → Gateway EP → S3               │ Gateway Endpoint       │ Bez NAT, prywatny ruch w AWS, brak kosztu endpointu
ECS/Lambda (private) → DynamoDB    │ private → Gateway EP → DynamoDB         │ Gateway Endpoint       │ Jak wyżej, niskie koszty, prywatny dostęp
ECS/Lambda (private) → Secrets     │ private → ENI endpointu → Secrets       │ Interface Endpoint     │ Dostęp do sekretów po prywatnym IP, bez NAT/Internetu
ECS/Lambda (private) → SSM         │ private → ENI endpointu → SSM           │ Interface Endpoint     │ Prywatny dostęp do parametrów konfiguracyjnych
ECS/Lambda (private) → SQS/SNS     │ private → NAT → IGW → usługa            │ NAT (opcjonalnie EP)   │ Na start przez NAT; endpointy ewentualnie jako rozszerzenie
ECS/Lambda (private) → ECR         │ private → NAT → IGW → ECR               │ NAT (opcjonalnie EP)   │ Na start przez NAT (wystarczające na kurs)
ECS/Lambda (private) → CloudWatch  │ private → NAT → IGW → CloudWatch        │ NAT                    │ NAT wystarcza dla logów/metryk
ECS/Lambda (private) → zewn. API   │ private → NAT → IGW → Internet          │ NAT                    │ Brak endpointu, ruch musi wyjść do Internetu
```

Wnioski:

- **Gateway Endpoint**:
  - zawsze, gdy usługa go wspiera (S3/DynamoDB) i dostęp jest z private,
  - minimalizuje koszty NAT i poprawia bezpieczeństwo.
- **Interface Endpoint**:
  - dla usług sensytywnych (sekrety, konfiguracja) oraz gdy chcemy unikać Internetu,
  - akceptujemy koszt stały za lepszy model bezpieczeństwa (Secrets/SSM).
- **NAT**:
  - fallback i ścieżka dla usług bez endpointu oraz dla zewnętrznych API.

---

## 7. Typowe pułapki (do wykorzystania w runbooku, W05-T05)

1. **Gateway Endpoint nie działa (ruch nadal przez NAT)**:
   - brak trasy do endpointu w route table private (`prefix S3/DynamoDB → vpce-...`),
   - aplikacja korzysta z niestandardowego endpointu/DNS, który nie jest objęty prefiksami endpointu,
   - Flow Logs pokazują ruch do NAT zamiast endpointu dla S3/DynamoDB.

2. **Interface Endpoint nie działa (timeout/403)**:
   - `private_dns_enabled = false` i aplikacja korzysta z publicznego hostname’u (trafienie do Internetu zamiast endpointu),
   - zbyt restrykcyjny SG endpointu (brak ingress z `sg_app` na 443),
   - endpoint utworzony tylko w jednej AZ, a ruch pochodzi z drugiej (w zależności od usługi).

3. **Koszty Interface Endpointów**:
   - zbyt wiele endpointów w dev, mimo że wystarczyłyby 2 (Secrets/SSM),
   - brak cleanupu (endpointy i Flow Logs zostają na długo po zakończeniu ćwiczeń) — sprzeczne z ADR-0002.

4. **Flow Logs nie pomagają w debugowaniu**:
   - Flow Logs wyłączone (`enable_flow_logs = false`),
   - zbyt krótka retencja (logi zdążyły wygasnąć),
   - filtr ograniczony do `ACCEPT`, gdy problem dotyczy ruchu `REJECT` (NACL/SG).

Te pułapki są adresowane w rozszerzonym `docs/runbooks/network-smoke-tests.md` (W05-T05).

---

## 8. Integracja z dalszymi tygodniami

- **W06** — Terraform foundations + implementacja `network-core`:
  - moduł `network-core` będzie dostarczał outputy (`vpc_id`, `private_route_table_id`, `private_subnet_ids`) zgodnie z designem z W04,
  - `network-endpoints` nie jest jeszcze implementowany.
- **W07** — implementacja `network-endpoints`:
  - na podstawie tego dokumentu powstanie kod HCL modułu,
  - po `terraform apply`:
    - ruch do S3/DynamoDB z private pójdzie przez Gateway Endpoints,
    - ruch do Secrets/SSM przez Interface Endpoints (PrivateLink),
    - Flow Logs będą dostępne w CloudWatch lub S3 jako wsparcie troubleshootingowe.

