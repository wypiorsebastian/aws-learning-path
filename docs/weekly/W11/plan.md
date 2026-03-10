# W11 — plan tygodnia

## Cel tygodnia (z roadmapy)

Poznać i **porównać kolejny model hostingu .NET w AWS** — Elastic Beanstalk jako PaaS. Drugi serwis (po App Runner z W10) ma działać w Beanstalk; efekt: praktyczne porównanie hostingów pod rozmowy techniczne.

## WhyNow

- Budujesz praktyczne porównanie hostingów (App Runner vs Beanstalk) — przydatne w rozmowach rekrutacyjnych i przy wyborze stacku.
- W10 dał pierwszy działający endpoint w App Runner; Beanstalk to inny model (PaaS z większą kontrolą nad platformą).
- DoD W11: umiesz wdrożyć i **porównać** App Runner vs Beanstalk.

## DoD (z roadmapy)

- **Umiesz wdrożyć i porównać App Runner vs Beanstalk.**
- Aplikacja działa w Elastic Beanstalk.
- Wiesz, gdzie szukać logów i health.
- Masz notatkę porównawczą hostingów.

## MVP tygodnia

Minimalne zaliczenie:

- **Model odpowiedzialności** Beanstalk spisany (W11-T01).
- **payments-api lub catalog-api** wdrożone do Elastic Beanstalk (.NET on Linux) (W11-T02).
- **Health i logi** zweryfikowane; typowe błędy startu sprawdzone (W11-T03).
- **Runbook** `docs/runbooks/elastic-beanstalk-deploy.md` z deployem i diagnostyką (W11-T04).

Stretch (opcjonalne):

- Moduł Terraform dla Beanstalk (environment + application).
- Notatka porównawcza w `docs/lessons/` (App Runner vs Beanstalk vs przyszły ECS).

## Pułapki (z roadmapy)

- **Package format** — Beanstalk .NET on Linux: publish package (zip) lub platforma kontenerowa w zależności od wersji.
- **Platform version** — wybór .NET runtime (np. .NET 6/8) i wersji platformy Beanstalk.
- **Env vars** — konfiguracja zmiennych środowiskowych w environment.
- **Health status** — gdzie sprawdzać health środowiska i aplikacji; różnica między environment health a aplikacją.
- **Koszt/Cleanup** — Beanstalk utrzymuje zasoby (EC2/load balancer itd.) — trzeba sprzątać po nauce.

## Prereq

- W10 (najlepiej z działającym App Runner) — masz już jedno API w chmurze i runbook.
- Działające API (catalog-api, orders-api lub payments-api) z `/health`.

---

## Plan D1–D5 (po 1.5h każda sesja)

### D1 (1.5h) — Model odpowiedzialności + przygotowanie do deployu (W11-T01)

**Cel:** Zrozumieć, za co odpowiada Beanstalk, a za co ty; przygotować wybór API i wymagania platformy.

- [ ] Przeczytać sekcję W11 w roadmapie i zakres Beanstalk (.NET on Linux).
- [ ] **W11-T01:** Spisać model odpowiedzialności w Beanstalk:
  - Co zarządza AWS (platforma, runtime, load balancer, skalowanie, patching)?
  - Co robi developer (kod, konfiguracja env, health endpoint, package format)?
  - Krótkie porównanie do App Runner (kto co robi).
- [ ] Zdecydować, które API wdrażać: payments-api lub catalog-api (spójne z W10 lub drugie dla porównania).
- [ ] Sprawdzić wymagania Beanstalk dla .NET on Linux: format deployu (zip vs container), port, platform version.
- **Output:** Notatka modelu odpowiedzialności; wybór API; lista kroków na T02.
- **Verification:** Notatka w repo (np. w `docs/lessons/` lub w `summary.md`); wiesz, jaki artifact będziesz wgrywać.

---

### D2 (1.5h) — Deploy do Beanstalk (W11-T02)

**Cel:** Wdrożyć wybrane API do Elastic Beanstalk i uzyskać działające środowisko.

- [ ] **W11-T02:** Wdróż payments-api lub catalog-api do Beanstalk:
  - Przygotować package (np. `dotnet publish` + zip) lub użyć kontenera, w zależności od wybranej platformy.
  - Utworzyć Application + Environment w Beanstalk (.NET on Linux).
  - Skonfigurować port (np. 5000/8080 według platformy), env vars (ASPNETCORE_ENVIRONMENT itd.).
  - Poczekać na zielony status środowiska.
- [ ] Pierwsza weryfikacja: wejść na URL środowiska, sprawdzić `/health`.
- **Output:** Działający URL środowiska Beanstalk; status environment (Green/Yellow/Red).
- **Verification:** GET na `<env-url>/health` zwraca 200; w konsoli widać health środowiska.

---

### D3 (1.5h) — Health, logi, troubleshooting (W11-T03)

**Cel:** Upewnić się, że wiesz, gdzie szukać logów i jak diagnozować typowe błędy.

- [ ] **W11-T03:** Sprawdź health, logi, typowe błędy startu:
  - Gdzie w konsoli Beanstalk (lub CloudWatch) są logi aplikacji i platformy?
  - Jak odczytać health środowiska vs health aplikacji?
  - Symulacja błędu (np. zła env var, zły port) — jak to wygląda w logach / health?
  - Zapisanie 2–3 typowych pułapek do runbooka.
- [ ] Rozpocząć **W11-T04:** szkic runbooka (nagłówki sekcji: deploy, health, logi, typowe błędy).
- **Output:** Notatki gdzie szukać logów; lista pułapek; wstęp runbooka.
- **Verification:** Potrafisz wskazać w konsoli log group / strumień; wiesz, jak zrestartować environment.

---

### D4 (1.5h) — Runbook + evidence (W11-T04)

**Cel:** Dokończyć runbook i zebrać evidence zgodne z DoD.

- [ ] **W11-T04:** Dokończyć runbook `docs/runbooks/elastic-beanstalk-deploy.md`:
  - Przeznaczenie, wymagania (platform version, package format).
  - Kroki deployu (krok po kroku).
  - Gdzie szukać logów i health.
  - Sekcja troubleshooting (typowe błędy: package format, platform version, env vars, health).
- [ ] Uzupełnić `docs/weekly/W11/evidence.md`: endpoint, health status, link do runbooka.
- [ ] Opcjonalnie: krótka notatka porównawcza App Runner vs Beanstalk (odpowiedzialności, kiedy który wybrać).
- **Output:** Gotowy runbook; evidence uzupełnione.
- **Verification:** Runbook pozwala powtórzyć deploy i diagnostykę; evidence zawiera wymagane elementy.

---

### D5 (1.5h) — Podsumowanie i DoD

**Cel:** Domknąć tydzień: summary, lekcje, przegląd DoD.

- [ ] Napisać `docs/lessons/W11-summary.md`: co zrobiłeś, co wynosisz (model Beanstalk, porównanie z App Runner), pułapki.
- [ ] Uzupełnić `docs/weekly/W11/summary.md`: status tasków, co zaliczone, co stretch, uwagi.
- [ ] Przejrzeć DoD: „Umiesz wdrożyć i porównać App Runner vs Beanstalk” — checklist (aplikacja działa, runbook, notatka porównawcza).
- [ ] W `log.md` dopisać ostatnie wpisy z sesji.
- **Output:** W11-summary.md, summary.md, czysty DoD.
- **Verification:** Evidence w repo; runbook i summary dostępne; możesz w 2 minuty opowiedzieć różnicę App Runner vs Beanstalk.
