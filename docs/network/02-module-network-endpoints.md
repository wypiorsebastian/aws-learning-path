# Moduł `network-endpoints` — szczegółowa dokumentacja

## 1. Po co istnieje moduł `network-endpoints`

Moduł `network-endpoints` odpowiada za **bezpieczny i efektywny dostęp** z naszej VPC dev do wybranych usług AWS oraz za **obserwowalność ruchu sieciowego**:

- dla **S3** i **DynamoDB**:
  - używamy **Gateway Endpoints**, żeby ruch nie szedł przez NAT/Internet,
  - redukujemy koszty NAT i poprawiamy bezpieczeństwo,
- dla **Secrets Manager** i **SSM Parameter Store**:
  - używamy **Interface Endpoints (PrivateLink)**,
  - sekrety/konfiguracja są dostępne po **prywatnym IP**, bez Internetu,
- dla całej VPC:
  - włączamy **VPC Flow Logs** do CloudWatch Logs,
  - mamy ślad tego, kto z kim rozmawia, na jakich portach i czy ruch był `ACCEPT`/`REJECT`.

**Azure analogia:**

- Gateway Endpoints ≈ **Service Endpoints** do Storage/Dynamo.
- Interface Endpoints ≈ **Private Endpoints** do Key Vault/Config.
- VPC Flow Logs ≈ **NSG/VNet Flow Logs** w Network Watcher.

Moduł jest **podpięty do network-core** — nie tworzy VPC ani subnetów, tylko korzysta z jego outputów (`vpc_id`, `private_route_table_id`, `private_subnet_ids`, `sg_ecs_id`).

---

## 2. Struktura modułu

Lokalizacja: `infra/terraform/modules/network-endpoints/`

- `versions.tf` — wersje Terraform/AWS.
- `variables.tf` — wejścia (VPC, route table, subnety, SG aplikacji, flagi enable_*, ustawienia Flow Logs).
- `main.tf` — Gateway Endpoints, Interface Endpoints, CloudWatch log group, IAM role/policy, aws_flow_log.
- `security.tf` — Security Group `sg_endpoints` + reguły ingress/egress.
- `outputs.tf` — identyfikatory endpointów, SG, Flow Logs.

---

## 3. `variables.tf` — jakie dane moduł wymaga na wejściu

Najważniejsze:

- `vpc_id` (`string`)
  - ID VPC z `network-core`.
  - potrzebne dla wszystkich endpointów i Flow Logs.
- `private_route_table_id` (`string`)
  - ID **prywatnej** route table (`aws_route_table.private` w `network-core`),
  - to do niej moduł „wstrzykuje” trasy Gateway Endpointów dla S3/DynamoDB.
- `private_subnet_ids` (`list(string)`)
  - ID subnetów private (`private-a`, `private-b`),
  - tutaj tworzymy ENI Interface Endpointów (Secrets/SSM).
- `sg_app_id` (`string`)
  - ID SG aplikacyjnego (`sg_app` / `sg_ecs_id`),
  - źródło ruchu do interface endpointów.

Flagi włączające/wyłączające elementy:

- `enable_s3_gateway_endpoint` (`bool`, domyślnie `true`)
- `enable_dynamodb_gateway_endpoint` (`bool`, domyślnie `true`)
- `enable_secretsmanager_interface_endpoint` (`bool`, domyślnie `true`)
- `enable_ssm_interface_endpoint` (`bool`, domyślnie `true`)
- `enable_flow_logs` (`bool`, domyślnie `true`)

Ustawienia Flow Logs:

- `flow_logs_destination_type` (na razie `"cloudwatch"`)
- `flow_logs_log_group_name` (nazwa log group; jeśli puste, budujemy ją z `name_prefix`)
- `flow_logs_retention_in_days` (domyślnie `7`)
- `flow_logs_traffic_type` (`"ACCEPT"` / `"REJECT"` / `"ALL"`, domyślnie `"ACCEPT"`)

Standardowe:

- `name_prefix` (`"orderflow-dev"`)
- `tags` (`map(string)`, domyślnie `{}`) — zmergowane z `common_tags`.

**Dlaczego tak:**

- moduł jest **parametryzowany**, ale domyślnie:
  - włącza wszystkie endpointy i Flow Logs,
  - zachowuje się zgodnie z designem W05 (endpoint-first, CloudWatch Logs).

---

## 4. `main.tf` — Gateway Endpoints, Interface Endpoints, Flow Logs

### 4.1 `locals.common_tags` i `data.aws_region.current`

`common_tags`:

- identyczny pattern jak w `network-core`, ale z `Module = "network-endpoints"`,
- pozwala w billingach odróżnić koszt VPC od kosztu endpointów/Flow Logs.

`data "aws_region" "current"`:

- pobiera region (np. `eu-central-1`),
- używamy go do złożenia `service_name` endpointów:
  - `com.amazonaws.${region}.s3`,
  - `com.amazonaws.${region}.dynamodb`,
  - `com.amazonaws.${region}.secretsmanager`,
  - `com.amazonaws.${region}.ssm`.

---

### 4.2 Gateway Endpoints — S3 i DynamoDB

Przykładowo (S3):

```hcl
resource "aws_vpc_endpoint" "s3_gateway" {
  count = var.enable_s3_gateway_endpoint ? 1 : 0

  vpc_id            = var.vpc_id
  service_name      = "com.amazonaws.${data.aws_region.current.name}.s3"
  vpc_endpoint_type = "Gateway"

  route_table_ids = [var.private_route_table_id]

  tags = merge(local.common_tags, {
    Name = "${var.name_prefix}-s3-gateway-endpoint"
  })
}
```

**Jak to działa:**

- Gateway Endpoint:
  - nie ma swojego ENI,
  - jest „wstrzykiwany” do **route table**:
    - dla odpowiednich prefiksów S3/DynamoDB dodaje trasę `→ vpce-...`.
- Ruch z private subnetów do S3/DynamoDB:
  - wykorzystuje tę trasę,
  - nie przechodzi przez NAT/IGW.

**Dlaczego go używamy:**

- **bezpieczeństwo:**
  - odcinasz się od publicznego Internetu w kontekście dostępu aplikacji do S3/DynamoDB,
- **koszt:**
  - Gateway Endpoint jest **bezpłatny** (płacisz tylko za operacje w S3/DynamoDB),
  - mniej ruchu przez NAT (płatny).

**Azure analogia:**  
Service Endpoint do Storage/DynamoDB — ruch zachowuje się jak wewnętrzny, bez konieczności korzystania z publicznego Internetu.

---

### 4.3 Security Group `sg_endpoints` (w `security.tf`)

```hcl
resource "aws_security_group" "sg_endpoints" {
  vpc_id      = var.vpc_id
  name        = "${var.name_prefix}-endpoints-sg"
  description = "Interface endpoints (Secrets/SSM): ingress z sg_app:443"
  ...
}

resource "aws_vpc_security_group_ingress_rule" "endpoints_from_app_https" {
  security_group_id            = aws_security_group.sg_endpoints.id
  referenced_security_group_id = var.sg_app_id
  from_port                    = 443
  to_port                      = 443
  ip_protocol                  = "tcp"
  description                  = "ECS/Lambda (sg_app) → interface endpoints (443)"
}

resource "aws_vpc_security_group_egress_rule" "endpoints_to_aws_https" {
  security_group_id = aws_security_group.sg_endpoints.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 443
  to_port           = 443
  ip_protocol       = "tcp"
  description       = "Interface endpoints → usługi AWS (443)"
}
```

**Cel SG:**

- **Ingress:**
  - tylko z `sg_app` (ECS/Lambda) na 443,
  - nikt inny w VPC nie może wejść na endpoint Secrets/SSM.
- **Egress:**
  - 443 do `0.0.0.0/0` (ale w praktyce to ruch wewnątrz sieci AWS, do usług Secrets/SSM).

**Dlaczego osobny SG, a nie w `sg_app`:**

- separacja odpowiedzialności:
  - `sg_app` opisuje, kto może mówić **do aplikacji** i dokąd aplikacja może wychodzić,
  - `sg_endpoints` opisuje tylko ruch **do/z endpointów**,
- przy debugowaniu:
  - patrzysz na `sg_endpoints` → od razu widzisz, kto może się łączyć z endpointem i dokąd on sam może się łączyć.

**Azure analogia:**  
NSG przypięty do NIC Private Endpointu (Key Vault/Config) — osobny od NSG aplikacyjnego.

---

### 4.4 Interface Endpoints — Secrets Manager i SSM

Przykład (Secrets):

```hcl
resource "aws_vpc_endpoint" "secretsmanager_interface" {
  count = var.enable_secretsmanager_interface_endpoint ? 1 : 0

  vpc_id            = var.vpc_id
  service_name      = "com.amazonaws.${data.aws_region.current.name}.secretsmanager"
  vpc_endpoint_type = "Interface"

  subnet_ids         = var.private_subnet_ids
  security_group_ids = [aws_security_group.sg_endpoints.id]

  private_dns_enabled = true
  ...
}
```

**Jak to działa:**

- Tworzy **ENI** w każdym prywatnym subnecie (`private-a`, `private-b`),
- SG endpointu to `sg_endpoints`,
- `private_dns_enabled = true`:
  - `secretsmanager.eu-central-1.amazonaws.com` → prywatne IP ENI,
  - aplikacje nie muszą znać specjalnych adresów `vpce-...`.

**Dlaczego Interface Endpointy:**

- sekrety/konfiguracja to **bardzo wrażliwe dane**:
  - chcemy, żeby ich pobieranie było:
    - możliwe z prywatnych subnetów (ECS/Lambda),
    - możliwe bez użycia NAT/Internetu,
    - kontrolowane przez SG.

**Azure analogia:**  
Private Endpoint do Key Vault / App Configuration z włączonym private DNS.

---

### 4.5 VPC Flow Logs — CloudWatch Logs

Fragment z `main.tf`:

- `aws_cloudwatch_log_group.vpc_flow_logs` — log group na logi,
- `aws_iam_role.vpc_flow_logs` + `aws_iam_role_policy.vpc_flow_logs` — rola pozwalająca pisać do CloudWatch,
- `aws_flow_log.vpc` — właściwa definicja Flow Logs.

**Parametry ważne z punktu widzenia sieci:**

- `vpc_id = var.vpc_id` — logujemy ruch dla całej VPC,
- `traffic_type = var.flow_logs_traffic_type` — domyślnie `ACCEPT`,
- `log_destination = aws_cloudwatch_log_group.vpc_flow_logs[0].arn` — logi trafiają do CloudWatch,
- `iam_role_arn` — rola, z poziomu której serwis VPC Flow Logs pisze logi.

**Po co:**

- Flow Logs pozwalają Ci **zobaczyć faktyczny ruch**:
  - czy ruch do S3/DynamoDB idzie przez endpoint (a nie NAT),
  - czy próby użycia endpointu Secrets/SSM są `ACCEPT` czy `REJECT`,
  - czy coś nie stoi na przeszkodzie (SG/NACL).

**Azure analogia:**  
NSG/VNet Flow Logs z włączeniem do Log Analytics.

---

## 5. `outputs.tf` — co moduł wystawia

Najważniejsze:

- `s3_gateway_endpoint_id`, `dynamodb_gateway_endpoint_id`
  - referencje do endpointów — przydadzą się np. w debugowaniu / przyszłych modułach.
- `secretsmanager_interface_endpoint_id`, `ssm_interface_endpoint_id`
  - identyfikatory interface endpointów,
  - mogą być użyte np. przy specyficznych policies.
- `endpoints_security_group_id`
  - ID `sg_endpoints` — przydatne, gdy inne moduły muszą np. dać ingress z endpointów do jakiegoś zasobu.
- `vpc_flow_log_id`, `vpc_flow_logs_log_group_name`
  - identyfikator Flow Log i nazwa log group — do debugowania i dokumentacji.

**Teraz** te outputy są głównie używane do:

- inspektracji/dokumentacji,
- ewentualnie przyszłych rozszerzeń.

---

## 6. Jak moduł jest używany w `envs/dev`

W `infra/terraform/envs/dev/main.tf`:

```hcl
module "network_endpoints" {
  source = "../../modules/network-endpoints"

  vpc_id                 = module.network_core.vpc_id
  private_route_table_id = module.network_core.private_route_table_id
  private_subnet_ids     = module.network_core.private_subnet_ids
  sg_app_id              = module.network_core.sg_ecs_id

  name_prefix = "orderflow-dev"
  tags        = {}
}
```

**Ważne zależności:**

- `network-endpoints` **nie** tworzy własnego VPC — zawsze korzysta z `network-core`,
- `private_route_table_id` mówi, która route table jest „private”,
- `private_subnet_ids` mówią, gdzie ENI endpointów mają się pojawić,
- `sg_ecs_id` (`sg_app_id`) mówi, kto jest klientem endpointów (ECS/Lambda).

---

## 7. Podsumowanie — jak myśleć o `network-endpoints`

Jeżeli po przerwie chcesz sobie odświeżyć obraz:

1. `network-core` stworzył:
   - VPC, subnety, IGW, NAT, route tables, SG.
2. `network-endpoints`:
   - **dodał prywatne „tunele”** do usług AWS:
     - Gateway EP: S3, DynamoDB (w route table),
     - Interface EP: Secrets, SSM (ENI w private),
   - **włączył logowanie ruchu** (VPC Flow Logs → CloudWatch).
3. `sg_endpoints`:
   - wpuszcza tylko ruch z `sg_app` na 443,
   - wypuszcza ruch z endpointów do usług AWS na 443.
4. Dzięki temu:
   - aplikacje w private subnetach:
     - biorą sekrety/konfigurację po prywatnym IP (bez NAT/Internetu),
     - sięgają do S3/DynamoDB po prywatnej ścieżce,
   - Ty masz:
     - spójny model bezpieczeństwa,
     - ślad ruchu w Flow Logs.

Reszta tygodni (ALB, ECS, RDS, Lambda, CI/CD) będzie się na to nakładać, ale **nie zmienia** tej logiki — jedynie ją wykorzystuje.

