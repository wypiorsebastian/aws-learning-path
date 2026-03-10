## W11 — taski tygodnia

### Kontekst

- **WeekId:** `W11`
- **Cel tygodnia:** Poznać i porównać kolejny model hostingu .NET w AWS — Elastic Beanstalk jako PaaS.
- **Outcome:** Drugi serwis działa w Elastic Beanstalk; umiesz wdrożyć i porównać App Runner vs Beanstalk; runbook deployu i diagnostyki.
- **Uwaga:** Zgodnie z zasadami projektu — kod generowany tylko na wyraźną prośbę; ten plik definiuje zakres i kroki.

---

## Taski bazowe z roadmapy

### W11-T01 — Spisz model odpowiedzialności w Beanstalk

- **TaskId:** `W11-T01`
- **Status:** `DONE`
- **Priorytet:** `P1`
- **Typ:** `Theory`
- **Cel:** Spisać model odpowiedzialności w Elastic Beanstalk (co robi AWS, co developer) i krótko porównać do App Runner.
- **Estymata:** 30m
- **Input:**
  - Dokumentacja AWS Elastic Beanstalk (.NET on Linux); doświadczenie z W10 (App Runner).
- **Kroki:**
  1. Przeczytać/przypomnieć sobie: Application, Environment, platforma .NET on Linux, kto zarządza runtime, LB, skalowaniem.
  2. Spisać: co zarządza Beanstalk (infra, platform version, load balancer, auto-scaling, patching), co robi developer (kod, package, env vars, health endpoint).
  3. Krótkie porównanie z App Runner: podobieństwa i różnice (kontrola vs prostota, format deployu, gdzie logi).
  4. Zapisać notatkę w repo (np. `docs/lessons/` lub sekcja w `summary.md`).
- **Verification:** Notatka istnieje; potrafisz w 2 zdaniach powiedzieć „Beanstalk robi X, ja robię Y”; wiesz, jaki artifact (zip/container) jest potrzebny do deployu.
- **Evidence:** Ścieżka do notatki (docs/lessons lub W11/summary.md).

---

### W11-T02 — Wdróż payments-api lub catalog-api do Beanstalk

- **TaskId:** `W11-T02`
- **Status:** `TODO`
- **Priorytet:** `P1`
- **Typ:** `Deploy`
- **Cel:** Wdrożyć wybrane API do Elastic Beanstalk (.NET on Linux) i uzyskać działające środowisko z endpointem /health.
- **Estymata:** 60m
- **Input:**
  - Wybrane API z W09/W10 (catalog-api, orders-api lub payments-api) z `/health`.
  - Wymagania Beanstalk z T01: format package (publish zip lub container), platform version, port.
- **Kroki:**
  1. Przygotować deploy package: `dotnet publish` i spakować do zip (lub zbudować obraz i użyć platformy kontenerowej Beanstalk — według wybranej opcji).
  2. W konsoli AWS (lub CLI): utworzyć Elastic Beanstalk Application (jeśli brak).
  3. Utworzyć Environment: platforma .NET on Linux, wybrana wersja runtime (.NET 6/8).
  4. Wgrać package / skonfigurować source; ustawić zmienne środowiskowe (np. ASPNETCORE_ENVIRONMENT).
  5. Poczekać na zielony status środowiska; skopiować URL.
  6. Zweryfikować: `curl <env-url>/health` → 200.
- **Verification:** Environment w statusie Ready/Green; publiczny URL zwraca 200 na `/health`.
- **Evidence:** URL środowiska; screenshot/opis statusu; output `curl`.

---

### W11-T03 — Sprawdź health, logi, typowe błędy startu

- **TaskId:** `W11-T03`
- **Status:** `TODO`
- **Priorytet:** `P1`
- **Typ:** `Troubleshooting`
- **Cel:** Wiedzieć, gdzie szukać logów i health w Beanstalk; przejść przez typowe błędy startu i zapisać pułapki.
- **Estymata:** 30m
- **Input:**
  - Działające środowisko z W11-T02; konsola Beanstalk, CloudWatch (jeśli używane).
- **Kroki:**
  1. Wskazać w konsoli Beanstalk: gdzie jest health środowiska, gdzie health aplikacji (jeśli różne).
  2. Znaleźć logi aplikacji i platformy (Environment → Logs, Request logs, CloudWatch log group — według konfiguracji).
  3. Opcjonalnie: wywołać typowy błąd (np. zła env var, zły port) i zobaczyć objaw w logach/health.
  4. Spisać 2–3 pułapki (package format, platform version, env vars, health) do runbooka lub notatki.
- **Verification:** Umiesz wskazać gdzie szukać logów; znasz co najmniej 2 typowe pułapki i ich objawy.
- **Evidence:** Krótka notatka lub sekcja w runbooku (gdzie logi, typowe błędy).

---

### W11-T04 — Runbook deployu i diagnostyki Beanstalk

- **TaskId:** `W11-T04`
- **Status:** `TODO`
- **Priorytet:** `P2`
- **Typ:** `Docs`
- **Cel:** Utworzyć runbook `docs/runbooks/elastic-beanstalk-deploy.md` z krokami deployu i diagnostyki.
- **Estymata:** 30m
- **Input:**
  - Doświadczenie z T02 (deploy) i T03 (logi, health, pułapki).
- **Kroki:**
  1. Sekcja: Przeznaczenie, wymagania (platform .NET on Linux, format package, port).
  2. Sekcja: Kroki deployu (krok po kroku — create app/env, upload package, env vars).
  3. Sekcja: Gdzie szukać logów i jak odczytać health.
  4. Sekcja: Troubleshooting — typowe błędy (package format, platform version, env vars, health status), objaw → diagnoza → fix.
  5. Zgodnie z konwencją projektu: Przeznaczenie, Kluczowe fakty, Operacyjny flow, Pułapki.
- **Verification:** Runbook pozwala powtórzyć deploy i podstawową diagnostykę bez zaglądania do innych źródeł.
- **Evidence:** `docs/runbooks/elastic-beanstalk-deploy.md`.
