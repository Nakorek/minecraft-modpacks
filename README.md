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

## ATM10A

`neoforge/atm10a` zawiera listę modów klienta importowaną z oficjalnego
`ATM10AERO-0.7.1.zip`: Minecraft `1.21.1`, NeoForge `21.1.250`.
Wersje modów z paczki są przypięte do wydania 0.7.1.
Dodatkowo dodaliśmy Freecam 1.3.0, Gamma Tweaks 1.0.0 oraz Bobby ReNeoForged 5.2.4-0.4 tylko dla klientów.
Nowy serwer Roshar ma seed `-919282885`, ustawiony przed pierwszym startem.
Adres serwera w sieci lokalnej: `roshar.lan:25570`.

Paczka w tym repo śledzi **mody, dwa pakiety zasobów i własny skrypt kategorii
magazynowych**. Oficjalne konfiguracje, zadania, skrypty KubeJS i inne pliki
paczki pochodzą z oficjalnego ZIP-a importowanego do Prisma. Zmiany tych plików
przy kolejnych wydaniach ATM10A wymagają importu
nowego oficjalnego ZIP-a; sam bootstrap aktualizuje pliki śledzone w packwiz.
Nie publikujemy kopii plików ATM Team w tym repo.

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
