# Minecraft Modpacks – konfiguracja serwerów TiliNakor

Repozytorium zawiera paczki modów (packwiz) dla 4 serwerów Minecraft Fabric 
zarządzanych przez Crafty Controller na QNAP-ie. Centralna kolekcja modów 
z automatyczną dystrybucją do klientów (przez packwiz-installer-bootstrap) 
i synchronizacją serwerów (przez mrpack-install).

**Aktualna wersja**: Minecraft 26.2, Fabric Loader 0.19.3  
**Środowisko zarządzania**: macOS (Apple Silicon M4 Pro), packwiz w `~/go/bin/`, repo w `~/Minecraft/minecraft-modpacks/`

## Serwery

| Serwer | Charakter | Paczka |
|--------|-----------|--------|
| **TiliNakor** | Survival główny, aktywny | `fabric/TiliNakor/` |
| **Pandora** | Survival zamrożony (ForeverWorld) | `fabric/TiliNakor/` (ta sama) |
| **TiliNakor test** | Testowy do eksperymentów | `fabric/TiliNakor_test/` |
| **kTiliNakor** | Kreatywny, do buildowania | `fabric/kTiliNakor/` |

UUID serwerów (do operacji na QNAP):

| Serwer | UUID |
|--------|------|
| TiliNakor | `5071df24-5a62-48d9-b038-c910d088898f` |
| Pandora | `7d468085-bc02-4e7b-b53a-54ad9f4b03e3` |
| TiliNakor test | `fc17ba3e-b41b-4fd3-b012-52749bd58833` |
| kTiliNakor | `eff8a0a1-9645-4d4b-a1d5-74fe9bfabf30` |

## Struktura repozytorium

```
minecraft-modpacks/
├── README.md                ← ten plik
├── .gitignore               ← ignoruje pliki *.mrpack (generowane lokalnie)
└── fabric/
    ├── TiliNakor/           ← paczka produkcyjna (TiliNakor + Pandora)
    │   ├── pack.toml        ← metadane paczki (nazwa, wersja MC, loader)
    │   ├── index.toml       ← indeks zawartości (auto-generowany)
    │   └── mods/
    │       └── *.pw.toml    ← metadane każdego moda (linki, hashe, side)
    ├── TiliNakor_test/      ← paczka testowa (pole eksperymentów)
    └── kTiliNakor/          ← paczka kreatywna (z Axiom i creative tools)
```

### Co jest, a czego nie ma w repo

✅ **W repo**: metadane paczek (`pack.toml`, `index.toml`, pliki `*.pw.toml`)  
❌ **NIE w repo**: fizyczne pliki `.jar` modów ani wygenerowane `.mrpack`  

Pliki `.jar` są pobierane dynamicznie z Modrinth/CurseForge przy każdej synchronizacji 
klienta i serwera, na podstawie URL-i i hashy zapisanych w plikach `.pw.toml`.

## Środowisko pracy (Mac)

### Wymagane narzędzia

- **packwiz** zainstalowane przez `go install github.com/packwiz/packwiz@latest`, binarka w `~/go/bin/packwiz` (dodana do PATH w `~/.zshrc`)
- **Git** (standard w macOS Command Line Tools)
- **GitHub Desktop** zalogowany jako Nakorek (alternatywa GUI do commit/push)
- **Terminus** dla SSH do QNAP (alternatywnie wbudowany `ssh`)
- **VSCode** lub inny edytor dla plików konfiguracyjnych

### Zmienne środowiskowe

W `~/.zshrc`:
```bash
export PATH="$HOME/go/bin:$PATH"
export CURSEFORGE_API_KEY='twój_klucz_tutaj'
```

Po zmianie: `source ~/.zshrc`.

### Workflow commit/push

Dwa równoważne sposoby, oba skonfigurowane i działają:

**Z Terminala** (wygodniejsze pod skrypty automatyzacji):
```bash
cd ~/Minecraft/minecraft-modpacks
git add -A
git commit -m "opis zmiany"
git push
```

Wymaga jednorazowej konfiguracji:
1. `git config --global credential.helper osxkeychain` – włącza macOS Keychain dla git
2. Wygeneruj **Personal Access Token (classic)** z scope `repo` na https://github.com/settings/tokens
3. Przy pierwszym pushu wpisz username = Nakorek + token jako hasło – keychain zapamięta na zawsze
4. Kolejne pushe pójdą bez pytania o credentials

**GitHub Desktop** – GUI, działa od ręki dzięki OAuth (alternatywa gdy nie chcesz CLI).

Oba ścieżki współistnieją – wybierz pod konkretne zadanie.

## Workflow aktualizacji modów

### Standardowa aktualizacja (co tydzień/dwa)

**1. Sprawdź dostępne aktualizacje (w paczce testowej najpierw!)**

```bash
cd ~/Minecraft/minecraft-modpacks/fabric/TiliNakor_test
packwiz update --all
```

Packwiz pokaże listę updateów i zapyta o potwierdzenie. Odpowiedz `N` żeby najpierw zobaczyć listę, oceń (czy są bety, major bumps), potem powtórz komendę i odpowiedz `Y`.

**2. Eksportuj mrpack i pushnij na GitHuba**

```bash
packwiz modrinth export
```

Commit + push z Terminala lub GH Desktop, opis typu *"Aktualizacja modów X, Y, Z"*.

**3. Test na kliencie**

Odpal w Prismie instancję `TiliNakor_test_auto`. Bootstrap zaktualizuje mody automatycznie. 
Zagraj chwilę, sprawdź czy nic się nie sypie.

**Jeśli Prism nie wykrywa zmian** – zamknij i otwórz Prism Launcher ponownie.

**4. Test na serwerze testowym (jeśli były aktualizacje serwerowych modów)**

Wgraj mrpack na QNAP do folderu testowego serwera (przez File Station albo SCP):
```
/Container/crafty/servers/fc17ba3e-b41b-4fd3-b012-52749bd58833/
```

W terminalu SSH na QNAP, zatrzymaj serwer w Crafty, potem:

```bash
cd /share/Container/crafty/servers/fc17ba3e-b41b-4fd3-b012-52749bd58833
ls *.mrpack    # WERYFIKACJA przed czyszczeniem!
rm mods/*.jar
docker exec -it crafty_container bash
/crafty/import/tools/mrpack-install-linux /crafty/servers/fc17ba3e-b41b-4fd3-b012-52749bd58833/TiliNakor_test-1.0.0.mrpack --server-dir /crafty/servers/fc17ba3e-b41b-4fd3-b012-52749bd58833
exit
```

⚠️ **Uwaga – duplikat fabric-server.jar**

Mrpack-install **pobiera świeży `fabric-server-mc.X-loader.Y-launcher.Z.jar`** nawet jak nie zmieniła się wersja MC. Po instalacji zostają dwa pliki – usuń duplikat:

```bash
cd /share/Container/crafty/servers/<UUID>
ls -la fabric-server*.jar
rm fabric-server-mc.<MC>-loader.<L>-launcher.<W>.jar
ls -la fabric-server*.jar
```

Powinien zostać tylko `fabric-server.jar` (aktualny dla obecnej wersji MC).

Start serwera w Crafty, test w grze.

**5. Replikacja na paczki produkcyjne**

Jeśli test wypadł OK – powtarzasz kroki 1-2 dla paczki `TiliNakor` (która obsługuje również Pandorę) i `kTiliNakor`.

Klienci dostają update przy następnym uruchomieniu instancji (bootstrap synchronizuje).

**6. Aktualizacja serwerów produkcyjnych** (jeśli zmiany dotyczą serwerowych modów)

Procedura jak w kroku 4, dla każdego serwera produkcyjnego (TiliNakor, Pandora, kTiliNakor) z odpowiednim mrpackiem.

### Mody klient-only

Aktualizacje modów oznaczonych `side = "client"` (np. Sodium, Iris, Litematica, Mod Menu) 
**nie wymagają żadnych operacji na serwerze**. Klienci dostaną update przez bootstrap.

### Pinowanie wersji moda

Czasem nie chcesz żeby `packwiz update --all` zaktualizował konkretny mod – 
np. bo nowsza wersja jest beta z konfliktami, ale starsza stabilna działa.

```bash
packwiz pin <slug>
```

Mod ma teraz `pin = true` w `.pw.toml`. `packwiz update --all` go pominie. 
Gdy chcesz znowu pozwalać na update:

```bash
packwiz unpin <slug>
```

**Use case z historii**: po migracji MC 26.1.2 → 26.2 Sodium 0.9.1-beta.2 był 
niekompatybilny z Iris 1.11.1 (Sodium 0.9 wymagało Iris 1.11.2+, której jeszcze nie 
było). Cofnęliśmy Sodium na 0.9.0 stable i zapinowali do czasu aż wyjdzie Sodium 
0.9.x stable kompatybilna z istniejącą Iris.

### Szybka podmiana pojedynczego moda na serwerze (bez mrpack-install)

Przy małej zmianie (np. krytyczny hotfix jednego moda) zamiast pełnej procedury mrpack-install można podmienić plik bezpośrednio:

```bash
cd ~/Minecraft/minecraft-modpacks/fabric/TiliNakor
cat mods/<mod>.pw.toml   # znajdź URL pobierania
```

W terminalu SSH na QNAP (po zatrzymaniu serwera):

```bash
cd /share/Container/crafty/servers/<UUID>/mods
rm <stary-plik-moda>.jar
wget "<URL z pw.toml>"
ls <pattern-moda>*
```

Tylko jeden plik powinien zostać. Start serwera w Crafty.

To było użyte np. przy hotfixie Lithium 0.24.3 → 0.24.4 (crash przy interakcji z Allay).

## Workflow usunięcia moda z paczki

Przy **wyrzucaniu** moda (np. po decyzji że już nie potrzebujesz) mrpack-install **nie jest** 
potrzebny – nic nie pobieramy, tylko czyścimy. 

### Krok 1 – Sprawdzenie zależności (przed usunięciem!)

Zanim usuniesz mod z paczek, **sprawdź czy nie jest zależnością innych modów**:

```bash
cd ~/Minecraft/minecraft-modpacks/fabric/TiliNakor_test
grep -i "<slug-lub-nazwa>" mods/*.pw.toml
```

Jeśli wynik pokazuje **tylko sam plik moda** – nic od niego nie zależy, można usuwać.  
Jeśli pokazuje **inne pliki** – te mody go wymagają, usunięcie spowoduje crash.

### Krok 2 – Usuwanie z paczki testowej najpierw

```bash
cd ~/Minecraft/minecraft-modpacks/fabric/TiliNakor_test
packwiz remove <slug>
packwiz list | grep -i <slug>
```

(Drugie polecenie potwierdza że mod zniknął – wynik pusty)

⚠️ **Uwaga – slug pliku może różnić się od sluga z URL Modrinth**. Przykład: 
mod *Flower Map* miał slug w `mods/` jako `flowermap` (bez myślnika), nie `flower-map`. 
Jeśli `packwiz remove` zwróci "Can't find this file" – sprawdź faktyczną nazwę:

```bash
ls mods/ | grep -i <fragment-nazwy>
```

### Krok 3 – Commit + push

Z Terminala lub w GitHub Desktop, opis usunięcia.

### Krok 4 – Klient

Bootstrap przy następnym uruchomieniu instancji **automatycznie usunie** plik moda z `mods/`.

### Krok 5 – Serwer (jeśli mod był `both` lub `server`)

W Crafty: **Stop** serwera.

W terminalu SSH:

```bash
cd /share/Container/crafty/servers/<UUID>
ls mods/ | grep -i <nazwa-moda>      # podgląd
rm mods/<nazwa-moda>-*.jar           # usunięcie
ls mods/ | grep -i <nazwa-moda>      # weryfikacja - pusto
```

W Crafty: **Start** serwera, sprawdź log że wstał bez problemu.

### Krok 6 – Replikacja na produkcję

Powtarzasz Kroki 2-5 dla `TiliNakor` i `kTiliNakor`.

## Workflow dodania nowego moda

### Mod z Modrinth

**1. Sprawdź czy mod jest na Modrinth** i zanotuj slug (część URL, np. `iris` z `modrinth.com/mod/iris`).

**2. Dodaj mod do paczki testowej najpierw**

```bash
cd ~/Minecraft/minecraft-modpacks/fabric/TiliNakor_test
packwiz modrinth add <slug>
```

Packwiz:
- Wyszuka mod (czasem zapyta o wybór jeśli jest niejednoznaczny)
- Pobierze metadane
- Doda zależności jeśli potrzeba
- Utworzy `mods/<slug>.pw.toml`

**3. Sprawdź ustawienie `side`**

```bash
cat mods/<slug>.pw.toml
```

Side opcje:
- `client` – tylko klient (rendering, GUI, narzędzia jak FreeCam)
- `server` – tylko serwer (Servux, modyfikacje gameplay-only)
- `both` – obie strony (większość modów, biblioteki)

Modrinth zwykle dobrze oznacza. **Jeśli wymaga korekty**:

```bash
nano mods/<slug>.pw.toml
# zmień linię "side" na odpowiednią
packwiz refresh
```

**4. Test, propagacja, etc.** – jak w workflow aktualizacji (push → klient → serwer testowy → produkcja).

### Dodanie konkretnej wersji moda (Modrinth)

Domyślnie `packwiz modrinth add <slug>` bierze **najnowszą wersję**. Czasem 
trzeba **konkretnej** (np. starszej stable zamiast nowszej beta, jak Sodium 0.9.0 
zamiast 0.9.1-beta.2).

Składnia wymaga **`--project-id` ORAZ `--version-id`** (nie sluga). Komenda 
z samym slugiem + `--version-id` zwróci błąd "cannot be used with separately 
specified URL/slug".

```bash
packwiz modrinth add --project-id <project-id> --version-id <version-id>
```

**Jak znaleźć ID** – Modrinth API:

```bash
curl -s "https://api.modrinth.com/v2/project/<slug>/version" | python3 -m json.tool | grep -B2 "<filename-fragment>"
```

To wypluje fragment JSON gdzie `id` to **version-id**. W URL widać też **project-id**:
```
https://cdn.modrinth.com/data/<PROJECT-ID>/versions/<VERSION-ID>/<filename>.jar
```

Przykład – Sodium 0.9.0 dla Fabric 26.2:
- project-id: `AANobbMI`
- version-id: `3QgJXuSK`

Po dodaniu warto **pinować** żeby `packwiz update --all` nie cofał do najnowszej:

```bash
packwiz pin <slug>
```

### Mod z CurseForge

Wymaga klucza CF API ustawionego w `~/.zshrc` (`CURSEFORGE_API_KEY`).

```bash
packwiz curseforge add <slug>
```

⚠️ **Uwaga – pułapka z bibliotekami**

Mody z CF często wymagają zależności (np. Fabric API). Packwiz może **podmienić** istniejący wpis 
modu z Modrinth na wersję z CF. Po dodaniu moda z CF zawsze sprawdź czy biblioteki są nadal 
z Modrinth:

```bash
cat mods/fabric-api.pw.toml
```

Szukaj `mode = "metadata:curseforge"` – to znaczy że wpis został podmieniony. 
Naprawa:

```bash
packwiz remove fabric-api
packwiz modrinth add fabric-api
```

⚠️ **Uwaga – pułapka z ukrytymi zależnościami przy update CF**

Mody z CF **mogą zacząć wymagać nowych zależności w nowej wersji**, a packwiz tego NIE wykryje przy `packwiz update`.

Przykłady z migracji na 26.1.2:
- **Survival Fly 1.3.2** zaczął wymagać **YetAnotherConfigLib (YACL)**
- **Waystones 26.1.2.4** zaczął wymagać **Shogi** (nowa biblioteka)

Po update na nową wersję MC zawsze **uruchom klienta jako pierwszy test** – jeśli wyskoczy crash 
typu `Mod 'X' requires Y, which is missing` – dopisz brakującą zależność:

```bash
packwiz modrinth add <slug-zaleznosci>
```

I powtarzaj iteracyjnie aż klient odpali. Dopiero potem testuj serwer.

### Test moda

Po push:
1. Otwórz instancję `TiliNakor_test_auto` w Prismie – bootstrap pobierze nowy mod
2. Sprawdź w Mod Menu czy się wczytał
3. Jeśli `both` lub `server` – wgraj nowy mrpack na serwer testowy i wykonaj mrpack-install
4. Test w grze

### Replikacja na produkcję

Tę samą komendę `packwiz <site> add <slug>` wykonujesz w paczce `TiliNakor` i (jeśli dotyczy) 
`kTiliNakor`. Każda paczka ma swoje wpisy.

## Konfiguracja klienta (dla graczy)

Każdy gracz instaluje **Prism Launcher** i konfiguruje instancje z auto-update przez 
**packwiz-installer-bootstrap**. Mody pobierają się automatycznie, aktualizują się 
automatycznie przy każdej zmianie na GitHubie.

### Lista serwerów

| Serwer | Adres | Paczka |
|--------|-------|--------|
| **Pandora** (zamrożony survival) | `pandora.lan:25565` | TiliNakor |
| **TiliNakor** (główny survival) | `tilinakor.lan:25566` | TiliNakor |
| **kTiliNakor** (kreatywny) | `ktilinakor.lan:25567` | kTiliNakor |
| **kTiliNakor test** (testowy) | `ktilinakor.lan:25568` | TiliNakor_test |

⚠️ Adresy `.lan` działają tylko w **lokalnej sieci**. Jeśli grasz spoza domu, 
poproś admina o IP zewnętrzne.

### Krok 1 – Prism Launcher

Pobierz i zainstaluj z https://prismlauncher.org/  
Dostępny dla Windows, Mac, Linux.

Zaloguj się kontem Microsoft/Mojang.

### Krok 2 – Pobranie packwiz-installer-bootstrap

Pobierz najnowszą wersję z:  
https://github.com/packwiz/packwiz-installer-bootstrap/releases/latest

Plik: `packwiz-installer-bootstrap.jar` (~100 KB).

Zapisz w wygodnym miejscu (np. `~/Tools/` na Mac/Linux, `C:\Tools\` na Windows).

### Krok 3 – Utwórz instancję w Prism

W zależności od serwera na który chcesz grać, potrzebujesz odpowiedniej instancji:

| Instancja w Prismie | URL paczki | Dla serwerów |
|---|---|---|
| **TiliNakor** | `https://raw.githubusercontent.com/Nakorek/minecraft-modpacks/main/fabric/TiliNakor/pack.toml` | TiliNakor + Pandora |
| **kTiliNakor** | `https://raw.githubusercontent.com/Nakorek/minecraft-modpacks/main/fabric/kTiliNakor/pack.toml` | kTiliNakor |

Tworzenie instancji:

1. **Add Instance** → **Niestandardowe** (Custom)
2. **Nazwa**: dowolna (np. `TiliNakor`)
3. **Minecraft version**: `26.2` (lub aktualna z `pack.toml`)
4. **Mod Loader**: **Fabric** wersja `0.19.3` (lub najnowsza stabilna)
5. Create

### Krok 4 – Wrzuć bootstrap do folderu instancji

1. Prawym na instancję → **Folder instancji** (otwiera się Finder/Eksplorator)
2. Skopiuj `packwiz-installer-bootstrap.jar` do **głównego folderu instancji** (obok `.minecraft/`, NIE wewnątrz)

### Krok 5 – Skonfiguruj pre-launch command

1. Prawym na instancję → **Edytuj instancję**
2. Po lewej: **Ustawienia**
3. Zakładka **Własne komendy**
4. Zaznacz checkbox **"Nadpisz Ustawienia Globalne"**
5. W polu **"Komendy przed uruchomieniem"** wklej (URL z tabeli wyżej, odpowiedni dla instancji):

```
"$INST_JAVA" -jar "$INST_DIR/packwiz-installer-bootstrap.jar" <URL_PACZKI>
```

Przykład dla TiliNakor:
```
"$INST_JAVA" -jar "$INST_DIR/packwiz-installer-bootstrap.jar" https://raw.githubusercontent.com/Nakorek/minecraft-modpacks/main/fabric/TiliNakor/pack.toml
```

⚠️ **Forward slash** `/` w ścieżce – działa zarówno na Windows jak i Mac/Linux.

Zapisz.

⚠️ **Prism Launcher 11.x+** automatycznie wykrywa zmianę wersji MC i Fabric 
w `pack.toml` (np. po migracji MC w paczce) i przy uruchomieniu instancji 
pyta *"This modpack uses newer versions of Minecraft/Fabric"* → kliknij **Update**. 
Bootstrap i tak pobierze nowe mody, ale wersje MC i loadera Prism ogarnia sam.

Na starszym Prismie trzeba ręcznie zmieniać w **Edytuj instancję → Wersja**.

### Krok 6 – Pierwszy launch

Uruchom instancję. Bootstrap pobierze wszystkie mody (kilka MB każdy). 
Trwa to 2-5 minut przy pierwszym razie.

**⚠️ Antywirus może blokować pobieranie** niektórych modów (zwłaszcza Flashback, niektóre mody renderingowe). 
Jeśli zobaczysz okno z błędami pobierania:
- Anuluj launch
- Spróbuj ponownie (każda próba może udać się z innym zestawem modów)
- Albo wyłącz tymczasowo AV / dodaj wyjątek dla folderu instancji

### Krok 7 – Łączenie się z serwerem

Po pierwszym launchu gra startuje z modami. W Minecraft:
1. **Multiplayer** → **Add Server**
2. Wpisz adres serwera z tabeli na początku tej sekcji

Instancja `TiliNakor` obsługuje 2 serwery (TiliNakor + Pandora) – wystarczy dodać oba do listy serwerów w grze.

### Aktualizacje

Wszystkie aktualizacje pobierają się **automatycznie** przy każdym uruchomieniu instancji. 
Nic nie musisz robić ręcznie.

Jeśli bootstrap "nie zauważa" zmian mimo że wiesz że coś się zmieniło na GitHubie – 
**zamknij i otwórz Prism Launcher**.

## Migracja na nową wersję Minecrafta

Procedura sprawdzona przy migracjach 1.21.11 → 26.1.2 i 26.1.2 → 26.2.

### Krok 1 – Sprawdzenie kompatybilności (bez modyfikacji prawdziwej paczki!)

Zrób **kopię paczki** do eksperymentów:

```bash
cd ~/Minecraft/minecraft-modpacks/fabric
cp -R TiliNakor_test _migration_check
cd _migration_check
rm *.mrpack
```

Wymuś migrację na docelową wersję:

```bash
packwiz migrate minecraft <wersja>
# np. packwiz migrate minecraft 26.2
```

Packwiz zapyta o aktualizację loadera (zazwyczaj `Y`) i o aktualizację modów. 
**Odpowiedz `N` na pytanie o update modów** – chcemy tylko raport, nie modyfikacje.

Następnie sprawdź który mod ma update a który nie:

```bash
packwiz update --all
# odpowiedź N
```

Packwiz wypisze listę typu:
```
Updates found:
  ModA: stara -> nowa
  ModB: stara -> nowa
  Failed to check updates for ModC: no valid versions found
  ...
```

### Krok 2 – Mody "already up to date"

Niektóre mody (np. Euphoria Patches, Fabric Language Kotlin) wspierają **wiele wersji MC 
w jednym pliku `.jar`**. Packwiz powie o nich "already up to date" – to znaczy że są **kompatybilne 
z nową wersją MC bez aktualizacji**.

Aby sprawdzić każdy z nich indywidualnie:
```bash
packwiz update <slug>
```

### Krok 3 – Mody problematyczne

Mody z komunikatem **"Failed to check updates: no valid versions found"** nie mają wersji 
pod nową MC. Trzy ścieżki:

- **Czekaj** – większość modów dostaje update w 1-3 miesiące po nowej wersji
- **Zamiennik** – szukaj forka albo alternatywnego moda o podobnej funkcji
- **Wyrzucenie** – jeśli mod nie jest kluczowy

Przykład z migracji 26.2: Krypton (optymalizacja network) i Flower Map (mini-mapa kolory) 
nie miały wersji na 26.2 → usunięte z paczki, do dodania z powrotem gdy wyjdą wersje 
kompatybilne (zwykle 1-2 tygodnie po release MC).

### Krok 4 – Sprzątanie po teście

```bash
cd ~/Minecraft/minecraft-modpacks/fabric
rm -rf _migration_check
```

### Krok 5 – Decyzja o migracji

Migrujesz dopiero jak:
- Krytyczne mody mają update (lub masz zamiennik)
- 90%+ paczki działa pod nową MC

### Krok 6 – Faktyczna migracja (gdy gotowi)

Pełna procedura:
1. Usuń z paczki `TiliNakor_test` mody bez wsparcia nowej MC (`packwiz remove <slug>`)
2. `packwiz migrate minecraft <wersja>` na `TiliNakor_test`
3. `packwiz update --all` z `Y`
4. **Test klienta NAJPIERW** – uruchom Prism, zobacz czy startuje
5. Jeśli crash przez brakujące zależności (CF mody pociągające nowe biblioteki) – dopisz przez `packwiz modrinth add <slug>`. Iteracyjnie aż klient ruszy.
6. **Konflikty wersji między modami** (patrz niżej) – cofnij na starszą wersję problemowego moda + pin
7. Push → test na klientach i serwerze testowym
8. Jeśli OK → analogicznie na `TiliNakor` i `kTiliNakor`
9. Aktualizacja wszystkich produkcyjnych serwerów (mrpack-install + podmiana fabric-server jeśli loader się zmienił)

### Konflikt wersji modów po major MC bump

Mody renderingowe (Sodium, Iris) i inne synchronizujące się przez API mają 
**wzajemne wymagania wersji**. Po migracji MC bywa że jeden mod jest już zaktualizowany 
do wersji wymagającej nowej wersji drugiego, którego nowsza wersja jeszcze nie wyszła.

**Diagnoza** z crash log – Fabric Loader podaje precyzyjnie który mod wymaga 
której wersji którego innego:
```
Mod 'Sodium' 0.9.1-beta.2 is incompatible with version 1.11.1 or earlier of 
mod 'Iris', yet a conflicting version is present: 1.11.1!
```

**Rozwiązanie**:
- Sprawdź na Modrinth alternatywne wersje moda który jest "zbyt nowy"
- Cofnij na **stable** zamiast bety (jeśli dostępna)
- Użyj `--project-id` + `--version-id` żeby dodać konkretną wersję
- **Pinuj** żeby `packwiz update --all` nie cofał z powrotem

Historyczny przykład: przy migracji 26.2 Sodium 0.9.1-beta.2 niekompatybilne 
z Iris 1.11.1. Cofnęliśmy Sodium na 0.9.0 stable (`--project-id AANobbMI --version-id 3QgJXuSK`) 
i zapinowali. Workflow zajął 5 minut zamiast czekać kilka dni aż wyjdzie Iris 1.11.2.

### Workflow dla "wielowersyjnych" modów

Jeśli używasz mody które wspierają wiele wersji MC (Fabric Language Kotlin, niektóre 
shadery), warto pamiętać że `packwiz update <slug>` po migracji MC **nie zaktualizuje ich** 
mimo że są zgodne. To OK – działają nadal.

## Migracja zarządzania na nowy komputer

Przy zmianie maszyny (np. PC → Mac) potrzebujesz:

1. **packwiz** zainstalowany lokalnie
2. **Git** i sposób auth do GitHuba (GitHub Desktop najprostsze, alternatywa: PAT + osxkeychain)
3. **Klucz CF API** w zmiennej środowiskowej
4. **Sklon repo** z GitHuba

### Mac – instalacja packwiz

Packwiz nie ma binarek na GitHubie, trzeba zbudować ze źródeł (potrzebne **Go**):

```bash
brew install go
go install github.com/packwiz/packwiz@latest
```

Binarka ląduje w `~/go/bin/packwiz`. Dodaj do PATH w `~/.zshrc`:

```bash
export PATH="$HOME/go/bin:$PATH"
```

### Mac – CF API key

W `~/.zshrc`:

```bash
export CURSEFORGE_API_KEY='twoj_klucz_tutaj'
```

⚠️ Pojedyncze cudzysłowy (`'...'`) – chroni przed interpretacją `$` i innych znaków specjalnych w kluczu.

Po zmianie `source ~/.zshrc`, sprawdź `echo $CURSEFORGE_API_KEY`.

### Mac – GitHub Desktop (opcja A)

Pobierz z https://desktop.github.com/. Po instalacji **Sign in** jako Nakorek → przeglądarka OAuth → autoryzacja. To załatwia credentials – kolejne commit/push w GH Desktop działają od ręki.

### Mac – PAT + osxkeychain dla Terminala (opcja B, dla skryptów)

```bash
git config --global credential.helper osxkeychain
```

Wygeneruj **Personal Access Token (classic)** na https://github.com/settings/tokens 
z scope `repo`. Skopiuj token i zapisz lokalnie (pokazuje się tylko raz!).

Przy pierwszym `git push` z Terminala wpisz username = Nakorek i token jako hasło – 
keychain zapisze, kolejne pushe będą działać bez pytania.

Obie opcje mogą działać równolegle.

### Mac – klon repo

W GitHub Desktop: **File → Clone repository → URL**, wpisz `https://github.com/Nakorek/minecraft-modpacks`, wybierz `~/Minecraft/` jako local path.

Lub w Terminalu:
```bash
mkdir -p ~/Minecraft
cd ~/Minecraft
git clone https://github.com/Nakorek/minecraft-modpacks.git
```

### Mac – różnice komend vs Windows PowerShell

| PowerShell (Windows) | bash (Mac) |
|---|---|
| `type plik.toml` | `cat plik.toml` |
| `dir` | `ls` |
| `del plik` | `rm plik` |
| `Copy-Item -Recurse src dst` | `cp -R src dst` |
| `Remove-Item -Recurse -Force dir` | `rm -rf dir` |
| `notepad plik` | `nano plik` (lub `code plik` w VSCode) |
| `findstr /S /I "wzor" mods\*.pw.toml` | `grep -i "wzor" mods/*.pw.toml` |
| Backslash `\` w ścieżkach | Forward slash `/` |
| `C:\Minecraft\minecraft-modpacks` | `~/Minecraft/minecraft-modpacks` |

⚠️ Dodatkowo: **zsh interpretuje `?` w URL jako pattern**. URL z parametrami query 
(np. `https://example.com/path?key=value`) trzeba wkleić **w cudzysłowach** albo 
go shell przerwie z `zsh: no matches found`. W przeglądarce nieobjawowy, w Terminalu wymaga uwagi.

## Troubleshooting

### Klient nie pobiera aktualizacji mimo że na GitHubie jest nowsza wersja

**Najczęstszy powód**: Prism Launcher trzyma stan w pamięci.

**Rozwiązanie**: zamknij całkowicie Prism Launcher i otwórz ponownie. Bootstrap odświeży stan.

### Bootstrap kończy z błędem "Unable to access jarfile"

Komenda pre-launch używa złej ścieżki do `packwiz-installer-bootstrap.jar`.

**Sprawdź**:
- Plik `packwiz-installer-bootstrap.jar` jest w **głównym folderze instancji** (obok `.minecraft/`, NIE wewnątrz)
- Komenda używa forward slash `/` zamiast backslash `\` (działa na Windows i Mac)
- Pełna komenda powinna wyglądać: `"$INST_JAVA" -jar "$INST_DIR/packwiz-installer-bootstrap.jar" <URL>`

### Bootstrap pomija dużą aktualizację za pierwszym razem

Przy migracji MC z dużą liczbą zmian (wszystkie mody zmieniają wersje) bootstrap 
**czasem nie kończy** pobierania za pierwszym podejściem. Druga próba zwykle ratuje.

Jeśli kilka prób się sypie – wyłącz/włącz Prism Launcher, restart bootstrap.

Przykład z migracji 26.2 produkcyjnej: pierwszy launch po migracji wykrył wszystkie 
stare wersje modów jako niekompatybilne (bootstrap nie pobrał nowych); drugi launch 
zassał wszystko poprawnie.

### Bootstrap pokazuje "Failed file downloads" – kilka modów nie pobranych

Antywirus rwie połączenia TCP do CDN Modrinth podczas masowego pobierania.

**Rozwiązania (w kolejności)**:
1. **Cancel launch** → ponów (każda próba pobiera inne losowe mody, za 2-3 razem zwykle wszystko schodzi)
2. **Wyłącz tymczasowo AV** (Windows Defender → Ochrona w czasie rzeczywistym → wyłącz), uruchom, włącz AV po pobraniu
3. **Dodaj wyjątek w AV** dla folderu instancji albo dla domeny `cdn.modrinth.com`

Szczególnie problemowe mody u części AV: **Flashback** (mod do nagrywania – AV może go traktować jak rejestrator wejść).

### Crash klienta po migracji MC: "Mod X requires Y, which is missing"

Typowy przy migracji wersji MC (np. 1.21.11 → 26.1.2). Mody z CF mogą zacząć wymagać nowych zależności, których packwiz NIE wykrywa automatycznie.

**Rozwiązanie**: dopisz brakującą zależność do paczki:
```bash
cd ~/Minecraft/minecraft-modpacks/fabric/TiliNakor_test
packwiz modrinth add <slug-brakujacego-moda>
```

Push, ponów uruchomienie klienta. Iteracyjnie aż klient odpali.

Historyczne przykłady (przy migracji 26.1.2):
- Survival Fly potrzebował YACL
- Waystones potrzebowało Shogi

### Crash klienta po migracji MC: konflikt wersji między modami

Spójrz na crash log – Fabric Loader podaje precyzyjnie który mod wymaga której 
wersji którego innego. Typowo Sodium ↔ Iris (renderery synchronizujące wersje API).

**Naprawa**: cofnięcie któregoś z modów na starszą stable + pin – patrz sekcja 
"Pinowanie wersji moda" i "Dodanie konkretnej wersji moda (Modrinth)".

### Mod z CurseForge zastąpił bibliotekę z Modrinth

Problem objawia się: po `packwiz curseforge add <mod>` plik np. `mods/fabric-api.pw.toml` 
ma w środku `mode = "metadata:curseforge"` zamiast `[update.modrinth]`.

**Naprawa**:
```bash
packwiz remove <slug>
packwiz modrinth add <slug>
```

Zawsze sprawdzaj plik biblioteki po dodaniu moda z CF.

### Eksport mrpacka pomija jakiś mod – "Download failed"

Najczęściej **antywirus** blokuje konkretny plik (np. Flashback). Mrpack zostaje z tym 
modem pominiętym.

**To NIE psuje pracy** – bootstrap na kliencie pobiera mody bezpośrednio z Modrinth 
(omijając lokalny cache packwiz) i często radzi sobie tam gdzie eksport zawiódł.

Jeśli mod jest client-only i klient go pobiera – nie martw się. Jeśli mod jest serwerowy 
i nie wchodzi do mrpacka – dodaj wyjątek w AV i ponów eksport.

### Mrpack-install nie usuwa starych modów

Mrpack-install **pobiera nowe** i **wypakowuje overrides**, ale **nie usuwa modów** 
których nie ma w mrpacku.

Przy **podmianie moda** (np. usunięcie Carpeta) **należy** ręcznie 
wyczyścić folder przed instalacją:

```bash
cd /share/Container/crafty/servers/<UUID>
rm mods/*.jar
# potem mrpack-install
```

Przy **zwykłej aktualizacji wersji moda** czyszczenie też jest zalecane (mrpack-install nadpisze 
pliki o tej samej nazwie, ale stare wersje z innymi nazwami zostaną).

### Mrpack-install zostawia duplikat fabric-server.jar

Mrpack-install zawsze pobiera świeży `fabric-server-mc.<MC>-loader.<L>-launcher.<W>.jar`, nawet jak nie zmieniła się wersja MC. Po instalacji są **dwa pliki**:
- `fabric-server.jar` – aktualny (z poprzedniej migracji)
- `fabric-server-mc.X-loader.Y-launcher.Z.jar` – świeżo pobrany, **duplikat**

Jeśli wersja MC ta sama (tylko aktualizacja modów) – **usuń duplikat**:

```bash
cd /share/Container/crafty/servers/<UUID>
ls -la fabric-server*.jar
rm fabric-server-mc.<MC>-loader.<L>-launcher.<W>.jar
ls -la fabric-server*.jar
```

Jeśli zmieniła się wersja MC – musisz świadomie podmienić (patrz "Serwer nie startuje po mrpack-install").

### Serwer nie startuje po mrpack-install (zmiana wersji MC)

Sprawdź czy `fabric-server.jar` został podmieniony na nową wersję:
```bash
ls -la /share/Container/crafty/servers/<UUID>/fabric-server*.jar
```

Powinieneś widzieć **jeden plik** `fabric-server.jar` z aktualną datą. 

Jeśli widzisz **dwa pliki** (stary `fabric-server.jar` + nowy `fabric-server-mc.X.X.X-loader.Y.Y.Y-launcher.Z.Z.Z.jar`) – musisz ręcznie podmienić:

⚠️ **Pułapka z `mv` – wykonuj każdą komendę osobno**, weryfikując stan między nimi. Łatwo o pomyłkę która nadpisze nowy plik starym.

```bash
cd /share/Container/crafty/servers/<UUID>
ls -la fabric-server*.jar
```

Sprawdź że widzisz dwa pliki. Potem:

```bash
mv fabric-server.jar fabric-server.jar.old_<opis>
```

Potem:
```bash
mv fabric-server-mc.<MC>-loader.<L>-launcher.<W>.jar fabric-server.jar
```

Potem:
```bash
sudo chmod 777 fabric-server.jar
ls -la fabric-server*
```

(ostatnie `ls` bez `.jar` na końcu pattern, żeby widzieć też pliki `.old_*`)

### Cofnięcie aktualizacji

Każda aktualizacja paczki w gicie jest cofalna przez **git revert** w GitHub Desktop 
(lub z Terminala: `git revert <hash-commita> && git push`).

Klienci dostaną stary stan przy następnym uruchomieniu instancji (bootstrap synchronizuje).

Serwery wymagają ręcznej akcji – wgranie poprzedniego mrpacka albo przywrócenie backupu z Crafty.