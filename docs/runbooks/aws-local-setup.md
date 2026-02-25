## Runbook — lokalny setup AWS dla OrderFlow AWS Lab

### Przeznaczenie
- Ten dokument opisuje **jak przygotować lokalne środowisko** do pracy z projektem OrderFlow AWS Lab:
  - instalacja podstawowych narzędzi (AWS CLI, Terraform, Docker, .NET 10 SDK),
  - konfiguracja profili AWS CLI i regionu,
  - podstawowa weryfikacja dostępu (`aws sts get-caller-identity`).
- Adresat: **senior .NET developer** przechodzący z Azure na AWS, pracujący na własnym laptopie (Linux / inny system).

### Wymagania wstępne
- Konto AWS z dostępem do konsoli (w tym do AWS SSO/Identity Center, jeśli jest używany).
- Uprawnienia do:
  - wykonywania logowania SSO / używania roli deweloperskiej,
  - podstawowych operacji w AWS (czytanie STS, IAM itp.).
- Możliwość instalacji narzędzi na lokalnej maszynie (uprawnienia administratora, dostęp do internetu).

---

## Instalacja narzędzi

> Celem jest posiadanie aktualnych wersji **AWS CLI v2**, **Terraform**, **Docker** i **.NET 10 SDK**, dostępnych z powłoki (`bash`).

### 1. AWS CLI v2
- Sprawdź, czy AWS CLI jest zainstalowane:
  - `aws --version`
- Jeśli narzędzie nie jest dostępne lub wersja jest zbyt stara:
  - pobierz i zainstaluj AWS CLI v2 zgodnie z oficjalną instrukcją dla swojego systemu operacyjnego.
- Po instalacji ponownie uruchom:
  - `aws --version`
  - upewnij się, że komenda działa bez błędów i wskazuje wersję 2.x.

### 2. Terraform
- Sprawdź wersję:
  - `terraform version`
- Jeśli Terraform nie jest zainstalowany:
  - pobierz binarkę Terraform dla swojego systemu (np. linux_amd64),
  - umieść binarkę w katalogu dostępnym w `PATH`.
- Zweryfikuj:
  - `terraform version` — powinno zwrócić numer wersji bez błędu.

### 3. Docker
- Sprawdź:
  - `docker --version`
- Jeśli Docker nie jest zainstalowany:
  - zainstaluj Docker Engine / Docker Desktop zgodnie z dokumentacją swojego systemu.
- Po instalacji:
  - `docker --version` — powinna zwrócić wersję Dockera,
  - opcjonalnie uruchom prosty kontener testowy (np. `docker run hello-world`), aby potwierdzić poprawne działanie demona Dockera.

### 4. .NET 10 SDK
- Sprawdź środowisko:
  - `dotnet --info`
- Wymagania dla projektu:
  - zainstalowany .NET SDK **10.0.x**,
  - dostępne runtime’y `Microsoft.NETCore.App` i `Microsoft.AspNetCore.App` w wersji 10.0.x.
- Jeśli SDK nie jest zainstalowane:
  - zainstaluj .NET 10 SDK z oficjalnej strony Microsoft,
  - zweryfikuj ponownie:
    - `dotnet --info` — powinno pokazać SDK 10.0.x oraz odpowiednie runtimes.

---

## Konfiguracja profili AWS CLI i regionu

> Celem jest posiadanie **jednego, jawnie nazwanego profilu roboczego** (np. `swpr-dev`) oraz **świadomego braku profilu `default`**, aby uniknąć przypadkowych operacji.

### Konwencja profili
- Główny profil roboczy:
  - `swpr-dev` — wskazuje na konto deweloperskie (np. `swpr-dev`) z uprawnieniami odpowiednimi do pracy w kursie.
- Celowa decyzja:
  - **nie konfigurujemy profilu `default`** lokalnie,
  - jeśli jakaś komenda użyje AWS CLI bez wskazania profilu i zakończy się błędem „Unable to locate credentials”, jest to oczekiwane zabezpieczenie.

### Konfiguracja profilu `swpr-dev`
- Utwórz / zaktualizuj profil, korzystając z:
  - `aws configure --profile swpr-dev`
  - lub przez konfigurację SSO/Identity Center (np. `aws configure sso --profile swpr-dev`), jeśli korzystasz z SSO.
- Upewnij się, że:
  - profil wskazuje na właściwe konto AWS (konto deweloperskie),
  - konfiguracja nie zapisuje stałych access key/secret key, jeśli używasz SSO (wówczas dane tymczasowe są pobierane przez workflow SSO).

### Region domyślny
- Wybierz region roboczy (przykładowo):
  - `eu-central-1` (Frankfurt) — dobry wybór dla środowisk w Europie.
- Ustaw region dla profilu `swpr-dev`:
  - w pliku konfiguracyjnym AWS CLI (`~/.aws/config`) lub podczas `aws configure --profile swpr-dev`.
- Założenie:
  - **wszystkie operacje** w tym kursie są wykonywane z użyciem profilu `swpr-dev` oraz wybranego regionu (tu: `eu-central-1`),
  - jeśli używasz innego regionu, konsekwentnie zamień go w tym dokumencie.

### Używanie profilu w praktyce
- W powłoce możesz:
  - ustawić zmienną: `export AWS_PROFILE=swpr-dev` (dla bieżącej sesji),
  - lub przekazywać profil jawnie:
    - `aws sts get-caller-identity --profile swpr-dev`
- Dla narzędzi takich jak Terraform, które korzystają z AWS CLI/SDK:
  - ustaw `AWS_PROFILE=swpr-dev` w środowisku, aby uniknąć niespójności.

---

## Weryfikacja

> Celem jest sprawdzenie, że narzędzia i profil działają razem poprawnie.

### 1. Wersje narzędzi
- Uruchom i zanotuj wyniki:
  - `aws --version`
  - `terraform version`
  - `docker --version`
  - `dotnet --info`
- Oczekiwane:
  - wszystkie komendy kończą się bez błędu,
  - wersje są zgodne z wymaganiami kursu (aktualne narzędzia, .NET 10 SDK).

### 2. Tożsamość STS
- Uruchom:
  - `aws sts get-caller-identity --profile swpr-dev`
- Oczekiwane:
  - zwracane są pola `UserId`, `Account`, `Arn`,
  - `Arn` wskazuje na **assumed-role** lub użytkownika/rolę, która odpowiada Twojemu profilowi deweloperskiemu,
  - `Account` odpowiada numerowi konta, które ma być używane w kursie.
- Jeśli `aws sts get-caller-identity` (bez `--profile`) zwraca:
  - `Unable to locate credentials` — jest to zgodne z naszą decyzją o braku profilu `default`.

---

## Pułapki

- **Profil `default` z przypadkowymi credentials:**
  - skonfigurowany `default` może sprawić, że przypadkowe komendy trafią w nieoczekiwane konto/region,
  - w tym runbooku **celowo nie konfigurujemy `default`** na laptopie deweloperskim.

- **Zły region:**
  - jeśli nie ustawisz regionu w profilu, AWS CLI może użyć innego regionu niż zakładasz,
  - upewnij się, że `region = eu-central-1` (lub inny wybrany) jest wpisany dla profilu `swpr-dev`.

- **Mieszanie SSO i stałych kluczy:**
  - unikaj jednoczesnego używania tego samego profilu z różnymi mechanizmami (SSO vs access keys),
  - trzymaj się jednego sposobu logowania per profil (tu: preferowane SSO + assumed-role).

- **PATH i wiele wersji narzędzi:**
  - jeśli masz kilka wersji Terraform / AWS CLI / .NET, upewnij się, że w `PATH` pierwsza jest ta, której chcesz używać,
  - dla .NET sprawdź, czy `dotnet --info` wskazuje SDK 10.0.x.

- **Docker bez działającego demona:**
  - `docker --version` może działać, nawet jeśli daemon Dockera nie jest uruchomiony,
  - w razie problemów z kontenerami sprawdź status usługi Dockera.

