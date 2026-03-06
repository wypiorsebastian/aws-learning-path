# W09 — plan tygodnia

## Cel tygodnia (z roadmapy)

Zbudować **lokalny baseline aplikacyjny** pod dalsze deploymenty: szkielet systemu OrderFlow w .NET 10 (APIs, worker, shared contracts, health endpoints, logging baseline) oraz podstawowy CI dla .NET.

## WhyNow

- Od teraz zaczyna się właściwy kod i integracja z AWS (W10+).
- Potrzebny jest działający lokalnie zestaw serwisów, żeby w kolejnych tygodniach wdrażać je do App Runner, Beanstalk, ECS itd.
- Bez baseline’u nie ma sensu budować pipeline’ów deploy.

## DoD (z roadmapy)

- **2–3 projekty API + worker** działają lokalnie.
- Wszystkie mają **health endpointy**.
- **Evidence:** `dotnet build` OK, `dotnet test` OK (jeśli są testy startowe), `/health` działa lokalnie dla API.

## MVP tygodnia

Minimalne zaliczenie:

- **orders-api**, **payments-api**, **catalog-api** (min. 2 z 3 API) + **order-worker** — projekty w `src/`, budują się i uruchamiają lokalnie.
- Endpoint **GET /health** (lub równoważny) w każdym API, zwracający status (np. Healthy/Unhealthy).
- **Structured logging baseline** (np. jedna wspólna konfiguracja lub wzorzec) w aplikacjach.
- Workflow **`.github/workflows/dotnet-ci.yml`**: `dotnet build` i `dotnet test` na PR/push (np. do `main`).

Stretch (opcjonalne):

- Trzeci API jeśli czas pozwoli; testy jednostkowe startowe; krótki dokument architektury kodu (`W09-T04`).

## Pułapki (z roadmapy)

- **Overengineering:** unikać DDD/CQRS/event sourcing na tym etapie — prosta, pragmatyczna struktura.

---

## Plan D1–D5 (po 1.5h każda sesja)

### D1 (1.5h) — Struktura repo i lista projektów (przed kodem)

**Cel:** Ustalić strukturę katalogów `src/`, wersję .NET (10), nazwy i odpowiedzialności projektów, bez pisania kodu.

- [ ] Przeczytać sekcję W09 w roadmapie i wymagania DoD.
- [ ] Zdecydować strukturę: np. `src/OrdersApi/`, `src/PaymentsApi/`, `src/CatalogApi/`, `src/OrderWorker/`, ewentualnie `src/shared/` na kontrakty.
- [ ] Ustalić typ projektów: Web API (minimal APIs lub kontrolery), Worker (Hosted Service / BackgroundService).
- [ ] Spisać w `docs/weekly/W09/questions.md` ewentualne wątpliwości (np. wspólna solution vs osobne, target framework).
- **Input:** Roadmapa W09, konwencje .NET w projekcie.
- **Output:** Krótka notatka: lista projektów, ścieżki, target framework (.NET 10).
- **Weryfikacja:** Jasna decyzja „co gdzie leży”; gotowość do W09-T01.

---

### D2 (1.5h) — Utworzenie projektów API i worker (W09-T01)

**Cel:** Dodać do repo projekty `orders-api`, `payments-api`, `catalog-api`, `order-worker` — minimalnie działające (build + run).

- [ ] Utworzyć solution (jeśli jeszcze nie ma) i projekty wg ustaleń z D1.
- [ ] Ustawić target framework .NET 10 (lub 8/9 jeśli 10 niedostępny w środowisku).
- [ ] Minimalna konfiguracja każdego API: endpoint (np. GET `/` lub `/api/orders`) zwracający 200; worker: pusty Hosted Service lub timer.
- [ ] `dotnet build` przechodzi dla całej solution; każdy projekt da się uruchomić lokalnie (`dotnet run`).
- **Input:** Wyniki D1, środowisko .NET lokalnie.
- **Output:** Katalogi `src/*` z projektami; solution buduje się i uruchamia.
- **Weryfikacja:** `dotnet build` OK; `dotnet run --project src/OrdersApi` (i pozostałe) startuje bez crashy.

---

### D3 (1.5h) — Health endpoints + structured logging (W09-T02)

**Cel:** Dodać endpoint `/health` w każdym API oraz wspólny baseline logowania (structured).

- [ ] W każdym API dodać mapowanie GET `/health` (ASP.NET Core Health Checks lub minimalny endpoint zwracający status).
- [ ] Skonfigurować structured logging (np. `Microsoft.Extensions.Logging` + console z formatem JSON lub czytelnym tekstem; ewentualnie Serilog jako wspólny wzorzec).
- [ ] W workerze: health może być opcjonalny (np. sam worker się nie eksponuje; notatka w docs) lub prosty „running” flag — zgodnie z DoD „2–3 API + worker”; DoD wymaga health dla API.
- [ ] Zweryfikować lokalnie: `curl localhost:5xxx/health` dla każdego API.
- **Input:** Projekty z D2, dokumentacja ASP.NET Core Health Checks.
- **Output:** Wszystkie API mają `/health`; logging spójny między projektami.
- **Weryfikacja:** `/health` zwraca 200 i status (np. Healthy); logi w jednym, czytelnym formacie.

---

### D4 (1.5h) — Workflow `dotnet build/test` (W09-T03)

**Cel:** Workflow GitHub Actions uruchamiający `dotnet build` i `dotnet test` na zmianach w kodzie.

- [ ] Utworzyć `.github/workflows/dotnet-ci.yml`.
- [ ] Trigger: np. `push` do `main`, `pull_request` do `main`, ścieżki np. `src/**`, `*.sln`.
- [ ] Kroki: checkout, setup .NET (wersja zgodna z projektami), restore, build, test (jeśli są testy).
- [ ] Upewnić się, że workflow przechodzi na aktualnym stanie repo (nawet przy zerowej liczbie testów).
- **Input:** Repo z `src/`, solution, ustalona wersja .NET.
- **Output:** Plik workflowu; udany run w Actions.
- **Weryfikacja:** Dla PR lub push workflow się uruchamia i `dotnet build` (oraz `dotnet test`) kończy się sukcesem.

---

### D5 (1.5h) — Architektura kodu + weryfikacja DoD (W09-T04)

**Cel:** Zapisać krótką architekturę kodu (pragmatyczną) i zweryfikować DoD tygodnia.

- [ ] W `docs/` (np. `docs/architecture/` lub `docs/weekly/W09/`) zapisać dokument: jakie projekty są, co robią (jednozdaniowo), jak są zorganizowane (solution, shared?), konwencje (health, logging). Bez overengineeringu — „na tym etapie: prosta, pragmatyczna”.
- [ ] Przebiec checklistę DoD: 2–3 API + worker działają lokalnie; health endpointy działają; `dotnet build` i `dotnet test` OK; CI workflow zielony.
- [ ] Uzupełnić `docs/weekly/W09/evidence.md` (output build/test, opis lokalnego uruchomienia).
- [ ] Opcjonalnie: `docs/lessons/W09-summary.md` — skrót lekcji (co zbudowano, czego unikać).
- **Input:** Stan repo po D2–D4, checklista DoD z roadmapy.
- **Output:** Dokument architektury; evidence uzupełnione; DoD potwierdzony.
- **Weryfikacja:** DoD spełniony; kolejny tydzień (W10) ma jasny punkt wejścia (działające API do wdrożenia).
