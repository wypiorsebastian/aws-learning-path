## W09 — taski tygodnia

### Kontekst

- **WeekId:** `W09`
- **Cel tygodnia:** Zbudować lokalny baseline aplikacyjny OrderFlow w .NET 10 (APIs, worker, health, logging) oraz podstawowy CI dla .NET.
- **Outcome:** Działające lokalnie 2–3 API + worker z health endpointami; `dotnet build/test` i workflow CI przechodzą.
- **Uwaga:** Zgodnie z zasadami projektu — kod generowany tylko na wyraźną prośbę; ten plik definiuje zakres i kroki; implementację wykonuje użytkownik (lub na żądanie agent).

---

## Taski bazowe z roadmapy

### W09-T01 — Utwórz orders-api, payments-api, catalog-api, order-worker

- **TaskId:** `W09-T01`
- **Status:** `DONE`
- **Priorytet:** `P1`
- **Typ:** `Coding`
- **Cel:** Dodać do repo cztery projekty: trzy API (orders, payments, catalog) oraz worker — minimalnie uruchamialne, bez overengineeringu.
- **Estymata:** 60m
- **Input:**
  - Ustalenia z D1 (struktura `src/`, nazwy projektów, target framework .NET 10).
  - Środowisko .NET lokalnie.
- **Kroki:**
  1. Utworzyć solution (jeśli brak) i katalogi projektów w `src/`.
  2. Dodać projekty: OrdersApi, PaymentsApi, CatalogApi (Web API), OrderWorker (Worker/BackgroundService).
  3. Ustawić target framework (np. net10.0 lub net8.0/net9.0).
  4. W każdym API: minimalny endpoint (np. GET `/` lub `/api/...`) zwracający 200.
  5. W workerze: minimalny Hosted Service (np. log co N sekund lub pusta pętla).
  6. Zweryfikować: `dotnet build`, `dotnet run` dla każdego projektu.
- **Verification:** `dotnet build` OK; każdy projekt uruchamia się lokalnie bez błędów.
- **Evidence:** Ścieżki do projektów w repo; output `dotnet build` (fragment lub screenshot).
- **Uwaga:** orders-api istniał wcześniej; wygenerowano payments-api i catalog-api; order-worker pominięty na żądanie.

---

### W09-T02 — Dodaj health endpoints + structured logging baseline

- **TaskId:** `W09-T02`
- **Status:** `DONE`
- **Priorytet:** `P1`
- **Typ:** `Coding`
- **Cel:** Każde API ma endpoint `/health`; wspólny baseline structured logging w aplikacjach.
- **Estymata:** 45m
- **Input:**
  - Projekty z W09-T01.
  - Dokumentacja ASP.NET Core Health Checks i logging (Microsoft.Extensions.Logging / Serilog).
- **Kroki:**
  1. W każdym API dodać GET `/health` (Health Checks API lub minimalny endpoint) zwracający status (Healthy/Unhealthy).
  2. Skonfigurować structured logging (format spójny: JSON lub czytelny tekst) we wszystkich projektach.
  3. W workerze: opcjonalnie prosty mechanizm „running” lub notatka, że health dotyczy API (DoD: health dla API).
  4. Przetestować lokalnie: `curl localhost:<port>/health` dla każdego API.
- **Verification:** `/health` zwraca 200 i status; logi w jednym, zrozumiałym formacie.
- **Evidence:** Opis lub snippet konfiguracji health + logging; wynik `curl .../health` (przykład).

---

### W09-T03 — Dodaj workflow dotnet build/test

- **TaskId:** `W09-T03`
- **Status:** `DONE`
- **Priorytet:** `P1`
- **Typ:** `CI/CD`
- **Cel:** Workflow GitHub Actions wykonujący `dotnet build` i `dotnet test` przy zmianach w kodzie.
- **Estymata:** 30m
- **Input:**
  - Repo z `src/`, solution, wersja .NET z projektów.
  - Konwencje workflowów z W08 (OIDC nie jest tu wymagany — tylko build/test).
- **Kroki:**
  1. Utworzyć `.github/workflows/dotnet-ci.yml`.
  2. Trigger: `push` do `main`, `pull_request` do `main`; paths: `src/**`, `*.sln` (lub szerszy).
  3. Job: checkout, setup .NET (np. `actions/setup-dotnet`), `dotnet restore`, `dotnet build`, `dotnet test`.
  4. Uruchomić workflow (push/PR) i upewnić się, że przechodzi.
- **Verification:** Workflow startuje na PR/push; `dotnet build` i `dotnet test` zielone (testy mogą być puste).
- **Evidence:** Link do pliku workflow; link/ID udanego runu w GitHub Actions.
- **Uwaga:** Zastosowano workflowy **per usługa** (ci-orders-api, ci-payments-api, ci-catalog-api, ci-order-worker) z triggerem na `paths: src/<projekt>/**` — spójne z modelem mikroserwisów i przyszłymi niezależnymi wdrożeniami. Każdy workflow buduje i testuje całą solution.

---

### W09-T04 — Zapisz architekturę kodu (prosta, pragmatyczna)

- **TaskId:** `W09-T04`
- **Status:** `TODO`
- **Priorytet:** `P2`
- **Typ:** `Docs`
- **Cel:** Udokumentować aktualną architekturę kodu: jakie projekty, co robią, jak są zorganizowane (solution, shared?), konwencje (health, logging).
- **Estymata:** 15m
- **Input:**
  - Stan repo po W09-T01–T03; ustalenia z D1.
- **Kroki:**
  1. Wybrać miejsce: `docs/architecture/` lub `docs/weekly/W09/` (np. `architecture-w09.md`).
  2. Opisać: lista projektów (orders-api, payments-api, catalog-api, order-worker), odpowiedzialność w jednym zdaniu każdy, struktura katalogów, konwencje (health, logging).
  3. Zachować prostotę — bez DDD/CQRS na tym etapie; „na tym etapie: prosta, pragmatyczna”.
- **Verification:** Ktoś wchodzący w repo może z dokumentu zrozumieć strukturę i cel projektów.
- **Evidence:** Ścieżka do dokumentu; ewentualnie wpis w `docs/lessons/W09-summary.md`.

---

## Verification (zbiorczy checklist z roadmapy)

- [ ] `dotnet build` OK
- [ ] `dotnet test` (jeśli są testy startowe) OK
- [ ] `/health` działa lokalnie dla API

---

## Evidence (zbiorczy z roadmapy)

- `docs/lessons/W09-summary.md` (opcjonalnie)
- output `dotnet build/test`
- opis lub screenshot lokalnego uruchomienia API/worker
