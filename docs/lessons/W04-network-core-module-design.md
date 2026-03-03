## W04 — Projekt modułu `network-core` (W04-T02)

Projekt modułu Terraform `network-core` dla VPC dev, przygotowany pod przyszłe moduły (W05 `network-endpoints`, ALB, ECS, RDS, Lambda).

**Input:** W03 (`docs/diagrams/vpc-dev.md`), W04-T01 (`docs/lessons/W04-traffic-models.md`).

---

## 1. Odpowiedzialność modułu

Moduł `network-core` tworzy **szkielet sieciowy VPC dev**:

- VPC (CIDR z W03),
- subnety public/private w 2 AZ,
- Internet Gateway,
- NAT Gateway (1 szt. w public-a, zgodnie z ADR-0004),
- route tables dla subnetów public i private (bez tras Gateway Endpoints — to W05),
- baseline Security Groups i NACL (opcjonalnie w tym module lub osobno).

**Moduł nie tworzy:**
- Gateway Endpoints (S3, DynamoDB) — W05 `network-endpoints`,
- Interface Endpoints (Secrets Manager, SSM) — W05 `network-endpoints`,
- ALB, ECS, RDS, Lambda — osobne moduły aplikacyjne.

---

## 2. Zasoby AWS (lista)

| Zasób | Opis | Uwagi |
|-------|------|-------|
| `aws_vpc` | VPC 10.0.0.0/16 | enable_dns_hostnames, enable_dns_support |
| `aws_subnet` | 4 subnety: public-a, public-b, private-a, private-b | map_public_ip_on_launch tylko dla public |
| `aws_internet_gateway` | IGW przypięty do VPC | |
| `aws_eip` | Elastic IP dla NAT Gateway | |
| `aws_nat_gateway` | NAT w public-a | ADR-0004: 1 NAT |
| `aws_route_table` | public RT (0.0.0.0/0 → IGW) | |
| `aws_route_table` | private RT (0.0.0.0/0 → NAT) | W05 doda trasy do S3/DynamoDB |
| `aws_route_table_association` | 4× (każdy subnet → odpowiednia RT) | |
| `aws_route` | public: 0.0.0.0/0 → IGW | |
| `aws_route` | private: 0.0.0.0/0 → NAT | |
| `aws_security_group` | (opcjonalnie) baseline SG | W04-T03; może być w module lub osobnym |
| `aws_network_acl` | (opcjonalnie) NACL dla subnetów | W04-T03; może być w module lub osobnym |

---

## 3. Wejścia modułu (variables)

| Zmienna | Typ | Wartość domyślna | Opis |
|---------|-----|------------------|------|
| `vpc_cidr` | string | `"10.0.0.0/16"` | CIDR VPC |
| `azs` | list(string) | `["eu-central-1a", "eu-central-1b"]` | Lista AZ |
| `public_subnet_cidrs` | list(string) | `["10.0.1.0/24", "10.0.2.0/24"]` | CIDR public-a, public-b |
| `private_subnet_cidrs` | list(string) | `["10.0.11.0/24", "10.0.12.0/24"]` | CIDR private-a, private-b |
| `enable_nat_gateway` | bool | `true` | Czy tworzyć NAT Gateway |
| `single_nat` | bool | `true` | 1 NAT (dev) vs NAT per AZ; na przyszłość |
| `tags` | map(string) | `{}` | Tagi bazowe (Project, Env itp.) |
| `name_prefix` | string | `"orderflow-dev"` | Prefix w nazwach zasobów |

---

## 4. Wyjścia modułu (outputs) — przygotowane pod W05 i moduły aplikacyjne

| Output | Typ | Konsument | Użycie |
|--------|-----|-----------|--------|
| `vpc_id` | string | W05, ALB, ECS, RDS, Lambda | VPC ID |
| `vpc_cidr` | string | SG, NACL | CIDR VPC |
| `public_subnet_ids` | list(string) | ALB | Subnety public (public-a, public-b) |
| `private_subnet_ids` | list(string) | ECS, RDS, Lambda, W05 Interface Endpoints | Subnety private (private-a, private-b) |
| `public_subnet_id_a` | string | ALB, referencje | public-a (eu-central-1a) |
| `public_subnet_id_b` | string | ALB, referencje | public-b (eu-central-1b) |
| `private_subnet_id_a` | string | RDS subnet group, W05 Interface Endpoints | private-a |
| `private_subnet_id_b` | string | RDS subnet group, W05 Interface Endpoints | private-b |
| `public_route_table_id` | string | (referencja) | Route table public |
| `private_route_table_id` | string | **W05 Gateway Endpoints** | Route table private — W05 doda trasy S3/DynamoDB |
| `nat_gateway_id` | string | (referencja, billing) | NAT Gateway |
| `igw_id` | string | (referencja) | Internet Gateway |
| `sg_alb_id` | string | ALB | (jeśli SG w module) |
| `sg_ecs_id` | string | ECS, Lambda | (jeśli SG w module) |
| `sg_rds_id` | string | RDS | (jeśli SG w module) |

**Kluczowe dla W05:**
- `private_route_table_id` — moduł `network-endpoints` będzie dodawał trasy Gateway Endpoint (S3, DynamoDB) do tej route table.
- `private_subnet_ids` (lub `private_subnet_id_a`, `private_subnet_id_b`) — moduł `network-endpoints` użyje ich do tworzenia Interface Endpointów (Secrets Manager, SSM) — ENI w tych subnetach.

---

## 5. Struktura katalogów i plików

```
infra/terraform/
├── modules/
│   └── network-core/
│       ├── main.tf       # VPC, subnets, IGW, NAT, route tables, routes, associations
│       ├── variables.tf  # inputs
│       ├── outputs.tf    # outputs (vpc_id, subnet_ids, route_table_id, itp.)
│       ├── security.tf   # (opcjonalnie) SG, NACL
│       └── versions.tf   # terraform/aws provider constraints
├── envs/
│   └── dev/
│       ├── main.tf       # module "network_core" { source = "../../modules/network-core" ... }
│       ├── variables.tf
│       ├── terraform.tfvars
│       └── backend.tf    # S3 backend (W06+)
```

---

## 6. Zasady naming i tagowania

### Nazewnictwo zasobów (prefix z variable)

- VPC: `{name_prefix}-vpc`
- Subnety: `{name_prefix}-public-a`, `{name_prefix}-public-b`, `{name_prefix}-private-a`, `{name_prefix}-private-b`
- Route tables: `{name_prefix}-public-rt`, `{name_prefix}-private-rt`
- NAT Gateway: `{name_prefix}-nat`
- SG (jeśli w module): `{name_prefix}-alb-sg`, `{name_prefix}-ecs-sg`, `{name_prefix}-rds-sg`

### Tagi (wg ADR-0002)

- `Project` = `OrderFlow-AWS-Lab`
- `Env` = `dev`
- `ManagedBy` = `terraform`
- `Module` = `network-core`
- `Name` = (opisowa nazwa zasobu)

---

## 7. Integracja z W05 (network-endpoints)

Moduł `network-endpoints` (W05) będzie:

1. **Korzystać z outputów `network-core`:**
   - `private_route_table_id` — do skojarzenia Gateway Endpointów S3 i DynamoDB (dodanie tras do tej route table).
   - `private_subnet_ids` — do tworzenia Interface Endpointów (Secrets Manager, SSM); ENI endpointu musi być w subnecie z dostępem do routingu (private-a, private-b).

2. **Tworzyć:**
   - `aws_vpc_endpoint` (gateway) dla S3, DynamoDB — skojarzenie z `private_route_table_id`.
   - `aws_vpc_endpoint` (interface) dla Secrets Manager, SSM — `subnet_ids` = `private_subnet_ids`, `vpc_id` = `vpc_id`.

3. **Nie modyfikować** `network-core` — tylko używać jego outputów. Struktura route table private jest taka, że dodanie tras Gateway Endpoint (prefix list) nie wymaga zmian w `network-core`.

---

## 8. Integracja z modułami aplikacyjnymi (ALB, ECS, RDS, Lambda)

- **ALB:** `subnet_ids` = `public_subnet_ids`, `vpc_id` = `vpc_id`, `security_group_ids` = `[sg_alb_id]`.
- **ECS:** `subnet_ids` = `private_subnet_ids`, `vpc_id` = `vpc_id`, `security_group_ids` = `[sg_ecs_id]`.
- **RDS:** `db_subnet_group` z `private_subnet_ids`, `vpc_security_group_ids` = `[sg_rds_id]`.
- **Lambda (w VPC):** `subnet_ids` = `private_subnet_ids`, `vpc_security_group_ids` = `[sg_ecs_id]` (lub osobny SG Lambda).

---

## 9. Pułapki i uwagi

- **Route table association:** Każdy subnet musi mieć dokładnie jedną route table association; nie pominąć któregoś subnetu.
- **NACL:** Domyślna NACL VPC allow-all; jeśli tworzymy własną — pamiętać o ephemeral ports (1024–65535) w ingress i egress.
- **NAT:** Po `terraform apply` NAT generuje koszt (godzinowy + data) — ADR-0002: tworzyć na czas ćwiczeń, potem destroy.
