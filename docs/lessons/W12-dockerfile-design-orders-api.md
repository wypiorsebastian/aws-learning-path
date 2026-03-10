# W12 — Analiza i projekt Dockerfile dla orders-api

Projekt wzorcowego Dockerfile zgodnego z best practices Microsoft i Docker.

---

## Źródła

1. **[.NET container images](https://learn.microsoft.com/en-us/dotnet/core/docker/container-images)** — obrazy `aspnet`, `sdk`, `runtime`; tagging scheme; scenariusze (Alpine, chiseled, distroless).
2. **[Docker building best practices](https://docs.docker.com/build/building/best-practices/)** — multi-stage, pin digests, .dockerignore, cache, USER non-root.
3. **[Tutorial: Containerize a .NET app](https://learn.microsoft.com/en-us/dotnet/core/docker/build-container)** — pinned SHA256, multi-stage, ENTRYPOINT.
4. **[ASP.NET Core Docker](https://learn.microsoft.com/en-us/aspnet/core/host-and-deploy/docker/building-net-docker-images)** — copy csproj first (cache), restore, publish.

---

## Zastosowane best practices

| Zasada | Źródło | Implementacja |
|--------|--------|---------------|
| **Multi-stage build** | Docker, Microsoft | Stage `build` (SDK) + stage `final` (aspnet runtime) — mniejszy obraz końcowy. |
| **Pinned digest (SHA256)** | Microsoft, Docker | `@sha256:...` przy `FROM` — reproducibility, supply chain integrity. |
| **Copy csproj first, restore** | ASP.NET Docker | Osobna warstwa `COPY` + `RUN dotnet restore` — lepszy cache (zmiana kodu nie invaliduje restore). |
| **COPY over ADD** | Docker | Używamy `COPY`; `ADD` tylko gdy potrzebny remote URL. |
| **Minimal runtime image** | Microsoft | `aspnet` (nie `sdk`) w final stage — tylko runtime, mniejszy obraz. |
| **Non-root USER** | Docker (USER) | `USER $APP_UID` — obraz aspnet definiuje `APP_UID`; mniejsza powierzchnia ataku. |
| **Explicit port** | ECS/Fargate | `ENV ASPNETCORE_URLS=http://+:8080`, `EXPOSE 8080` — zgodność z ALB, health check. |
| **.dockerignore** | Docker | Wykluczenie `bin/`, `obj/`, `**/*.Tests/` — szybszy build, mniejszy kontekst. |
| **ENTRYPOINT exec form** | Docker | `["dotnet", "Orders.Api.dll"]` — proper signal handling. |
| **UseAppHost=false** | Catalog-api | `/p:UseAppHost=false` — unika platform-specific app host przy publish. |

---

## Decyzje projektowe

- **Obraz bazowy:** `mcr.microsoft.com/dotnet/aspnet:10.0` — Ubuntu-based, ICU/tzdata (globalization), standard dla API.
- **Nie używamy chiseled/distroless** — wymagają `InvariantGlobalization=true`; orders-api może potrzebować normalizacji dat/culture.
- **Digesty:** Zgodne z catalog-api (sdk:10.0, aspnet:10.0) — ten sam baseline, weryfikowany w projekcie.
- **Architektura:** Build context = `src/orders-api/`; ścieżki `Orders.Api/` (bez `src/` w COPY — context jest katalogiem orders-api).

---

## Pułapki (z roadmapy W12)

- **Arch mismatch:** Na Mac/ARM build domyślnie dla arm64; Fargate = linux/amd64. Rozwiązanie: `docker build --platform linux/amd64` lub `docker buildx build --platform linux/amd64`.
- **Port:** Aplikacja musi nasłuchiwać na 8080 — `ASPNETCORE_URLS` to wymusza.
- **Tagowanie:** Unikać samego `latest`; w pipeline używać commit SHA / semver.

---

## Weryfikacja lokalna

```bash
cd src/orders-api
docker build -t orders-api:local .
docker run --rm -p 8080:8080 orders-api:local
# W innym terminalu:
curl http://localhost:8080/health
```
