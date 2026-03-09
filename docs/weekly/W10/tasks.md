## W10 — taski tygodnia

### Kontekst

- **WeekId:** `W10`
- **Cel tygodnia:** Uzyskać pierwszy działający endpoint .NET w AWS — wdrożyć catalog-api lub orders-api do App Runner.
- **Outcome:** Publiczny `/health` z API działającego w App Runner; runbook deployu; zapisany troubleshooting.
- **Uwaga:** Zgodnie z zasadami projektu — kod generowany tylko na wyraźną prośbę; ten plik definiuje zakres i kroki.

---

## Taski bazowe z roadmapy

### W10-T01 — Przygotuj Dockerfile dla wybranego API

- **TaskId:** `W10-T01`
- **Status:** `DONE`
- **Priorytet:** `P1`
- **Typ:** `Coding`
- **Cel:** Dodać Dockerfile (lub source deploy config) dla catalog-api lub orders-api — multi-stage, port 8080, health endpoint dostępny.
- **Estymata:** 45m
- **Input:**
  - Projekty z W09 (catalog-api, orders-api); każdy ma `/health`.
  - Wymagania App Runner: port (np. 8080), health check path `/health`.
- **Kroki:**
  1. Wybrać API (np. catalog-api — mniej endpointów).
  2. Dodać `Dockerfile` w katalogu projektu: multi-stage (build + runtime), `dotnet publish`, ekspozycja portu 8080.
  3. Zweryfikować lokalnie: `docker build`, `docker run`; `curl localhost:8080/health`.
  4. Upewnić się, że start command jest poprawny (np. `dotnet Catalog.Api.dll`).
- **Verification:** Kontener startuje; GET `/health` zwraca 200 na porcie 8080.
- **Evidence:** Ścieżka do Dockerfile; output `docker run`; wynik `curl .../health`.

---

### W10-T02 — Wdróż serwis do App Runner

- **TaskId:** `W10-T02`
- **Status:** `TODO`
- **Priorytet:** `P1`
- **Typ:** `Deploy`
- **Cel:** Wdrożyć serwis App Runner na podstawie kontenera (ECR) lub source (GitHub); skonfigurować port, health check, env vars.
- **Estymata:** 45m
- **Input:**
  - Dockerfile z W10-T01; obraz w ECR (lub repo GitHub dla source deploy).
  - Konto AWS; AWS CLI / konsola.
- **Kroki:**
  1. Zbudować obraz i pushować do ECR (jeśli container deploy); alternatywnie — skonfigurować source deploy z GitHub.
  2. App Runner → Create service; wybrać source (ECR / GitHub).
  3. Skonfigurować: port 8080, health check path `/health`, env vars (np. ASPNETCORE_ENVIRONMENT).
  4. Poczekać na status Running; skopiować URL serwisu.
  5. Zweryfikować: `curl https://<service-url>/health`.
- **Verification:** Serwis w statusie Running; publiczny URL odpowiada na `/health` z 200.
- **Evidence:** URL serwisu; output `curl`; screenshot/opis statusu w konsoli.

---

### W10-T03 — Zweryfikuj /health, logi, env vars

- **TaskId:** `W10-T03`
- **Status:** `TODO`
- **Priorytet:** `P1`
- **Typ:** `Verification` / `Troubleshooting`
- **Cel:** Potwierdzić działanie endpointu; sprawdzić logi w CloudWatch; zweryfikować przekazywanie env vars; zidentyfikować i zapisać pułapki.
- **Estymata:** 30m
- **Input:**
  - Serwis App Runner z W10-T02; CloudWatch Logs.
- **Kroki:**
  1. Sprawdzić `/health` publicznie.
  2. Otworzyć logi w CloudWatch (log group App Runner).
  3. Sprawdzić, czy env vars są widoczne w aplikacji (np. w response health).
  4. Zrobić redeploy po małej zmianie — flow: build → push → update service.
  5. Jeśli były problemy: spisać objaw, hipotezę, fix (do runbooka).
- **Verification:** Endpoint działa; logi widoczne; redeploy możliwy; pułapki udokumentowane.
- **Evidence:** Opis weryfikacji; notatki troubleshootingowe (jeśli były błędy).

---

### W10-T04 — Runbook + różnice App Runner vs inne modele

- **TaskId:** `W10-T04`
- **Status:** `TODO`
- **Priorytet:** `P2`
- **Typ:** `Docs`
- **Cel:** Utworzyć `docs/runbooks/apprunner-deploy.md` z krokami deployu i pułapkami; opcjonalnie — krótką notatkę porównawczą hostingów.
- **Estymata:** 30m
- **Input:**
  - Doświadczenie z W10-T01–T03; format runbooków z projektu.
- **Kroki:**
  1. Utworzyć `docs/runbooks/apprunner-deploy.md`: cel, prereq, kroki (build → push → create/update service), pułapki (port, start command, health check, env vars), weryfikacja.
  2. Opcjonalnie: notatka „App Runner vs ECS/Beanstalk” (na potrzeby W11).
- **Verification:** Runbook pozwala odtworzyć deploy; pułapki opisane.
- **Evidence:** Ścieżka do runbooka; ewentualnie `docs/lessons/W10-summary.md`.

---

## Verification (zbiorczy checklist z roadmapy)

- [ ] Endpoint `/health` odpowiada
- [ ] Logi aplikacji widoczne
- [ ] Możesz zrobić redeploy po zmianie kodu

---

## Evidence (zbiorczy z roadmapy)

- `docs/lessons/W10-summary.md` (opcjonalnie)
- `docs/runbooks/apprunner-deploy.md`
