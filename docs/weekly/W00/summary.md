## W00 — podsumowanie tygodnia

#### Cel tygodnia
- Zdefiniować projekt, repo, standard pracy i artefakty dokumentacyjne (`README`, szablony, ADR), tak aby repo było gotowe do startu W01.

#### Co zrobiłem
- Przygotowałem `README.md` opisujące:
  - cel projektu `OrderFlow AWS Lab`,
  - profil uczestnika (senior .NET → AWS, dev-only),
  - zakres techniczny (AWS, .NET 10, Terraform, CI/CD),
  - sposób używania roadmapy i tygodniowych artefaktów.
- Utworzyłem szablony dokumentacyjne:
  - `docs/lessons/_template.md` (tygodniowe podsumowanie),
  - `docs/troubleshooting/_template.md` (notatki troubleshootingowe).
- Zdefiniowałem zakres kursu w `docs/adr/ADR-0001-course-scope.md` (kontekst, in scope / out of scope, konsekwencje, Organizations + konto `swpr-dev`).
- Utworzyłem bazową strukturę repo:
  - katalogi `src/*`, `infra/terraform/*`, `.github/workflows/`,
  - projekt Web API `src/orders-api/Orders.Api.csproj` (net10.0),
  - solution `OrderFlow.sln` zawierającą `Orders.Api`.
- Zbudowałem lokalnie solution (`dotnet build OrderFlow.sln`) z sukcesem.

#### Co działa
- README daje spójny opis projektu i kursu, można na jego podstawie „pitchować” inicjatywę.
- Szablony lessons/troubleshooting są gotowe do użycia w kolejnych tygodniach.
- Repo ma sensowną strukturę katalogów startowych zgodną z roadmapą.
- Istnieje solution `OrderFlow.sln` z pierwszym projektem `orders-api` na .NET 10 i poprawnie się buduje.
- ADR-0001 opisuje realne środowisko (AWS Organization, OU `Development`, konto `swpr-dev`) i zakres kursu.

#### Co nie działało / problemy
- W środowisku asystenta dostępne było tylko SDK .NET 10, więc oryginalne założenie `.NET 8` wymagało korekty:
  - trzeba było zaktualizować README, roadmapę i ADR na .NET 10.
- Automatyczne tworzenie solucji przez CLI w sandboxie wymagało obejścia (ręcznie przygotowany plik `.sln`).

#### Smoke tests (W00)
- [x] `dotnet build` przechodzi lokalnie dla `OrderFlow.sln`.
- [x] Repo ma strukturę katalogów zgodną z roadmapą (src/*, infra/terraform/*, docs/*, .github/workflows/).
- [x] README opisuje projekt, cel i zakres kursu.

#### Evidence (odniesienia)
- `docs/weekly/W00/evidence.md`:
  - linki do README, szablonów, ADR-0001,
  - informacja o `src/orders-api/Orders.Api.csproj` (`net10.0`) i strukturze katalogów,
  - informacja o udanym lokalnym `dotnet build OrderFlow.sln` (potwierdzone ręcznie).
