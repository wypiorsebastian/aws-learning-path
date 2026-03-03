# Network Smoke Tests — checklisty diagnostyczne (W04-T04)

Checklista kroków diagnostycznych przy problemach sieciowych w VPC dev (routing, SG, NACL). Input: W04-T01 (modele ruchu), W04-T03 (baseline SG/NACL).

Docelowe rozszerzenie: W05-T05 (VPC Endpoints, Flow Logs).

---

## 1. Kolejność diagnostyki

1. **Routing** — czy pakiety docierają do właściwego miejsca (route tables)?
2. **Security Groups** — czy SG pozwala na dany ruch (ingress/egress)?
3. **NACL** — czy NACL nie blokuje ruchu (w tym ephemeral ports)?

---

## 2. Objawy i możliwe przyczyny

### 2.1 502 Bad Gateway / 504 Gateway Timeout na ALB

| # | Sprawdź | Co weryfikować |
|---|---------|----------------|
| 1 | Targety w target group | Czy targety są healthy? Czy port targetu (np. 8080) zgadza się z aplikacją? |
| 2 | SG ALB | Egress do sg_app:8080 — czy ALB może wysłać ruch do targetów? |
| 3 | SG ECS/Lambda | Ingress z sg_alb:8080 — czy targety przyjmują ruch z ALB? |
| 4 | Route table public | 0.0.0.0/0 → IGW — czy ruch z Internetu dociera do ALB? |
| 5 | Route table private | Czy private subnety mają trasę do NAT (dla health checków ALB, jeśli używane)? |
| 6 | NACL | Czy NACL public/private nie blokuje ruchu ALB→target lub return (ephemeral)? |

### 2.2 Brak odpowiedzi z aplikacji w ECS (target unreachable)

| # | Sprawdź | Co weryfikować |
|---|---------|----------------|
| 1 | ECS task — ENI | Czy task ma przypisany ENI w private subnet? Czy task jest w stanie Running? |
| 2 | SG ALB → sg_app | Czy sg_alb ma egress do sg_app na porcie aplikacji? |
| 3 | SG sg_app | Czy sg_app ma ingress z sg_alb na porcie aplikacji? |
| 4 | Subnet association | Czy ALB ma ENI w public-a i public-b? Czy targety są w private-a/private-b? |
| 5 | Route table private | local + 0.0.0.0/0 → NAT — czy private subnety routują poprawnie? |
| 6 | NACL | Czy NACL private ma allow ingress z public (10.0.1.0/24, 10.0.2.0/24) na port aplikacji? Czy ephemeral return jest allow? |

### 2.3 Brak wyjścia do Internetu z ECS (timeout przy SQS, S3, zewn. API)

| # | Sprawdź | Co weryfikować |
|---|---------|----------------|
| 1 | Route table private | Czy 0.0.0.0/0 kieruje do NAT Gateway? |
| 2 | NAT Gateway | Czy NAT istnieje w public-a i jest w stanie Available? |
| 3 | SG sg_app | Egress 443, 80 do 0.0.0.0/0 — czy jest allow? |
| 4 | NACL private egress | Czy NACL pozwala na egress 443, 80, ephemeral? |
| 5 | NACL private ingress | Czy NACL pozwala na return (ephemeral 1024–65535) z 0.0.0.0/0? |
| 6 | IGW | Czy IGW jest przypięty do VPC? Czy public route table ma 0.0.0.0/0 → IGW? |
| 7 | Gateway Endpoint | Czy ruch do S3/DynamoDB idzie przez Gateway EP (route table), a nie przez NAT? |

### 2.4 ECS nie może połączyć się z RDS

| # | Sprawdź | Co weryfikować |
|---|---------|----------------|
| 1 | SG sg_rds | Ingress z sg_app:5432 — czy RDS przyjmuje ruch z ECS? |
| 2 | SG sg_app | Egress do sg_rds:5432 — czy ECS może wysłać ruch do RDS? |
| 3 | RDS subnet group | Czy RDS jest w private-a i private-b (te same subnety co ECS)? |
| 4 | Route table private | local — ruch wewnątrz VPC nie wychodzi; czy oba są w tej samej VPC? |
| 5 | NACL private | Czy NACL pozwala na ruch 5432 w obu kierunkach (lub ephemeral return)? |

### 2.5 Lambda w VPC nie może wyjść do AWS APIs / RDS

| # | Sprawdź | Co weryfikować |
|---|---------|----------------|
| 1 | Lambda — subnets | Czy Lambda ma subnet_ids = private-a, private-b? |
| 2 | Lambda — SG | Czy sg_app (lub odpowiedni SG) jest przypięty do Lambda? |
| 3 | Route table private | 0.0.0.0/0 → NAT — czy private subnety routują do NAT? |
| 4 | NAT Gateway | Czy NAT jest Available? |
| 5 | Cold start / ENI | Lambda w VPC tworzy ENI — czy są wolne adresy IP w private subnetach? |

### 2.6 Ruch do S3/DynamoDB idzie przez NAT zamiast przez Gateway Endpoint (lub 403/timeout)

| # | Sprawdź | Co weryfikować |
|---|---------|----------------|
| 1 | Gateway Endpoint S3/DynamoDB | Czy endpointy istnieją i są w stanie Available? |
| 2 | Route table private | Czy istnieją trasy `prefix S3/DynamoDB → vpce-...`? Czy nie zostały przypadkowo usunięte/zmienione? |
| 3 | NAT vs endpoint | W Flow Logs (gdy włączone) sprawdź, czy ruch do adresów S3/DynamoDB trafia na NAT, czy na endpoint (destination). |
| 4 | DNS aplikacji | Czy aplikacja używa standardowych hostname’ów S3/DynamoDB (a nie twardo wpisanych IP/niestandardowych domen)? |

### 2.7 Problemy z Interface Endpointami (Secrets Manager / SSM)

| # | Sprawdź | Co weryfikować |
|---|---------|----------------|
| 1 | Interface Endpoint | Czy endpointy Secrets/SSM istnieją, są w stanie Available i są przypięte do `private-a`/`private-b`? |
| 2 | SG endpointów | Czy SG endpointów ma ingress z `sg_app` na 443 i właściwy egress (443 do 0.0.0.0/0 lub odpowiednich prefixów AWS)? |
| 3 | Private DNS | Czy `private_dns_enabled = true`? Jeśli nie, czy aplikacja używa endpoint-specyficznego hostname’u (`vpce-...`)? |
| 4 | Ruch w Flow Logs | Czy w VPC Flow Logs widać próby połączeń z ECS/Lambda do ENI endpointów (status `ACCEPT`/`REJECT`)? |

---

## 3. Szybka checklista: „co sprawdzić w kolejności”

1. **Czy routing jest poprawny?**  
   Route tables: public (0.0.0.0/0 → IGW), private (0.0.0.0/0 → NAT, local, prefix S3/DynamoDB gdy Gateway EP).

2. **Czy SG pozwala na ruch?**  
   Ingress i egress dla każdej pary (ALB↔ECS, ECS↔RDS, ECS↔0.0.0.0/0).

3. **Czy NACL nie blokuje?**  
   NACL stateless — sprawdź oba kierunki. **Ephemeral 1024–65535** w ingress i egress.

4. **Czy zasób jest w dobrym subnecie?**  
   ALB w public, ECS/RDS/Lambda w private. Subnet association.

5. **Czy NAT/IGW działają?**  
   NAT w stanie Available, IGW przypięty do VPC.

6. **Czy endpointy działają poprawnie?**  
   Gateway: trasy do S3/DynamoDB w route table private, brak niepotrzebnego ruchu przez NAT.  
   Interface: endpointy w private subnetach, poprawne SG, włączone Private DNS (o ile oczekiwane).

7. **Czy VPC Flow Logs pomagają zdiagnozować problem?**  
   Sprawdź w Flow Logs, czy widzisz ruch `ACCEPT`/`REJECT` dla problematycznego połączenia; w razie potrzeby tymczasowo ustaw `traffic_type = ALL`.

---

## 4. Przydatne komendy AWS CLI (referencja)

```bash
# Route tables i associations
aws ec2 describe-route-tables --filters "Name=vpc-id,Values=<vpc-id>"

# Security Groups
aws ec2 describe-security-groups --group-ids <sg-id>

# NACL
aws ec2 describe-network-acls --filters "Name=vpc-id,Values=<vpc-id>"

# NAT Gateway status
aws ec2 describe-nat-gateways --filter "Name=vpc-id,Values=<vpc-id>"

# Subnet associations
aws ec2 describe-subnets --filters "Name=vpc-id,Values=<vpc-id>"

# VPC Flow Logs (lista)
aws ec2 describe-flow-logs --filter "Name=resource-id,Values=<vpc-id>"
```
