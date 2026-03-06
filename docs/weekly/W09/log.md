## W09 — log tygodnia

Log wpisów chronologicznie; każdy wpis z datą/czasem i powiązanym TaskId.

---

- **2025-03-06** — W09-T01: Wygenerowano payments-api i catalog-api (wzorzec jak orders-api: net10.0, minimalne GET `/` i `/api/...` zwracające 200). Oba projekty dodane do OrderFlow.sln. Później dodany order-worker. `dotnet build OrderFlow.sln` OK.
- **2025-03-06** — W09-T02: Health był już w trzech API (GET `/health` → 200, status/service/environment). Dodany structured logging: Serilog z CompactJsonFormatter we wszystkich 4 projektach (API: Serilog.AspNetCore + UseSerilog; worker: Log.Logger + AddSerilog). Build OK.
- **2025-03-06** — W09-T03: Dodane 4 workflowy CI per usługa (ci-orders-api, ci-payments-api, ci-catalog-api, ci-order-worker). Trigger na paths `src/<projekt>/**`; każdy wykonuje restore, build i test całej solution (Release). Zgodne z modelem mikroserwisów i przyszłymi niezależnymi wdrożeniami.
