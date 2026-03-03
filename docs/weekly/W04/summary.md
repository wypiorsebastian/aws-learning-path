## W04 — podsumowanie tygodnia

Podsumowanie tygodnia W04 (`Routing, IGW, NAT, SG, NACL — design`) względem roadmapy i DoD (po aktualizacji roadmapy na wariant design-only).

---

- **Cel tygodnia (z roadmapy):** Zrozumieć przepływy ruchu i zaprojektować sieć (routing, SG, NACL) gotową do implementacji w Terraform.
- **DoD:** Design jest zrozumiany i gotowy jako input do implementacji w W06 (modele ruchu, projekt modułu `network-core`, tabela SG/NACL, checklisty diagnostyczne).
- **Status:** **DONE** (wszystkie taski W04-T01..T04 zrealizowane zgodnie z nowym zakresem roadmapy).

### Co osiągnięto
- **Modele przepływu ruchu (W04-T01):**
  - Zbudowano szczegółowy model ruchu w VPC dev (`docs/lessons/W04-traffic-models.md`): inwentarz elementów, scenariusze A1–C2, macierz „kto z kim przez co”, synteza route tables, stateful vs stateless, pułapki (NACL, cross-AZ).
- **Projekt modułu `network-core` (W04-T02):**
  - Zaprojektowano moduł Terraform `network-core` (`docs/lessons/W04-network-core-module-design.md`): VPC, subnety, IGW, NAT (1 szt. zgodnie z ADR-0004), route tables + associations.
  - Zdefiniowano wejścia (CIDR, AZ, CIDR subnetów, flagi NAT) i wyjścia (`vpc_id`, `public/private_subnet_ids`, `public/private_route_table_id`, `nat_gateway_id`, SG IDs) pod przyszłe moduły (W05 `network-endpoints`, ALB, ECS, RDS, Lambda).
- **Baseline SG i NACL (W04-T03):**
  - Opracowano SG: `sg_alb`, `sg_app`, `sg_rds` z jasno opisanymi regułami ingress/egress spójnymi z modelami ruchu (`docs/lessons/W04-sg-nacl-baseline.md`).
  - Przyjęto pragmatyczny baseline NACL w dev (domyślny allow-all) z opisem bardziej restrykcyjnej opcji jako przyszły hardening.
- **Checklisty diagnostyczne (W04-T04):**
  - Utworzono `docs/runbooks/network-smoke-tests.md` z kolejnością diagnostyki (routing → SG → NACL), typowymi objawami (502/504, brak wyjścia do Internetu, ECS↔RDS, Lambda w VPC), szybką checklistą oraz przykładowymi komendami AWS CLI.

### Co nie zostało dowiezione / otwarte kwestie
- Zgodnie z aktualną roadmapą **nie implementowano** jeszcze modułu `network-core` w Terraform ani `terraform plan`:
  - implementacja HCL jest świadomie przesunięta na W06 (Terraform foundations + implementacja `network-core`),
  - ten brak nie jest odchyleniem, tylko częścią nowego planu (design-first).
- ADR-0004 (NAT) nadal ma status `Proposed`:
  - ma zostać formalnie oznaczony jako `Accepted` po pierwszym udanym `terraform plan/apply` w tygodniach sieciowych (W06/W07).

### Root cause problemów / opóźnień
- Brak technicznych blokad w W04; główną „zmianą” był **świadomy redesign roadmapy**:
  - zauważyłeś, że wcześniejsza wersja wymuszała implementację Terraform przed tygodniem z fundamentami Terraform,
  - wspólnie przeszliśmy na wariant: W04/W05 — design, W06/W07 — implementacja,
  - dzięki temu praca w W04 była czystym designem (zgodnym z obecnym DoD), bez presji na przedwczesne HCL.

### Lessons learned
- Dobry design sieci (routing, SG, NACL) **przed Terraformem**:
  - upraszcza późniejszą implementację (kod jest wtedy mechaniczny),
  - pozwala skupić się osobno na mechanice Terraform (W06), bez mieszania koncepcji sieci i języka HCL.
- Myślenie w kategoriach **stateful vs stateless**:
  - SG (stateful) vs NACL (stateless) i ich wpływ na debugowanie (ephemeral ports) jest kluczowe przy projektowaniu troubleshooting runbooków.
- Wczesne zaplanowanie **outputów modułu `network-core`**:
  - zmniejsza ryzyko refaktoringu, gdy pojawią się kolejne moduły (endpoints, ALB, ECS, RDS, Lambda),
  - ułatwia projektowanie kolejnych tygodni (W05/W06/W07) jako spójnego ciągu.

### Next actions (poza W04)
- **W05 (już zrealizowane):**
  - Design modułu `network-endpoints` (Gateway/Interface, Flow Logs) oraz notatki „kiedy który endpoint”.
- **W06:**
  - Zająć się fundamentami Terraform (providers, backend, moduły) i zaimplementować moduł `network-core` w HCL na bazie designu z W04.
  - Uruchomić `terraform fmt/validate/plan` dla `network-core` i przygotować evidence dla tygodnia.
- **W07:**
  - Zaimplementować moduł `network-endpoints` (Gateway/Interface, Flow Logs) i zweryfikować w praktyce, że ruch do S3/DynamoDB/Secrets/SSM idzie zgodnie z modelem endpoint-first, NAT jako fallback.

### Portfolio bullets (1–3)
- Zaprojektowałem sieć VPC dev w AWS na poziomie **routing/IGW/NAT/SG/NACL**, przygotowując pełny design pod moduł Terraform `network-core` (bez generowania kodu).
- Opracowałem baseline Security Groups i NACL oraz checklisty diagnostyczne (routing vs SG vs NACL), tworząc praktyczny **runbook troubleshootingowy** dla problemów sieciowych w VPC.
- Zdefiniowałem interfejs modułu `network-core` (wejścia/wyjścia, struktura katalogów, integracja z przyszłymi modułami), tak aby implementacja Terraform w kolejnych tygodniach była mechanicznym krokiem na bazie tego designu.

