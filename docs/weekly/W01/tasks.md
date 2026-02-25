## W01 — taski tygodnia

### Kontekst
- **WeekId:** `W01`
- **Cel tygodnia:** Przygotować bezpieczny baseline pracy z AWS lokalnie: narzędzia, profile CLI, region, runbook setupu oraz zasady kosztowe.
- **Outcome:** Działające profile AWS CLI + potwierdzona tożsamość oraz spisany runbook lokalnego setupu (`aws-local-setup.md`).

---

## Taski bazowe z roadmapy

### W01-T01 — Zainstaluj / zweryfikuj narzędzia lokalne (AWS CLI, Terraform, Docker, .NET 10 SDK)
- **TaskId:** `W01-T01`
- **Status:** `DONE`
- **Priorytet:** `P1`
- **Typ:** `Setup/Theory`
- **Cel:** Mieć zainstalowane i zweryfikowane podstawowe narzędzia potrzebne do pracy z AWS i projektem (.NET 10, Terraform, Docker, AWS CLI).
- **Estymata:** 60m
- **Input:**
  - Sekcja `W01` w `docs/roadmap/aws-course-roadmap-operational-0-24.md`.
  - Dokumentacja instalacji: AWS CLI, Terraform, Docker, .NET 10 SDK (dla Twojego systemu operacyjnego).
  - Aktualny stan środowiska lokalnego (co już jest zainstalowane).
- **Kroki:**
  1. Sprawdzić wersje aktualnie zainstalowanych narzędzi:
     - `aws --version`
     - `terraform version`
     - `docker --version`
     - `dotnet --info`
  2. Na podstawie wyników zdecydować, które narzędzia wymagają instalacji lub aktualizacji.
  3. Zainstalować/upewnić się, że są dostępne:
     - AWS CLI v2,
     - Terraform (aktualna stabilna wersja),
     - Docker (Engine/Desktop),
     - .NET 10 SDK (zgodnie z wymaganiami repo).
  4. Ponownie uruchomić komendy weryfikacyjne z kroku 1 i upewnić się, że PATH jest ustawiony poprawnie.
  5. Zanotować wersje narzędzi oraz ewentualne pułapki (proxy, brak uprawnień admina, różnice między shellami) do późniejszego użycia w `aws-local-setup.md`.
- **Verification:**
  - Wszystkie komendy:
    - `aws --version`
    - `terraform version`
    - `docker --version`
    - `dotnet --info`
    działają bez błędów.
  - Zidentyfikowane są ewentualne ograniczenia środowiskowe (jeśli istnieją) i uwzględnione w notatkach.
- **Evidence:**
  - Fragmenty outputu komend w `docs/weekly/W01/evidence.md` (bez wrażliwych danych).
  - Krótka notatka w `docs/weekly/W01/log.md` z numerem taska i listą zainstalowanych/zweryfikowanych narzędzi.

---

### W01-T02 — Skonfiguruj profile AWS CLI + region default + MFA (jeśli dostępne)
- **TaskId:** `W01-T02`
- **Status:** `DONE`
- **Priorytet:** `P1`
- **Typ:** `Security`
- **Cel:** Mieć poprawnie skonfigurowane profile AWS CLI z domyślnym regionem i działającym flow uwierzytelniania (w tym MFA, jeśli jest używane).
- **Estymata:** 45m
- **Input:**
  - Sekcja `W01` w roadmapie (metadane tygodnia, DoD, pułapki).
  - Informacje o środowisku AWS (konto, ewentualna Organization, nazwa konta `swpr-dev` itp.).
  - Dokumentacja AWS CLI: konfiguracja profili (`~/.aws/config`, `~/.aws/credentials`), `aws sts get-caller-identity`.
- **Kroki:**
  1. Zaplanować konwencję nazw profili (np. `swpr-dev`, `default` wskazujący na główny profil roboczy).
  2. Skonfigurować profil/profil(e) za pomocą:
     - `aws configure --profile <nazwa>` lub edycji plików `~/.aws/config` i `~/.aws/credentials`.
  3. Ustalić i ustawić region domyślny (np. `eu-central-1`) zarówno w profilu, jak i ewentualnie w zmiennych środowiskowych, jeśli to potrzebne.
  4. Jeśli używasz MFA:
     - upewnić się, że flow logowania obejmuje wymagane kroki (np. urządzenie MFA, czas życia sesji),
     - przetestować scenariusz wygasania sesji i ponownego logowania (jeśli to możliwe).
  5. Uruchomić:
     - `aws sts get-caller-identity --profile <profil>`
     i sprawdzić, czy identyfikator konta/ARN odpowiada oczekiwaniom.
  6. Zanotować wnioski i ewentualne pułapki (np. konflikt profili, domyślny region inny niż oczekiwany).
- **Verification:**
  - `aws sts get-caller-identity` działa bez błędów dla wybranego profilu.
  - Komendy CLI domyślnie trafiają w oczekiwany region.
  - Wiesz, z jakiej tożsamości korzystasz (konto, użytkownik/rola) i potrafisz to wyjaśnić.
- **Evidence:**
  - Zanonimizowany fragment outputu `aws sts get-caller-identity` w `docs/weekly/W01/evidence.md` (bez wrażliwych identyfikatorów).
  - Opis przyjętej konwencji profili/regionów w `aws-local-setup.md`.
  - Wpis w `docs/weekly/W01/log.md` z numerem taska.

---

### W01-T03 — Spisz runbook `aws-local-setup.md` (kroki + weryfikacja)
- **TaskId:** `W01-T03`
- **Status:** `DONE`
- **Priorytet:** `P1`
- **Typ:** `Docs`
- **Cel:** Utworzyć runbook `docs/runbooks/aws-local-setup.md`, który opisuje pełen proces przygotowania lokalnego środowiska do pracy z AWS dla tego projektu.
- **Estymata:** 30m
- **Input:**
  - Sekcja `W01` w roadmapie (artefakty i evidence).
  - Wyniki pracy z tasków `W01-T01` i `W01-T02` (konkretne komendy, decyzje, pułapki).
  - Zasady dokumentacji z `.cursor/rules/04-documentation-style-pl.mdc`.
- **Kroki:**
  1. Zdefiniować strukturę runbooka:
     - `Przeznaczenie`,
     - `Wymagania wstępne`,
     - `Instalacja narzędzi`,
     - `Konfiguracja profili i regionu`,
     - `Weryfikacja`,
     - `Pułapki`.
  2. Spisać konkretne kroki instalacji/weryfikacji dla:
     - AWS CLI,
     - Terraform,
     - Docker,
     - .NET 10 SDK.
  3. Opisać konfigurację profili AWS CLI i regionu (bez tajnych danych, tylko nazwy profili/regionów i ogólny flow).
  4. Dodać sekcję „Jak poznam, że działa” z listą komend weryfikacyjnych i oczekiwanymi rezultatami.
  5. Dopisać sekcję „Pułapki” na podstawie własnych problemów (np. PATH, proxy, konflikt wersji).
- **Verification:**
  - Runbook można przekazać innej osobie senior .NET i będzie w stanie odtworzyć środowisko.
  - Runbook jest spójny z rzeczywistą konfiguracją, którą masz lokalnie.
  - Dokument jest po polsku i korzysta z uzgodnionego stylu dokumentacyjnego.
- **Evidence:**
  - Plik `docs/runbooks/aws-local-setup.md` w repo.
  - Wpis w `docs/weekly/W01/log.md` powiązany z tym taskiem.
  - Odniesienie do runbooka w `docs/weekly/W01/evidence.md` i `docs/lessons/W01-summary.md`.

---

### W01-T04 — ADR-0002-cost-guardrails-dev.md (zasady kosztowe dev)
- **TaskId:** `W01-T04`
- **Status:** `DONE`
- **Priorytet:** `P2`
- **Typ:** `ADR`
- **Cel:** Opisać zasady kosztowe i guardrails dla środowiska developerskiego, aby świadomie minimalizować koszty eksperymentów w AWS.
- **Estymata:** 15m
- **Input:**
  - Globalne założenia kursu (profil uczestnika, `dev-only`, IaC, CI/CD) z roadmapy i ADR-0001.
  - Sekcja W01 (koszt/cleanup) w roadmapie.
  - Ogólna wiedza o modelu kosztowym AWS (free tier, budżety, typowe pułapki).
- **Kroki:**
  1. Zdefiniować problem/zakres decyzji: jak zapewnić, że praca w środowisku dev nie „ucieknie” kosztowo.
  2. Opisać kontekst:
     - profil uczestnika (samodzielna nauka, ograniczony budżet),
     - horyzont czasowy kursu,
     - brak wymagań produkcyjnych.
  3. Wypisać konkretne zasady (guardrails), np.:
     - preferencja usług w darmowym tierze / low-cost,
     - ograniczanie rozmiaru/klasy zasobów (np. małe instancje, brak drogich RDS na start),
     - obowiązkowy cleanup po eksperymentach (tagowanie + okresowe sprzątanie),
     - opcjonalne użycie AWS Budgets / alertów (choćby konceptualnie).
  4. Opisać konsekwencje tej decyzji dla kolejnych tygodni (np. wybór usług, unikanie niektórych scenariuszy).
  5. Zalogować decyzję w `docs/weekly/W01/log.md` z referencją do numeru ADR.
- **Verification:**
  - ADR jasno opisuje, jak podejmujesz decyzje kosztowe w trakcie kursu.
  - Po przeczytaniu ADR można wyjaśnić, dlaczego niektóre usługi/scenariusze są świadomie pomijane na tym etapie.
- **Evidence:**
  - Plik `docs/adr/ADR-0002-cost-guardrails-dev.md` w repo.
  - Wpis w `docs/weekly/W01/log.md` z numerem ADR i krótkim streszczeniem decyzji.

