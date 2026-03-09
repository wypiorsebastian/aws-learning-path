# Architektura kodu — OrderFlow (baseline W09)

**Wersja:** 1.0  
**Zakres:** Stan po W09 — lokalny baseline aplikacyjny, prosta struktura bez overengineeringu.

---

## 1. Przegląd

OrderFlow to projekt kursowy (learning-by-building): system e-commerce (orders + payments + catalog) budowany jako nośnik nauki AWS. Na etapie W09 mamy minimalny zestaw projektów .NET 10: trzy API, jeden worker i testy jednostkowe.

**Zasada:** Na tym etapie — prosta, pragmatyczna architektura. Bez DDD, CQRS ani event sourcingu.

---

## 2. Projekty

| Projekt | Typ | Odpowiedzialność (jedno zdanie) |
|---------|-----|---------------------------------|
| **orders-api** | Web API | Tworzenie i obsługa zamówień; minimalnie: GET `/api/orders`. |
| **payments-api** | Web API | Inicjacja i callback płatności; minimalnie: endpointy płatności. |
| **catalog-api** | Web API | Katalog produktów; minimalnie: GET `/api/catalog`. |
| **order-worker** | Worker (BackgroundService) | Asynchroniczne przetwarzanie zamówień; na razie: Hosted Service z prostym timerem/logiem. |

### Projekty testowe

| Projekt | Odpowiedzialność |
|---------|------------------|
| **Orders.Api.Tests** | Testy jednostkowe orders-api. |
| **Payments.Api.Tests** | Testy jednostkowe payments-api. |
| **Catalog.Api.Tests** | Testy jednostkowe catalog-api. |
| **OrderWorker.Tests** | Testy jednostkowe order-worker. |

---

## 3. Struktura katalogów

```
src/
├── orders-api/
│   ├── Orders.Api/           # projekt API
│   └── Orders.Api.Tests/     # projekt testów
├── payments-api/
│   ├── Payments.Api/
│   └── Payments.Api.Tests/
├── catalog-api/
│   ├── Catalog.Api/
│   └── Catalog.Api.Tests/
└── order-worker/
    ├── OrderWorker/
    └── OrderWorker.Tests/
```

- **Solution:** `OrderFlow.sln` w katalogu głównym repo — buduje wszystkie projekty.
- **Shared:** Brak projektu `shared` na tym etapie; kontrakty/współdzielone typy pojawią się w kolejnych tygodniach.
- **Target framework:** .NET 10 (`net10.0`).

---

## 4. Konwencje

### Health

- Każde API ma endpoint **GET `/health`** zwracający 200 i JSON: `{ "status": "Healthy", "service": "<nazwa>", "environment": "<env>" }`.
- Worker nie ma health endpointu (DoD tygodnia wymaga health dla API).

### Logging

- **Structured logging:** Serilog z `CompactJsonFormatter` do konsoli — jedna linia JSON na zdarzenie.
- **API:** `Serilog.AspNetCore` + `UseSerilog` w `Program.cs`; konfiguracja z `ReadFrom.Configuration`.
- **Worker:** `Serilog.Extensions.Hosting`, `Log.Logger` + `AddSerilog`; ten sam format JSON.
- Konfiguracja przez `appsettings.json` (np. `Serilog:MinimumLevel`).

### CI/CD

- Osobne workflowy per usługa: `ci-orders-api`, `ci-payments-api`, `ci-catalog-api`, `ci-order-worker`.
- Trigger: `paths: src/<projekt>/**` na push/PR do `master`.
- Kroki: restore, build całej solution, test **tylko odpowiadającego projektu testowego**.

---

## 5. Weryfikacja

- `dotnet build OrderFlow.sln` — buduje całą solution.
- `dotnet test OrderFlow.sln` — uruchamia wszystkie projekty testowe.
- `curl http://localhost:<port>/health` — sprawdza health każdego API.
- Lokalne uruchomienie: `dotnet run --project src/<projekt>/<Projekt>.csproj`.

---

## 6. Następne kroki (kontekst roadmapy)

W W10+ planowane m.in.: wdrożenie do AWS (App Runner, ECS, Lambda), integracje (SQS, SNS), IaC w Terraform, rozszerzenie CI/CD o deployment.
