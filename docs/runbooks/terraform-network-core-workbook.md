# Workbook — budowa sieci VPC dev w Terraform (moduł network-core)

## Przeznaczenie

Ten dokument to **kompleksowa instrukcja krok po kroku** tworzenia warstwy sieciowej (VPC, subnety, IGW, NAT, route tables, Security Groups) w Terraform. Ma pozwolić:

- **Odtworzyć cały proces** od zera w przyszłości.
- **Rozumieć zależności** między plikami i zasobami (mapa mentalna).
- **Pracować pojedynczo** (jeden plik lub jedna grupa zasobów na raz) bez gubienia się w procesie.
- **Weryfikować postęp** za pomocą checklisty na końcu dokumentu.

**Kontekst projektowy:** design w `docs/lessons/W04-network-core-module-design.md`, `docs/lessons/W04-traffic-models.md`, `docs/lessons/W04-sg-nacl-baseline.md`; backend S3 skonfigurowany w `envs/dev` (W06-T01, W06-T02).

---

## Część 1 — Mapa mentalna: co budujemy i po co

### 1.1 Cel warstwy sieciowej

Tworzymy **szkielet VPC dev**, w którym później będą działać:

- **ALB** (w subnetach public) — wejście z Internetu.
- **ECS, Lambda, RDS** (w subnetach private) — aplikacje i baza.
- **Moduł network-endpoints** (W07) — doda trasy do S3/DynamoDB i Interface Endpoints w tych samych subnetach/routingu.

Bez tej warstwy nie ma adresacji, routingu ani baseline’u SG — dlatego robimy ją pierwszą.

### 1.2 Zasoby AWS i ich rola (w kolejności zależności)

| # | Zasób | Po co istnieje | Z czego zależy |
|---|--------|----------------|----------------|
| 1 | **VPC** | Kontener sieciowy (10.0.0.0/16); wszystko żyje „w środku”. | — |
| 2 | **Subnety (4)** | Segmentacja: public (ALB, NAT) vs private (ECS, RDS, Lambda). 2 AZ dla multi-AZ. | VPC |
| 3 | **Internet Gateway (IGW)** | Bramka „VPC ↔ Internet”; bez niej public nie ma dostępu do/z Internetu. | VPC |
| 4 | **Elastic IP (EIP)** | Stały publiczny IP dla NAT Gateway (wymagany przez AWS). | — (ale używany tylko przez NAT) |
| 5 | **NAT Gateway** | Umożliwia **private** wychodzenie do Internetu (SQS, CloudWatch, zewn. API) bez wystawiania private na zewnątrz. | VPC, subnet public (np. public-a), EIP |
| 6 | **Route table — public** | Mówi: ruch z public idzie do IGW (0.0.0.0/0 → IGW). | VPC, IGW |
| 7 | **Route table — private** | Mówi: ruch z private idzie do NAT (0.0.0.0/0 → NAT); trasy do S3/DynamoDB doda W07. | VPC, NAT Gateway |
| 8 | **Route table associations (4)** | Łączy każdy subnet z właściwą route table (public-a/b → public RT, private-a/b → private RT). | Subnety, obie route tables |
| 9 | **Routes (2)** | Jedna trasa w public RT (0.0.0.0/0 → IGW), jedna w private RT (0.0.0.0/0 → NAT). | Route tables, IGW, NAT |
| 10 | **Security Groups (3)** | Stateful firewall: sg_alb (ALB), sg_app (ECS/Lambda), sg_rds (RDS). Kto z kim może gadać i na jakich portach. | VPC |

**NACL:** świadomie **nie** tworzymy własnych NACL w dev — używamy domyślnego NACL VPC (allow all), żeby uniknąć pułapki z portami efemerycznymi.

### 1.3 Gdzie to wszystko „mieszka” w Terraform

- **Moduł `infra/terraform/modules/network-core/`** — zawiera **definicje** wszystkich powyższych zasobów (VPC, subnety, IGW, NAT, RT, SG).
- **Root `infra/terraform/envs/dev/`** — **wywołuje** ten moduł (jedna blokada `module "network_core"`) i przekazuje mu zmienne (np. `name_prefix`, `tags`). Nie definiuje sam VPC/subnetów — tylko korzysta z outputów modułu.

Dzięki temu:
- Sieć jest w jednym, reużywalnym module.
- envs/dev może później dodać drugi moduł (np. `network-endpoints`) i przekazać mu outputy z `network-core` (np. `private_route_table_id`, `private_subnet_ids`).

### 1.4 Kolejność plików i bloków (co tworzyć w jakiej kolejności)

Poniższa kolejność minimalizuje błędy „odwołanie do nieistniejącego zasobu”:

1. **modules/network-core/versions.tf** — wymagania Terraform i providera AWS (bez tego nic nie działa).
2. **modules/network-core/variables.tf** — wejścia modułu (vpc_cidr, azs, subnety, name_prefix, tags); używane w main.tf i security.tf.
3. **modules/network-core/main.tf** — jeden plik, ale wypełniany w trzech etapach (Kroki 3–5 w Części 2), żeby można było weryfikować plan po każdej porcji:
   - **Etap 1 (Krok 3):** locals, VPC, subnety (4×),
   - **Etap 2 (Krok 4):** IGW, EIP, NAT Gateway (w public-a),
   - **Etap 3 (Krok 5):** route table public + route 0.0.0.0/0 → IGW, route table private + route 0.0.0.0/0 → NAT, route_table_association (4×).
4. **modules/network-core/security.tf** — trzy Security Groups (sg_alb, sg_app, sg_rds) z regułami zgodnie z W04-sg-nacl-baseline.
5. **modules/network-core/outputs.tf** — wszystkie wyjścia (vpc_id, subnet_ids, route_table_ids, sg_*_id itd.) potrzebne dla W07 i modułów aplikacyjnych.
6. **envs/dev/main.tf** — rozszerzenie o wywołanie `module "network_core"` z `source = "../../modules/network-core"` i przekazaniem zmiennych.
7. **envs/dev/variables.tf** — ewentualne zmienne root (np. region już jest; można dodać name_prefix, tags), jeśli chcesz przekazywać je z tfvars.

Po każdym kroku (albo po grupie kroków) warto uruchomić `terraform init` (gdy zmieniasz moduły), `terraform validate` i `terraform plan`, żeby upewnić się, że nie ma błędów odwołań.

---

## Część 2 — Instrukcja krok po kroku

### Krok 1 — versions.tf w module

**Plik:** `infra/terraform/modules/network-core/versions.tf`

**Co zawiera:**  
Blok `terraform { required_version = ">= 1.0"; required_providers { aws = { source = "hashicorp/aws", version = "~> 5.0" } } }`.

**Po co:** Terraform i provider AWS muszą być zadeklarowani; bez tego `terraform init` w envs/dev nie będzie wiedział, skąd brać providera przy module.

**Weryfikacja:** Z katalogu `envs/dev` uruchom `terraform init` (jeśli moduł jest już dodany w main.tf) lub po prostu utwórz plik — walidacja przyjdzie przy pełnym module.

---

### Krok 2 — variables.tf w module

**Plik:** `infra/terraform/modules/network-core/variables.tf`

**Co zawiera:**  
Zmienne: `vpc_cidr` (default `"10.0.0.0/16"`), `azs` (list, np. `["eu-central-1a", "eu-central-1b"]`), `public_subnet_cidrs`, `private_subnet_cidrs`, `enable_nat_gateway` (bool), `name_prefix` (string), `tags` (map(string)). Opcjonalnie: `single_nat`, `app_port` (np. 8080) dla SG.

**Po co:** Moduł dostaje parametry z zewnątrz; można w envs/dev nadpisać np. `name_prefix` bez zmiany kodu modułu. Wartości domyślne zgodne z W03/W04.

**Weryfikacja:** `terraform validate` w katalogu modułu (jeśli uruchamiasz go osobno) lub w envs/dev po dodaniu modułu.

---

### Krok 3 — main.tf w module (VPC i subnety)

**Plik:** `infra/terraform/modules/network-core/main.tf`

**Sekcja 3a — locals**  
`common_tags = merge(var.tags, { Project = "OrderFlow-AWS-Lab", Env = "dev", ManagedBy = "terraform", Module = "network-core" })` — używane we wszystkich zasobach.

**Sekcja 3b — VPC**  
`aws_vpc` z `cidr_block = var.vpc_cidr`, `enable_dns_hostnames = true`, `enable_dns_support = true`, tagi (Name = `${var.name_prefix}-vpc`).

**Sekcja 3c — Subnety**  
Cztery `aws_subnet`: public-a (var.azs[0], var.public_subnet_cidrs[0]), public-b (var.azs[1], var.public_subnet_cidrs[1]), private-a (var.azs[0], var.private_subnet_cidrs[0]), private-b (var.azs[1], var.private_subnet_cidrs[1]). Dla public: `map_public_ip_on_launch = true`. Tagi Name np. `{name_prefix}-public-a` itd.

**Po co:** VPC to kontener; subnety dzielą przestrzeń na public/private i AZ. Bez nich nie ma gdzie postawić IGW/NAT ani przypisać route tables.

**Weryfikacja:** `terraform plan` — powinien pokazać utworzenie VPC i 4 subnetów (jeśli reszty main.tf jeszcze nie ma, plan może narzekać na brakujące zasoby; wtedy dodajesz kolejne bloki).

---

### Krok 4 — main.tf w module (IGW, EIP, NAT)

**Ten sam plik:** `infra/terraform/modules/network-core/main.tf`

**Sekcja 4a — Internet Gateway**  
`aws_internet_gateway` z `vpc_id = aws_vpc.this.id` (lub jak nazwałeś VPC). Tag Name np. `{name_prefix}-igw`.

**Sekcja 4b — Elastic IP**  
`aws_eip` dla NAT (domain = "vpc"). Tag Name np. `{name_prefix}-nat-eip`.

**Sekcja 4c — NAT Gateway**  
`aws_nat_gateway` z `subnet_id` = subnet public-a, `allocation_id = aws_eip.nat.id`. Tag Name np. `{name_prefix}-nat`. Warunek: `count = var.enable_nat_gateway ? 1 : 0` (opcjonalnie), żeby móc wyłączyć NAT.

**Po co:** IGW umożliwia ruch public ↔ Internet; NAT umożliwia ruch private → Internet bez wystawiania private na zewnątrz.

**Weryfikacja:** `terraform validate`; `terraform plan` powinien pokazywać IGW, EIP, NAT.

---

### Krok 5 — main.tf w module (route tables i trasy)

**Ten sam plik:** `infra/terraform/modules/network-core/main.tf`

**Sekcja 5a — Route table public**  
`aws_route_table` z vpc_id; tag Name np. `{name_prefix}-public-rt`.  
`aws_route`: `route_table_id` = ta RT, `destination_cidr_block = "0.0.0.0/0"`, `gateway_id = aws_internet_gateway.this.id`.

**Sekcja 5b — Route table private**  
`aws_route_table` z vpc_id; tag Name np. `{name_prefix}-private-rt`.  
`aws_route`: destination 0.0.0.0/0, `nat_gateway_id = aws_nat_gateway.this[0].id` (jeśli używasz count). Uwaga: private RT **nie** zawiera jeszcze tras do S3/DynamoDB — te doda moduł network-endpoints (W07).

**Sekcja 5c — Route table associations**  
Cztery `aws_route_table_association`: public-a → public RT, public-b → public RT, private-a → private RT, private-b → private RT.

**Po co:** Route tables decydują, dokąd idzie ruch z subnetów (public → IGW, private → NAT). Associations wiążą subnety z tymi tabelami.

**Weryfikacja:** `terraform plan` — brak błędów; plan pokazuje 2 route tables, 2 routes, 4 associations.

---

### Krok 6 — security.tf w module (Security Groups)

**Plik:** `infra/terraform/modules/network-core/security.tf`

**Zasoby:**

- **sg_alb:** vpc_id = aws_vpc.this.id. Ingress: 80, 443 z 0.0.0.0/0. Egress: 8080 (lub var.app_port) do sg_app (security_group_id = aws_security_group.sg_app.id). Name np. `{name_prefix}-alb-sg`.
- **sg_app:** Ingress: 8080 z sg_alb. Egress: 5432 do sg_rds; 443 i 80 do 0.0.0.0/0. Name np. `{name_prefix}-ecs-sg`.
- **sg_rds:** Ingress: 5432 z sg_app. Egress: można pominąć lub 0.0.0.0/0 (return traffic). Name np. `{name_prefix}-rds-sg`.

**Uwaga:** sg_app musi być zdefiniowany przed sg_alb (bo sg_alb w egress odnosi się do sg_app), a sg_rds przed sg_app (sg_app w egress odnosi się do sg_rds). Kolejność w pliku: najpierw sg_rds, potem sg_app, potem sg_alb — albo użyj osobnych bloków `aws_security_group_rule`, żeby uniknąć zależności cyklicznych (zalecane: osobne reguły wg W04-sg-nacl-baseline).

**Po co:** Baseline dostępu — ALB tylko z Internetu i do app; app tylko z ALB i do RDS + AWS/Internet; RDS tylko z app.

**Weryfikacja:** `terraform validate`; `terraform plan` pokazuje 3 SG i reguły.

---

### Krok 7 — outputs.tf w module

**Plik:** `infra/terraform/modules/network-core/outputs.tf`

**Co zawiera:**  
Outputy: `vpc_id`, `vpc_cidr`, `public_subnet_ids`, `private_subnet_ids`, `public_subnet_id_a`, `public_subnet_id_b`, `private_subnet_id_a`, `private_subnet_id_b`, `public_route_table_id`, `private_route_table_id`, `nat_gateway_id`, `igw_id`, `sg_alb_id`, `sg_ecs_id`, `sg_rds_id`. Wszystkie odwołania do zasobów z main.tf i security.tf.

**Po co:** envs/dev i przyszły moduł network-endpoints (W07) potrzebują tych identyfikatorów; bez outputów moduł jest „ślepy” na zewnątrz.

**Weryfikacja:** `terraform plan` w envs/dev (gdy moduł jest wywołany) — outputy pojawią się w planie jako „Outputs”.

---

### Krok 8 — Wywołanie modułu w envs/dev

**Plik:** `infra/terraform/envs/dev/main.tf`

**Co dodać:**  
Blok `module "network_core" { source = "../../modules/network-core"; vpc_cidr = "10.0.0.0/16"; azs = ["eu-central-1a", "eu-central-1b"]; public_subnet_cidrs = ["10.0.1.0/24", "10.0.2.0/24"]; private_subnet_cidrs = ["10.0.11.0/24", "10.0.12.0/24"]; name_prefix = "orderflow-dev"; tags = {} }` (lub przekaż zmienne z var. w envs/dev). Provider zostaje ten sam (region = var.region).

**Po co:** Root łączy moduł z konfiguracją środowiska; state będzie w S3 (backend już skonfigurowany), a plan/apply będą tworzyć zasoby z modułu.

**Weryfikacja:** Z `envs/dev`: `terraform init` (pobranie modułu), `terraform validate`, `terraform plan`. Plan powinien pokazywać wszystkie zasoby modułu (VPC, subnety, IGW, NAT, RT, associations, SG) — **bez apply** na tym etapie (apply w W07).

---

## Część 3 — Checklist (śledzenie postępu)

Odnosz się do tej listy, tworząc pliki i zasoby pojedynczo. Zaznacz `[x]` po ukończeniu.

### Pliki w modules/network-core/

- [ ] `infra/terraform/modules/network-core/versions.tf`
- [ ] `infra/terraform/modules/network-core/variables.tf`
- [ ] `infra/terraform/modules/network-core/main.tf` (VPC + subnety)
- [ ] `infra/terraform/modules/network-core/main.tf` (IGW + EIP + NAT)
- [ ] `infra/terraform/modules/network-core/main.tf` (route tables + routes + associations)
- [ ] `infra/terraform/modules/network-core/security.tf`
- [ ] `infra/terraform/modules/network-core/outputs.tf`

### Pliki w envs/dev/

- [ ] `infra/terraform/envs/dev/main.tf` — wywołanie `module "network_core"` (provider już jest)

### Zasoby AWS (weryfikacja przez terraform plan)

- [ ] VPC (aws_vpc)
- [ ] Subnet public-a
- [ ] Subnet public-b
- [ ] Subnet private-a
- [ ] Subnet private-b
- [ ] Internet Gateway
- [ ] Elastic IP (dla NAT)
- [ ] NAT Gateway (w public-a)
- [ ] Route table — public
- [ ] Route table — private
- [ ] Route 0.0.0.0/0 → IGW (public RT)
- [ ] Route 0.0.0.0/0 → NAT (private RT)
- [ ] Route table association — public-a
- [ ] Route table association — public-b
- [ ] Route table association — private-a
- [ ] Route table association — private-b
- [ ] Security group — sg_alb
- [ ] Security group — sg_app
- [ ] Security group — sg_rds

### Weryfikacja końcowa

- [ ] `terraform fmt` (w modules/network-core i envs/dev)
- [ ] `terraform validate` (z katalogu envs/dev)
- [ ] `terraform plan` (z envs/dev) — plan bez błędów, lista zasobów do utworzenia zgodna z powyższą listą
- [ ] Gotowość do `terraform apply` w W07 (po dodaniu modułu network-endpoints lub przed — w zależności od kolejności zadań)

---

## Powiązane dokumenty

- Design modułu: `docs/lessons/W04-network-core-module-design.md`
- Modele ruchu: `docs/lessons/W04-traffic-models.md`
- Baseline SG: `docs/lessons/W04-sg-nacl-baseline.md`
- Architektura W03–W05: `docs/lessons/W04-W05-network-architecture-overview.md`
- Backend/bootstrap: `docs/runbooks/terraform-backend-bootstrap.md`
