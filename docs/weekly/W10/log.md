## W10 — log tygodnia

Log wpisów chronologicznie; każdy wpis z datą/czasem i powiązanym TaskId.

---

- **2025-03-09** — W10-T01: Utworzono Dockerfile dla catalog-api w `src/catalog-api/Dockerfile`. Multi-stage (sdk:10.0 build, aspnet:10.0 runtime), port 8080, `ASPNETCORE_URLS=http://+:8080`. Lokalna weryfikacja: `docker build -t catalog-api:local .` OK; `docker run -p 8080:8080`; `curl http://localhost:8080/health` → 200, `{"status":"Healthy","service":"catalog-api","environment":"local-dev"}`. Dodano `.dockerignore` (bin, obj, Tests).
- **2025-03-09** — W10-T01 DONE: Dodatkowe usprawnienia Dockerfile — `USER $APP_UID` (non-root), pinned SHA256 digests dla reproducibility. Build i test /health OK. Task zamknięty.
