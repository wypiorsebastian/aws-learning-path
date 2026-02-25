## W02 — plan sesji D1–D5

### Kontekst tygodnia
- **Cel tygodnia:** Zrozumieć model uprawnień AWS i przygotować matrycę ról.
- **WhyNow:** IAM będzie używane wszędzie: Terraform, GitHub Actions (OIDC), ECS, Lambda, secrets — bez solidnego fundamentu IAM reszta tygodni będzie krucha.
- **Outcome (wg roadmapy):** Matryca ról i zrozumienie aktualnego modelu IAM na koncie.
- **DoD (skrót):** Potrafię wyjaśnić różnicę między IAM user / role / policy / trust policy i zaprojektować role projektu.

### Założenia czasowe
- 5 sesji po **1.5h** (D1–D5).
- Fokus: **zrozumienie modelu IAM, matryca ról, zasady bezpieczeństwa**. Brak zmian w infrastrukturze/kodzie poza ewentualnymi małymi eksperymentami na koncie dev (z zachowaniem guardrails kosztowych z W01).

---

## D1 (1.5h) — IAM fundamentals: users, roles, policies, trust (W02-T01)
- [ ] Przeczytać sekcję `W02` w `docs/roadmap/aws-course-roadmap-operational-0-24.md` (cel, DoD, pułapki).
- [ ] Zapoznać się z dokumentacją AWS IAM:
  - koncepcje: IAM user, IAM role, identity-based policy, resource-based policy,
  - pojęcia: principal, action, resource, condition, effect.
- [ ] Założyć szkic notatki `W02-T01`: sekcje users, roles, policies, trust policy, session vs long-lived credentials.
- [ ] Wypisać typowe use-case:
  - kiedy używam IAM user,
  - kiedy używam IAM role,
  - gdzie podpinam policies i jak działa ewaluacja.
- [ ] Zanotować pułapki z roadmapy (szczególnie: mylenie trust policy z permission policy).

**Cel D1:** mieć sensowny szkic notatki z wyjaśnieniem różnicy user/role/policy/trust oraz podstawowych pojęć IAM.

---

## D2 (1.5h) — STS i sesje, domknięcie notatki (W02-T01)
- [ ] Dopracować notatkę `W02-T01` o:
  - AWS STS i tymczasowe poświadczenia,
  - jak wygląda przepływ: tożsamość → assume role → session,
  - różnica między long-lived keys a session credentials.
- [ ] Uporządkować rozdzielnie:
  - **trust policy** (kto może wejść w rolę),
  - **permission policy** (co dana tożsamość może zrobić).
- [ ] Dodać konkretne przykłady (choćby pseudokod / opis) dla:
  - user z przypiętą policy,
  - role dla aplikacji (np. ECS task / Lambda),
  - role dla GitHub Actions (OIDC).
- [ ] Zidentyfikować otwarte pytania, które wymagają doprecyzowania w trakcie tygodnia i dopisać je do `docs/weekly/W02/questions.md`.

**Cel D2:** mieć kompletną notatkę `W02-T01`, na której oprze się projektowanie matrycy ról.

---

## D3 (1.5h) — Matryca ról: local dev / GitHub Actions / ECS / Lambda (W02-T02)
- [ ] Utworzyć szkic matrycy ról (docelowo `docs/runbooks/iam-role-matrix.md` zgodnie z roadmapą):
  - kolumny: `Principal`, `Trust (kto może przyjąć rolę)`, `Permission scope`, `Usage / kontekst`,
  - wiersze: local developer, GitHub Actions, ECS task, Lambda execution (na razie high-level).
- [ ] Na bazie notatki z W02-T01 opisać:
  - jakie role są potrzebne dla lokalnego developera (aws-vault/CLI / console),
  - jakie role są potrzebne dla CI/CD (GitHub Actions z OIDC),
  - jakie role będą potrzebne dla workloadów (ECS/Lambda) w tym projekcie.
- [ ] Określić zasadę least privilege na poziomie matrycy (np. oddzielenie ról infra vs app, read-only vs write).
- [ ] Zanotować decyzje i ewentualne kompromisy w matrycy (np. uproszczenia typowe dla środowiska dev-only).

**Cel D3:** mieć pierwszą wersję matrycy ról, która pokrywa główne persony: dev, CI/CD, workloady.

---

## D4 (1.5h) — Zasada „brak long-lived keys” + minimalne policy snippets (W02-T03, W02-T04)
- [ ] Na podstawie pracy z W01 i W02 opisać zasadę:
  - brak long-lived access keys w CI/CD,
  - preferencja OIDC i krótkich sesji STS,
  - jak to zmapuje się na GitHub Actions w tym projekcie.
- [ ] Zaplanować krótką notatkę / sekcję dokumentacji dla W02-T03 (zasada CI/CD bez long-lived keys).
- [ ] Zaprojektować minimalne przykłady policies dla:
  - S3 read-only (np. bucket z artefaktami / logami),
  - SQS producer (wysyłanie wiadomości do kolejki).
- [ ] Zastanowić się, które z tych policies będą przypięte do ról workloadów, a które do ról narzędziowych (np. CI/CD).

**Cel D4:** mieć spisaną zasadę „brak long-lived keys w CI/CD” oraz wstępne przykłady policies pod S3 read-only i SQS producer.

---

## D5 (1.5h) — Weryfikacja DoD W02 i podsumowanie
- [ ] Przejrzeć kryteria DoD tygodnia W02 z roadmapy:
  - potrafię wyjaśnić różnicę user/role/policy/trust,
  - mam zaprojektowaną matrycę ról dla projektu (dev, CI/CD, ECS/Lambda).
- [ ] Uzupełnić `docs/weekly/W02/evidence.md` o:
  - referencję do notatki z W02-T01 (users/roles/policies/trust),
  - aktualną wersję matrycy ról (lokalizacja + krótki opis),
  - opis zasady braku long-lived keys w CI/CD,
  - przykładowe snippets policies (przynajmniej high-level).
- [ ] Utworzyć/uzupełnić `docs/lessons/W02-summary.md` na podstawie szablonu lessons (najważniejsze wnioski z IAM).
- [ ] Upewnić się, że pytania z `docs/weekly/W02/questions.md` mają dopisane odpowiedzi lub są oznaczone jako otwarte na kolejne tygodnie.

**Cel D5:** domknąć tydzień W02 z gotową matrycą ról IAM, spisanymi zasadami bezpieczeństwa oraz evidence, które potwierdza spełnienie DoD.

