## W01 — podsumowanie tygodnia

#### Cel tygodnia
- Przygotować bezpieczny baseline pracy z AWS lokalnie: narzędzia, profile CLI, region, runbook lokalnego setupu oraz zasady kosztowe dev.

#### Co zrobiłem
- Zrealizowałem wszystkie taski tygodnia W01:
  - `W01-T01` — zweryfikowałem i mam działające lokalnie: AWS CLI (2.33.29), Terraform (1.14.6), Docker (29.2.1) oraz .NET 10 SDK (10.0.102).
  - `W01-T02` — skonfigurowałem główny profil AWS CLI `swpr-dev` bez profilu `default`, z regionem `eu-central-1` i potwierdziłem tożsamość przez `aws sts get-caller-identity`.
  - `W01-T03` — przygotowałem runbook `docs/runbooks/aws-local-setup.md` opisujący instalację narzędzi, konfigurację profili, regionu i kroki weryfikacji.
  - `W01-T04` — utworzyłem `docs/adr/ADR-0002-cost-guardrails-dev.md` definiujący zasady kosztowe dev („learning-first z guardrails”).

#### Co działa
- Lokalny zestaw narzędzi (AWS CLI, Terraform, Docker, .NET 10 SDK) jest zainstalowany i dostępny z powłoki.
- Profil AWS CLI `swpr-dev` działa poprawnie, ma ustawiony region `eu-central-1`, a STS zwraca poprawną tożsamość konta dev.
- Runbook `aws-local-setup.md` opisuje realne kroki instalacji, konfiguracji profilu i weryfikacji, które faktycznie przeszedłem.
- ADR-0002 formalizuje zasady kosztowe: mogę używać także droższych usług na potrzeby nauki, ale z krótkim czasem życia zasobów i odtwarzaniem przez Terraform/pipeline’y.

#### Co nie działało / problemy
- Brak istotnych problemów technicznych — narzędzia i CLI działały od razu po instalacji.
- Wymagało świadomej decyzji, aby **nie używać profilu `default`** i pracować wyłącznie na `swpr-dev`, żeby uniknąć przypadkowych operacji na złym koncie/regionie.

#### Smoke tests (W01)
- [x] `aws --version` działa i pokazuje oczekiwaną wersję.
- [x] `terraform version` działa.
- [x] `dotnet --info` działa i pokazuje .NET 10 SDK.
- [x] `aws sts get-caller-identity` działa dla głównego profilu roboczego (`swpr-dev`).

#### Evidence (odniesienia)
- `docs/weekly/W01/evidence.md`:
  - wersje narzędzi (`aws`, `terraform`, `docker`, `dotnet`),
  - wynik `aws sts get-caller-identity --profile swpr-dev`,
  - opis przyjętej konwencji profili i regionu.
- `docs/runbooks/aws-local-setup.md`:
  - szczegółowe kroki instalacji narzędzi, konfiguracji profilu `swpr-dev` i weryfikacji.
- `docs/adr/ADR-0002-cost-guardrails-dev.md`:
  - zasady kosztowe dev („learning-first z guardrails”, ephemeralne drogie zasoby, odtwarzanie Terraformem/pipeline’ami).

