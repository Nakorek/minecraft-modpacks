#!/bin/bash
# update-server.sh - Aktualizacja jednego serwera Minecraft na QNAP
#
# Wykonuje pełną procedurę:
#   1. Walidacja: SSH działa, mrpack lokalny istnieje, paczka się zgadza
#   2. Wgranie mrpacka na QNAP (SCP)
#   3. Safety: pyta czy serwer jest zatrzymany w Crafty
#   4. Czyszczenie folderu mods/
#   5. mrpack-install w kontenerze docker
#   6. Sprzątanie fabric-server.jar:
#      - jeśli duplikat (ta sama wersja) -> usunięcie
#      - jeśli zmiana MC/Loadera -> podmiana
#   7. Komunikat do startu w Crafty + test
#
# Użycie:
#   ./scripts/update-server.sh <alias>
#   ./scripts/update-server.sh test
#   ./scripts/update-server.sh tilinakor

set -e  # zatrzymaj na pierwszym błędzie

# Załaduj wspólne funkcje
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/common.sh"
source "$SCRIPT_DIR/lib/server.sh"

# ============================================================================
# WALIDACJA ARGUMENTÓW
# ============================================================================

if [ $# -eq 0 ] || [ "${1:-}" = "-h" ] || [ "${1:-}" = "--help" ]; then
    cat <<EOF
update-server.sh - aktualizacja serwera Minecraft na QNAP

UŻYCIE:
    ./scripts/update-server.sh <alias>

DOSTĘPNE ALIASY:
    test         TiliNakor test (UUID fc17ba3e-...)
    tilinakor    TiliNakor produkcja (UUID 5071df24-...)
    pandora      Pandora (UUID 7d468085-...)
    ktilinakor   kTiliNakor creative (UUID eff8a0a1-...)

PRZYKŁADY:
    ./scripts/update-server.sh test
    ./scripts/update-server.sh tilinakor

CO ROBI:
    1. Sprawdza warunki (SSH, mrpack, paczka)
    2. Pyta czy serwer został zatrzymany w Crafty
    3. Wgrywa mrpack na QNAP (SCP)
    4. Czyści folder mods/
    5. Uruchamia mrpack-install w kontenerze docker
    6. Sprzątanie fabric-server.jar (duplikat lub podmiana wersji)
    7. Informuje że można startować serwer w Crafty

WYMAGANIA:
    - SSH do QNAP działa bez hasła ("ssh qnap 'echo ok'")
    - mrpack istnieje w paczce (uruchom packwiz modrinth export)
    - Serwer ZATRZYMANY w Crafty (skrypt poprosi o potwierdzenie)
EOF
    exit 0
fi

ALIAS="$1"

# ============================================================================
# WALIDACJA ŚRODOWISKA
# ============================================================================

require_command ssh
require_command scp
require_command git

# Sprawdź alias
if ! server_alias_exists "$ALIAS"; then
    log_error "Nieznany alias serwera: $ALIAS"
    log_error "Dostępne aliasy: $(server_list_aliases)"
    log_error "Uruchom z --help dla pełnej listy."
    exit 1
fi

# Pobierz informacje o serwerze
UUID=$(server_get_uuid "$ALIAS")
PACK_NAME=$(server_get_pack "$ALIAS")
SERVER_NAME=$(server_get_name "$ALIAS")
REPO_ROOT="$(get_repo_root)"
PACK_DIR="$REPO_ROOT/fabric/$PACK_NAME"
LOCAL_MRPACK="$PACK_DIR/$PACK_NAME-1.0.0.mrpack"

log_section "Aktualizacja serwera: $SERVER_NAME"
log_info "Alias:    $ALIAS"
log_info "UUID:     $UUID"
log_info "Paczka:   $PACK_NAME"

# Walidacje
require_pack_dir "$PACK_DIR"

if [ ! -f "$LOCAL_MRPACK" ]; then
    log_error "Brak lokalnego mrpacka: $LOCAL_MRPACK"
    log_error "Najpierw wykonaj eksport:"
    log_error "  cd $PACK_DIR && packwiz modrinth export"
    exit 1
fi
log_ok "Mrpack lokalny:    $LOCAL_MRPACK ($(du -h "$LOCAL_MRPACK" | cut -f1))"

# Sprawdź SSH
log_info "Sprawdzanie połączenia SSH do QNAP..."
if ! qnap_check_connection; then
    exit 1
fi
log_ok "SSH OK"

# ============================================================================
# SAFETY BRAMKA - serwer zatrzymany?
# ============================================================================

log_section "Safety bramka"
log_warn "Aktualizacja wymaga zatrzymanego serwera w Crafty."
log_warn "Jeśli serwer nadal działa - zatrzymaj go TERAZ w panelu Crafty."
echo ""

if ! confirm "Czy serwer '$SERVER_NAME' został zatrzymany w Crafty?" "N"; then
    log_warn "Anulowane. Zatrzymaj serwer w Crafty i uruchom ponownie."
    exit 0
fi

# ============================================================================
# KROK 1: WGRANIE MRPACKA NA QNAP
# ============================================================================

log_section "1/4 - Wgrywanie mrpacka na QNAP"

REMOTE_DIR=$(server_remote_dir "$ALIAS")
log_info "Cel: $REMOTE_DIR/"

log_info "SCP w toku..."
server_upload_mrpack "$ALIAS" "$LOCAL_MRPACK"
log_ok "Mrpack wgrany."

# Weryfikacja
EXISTING_MRPACK=$(server_check_mrpack "$ALIAS")
if [ -z "$EXISTING_MRPACK" ]; then
    log_error "Po SCP nie widać mrpacka na QNAP - coś poszło nie tak."
    exit 1
fi
log_ok "Weryfikacja: $EXISTING_MRPACK"

# ============================================================================
# KROK 2: CZYSZCZENIE MODS
# ============================================================================

log_section "2/4 - Czyszczenie folderu mods/"

MODS_COUNT_BEFORE=$(qnap_exec "ls $REMOTE_DIR/mods/ 2>/dev/null | wc -l")
log_info "Modów obecnie: $MODS_COUNT_BEFORE"

log_info "Usuwanie *.jar z mods/..."
server_clear_mods "$ALIAS"

MODS_COUNT_AFTER=$(qnap_exec "ls $REMOTE_DIR/mods/ 2>/dev/null | wc -l")
log_ok "Folder mods/ posprzątany. Plików zostało: $MODS_COUNT_AFTER (powinno być 0)"

# ============================================================================
# KROK 3: MRPACK-INSTALL
# ============================================================================

log_section "3/4 - Mrpack-install w kontenerze docker"

log_info "Uruchamianie mrpack-install-linux..."
log_info "(może chwilę potrwać - pobiera mody z Modrinth)"
echo ""

server_run_mrpack_install "$ALIAS" "$PACK_NAME"

echo ""
log_ok "Mrpack-install zakończony."

# ============================================================================
# KROK 4: SPRZĄTANIE fabric-server.jar
# ============================================================================

log_section "4/4 - Sprzątanie fabric-server.jar"

# Sprawdź stan
log_info "Stan plików fabric-server*.jar:"
JAR_LIST=$(server_check_fabric_jars "$ALIAS")
echo "$JAR_LIST"
echo ""

# Policz pliki
JAR_COUNT=$(echo "$JAR_LIST" | wc -l)

# Sprawdź czy jest oryginał i czy jest pobrany duplikat
HAS_ORIGINAL=$(echo "$JAR_LIST" | grep -c "fabric-server.jar$" || true)
HAS_DOWNLOADED=$(echo "$JAR_LIST" | grep -c "fabric-server-mc\." || true)

if [ "$HAS_DOWNLOADED" -eq 0 ]; then
    log_info "Brak pobranego pliku - nic do sprzątania."
elif [ "$HAS_ORIGINAL" -eq 0 ] && [ "$HAS_DOWNLOADED" -gt 0 ]; then
    # Tylko pobrany, nie ma oryginalnego - to dziwne ale możliwe (pierwszy raz)
    log_warn "Nie ma oryginalnego fabric-server.jar, tylko pobrany."
    log_warn "Wymaga ręcznej decyzji - sprawdź stan i ewentualnie podmień."
else
    # Mamy oba - porównaj rozmiary
    ORIG_SIZE=$(server_file_size "$ALIAS" "$REMOTE_DIR/fabric-server.jar")
    
    # Znajdź ścieżkę pobranego (jest dynamiczna nazwa)
    DOWNLOADED_PATH=$(qnap_exec "ls $REMOTE_DIR/fabric-server-mc.*-loader.*-launcher.*.jar 2>/dev/null | head -1")
    DOWNLOADED_SIZE=$(server_file_size "$ALIAS" "$DOWNLOADED_PATH")
    
    log_info "Oryginał:  $ORIG_SIZE B"
    log_info "Pobrany:   $DOWNLOADED_SIZE B"
    
    if [ "$ORIG_SIZE" = "$DOWNLOADED_SIZE" ]; then
        log_ok "Rozmiary identyczne - to ten sam plik (MC/Loader bez zmian)."
        log_info "Usuwam pobrany duplikat..."
        server_remove_duplicate_fabric_jar "$ALIAS"
        log_ok "Duplikat usunięty."
    else
        log_warn "Rozmiary różne - prawdopodobnie zmiana wersji MC lub Fabric Loadera."
        echo ""
        if confirm "Podmienić oryginał na nowo pobrany (z backupem .old_<data>)?" "Y"; then
            OLD_LABEL=$(date +%Y%m%d_%H%M%S)
            log_info "Backup starego: fabric-server.jar.old_$OLD_LABEL"
            log_info "Podmiana w toku..."
            
            if server_replace_fabric_jar "$ALIAS" "$OLD_LABEL"; then
                log_ok "Podmiana zakończona."
            else
                log_error "Podmiana nieudana - sprawdź stan ręcznie."
                exit 1
            fi
        else
            log_warn "Pominięto podmianę. Plik 'fabric-server.jar' nadal stary."
            log_warn "Serwer może NIE wystartować. Sprawdź ręcznie."
        fi
    fi
fi

# Stan finalny
echo ""
log_info "Stan finalny fabric-server*.jar:"
server_check_fabric_jars "$ALIAS"

# ============================================================================
# PODSUMOWANIE
# ============================================================================

log_section "Zakończono aktualizację serwera: $SERVER_NAME"
log_ok "Wszystkie kroki wykonane pomyślnie."
echo ""
log_info "Następne kroki:"
log_info "  1. W Crafty Controller -> Start serwera '$SERVER_NAME'"
log_info "  2. Sprawdź log startu (czy wszystkie mody się załadowały)"
log_info "  3. Połącz się klientem i przetestuj w grze"

if [ "$ALIAS" = "test" ]; then
    log_info ""
    log_info "Po teście testowego, możesz aktualizować produkcję:"
    log_info "  ./scripts/update-server.sh tilinakor"
    log_info "  ./scripts/update-server.sh pandora"
    log_info "  ./scripts/update-server.sh ktilinakor"
fi
