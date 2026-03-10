# Analiza: przesunięcie Elastic Beanstalk za ECS Fargate i Lambda (ok. W23)

**Data:** 2025-03-10  
**Kontekst:** catalog-api już na App Runner; pytanie, czy Beanstalk można przenieść na koniec (ok. W23) i czy payments-api będzie potrzebne w flow Fargate/Lambda/orders-api.

---

## 1. Czy zmiana kolejności jest możliwa?

**Tak.** Z punktu widzenia zależności roadmapy **żaden tydzień W12–W24 nie ma W11 (Beanstalk) w Prereq**.

| Tydzień | Prereq (z roadmapy) |
|---------|----------------------|
| W12 (ECR) | W09 |
| W13 (ECS Fargate) | W07, W12 |
| W14–W22 | W13, W14, … W21 (łańcuch bez W11) |
| W23 (Observability) | W13–W22 |
| W24 (Finalizacja) | W00–W23 |

**Wniosek:** Beanstalk jest „wyspą” w sensie zależności — wymaga tylko W10 (App Runner). Można go przesunąć za ECS i Lambda bez łamania prereq dla W12–W22.

---

## 2. Czy payments-api jest potrzebne przy Fargate i Lambda (orders-api)?

**Nie.** W roadmapie:

- **W13 (ECS Fargate):** wdrażany jest **orders-api** — bez wywołań do payments-api.
- **W16 (RDS):** orders-api łączy się z RDS — bez payments-api.
- **W18 (SQS):** orders-api publikuje do kolejki, **order-worker** konsumuje — bez payments-api.
- **W20 (Lambda):** **payment-callback** (Lambda) to endpoint dla **callbacków od zewnętrznego providera płatności**; Lambda publikuje event/kolejkę w dół. Nie ma w roadmapie zadania „orders-api wywołuje payments-api” ani „Lambda wywołuje payments-api”.

**payments-api** w roadmapie pojawia się tylko w **W11-T02** jako jedna z opcji do wdrożenia na Beanstalk („Wdróż payments-api **lub** catalog-api do Beanstalk”). Nie jest wymagane do działania flow orders-api ↔ Fargate ↔ SQS ↔ Lambda (payment-callback).

**Podsumowanie:** Do pracy z Fargate, Lambda i orders-api **nie musisz** mieć payments-api wdrożonego nigdzie. Catalog-api na App Runner w zupełności wystarcza jako drugi serwis w chmurze; payments-api możesz wdrożyć później (np. na Beanstalk w okolicy W23) albo w ogóle pominąć w tym flow.

---

## 3. Opcje przesunięcia Beanstalk „gdzieś w okolicy W23”

### Opcja A — Beanstalk jako W23 (Observability przesuwa się na W24, Finalizacja na W25)

- **W11:** Obecną treść W11 (Beanstalk) wykreślić / zastąpić np. „Tydzień rezerwy” lub lekkim tematem (np. pogłębienie runbooków App Runner, porównanie hostingu na podstawie dokumentacji).
- **W12–W22:** Bez zmian.
- **W23:** Elastic Beanstalk (obecna treść W11).
- **W24:** Observability, alarmy, troubleshooting (obecna W23).
- **W25:** Finalizacja i portfolio (obecna W24).

**Efekt:** Kurs ma 26 tygodni (W00–W25). Course DoD nadal da się spełnić („App Runner lub Beanstalk minimum 1; docelowo oba” — Beanstalk w W23).

### Opcja B — Zachować 25 tygodni (W00–W24): Beanstalk w W23, Observability wchłonięta w W22/W24

- **W23:** Beanstalk.
- **W24:** Finalizacja z elementami observability (alarmy, playbooki) wplecionymi w „domknięcie projektu”.

**Minus:** Observability jest teraz osobnym tygodniem (W23) z jasnym DoD; łączenie z finalizacją rozmywa cel i może być za dużo na jeden tydzień.

### Opcja C — Nie zmieniać numeracji; „W11” zrobić później jako catch-up / stretch

- **W11:** Formalnie pomijasz (lub robisz tylko T01 theory + notatkę porównawczą bez deployu).
- **W12–W24:** Idą po kolei jak dziś.
- **Po W22 lub w W23:** Robisz Beanstalk jako **stretch / catch-up** (np. jeden tydzień „Beanstalk + porównanie hostingów”) bez zmiany numeracji W23/W24.

**Efekt:** Roadmapa pozostaje 0–24; Beanstalk jest „opcjonalnym blokiem” po Lambda. Course DoD: „App Runner lub Beanstalk (minimum 1)” — spełnione przez App Runner; „docelowo oba” — realizowane w catch-up.

---

## 4. Rekomendacja

- **Zmiana miejsca jest możliwa** i nie koliduje z Fargate/Lambda/orders-api.
- **payments-api nie jest wymagane** do flow orders-api + Fargate + Lambda; możesz na Beanstalk w dowolnym momencie wdrożyć catalog-api (ponownie), payments-api lub inny API.
- Jeśli chcesz **zachować 25 tygodni (W00–W24)** i nie dodawać W25: **Opcja C** (Beanstalk jako stretch/catch-up po W22) jest najmniej inwazyjna.
- Jeśli akceptujesz **26 tygodni**: **Opcja A** daje najczystszy podział (W23 = Beanstalk, W24 = Observability, W25 = Finalizacja) i wymaga jedynie aktualizacji roadmapy (przesunięcie sekcji + prereq W24→W25).

---

## 5. Co zaktualizować w roadmapzie po decyzji

- Jeśli **Opcja A:** przenieść blok „W11 — Elastic Beanstalk” na pozycję W23; obecny W23 → W24, W24 → W25; zaktualizować Prereq (W23: np. W10 + W22; W24: W13–W23; W25: W00–W24); indeks tygodni → usługi; Course DoD (jeśli jest sztywne „W00–W24”).
- Jeśli **Opcja C:** w sekcji W11 dodać adnotację „Opcjonalny / stretch; można zrealizować po W22 jako catch-up”; W23/W24 bez zmian.
