## W01 — plan sesji D1–D5

### Kontekst tygodnia
- **Cel tygodnia:** Przygotować bezpieczny baseline pracy z AWS lokalnie.
- **WhyNow:** Wszystko później zależy od poprawnej konfiguracji CLI, profili i tożsamości AWS.
- **Outcome (wg roadmapy):** Działające profile AWS CLI + potwierdzona tożsamość oraz spisany runbook lokalnego setupu.

### Założenia czasowe
- 5 sesji po **1.5h** (D1–D5).
- Fokus: konfiguracja konta/profili AWS, narzędzi lokalnych i dokumentacji. **Brak zmian funkcjonalnych w kodzie .NET**, brak Terraform/CI-CD poza instalacją narzędzia.

---

## D1 (1.5h) — Inwentaryzacja i instalacja narzędzi lokalnych (W01-T01)
- [ ] Przeczytać sekcję `W01` w `docs/roadmap/aws-course-roadmap-operational-0-24.md` i upewnić się, że rozumiem cel tygodnia, DoD i oczekiwane evidence.
- [ ] Sprawdzić, jakie wersje narzędzi są już zainstalowane lokalnie:
  - `aws --version`
  - `terraform version`
  - `docker --version`
  - `dotnet --info`
- [ ] Jeśli brakuje któregoś z narzędzi lub wersja jest zbyt stara, zaplanować i wykonać instalację/aktualizację:
  - AWS CLI (v2),
  - Terraform (aktualna stabilna wersja),
  - Docker (Docker Engine / Docker Desktop w zależności od środowiska),
  - .NET 10 SDK (zgodnie z roadmapą / repo).
- [ ] Zanotować ewentualne ograniczenia środowiskowe (np. brak uprawnień admina, proxy, specyficzny OS).

**Cel D1:** mieć zainstalowane (lub zweryfikowane) wszystkie narzędzia wymagane w W01-T01 oraz wiedzieć, czy są jakieś techniczne blokery.

---

## D2 (1.5h) — Konfiguracja profili AWS CLI i regionu (W01-T01, W01-T02)
- [ ] Zapoznać się z koncepcjami:
  - profile AWS CLI (`~/.aws/config`, `~/.aws/credentials`),
  - region domyślny,
  - podstawy STS: `aws sts get-caller-identity`.
- [ ] Zaplanować konwencję nazw profili (np. `swpr-dev`, `default` wskazujący na właściwy profil).
- [ ] Skonfigurować profil/profile AWS CLI dla konta roboczego (zgodnie z Organizations / kontem `swpr-dev` jeśli dotyczy).
- [ ] Ustawić sensowny region domyślny (np. `eu-central-1` / `eu-west-1` — zgodnie z roadmapą i własną preferencją).
- [ ] Zweryfikować dostęp:
  - uruchomić `aws sts get-caller-identity --profile <profil>` i upewnić się, że tożsamość jest zgodna z oczekiwaniami,
  - jeśli używasz MFA, potwierdzić flow logowania (czas ważności sesji, ewentualne błędy).
- [ ] Zanotować najważniejsze decyzje (nazwa profilu, region, sposób logowania) do wykorzystania później w runbooku.

**Cel D2:** mieć poprawnie działający profil/profil(e) AWS CLI z ustawionym regionem domyślnym oraz potwierdzoną tożsamością przez STS.

---

## D3 (1.5h) — Runbook `aws-local-setup.md` — szkic (W01-T03)
- [ ] Utworzyć (lub przygotować do utworzenia) plik `docs/runbooks/aws-local-setup.md`.
- [ ] Zaprojektować strukturę runbooka zgodnie z zasadami dokumentacji:
  - `Przeznaczenie` (dla kogo jest dokument),
  - `Wymagania wstępne` (konto AWS, dostęp do konsoli, system operacyjny, uprawnienia),
  - `Instalacja narzędzi` (AWS CLI, Terraform, Docker, .NET 10 SDK),
  - `Konfiguracja profili i regionu`,
  - `Weryfikacja` (komendy, które trzeba uruchomić),
  - `Pułapki` (np. zły region, konflikt profili, PATH, proxy).
- [ ] Na bazie pracy z D1–D2 spisać konkretne kroki instalacji/weryfikacji dla każdego narzędzia (nawet jeśli część będzie dopracowana później).
- [ ] Dodać sekcję z przykładowymi komendami weryfikującymi (`aws --version`, `terraform version`, `dotnet --info`, `aws sts get-caller-identity`).

**Cel D3:** mieć sensowny szkic runbooka lokalnego setupu, który odzwierciedla Twoje realne środowisko i decyzje z W01.

---

## D4 (1.5h) — Domknięcie runbooka + ADR kosztowy (W01-T03, W01-T04)
- [ ] Uzupełnić brakujące fragmenty w `aws-local-setup.md`:
  - doprecyzować komendy instalacyjne (wysoki poziom, bez zależności od pojedynczego OS jeśli niepotrzebne),
  - dopisać uwagi operacyjne (czasowość sesji MFA, typowe błędy).
- [ ] Zweryfikować runbook „end-to-end”: przejść go mentalnie lub faktycznie na swoim środowisku i sprawdzić, czy niczego nie brakuje.
- [ ] Utworzyć ADR `docs/adr/ADR-0002-cost-guardrails-dev.md` dla zasad kosztowych środowiska deweloperskiego:
  - założenia `dev-only`,
  - preferencja usług z darmowym tierem / niskokosztowych,
  - zasady sprzątania zasobów po eksperymentach,
  - ograniczenia dotyczące drogich usług (np. RDS produkcyjnego typu, duże instancje EC2),
  - ewentualne użycie AWS Budgets / alertów kosztowych (nawet jeśli tylko konceptualnie na tym etapie).
- [ ] Powiązać ADR z roadmapą (referencje do W01 i ogólnego celu kursu).

**Cel D4:** mieć spójny runbook lokalnego setupu oraz formalnie opisane zasady kosztowe dla środowiska dev.

---

## D5 (1.5h) — Weryfikacja DoD W01 i podsumowanie
- [ ] Zweryfikować kryteria DoD tygodnia W01 (z roadmapy):
  - [ ] `aws --version` zwraca poprawną wersję CLI,
  - [ ] `terraform version` działa,
  - [ ] `dotnet --info` działa i pokazuje .NET 10 SDK,
  - [ ] `aws sts get-caller-identity` zwraca poprawną tożsamość dla wybranego profilu.
- [ ] Uzupełnić `docs/weekly/W01/evidence.md` o:
  - informację o wersjach narzędzi,
  - opis skonfigurowanych profili/regionu (bez wrażliwych danych),
  - referencje do `aws-local-setup.md` i ADR-0002.
- [ ] Utworzyć/uzupełnić `docs/lessons/W01-summary.md` na podstawie szablonu lessons (najważniejsze wnioski z tygodnia).
- [ ] Zaktualizować `docs/weekly/index.md`, jeśli coś zmieniło się w statusie W01 lub następnym kroku.

**Cel D5:** domknąć tydzień W01 z działającymi profilami CLI, spisanym runbookiem oraz jasnymi zasadami kosztowymi, gotowy do startu W02.

