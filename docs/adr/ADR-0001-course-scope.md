# ADR-0001 — Zakres kursu i projektu OrderFlow AWS Lab

- **Status:** Accepted  
- **Data:** 2026-02-25  
- **Kontekst:** Kurs „AWS dla Senior .NET Developera (Azure → AWS, DevOps-ready)” realizowany w repo `aws-learning-path` na bazie projektu `OrderFlow AWS Lab`.

---

## 1. Kontekst

- Uczestnik:
  - senior .NET developer (C# / .NET 10+),
  - ma już doświadczenie z chmurą (Azure),
  - celem jest świadome wejście w AWS na poziomie umożliwiającym samodzielne projektowanie i wdrażanie systemów.
- Kurs:
  - horyzont: tygodnie `W00–W24`,
  - tempo: 5 × 1.5h tygodniowo,
  - tryb pracy: project-based learning na jednym systemie domenowym (`OrderFlow AWS Lab`),
  - środowisko: `dev-only` z kontrolą kosztów (świadome decyzje dot. NAT, endpoints, RDS, itp.).
- Środowisko AWS:
  - istniejąca **AWS Organization** (`o-s4cwlsjvht`),
  - OU: `Development`,
  - konto robocze dla kursu: `swpr-dev` (konto deweloperskie w OU Development).
- Projekt kursowy `OrderFlow AWS Lab`:
  - uproszczony system e-commerce (orders + payments),
  - komponenty: APIs, worker, Lambda, kolejki, event bus, storage, baza relacyjna i NoSQL,
  - repo ma być materiałem **portfolio-ready** (architektura, IaC, runbooki, ADR, troubleshooting).
- Narzędzia i ekosystem:
  - IaC: Terraform (modularne `modules/` + `envs/dev/`),
  - CI/CD: GitHub Actions z OIDC do AWS (bez statycznych kluczy),
  - IDE/asystent: Cursor AI z roadmapą jako source of truth.

---

## 2. Decyzja

### 2.1 Zakres techniczny kursu (in scope)

**AWS — MUST (hands-on):**
- Tożsamość i bezpieczeństwo:
  - IAM (users, roles, policies, trust policies),
  - KMS,
  - Secrets Manager,
  - SSM Parameter Store.
- Networking:
  - VPC, subnets (public/private),
  - route tables, Internet Gateway, NAT Gateway,
  - Security Groups, NACL,
  - VPC Endpoints (Gateway + Interface), PrivateLink (praktyka bazowa).
- Hosting / compute:
  - ECS + Fargate (główny model hostingu),
  - Lambda + API Gateway,
  - App Runner (porównanie, „szybki hosting”),
  - Elastic Beanstalk (porównanie PaaS dla .NET).
- Dane i integracje:
  - S3,
  - RDS PostgreSQL,
  - DynamoDB,
  - SQS (+ DLQ),
  - SNS,
  - EventBridge.
- Operacje / obserwowalność:
  - CloudWatch (logs, metrics, alarms, dashboards),
  - CloudTrail — awareness i podstawy.

**.NET 10 (Application):**
- Kilka prostych, pragmatycznych usług Web API:
  - `orders-api`,
  - `payments-api`,
  - `catalog-api`.
- Worker:
  - `order-worker` do asynchronicznego przetwarzania zdarzeń (SQS).
- Lambda:
  - `payment-callback` (.NET 10) za API Gateway.
- Wspólne aspekty:
  - health endpointy,
  - structured logging,
  - podstawy observability (korelacja, metryki bazowe),
  - prosty, „czytelny” kod zamiast over-engineeringu.

**IaC / CI-CD:**
- Terraform:
  - modularna struktura (`modules/`, `envs/dev/`),
  - standards: variables/locals/outputs, tagging, naming,
  - backend remote state w S3.
- GitHub Actions:
  - OIDC do AWS (role + trust policy),
  - pipeline IaC (`plan` + `apply`),
  - pipeline build/push image (ECR),
  - pipeline deploy (ECS i/lub Lambda).

**Security / Networking / Operations:**
- Security baseline:
  - least privilege IAM,
  - zarządzanie sekretami (Secrets Manager / SSM, brak sekretów w repo),
  - przegląd i utwardzanie konfiguracji (security hardening tygodnia W22).
- Networking:
  - zaprojektowana i wdrożona VPC dev z public/private subnetami, routingiem, NAT, endpoints,
  - ingress do ECS przez ALB,
  - podstawowy model przepływów ruchu (Internet → ALB → ECS, ECS → NAT → AWS APIs).
- Observability:
  - dashboardy i alarmy CloudWatch dla kluczowych komponentów (ECS, Lambda, SQS, itp.),
  - min. 3 playbooki troubleshootingowe.

### 2.2 Co jest poza zakresem (świadomie out of scope w tej fazie)

- Zaawansowane tematy governance’owe w Organizations:
  - Control Tower, rozbudowane wzorce SCP, złożone scenariusze multi-account governance — traktowane jako faza 2, poza zakresem core kursu.
- Kubernetes / EKS:
  - EKS traktowany jako potencjalna **faza 2** po ukończeniu core kursu.
- Bardzo zaawansowane usługi security:
  - GuardDuty, Security Hub, Config — ponad awareness/bazowe przykłady.
- Zaawansowane networking enterprise:
  - Transit Gateway, złożone VPN/Direct Connect.
- Złożone frontendy/UI:
  - brak rozbudowanego frontendu; skupienie na backendzie, integracjach i infrastrukturze.

---

## 3. Uzasadnienie (Why)

- Kurs jest skierowany do osoby, która **już umie programować i zna chmurę**, więc nie ma potrzeby budowania od zera fundamentalnych kompetencji programistycznych.
- Największą wartością dla uczestnika są:
  - zrozumienie modeli hostingu .NET w AWS,
  - praktyka z IAM + networking + security,
  - opanowanie Terraform + GitHub Actions z OIDC,
  - umiejętność prowadzenia rozmowy technicznej o realnym systemie (nie tylko o pojedynczych usługach).
- Skupienie zakresu na `OrderFlow AWS Lab` pozwala:
  - spiąć większość kluczowych usług AWS w jednym, sensownym kontekście domenowym,
  - budować portfolio „case’ami” (runbooki, troubleshooting, ADR-y), a nie samym kodem.
- Ograniczenie do `dev-only` z kontrolą kosztów:
  - umożliwia bezpieczne eksperymenty (NAT, endpoints, RDS, SQS, itp.),
  - wymusza świadome decyzje kosztowe (np. 1 NAT vs HA, retencja logów).

---

## 4. Konsekwencje

### 4.1 Pozytywne

- Repo po ukończeniu roadmapy jest:
  - **portfolio-ready** — czytelny README, ADR-y, runbooki, weekly summaries,
  - dobrą bazą do rozmów technicznych o AWS + .NET + DevOps.
- Uczestnik:
  - ma praktyczne doświadczenie z głównymi usługami AWS używanymi w projektach .NET backendowych,
  - rozumie przepływy: od kodu, przez IaC i CI/CD, po operacje i troubleshooting.
- Roadmapa tygodni (`W00–W24`) jest spójna z tym ADR:
  - każdy tydzień wnosi konkretny element do celu kursu,
  - łatwo ocenić DoD całego kursu (sekcja 12 roadmapy).

### 4.2 Negatywne / trade-offy

- Mniejsza głębia w niektórych obszarach:
  - brak pełnego wejścia w EKS oraz zaawansowane security huby (GuardDuty/Security Hub/Config) i pełne Control Tower/SCP governance — to świadomie pozostaje na „faza 2”.
- Silne związanie z jednym projektem:
  - wiedza jest mocno osadzona w domenie `OrderFlow AWS Lab`;
  - wymagane jest mentalne „przetłumaczenie” rozwiązań na inne domeny w przyszłych projektach.

---

## 5. Powiązane dokumenty

- Roadmapa kursu: `docs/roadmap/aws-course-roadmap-operational-0-24.md`
- Główny opis projektu: `README.md`
- Weekly artefakty (plan, tasks, log, evidence, questions, summary): `docs/weekly/Wxx/`
- Szablony:
  - `docs/lessons/_template.md`
  - `docs/troubleshooting/_template.md`

