# W11 — Elastic Beanstalk: model odpowiedzialności i porównanie z App Runner

## Przeznaczenie

- Notatka z **W11-T01**: kto (AWS vs developer) za co odpowiada w Elastic Beanstalk oraz krótkie porównanie z App Runner.
- Służy do przygotowania deployu (T02) i do rozmów technicznych (kiedy Beanstalk, kiedy App Runner).

---

## Model odpowiedzialności w Elastic Beanstalk

### Co zarządza AWS (Beanstalk)

| Obszar | Odpowiedzialność AWS |
|--------|----------------------|
| **Platforma** | Wybór platformy (np. .NET 6/8 on Linux), wersja runtime, aktualizacje platformy (platform version). |
| **Infrastruktura** | EC2 (instancje), AMI, sieć (VPC/subnet — jeśli nie podasz własnej), storage na instancji. |
| **Load balancer** | ALB/ELB w konfiguracji single-instance lub load-balanced; health check na poziomie LB. |
| **Auto-scaling** | Min/Max instances, scaling triggers (CPU, request count itd.) — konfigurowane przez ciebie, wykonywane przez Beanstalk. |
| **Patching** | Patching systemu operacyjnego i runtime’u platformy (w ramach wybranej platform version); ty wybierasz „when” przez aktualizację platformy. |
| **Wdrożenie** | Odbiera artifact (zip lub obraz), rozkłada na instancje, rolling/rolling with batch; zarządza wersjami aplikacji (application versions). |
| **Logi platformy** | Logi serwera (nginx/proxy), deployment, healthd; dostęp przez konsolę (Request logs, Full logs) lub CloudWatch (jeśli włączone). |

### Co robi developer

| Obszar | Odpowiedzialność developera |
|--------|-----------------------------|
| **Kod** | Aplikacja .NET (API), zależności, konfiguracja (appsettings, env). |
| **Package** | `dotnet publish` + spakowanie do **ZIP** (dla .NET on Linux); zawartość: DLL, deps.json, runtimeconfig.json, appsettings, ewentualnie Procfile / .ebextensions. |
| **Port / proces** | Aplikacja musi nasłuchiwać na porcie, który Beanstalk przekazuje (zmienna `PORT`); domyślnie reverse proxy (nginx) przekazuje ruch na ten port. |
| **Health endpoint** | Endpoint (np. `/health`) zrozumiały dla health checków Beanstalka; konfiguracja ścieżki w environment. |
| **Env vars** | Zmienne środowiskowe ustawiane w konfiguracji Environment (ASPNETCORE_ENVIRONMENT, connection strings itd.). |
| **Wersja .NET** | Wybór self-contained vs framework-dependent; zgodność z wybraną platform version (np. .NET 8). |

**W skrócie:** Beanstalk zarządza **runtime, serwerami, LB, skalowaniem i wdrożeniem**; ty dostarczasz **artifact (zip), konfigurację (env, health path) i kod**.

---

## Artifact do deployu (.NET on Linux)

- **Standard:** plik **ZIP** z outputem `dotnet publish` (DLL, deps.json, runtimeconfig.json, appsettings, ewent. web.config).
- **Opcje aplikacji:** framework-dependent (runtime na platformie Beanstalk) lub self-contained (runtime w zipie).
- **Opcjonalnie:** Docker jako platforma Beanstalk — wtedy artifact to obraz w ECR; dla „.NET on Linux” typowy path to ZIP.
- **Weryfikacja:** Po T01 wiesz, że do T02 przygotowujesz `dotnet publish -c Release` i pakujesz wynik do zip (bez zbędnych plików źródłowych).

---

## Porównanie: App Runner vs Elastic Beanstalk

| Aspekt | App Runner | Elastic Beanstalk |
|--------|------------|-------------------|
| **Model** | Serwerless container / source; „podaj obraz lub repo, reszta u nas”. | PaaS: Application + Environment(s); ty podajesz artifact (zip lub obraz), Beanstalk kręci EC2 + LB + deploy. |
| **Odpowiedzialność AWS** | Runtime, skalowanie (do zera), LB, SSL, deploy z obrazu/source. **Brak dostępu do OS/VM.** | Runtime platformy, EC2, LB, auto-scaling, patching OS/runtime, zarządzanie wersjami aplikacji. **Masz „prawie VM” (SSH wg potrzeb).** |
| **Odpowiedzialność dev** | Obraz (lub source), port, health path, env vars. | Zip (lub obraz), port (zmienna PORT), health path, env vars, ewent. .ebextensions / nginx. |
| **Format deployu** | Obraz w ECR lub połączenie z GitHub (source build). | Dla .NET on Linux: **ZIP** (dotnet publish). Opcjonalnie Docker platform. |
| **Kontrola** | Niska — brak dostępu do sieci/VM, mniej opcji tuningu. | Wyższa — environment config, scaling, .ebextensions, możliwość VPC, custom AMI (zaawansowane). |
| **Logi** | CloudWatch: `service` (platforma, health) i `application` (stdout aplikacji). | Konsola: Request logs, Full logs; opcjonalnie CloudWatch (włączenie w config). |
| **Koszt** | Płatność za vCPU/memory w czasie użycia; scale to zero. | EC2 + LB przez cały czas życia environmentu; brak scale to zero. |
| **Kiedy który** | Szybki start, mało ops, scale to zero, „tylko kontener/source”. | Więcej kontroli, compliance (VPC, custom config), wielośrodowiskowość (envs), znany model PaaS. |

---

## Kluczowe fakty

- **Beanstalk = PaaS na EC2:** Application to „folder” na wersje; Environment to konkretne wdrożenie (jedna platforma, jedna konfiguracja). Można mieć wiele environments (dev, staging) w jednej Application.
- **Health:** Environment ma swój status (Green/Yellow/Red); health check aplikacji (np. `/health`) konfigurujesz w Environment — Beanstalk używa tego do LB i do oznaczania instancji.
- **Logi:** W konsoli: Environment → Logs (Request logs, Full logs); dla diagnostyki startu przydatne Full logs (app + platform). CloudWatch wymaga włączenia w konfiguracji.
- **Cleanup:** Beanstalk trzyma EC2 i LB — po nauce warto usunąć environment (lub całą application), żeby nie płacić za idle.

---

## Weryfikacja (T01)

- [x] Notatka istnieje w repo.
- **W dwóch zdaniach:** Beanstalk zarządza platformą .NET, EC2, LB, skalowaniem i wdrożeniem; ja dostarczam zip z `dotnet publish`, konfiguruję env vars i ścieżkę health.
- **Artifact na T02:** ZIP z outputu `dotnet publish` dla wybranego API (catalog-api / payments-api), platforma .NET on Linux.
