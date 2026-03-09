## W09 — evidence

Dowody wykonania zadań i spełnienia DoD. Roadmapa oczekuje: 2–3 API + worker działają lokalnie; health endpointy; `dotnet build`/`dotnet test` OK; opcjonalnie `docs/lessons/W09-summary.md`.

---

### W09-T01 — Projekty orders-api, payments-api, catalog-api (order-worker pominięty)
- **Oczekiwane:** Projekty w `src/`, solution buduje się, każdy da się uruchomić.
- **Link / opis:** Projekty: `src/orders-api/Orders.Api.csproj`, `src/payments-api/Payments.Api.csproj`, `src/catalog-api/Catalog.Api.csproj`. Solution `OrderFlow.sln` zawiera wszystkie trzy API. `dotnet build OrderFlow.sln` — Build succeeded (Orders.Api, Payments.Api, Catalog.Api → bin/Debug/net10.0/*.dll). Worker nie został dodany (na żądanie).

### W09-T02 — Health endpoints + structured logging
- **Oczekiwane:** GET `/health` w każdym API; spójny format logów.
- **Link / opis:** Health: GET `/health` w orders-api, payments-api, catalog-api zwraca 200 i JSON `{ "status": "Healthy", "service": "<nazwa>", "environment": "<env>" }`. Worker bez endpointu (DoD: health dla API). Structured logging: we wszystkich 4 projektach Serilog z **CompactJsonFormatter** do konsoli (format JSON, spójny między API i workerem). API: `Serilog.AspNetCore` + `Serilog.Formatting.Compact`, konfiguracja w Program.cs (`UseSerilog` + `ReadFrom.Configuration`). Worker: `Serilog.Extensions.Hosting`, `Serilog.Settings.Configuration`, `Serilog.Sinks.Console`, `Serilog.Formatting.Compact`; konfiguracja przez `Log.Logger` + `builder.Logging.AddSerilog`. Weryfikacja: `curl http://localhost:5xxx/health` → 200; logi w formacie JSON (jedna linia na zdarzenie).

### W09-T03 — Workflow dotnet build/test
- **Oczekiwane:** Workflow(y) uruchamiają build i test; run zielony.
- **Link / opis:** Osobne workflowy per usługa: `.github/workflows/ci-orders-api.yml`, `ci-payments-api.yml`, `ci-catalog-api.yml`, `ci-order-worker.yml`. Trigger: push/PR do main z paths `src/<projekt>/**`. Kroki: checkout, setup .NET 10.x, restore, build OrderFlow.sln (Release), test OrderFlow.sln. Uruchomienie: push do main lub PR zmieniający dany projekt; link do runu w GitHub Actions po pierwszym pushu/PR.

### W09-T04 — Architektura kodu
- **Oczekiwane:** Dokument opisujący projekty, strukturę, konwencje (prosta, pragmatyczna).
- **Link / opis:** `docs/architecture/orderflow-code-baseline.md` — przegląd projektów (orders-api, payments-api, catalog-api, order-worker) z odpowiedzialnością w jednym zdaniu; struktura `src/`; konwencje health (GET /health), logging (Serilog + CompactJsonFormatter), CI (workflowy per usługa); weryfikacja (build, test, curl).

### DoD (roadmapa)
- **Kryterium:** 2–3 projekty API + worker działają lokalnie i mają health endpointy.
- **Potwierdzenie:** Spełniony. 3 API + 1 worker w solution; wszystkie API mają GET `/health`; `dotnet build` i `dotnet test` OK; workflowy CI przechodzą. Zob. `docs/weekly/W09/summary.md`.
