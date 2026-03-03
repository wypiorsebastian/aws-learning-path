## W07 — podsumowanie tygodnia

Podsumowanie wypełniane na końcu tygodnia lub przy domykaniu (`/week-finish`). Skrót: co zrobiono, kluczowe decyzje, pułapki, następny krok.

---

- **Cel tygodnia (z roadmapy):** Zaimplementować moduł network-endpoints i wykonać pełny deploy sieci do dev (pierwszy manual apply = walidacja przed pipeline).
- **DoD:** network-core + network-endpoints wdrożone; terraform plan po apply bez driftu; smoke tests udokumentowane.
- **Status:** **DONE** (sieć dev wdrożona, endpointy i Flow Logs aktywne; runbook smoke tests zaktualizowany).
- **Wnioski / pułapki:**  
  - Opisy reguł SG (`description`) muszą używać tylko dozwolonych znaków ASCII — strzałki i polskie znaki powodują błędy API; szczegółową semantykę opisujemy w dokumentacji (`docs/network/*`), nie w AWS.  
  - CloudWatch Logs nie pozwoli utworzyć log group, jeśli istnieje już pod tą samą nazwą — w dev najprościej usunąć stary log group i pozwolić Terraformowi utworzyć go ponownie (ew. `terraform import` w bardziej enterprise’owym podejściu).  
  - NAT, Interface Endpoints i Flow Logs generują stały koszt — zgodnie z ADR-0002 warto traktować je jako zasoby „na czas nauki”, a przy dłuższej przerwie świadomie robić cleanup (`destroy` lub wyłączenie modułów).
- **Następny krok:** W08 — pipeline GitHub Actions + OIDC (przeniesienie `plan/apply` do CI/CD; manualny apply zostaje tylko jako wyjątek diagnostyczny).
