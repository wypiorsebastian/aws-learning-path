## W04 — Modele przepływu ruchu (W04-T01)

Model przepływu ruchu dla VPC dev projektu OrderFlow AWS Lab, na bazie topologii z W03 (`docs/diagrams/vpc-dev.md`). Input do projektowania route tables, SG i NACL w W04-T02/T03.

---

## 1. Inwentarz elementów składowych

### 1.1 Elementy sieciowe (VPC)

| Element | Lokalizacja | Typ | Rola |
|---------|-------------|-----|------|
| VPC | 10.0.0.0/16 | kontener | Izolacja sieciowa projektu |
| IGW | VPC | brama | Ruch publiczny ↔ Internet |
| NAT Gateway | public-a (eu-central-1a) | brama | Ruch wychodzący z private → Internet (fallback) |
| public-a | 10.0.1.0/24, eu-central-1a | subnet | ALB, NAT |
| public-b | 10.0.2.0/24, eu-central-1b | subnet | ALB |
| private-a | 10.0.11.0/24, eu-central-1a | subnet | ECS, RDS, Lambda, Interface Endpoints |
| private-b | 10.0.12.0/24, eu-central-1b | subnet | ECS, RDS, Lambda, Interface Endpoints |

### 1.2 Komponenty aplikacyjne

| Komponent | Typ | Subnet(y) | Producent ruchu | Konsument ruchu |
|-----------|-----|-----------|-----------------|-----------------|
| ALB | load balancer | public-a, public-b | Internet | ECS, Lambda |
| ECS Fargate | compute (orders-api, payments-api, catalog-api, order-worker) | private-a, private-b | ALB | RDS, S3, DynamoDB, Secrets Manager, SSM, SQS, SNS, EventBridge, CloudWatch, ECR, zewn. API |
| Lambda payment-callback | serverless | private-a, private-b | API Gateway (zewn.) lub wewn. | RDS, Secrets Manager, SSM, SQS/SNS, zewn. API |
| RDS PostgreSQL | baza danych | private-a, private-b | ECS, Lambda | — |

### 1.3 Usługi AWS (poza VPC) — dostęp z private

| Usługa | Ścieżka | W05 |
|--------|---------|-----|
| S3 | Gateway Endpoint (route table) | tak |
| DynamoDB | Gateway Endpoint (route table) | tak |
| Secrets Manager | Interface Endpoint (ENI w private-a/b) | tak |
| SSM Parameter Store | Interface Endpoint (ENI w private-a/b) | tak |
| SQS, SNS, EventBridge | NAT | opcjonalnie endpointy |
| CloudWatch Logs/Metrics | NAT | — |
| ECR | NAT | opcjonalnie endpoint |

---

## 2. Scenariusze przepływu ruchu

### 2.1 Ruch przychodzący (Internet → aplikacja)

| # | Producent | Konsument | Ścieżka | Port(y) | SG | NACL |
|---|-----------|-----------|---------|---------|----|------|
| A1 | Internet | ALB | IGW → public-a/b | 80, 443 | SG ALB (ingress 0.0.0.0/0:80,443) | NACL public ingress |
| A2 | ALB | ECS/Lambda | public → private-a/b | 8080, 80, app | SG ECS/Lambda (ingress z SG ALB) | NACL private ingress z public |

### 2.2 Ruch wewnętrzny (private → private)

| # | Producent | Konsument | Ścieżka | Port(y) | SG | NACL |
|---|-----------|-----------|---------|---------|----|------|
| A3 | ECS/Lambda | RDS | private-a/b → private-a/b | 5432 | SG RDS (ingress z SG ECS/Lambda) | NACL private (wewnątrz VPC) |

### 2.3 Ruch wychodzący (private → usługi AWS) — endpoint-first

| # | Producent | Konsument | Ścieżka | Port(y) | SG | NACL |
|---|-----------|-----------|---------|---------|----|------|
| B1 | ECS/Lambda | S3 | prefix S3 → Gateway EP | 443 | — | NACL private egress |
| B2 | ECS/Lambda | DynamoDB | prefix DynamoDB → Gateway EP | 443 | — | NACL private egress |
| B3 | ECS/Lambda | Secrets Manager | private → ENI endpointu | 443 | SG endpointu (ingress z SG ECS/Lambda) | NACL private egress |
| B4 | ECS/Lambda | SSM | private → ENI endpointu | 443 | SG endpointu (ingress z SG ECS/Lambda) | NACL private egress |

### 2.4 Ruch wychodzący (private → Internet) — NAT fallback

| # | Producent | Konsument | Ścieżka | Port(y) | SG | NACL |
|---|-----------|-----------|---------|---------|----|------|
| C1 | ECS/Lambda | SQS, SNS, EventBridge, CloudWatch, ECR, zewn. API | private → NAT (public-a) → IGW | 443, 80, ephemeral | SG ECS/Lambda (egress) | NACL private egress, ephemeral return |

### 2.5 Ruch zwrotny (odpowiedzi)

| # | Kierunek | Uwagi |
|---|----------|-------|
| C2 | IGW/NAT/endpoint → private | Porty efemeryczne 1024–65535. SG stateful — return automatyczny. NACL stateless — trzeba jawnie allow ephemeral. |

---

## 3. Macierz „kto z kim przez co”

```
                    │ Internet │ ALB  │ ECS/Lambda │ RDS  │ S3/DynamoDB │ Secrets/SSM │ SQS/SNS/CW/ECR/API │
────────────────────┼──────────┼──────┼────────────┼──────┼─────────────┼─────────────┼────────────────────┤
Internet            │    —     │ IGW  │     —      │  —   │      —      │      —      │        —           │
ALB (public)        │    —     │  —   │  direct    │  —   │      —      │      —      │        —           │
ECS/Lambda (private)│    —     │  —   │    —       │ VPC  │ Gateway EP  │ Interface EP│       NAT           │
RDS (private)       │    —     │  —   │  VPC       │  —   │      —      │      —      │        —           │
```

---

## 4. Route tables (synteza)

| Subnet | Kierunek | Trasa | Cel |
|--------|----------|-------|-----|
| public-a, public-b | ingress | 0.0.0.0/0 → IGW | ruch z Internetu do ALB |
| public-a, public-b | egress | local + 0.0.0.0/0 → IGW | ALB → Internet |
| private-a, private-b | egress | local + prefix S3 → Gateway EP | S3 (W05) |
| private-a, private-b | egress | prefix DynamoDB → Gateway EP | DynamoDB (W05) |
| private-a, private-b | egress | 0.0.0.0/0 → NAT | SQS, SNS, CW, ECR, zewn. API |

Secrets Manager, SSM: DNS rozwiązuje się do prywatnego IP Interface Endpointu — ruch przez VPC local.

---

## 5. Stateful vs stateless

| Element | Typ | Skutek |
|---------|-----|--------|
| SG | stateful | Allow egress → automatyczny return; nie trzeba osobnej reguły ingress dla odpowiedzi |
| NACL | stateless | Osobne reguły ingress i egress; dla ephemeral ports (1024–65535) w obu kierunkach |
| Routing | stateless | Kierunek „tam”; powrót po tej samej ścieżce |

---

## 6. Pułapki (z roadmapy W04)

- **NACL blokujące ephemeral ports** — ruch zwrotny (np. odpowiedź z RDS, S3, Internetu) przychodzi na port efemeryczny; NACL stateless musi mieć allow.
- **Route table associations** — każdy subnet musi mieć skojarzoną route table; łatwo pominąć przy wielu subnetach.
- **Cross-AZ** — ruch z private-b do NAT w public-a przechodzi między AZ; większe opóźnienie i koszt transferu.
