## W07 — network-endpoints + deploy sieci do dev (podsumowanie)

### 1. Cel tygodnia

W07 był pierwszym tygodniem, w którym **sieć dev faktycznie trafiła do AWS**:

- zaimplementowaliśmy moduł `network-endpoints` (Gateway Endpoints, Interface Endpoints, Flow Logs),
- wpięliśmy go w istniejący `network-core`,
- wykonaliśmy ręczny `terraform apply` całego stacka sieci (walidacja przed pipeline z W08),
- rozszerzyliśmy runbook smoke tests, żeby świadomie weryfikować działanie endpointów i Flow Logs.

### 2. Co zostało wdrożone (technicznie)

#### 2.1 Gateway Endpoints — S3 i DynamoDB

- Utworzyliśmy **Gateway VPC Endpoints** dla:
  - `com.amazonaws.<region>.s3`,
  - `com.amazonaws.<region>.dynamodb`.
- Endpointy:
  - są przypięte do tej samej VPC co reszta sieci (`module.network_core.vpc_id`),
  - są skojarzone z **prywatną route table** (`module.network_core.private_route_table_id`).

Efekt:

- w prywatnej route table pojawiły się trasy `prefix S3/DynamoDB → vpce-...`,
- ruch z subnetów private do S3/DynamoDB:
  - nie przechodzi przez NAT Gateway ani IGW,
  - zostaje w prywatnej sieci AWS, co:
    - obniża koszty (mniej ruchu przez NAT),
    - poprawia bezpieczeństwo (brak wyjścia do „publicznego Internetu”).

**Azure analogia:**  
To zachowuje się podobnie jak **Service Endpoints** do Storage/DynamoDB — ruch z Twojego VNetu do PaaS jest prywatny i kontrolowany przez routing.

#### 2.2 Interface Endpoints — Secrets Manager i SSM (PrivateLink)

- Utworzyliśmy **Interface VPC Endpoints** dla:
  - `Secrets Manager`,
  - `SSM Parameter Store`.
- Endpointy:
  - tworzą ENI (karty sieciowe) w subnetach `private-a` i `private-b`,
  - są chronione przez dedykowaną SG `sg_endpoints`,
  - mają włączony **Private DNS**:
    - `secretsmanager.eu-central-1.amazonaws.com` i `ssm.eu-central-1.amazonaws.com` rozwiązują się do prywatnego IP w naszej VPC.

Security Group `sg_endpoints`:

- `sg_app` (ECS/Lambda) może:
  - łączyć się z endpointami na 443 (ingress do `sg_endpoints`),
- endpointy mogą:
  - wychodzić na 443 do `0.0.0.0/0` (w praktyce do usług AWS).

Efekt:

- aplikacje w subnetach private:
  - pobierają **sekrety** (Secrets Manager) i **parametry konfiguracyjne** (SSM) po prywatnym IP,
  - nie muszą korzystać z NAT Gateway / Internetu, ani specjalnych hostname’ów `vpce-...`.

**Azure analogia:**  
To odpowiednik **Private Endpointów** do Key Vault / App Configuration (NIC w Twoim subnecie, NSG na tym NICu, prywatna strefa DNS).

#### 2.3 VPC Flow Logs — CloudWatch Logs

- W module `network-endpoints` włączyliśmy **Flow Logs** dla całej VPC dev:
  - destination: **CloudWatch Logs**,
  - log group o nazwie opartej o `name_prefix` (np. `orderflow-dev-vpc-flow-logs`),
  - retencja krótkoterminowa (np. 7 dni),
  - `traffic_type = "ACCEPT"` (wystarczy do typowej analizy).
- Dodatkowo:
  - IAM role z trust policy dla `vpc-flow-logs.amazonaws.com`,
  - policy z uprawnieniami `logs:CreateLogGroup`, `logs:CreateLogStream`, `logs:PutLogEvents`, itp.

Efekt:

- mamy operacyjną widoczność:
  - kto z kim rozmawia w VPC (źródło, cel, port),
  - czy ruch był `ACCEPT` czy `REJECT`,
  - czy ruch do S3/DynamoDB idzie przez endpoint, czy przypadkiem przez NAT.

### 3. Pierwszy manualny `terraform apply` — po co i co wyszło

W W07 świadomie wykonaliśmy:

```bash
AWS_PROFILE=swpr-dev
terraform fmt
terraform validate
terraform plan
terraform apply
```

z katalogu `infra/terraform/envs/dev`.

Powody:

- chcieliśmy:
  - najpierw **zweryfikować sieć ręcznie**, zanim oddamy sterowanie pipeline’om,
  - mieć możliwość szybkiego debugowania problemów (np. opisy SG, istniejąca log group),
  - upewnić się, że design z W04/W05 jest poprawnie przełożony na realne zasoby.

Wynik:

- VPC, subnety, IGW, NAT, route tables, SG (`network-core`) zostały utworzone,
- Gateway/Interface Endpoints oraz Flow Logs z modułu `network-endpoints` też zostały utworzone,
- `terraform state list` pokazuje zasoby z obu modułów,
- plan po apply (uruchomiony ponownie) nie pokazał istotnego driftu.

Ta walidacja jest **jednorazowa** — od W08 kolejne apply mają być realizowane przez pipeline (GitHub Actions + OIDC).

### 4. Pułapki, które wyszły „na żywo”

#### 4.1 Znaki w opisach reguł SG (`description`)

- AWS ma bardzo restrykcyjny zestaw dozwolonych znaków w polu `description`:
  - tylko `a-zA-Z0-9. _-:/()#,@[]+=&;{}!$*`,
  - strzałki (`→`) i polskie litery powodowały błąd `Invalid rule description`.
- Musieliśmy:
  - uprościć opisy, a w przypadku reguł — wręcz je usunąć (opisy zostają na poziomie SG i w dokumentacji).

Wniosek:

- opisy SG w Terraform trzymamy **proste** (ASCII),
- wszystkie „ładne” opisy, kontekst i uzasadnienia — w `docs/network/*`, a nie w AWS API.

#### 4.2 Istniejąca log group dla Flow Logs

- Pierwsze podejście do tworzenia log group dla Flow Logs skończyło się błędem:
  - `ResourceAlreadyExistsException: The specified log group already exists`,
  - oznacza to, że:
    - ktoś już wcześniej utworzył log group o tej samej nazwie (ręcznie lub w nieudanym apply),
    - nie było jej jeszcze w stanie Terraform.
- Rozwiązanie w dev:
  - usunąć log group ręcznie w CloudWatch,
  - powtórzyć `terraform apply`.

Alternatywnie (bardziej „enterprise”): `terraform import` istniejącej log group do stanu.

#### 4.3 Koszty NAT / endpointów / Flow Logs

- NAT Gateway, interface endpoints i Flow Logs w CloudWatch generują:
  - opłatę godzinową (NAT, endpointy),
  - opłatę za dane (ruch/logi).
- Zgodnie z ADR-0002:
  - traktujemy to jako zasoby „na czas nauki”,
  - przy dłuższej przerwie warto:
    - zrobić `terraform destroy` stacka,
    - albo tymczasowo wyłączyć moduł `network-endpoints` i ponowić `apply`.

### 5. Runbook smoke tests — co zostało dodane

`docs/runbooks/network-smoke-tests.md` został rozszerzony o:

- **Gateway Endpoints (S3/DynamoDB)** — jak sprawdzić:
  - obecność endpointów i tras w route table,
  - to, że ruch do S3/DynamoDB nie idzie przez NAT (z pomocą Flow Logs).
- **Interface Endpoints (Secrets/SSM)** — jak sprawdzić:
  - istnienie endpointów w subnetach private,
  - poprawne SG endpointów (ingress z `sg_app` na 443, egress na 443),
  - działanie Private DNS (lub użycie hostname’ów `vpce-...` przy wyłączonym DNS),
  - status `ACCEPT/REJECT` w Flow Logs.
- **Flow Logs** — jak:
  - upewnić się, że logi są zbierane,
  - tymczasowo przełączyć `traffic_type` na `ALL` dla głębokiej diagnostyki.

Runbook jest teraz praktycznym narzędziem do weryfikacji sieci po każdym deployu.

### 6. Gotowość pod W08 (pipeline IaC)

Po W07 mamy:

- działającą sieć dev w AWS (`network-core + network-endpoints`),
- sprawdzoną ścieżkę `terraform apply` z lokalnej maszyny,
- runbook do smoke testów sieci.

To tworzy dobry punkt startowy dla W08:

- w W08 przenosimy `plan` i `apply` do **GitHub Actions** z użyciem **OIDC**,
- od tego momentu:
  - ręczny `apply` staje się wyjątkiem (tylko do diagnostyki),
  - standardem jest pipeline: PR → `plan` w CI, merge/manual → `apply` w CI.

