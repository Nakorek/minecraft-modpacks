# Minecraft modpacks

Repozytorium packwiz dla serwerów Minecraft zarządzanych przez Crafty na QNAP.
Klienci Prism pobierają listę modów z GitHuba przez `packwiz-installer-bootstrap`.

## Aktywne paczki i serwery

| Serwer | Paczka | Crafty UUID | Port |
| --- | --- | --- | --- |
| TiliNakor | `fabric/TiliNakor` | `5071df24-5a62-48d9-b038-c910d088898f` | 25566 |
| Pandora | `fabric/TiliNakor` | `7d468085-bc02-4e7b-b53a-54ad9f4b03e3` | 25565 |
| TiliNakor test | `fabric/TiliNakor_test` | `fc17ba3e-b41b-4fd3-b012-52749bd58833` | 25568 |
| Scadrial | `neoforge/scadrial` | `17edf8a6-efd8-4a03-ba4e-592458e0b309` | 25569 |
| Roshar | ATM10A 0.7.1 | `ffe9fc17-84bf-4077-941b-00d485b44682` | 25570 |

Stare światy Roshar i kTiliNakor zostały wycofane i usunięte z Crafty.
Nowy Roshar to osobna instancja ATM10A bez migracji świata. Historia starej
konfiguracji pozostaje w Git.

## Poradniki do Rosharu

- [Colony Report na Rosharze](docs/roshar/colony-report.md) opisuje crafting,
  postęp budów, wykres dostaw i filtrowanie po budynku.
- [MineColonies — menu bez mleka i minimalne zapasy](docs/roshar/minecolonies-menu-i-zapasy.md):
  dziewięć dań dla Wise Peak i gotowa rozpiska składników dla kuchni i piekarni.
- [Unobtainium Arcanist — trzy zestawy nici](docs/roshar/vibranium-arcanist-nici.md):
  pełne rozpiski slotów dla walki mieszanej, eksploracji i trudniejszych walk,
  opisy efektów, porównanie oraz wspólna lista nici do przygotowania.

## ATM10A

`neoforge/atm10a` zawiera listę modów klienta importowaną z oficjalnego
`ATM10AERO-0.7.1.zip`: Minecraft `1.21.1`, NeoForge `21.1.250`.
Wersje modów z paczki są przypięte do wydania 0.7.1.
Dodatkowo dodaliśmy Freecam 1.3.0, Gamma Tweaks 1.0.0 oraz Bobby ReNeoForged 5.2.4-0.4 tylko dla klientów.
Nowy serwer Roshar ma seed `-919282885`, ustawiony przed pierwszym startem.
Adres serwera w sieci lokalnej: `roshar.lan:25570`.

Paczka w tym repo śledzi **mody, pakiety zasobów i własne skrypty
integracyjne KubeJS**. Oficjalne konfiguracje, zadania, skrypty KubeJS i inne pliki
paczki pochodzą z oficjalnego ZIP-a importowanego do Prisma. Zmiany tych plików
przy kolejnych wydaniach ATM10A wymagają importu
nowego oficjalnego ZIP-a; sam bootstrap aktualizuje pliki śledzone w packwiz.
Nie publikujemy kopii plików ATM Team w tym repo.

### Network Tool w Pattern Providerach

Poprawka dodaje brakujący panel schowka, który powodował rozłączenie po otwarciu
Pattern Providera z Network Tool w ekwipunku. Packwiz pobiera pakiet
`config/openloader/packs/expanded-ae-network-tool-fix.zip`, a OpenLoader włącza go
automatycznie przy starcie klienta. Wystarczy ponownie uruchomić grę w Prism.

### Instalacja ATM10A w Prism Launcherze

1. Pobierz oficjalny plik klienta `ATM10AERO-0.7.1.zip` z
   [CurseForge](https://www.curseforge.com/minecraft/modpacks/all-the-mods-10-aeronautics/files/9022977).
2. W Prism wybierz **Dodaj instalację → Importuj** i wskaż ZIP bez rozpakowywania.
3. Skopiuj `packwiz-installer-bootstrap.jar` do głównego folderu instancji,
   obok `.minecraft/`. Pobierz go z
   [wydań packwiz-installer-bootstrap](https://github.com/packwiz/packwiz-installer-bootstrap/releases/latest).
4. W ustawieniach instancji włącz własne komendy i ustaw komendę przed startem:

   ```text
   "$INST_JAVA" -jar "$INST_DIR/packwiz-installer-bootstrap.jar" https://raw.githubusercontent.com/Nakorek/minecraft-modpacks/main/neoforge/atm10a/pack.toml
   ```

5. Przydziel klientowi co najmniej 8 GiB RAM i uruchom grę. Bootstrap porówna
   stan instancji z listą w Git: doda, zaktualizuje lub usunie śledzone mody.

Instancja Scadrial używa analogicznego adresu z `/neoforge/scadrial/pack.toml`.
TiliNakor i Pandora dzielą paczkę `/fabric/TiliNakor/pack.toml`.

### Aktualizacje ATM10A

Najpierw testuj nową wersję oficjalnej paczki osobno. Po zatwierdzeniu wersji
ponownie importuj jej ZIP przez packwiz do pustego katalogu roboczego, porównaj
metadane modów z `neoforge/atm10a`, skopiuj nowe metadane, uruchom `packwiz
refresh`, a następnie przetestuj klienta. Po `git push` gracze dostaną nową
listę przy uruchomieniu Prisma. Zaktualizuj również oficjalne pliki serwera do
tej samej wersji i konfiguracje klientów z oficjalnego ZIP-a.

Roshar jest **nową instancją Crafty** z oficjalnego pakietu serwerowego ATM10A
0.7.1, NeoForge `21.1.250` i Java 21. Korzysta z portu `25570` oraz katalogu
`/share/Container/crafty/servers/ffe9fc17-84bf-4077-941b-00d485b44682`.
Seed wpisano w `server.properties` przed pierwszym wygenerowaniem świata.
Aktualizacje serwera wymagają oficjalnego pakietu serwerowego w tej samej
wersji co klient; `update-server-neoforge.sh` nadal obsługuje tylko Scadrial.

### MineColonies na Rosharze

Do ATM10A 0.7.1 dodano MineColonies `1.1.1403`, Multi-Piston `1.2.58`
i TownTalk `1.2.0` na klientach oraz serwerze. Pozostawiono biblioteki z
oficjalnej paczki: Structurize `1.0.832`, BlockUI `1.0.212` i Domum
Ornamentum `1.0.236`. Minecraft `1.21.1` i NeoForge `21.1.250` bez zmian.

Klienci pobierają te trzy dodatki przez istniejący bootstrap packwiz w Prism.
Przy ponownym imporcie oficjalnej paczki zachowaj również te dodatkowe mody.
Przed instalacją sprawdzono start na osobnym pustym świecie z modami,
konfiguracją i skryptami serwera Roshar.

### Style Shogun, Byzantine i Nile na Rosharze

Dodano [Byzantine Styles Pack 51.1](https://www.curseforge.com/minecraft/mc-mods/byzantine-styles-pack-for-minecolonies/files/9002815)
autorstwa Spumantii: plik `Byzantine-1.21.1-51.1.jar`, CurseForge projekt
`974855`, plik `9002815`. Pakiet udostępnia **Shogun 23.4** (1412 schematów),
`Byzantine_for_1.20`, `Nile` oraz dodatkowy, oznaczony przez autora jako testowy
`Rebel_Base`. Minecraft, NeoForge, MineColonies i biblioteki pozostają
w dotychczasowych wersjach.

Pakiet jest zainstalowany na serwerze. Prism pobiera tę samą wersję przez
istniejący bootstrap packwiz. W Build Tool można wybrać Shogun do nowych
budów i zlecanych przebudów. Samo dodanie schematów nie przebudowuje kolonii.
Przy ponownym imporcie lub aktualizacji oficjalnej paczki zachowaj ten dodatek.

Przed wdrożeniem sprawdzono start na osobnym pustym świecie i potwierdzono
wczytanie czterech pakietów przez Structurize oraz odczyt schematów chaty
budowniczego i ratusza Shogun. [Wynik próby](docs/compatibility/roshar-shogun-2026-11-04.json).

### Style Tropical i Steampunk na Rosharze

Dodatek [Stylecolonies 1.15.68](https://www.curseforge.com/minecraft/mc-mods/stylecolonies/files/9447179)
zawiera **Tropical 2.0** (307 schematów) oraz **Steampunk 127** (562 schematy).
Plik: `stylecolonies-1.15.68-1.21.1.jar`, CurseForge projekt `827507`, plik
`9447179`. Dodatek zawiera również inne pakiety stylów; część z nich wymaga
opcjonalnych modów. Tropical i Steampunk korzystają z bibliotek już obecnych
na Rosharze: MineColonies, Structurize i Domum Ornamentum.

Wersja jest przypięta w packwiz i przeznaczona dla Minecraft `1.21.1` oraz
NeoForge. Klienci pobierają ją przy kolejnym uruchomieniu Prisma przez
istniejący bootstrap. Taki sam plik musi znajdować się w katalogu `mods/`
serwera. Po dodaniu wymagane jest ponowne uruchomienie gry i serwera.
W Build Tool można wybrać Tropical lub Steampunk przy nowych budowach oraz
przebudowach. Tropical jest stylem na palach nad płytką wodą.

Przy aktualizacji lub ponownym imporcie oficjalnej paczki ATM10A zachowaj
Stylecolonies razem z dotychczasowymi dodatkami MineColonies.

Przed wdrożeniem sprawdzono start pełnej paczki na osobnym świecie, wczytanie
obu pakietów oraz pełny odczyt ośmiu schematów: chat budowniczego i ratuszy
na poziomach 1 i 5. Potwierdzono również dostępność dotychczasowego Shogun.
Statycznie odczytano wszystkie 869 schematów Tropical i Steampunk.
[Wynik próby](docs/compatibility/roshar-stylecolonies-2026-11-17.json).
Nie wykonywano próby w interfejsie klienta.

### Praca kolonistów podczas deszczu na Rosharze

Własny skrypt `neoforge/atm10a/kubejs/server_scripts/modpack/minecolonies_rain_work.js`
przy uruchamianiu serwera lub świata ustawia i zapisuje
`gameplay.workersalwaysworkinrain = true` w `config/minecolonies-server.toml`.
Korzysta z API konfiguracji MineColonies i zachowuje pozostałe ustawienia.
Dzięki temu opcja wraca również po ponownym wygenerowaniu konfiguracji.

Skrypt jest śledzony przez packwiz. Klienci pobierają go przy kolejnym
uruchomieniu Prisma; działa także w światach jednoosobowych. Na serwerze musi
znajdować się ta sama kopia w `kubejs/server_scripts/modpack/`. Przy aktualizacji
oficjalnej paczki zachowaj ten skrypt razem z pozostałymi własnymi poprawkami.
Pełne zastosowanie poprawki następuje przy uruchomieniu świata lub serwera.

### Ładowanie całej kolonii na Rosharze

Od **2026-11-11** Roshar używa ustawień w `config/minecolonies-server.toml`:

```toml
[gameplay]
forceloadcolony = true
colonyloadstrictness = 1
loadtime = 1440
```

MineColonies utrzymuje wszystkie zajęte chunki kolonii, kiedy właściciel lub
oficer przebywa w jej zasięgu. Może stać w jednym miejscu; dodatkowe ładowanie
kolonii przez FTB Chunks nie jest potrzebne. Od **2026-11-20** ustawiono
`loadtime = 1440`, czyli maksymalnie 24 godziny dodatkowego ładowania po
odejściu właściciela lub oficera. Licznik nie jest zachowywany po restarcie
serwera; właściciel lub oficer musi ponownie odwiedzić kolonię. To ustawienie
nie oznacza stałego działania kolonii bez obecności graczy.

Własny skrypt `neoforge/atm10a/kubejs/server_scripts/modpack/minecolonies_chunk_loading.js`
przy starcie serwera lub świata ustawia i zapisuje wszystkie trzy opcje przez
API MineColonies, również po ponownym wygenerowaniu konfiguracji. Zachowuje
pozostałe ustawienia. Skrypt jest śledzony przez packwiz, więc
Prism pobiera go przy następnym uruchomieniu. Na serwerze zachowaj tę samą kopię
w `kubejs/server_scripts/modpack/` przy aktualizacjach oficjalnej paczki.
Zmiany stosuj przy zatrzymanym serwerze; obowiązują po jego uruchomieniu.

[Opis opcji ładowania w dokumentacji MineColonies](https://minecolonies.com/wiki/misc/configfile/).

### Wyłączone najazdy na kolonię Tilanary na Rosharze

Stan na **2026-11-08**: najazdy MineColonies na kolonię **WisePeak**
(Tilanara, ID `1`) są wyłączone. Użyta komenda operatora:

```mcfunction
/mc colony canSpawnRaiders 1 false
```

Ustawienie dotyczy kolonii `1` i jest zapisywane w danych świata. Komenda
nie wymaga restartu serwera. W konsoli Crafty wpisuje się ją bez początkowego `/`.
Aby ponownie włączyć najazdy dla tej kolonii:

```mcfunction
/mc colony canSpawnRaiders 1 true
```

[Opis komendy w dokumentacji MineColonies](https://minecolonies.com/wiki/misc/command/#colony-commands).

### Multi-Colony Patch: test i odłożona instalacja

**Decyzja z 2026-11-04: nie instalować teraz.** Użytkownik chce przemyśleć
dodanie moda; wdrożenie na Rosharze i dodanie do paczki Prisma wymaga jego
nowego, wyraźnego polecenia.

Sprawdzono [MineColonies Multi-Colony Patch 1.0.0](https://www.curseforge.com/minecraft/mc-mods/minecolonies-multi-colony-patch/files/8752957)
(CurseForge: projekt `1671716`, plik `8752957`) z Minecraft `1.21.1`,
NeoForge `21.1.250`, MineColonies `1.1.1403` i pozostałymi modami Rosharu.
Wymagania dodatku to NeoForge co najmniej `21.1.235` i MineColonies co najmniej
`1.1.1374-1.21.1-snapshot`.

Próbny serwer z osobną kopią paczki i nowym, pustym światem uruchomił się,
załadował dodatek i zakończył pracę poprawnie (kod wyjścia `0`). Nie wystąpiły
błędy nakładania poprawek moda; zarejestrowano komendę `/mc home [<id>]`.
Statyczne porównanie metod używanych przez poprawkę klientowego Clipboarda
wykazało zgodne sygnatury API. **Nie uruchamiano klienta z dodatkiem i nie
testowano rozgrywki z kilkoma działającymi koloniami.** Autor również zaznacza
brak długotrwałych testów, więc potwierdzona jest zgodność startowa.

W teście dodatek wygenerował plik `config/minecolonies-multicolony`
(bez rozszerzenia `.toml`), z `maxColoniesPerPlayer = -1` (bez limitu)
i `allowIndividualColonyDeletion = true`. Rozważany przez użytkownika limit
to **3–4 kolonie**. Limit dodatku dotyczy pojedynczego gracza; mod pozwala
jednemu graczowi posiadać kilka kolonii. Wymaga instalacji na kliencie i serwerze.

[Zapis wyniku testu](docs/compatibility/roshar-multicolony-2026-11-04.json)
zawiera sumę kontrolną pliku i szczegóły sprawdzenia. Pliki diagnostyczne na
QNAP znajdują się w `/crafty/import/roshar-multicolony-check-20261104/`.
Test nie otwierał świata produkcyjnego. Dodatek pozostaje wyłącznie w katalogu
diagnostycznym, poza modami Rosharu i indeksem paczki packwiz.

### Integracja AE2 z MineColonies na Rosharze

AE2Colonies `1.2.4` dodano do paczki klienta i serwera. Dodatek korzysta z
istniejących wersji AE2 `19.2.17`, MineColonies `1.1.1403`, Domum Ornamentum
`1.0.236` oraz GuideME `21.1.19`; nie wymaga aktualizacji pozostałych modów.
Prism pobiera go przez dotychczasowy bootstrap packwiz. Przy ponownym imporcie
oficjalnej paczki zachowaj także ten dodatek.

ME Colony Terminal ustawiony wewnątrz magazynu kolonii i podłączony do ME
umożliwia kurierom odkładanie, pobieranie i zlecanie autocraftingu. Opcjonalny
ME Architect's Cutter na tej samej sieci obsługuje bloki Domum Ornamentum.
Opis i wydanie: [AE2Colonies 1.2.4](https://www.curseforge.com/minecraft/mc-mods/ae2colonies-applied-energistics-2-minecolonies/files/9253782).

Przed instalacją sprawdzono start na osobnym pustym świecie z modami,
konfiguracją i skryptami Rosharu oraz rejestrację i postawienie obu nowych bloków.

### Przyspieszanie Crimson Iron i Azure Silver przez AE2 na Rosharze

Własny skrypt `neoforge/atm10a/kubejs/server_scripts/modpack/crimson_iron_growth.js`
dodaje `mysticalagriculture:crimson_iron_crop` oraz
`mysticalagriculture:azure_silver_crop` do tagu bloków
`ae2:growth_acceleratable`. Naprawia pominięcie obu niestandardowych upraw
w obsłudze Growth Acceleratorów AE2. Receptury i wymagania upraw pozostają
takie jak w ATM10A 0.7.1.

Skrypt jest śledzony przez packwiz i instalowany również na serwerze.
Na działającym serwerze można go wczytać komendą `reload`; tagi bloków
są synchronizowane z połączonymi klientami. Klienci pobierają lokalną kopię
skryptu przy następnym uruchomieniu Prisma, także do gry jednoosobowej.

### Kategorie przedmiotów do migracji AE2 na Rosharze

Własny skrypt `neoforge/atm10a/kubejs/server_scripts/modpack/storage_routing_tags.js`
buduje podczas uruchamiania świata i przeładowania zasobów dwa tagi przedmiotów:

- `modpack:non_stackable` — typy, których domyślny przedmiot ma maksymalny stos 1.
- `modpack:stackable` — typy, których domyślny przedmiot ma maksymalny stos większy niż 1.

Puste przedmioty są pomijane. Klasyfikacja jest automatyczna i uwzględnia
zainstalowane mody. Nie zmienia przedmiotów, receptur, pojemności stosów ani
istniejącego magazynu. Tagi dotyczą całego typu przedmiotu, więc wyjątkowe
limity stosu nadane pojedynczej sztuce przez komponenty wymagają osobnej obsługi.

Skrypt jest śledzony przez packwiz i trafi do klientów przy następnym uruchomieniu
Prisma. Na serwerze ten sam plik znajduje się w
`kubejs/server_scripts/modpack/storage_routing_tags.js`; działa po uruchomieniu
serwera lub `/reload`. Samo dodanie tagów nie uruchamia migracji ani sortowania.
Docelowe filtry w ME Tag Storage Bus używają powyższych nazw tagów.

## MineColonies na Scadrialu

Scadrial pozostaje na Minecraft `1.21.1` i NeoForge `21.1.233`.
Dodano MineColonies `1.1.1403` oraz Structurize `1.0.835`, BlockUI `1.0.212`,
Domum Ornamentum `1.0.236`, Multi-Piston `1.2.58` i TownTalk `1.2.0`.
Wszystkie te mody są instalowane na kliencie i serwerze.

Przed instalacją na zatrzymanym serwerze sprawdzono start tego zestawu
z dotychczasowymi modami Scadrialu na osobnym pustym świecie.
Instalacja MineColonies nie wymaga resetowania chunków istniejącego świata.
Klienci pobiorą dodatki przy następnym uruchomieniu instancji w Prism.

## Pozostałe operacje

| Skrypt | Zadanie |
| --- | --- |
| `scripts/update-test.sh` | Aktualizacja paczki Fabric test |
| `scripts/add-mod-test.sh` | Dodanie moda do paczki Fabric test |
| `scripts/update-prod.sh` | Aktualizacja paczki TiliNakor dla TiliNakor i Pandory |
| `scripts/add-mod-prod.sh` | Dodanie moda do paczki TiliNakor |
| `scripts/update-server.sh` | Aktualizacja serwerów Fabric `test`, `tilinakor`, `pandora` |
| `scripts/update-server-neoforge.sh` | Aktualizacja Scadrial |

Skrypty serwerowe wymagają zatrzymania danego serwera w Crafty. Do serwera na
QNAP łączą się przez alias SSH `qnap`. Ścieżka hosta
`/share/Container/crafty/servers/<UUID>` odpowiada ścieżce kontenera
`/crafty/servers/<UUID>`.

Scadrial przechowuje ręczne mody we własnym `neoforge/scadrial/manual-mods/`.
Nie zależy już od plików wycofanego Rosharu. Po każdej zmianie konfiguracji
lub ręcznego moda uruchom `packwiz refresh` w katalogu paczki, sprawdź
`git diff`, zrób commit i `git push`, a dopiero potem zaktualizuj serwer.

Pliki `.mrpack` są wytwarzane lokalnie i ignorowane przez Git. Cofnięcie
metadanych paczki: `git revert <commit>` i `git push`.
