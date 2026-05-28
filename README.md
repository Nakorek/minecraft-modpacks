# Minecraft Modpacks – konfiguracja serwerów TiliNakor

Repozytorium zawiera paczki modów (packwiz) dla 4 serwerów Minecraft Fabric 
zarządzanych przez Crafty Controller na QNAP-ie. Centralna kolekcja modów 
z automatyczną dystrybucją do klientów (przez packwiz-installer-bootstrap) 
i synchronizacją serwerów (przez mrpack-install).

**Aktualna wersja**: Minecraft 1.21.11, Fabric Loader 0.19.2

## Serwery

| Serwer | Charakter | Paczka |
|--------|-----------|--------|
| **TiliNakor** | Survival główny, aktywny | `fabric/TiliNakor/` |
| **Pandora** | Survival zamrożony (ForeverWorld) | `fabric/TiliNakor/` (ta sama) |
| **TiliNakor test** | Testowy do eksperymentów | `fabric/TiliNakor_test/` |
| **kTiliNakor** | Kreatywny, do buildowania | `fabric/kTiliNakor/` |

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

## Workflow aktualizacji modów

### Standardowa aktualizacja (co tydzień/dwa)

**1. Sprawdź dostępne aktualizacje (w paczce testowej najpierw!)**

```powershell
cd C:\Minecraft\minecraft-modpacks\fabric\TiliNakor_test
packwiz update --all
```

Packwiz pokaże listę updateów i zapyta o potwierdzenie. Odpowiedz `Y` po przeglądnięciu.

**2. Eksportuj mrpack i pushnij na GitHuba**

```powershell
packwiz modrinth export
```

W GitHub Desktop: commit z opisem typu *"Aktualizacja modów X, Y, Z"* → Push origin.

**3. Test na kliencie**

Odpal w Prismie instancję `TiliNakor_test_auto`. Bootstrap zaktualizuje mody automatycznie. 
Zagraj chwilę, sprawdź czy nic się nie sypie.

**Jeśli Prism nie wykrywa zmian** – zamknij i otwórz Prism Launcher ponownie.

**4. Test na serwerze testowym (jeśli były aktualizacje serwerowych modów)**

Wgraj mrpack na QNAP do folderu testowego serwera (przez File Station):
```
/Container/crafty/servers/fc17ba3e-b41b-4fd3-b012-52749bd58833/
```

W PuTTY na QNAP:
```bash
docker exec -it crafty_container bash
/crafty/import/tools/mrpack-install-linux /crafty/servers/fc17ba3e-b41b-4fd3-b012-52749bd58833/TiliNakor_test-1.0.0.mrpack --server-dir /crafty/servers/fc17ba3e-b41b-4fd3-b012-52749bd58833
exit
```

Start serwera w Crafty, test w grze.

**5. Replikacja na paczki produkcyjne**

Jeśli test wypadł OK – powtarzasz kroki 1-2 dla paczki `TiliNakor` (która obsługuje również Pandorę) i `kTiliNakor`.

Klienci dostają update przy następnym uruchomieniu instancji (bootstrap synchronizuje).

**6. Aktualizacja serwerów produkcyjnych** (jeśli zmiany dotyczą serwerowych modów)

W PuTTY, dla każdego serwera produkcyjnego:
- TiliNakor: UUID `5071df24-5a62-48d9-b038-c910d088898f`
- Pandora: UUID `7d468085-bc02-4e7b-b53a-54ad9f4b03e3`
- kTiliNakor: UUID `eff8a0a1-9645-4d4b-a1d5-74fe9bfabf30`

```bash
# Zatrzymaj serwer w Crafty
# Backup modów (opcjonalnie, ale zalecane przy większych zmianach)
cd /share/Container/crafty/servers/<UUID>
cp -r mods mods_backup_$(date +%Y%m%d)

# Wgraj odpowiedni mrpack do folderu serwera (File Station albo cp z innego serwera)
# Jeśli zmiana to TYLKO aktualizacja istniejących modów - nie czyść folderu mods/
# Jeśli zmiana to PODMIANA modów (usunięcie/wymiana) - wyczyść:
rm mods/*.jar

# Mrpack-install
docker exec -it crafty_container bash
/crafty/import/tools/mrpack-install-linux /crafty/servers/<UUID>/<paczka>.mrpack --server-dir /crafty/servers/<UUID>
exit

# Start serwera w Crafty
```

### Mody klient-only

Aktualizacje modów oznaczonych `side = "client"` (np. Sodium, Iris, Litematica, Mod Menu) 
**nie wymagają żadnych operacji na serwerze**. Klienci dostaną update przez bootstrap.

## Workflow dodania nowego moda

### Mod z Modrinth

**1. Sprawdź czy mod jest na Modrinth** i zanotuj slug (część URL, np. `iris` z `modrinth.com/mod/iris`).

**2. Dodaj mod do paczki testowej najpierw**

```powershell
cd C:\Minecraft\minecraft-modpacks\fabric\TiliNakor_test
packwiz modrinth add <slug>
```

Packwiz:
- Wyszuka mod (czasem zapyta o wybór jeśli jest niejednoznaczny)
- Pobierze metadane
- Doda zależności jeśli potrzeba
- Utworzy `mods/<slug>.pw.toml`

**3. Sprawdź ustawienie `side`**

```powershell
type mods\<slug>.pw.toml
```

Side opcje:
- `client` – tylko klient (rendering, GUI, narzędzia jak FreeCam)
- `server` – tylko serwer (Servux, modyfikacje gameplay-only)
- `both` – obie strony (większość modów, biblioteki)

Modrinth zwykle dobrze oznacza. **Jeśli wymaga korekty**:

```powershell
notepad mods\<slug>.pw.toml
# zmień linię "side" na odpowiednią
packwiz refresh
```

**4. Test, propagacja, etc.** – jak w workflow aktualizacji (push → klient → serwer testowy → produkcja).

### Mod z CurseForge

Wymaga klucza CF API ustawionego w zmiennej środowiskowej `CURSEFORGE_API_KEY` (już ustawione na stałe w systemie).

```powershell
packwiz curseforge add <slug>
```

⚠️ **Uwaga – pułapka z bibliotekami**

Mody z CF często wymagają zależności (np. Fabric API). Packwiz może **podmienić** istniejący wpis 
modu z Modrinth na wersję z CF. Po dodaniu moda z CF zawsze sprawdź czy biblioteki są nadal 
z Modrinth:

```powershell
type mods\fabric-api.pw.toml
```

Szukaj `mode = "metadata:curseforge"` – to znaczy że wpis został podmieniony. 
Naprawa:

```powershell
packwiz remove fabric-api
packwiz modrinth add fabric-api
```

### Test moda

Po push:
1. Otwórz instancję `TiliNakor_test_auto` w Prismie – bootstrap pobierze nowy mod
2. Sprawdź w Mod Menu czy się wczytał
3. Jeśli `both` lub `server` – wgraj nowy mrpack na serwer testowy i wykonaj mrpack-install
4. Test w grze

### Replikacja na produkcję

Tę samą komendę `packwiz <site> add <slug>` wykonujesz w paczce `TiliNakor` i (jeśli dotyczy) 
`kTiliNakor`. Każda paczka ma swoje wpisy.

W przyszłości (Etap 8.3) można zautomatyzować propagację moda między paczkami skryptem.

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

Zapisz w wygodnym miejscu (np. `C:\Tools\` na Windows, `~/Tools/` na Mac/Linux).

### Krok 3 – Utwórz instancję w Prism

W zależności od serwera na który chcesz grać, potrzebujesz odpowiedniej instancji:

| Instancja w Prismie | URL paczki | Dla serwerów |
|---|---|---|
| **TiliNakor** | `https://raw.githubusercontent.com/Nakorek/minecraft-modpacks/main/fabric/TiliNakor/pack.toml` | TiliNakor + Pandora |
| **kTiliNakor** | `https://raw.githubusercontent.com/Nakorek/minecraft-modpacks/main/fabric/kTiliNakor/pack.toml` | kTiliNakor |

Tworzenie instancji:

1. **Add Instance** → **Niestandardowe** (Custom)
2. **Nazwa**: dowolna (np. `TiliNakor`)
3. **Minecraft version**: `1.21.11`
4. **Mod Loader**: **Fabric** wersja `0.19.2` (lub najnowsza stabilna)
5. Create

### Krok 4 – Wrzuć bootstrap do folderu instancji

1. Prawym na instancję → **Folder instancji** (otwiera się Eksplorator/Finder)
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

Zapisz.

### Krok 6 – Pierwszy launch

Uruchom instancję. Bootstrap pobierze wszystkie mody (39 sztuk, kilka MB każdy). 
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

Procedura sprawdzona przy testowym podejściu do 26.1.2 (paczka pozostała na 1.21.11 
ze względu na brak aktualizacji moda Carpet).

### Krok 1 – Sprawdzenie kompatybilności (bez modyfikacji prawdziwej paczki!)

Zrób **kopię paczki** do eksperymentów:

```powershell
cd C:\Minecraft\minecraft-modpacks\fabric
Copy-Item -Path TiliNakor_test -Destination _migration_check -Recurse
cd _migration_check
del *.mrpack
```

Wymuś migrację na docelową wersję:

```powershell
packwiz migrate minecraft <wersja>
# np. packwiz migrate minecraft 26.1.2
```

Packwiz zapyta o aktualizację loadera (zazwyczaj `Y`) i o aktualizację modów. 
**Odpowiedz `N` na pytanie o update modów** – chcemy tylko raport, nie modyfikacje.

Następnie sprawdź który mod ma update a który nie:

```powershell
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
```powershell
packwiz update <slug>
```

### Krok 3 – Mody problematyczne

Mody z komunikatem **"Failed to check updates: no valid versions found"** nie mają wersji 
pod nową MC. Trzy ścieżki:

- **Czekaj** – większość modów dostaje update w 1-3 miesiące po nowej wersji
- **Zamiennik** – szukaj forka albo alternatywnego moda o podobnej funkcji
- **Wyrzucenie** – jeśli mod nie jest kluczowy

### Krok 4 – Sprzątanie po teście

```powershell
cd C:\Minecraft\minecraft-modpacks\fabric
Remove-Item -Path _migration_check -Recurse -Force
```

### Krok 5 – Decyzja o migracji

Migrujesz dopiero jak:
- Krytyczne mody mają update (lub masz zamiennik)
- 90%+ paczki działa pod nową MC

### Krok 6 – Faktyczna migracja (gdy gotowi)

Pełna procedura:
1. `packwiz migrate minecraft <wersja>` na `TiliNakor_test`
2. `packwiz migrate loader` (jeśli nie zrobione przy poprzedniej komendzie)
3. `packwiz update --all` z `Y`
4. Push → test na klientach i serwerze testowym
5. Jeśli OK → analogicznie na `TiliNakor` i `kTiliNakor`
6. Aktualizacja wszystkich produkcyjnych serwerów

### Workflow dla "wielowersyjnych" modów

Jeśli używasz mody które wspierają wiele wersji MC (Fabric Language Kotlin, niektóre 
shadery), warto pamiętać że `packwiz update <slug>` po migracji MC **nie zaktualizuje ich** 
mimo że są zgodne. To OK – działają nadal.

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

### Bootstrap pokazuje "Failed file downloads" – kilka modów nie pobranych

Antywirus rwie połączenia TCP do CDN Modrinth podczas masowego pobierania.

**Rozwiązania (w kolejności)**:
1. **Cancel launch** → ponów (każda próba pobiera inne losowe mody, za 2-3 razem zwykle wszystko schodzi)
2. **Wyłącz tymczasowo AV** (Windows Defender → Ochrona w czasie rzeczywistym → wyłącz), uruchom, włącz AV po pobraniu
3. **Dodaj wyjątek w AV** dla folderu instancji albo dla domeny `cdn.modrinth.com`

Szczególnie problemowe mody u części AV: **Flashback** (mod do nagrywania – AV może go traktować jak rejestrator wejść).

### Mod z CurseForge zastąpił bibliotekę z Modrinth

Problem objawia się: po `packwiz curseforge add <mod>` plik np. `mods/fabric-api.pw.toml` 
ma w środku `mode = "metadata:curseforge"` zamiast `[update.modrinth]`.

**Naprawa**:
```powershell
packwiz remove <slug>
packwiz modrinth add <slug>
```

Zawsze sprawdzaj plik biblioteki po dodaniu moda z CF.

### Eksport mrpacka pomija jakiś mod – "Download failed"

Najczęściej **antywirus** blokuje konkretny plik (np. Flashback). Mrpack zostaje z tym 
modem pominiętym.

**To NIE psuje pracy** – bootstrap na kliencie pobiera mody bezpośrednio z Modrinth 
(omijając lokalny cache packwiz) i często radzi sobie tam gdzie eksport zawiódł.

Jeśli mod jest client-only i klient go pobiera – nie martw się. Jeśli mod jest serverowy 
i nie wchodzi do mrpacka – dodaj wyjątek w AV i ponów eksport.

### Mrpack-install nie usuwa starych modów

Mrpack-install **pobiera nowe** i **wypakowuje overrides**, ale **nie usuwa modów** 
których nie ma w mrpacku.

Przy **podmianie moda** (np. usunięcie Carpeta i dodanie TIS Carpeta) **należy** ręcznie 
wyczyścić folder przed instalacją:

```bash
cd /share/Container/crafty/servers/<UUID>
rm mods/*.jar
# potem mrpack-install
```

Przy **zwykłej aktualizacji wersji moda** czyszczenie nie jest konieczne – mrpack-install 
nadpisze pliki o tej samej nazwie, a stare wersje z innymi nazwami (np. `mod-1.0.jar` → 
`mod-2.0.jar`) trzeba potem ręcznie posprzątać.

### Pierwsza komenda CurseForge prosi o klucz API

Klucz CF API powinien być w zmiennej środowiskowej `CURSEFORGE_API_KEY`. 

**Sprawdzenie**:
```powershell
$env:CURSEFORGE_API_KEY
```

Powinno wyświetlić twój klucz.

**Jeśli pusty** – ustaw na stałe:
```powershell
[System.Environment]::SetEnvironmentVariable('CURSEFORGE_API_KEY', 'TWÓJ_KLUCZ', 'User')
```

Klucz uzyskasz z https://console.curseforge.com/ (zakładka API Keys).

### Serwer nie startuje po mrpack-install

Sprawdź czy `fabric-server.jar` został podmieniony na nową wersję:
```bash
ls -la /share/Container/crafty/servers/<UUID>/fabric-server*.jar
```

Powinieneś widzieć **jeden plik** `fabric-server.jar` z aktualną datą. 

Jeśli widzisz **dwa pliki** (stary `fabric-server.jar` + nowy `fabric-server-mc.X.X.X-loader.Y.Y.Y-launcher.Z.Z.Z.jar`) – musisz ręcznie podmienić:

```bash
cd /share/Container/crafty/servers/<UUID>
mv fabric-server.jar fabric-server.jar.old
mv fabric-server-mc.*.jar fabric-server.jar
sudo chmod 777 fabric-server.jar
```

### Cofnięcie aktualizacji

Każda aktualizacja paczki w gicie jest cofalna przez **git revert** w GitHub Desktop.

Klienci dostaną stary stan przy następnym uruchomieniu instancji (bootstrap synchronizuje).

Serwery wymagają ręcznej akcji – wgranie poprzedniego mrpacka albo przywrócenie backupu 
`mods_backup_RRRRMMDD`.
