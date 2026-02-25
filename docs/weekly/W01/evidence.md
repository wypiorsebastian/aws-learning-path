## W01 — evidence

> Zbieraj tu konkretne dowody wykonania pracy z tygodnia W01.

### Przykładowe elementy evidence
- Fragmenty outputu:
  - `aws --version`
  - `terraform version`
  - `docker --version`
  - `dotnet --info`
  - `aws sts get-caller-identity` (zanonimizowany).
- Opis skonfigurowanych profili i regionu (bez wrażliwych danych).
- Linki/referencje do kluczowych plików:
  - `docs/runbooks/aws-local-setup.md`
  - `docs/adr/ADR-0002-cost-guardrails-dev.md`
  - `docs/lessons/W01-summary.md`

---

### Zebrane evidence

- Narzędzia lokalne (W01-T01):
  - `aws --version` → `aws-cli/2.33.29 Python/3.13.11 Linux/6.18.8-200.fc43.x86_64 exe/x86_64.fedora.43`
  - `terraform version` → `Terraform v1.14.6` (`linux_amd64`)
  - `docker --version` → `Docker version 29.2.1, build a5c7197`
  - `dotnet --info` → SDK `10.0.102`, runtimes `Microsoft.AspNetCore.App 10.0.2`, `Microsoft.NETCore.App 10.0.2` na Fedora 43 (`RID=fedora.43-x64`)
- Profile i STS (W01-T02):
  - Główny profil roboczy: `swpr-dev` (świadomie brak profilu `default`; każda operacja ma jawnie wskazywać profil).
  - Region domyślny profilu: `eu-central-1` (dla projektu przyjmujemy region Frankfurt; jeśli korzystasz z innego, zastąp go konsekwentnie w konfiguracji i dokumentacji).
  - `aws sts get-caller-identity --profile swpr-dev` → poprawna tożsamość typu `assumed-role` + konto dev (szczegóły zanonimizowane na potrzeby repo).
- Runbook lokalnego setupu (W01-T03):
  - `docs/runbooks/aws-local-setup.md` opisuje instalację narzędzi, konfigurację profili CLI (profil `swpr-dev`, brak `default`), ustawienie regionu oraz kroki weryfikacji i typowe pułapki.

