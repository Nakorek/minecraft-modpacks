# Minecraft Modpacks – konfiguracja serwerów TiliNakor

Centralna kolekcja modów (packwiz) dla 4 serwerów Minecraft Fabric zarządzanych
przez Crafty Controller na QNAP. Mody dystrybuowane do klientów automatycznie
przez packwiz-installer-bootstrap, do serwerów przez mrpack-install.
Codzienny workflow jest zautomatyzowany skryptami bash w `scripts/`.

**Aktualna wersja:** Minecraft 26.2, Fabric Loader 0.19.3
**Środowisko:** macOS (Apple Silicon M4 Pro), packwiz w `~/go/bin/`, repo w `~/Minecraft/minecraft-modpacks/`

## Serwery i paczki

Cztery serwery obsługiwane przez trzy paczki (Pandora i TiliNakor dzielą tę samą paczkę,
bo grają na tym samym zestawie modów):

| Serwer | Rola | Paczka | UUID | Adres |
|---|---|---|---|---|
| **TiliNakor** | produkcja survival | `TiliNakor` | `5071df24-5a62-48d9-b038-c910d088898f` | `tilinakor.lan:25566` |
| **Pandora** | zamrożony survival | `TiliNakor` | `7d468085-bc02-4e7b-b53a-54ad9f4b03e3` | `pandora.lan:25565` |
| **TiliNakor test** | pole eksperymentów | `TiliNakor_test` | `fc17ba3e-b41b-4fd3-b012-52749bd58833` | `ktilinakor.lan:25568` |
| **kTiliNakor** | creative | `kTiliNakor` | `eff8a0a1-9645-4d4b-a1d5-74fe9bfabf30` | `ktilinakor.lan:25567` |

### Struktura repo

```
minecraft-modpacks/
├── README.md               ← ten plik
├── .gitignore              ← ignoruje *.mrpack
├── fabric/
│   ├── TiliNakor/          ← paczka produkcyjna
│   ├── TiliNakor_test/     ← paczka testowa
│   └── kTiliNakor/         ← paczka kreatywna
└── scripts/
    ├── lib/
    │   ├── common.sh       ← funkcje wspólne (kolory, walidacja, git)
    │   └── server.sh       ← operacje SSH/SCP/Docker na QNAP
    ├── update-test.sh      ← aktualizacja paczki testowej
    ├── update-prod.sh      ← aktualizacja paczek produkcyjnych
    ├── update-server.sh    ← aktualizacja pojedynczego serwera
    ├── add-mod-test.sh     ← dodanie moda do paczki testowej
    └── add-mod-prod.sh     ← dodanie moda do paczek produkcyjnych
```

W repo są **metadane packwiz** (`pack.toml`, `index.toml`, `mods/*.pw.toml`) i skrypty.
Fizyczne pliki `.jar` i `.mrpack` **nie są** w gicie – pobierane dynamicznie z Modrinth/CurseForge
na podstawie linków w metadanych.

## Szybki start – codzienny workflow

### Aktualizacja modów

Cała aktualizacja (paczka test → klient test → serwer test → paczka prod → serwer prod)
w kilku komendach:

```bash
cd ~/Minecraft/minecraft-modpacks

# 1. Sprawdź co jest do aktualizacji na teście
./scripts/update-test.sh --check

# 2. Zaaplikuj aktualizacje testowej (packwiz zapyta o Y/N per lista)
./scripts/update-test.sh --apply
# → odpal klienta testowego w Prismie, sprawdź w grze

# 3. Zaktualizuj serwer testowy (Stop w Crafty przed uruchomieniem)
./scripts/update-server.sh test
# → Start w Crafty, sprawdź w grze na serwerze

# 4. Jeśli OK - zaktualizuj paczki produkcyjne
./scripts/update-prod.sh
# → packwiz zapyta o Y/N per paczka, potem eksport + commit + push

# 5. Zaktualizuj serwery produkcyjne (Stop w Crafty przed każdym!)
./scripts/update-server.sh pandora     # najmniej krytyczna
./scripts/update-server.sh ktilinakor  # creative
./scripts/update-server.sh tilinakor   # produkcja - ostrzeż graczy
```

Klienci Prisma dostają update automatycznie przy najbliższym uruchomieniu instancji
(bootstrap pobiera nowe wersje z GitHuba).

### Dodanie nowego moda

Analogiczny workflow: test → prod. Skrypty sprawdzają czy mod już nie jest w paczce.

```bash
cd ~/Minecraft/minecraft-modpacks

# 1. Dodaj mod do paczki testowej
./scripts/add-mod-test.sh <slug>
# → odpal klienta testowego w Prismie, sprawdź w grze

# 2. Jeśli mod jest 'both' lub 'server' - zaktualizuj serwer testowy
./scripts/update-server.sh test
# → Start w Crafty, sprawdź na serwerze

# 3. Jeśli OK - dodaj do paczek produkcyjnych
./scripts/add-mod-prod.sh <slug>
# → safety bramka pyta czy test przeszedł

# 4. Jeśli mod jest 'both'/'server' - zaktualizuj serwery produkcyjne
./scripts/update-server.sh pandora
./scripts/update-server.sh ktilinakor
./scripts/update-server.sh tilinakor
```

Dla konkretnej wersji (nie najnowszej): `add-mod-test.sh --project-id X --version-id Y`
– zobacz sekcję "Dodanie konkretnej wersji moda" niżej.

## Skrypty

Framework bash oparty na wspólnej bibliotece `scripts/lib/`. Wszystkie skrypty
mają `--help` i kolorowy output. Wymagają: `packwiz`, `git`, `ssh`, `scp` w PATH.

### `update-test.sh` – aktualizacja paczki testowej

Operuje **tylko** na `TiliNakor_test`. Dwa tryby:

- `--check` (default) – raport, nic nie modyfikuje
- `--apply` – interaktywna aktualizacja + eksport + commit + push

```bash
./scripts/update-test.sh              # = --check
./scripts/update-test.sh --check      # to samo, jawnie
./scripts/update-test.sh --apply      # faktyczna aktualizacja
```

Tryb `--apply`:
1. `packwiz update --all` (interaktywnie, packwiz pyta Y/N)
2. `packwiz modrinth export`
3. Pokazuje `git status`, pyta o commit
4. Pyta o opis commita (Enter dla defaultu)
5. `git add -A && git commit && git push`

### `update-prod.sh` – aktualizacja paczek produkcyjnych

Operuje na `TiliNakor` i `kTiliNakor`. Zawiera safety bramkę:

```bash
./scripts/update-prod.sh
```

Sekwencja:
1. Pyta: *"Czy test przeszedł pomyślnie?"* – jeśli N, przerywa
2. Iteruje przez paczki, każda z pytaniem Y/N (można skipnąć jedną)
3. `packwiz update --all` interaktywnie + eksport mrpacka
4. Wspólny commit + push z opisem
5. Podsumowanie z sugestiami następnych kroków (które `update-server.sh` odpalić)

### `add-mod-test.sh` – dodanie moda do paczki testowej

Dodaje mod z Modrinth do `TiliNakor_test`. Bezpieczne – sprawdza czy mod
już istnieje przed dodaniem.

```bash
./scripts/add-mod-test.sh <slug>
./scripts/add-mod-test.sh --project-id <ID> --version-id <ID>
```

Sekwencja:
1. Sprawdza czy `mods/<slug>.pw.toml` już istnieje – jeśli tak, przerywa
   z sugestią `packwiz update` lub `remove + add`
2. `packwiz modrinth add`
3. `packwiz modrinth export`
4. Commit + push (jeśli coś się zmieniło; w przeciwnym razie wyjście bez pytania)
5. Podsumowanie z podpowiedzią następnych kroków (zależne od `side` moda)

Podpowiedzi końcowe uwzględniają czy mod jest `client` / `both` / `server` –
skrypt sam mówi czy trzeba aktualizować serwer testowy.

### `add-mod-prod.sh` – dodanie moda do paczek produkcyjnych

Analogiczny do `update-prod.sh` – z safety bramką:

```bash
./scripts/add-mod-prod.sh <slug>
./scripts/add-mod-prod.sh --project-id <ID> --version-id <ID>
```

Sekwencja:
1. Pyta: *"Czy mod został przetestowany?"* – jeśli N, przerywa
2. Sprawdza w każdej paczce prod czy mod nie istnieje
3. Dodaje do `TiliNakor` i `kTiliNakor`
4. Eksportuje mrpacki obu paczek
5. Commit + push
6. Podsumowanie z sugestiami (zależne od `side` moda)

**Uwaga**: obsługuje **tylko Modrinth**. Mody z CurseForge dodawaj ręcznie
w każdej paczce osobno (`packwiz curseforge add`) – automatyzacja tego to
ryzyko podmiany bibliotek (patrz "Dodawanie moda z CurseForge" niżej).

### `update-server.sh` – aktualizacja pojedynczego serwera

Aktualizuje jeden serwer przez SSH + docker exec. Alias jako argument:

```bash
./scripts/update-server.sh test        # TiliNakor test
./scripts/update-server.sh tilinakor   # TiliNakor produkcja
./scripts/update-server.sh pandora     # Pandora
./scripts/update-server.sh ktilinakor  # kTiliNakor
```

Sekwencja (4 etapy):
1. **SCP mrpacka** z Maca na QNAP (do folderu serwera)
2. **Czyszczenie** `mods/` (rm mods/*.jar)
3. **mrpack-install** przez `docker exec crafty_container`
4. **Sprzątanie fabric-server.jar**:
   - Jeśli rozmiary identyczne (ta sama wersja MC/Loader) → usunięcie duplikatu
   - Jeśli różne (zmiana wersji) → pyta o podmianę z backupem `.old_<data>`

Safety bramka na starcie: pyta czy serwer został zatrzymany w Crafty.

**Wymaga skonfigurowanego SSH** – zobacz sekcję "Konfiguracja infrastruktury".

### `lib/common.sh` i `lib/server.sh`

Biblioteki wspólne. Nie uruchamiane bezpośrednio, tylko `source`'owane w skryptach:

- `common.sh` – kolory (`log_info`, `log_ok`, `log_warn`, `log_error`, `log_section`),
  walidacja (`require_command`, `require_pack_dir`, `require_git_repo`),
  interakcja (`confirm`, `ask_input`), pomocnicze git (`git_has_changes`, `git_show_status`),
  `get_repo_root` dla dowolnej lokalizacji uruchomienia
- `server.sh` – mapowanie aliasów serwerów (`server_get_uuid`, `server_get_pack`),
  operacje SSH/SCP/Docker (`qnap_exec`, `qnap_docker_exec`, `qnap_scp_to`),
  wysokopoziomowe (`server_upload_mrpack`, `server_run_mrpack_install`,
  `server_replace_fabric_jar`)

Kluczowa uwaga dla `server.sh`: docker jest w niestandardowej lokalizacji
(`/share/ZFS530_DATA/.qpkg/container-station/bin/docker`) i **non-interactive SSH nie
ładuje PATH z profile**, więc używamy pełnej ścieżki. Ścieżki przekazywane do
`docker exec` muszą być **z perspektywy kontenera** (`/crafty/servers/<UUID>`),
nie hosta (`/share/Container/crafty/servers/<UUID>`) – tłumaczy je funkcja
`server_container_dir`.

## Ręczne workflow (fallback / referencje)

Skrypty pokrywają ~95% codziennej pracy. Poniższe workflow są potrzebne
przy specjalnych sytuacjach (dodanie nowego moda, migracja MC, pinowanie wersji).

### Dodawanie moda z Modrinth

```bash
cd ~/Minecraft/minecraft-modpacks/fabric/TiliNakor_test
packwiz modrinth add <slug>
cat mods/<slug>.pw.toml
```

Slug to część URL z Modrinth (`modrinth.com/mod/<slug>`). Sprawdź w wygenerowanym
pliku:
- `side` = `client` / `server` / `both` (Modrinth zwykle poprawnie ustawia)
- Zależności dodane automatycznie (jeśli były potrzebne)

Po dodaniu:
```bash
packwiz modrinth export
git add -A && git commit -m "TiliNakor_test - dodanie <nazwa>" && git push
```

Test w kliencie testowym, potem replikacja na paczki prod (te same komendy w folderach
`TiliNakor/` i `kTiliNakor/`).

### Dodanie konkretnej wersji moda (np. starszej stable zamiast beta)

Domyślnie `packwiz modrinth add` bierze najnowszą. Do wybrania konkretnej trzeba
`--project-id` **oraz** `--version-id`. Sam slug nie zadziała ("cannot be used
with separately specified URL/slug").

Znalezienie ID przez Modrinth API:

```bash
curl -s "https://api.modrinth.com/v2/project/<slug>/version" | python3 -m json.tool | grep -B2 "<filename-fragment>"
```

W wypluwanym JSON widać `id` (version-id) i URL z `data/<PROJECT-ID>/versions/<VERSION-ID>/`.

Przykład (Sodium 0.9.0 dla Fabric 26.2):
```bash
packwiz modrinth add --project-id AANobbMI --version-id 3QgJXuSK
```

### Pinowanie wersji moda

Zatrzymuje mod na obecnej wersji – `packwiz update` go pomija:

```bash
packwiz pin <slug>
packwiz unpin <slug>
```

Kiedy pinować:
- Konflikt wersji z innym modem (np. Sodium ↔ Iris po major MC bump)
- Beta powoduje problemy, stable starsza działa
- Regression w nowej wersji

Historia projektu: przy migracji 26.2 Sodium 0.9.1-beta.2 wymagał Iris 1.11.2+,
którego nie było (tylko 1.11.1). Cofnięto Sodium na 0.9.0 stable + pin.
Po wyjściu Iris 1.11.2 – unpin + update do Sodium 0.9.1 stable.

### Dodawanie moda z CurseForge

Wymaga `CURSEFORGE_API_KEY` w `~/.zshrc`. **Preferuj Modrinth** kiedy tylko możliwe
– CF ma dwie pułapki:

**Pułapka 1**: `packwiz curseforge add <mod>` może podmienić istniejący wpis
biblioteki z Modrinth na wersję z CF. Sprawdzenie:
```bash
cat mods/fabric-api.pw.toml
```
Jeśli w środku `mode = "metadata:curseforge"` – naprawa:
```bash
packwiz remove fabric-api
packwiz modrinth add fabric-api
```

**Pułapka 2**: Mody z CF **mogą zacząć wymagać nowych zależności w nowej wersji**,
a packwiz tego NIE wykryje przy `packwiz update`. Uruchom klienta jako pierwszy test.
Przy migracji 26.1.2: Survival Fly zaczął wymagać YACL, Waystones – Shogi.

### Usuwanie moda

Zawsze sprawdź czy nie jest zależnością:
```bash
grep -i "<slug-lub-nazwa>" mods/*.pw.toml
```

Jeśli pokazuje tylko sam plik moda – można usuwać:
```bash
packwiz remove <slug>
```

⚠️ **Slug pliku może różnić się od URL**. Przykład: mod *Flower Map* z URL
`/mod/flowermap` ma plik `mods/flowermap.pw.toml` (bez myślnika). Jeśli
`packwiz remove` zwraca "Can't find this file":
```bash
ls mods/ | grep -i <fragment>
```

### Migracja na nową wersję Minecrafta

Rzadka, ale ważna procedura (raz na kilka miesięcy). Sprawdzone przy migracjach
1.21.11 → 26.1.2 i 26.1.2 → 26.2.

**Krok 1 – Sprawdzenie kompatybilności na kopii paczki** (bez ryzyka):

```bash
cd ~/Minecraft/minecraft-modpacks/fabric
cp -R TiliNakor_test _migration_check
cd _migration_check
rm *.mrpack

packwiz migrate minecraft <wersja>
# Loader: Y
# Update mods: N   ← chcemy tylko raport!

packwiz update --all
# Odpowiedź: N
```

Packwiz wypisze listę: mody z update, mody "already up to date" (multi-version),
mody z `no valid versions found` (blokujące).

**Krok 2 – Decyzja o modach blokujących**

- **Czekaj** – autorzy zwykle wydają wersje w 1-3 miesiące
- **Wyrzuć** – jeśli nie krytyczne (potem można dodać z powrotem)
- **Zamiennik** – szukaj forka albo alternatywnego moda

Przykład z 26.2: Krypton i Flower Map wyrzucone tymczasowo → wróciły ~miesiąc później.

**Krok 3 – Sprzątanie i faktyczna migracja**

```bash
cd ~/Minecraft/minecraft-modpacks/fabric
rm -rf _migration_check

cd TiliNakor_test
packwiz remove <blokujące>       # jeśli decyzja: wyrzucić
packwiz migrate minecraft <wersja>
# Loader: Y
# Update mods: Y
```

**Krok 4 – Konflikt wersji między modami** (typowe po major MC bump)

Mody synchronizujące API (Sodium ↔ Iris) mogą wymagać wzajemnie nowszych wersji.
Diagnoza z crash log:
```
Mod 'Sodium' 0.9.1-beta.2 is incompatible with version 1.11.1 or earlier of mod 'Iris'
```

Rozwiązanie: cofnąć jeden mod na starszą wersję + pinować. Patrz sekcje
"Dodanie konkretnej wersji" i "Pinowanie".

**Krok 5 – Test klienta**

Odpal Prism z testowej instancji. Jeśli crash na brakujące zależności
(mody z CF) – dopisz przez `packwiz modrinth add <slug>` iteracyjnie.

**Krok 6 – Replikacja**

Analogiczna procedura na `TiliNakor` i `kTiliNakor`. Potem serwery
przez `update-server.sh`.

⚠️ Przy zmianie **Fabric Loader** (nie tylko MC) skrypt `update-server.sh`
sam podmieni `fabric-server.jar` – patrz opis skryptu wyżej.

## Konfiguracja klienta (dla graczy)

Każdy gracz instaluje **Prism Launcher** i konfiguruje instancje z auto-update
przez packwiz-installer-bootstrap. Mody pobierają się i aktualizują automatycznie
przy każdym uruchomieniu instancji.

### Krok 1 – Prism Launcher

Pobierz z https://prismlauncher.org/ (Windows/Mac/Linux). Zaloguj się kontem
Microsoft/Mojang.

### Krok 2 – Bootstrap

Pobierz `packwiz-installer-bootstrap.jar` (~100 KB) z:
https://github.com/packwiz/packwiz-installer-bootstrap/releases/latest

Zapisz w wygodnym miejscu (np. `~/Tools/`).

### Krok 3 – Instancja w Prismie

Dwie instancje w zależności od serwerów na których grasz:

| Instancja | URL pack.toml | Dla serwerów |
|---|---|---|
| **TiliNakor** | `https://raw.githubusercontent.com/Nakorek/minecraft-modpacks/main/fabric/TiliNakor/pack.toml` | TiliNakor + Pandora |
| **kTiliNakor** | `https://raw.githubusercontent.com/Nakorek/minecraft-modpacks/main/fabric/kTiliNakor/pack.toml` | kTiliNakor |

Tworzenie:
1. **Add Instance** → **Niestandardowe** (Custom)
2. Nazwa dowolna, Minecraft `26.2`, Loader **Fabric** `0.19.3`
3. Create

### Krok 4 – Wrzuć bootstrap

Prawym na instancję → **Folder instancji** → skopiuj `packwiz-installer-bootstrap.jar`
do **głównego folderu instancji** (obok `.minecraft/`, NIE wewnątrz).

### Krok 5 – Pre-launch command

Prawym → **Edytuj instancję** → **Ustawienia** → **Własne komendy**:

- Zaznacz *"Nadpisz Ustawienia Globalne"*
- W polu **"Komendy przed uruchomieniem"** wklej (URL z tabeli wyżej):

```
"$INST_JAVA" -jar "$INST_DIR/packwiz-installer-bootstrap.jar" <URL_PACZKI>
```

⚠️ Forward slash `/` – działa na Windows i Mac/Linux.

**Prism Launcher 11.x+** sam wykrywa zmianę wersji MC/Fabric w `pack.toml`
i przy uruchomieniu pyta *"This modpack uses newer versions..."* → **Update**.
Nie trzeba ręcznie zmieniać wersji w ustawieniach instancji.

### Krok 6 – Pierwszy launch

Bootstrap pobierze wszystkie mody (2-5 min pierwszym razem).

**Antywirus może blokować** niektóre mody (zwłaszcza Flashback). Anuluj i ponów
1-2 razy, lub dodaj wyjątek dla folderu instancji.

### Krok 7 – Serwery w grze

Multiplayer → Add Server → adres z tabeli na początku (`tilinakor.lan:25566` itd.).
`.lan` działa tylko w lokalnej sieci.

### Kolejne uruchomienia

Bootstrap sam sprawdza GitHuba i pobiera update'y. Nic ręcznie.
Jeśli "nie widzi" zmian – zamknij i otwórz Prism Launcher.

## Konfiguracja infrastruktury (nowy komputer / środowisko od zera)

### 1. packwiz przez Go

Packwiz nie ma binarek na GitHubie:
```bash
brew install go
go install github.com/packwiz/packwiz@latest
```

Binarka ląduje w `~/go/bin/packwiz`. W `~/.zshrc`:
```bash
export PATH="$HOME/go/bin:$PATH"
export CURSEFORGE_API_KEY='twoj_klucz'
```

Pojedyncze cudzysłowy dla klucza – chroni przed interpretacją `$` i innych znaków.
Po zmianie: `source ~/.zshrc`.

### 2. Git auth

Dwa równoważne sposoby, działają razem:

**GitHub Desktop** (GUI):
- https://desktop.github.com/, Sign in jako Nakorek (OAuth w przeglądarce)
- File → Clone repository → `github.com/Nakorek/minecraft-modpacks` do `~/Minecraft/`

**Terminal (PAT + macOS Keychain)** – wygodniejsze pod skrypty:
```bash
git config --global credential.helper osxkeychain
```
Wygeneruj **Personal Access Token (classic)** na https://github.com/settings/tokens
z scope `repo`. Przy pierwszym `git push` z Terminala wpisz username = Nakorek
i token jako hasło – keychain zapisze na zawsze.

### 3. SSH key na QNAP

Wymagane dla `update-server.sh`. Osobny klucz dla QNAP (nie mieszamy z innymi):

```bash
ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519_naqnap -C "Mac do QNAP"
```

Konfiguracja w `~/.ssh/config`:
```
Host qnap
    HostName 172.20.20.10
    User flagstone4408
    IdentityFile ~/.ssh/id_ed25519_naqnap
    IdentitiesOnly yes
```
```bash
chmod 600 ~/.ssh/config
```

Wgraj klucz publiczny (raz z hasłem):
```bash
ssh-copy-id -i ~/.ssh/id_ed25519_naqnap.pub flagstone4408@172.20.20.10
```

Test:
```bash
ssh qnap "echo Hello z QNAP"
```

Bez pytania o hasło = ✅. Skrypt `update-server.sh` gotowy do użycia.

### 4. Klon repo

```bash
mkdir -p ~/Minecraft && cd ~/Minecraft
git clone https://github.com/Nakorek/minecraft-modpacks.git
```

Skrypty w `scripts/` są już `chmod +x` w repo, gotowe do użycia.

### PowerShell vs bash (referencja komend)

| PowerShell (Windows) | bash (Mac) |
|---|---|
| `type plik` | `cat plik` |
| `dir` | `ls` |
| `del plik` | `rm plik` |
| `Copy-Item -Recurse src dst` | `cp -R src dst` |
| `Remove-Item -Recurse -Force dir` | `rm -rf dir` |
| `notepad plik` | `nano plik` / `code plik` |
| `findstr /S /I "wzor" mods\*.pw.toml` | `grep -i "wzor" mods/*.pw.toml` |
| `\` w ścieżkach | `/` w ścieżkach |
| `C:\Minecraft\minecraft-modpacks` | `~/Minecraft/minecraft-modpacks` |

⚠️ **zsh interpretuje `?` w URL jako pattern**. URL z parametrami query trzeba
wkleić w cudzysłowach, inaczej `zsh: no matches found`.

## Troubleshooting

### Skrypt `update-server.sh` – "SSH nie odpowiada"

Sprawdź krok po kroku:
```bash
ping 172.20.20.10                    # sieć
ssh qnap "echo ok"                   # ssh key
grep qnap ~/.ssh/config              # konfiguracja
ls -la ~/.ssh/id_ed25519_naqnap      # klucz istnieje
```

### Skrypt `update-server.sh` – "docker: command not found"

Docker w QNAP Container Station ma niestandardową ścieżkę. Skrypt używa
`/share/ZFS530_DATA/.qpkg/container-station/bin/docker` – jeśli u ciebie
inaczej, poprawić `QNAP_DOCKER_BIN` w `scripts/lib/server.sh`:
```bash
ssh qnap "which docker"    # z sesji interaktywnej
```

### mrpack-install zwraca 404

Prawdopodobnie ścieżka podana z perspektywy **hosta** zamiast **kontenera**.
Docker widzi bind mount:
- Host: `/share/Container/crafty/servers/<UUID>`
- Container: `/crafty/servers/<UUID>`

Do `docker exec` używać ścieżek kontenera. Skrypt to obsługuje przez
`server_container_dir` – jeśli piszesz własne komendy, pamiętaj o mapowaniu.

### Klient nie pobiera aktualizacji

Prism Launcher trzyma stan w pamięci. Zamknij całkowicie i otwórz ponownie.

### Bootstrap "Unable to access jarfile"

`packwiz-installer-bootstrap.jar` musi być w **głównym folderze instancji**
(obok `.minecraft/`, nie wewnątrz). Komenda pre-launch używa `$INST_DIR/...`
z forward slash.

### Bootstrap pomija dużą aktualizację

Przy migracji MC bootstrap czasem nie kończy pobierania za pierwszym razem.
Druga próba zwykle ratuje. Jeśli kilka prób się sypie – restart Prisma.

### Bootstrap "Failed file downloads"

Antywirus rwie TCP do CDN Modrinth. Rozwiązania:
1. Anuluj i ponów (każda próba różny zestaw modów)
2. Wyłącz AV na czas pobierania
3. Wyjątek w AV dla folderu instancji / domeny `cdn.modrinth.com`

Szczególnie problemowe: **Flashback** (mod nagrywania – AV bierze za keylogger).

### Crash klienta: "Mod X requires Y, which is missing"

Migracja MC z modów CF – nowe zależności których packwiz nie wykrył.
Dodaj brakującą przez `packwiz modrinth add <slug>` iteracyjnie aż odpali.

### Crash klienta: konflikt wersji między modami

Fabric Loader w crash logu podaje precyzyjnie który mod wymaga której wersji.
Typowo Sodium ↔ Iris. Rozwiązanie: cofnąć jeden mod + pin. Patrz sekcje
"Dodanie konkretnej wersji" i "Pinowanie".

### Mod z CF zastąpił bibliotekę z Modrinth

Po `packwiz curseforge add` biblioteka np. `mods/fabric-api.pw.toml` ma
`mode = "metadata:curseforge"`. Naprawa:
```bash
packwiz remove <slug>
packwiz modrinth add <slug>
```

### Eksport mrpacka pomija mod – "Download failed"

Antywirus blokuje konkretny plik przy eksporcie. To NIE psuje pracy dla klientów
– bootstrap pobiera bezpośrednio z Modrinth omijając cache packwiz. Dla serwera
(mrpack-install) – wyjątek w AV.

### Serwer nie startuje po mrpack-install (zmiana wersji MC)

`update-server.sh` obsługuje to automatycznie – wykrywa różne rozmiary
`fabric-server.jar` i pyta o podmianę.

Manualnie – każdy `mv` osobno, weryfikacja `ls -la fabric-server*.jar` między:
```bash
cd /share/Container/crafty/servers/<UUID>
ls -la fabric-server*.jar
mv fabric-server.jar fabric-server.jar.old_<opis>
mv fabric-server-mc.<MC>-loader.<L>-launcher.<W>.jar fabric-server.jar
sudo chmod 777 fabric-server.jar
```

### Cofnięcie aktualizacji

Każda zmiana w gicie jest cofalna:
```bash
git revert <hash-commita>
git push
```
lub w GitHub Desktop. Klienci dostaną cofnięty stan przy najbliższym launchu
(bootstrap). Serwery – ręczne mrpack-install z poprzedniego mrpacka albo restore
z Crafty.

## TODO / czekamy na

- **Big Sign Writer** – blokada Mojanga MC-308809 (znaki broken w 26.2),
  naprawione w snapshotach 26.3. Czekamy na stable 26.3.
- **PINS.md** – osobny plik do trackingu pinów, gdy pojawi się kolejny aktywny
  pin. Aktualnie brak (Sodium odpięty w lipcu 26 po wyjściu Iris 1.11.2).
- **Kolejne skrypty automatyzacji** do rozważenia:
  - `audit-pins.sh` – audyt pinów i sugestie odpinania
  - `remove-mod-test.sh` / `remove-mod-prod.sh` – analogicznie do add-mod-*
  - `compat-check.sh` – automatyczny compatibility check przed migracją MC
