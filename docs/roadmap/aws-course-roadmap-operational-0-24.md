# AWS dla Senior .NET Developera (Azure → AWS, DevOps-ready)
## Roadmapa operacyjna 0–24 (wersja do pracy w Cursor AI)

---

## Dokument — metadane globalne

- **DocumentId:** `AWS-NET8-ROADMAP-OPS-0-24`
- **Wersja:** `1.0`
- **Status:** `Aktywny`
- **Autor programu:** ChatGPT (na podstawie wymagań użytkownika)
- **Uczestnik:** Senior .NET Developer (C# / .NET 10+) z doświadczeniem w Azure
- **Język pracy:** Polski
- **Tryb nauki:** Project-based learning (ciągły projekt)
- **Tempo:** 5 × 1.5h tygodniowo (7.5h / tydzień)
- **Horyzont:** Tydzień `0`–`24`
- **Środowisko:** `dev-only` (świadome ograniczenia kosztowe)
- **IaC:** Terraform
- **CI/CD:** GitHub Actions + OIDC do AWS
- **IDE/Asystent:** Cursor AI
- **Projekt kursowy:** `OrderFlow AWS Lab` (e-commerce: orders + payments)

---

## 1. Wstęp (kontekst uczestnika)

Jesteś **senior .NET developerem** z doświadczeniem w **Azure**. Masz już kompetencje cloudowe, ale chcesz wejść w **AWS** w sposób praktyczny i uporządkowany, bez utraty kontekstu projektu.

Ten kurs:
- **nie jest kursem „od zera w IT”**,
- zakłada, że umiesz programować, projektować systemy i pracować z chmurą,
- koncentruje się na **przeniesieniu i rozszerzeniu** Twoich kompetencji na AWS,
- ma równolegle budować profil **DevOps-ready**.

---

## 2. Cel kursu

### Cel główny
Nauczyć się AWS praktycznie jako senior .NET developer, aby:
- zwiększyć kompetencje cloudowe,
- zwiększyć atrakcyjność na rynku pracy,
- umieć samodzielnie projektować i wdrażać aplikacje .NET w AWS,
- rozwinąć profil w kierunku DevOps / Cloud Engineer.

### Cele końcowe (Course Outcomes)
Po ukończeniu kursu uczestnik powinien umieć:
1. Zaprojektować i wdrożyć środowisko `dev` w AWS (VPC, subnety, routing, NAT, SG/NACL, endpoints).
2. Wdrożyć .NET 10+ w wielu modelach hostingu AWS:
   - App Runner,
   - Elastic Beanstalk,
   - ECS Fargate,
   - Lambda + API Gateway.
3. Zbudować modularne IaC w Terraform + pipeline’y GitHub Actions (OIDC).
4. Użyć IAM, KMS, Secrets Manager, SSM Parameter Store w praktyce.
5. Zbudować flow event-driven (SQS, SNS, EventBridge) z retry/DLQ.
6. Skonfigurować podstawową obserwowalność (CloudWatch logs/metrics/alarms).
7. Przygotować repo i dokumentację w formie portfolio technicznego.

---

## 3. Opis projektu kursowego — `OrderFlow AWS Lab`

### Cel projektu
Zbudować uproszczony system e-commerce (orders + payments), który posłuży jako **nośnik nauki AWS** i pozwoli przejść przez najważniejsze usługi, wzorce architektoniczne, modele hostingu, security, IaC i CI/CD.

### Domena (uproszczona)
- **Orders** — tworzenie i obsługa zamówień
- **Payments** — inicjacja i callback płatności
- **Catalog** — prosty katalog produktów
- **Notifications** — przetwarzanie zdarzeń / komunikaty
- **Async Processing** — worker + kolejki + event bus

### Docelowe komponenty (repo)
- `orders-api` (.NET 10 Web API)
- `payments-api` (.NET 10 Web API)
- `catalog-api` (.NET 10 Web API)
- `order-worker` (.NET worker)
- `payment-callback` (.NET 10 Lambda)
- `shared contracts / primitives`
- `infra/terraform`
- `.github/workflows`
- `docs/*` (runbooki, ADR, troubleshooting, evidence)

---

## 4. Serwisy AWS objęte kursem (lista docelowa)

### 4.1 MUST (hands-on)
#### Tożsamość i bezpieczeństwo
- IAM (Users / Roles / Policies / Trust Policies)
- KMS
- Secrets Manager
- SSM Parameter Store

#### Networking
- VPC
- Subnets (public/private)
- Route Tables
- Internet Gateway
- NAT Gateway
- Security Groups
- NACL
- VPC Endpoints (Gateway + Interface)
- PrivateLink (mechanizm + praktyka bazowa)

#### Hosting / Compute
- ECS
- Fargate
- ECR
- Lambda
- API Gateway

#### Dane i integracje
- S3
- RDS (PostgreSQL)
- DynamoDB
- SQS
- SNS
- EventBridge

#### Operacje / obserwowalność
- CloudWatch (Logs / Metrics / Alarms / Dashboards)
- CloudTrail (awareness + podstawy)

#### Delivery / IaC
- Terraform
- GitHub Actions (OIDC do AWS)

### 4.2 SHOULD (praktyka bazowa / porównanie)
- App Runner
- Elastic Beanstalk
- WAF (praktyka bazowa)
- Shield (awareness)
- Route 53 (opcjonalnie praktyka)
- CloudFront (awareness / opcjonalnie praktyka)
- OpenTelemetry / ADOT (podstawy operacyjne)

### 4.3 NICE / później (po kursie core)
- EKS (moduł rozszerzający)
- Step Functions
- AWS Config / GuardDuty / Security Hub (głębiej)
- Organizations / Control Tower / SCP
- Advanced networking (TGW / VPN enterprise)

---

## 5. Jak używać tego dokumentu w Cursor AI (operacyjnie)

### Zasada pracy tygodniowej
Każdy tydzień realizujesz w cyklu:
1. **Plan**
2. **Implementacja**
3. **Deploy**
4. **Weryfikacja**
5. **Troubleshooting**
6. **Notatki + cleanup**

### Co robić na początku każdego tygodnia
- Przeczytaj sekcję tygodnia `Wxx`
- Uzupełnij statusy tasków na `TODO`
- Sprawdź `Prereq`
- Zdefiniuj sesje D1–D5 (1.5h każda)
- Ustal zakres minimum (MVP tygodnia)

### Co robić na końcu każdego tygodnia
- Zamknij checklistę DoD tygodnia
- Uzupełnij `docs/lessons/Wxx-summary.md`
- Dodaj wpisy do `docs/troubleshooting/*` (jeśli były problemy)
- Zrób cleanup / wyłącz kosztowne zasoby
- Zapisz „Next actions” na kolejny tydzień

---

## 6. Statusy i legenda (do odhaczania)

### Statusy zadań
- `[ ] TODO`
- `[~] W TRAKCIE`
- `[x] DONE`
- `[!] BLOCKED`
- `[-] SKIPPED (świadomie)`

### Priorytety
- `P1` — obowiązkowe (bez tego tydzień niezaliczony)
- `P2` — ważne
- `P3` — opcjonalne / stretch

### Typy zadań
- `Theory`
- `Design`
- `IaC`
- `Coding`
- `Deploy`
- `CI/CD`
- `Security`
- `Observability`
- `Troubleshooting`
- `Docs`

---

## 7. Metadane — schemat tygodnia i zadania (stały standard)

### 7.1 Metadane tygodnia (schema)
Każdy tydzień zawiera:
- **WeekId**
- **Faza**
- **Nazwa**
- **Cel tygodnia**
- **WhyNow**
- **Zakres AWS**
- **Zakres .NET**
- **Zakres Terraform / CI-CD**
- **Zakres Networking / Security**
- **Prereq**
- **Outcome**
- **Artefakty repo**
- **Evidence**
- **Pułapki**
- **Koszt / Cleanup**
- **Definicja ukończenia (DoD)**

### 7.2 Metadane zadania (schema)
Każdy task zawiera:
- **TaskId**
- **Priorytet**
- **Typ**
- **Cel**
- **Czas**
- **Input**
- **Kroki**
- **Output**
- **Verification**
- **Troubleshooting hints**
- **Evidence path**

---

## 8. Struktura repo (docelowa)

```text
src/
  orders-api/
  payments-api/
  catalog-api/
  workers/
    order-worker/
    notification-worker/
  lambdas/
    payment-callback/
  shared/

infra/
  terraform/
    modules/
    envs/
      dev/

.github/
  workflows/

docs/
  roadmap/
  lessons/
  runbooks/
  troubleshooting/
  adr/
  diagrams/
  evidence/
```

---

## 9. Szablony plików roboczych (obowiązkowe)

### 9.1 Tygodniowe podsumowanie
Plik: `docs/lessons/Wxx-summary.md`

Minimalne sekcje:
- Cel tygodnia
- Co zrobiłem
- Co działa
- Co nie działało
- Jak naprawiłem
- Smoke tests
- Koszt / cleanup
- Wnioski
- Next actions

### 9.2 Troubleshooting note
Plik: `docs/troubleshooting/<topic>-<date>.md`

Minimalne sekcje:
- Objaw
- Kontekst
- Root cause
- Diagnoza (kroki)
- Fix
- Jak poznam, że działa
- Jak zapobiec

### 9.3 Runbook
Plik: `docs/runbooks/<topic>.md`

Minimalne sekcje:
- Cel runbooka
- Kiedy używać
- Prereq
- Kroki
- Weryfikacja
- Typowe błędy
- Rollback / cleanup

---

# 10. Roadmapa operacyjna 0–24 (tydzień po tygodniu)

---

## W00 — Kickoff kursu i kontrakt techniczny projektu

### Metadane tygodnia
- **WeekId:** `W00`
- **Faza:** `Kickoff`
- **Nazwa:** `Start kursu i definicja projektu`
- **Cel tygodnia:** Zdefiniować projekt, repo, standard pracy i artefakty dokumentacyjne
- **WhyNow:** Bez tego później zniknie kontekst i spójność
- **Zakres AWS:** Brak (planowanie)
- **Zakres .NET:** Baseline solution `.NET 10`
- **Zakres Terraform / CI-CD:** Szkielet katalogów
- **Zakres Networking / Security:** Plan zakresu (bez implementacji)
- **Prereq:** GitHub repo, lokalne narzędzia, czas na kickoff
- **Outcome:** Repo-szkielet + roadmapa + szablony dokumentacji
- **Artefakty repo:** `README.md`, `docs/roadmap/*`, `docs/lessons/_template.md`, `src/`, `infra/terraform/`
- **Evidence:** Commit inicjalny + build `.NET` baseline
- **Pułapki:** Brak definicji DoD, brak standardu notatek
- **Koszt/Cleanup:** Brak
- **DoD:** Repo gotowe do rozpoczęcia tygodnia 1

### Zadania
- [ ] **W00-T01 (P1 | Design | 45m)** — Opisz projekt `OrderFlow AWS Lab` w `README.md`
- [ ] **W00-T02 (P1 | Docs | 45m)** — Utwórz szablony `docs/lessons/_template.md` i `docs/troubleshooting/_template.md`
- [ ] **W00-T03 (P1 | Coding/Setup | 30m)** — Utwórz `OrderFlow.sln` + placeholder projekty .NET 10
- [ ] **W00-T04 (P2 | Docs | 30m)** — Utwórz `docs/adr/ADR-0001-course-scope.md`

### Verification (tydzień)
- [ ] `dotnet build` przechodzi lokalnie
- [ ] Repo ma strukturę katalogów zgodną z roadmapą
- [ ] README opisuje projekt, cel i zakres kursu

### Evidence (do zapisania)
- `docs/lessons/W00-summary.md`
- tree repo (tekstowo)
- wynik `dotnet build`

---

## W01 — AWS account bootstrap + narzędzia lokalne

### Metadane tygodnia
- **WeekId:** `W01`
- **Faza:** `Bootstrap AWS`
- **Nazwa:** `Konto AWS, CLI, profile, MFA`
- **Cel tygodnia:** Przygotować bezpieczny baseline pracy z AWS lokalnie
- **WhyNow:** Wszystko później zależy od poprawnej konfiguracji CLI i tożsamości
- **Zakres AWS:** IAM, STS (podstawy praktyczne)
- **Zakres .NET:** Brak zmian funkcjonalnych
- **Zakres Terraform / CI-CD:** Brak
- **Zakres Networking / Security:** Security baseline konta
- **Prereq:** Konto AWS, dostęp do konsoli
- **Outcome:** Działające profile AWS CLI + potwierdzona tożsamość
- **Artefakty repo:** `docs/runbooks/aws-local-setup.md`, `docs/lessons/W01-summary.md`
- **Evidence:** `aws sts get-caller-identity`
- **Pułapki:** Zły region, profile nadpisane, PATH
- **Koszt/Cleanup:** Brak
- **DoD:** CLI działa, runbook lokalnego setupu istnieje

### Zadania
- [ ] **W01-T01 (P1 | Setup/Theory | 60m)** — Zainstaluj / zweryfikuj: AWS CLI, Terraform, Docker, .NET 10 SDK
- [ ] **W01-T02 (P1 | Security | 45m)** — Skonfiguruj profile AWS CLI + region default + MFA (jeśli dostępne)
- [ ] **W01-T03 (P1 | Docs | 30m)** — Spisz `aws-local-setup.md` (kroki + weryfikacja)
- [ ] **W01-T04 (P2 | ADR | 15m)** — `ADR-0002-cost-guardrails-dev.md` (zasady kosztowe dev)

### Verification (tydzień)
- [ ] `aws --version`
- [ ] `terraform version`
- [ ] `dotnet --info`
- [ ] `aws sts get-caller-identity` zwraca poprawną tożsamość

### Evidence
- `docs/lessons/W01-summary.md`
- wersje narzędzi
- wynik STS (bez wrażliwych danych)

---

## W02 — IAM fundamentals dla developera

### Metadane tygodnia
- **WeekId:** `W02`
- **Faza:** `Security Foundation`
- **Nazwa:** `IAM roles, policies, trust policy`
- **Cel tygodnia:** Zrozumieć model uprawnień AWS i przygotować matrycę ról
- **WhyNow:** IAM będzie wszędzie: Terraform, GitHub Actions, ECS, Lambda, secrets
- **Zakres AWS:** IAM, STS
- **Zakres .NET:** Credential chain awareness (koncept)
- **Zakres Terraform / CI-CD:** Plan roli dla GitHub OIDC
- **Zakres Networking / Security:** Least privilege foundation
- **Prereq:** W01 zakończony
- **Outcome:** Matryca ról i zrozumienie IAM as-is
- **Artefakty repo:** `docs/runbooks/iam-role-matrix.md`, `ADR-0003-iam-role-strategy.md`
- **Evidence:** Notatka + przykładowe policy snippets
- **Pułapki:** Mylenie trust policy z permission policy
- **Koszt/Cleanup:** Brak
- **DoD:** Uczestnik potrafi wyjaśnić user/role/policy/trust i zaprojektować role projektu

### Zadania
- [ ] **W02-T01 (P1 | Theory | 45m)** — Notatka: IAM users vs roles vs policies vs trust
- [ ] **W02-T02 (P1 | Design | 45m)** — Matryca ról: local dev / GitHub Actions / ECS task / Lambda execution
- [ ] **W02-T03 (P1 | Docs | 30m)** — Zasada: brak long-lived keys w CI/CD
- [ ] **W02-T04 (P2 | Security | 30m)** — Przygotuj minimalne przykłady policy (S3 read-only, SQS producer)

### Verification
- [ ] `iam-role-matrix.md` zawiera principal, trust, permission scope, usage
- [ ] ADR opisuje strategię least privilege i OIDC-first

### Evidence
- `docs/lessons/W02-summary.md`
- `docs/runbooks/iam-role-matrix.md`

---

## W03 — Projekt VPC i adresacji (dev-only)

### Metadane tygodnia
- **WeekId:** `W03`
- **Faza:** `Networking`
- **Nazwa:** `VPC, subnety, adresacja`
- **Cel tygodnia:** Zaprojektować topologię sieciową dev dla całego projektu
- **WhyNow:** Hosting, RDS, ECS, ALB i endpointy będą zależne od tej decyzji
- **Zakres AWS:** VPC, Subnets (design)
- **Zakres .NET:** Brak
- **Zakres Terraform / CI-CD:** Przygotowanie specyfikacji dla modułu network
- **Zakres Networking / Security:** Adresacja, subnet placement
- **Prereq:** W02
- **Outcome:** Diagram + tabela subnetów + decyzje kosztowe (NAT)
- **Artefakty repo:** `ADR-0004-vpc-dev-topology.md`, `docs/diagrams/vpc-dev.md`
- **Evidence:** Diagram + tabela CIDR
- **Pułapki:** Za mały CIDR, mieszanie public/private subnetów
- **Koszt/Cleanup:** Brak
- **DoD:** Topologia gotowa do implementacji w Terraform

### Zadania
- [ ] **W03-T01 (P1 | Design | 60m)** — Zdefiniuj CIDR VPC i subnety (public/private, min. 2 AZ)
- [ ] **W03-T02 (P1 | Design | 30m)** — Rozmieść komponenty (ALB, ECS, RDS, endpoints, Lambda VPC if needed)
- [ ] **W03-T03 (P1 | ADR | 30m)** — Opisz kompromis dev-only: 1 NAT vs HA NAT per AZ
- [ ] **W03-T04 (P2 | Docs | 30m)** — Uzupełnij diagram przepływu ruchu (public → private)

### Verification
- [ ] Tabela subnetów nie zawiera konfliktów CIDR
- [ ] Każdy komponent ma przypisany typ subnetu
- [ ] ADR opisuje trade-off koszt/HA

### Evidence
- `docs/lessons/W03-summary.md`
- `docs/adr/ADR-0004-vpc-dev-topology.md`

---

## W04 — Routing, IGW, NAT, SG, NACL + start Terraform network-core

### Metadane tygodnia
- **WeekId:** `W04`
- **Faza:** `Networking + IaC`
- **Nazwa:** `Routing i kontrola ruchu w VPC`
- **Cel tygodnia:** Rozpocząć implementację VPC w Terraform i zrozumieć przepływy ruchu
- **WhyNow:** Bez routing/SG/NACL późniejszy troubleshooting będzie chaotyczny
- **Zakres AWS:** Route Tables, IGW, NAT Gateway, SG, NACL
- **Zakres .NET:** Brak
- **Zakres Terraform / CI-CD:** Moduł `network-core`
- **Zakres Networking / Security:** Stateful vs stateless controls
- **Prereq:** W03 design gotowy
- **Outcome:** `terraform plan` dla podstaw sieci
- **Artefakty repo:** `infra/terraform/modules/network-core/*`
- **Evidence:** `terraform validate` + `terraform plan`
- **Pułapki:** Route table associations, NACL blokujące ephemeral ports
- **Koszt/Cleanup:** NAT po apply generuje koszt
- **DoD:** Plan jest poprawny i zrozumiany

### Zadania
- [ ] **W04-T01 (P1 | Theory | 45m)** — Spisz modele przepływu ruchu (Internet→ALB→ECS, ECS→NAT→AWS APIs)
- [ ] **W04-T02 (P1 | IaC | 60m)** — Zaimplementuj moduł `network-core` (VPC, subnets, IGW, route tables)
- [ ] **W04-T03 (P1 | IaC/Security | 30m)** — Dodaj baseline SG i NACL
- [ ] **W04-T04 (P2 | Docs | 15m)** — Checklisty diagnostyczne: routing vs SG vs NACL

### Verification
- [ ] `terraform fmt`
- [ ] `terraform validate`
- [ ] `terraform plan` bez błędów składni/logiki

### Evidence
- `docs/lessons/W04-summary.md`
- plan output (fragmenty kluczowe)
- tabela SG/NACL

---

## W05 — VPC Endpoints, PrivateLink, Flow Logs

### Metadane tygodnia
- **WeekId:** `W05`
- **Faza:** `Networking+`
- **Nazwa:** `Prywatny dostęp do usług AWS i widoczność ruchu`
- **Cel tygodnia:** Zmniejszyć zależność od NAT dla wybranych usług i zwiększyć obserwowalność sieci
- **WhyNow:** To element dojrzałości cloud/networking i dobry fundament pod security
- **Zakres AWS:** VPC Endpoints (Gateway/Interface), PrivateLink, VPC Flow Logs
- **Zakres .NET:** Brak
- **Zakres Terraform / CI-CD:** Moduł `network-endpoints`
- **Zakres Networking / Security:** Endpointy i DNS prywatny (awareness)
- **Prereq:** W04 moduł network-core
- **Outcome:** Endpoint S3/DynamoDB + (min. 1 interface endpoint lub szczegółowa notatka) + Flow Logs
- **Artefakty repo:** `modules/network-endpoints`, `runbooks/network-smoke-tests.md`
- **Evidence:** Apply + route table associations + log entries
- **Pułapki:** Private DNS dla interface endpoint, SG endpointów, koszt endpointów interface
- **Koszt/Cleanup:** Interface endpoints kosztują godzinowo
- **DoD:** Rozumiesz i potrafisz zastosować Gateway Endpoint; interface endpoint przynajmniej na poziomie praktyki bazowej

### Zadania
- [ ] **W05-T01 (P1 | Theory | 45m)** — Porównanie: Gateway Endpoint vs Interface Endpoint vs PrivateLink
- [ ] **W05-T02 (P1 | IaC | 45m)** — Dodaj gateway endpoint dla S3 (opcjonalnie też DynamoDB)
- [ ] **W05-T03 (P1 | Observability | 30m)** — Włącz VPC Flow Logs (CloudWatch lub S3)
- [ ] **W05-T04 (P2 | IaC/Security | 30m)** — Dodaj interface endpoint (np. Secrets Manager/SSM) lub dokładny plan implementacji
- [ ] **W05-T05 (P2 | Docs | 15m)** — Uzupełnij network smoke tests

### Verification
- [ ] Endpoint S3 istnieje i jest skojarzony z route tables
- [ ] Flow Logs generują wpisy
- [ ] Masz notatkę „kiedy który endpoint”

### Evidence
- `docs/lessons/W05-summary.md`
- `docs/runbooks/network-smoke-tests.md`

---

## W06 — Terraform foundations i standardy modułów

### Metadane tygodnia
- **WeekId:** `W06`
- **Faza:** `IaC`
- **Nazwa:** `Struktura Terraform i standardy modułów`
- **Cel tygodnia:** Ustalić spójny standard Terraform dla całego projektu
- **WhyNow:** Liczba zasobów szybko wzrośnie; bez standardów repo zrobi się nieczytelne
- **Zakres AWS:** Pośrednio (abstrakcje zasobów)
- **Zakres .NET:** Brak
- **Zakres Terraform / CI-CD:** Moduły, naming, variables, outputs, tagging conventions
- **Zakres Networking / Security:** Brak nowych usług
- **Prereq:** W04-W05
- **Outcome:** Czytelna architektura Terraform repo gotowa pod dalsze moduły
- **Artefakty repo:** `infra/terraform/README.md`, `modules/_standards.md`
- **Evidence:** `fmt/validate` na modułach
- **Pułapki:** Over-abstraction, moduły zbyt „generyczne”
- **Koszt/Cleanup:** Brak
- **DoD:** Każdy moduł ma standardowy szkielet i konwencje

### Zadania
- [ ] **W06-T01 (P1 | Design/IaC | 45m)** — Ustal strukturę `modules/` i `envs/dev/`
- [ ] **W06-T02 (P1 | IaC | 45m)** — Ustal standard `variables.tf`, `locals.tf`, `outputs.tf`, tagging
- [ ] **W06-T03 (P1 | Docs | 30m)** — `modules/_standards.md` + przykładowy template modułu
- [ ] **W06-T04 (P2 | Docs | 30m)** — Zasady refaktoryzacji modułów (kiedy wydzielać/scalać)

### Verification
- [ ] Co najmniej 1–2 istniejące moduły dostosowane do standardu
- [ ] README IaC opisuje strukturę i sposób użycia

### Evidence
- `docs/lessons/W06-summary.md`
- `infra/terraform/README.md`

---

## W07 — Terraform remote state (S3) + pierwszy pełny deploy sieci

### Metadane tygodnia
- **WeekId:** `W07`
- **Faza:** `IaC Deploy`
- **Nazwa:** `Remote state i deploy VPC do dev`
- **Cel tygodnia:** Przenieść state do S3 i wykonać pełny deploy warstwy sieciowej
- **WhyNow:** To warunek przejścia do CI/CD i hostingu
- **Zakres AWS:** S3 (backend), IAM (uprawnienia do backendu)
- **Zakres .NET:** Brak
- **Zakres Terraform / CI-CD:** `backend "s3"`, `init -migrate-state`, apply flow
- **Zakres Networking / Security:** Deploy VPC baseline
- **Prereq:** W06
- **Outcome:** Sieć dev istnieje i jest zarządzana przez Terraform remote state
- **Artefakty repo:** `envs/dev/backend.*`, `runbooks/terraform-backend-bootstrap.md`
- **Evidence:** `terraform state list`, widoczne zasoby w AWS
- **Pułapki:** Bootstrap backendu, migracja stanu, rozjazd konfiguracji
- **Koszt/Cleanup:** NAT, endpoints, flow logs mogą już generować koszty
- **DoD:** Remote state działa; `plan` jest stabilny po apply

### Zadania
- [ ] **W07-T01 (P1 | IaC | 45m)** — Bootstrap bucket S3 dla Terraform state
- [ ] **W07-T02 (P1 | IaC | 30m)** — Przenieś state do backendu S3 (`init -migrate-state`)
- [ ] **W07-T03 (P1 | Deploy | 45m)** — `terraform apply` dla network stack w `envs/dev`
- [ ] **W07-T04 (P1 | Docs/Troubleshooting | 30m)** — Runbook: smoke tests sieci po deployu

### Verification
- [ ] `terraform state list` działa z remote backend
- [ ] Zasoby VPC widoczne w AWS
- [ ] `terraform plan` po apply nie pokazuje driftu (lub drift jest wyjaśniony)

### Evidence
- `docs/lessons/W07-summary.md`
- `docs/runbooks/terraform-backend-bootstrap.md`
- `docs/runbooks/network-smoke-tests.md`

---

## W08 — GitHub Actions + OIDC do AWS (pipeline dla Terraform)

### Metadane tygodnia
- **WeekId:** `W08`
- **Faza:** `CI/CD + Security`
- **Nazwa:** `Terraform pipeline przez GitHub OIDC`
- **Cel tygodnia:** Uruchomić pipeline IaC bez statycznych kluczy AWS
- **WhyNow:** Kolejne deploymenty powinny być repeatable i CI-driven
- **Zakres AWS:** IAM OIDC provider / role / STS
- **Zakres .NET:** Brak
- **Zakres Terraform / CI-CD:** GitHub Actions `plan` + `apply`
- **Zakres Networking / Security:** Trust policy zawężona do repo/branch
- **Prereq:** W07
- **Outcome:** Pipeline Terraform działa przez OIDC (PR plan + main apply)
- **Artefakty repo:** `.github/workflows/terraform-plan.yml`, `.github/workflows/terraform-apply.yml`
- **Evidence:** Udane runy workflow
- **Pułapki:** Błędny `sub` claim, zbyt szeroka trust policy
- **Koszt/Cleanup:** Brak
- **DoD:** PR generuje plan, merge uruchamia apply (manual gate opcjonalnie)

### Zadania
- [ ] **W08-T01 (P1 | Security | 60m)** — Utwórz OIDC provider i IAM role dla GitHub Actions
- [ ] **W08-T02 (P1 | CI/CD | 30m)** — Workflow `terraform plan` na PR
- [ ] **W08-T03 (P1 | CI/CD | 30m)** — Workflow `terraform apply` na `main` (kontrolowany)
- [ ] **W08-T04 (P2 | Docs | 30m)** — Runbook pipeline IaC + troubleshooting OIDC

### Verification
- [ ] Workflow assume-role działa
- [ ] `terraform plan` w CI działa na PR
- [ ] `terraform apply` działa na merge / manual dispatch

### Evidence
- `docs/lessons/W08-summary.md`
- logi workflow (linki)
- fragment trust policy (zanonimizowany)

---

## W09 — Szkielet aplikacji .NET 10 (mikroserwisy + worker)

### Metadane tygodnia
- **WeekId:** `W09`
- **Faza:** `Application Foundation`
- **Nazwa:** `Szkielet systemu OrderFlow w .NET 10`
- **Cel tygodnia:** Zbudować lokalny baseline aplikacyjny pod dalsze deploymenty
- **WhyNow:** Od teraz zaczyna się właściwy kod i integracja z AWS
- **Zakres AWS:** Brak (lokalny fokus)
- **Zakres .NET:** APIs, worker, shared contracts, health endpoints, logging baseline
- **Zakres Terraform / CI-CD:** Podstawowy CI dla .NET
- **Zakres Networking / Security:** Brak nowych tematów
- **Prereq:** W00–W08
- **Outcome:** Działające lokalnie APIs + worker + CI build/test
- **Artefakty repo:** `src/*`, `.github/workflows/dotnet-ci.yml`
- **Evidence:** `dotnet build/test`, lokalne uruchomienie
- **Pułapki:** Overengineering (DDD/CQRS za wcześnie)
- **Koszt/Cleanup:** Brak
- **DoD:** 2–3 projekty API + worker działają lokalnie i mają health endpointy

### Zadania
- [ ] **W09-T01 (P1 | Coding | 60m)** — Utwórz `orders-api`, `payments-api`, `catalog-api`, `order-worker`
- [ ] **W09-T02 (P1 | Coding | 45m)** — Dodaj health endpoints + structured logging baseline
- [ ] **W09-T03 (P1 | CI/CD | 30m)** — Dodaj workflow `dotnet build/test`
- [ ] **W09-T04 (P2 | Docs | 15m)** — Zapisz architekturę kodu (na tym etapie: prosta, pragmatyczna)

### Verification
- [ ] `dotnet build` OK
- [ ] `dotnet test` (jeśli są testy startowe) OK
- [ ] `/health` działa lokalnie dla API

### Evidence
- `docs/lessons/W09-summary.md`
- output `dotnet build/test`

---

## W10 — App Runner (pierwszy hosting .NET)

### Metadane tygodnia
- **WeekId:** `W10`
- **Faza:** `Hosting Models`
- **Nazwa:** `Wdrożenie pierwszego API do App Runner`
- **Cel tygodnia:** Uzyskać pierwszy działający endpoint .NET w AWS
- **WhyNow:** Szybki feedback i wdrożenie bez złożoności ECS
- **Zakres AWS:** App Runner (+ ECR opcjonalnie), IAM (service access)
- **Zakres .NET:** Dockerfile lub source-build path
- **Zakres Terraform / CI-CD:** V1 manual/console lub partial IaC (świadomie)
- **Zakres Networking / Security:** Publiczny ingress basics
- **Prereq:** W09 + działający serwis lokalnie
- **Outcome:** `catalog-api` lub `orders-api` działa na App Runner
- **Artefakty repo:** `Dockerfile`, `runbooks/apprunner-deploy.md`, opcjonalnie moduł `apprunner`
- **Evidence:** Publiczny `/health`
- **Pułapki:** Port, start command, health check, env vars
- **Koszt/Cleanup:** App Runner koszt runtime
- **DoD:** Działający endpoint + zapisany troubleshooting deployu

### Zadania
- [ ] **W10-T01 (P1 | Coding | 45m)** — Przygotuj Dockerfile (lub source deploy config) dla wybranego API
- [ ] **W10-T02 (P1 | Deploy | 45m)** — Wdróż serwis do App Runner
- [ ] **W10-T03 (P1 | Verification/Troubleshooting | 30m)** — Zweryfikuj `/health`, logi, env vars
- [ ] **W10-T04 (P2 | Docs | 30m)** — Runbook + różnice App Runner vs inne modele (własne notatki)

### Verification
- [ ] Endpoint `/health` odpowiada
- [ ] Logi aplikacji widoczne
- [ ] Możesz zrobić redeploy po zmianie kodu

### Evidence
- `docs/lessons/W10-summary.md`
- `docs/runbooks/apprunner-deploy.md`

---

## W11 — Elastic Beanstalk (.NET on Linux)

### Metadane tygodnia
- **WeekId:** `W11`
- **Faza:** `Hosting Models`
- **Nazwa:** `Elastic Beanstalk jako PaaS dla .NET`
- **Cel tygodnia:** Poznać i porównać kolejny model hostingu .NET w AWS
- **WhyNow:** Budujesz praktyczne porównanie hostingów pod rozmowy techniczne
- **Zakres AWS:** Elastic Beanstalk (pośrednio jego warstwa infrastrukturalna)
- **Zakres .NET:** Publish package / runtime config
- **Zakres Terraform / CI-CD:** Minimalny deploy flow (manual lub półautomatyczny)
- **Zakres Networking / Security:** Basic ingress/security awareness
- **Prereq:** W10
- **Outcome:** Drugi serwis działa w Elastic Beanstalk
- **Artefakty repo:** `runbooks/elastic-beanstalk-deploy.md`, opcjonalnie moduł Terraform
- **Evidence:** Endpoint + health status środowiska
- **Pułapki:** Package format, platform version, env vars, health status
- **Koszt/Cleanup:** Beanstalk utrzymuje zasoby — trzeba sprzątać
- **DoD:** Umiesz wdrożyć i porównać App Runner vs Beanstalk

### Zadania
- [ ] **W11-T01 (P1 | Theory | 30m)** — Spisz model odpowiedzialności w Beanstalk
- [ ] **W11-T02 (P1 | Deploy | 60m)** — Wdróż `payments-api` lub `catalog-api` do Beanstalk
- [ ] **W11-T03 (P1 | Troubleshooting | 30m)** — Sprawdź health, logi, typowe błędy startu
- [ ] **W11-T04 (P2 | Docs | 30m)** — Runbook deployu i diagnostyki Beanstalk

### Verification
- [ ] Aplikacja działa
- [ ] Umiesz wskazać gdzie szukać logów / health
- [ ] Masz notatkę porównawczą hostingów

### Evidence
- `docs/lessons/W11-summary.md`
- `docs/runbooks/elastic-beanstalk-deploy.md`

---

## W12 — ECR + standard konteneryzacji .NET

### Metadane tygodnia
- **WeekId:** `W12`
- **Faza:** `Containers`
- **Nazwa:** `ECR i standaryzacja obrazów .NET`
- **Cel tygodnia:** Przygotować kontenery i registry pod ECS/Fargate
- **WhyNow:** ECS/Fargate wymaga sprawnego build/push workflow
- **Zakres AWS:** ECR
- **Zakres .NET:** Multi-stage Dockerfiles, config przez env vars
- **Zakres Terraform / CI-CD:** Moduł `ecr` + workflow build/push
- **Zakres Networking / Security:** Brak nowych
- **Prereq:** W09
- **Outcome:** Obrazy `.NET` trafiają do ECR z GitHub Actions
- **Artefakty repo:** `Dockerfile*`, `modules/ecr`, `workflows/build-push-ecr.yml`
- **Evidence:** Image tags w ECR (np. commit SHA)
- **Pułapki:** Tagowanie `latest`, arch mismatch, zły port
- **Koszt/Cleanup:** ECR storage — ustaw lifecycle policy
- **DoD:** Min. 1 serwis budowany i pushowany automatycznie do ECR

### Zadania
- [ ] **W12-T01 (P1 | Coding | 45m)** — Ustandaryzuj Dockerfile dla API/worker (template)
- [ ] **W12-T02 (P1 | IaC | 30m)** — Utwórz ECR repo + lifecycle policy
- [ ] **W12-T03 (P1 | CI/CD | 45m)** — Pipeline build/push image do ECR (OIDC)
- [ ] **W12-T04 (P2 | Docs | 30m)** — Runbook build/push + troubleshooting image build

### Verification
- [ ] `docker build` lokalnie działa
- [ ] Pipeline pushuje obraz do ECR
- [ ] ECR ma politykę retencji / cleanup

### Evidence
- `docs/lessons/W12-summary.md`
- workflow logs
- screenshot/listing ECR tags

---

## W13 — ECS + Fargate (pierwszy serwis)

### Metadane tygodnia
- **WeekId:** `W13`
- **Faza:** `ECS/Fargate`
- **Nazwa:** `Pierwszy deployment .NET do ECS Fargate`
- **Cel tygodnia:** Uruchomić `orders-api` na ECS Fargate
- **WhyNow:** To główny docelowy model hostingu dla kursu
- **Zakres AWS:** ECS, Fargate, ECR, IAM (execution/task roles)
- **Zakres .NET:** Runtime config kontenera, health endpoint
- **Zakres Terraform / CI-CD:** Moduły `ecs-cluster`, `ecs-service-basic`
- **Zakres Networking / Security:** Subnets i SG dla tasków
- **Prereq:** W07 (VPC), W12 (ECR)
- **Outcome:** Running ECS service (nawet bez ALB w pierwszym kroku)
- **Artefakty repo:** `modules/ecs-*`, `runbooks/ecs-first-deploy.md`
- **Evidence:** Taski `RUNNING`, logi w CloudWatch
- **Pułapki:** Task definition (CPU/RAM), IAM role permissions, log driver
- **Koszt/Cleanup:** Fargate runtime
- **DoD:** Task startuje stabilnie, logi są widoczne

### Zadania
- [ ] **W13-T01 (P1 | IaC | 45m)** — ECS cluster + IAM roles (execution/task)
- [ ] **W13-T02 (P1 | IaC/Deploy | 45m)** — Task definition + service dla `orders-api`
- [ ] **W13-T03 (P1 | Observability | 30m)** — CloudWatch log group + podstawowa konfiguracja logów
- [ ] **W13-T04 (P1 | Troubleshooting | 30m)** — Runbook „task nie startuje”
- [ ] **W13-T05 (P2 | Docs | 15m)** — Notatka: ECS/Fargate model odpowiedzialności

### Verification
- [ ] ECS cluster istnieje
- [ ] Service ma running tasks
- [ ] Logi aplikacji trafiają do CloudWatch

### Evidence
- `docs/lessons/W13-summary.md`
- `docs/runbooks/ecs-first-deploy.md`

---

## W14 — ALB + target groups + ingress dla ECS

### Metadane tygodnia
- **WeekId:** `W14`
- **Faza:** `ECS/Fargate + Networking`
- **Nazwa:** `Publikacja ECS przez ALB`
- **Cel tygodnia:** Udostępnić API hostowane na ECS przez ALB
- **WhyNow:** Ingress + health checks to krytyczny element produkcyjnego hostingu
- **Zakres AWS:** ALB, Target Groups, ECS, CloudWatch
- **Zakres .NET:** Health/readiness endpointy
- **Zakres Terraform / CI-CD:** Moduł `alb`, integracja z ECS service
- **Zakres Networking / Security:** SG ALB ↔ ECS, subnets public/private
- **Prereq:** W13
- **Outcome:** Publiczny ALB kieruje ruch do ECS service
- **Artefakty repo:** `modules/alb`, `runbooks/alb-ecs-smoke-tests.md`
- **Evidence:** `GET /health` przez ALB, healthy target
- **Pułapki:** Zły health check path/port, SG, target type, subnet placement
- **Koszt/Cleanup:** ALB kosztuje stale
- **DoD:** Target group healthy, endpoint działa stabilnie

### Zadania
- [ ] **W14-T01 (P1 | IaC | 45m)** — ALB + listener + target group
- [ ] **W14-T02 (P1 | IaC/Deploy | 30m)** — Podłącz ECS service do target group
- [ ] **W14-T03 (P1 | Coding | 30m)** — Dostosuj health endpointy pod ALB
- [ ] **W14-T04 (P1 | Troubleshooting | 45m)** — Runbook diagnostyki `Unhealthy targets`
- [ ] **W14-T05 (P2 | Docs | 15m)** — Smoke tests ingressu ALB

### Verification
- [ ] Target group status: healthy
- [ ] Publiczny endpoint działa
- [ ] Logi pokazują ruch przez ALB

### Evidence
- `docs/lessons/W14-summary.md`
- `docs/runbooks/alb-ecs-smoke-tests.md`

---

## W15 — ECS deployment workflow, autoscaling, rollout/rollback

### Metadane tygodnia
- **WeekId:** `W15`
- **Faza:** `ECS/Fargate Ops`
- **Nazwa:** `Cykl życia deploymentu ECS`
- **Cel tygodnia:** Zautomatyzować deploye i opanować rollback
- **WhyNow:** „Postawić” to za mało — liczy się repeatability i operacyjność
- **Zakres AWS:** ECS, ALB, CloudWatch
- **Zakres .NET:** Wersjonowanie image + config changes
- **Zakres Terraform / CI-CD:** Workflow deploy ECS
- **Zakres Networking / Security:** Brak nowych
- **Prereq:** W13–W14
- **Outcome:** Deploy nowej wersji + rollback runbook + basic autoscaling
- **Artefakty repo:** `workflows/deploy-ecs.yml`, `runbooks/ecs-rollout-rollback.md`
- **Evidence:** Udany rollout i (przynajmniej testowy) rollback
- **Pułapki:** Tag `latest`, health grace period, niedeterministyczny deploy
- **Koszt/Cleanup:** Możliwy krótkotrwały wzrost task count
- **DoD:** Działający pipeline deploy ECS + opisany rollback

### Zadania
- [ ] **W15-T01 (P1 | CI/CD | 45m)** — Workflow deploy ECS (nowa task definition / image tag)
- [ ] **W15-T02 (P1 | IaC/Ops | 30m)** — Basic autoscaling policy dla ECS service
- [ ] **W15-T03 (P1 | Troubleshooting | 45m)** — Przećwicz rollout z błędem + rollback
- [ ] **W15-T04 (P1 | Docs | 30m)** — Runbook rollout/rollback
- [ ] **W15-T05 (P2 | Observability | 15m)** — Zanotuj metryki do monitorowania przy deployu

### Verification
- [ ] Nowa wersja obrazu została wdrożona
- [ ] Można wrócić do poprzedniej wersji
- [ ] Autoscaling policy istnieje i jest poprawnie przypięta

### Evidence
- `docs/lessons/W15-summary.md`
- `docs/runbooks/ecs-rollout-rollback.md`

---

## W16 — RDS PostgreSQL + EF Core + sekrety

### Metadane tygodnia
- **WeekId:** `W16`
- **Faza:** `Data Layer`
- **Nazwa:** `RDS PostgreSQL dla Orders`
- **Cel tygodnia:** Podłączyć `orders-api` do relacyjnej bazy danych w AWS
- **WhyNow:** Projekt e-commerce wymaga trwałych danych transakcyjnych
- **Zakres AWS:** RDS, Secrets Manager / SSM, IAM, KMS (jeśli używasz własnego klucza)
- **Zakres .NET:** EF Core, migrations, connection config
- **Zakres Terraform / CI-CD:** Moduł `rds-postgres`, sekrety, SG
- **Zakres Networking / Security:** Private subnets dla DB + SG from ECS
- **Prereq:** W13–W15
- **Outcome:** API zapisuje/odczytuje zamówienia z RDS
- **Artefakty repo:** `modules/rds-postgres`, EF migrations, `runbooks/rds-connectivity.md`
- **Evidence:** CRUD test przez API
- **Pułapki:** SG DB, connection string, migracje w złym miejscu, timeouty
- **Koszt/Cleanup:** RDS kosztuje stale (dev-only pilnować uptime/destroy)
- **DoD:** CRUD działa; sekrety nie są hardcoded

### Zadania
- [ ] **W16-T01 (P1 | IaC | 45m)** — Utwórz RDS PostgreSQL + subnet group + SG
- [ ] **W16-T02 (P1 | Security | 30m)** — Umieść connection string/credentials w Secrets Manager lub SSM
- [ ] **W16-T03 (P1 | Coding | 45m)** — Dodaj EF Core model `Order` + migracje + persistence
- [ ] **W16-T04 (P1 | Deploy | 30m)** — Wdróż API z połączeniem do RDS
- [ ] **W16-T05 (P2 | Docs/Troubleshooting | 15m)** — Runbook connectivity DB z ECS

### Verification
- [ ] API tworzy i odczytuje zamówienie w RDS
- [ ] Połączenie pobiera sekret z AWS
- [ ] Brak sekretów w repo i logach

### Evidence
- `docs/lessons/W16-summary.md`
- `docs/runbooks/rds-connectivity.md`

---

## W17 — S3 + KMS + wzorzec plików (presigned URL / upload)

### Metadane tygodnia
- **WeekId:** `W17`
- **Faza:** `Storage`
- **Nazwa:** `S3 jako object storage w aplikacji`
- **Cel tygodnia:** Zaimplementować obsługę plików w S3 z bezpiecznym dostępem
- **WhyNow:** S3 to bardzo częsty element systemów web/API
- **Zakres AWS:** S3, KMS, IAM
- **Zakres .NET:** AWS SDK for .NET (S3), upload/download/presigned URL
- **Zakres Terraform / CI-CD:** Moduł `s3-bucket`
- **Zakres Networking / Security:** Public access block, IAM permissions
- **Prereq:** W12 (ECR), W16 (sekrety/security baseline)
- **Outcome:** API obsługuje pliki przez S3
- **Artefakty repo:** `modules/s3-bucket`, integracja .NET, `runbooks/s3-upload-flow.md`
- **Evidence:** Upload + odczyt pliku działa
- **Pułapki:** KMS perms, bucket policy vs IAM, CORS (jeśli testujesz z UI)
- **Koszt/Cleanup:** Niski, ale czyść testowe obiekty
- **DoD:** Działa upload/download i bucket nie jest publicznie otwarty

### Zadania
- [ ] **W17-T01 (P1 | IaC | 45m)** — Bucket S3 (public access block, encryption, versioning opcjonalnie)
- [ ] **W17-T02 (P1 | Coding | 45m)** — Integracja .NET z S3 (upload/download/presigned URL)
- [ ] **W17-T03 (P1 | Security | 30m)** — Minimalne IAM permissions (S3 + KMS) dla aplikacji
- [ ] **W17-T04 (P2 | Docs | 30m)** — Runbook upload flow + troubleshooting auth errors

### Verification
- [ ] Plik można wysłać i odczytać
- [ ] Brak publicznego bucketu
- [ ] Aplikacja działa z minimalnym zakresem uprawnień

### Evidence
- `docs/lessons/W17-summary.md`
- `docs/runbooks/s3-upload-flow.md`

---

## W18 — Messaging I: SQS + DLQ + worker

### Metadane tygodnia
- **WeekId:** `W18`
- **Faza:** `Event-Driven`
- **Nazwa:** `Asynchroniczne przetwarzanie przez SQS`
- **Cel tygodnia:** Zbudować kolejkę z DLQ i worker przetwarzający zdarzenia orderów
- **WhyNow:** Event-driven i messaging są kluczowe dla nowoczesnych backendów
- **Zakres AWS:** SQS, DLQ, CloudWatch (metryki queue)
- **Zakres .NET:** Worker + SQS producer/consumer + retry awareness
- **Zakres Terraform / CI-CD:** Moduł `sqs`
- **Zakres Networking / Security:** IAM access do SQS
- **Prereq:** W15–W17
- **Outcome:** `orders-api` publikuje wiadomość, worker przetwarza, DLQ działa
- **Artefakty repo:** `modules/sqs`, `workers/order-worker`, `runbooks/sqs-dlq-operations.md`
- **Evidence:** Wiadomości w queue/DLQ + logi workerów
- **Pułapki:** Visibility timeout, duplicate delivery assumptions, poison messages
- **Koszt/Cleanup:** Niski
- **DoD:** Działa happy path i failure path (DLQ)

### Zadania
- [ ] **W18-T01 (P1 | IaC | 30m)** — SQS queue + DLQ + redrive policy
- [ ] **W18-T02 (P1 | Coding | 60m)** — Producer w `orders-api` + consumer w `order-worker`
- [ ] **W18-T03 (P1 | Troubleshooting | 30m)** — Przetestuj poison message → DLQ
- [ ] **W18-T04 (P1 | Docs | 30m)** — Runbook diagnostyki DLQ
- [ ] **W18-T05 (P2 | Observability | 15m)** — Lista metryk kolejki do monitorowania

### Verification
- [ ] Wiadomość trafia do queue i jest konsumowana
- [ ] Błędna wiadomość trafia do DLQ
- [ ] Worker loguje correlation/order id

### Evidence
- `docs/lessons/W18-summary.md`
- `docs/runbooks/sqs-dlq-operations.md`

---

## W19 — Messaging II: SNS + EventBridge (pub/sub i routing zdarzeń)

### Metadane tygodnia
- **WeekId:** `W19`
- **Faza:** `Event-Driven`
- **Nazwa:** `Pub/Sub i event bus w domenie e-commerce`
- **Cel tygodnia:** Zbudować routing zdarzeń do wielu konsumentów
- **WhyNow:** Pokazuje dojrzałość architektoniczną i rozdzielenie integracji
- **Zakres AWS:** SNS, EventBridge, SQS (targets), CloudWatch
- **Zakres .NET:** Event contracts, publishers, consumers
- **Zakres Terraform / CI-CD:** Moduły `sns`, `eventbridge`
- **Zakres Networking / Security:** IAM publish/subscribe
- **Prereq:** W18
- **Outcome:** `OrderCreated` trafia do min. 2 konsumentów/ścieżek
- **Artefakty repo:** event contracts, routing config, diagram event flow
- **Evidence:** Logi i metryki pokazujące routing eventów
- **Pułapki:** Coupling payloadów, brak wersjonowania kontraktów
- **Koszt/Cleanup:** Niski
- **DoD:** Działa pub/sub + masz notatkę porównawczą SQS/SNS/EventBridge

### Zadania
- [ ] **W19-T01 (P1 | Design | 45m)** — Zdefiniuj event contracts (`OrderCreated`, `PaymentRequested`, ...)
- [ ] **W19-T02 (P1 | IaC | 45m)** — SNS topic i/lub EventBridge rules + targets
- [ ] **W19-T03 (P1 | Coding | 30m)** — Publisher w API + konsumenci/targety
- [ ] **W19-T04 (P1 | Docs | 30m)** — Notatka „SQS vs SNS vs EventBridge” (as-is)
- [ ] **W19-T05 (P2 | Troubleshooting | 15m)** — Checklista diagnostyczna routingu eventów

### Verification
- [ ] Event trafia do co najmniej 2 ścieżek
- [ ] Kontrakty zdarzeń są w `shared/`
- [ ] Masz opis kiedy używać czego

### Evidence
- `docs/lessons/W19-summary.md`
- diagram event flow

---

## W20 — Lambda (.NET 10) + API Gateway (payment callback)

### Metadane tygodnia
- **WeekId:** `W20`
- **Faza:** `Serverless`
- **Nazwa:** `Callback płatności jako Lambda + API Gateway`
- **Cel tygodnia:** Zaimplementować serverless endpoint dla callbacków płatniczych
- **WhyNow:** Łączy .NET + serverless + IAM + integrację event-driven
- **Zakres AWS:** Lambda, API Gateway, IAM, CloudWatch Logs
- **Zakres .NET:** Lambda handler, serialization, idempotency hook
- **Zakres Terraform / CI-CD:** Moduły `lambda`, `api-gateway`, deploy workflow
- **Zakres Networking / Security:** IAM execution role; VPC attach tylko jeśli potrzebne (świadomie)
- **Prereq:** W18–W19
- **Outcome:** Działający callback endpoint publikuje event/kolejkę
- **Artefakty repo:** `src/lambdas/payment-callback`, `runbooks/lambda-api-gateway-callback.md`
- **Evidence:** Callback request → logi Lambdy → downstream event
- **Pułapki:** Handler signature, timeout, permissions invoke, route mapping
- **Koszt/Cleanup:** Niski
- **DoD:** Callback działa + idempotency/retry jest świadomie opisane

### Zadania
- [ ] **W20-T01 (P1 | Coding | 45m)** — Utwórz projekt Lambdy `.NET 10` + handler callbacku
- [ ] **W20-T02 (P1 | IaC/Deploy | 45m)** — Wdróż Lambda + API Gateway route
- [ ] **W20-T03 (P1 | Verification | 30m)** — Test callbacku (happy path + duplicate callback)
- [ ] **W20-T04 (P1 | Design/Docs | 30m)** — Notatka o idempotency i retry dla callbacków
- [ ] **W20-T05 (P2 | CI/CD | 15m)** — Pipeline deploy Lambdy (jeśli nie zdążysz, zaplanuj W20/W21)

### Verification
- [ ] Publiczny endpoint callback działa
- [ ] Lambda loguje request i publikuje downstream event
- [ ] Masz plan/implementację idempotency

### Evidence
- `docs/lessons/W20-summary.md`
- `docs/runbooks/lambda-api-gateway-callback.md`

---

## W21 — DynamoDB (idempotency store / projection)

### Metadane tygodnia
- **WeekId:** `W21`
- **Faza:** `Data Layer / NoSQL`
- **Nazwa:** `DynamoDB dla use-case technicznego`
- **Cel tygodnia:** Użyć DynamoDB tam, gdzie relacyjna baza nie jest najlepsza
- **WhyNow:** Utrwalasz wzorzec „RDS + DynamoDB” i dobór storage do problemu
- **Zakres AWS:** DynamoDB, IAM, KMS (opcjonalnie)
- **Zakres .NET:** AWS SDK for .NET (DynamoDB), model PK/SK
- **Zakres Terraform / CI-CD:** Moduł `dynamodb-table`
- **Zakres Networking / Security:** IAM permissions
- **Prereq:** W16, W20
- **Outcome:** Idempotency/projection store działa na DynamoDB
- **Artefakty repo:** `modules/dynamodb-table`, repozytorium DynamoDB, runbook debug
- **Evidence:** Test scenariusza duplikatu / projection read
- **Pułapki:** Złe klucze, założenia o consistency, brak TTL (jeśli potrzebny)
- **Koszt/Cleanup:** Niski
- **DoD:** Co najmniej 1 uzasadniony use-case działa na DynamoDB

### Zadania
- [ ] **W21-T01 (P1 | Design | 45m)** — Zaprojektuj model tabeli (PK/SK, atrybuty, TTL opcjonalnie)
- [ ] **W21-T02 (P1 | IaC | 30m)** — Utwórz tabelę DynamoDB
- [ ] **W21-T03 (P1 | Coding | 45m)** — Integracja `.NET` z DynamoDB (use-case: idempotency/projection)
- [ ] **W21-T04 (P1 | Verification | 30m)** — Przetestuj duplicate callback / duplicate event handling
- [ ] **W21-T05 (P2 | Docs | 15m)** — Runbook „DynamoDB debugging basics”

### Verification
- [ ] Zapis/odczyt DynamoDB działa
- [ ] Use-case idempotency/projection jest realnie użyty
- [ ] Model tabeli jest opisany i uzasadniony

### Evidence
- `docs/lessons/W21-summary.md`
- `docs/runbooks/dynamodb-debugging-basics.md`

---

## W22 — Security hardening (IAM/KMS/Secrets/SSM/WAF + Shield awareness)

### Metadane tygodnia
- **WeekId:** `W22`
- **Faza:** `Security Hardening`
- **Nazwa:** `Przegląd bezpieczeństwa dev i domknięcie baseline`
- **Cel tygodnia:** Usunąć oczywiste ryzyka i uporządkować security posture projektu
- **WhyNow:** System już działa — czas na świadome utwardzenie
- **Zakres AWS:** IAM, KMS, Secrets Manager, SSM, WAF (praktyka bazowa), Shield (awareness), CloudTrail (awareness)
- **Zakres .NET:** Config/secret hygiene, brak sekretów w logach
- **Zakres Terraform / CI-CD:** Security policy review + opcjonalny WAF attach
- **Zakres Networking / Security:** Least privilege review, ingress protection basics
- **Prereq:** W20–W21
- **Outcome:** Security baseline dla dev + checklista review
- **Artefakty repo:** `runbooks/security-review-dev.md`, `ADR-00xx-secret-management.md`
- **Evidence:** Wypełniona checklista i wdrożone poprawki
- **Pułapki:** Zbyt szerokie IAM, sekrety wyciekające w logs, „włączony WAF bez zrozumienia”
- **Koszt/Cleanup:** WAF może generować koszt
- **DoD:** Least privilege i secret handling są uporządkowane; WAF/Shield rozumiane praktycznie lub dokładnie opisane

### Zadania
- [ ] **W22-T01 (P1 | Security Review | 45m)** — Przegląd i ograniczenie IAM policies (pipeline/app roles)
- [ ] **W22-T02 (P1 | Security/Coding | 45m)** — Uporządkuj użycie Secrets Manager vs SSM Parameter Store
- [ ] **W22-T03 (P1 | Security | 30m)** — Przegląd KMS usage (S3/secrets/DB where applicable)
- [ ] **W22-T04 (P2 | Security/Awareness+Practice | 30m)** — WAF basic ruleset (jeśli budżet/zakres pozwala)
- [ ] **W22-T05 (P1 | Docs | 30m)** — `security-review-dev.md` + checklista audytu dev

### Verification
- [ ] Brak jawnych sekretów w repo i logach
- [ ] IAM role są zawężone i nadal działają
- [ ] Masz udokumentowane decyzje security

### Evidence
- `docs/lessons/W22-summary.md`
- `docs/runbooks/security-review-dev.md`

---

## W23 — Observability, alarmy, troubleshooting i koszt operacyjny

### Metadane tygodnia
- **WeekId:** `W23`
- **Faza:** `Operations / Reliability`
- **Nazwa:** `CloudWatch + runbooki diagnostyczne`
- **Cel tygodnia:** Zrobić system utrzymywalny operacyjnie i diagnozowalny
- **WhyNow:** To odróżnia „demo” od realnych kompetencji cloud/devops
- **Zakres AWS:** CloudWatch (logs/metrics/alarms/dashboard), CloudTrail (awareness), Budgets (opcjonalnie)
- **Zakres .NET:** Structured logging, correlation IDs, metryki/tracing hooks
- **Zakres Terraform / CI-CD:** Alarmy/dashboards as code (jeśli zdążysz)
- **Zakres Networking / Security:** Objaw→diagnoza dla problemów sieci/security
- **Prereq:** W13–W22
- **Outcome:** Dashboardy, alarmy i playbooki troubleshootingowe
- **Artefakty repo:** `runbooks/ops-smoke-tests.md`, `troubleshooting/*.md`, opcjonalnie moduł `cloudwatch-alarms`
- **Evidence:** Alarm testowy + dashboard + 3 playbooki
- **Pułapki:** Alert fatigue, brak korelacji logów, brak retention policy
- **Koszt/Cleanup:** Log retention i alarmy generują koszty
- **DoD:** Masz minimalny pakiet operacyjny i potrafisz przejść 3 scenariusze awarii

### Zadania
- [ ] **W23-T01 (P1 | Observability | 45m)** — Dashboardy/metryki dla ECS, Lambda, SQS
- [ ] **W23-T02 (P1 | Observability | 30m)** — Alarmy (np. ECS unhealthy, Lambda errors, DLQ > 0)
- [ ] **W23-T03 (P1 | Troubleshooting | 45m)** — Przećwicz 3 kontrolowane awarie i opisz playbooki
- [ ] **W23-T04 (P1 | Docs | 30m)** — `ops-smoke-tests.md` + checklista przed/po deployu
- [ ] **W23-T05 (P2 | Cost/Ops | 15m)** — Zasady retencji logów i cleanup kosztów

### Verification
- [ ] Dashboard pokazuje kluczowe metryki
- [ ] Co najmniej 1 alarm można wywołać testowo
- [ ] Są min. 3 playbooki troubleshootingowe

### Evidence
- `docs/lessons/W23-summary.md`
- `docs/runbooks/ops-smoke-tests.md`
- `docs/troubleshooting/*`

---

## W24 — Finalizacja projektu i przygotowanie pod rozmowy / portfolio

### Metadane tygodnia
- **WeekId:** `W24`
- **Faza:** `Finalization / Portfolio`
- **Nazwa:** `Domknięcie projektu i narracja rekrutacyjna`
- **Cel tygodnia:** Zamienić projekt edukacyjny w materiał pokazowy (portfolio)
- **WhyNow:** Bez tego duża część wartości pozostaje tylko w głowie
- **Zakres AWS:** Przegląd wszystkich użytych usług
- **Zakres .NET:** Porządki kodu + README + diagramy
- **Zakres Terraform / CI-CD:** Porządki i indeks runbooków
- **Zakres Networking / Security:** Final review checklist
- **Prereq:** W00–W23
- **Outcome:** Repo portfolio-ready + case stories + plan dalszego rozwoju
- **Artefakty repo:** final `README.md`, `docs/portfolio/interview-stories.md`, indeks runbooków
- **Evidence:** Komplet dokumentacji + final checklist
- **Pułapki:** Brak narracji decyzji i kompromisów, „ładne demo bez treści technicznej”
- **Koszt/Cleanup:** Finalny destroy lub świadomy plan utrzymania minimum
- **DoD:** Projekt da się pokazać i obronić technicznie na rozmowie

### Zadania
- [ ] **W24-T01 (P1 | Docs/Architecture | 60m)** — Finalny README (cel, architektura, serwisy, deploy, uruchomienie)
- [ ] **W24-T02 (P1 | Docs/Portfolio | 45m)** — `interview-stories.md` (5–7 historii: problem → decyzja → kompromis → wynik)
- [ ] **W24-T03 (P1 | Docs | 30m)** — Indeks runbooków/troubleshooting/ADR
- [ ] **W24-T04 (P1 | Ops/Cleanup | 30m)** — Finalny cleanup plan (destroy vs keep minimal)
- [ ] **W24-T05 (P2 | Roadmap | 15m)** — Plan fazy 2 (np. EKS / CloudFront / Route53 / OTel deeper)

### Verification
- [ ] README jest samowystarczalny
- [ ] Case stories są gotowe do rozmów technicznych
- [ ] Jest lista „co umiem / czego się nauczyłem”
- [ ] Koszty dev są pod kontrolą

### Evidence
- `docs/lessons/W24-summary.md`
- `docs/portfolio/interview-stories.md`

---

# 11. Macierz tygodni → usługi AWS (szybki indeks)

## Networking / Security
- **IAM:** W02, W08, W13, W16, W20, W22
- **VPC/Subnets/Routes/IGW/NAT/SG/NACL:** W03–W05, W14, W16
- **VPC Endpoints / PrivateLink:** W05
- **KMS / Secrets / SSM:** W16, W17, W22
- **WAF / Shield:** W22 (WAF praktyka bazowa, Shield awareness)

## Hosting / Compute
- **App Runner:** W10
- **Elastic Beanstalk:** W11
- **ECR:** W12
- **ECS + Fargate:** W13–W15
- **Lambda + API Gateway:** W20

## Data / Integracje
- **S3:** W07 (Terraform state), W17 (app storage)
- **RDS PostgreSQL:** W16
- **SQS + DLQ:** W18
- **SNS / EventBridge:** W19
- **DynamoDB:** W21

## Operacyjność
- **CloudWatch:** W13–W15, W18, W20, W23
- **CloudTrail (awareness):** W22–W23

## IaC / CI-CD
- **Terraform:** W04–W08, dalej stale
- **GitHub Actions + OIDC:** W08, W12, W15, W20

---

# 12. Definicja ukończenia całego kursu (Course DoD)

Kurs uznaje się za ukończony, gdy spełnione są wszystkie warunki:

## 12.1 Projekt / hosting
- [ ] Działające usługi .NET w co najmniej 3 modelach hostingu:
  - [ ] ECS Fargate (obowiązkowo)
  - [ ] Lambda + API Gateway (obowiązkowo)
  - [ ] App Runner lub Elastic Beanstalk (minimum 1; docelowo oba)

## 12.2 Infrastruktura i delivery
- [ ] Terraform modularny (`modules` + `envs/dev`)
- [ ] Remote state w S3
- [ ] GitHub Actions OIDC do AWS
- [ ] Pipeline IaC (`plan` + `apply`)
- [ ] Pipeline build/push image (ECR)
- [ ] Pipeline deploy (ECS i/lub Lambda)

## 12.3 Security / networking
- [ ] VPC z public/private subnetami i routingiem
- [ ] NAT + SG/NACL (świadomie skonfigurowane)
- [ ] VPC Endpoints (min. Gateway Endpoint + awareness/praktyka Interface Endpoint)
- [ ] IAM least privilege dla kluczowych ról
- [ ] Sekrety poza repo (`Secrets Manager` / `SSM`)

## 12.4 Data / event-driven
- [ ] RDS PostgreSQL użyty w realnym use-case
- [ ] S3 użyte w realnym use-case
- [ ] SQS + DLQ działają
- [ ] SNS/EventBridge użyte do routingu zdarzeń
- [ ] DynamoDB użyte w uzasadnionym use-case technicznym (np. idempotency/projection)

## 12.5 Operacyjność / dokumentacja
- [ ] CloudWatch dashboard + alarmy (minimum)
- [ ] Min. 3 playbooki troubleshootingowe
- [ ] README architektury i uruchomienia
- [ ] ADR-y kluczowych decyzji
- [ ] Tygodniowe podsumowania `W00–W24`
- [ ] Runbooki + evidence

## 12.6 Kompetencja rozmowy technicznej
- [ ] Uczestnik potrafi opowiedzieć:
  - [ ] architekturę systemu,
  - [ ] wybór hostingu (App Runner vs Beanstalk vs ECS vs Lambda),
  - [ ] kompromisy kosztowe `dev-only`,
  - [ ] 3–5 realnych problemów i diagnostykę,
  - [ ] model IAM i security baseline projektu.

---

# 13. Szablon tygodniowego podsumowania (do kopiowania)

> Plik: `docs/lessons/Wxx-summary.md`

```markdown
# Wxx — <nazwa tygodnia>

## Cel tygodnia
- 

## Co zrobiłem
- 

## Co działa
- 

## Co nie działało
- 

## Root cause / diagnoza
- 

## Jak naprawiłem
- 

## Smoke tests
- [ ] 
- [ ] 
- [ ] 

## Evidence
- 
- 

## Koszt / cleanup
- Co utrzymuję:
- Co usunąłem:
- Co wyłączam po sesji:

## Wnioski
- 

## Next actions (Wxx+1)
- 
```

---

# 14. Szablon task-listy dziennej (opcjonalne, pod Cursor)

> Możesz tworzyć plik `docs/lessons/Wxx-day-plan.md`

```markdown
# Wxx — plan sesji (D1–D5)

## D1 (1.5h)
- [ ] 
- [ ] 
- [ ] 

## D2 (1.5h)
- [ ] 
- [ ] 
- [ ] 

## D3 (1.5h)
- [ ] 
- [ ] 
- [ ] 

## D4 (1.5h)
- [ ] 
- [ ] 
- [ ] 

## D5 (1.5h)
- [ ] 
- [ ] 
- [ ] 

## Blockery
- 

## Decyzje / ADR candidates
- 
```

---

# 15. Następny krok po wdrożeniu tej roadmapy

Po dodaniu tego pliku do repo:
1. Utwórz `W00-summary.md`
2. Przejdź przez W00 i W01
3. Utrzymuj rytm tygodniowy
4. Nie przeskakuj faz (szczególnie networking + IAM + Terraform)
5. Każdy problem zapisuj jako troubleshooting note

To jest **roadmapa operacyjna**, więc ma być używana jak plan pracy, nie tylko przeczytana.

---
