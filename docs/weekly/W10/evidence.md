## W10 — evidence

Dowody wykonania zadań i spełnienia DoD. Roadmapa oczekuje: działający endpoint; zapisany troubleshooting deployu; `docs/runbooks/apprunner-deploy.md`.

---

### W10-T01 — Dockerfile dla catalog-api
- **Oczekiwane:** Dockerfile multi-stage, port 8080; `docker build` i `docker run` OK; GET `/health` zwraca 200.
- **Link / opis:** `src/catalog-api/Dockerfile` — multi-stage (sdk:10.0, aspnet:10.0), port 8080, `USER $APP_UID` (non-root), pinned SHA256 digests. `.dockerignore` wyklucza bin/obj/Tests. Weryfikacja: `docker build -t catalog-api:local .` OK; `docker run -p 8080:8080 catalog-api:local`; `curl http://localhost:8080/health` → 200, `{"status":"Healthy","service":"catalog-api","environment":"local-dev"}`. **Verification:** spełnione.
