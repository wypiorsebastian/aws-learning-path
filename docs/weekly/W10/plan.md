# W10 — plan tygodnia

## Cel tygodnia (z roadmapy)

Uzyskać **pierwszy działający endpoint .NET w AWS** — wdrożyć jedno API (catalog-api lub orders-api) do **App Runner** i zweryfikować publiczny `/health`.

## WhyNow

- Szybki feedback i wdrożenie bez złożoności ECS.
- Po W09 mamy działające lokalnie API z health endpointami — idealny punkt wejścia do hostingu.
- App Runner pozwala skupić się na mechanice deployu kontenera bez zarządzania klastrem.

## DoD (z roadmapy)

- **Działający endpoint** — publiczny URL z odpowiedzią na `/health`.
- **Zapisany troubleshooting deployu** — notatki o pułapkach (port, start command, health check, env vars) i sposobie ich obejścia.

## MVP tygodnia

Minimalne zaliczenie:

- **Dockerfile** dla wybranego API (catalog-api lub orders-api).
- Serwis wdrożony do **App Runner**.
- Publiczny endpoint **GET /health** zwracający 200.
- **Runbook** `docs/runbooks/apprunner-deploy.md` z krokiem deployu i typowymi pułapkami.

Stretch (opcjonalne):

- Moduł Terraform dla App Runner.
- Porównanie App Runner vs inne modele (notatka do W11).

## Pułapki (z roadmapy)

- **Port** — App Runner oczekuje określonego portu (domyślnie 8080).
- **Start command** — musi wskazywać na poprawny proces.
- **Health check** — ścieżka i konfiguracja muszą pasować do aplikacji.
- **Env vars** — przekazywanie zmiennych (np. environment) do aplikacji.

## Prereq

- W09 DONE — działające lokalnie API z `/health`, structured logging.
- Konto AWS (dev-only), lokalny AWS CLI skonfigurowany.

---

## Plan D1–D5 (po 1.5h każda sesja)

### D1 (1.5h) — Decyzje + Dockerfile (W10-T01)

**Cel:** Wybrać API do wdrożenia i przygotować Dockerfile (lub source-deploy config).

- [ ] Przeczytać sekcję W10 w roadmapie i wymagania App Runner (port, health check).
- [ ] Zdecydować: catalog-api czy orders-api (np. catalog-api — mniej endpointów, szybszy smoke test).
- [ ] Stworzyć Dockerfile w katalogu wybranego API:
  - multi-stage (build + runtime),
  - port eksponowany (np. 8080 dla App Runner),
  - `dotnet publish` + minimalny runtime image,
  - health endpoint dostępny na `/health`.
- [ ] Zweryfikować lokalnie: `docker build` + `docker run`; `curl localhost:8080/health`.
- **Input:** Projekty z W09, dokumentacja App Runner (source vs container).
- **Output:** `Dockerfile` w `src/catalog-api/` (lub `src/orders-api/`); lokalna weryfikacja kontenera.
- **Weryfikacja:** Kontener startuje; `/health` zwraca 200; port 8080 eksponowany.

---

### D2 (1.5h) — Deploy do App Runner (W10-T02)

**Cel:** Wdrożyć serwis do App Runner (ręcznie przez konsolę lub AWS CLI).

- [ ] W konsoli AWS: App Runner → Create service.
- [ ] Wybrać source: **ECR** (jeśli już masz obraz) lub **GitHub** (source deploy — jeśli wybrano tę ścieżkę). Alternatywnie: ECR z obrazem pushowanym z lokalnego builda.
- [ ] Skonfigurować:
  - port (np. 8080),
  - start command (jeśli potrzebny),
  - health check path: `/health`,
  - env vars (np. `ASPNETCORE_ENVIRONMENT=Development`).
- [ ] Po utworzeniu: poczekać na status Running; skopiować URL serwisu.
- [ ] Zweryfikować: `curl https://<service-url>/health`.
- **Input:** Dockerfile z D1; konto AWS; obraz w ECR (jeśli container deploy) lub repo GitHub (jeśli source).
- **Output:** Serwis App Runner w statusie Running; publiczny URL.
- **Weryfikacja:** Endpoint odpowiada; `/health` zwraca 200.

---

### D3 (1.5h) — Weryfikacja + troubleshooting (W10-T03)

**Cel:** Zweryfikować `/health`, logi, env vars; zidentyfikować pułapki i zapisać je.

- [ ] Przebiec checklistę: `/health` publicznie, logi w CloudWatch Logs, env vars widoczne w logach (jeśli są).
- [ ] Sprawdzić konfigurację health check w App Runner i porównać z rzeczywistą odpowiedzią aplikacji.
- [ ] Jeśli były błędy przy deployu: spisać objaw, hipotezę, fix, root cause.
- [ ] Zrobić redeploy po małej zmianie (np. wiadomość w health) — sprawdzić flow: build → push → update service.
- **Input:** Serwis App Runner z D2; CloudWatch Logs.
- **Output:** Potwierdzenie działania; notatki troubleshootingowe (objawy, fixy).
- **Weryfikacja:** Możesz zrobić redeploy po zmianie kodu; logi widoczne.

---

### D4 (1.5h) — Runbook + różnice hostingów (W10-T04)

**Cel:** Spisać runbook deployu i krótką notatkę porównawczą App Runner vs inne modele.

- [ ] Utworzyć `docs/runbooks/apprunner-deploy.md`:
  - cel (deploy API .NET do App Runner),
  - prereq (Dockerfile, ECR/container lub GitHub/source),
  - kroki: build image, push do ECR (lub trigger source), utworzenie/aktualizacja serwisu,
  - pułapki: port, start command, health check path, env vars,
  - weryfikacja (`/health`, logi).
- [ ] Opcjonalnie: krótka notatka — „App Runner vs ECS/Beanstalk” (na potrzeby W11).
- [ ] Uzupełnić `docs/weekly/W10/evidence.md`.
- **Input:** Doświadczenie z D1–D3; runbook z poprzednich tygodni (format).
- **Output:** `docs/runbooks/apprunner-deploy.md`; evidence uzupełnione.
- **Weryfikacja:** Ktoś inny mógłby wykonać deploy na podstawie runbooka.

---

### D5 (1.5h) — Domknięcie tygodnia + DoD

**Cel:** Zweryfikować DoD, uzupełnić evidence, zapisać summary.

- [ ] Przebiec DoD: działający endpoint; zapisany troubleshooting deployu.
- [ ] Uzupełnić `docs/weekly/W10/summary.md` (co zrobiono, pułapki, lessons learned).
- [ ] Opcjonalnie: `docs/lessons/W10-summary.md` — skrót lekcji (co daje App Runner, kiedy używać).
- [ ] Cleanup: jeśli dev-only — rozważyć zatrzymanie/usunięcie serwisu po sesji (koszt runtime).
- **Input:** Stan repo po D1–D4; checklista DoD.
- **Output:** DoD potwierdzony; summary uzupełniony; gotowość do W11.
- **Weryfikacja:** DoD spełniony; W11 ma jasny punkt wejścia (drugi hosting — Beanstalk).
