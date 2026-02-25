## W01 — dziennik pracy

> Notuj tutaj krótkie wpisy z każdej sesji (czas, TaskId, co zostało zrobione / decyzje).

### Wzór wpisu
- `2026-03-01 20:15` — `W01-T01` — krótki opis wykonanej pracy / decyzji.

---

### Wpisy

- `2026-02-25 00:00` — `W01-T01` — zweryfikowano lokalne środowisko: `aws --version` (aws-cli/2.33.29), `terraform version` (v1.14.6), `docker --version` (29.2.1), `dotnet --info` (SDK 10.0.102 na Fedora 43); brak problemów z PATH, wszystkie narzędzia dostępne w powłoce bash.
- `2026-02-25 00:10` — `W01-T02` — skonfigurowano główny profil AWS CLI `swpr-dev` (bez użycia profilu `default`); potwierdzono tożsamość i konto za pomocą `aws sts get-caller-identity --profile swpr-dev`. Brak profilu `default` jest decyzją bezpieczeństwa — każda operacja ma jawnie wskazywać profil.
- `2026-02-25 00:20` — `W01-T03` — utworzono runbook `docs/runbooks/aws-local-setup.md` opisujący instalację AWS CLI, Terraform, Docker, .NET 10 SDK, konfigurację profilu `swpr-dev` (bez `default`), ustawienie regionu `eu-central-1`, kroki weryfikacji (wersje narzędzi, STS) oraz typowe pułapki.
- `2026-02-25 00:30` — `W01-T04` — utworzono `docs/adr/ADR-0002-cost-guardrails-dev.md` definiujący zasady kosztowe dla środowiska dev: learning-first z guardrails (ephemeralne drogie zasoby tworzone na czas lekcji/tasków, odtwarzane Terraformem/pipeline’ami, stałe środowisko dev utrzymywane w rozsądnym koszcie).

