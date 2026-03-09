## W09 — podsumowanie tygodnia

Podsumowanie wypełniane na końcu tygodnia lub przy domykaniu (`/week-finish`). Skrót: co zrobiono, kluczowe decyzje, pułapki, następny krok.

---

- **Cel tygodnia (z roadmapy):** Zbudować lokalny baseline aplikacyjny OrderFlow w .NET 10 (APIs, worker, health, logging) oraz podstawowy CI dla .NET.
- **DoD:** **Spełniony**
- **Status:** **DONE**

### Co osiągnięto

- **W09-T01:** Trzy API (orders, payments, catalog) + worker w `src/`, target net10.0; `dotnet build OrderFlow.sln` OK; każdy projekt uruchamialny lokalnie.
- **W09-T02:** GET `/health` w każdym API (200, JSON z status/service/environment); Serilog z CompactJsonFormatter we wszystkich 4 projektach; logi w formacie JSON (jedna linia na zdarzenie).
- **W09-T03:** Cztery workflowy CI per usługa (ci-orders-api, ci-payments-api, ci-catalog-api, ci-order-worker); trigger na `paths: src/<projekt>/**`; restore + build solution, test **tylko odpowiadającego projektu testowego**.
- **W09-T04:** Dokument architektury `docs/architecture/orderflow-code-baseline.md` — lista projektów, odpowiedzialność, struktura, konwencje (health, logging, CI).
- **Dodatkowo:** Projekty testowe (xUnit) dla każdego projektu głównego; smoke testy; workflowy testują per projekt zamiast całej solution.

### Co nie dowiezione / luki

- `docs/lessons/W09-summary.md` — opcjonalne, nie utworzono (stretch).
- Brak eksplicytnego screenshotu/linku do udanego runu GitHub Actions (evidence opisuje konfigurację; run weryfikowalny przez push/PR).

### Root cause problemów / opóźnień

Brak.

### Lessons learned

- Workflowy per usługa zamiast jednego „dotnet-ci” — spójne z modelem mikroserwisów i przyszłymi niezależnymi wdrożeniami; `dotnet test` per projekt przyspiesza CI.
- Serilog CompactJsonFormatter — spójny format JSON dla API i workera; konfiguracja przez `appsettings.json`.
- Dokument architektury w `docs/architecture/` — trwałe miejsce; baseline bez overengineeringu ułatwia onboarding.

### Next actions

- **W10:** App Runner — przygotować Dockerfile i wdrożyć catalog-api lub orders-api na AWS App Runner; `runbooks/apprunner-deploy.md`.
- Weryfikacja: `curl https://<endpoint>/health` publicznie dostępny.

### Portfolio bullets (1–3)

1. Lokalny baseline .NET 10: trzy API + worker z health endpoints i structured logging (Serilog JSON); `dotnet build/test` OK.
2. CI per usługa: cztery workflowy GitHub Actions (trigger na paths), build solution + test tylko zmienionego projektu.
3. Dokumentacja architektury kodu (`docs/architecture/orderflow-code-baseline.md`) — projekty, konwencje, weryfikacja.
