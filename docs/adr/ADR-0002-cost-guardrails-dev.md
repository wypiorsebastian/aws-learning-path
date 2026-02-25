# ADR-0002 — Zasady kosztowe (cost guardrails) dla środowiska dev

- **Status:** Accepted  
- **Data:** 2026-02-25  
- **Kontekst:** Kurs „AWS dla Senior .NET Developera (Azure → AWS, DevOps-ready)” realizowany w trybie `dev-only`, z celem nauki i portfolio, a nie optymalizacji kosztów „za wszelką cenę”.

---

## 1. Kontekst

- Środowisko:
  - AWS Organization z kontem deweloperskim `swpr-dev` w OU `Development`,
  - wszystkie eksperymenty kursowe odbywają się na tym koncie, w regionie przyjętym dla projektu (np. `eu-central-1`).
- Profil uczestnika:
  - senior .NET developer z doświadczeniem w Azure,
  - pracuje samodzielnie na swoim koncie/środowisku, płacąc z własnych środków lub budżetu ograniczonego.
- Charakter kursu:
  - **learning-first**: priorytetem jest zrozumienie usług AWS, IaC, CI/CD, security i operacji,
  - repo ma być **portfolio-ready** – kod + architektura + IaC + ADR + runbooki + troubleshooting,
  - środowisko jest **dev-only**, bez wymagań produkcyjnych (SLA, HA multi-AZ, RTO/RPO).
- Model kosztowy:
  - część usług ma darmowy tier (S3, Lambda, DynamoDB, CloudWatch w ograniczonym zakresie),
  - część ma koszt stały niezależny od użycia (NAT Gateway, RDS w wyższych klasach, duże ECS/EKS),
  - łatwo „przestrzelić” koszty, zostawiając zasoby włączone na dłużej bez potrzeby.
- Potrzeba:
  - ustalić **prostą, spójną politykę kosztową** („cost guardrails”), która:
    - pozwala **świadomie** używać też droższych usług na potrzeby nauki,
    - wymusza **krótki czas życia drogich zasobów** i ich odtwarzanie Terraformem / pipeline’ami,
    - chroni przed przypadkowymi, długoterminowymi kosztami.

---

## 2. Problem / Decision Driver

Jak prowadzić kurs i eksperymenty w AWS tak, aby:

- **nie zabić** się kosztami przy długotrwałym `W00–W24`,
- **nie ograniczyć nauki** tylko do „taniego” podzbioru usług (np. rezygnując z RDS, NAT, ECS),
- jednocześnie:
  - utrzymać środowisko w ryzach (`dev-only`, pojedynczy region, pojedyncze konto),
  - móc spokojnie rozmawiać na rozmowie rekrutacyjnej o **realnych** komponentach (RDS, ECS, NAT, itp.),
  - mieć proste zasady cleanupu i odtwarzania.

---

## 3. Opcje

### Opcja A — „Ultra-oszczędnie” (unikamy wszystkiego, co kosztuje)

- Maksymalne ograniczanie usług:
  - brak RDS, brak NAT Gateway, brak ECS (tylko Lambda + S3 + DynamoDB),
  - wykorzystywanie praktycznie wyłącznie darmowego tieru.
- Zalety:
  - minimalne koszty miesięczne,
  - małe ryzyko przypadkowego „przestrzelenia” rachunku.
- Wady:
  - **zubożona nauka** – brak realnych scenariuszy z RDS, NAT, ECS, VPC z prywatnymi subnetami,
  - mało reprezentatywne dla typowych projektów .NET w AWS,
  - portfolio wygląda bardziej jak „lab z Lambdą” niż system z prawdziwą infrastrukturą.

### Opcja B — „Bez limitów” (ignorujemy koszty w imię nauki)

- Używanie usług tak, jak w projekcie produkcyjnym:
  - wiele środowisk, kilka regionów, pełne HA (multi-AZ, multi-AZ RDS, wiele NAT Gateway),
  - brak cleanupu, zasoby często zostają „na stałe”.
- Zalety:
  - pełny zakres techniczny, zbliżony do realnych dużych wdrożeń.
- Wady:
  - wysokie, nieprzewidywalne koszty,
  - duże ryzyko, że kurs trzeba przerwać lub ograniczyć, bo rachunek jest zbyt wysoki,
  - słaba dyscyplina operacyjna (brak cleanupu, brak świadomości kosztów).

### Opcja C — „Learning-first z guardrails” (ephemeralne zasoby drogie, IaC + cleanup)

- Założenia:
  - **pełna nauka kluczowych usług** (RDS, ECS, NAT Gateway, VPC, itp.),
  - **drogie zasoby są tworzone na czas lekcji / taska**, a potem świadomie usuwane,
  - odtwarzalność zapewnia **Terraform + pipeline’y** (IaC jako jedyne źródło prawdy).
- Praktyka:
  - tanie / serverless / free-tier mogą żyć dłużej (S3, DynamoDB w małej skali, Lambda, podstawowe logi),
  - drogie elementy (RDS, NAT Gateway, większe ECS) mają:
    - **oznaczone tagami** (`Project=OrderFlow`, `Env=dev`, `TTL`/`Owner`),
    - **jasne zasady**: tworzymy na czas ćwiczenia, potem `terraform destroy` lub usuwamy moduł w `envs/dev`,
  - stawianie środowiska to:
    - `terraform apply` lokalnie lub przez pipeline (`plan` + `apply`),
    - wtedy, gdy jest realna potrzeba (lekcja, task).

---

## 4. Decyzja

Wybieramy **Opcję C — „Learning-first z guardrails”**.

- Priorytetem jest **pełna wartość edukacyjna**, ale:
  - z **ograniczeniem czasu życia drogich zasobów**,
  - z **konsekwentnym użyciem IaC (Terraform)** i pipeline’ów do tworzenia/niszczenia środowiska.
- Kluczowe zasady:
  1. **Nigdy nie rezygnujemy z ważnej usługi tylko dlatego, że coś kosztuje**, jeśli jest ona:
     - powszechna w realnych systemach (RDS, ECS, NAT Gateway, VPC z prywatnymi subnetami),
     - kluczowa dla zrozumienia architektury AWS.
  2. **Zasób może istnieć „na czas lekcji / taska”**:
     - np. stawiamy RDS + ECS + NAT na jedną/dwie sesje,
     - po zakończeniu zadania niszczymy środowisko (`terraform destroy` lub wyłączamy dany moduł w `envs/dev`),
     - w kolejnym tygodniu/tasku, gdy potrzeba wraca, odtwarzamy je **z Terraform** / pipeline’u.
  3. **Stałe środowisko dev jest „lekko-średnio kosztowe”**:
     - dopuszczamy stałą VPC dev, S3, parametry, role IAM, podstawowe logowanie,
     - drogie komponenty (RDS, NAT Gateway, duże ECS/EKS) nie wiszą w tle bez powodu.

---

## 5. Konsekwencje

### 5.1 Pozytywne

- **Realistyczna nauka**:
  - dotykasz RDS, ECS, NAT, VPC, IAM, itp. w realnych scenariuszach,
  - możesz o nich opowiadać na rozmowie jako o własnym projekcie.
- **Kontrola kosztów**:
  - drogie elementy nie wiszą miesiącami – ich czas życia jest powiązany z taskami / tygodniami,
  - możliwość okresowego „wyzerowania” środowiska dev (`terraform destroy` wszystkiego lub modułów).
- **Dyscyplina operacyjna**:
  - IaC + tagowanie => zawsze wiesz, skąd się wziął zasób i jak go odtworzyć,
  - cleanup jest naturalną częścią definicji tasków (np. Wxx-Tyy zawiera krok „sprzątanie”).

### 5.2 Negatywne / trade-offy

- **Czas na odtwarzanie środowiska**:
  - przed sesją trzeba czasem znowu zrobić `terraform apply` / uruchomić pipeline,
  - wymaga to cierpliwości i dbałości o kolejność kroków.
- **Złożoność IaC/pipeline’ów**:
  - trzeba zaprojektować moduły Terraform tak, aby można było względnie niezależnie włączać/wyłączać komponenty,
  - pipeline’y muszą radzić sobie z częściowym stanem (np. RDS stworzone, ECS jeszcze nie).

---

## 6. Wpływ na kolejne tygodnie

- **Projektowanie modułów Terraform (`infra/terraform/modules`, `envs/dev`)**:
  - moduły dla drogich komponentów (RDS, NAT, ECS cluster) powinny być:
    - osobno wydzielone,
    - łatwe do wyłączenia / zniszczenia bez ruszania całego VPC.
- **Tagowanie zasobów**:
  - konsekwentne tagi:
    - `Project = OrderFlow-AWS-Lab`
    - `Env = dev`
    - `Owner = <Twoje_Imię_Nazwisko>`
    - opcjonalnie `TTL` (np. data lub opis: `session`, `week`, `temporary`)
  - ułatwia to późniejszą analizę kosztów i cleanup.
- **Budżety i alerty (awareness)**:
  - w jednym z tygodni (np. IAM/FinOps) warto:
    - skonfigurować prosty `AWS Budget` z alertem mailowym,
    - nie musi to być idealne FinOps, ale ma dawać świadomość kosztów.
- **Definicje tasków tygodniowych**:
  - przy taskach, które tworzą drogie zasoby, dodać:
    - krok „cleanup” (np. `terraform destroy -target=...` lub sekcja „Jak posprzątać” w runbooku),
    - przypomnienie o tagowaniu.

---

## 7. Weryfikacja / rollback

- **Jak poznam, że guardrails działają:**
  - rachunek za AWS w trakcie kursu jest przewidywalny i akceptowalny,
  - nie ma „zapomnianych” RDS / NAT / ECS działających tygodniami bez powodu,
  - w `docs/weekly/*/tasks.md` i `log.md` pojawiają się kroki cleanupu i odniesienia do Terraform.
- **Rollback / korekta:**
  - jeśli mimo wszystko koszty rosną zbyt mocno:
    - możemy wprowadzić twarde limity (np. rezygnacja z części scenariuszy z RDS lub NAT),
    - albo jeszcze bardziej skrócić czas życia drogich zasobów (tylko na jedną sesję).
  - decyzja o takim „przykręceniu śruby” powinna być odnotowana w kolejnym ADR lub update tego dokumentu.

---

## 8. Powiązane dokumenty

- `docs/adr/ADR-0001-course-scope.md` — globalny zakres kursu i projektu.
- `docs/roadmap/aws-course-roadmap-operational-0-24.md` — roadmapa tygodni `W00–W24`, w tym sekcje `Koszt/Cleanup`.
- `docs/runbooks/aws-local-setup.md` — runbook lokalnego przygotowania środowiska (narzędzia + profil `swpr-dev`).
- `docs/weekly/W01/*` — artefakty tygodnia W01 (plan, tasks, log, evidence, questions, summary).
