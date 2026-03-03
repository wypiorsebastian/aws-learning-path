## W04 — Baseline SG i NACL (W04-T03)

Projekt minimalnego zestawu Security Groups i NACL dla VPC dev, spójny z modelami przepływu ruchu (W04-T01).

**Input:** `docs/lessons/W04-traffic-models.md`, roadmapa W04 (pułapki: NACL blokujące ephemeral ports).

---

## 1. Security Groups — tabela i reguły

### 1.1 SG ALB (`sg_alb`)

| Kierunek | Źródło / Cel | Port | Cel scenariusza |
|----------|--------------|------|------------------|
| Ingress | 0.0.0.0/0 | 80 | A1: Internet → ALB |
| Ingress | 0.0.0.0/0 | 443 | A1: Internet → ALB |
| Egress | sg_app (SG ECS/Lambda) | 8080 | A2: ALB → ECS/Lambda |

**Przypięte do:** ALB (public-a, public-b).

**Uzasadnienie:** Ingress tylko HTTP/HTTPS; egress wyłącznie do backendu (least privilege).

---

### 1.2 SG ECS/Lambda (`sg_app`)

Współdzielony przez ECS Fargate i Lambda w VPC (obie grupy mają ten sam wzorzec ruchu).

| Kierunek | Źródło / Cel | Port | Cel scenariusza |
|----------|--------------|------|------------------|
| Ingress | sg_alb | 8080 | A2: ALB → ECS/Lambda |
| Egress | sg_rds | 5432 | A3: ECS/Lambda → RDS |
| Egress | 0.0.0.0/0 | 443 | B1–B4, C1: S3, DynamoDB, Secrets, SSM, SQS, SNS, CW, ECR, API |
| Egress | 0.0.0.0/0 | 80 | C1: HTTP (nuget, package feeds itp.) |

**Przypięte do:** ECS tasks, Lambda (gdy w VPC).

**Uzasadnienie:** Ingress tylko z ALB; egress do RDS i usług AWS/Internet. SG jest stateful — ruch zwrotny jest automatycznie dozwolony.

---

### 1.3 SG RDS (`sg_rds`)

| Kierunek | Źródło / Cel | Port | Cel scenariusza |
|----------|--------------|------|------------------|
| Ingress | sg_app | 5432 | A3: ECS/Lambda → RDS |
| Egress | — | — | RDS nie inicjuje ruchu; można pominąć lub zostawić domyślny |

**Przypięte do:** RDS PostgreSQL (subnet group private-a, private-b).

**Uzasadnienie:** RDS przyjmuje tylko ruch z aplikacji na 5432.

---

### 1.4 SG dla Interface Endpoints (W05)

W W05 będą tworzone SG dla Interface Endpointów (Secrets Manager, SSM). Na potrzeby W04 zapisujemy założenie:

| SG | Ingress | Cel scenariusza |
|----|---------|------------------|
| sg_endpoint_secrets | sg_app:443 | B3, B4: ECS/Lambda → Interface Endpoint |

Implementacja w modułach `network-endpoints` (W05).

---

## 2. NACL — rekomendacja dla dev

### 2.1 Pułapka z roadmapy

**NACL blokujące ephemeral ports** — ruch zwrotny (odpowiedzi z RDS, S3, Internetu) przychodzi na porty 1024–65535. NACL jest stateless: trzeba jawnie zezwolić na ephemeral w obu kierunkach.

### 2.2 Rekomendacja: domyślny NACL VPC (Opcja A)

- **Domyślny NACL VPC** ma regułę `*` allow dla ingress i egress.
- Nie blokuje ephemeral ports.
- Brak dodatkowej złożoności w dev.

**Decyzja:** W dev używamy **domyślnego NACL VPC**. Nie tworzymy własnych NACL. Dokumentujemy to jako świadomy baseline.

### 2.3 Alternatywa: własne NACL (Opcja B — przyszły hardening)

Jeśli w przyszłości (np. hardening W22) będzie potrzebny restrykcyjniejszy NACL, należy:

1. **NACL public:**
   - Ingress: 80, 443 z 0.0.0.0/0; ephemeral 1024–65535 z 0.0.0.0/0 i 10.0.0.0/16.
   - Egress: 80, 443 do 0.0.0.0/0; 8080 do 10.0.11.0/24, 10.0.12.0/24; ephemeral 1024–65535 do 0.0.0.0/0.

2. **NACL private:**
   - Ingress: 8080 z 10.0.1.0/24, 10.0.2.0/24; 5432 z 10.0.11.0/24, 10.0.12.0/24; 443 z 10.0.0.0/16; ephemeral 1024–65535 z 0.0.0.0/0 i 10.0.0.0/16.
   - Egress: 5432, 443, 80 do 0.0.0.0/0 i 10.0.0.0/16; ephemeral 1024–65535 do 0.0.0.0/0.

**Uwaga:** Numeracja i zakresy portów muszą być zgodne z limitami AWS NACL. Kluczowe jest jawne allow ephemeral w obu kierunkach.

---

## 3. Tabela SG/NACL (zbiorcza)

| Zasób | Typ | Przypięte do | Główne reguły |
|-------|-----|--------------|---------------|
| sg_alb | SG | ALB | Ingress: 80, 443 z 0.0.0.0/0. Egress: 8080 do sg_app. |
| sg_app | SG | ECS, Lambda | Ingress: 8080 z sg_alb. Egress: 5432 do sg_rds; 443, 80 do 0.0.0.0/0. |
| sg_rds | SG | RDS | Ingress: 5432 z sg_app. Egress: domyślny. |
| nacl_public | NACL | public-a, public-b | **Baseline dev:** domyślny NACL VPC (allow all). Opcja B: własny NACL — patrz sekcja 2.3. |
| nacl_private | NACL | private-a, private-b | **Baseline dev:** domyślny NACL VPC. Opcja B: własny NACL — patrz sekcja 2.3. |

---

## 4. Spójność z modelami ruchu

| Scenariusz | SG | NACL (baseline) |
|------------|----|------------------|
| A1: Internet → ALB | sg_alb ingress 80, 443 | Domyślny allow |
| A2: ALB → ECS | sg_alb egress → sg_app:8080; sg_app ingress z sg_alb:8080 | Domyślny allow |
| A3: ECS → RDS | sg_app egress → sg_rds:5432; sg_rds ingress z sg_app:5432 | Domyślny allow |
| B1–B4, C1: ECS → AWS/Internet | sg_app egress 443, 80 | Domyślny allow |
| C2: ruch zwrotny | SG stateful — return automatyczny | Domyślny NACL — ephemeral allow |

---

## 5. Port aplikacji (8080)

W przykładach użyto portu **8080** jako typowego portu aplikacji .NET. W implementacji można wprowadzić zmienną (np. `app_port`) dla elastyczności.
