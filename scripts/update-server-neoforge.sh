#!/bin/bash
# update-server-neoforge.sh - Aktualizacja serwera NeoForge na QNAP
#
# Analogiczny do update-server.sh (Fabric), bez logiki fabric-server.jar
# (NeoForge instaluje się raz przez installer, mrpack-install nie dotyka loadera).
#
# Użycie:
#   ./scripts/update-server-neoforge.sh <alias>
#   ./scripts/update-server-neoforge.sh roshar

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/common.sh"
source "$SCRIPT_DIR/lib/server.sh"

if [ $# -eq 0 ] || [ "${1:-}" = "-h" ] || [ "${1:-}" = "--help" ]; then
    cat <<EOF
update-server-neoforge.sh - aktualizacja serwera NeoForge na QNAP

UŻYCIE:
    ./scripts/update-server-neoforge.sh <alias>

DOSTĘPNE ALIASY (NeoForge):
    roshar    Roshar - Create SMP (UUID 1f9afc98-...)

CO ROBI:
    1. Sprawdza warunki (SSH, mrpack, paczka)
    2. Pyta czy serwer został zatrzymany w Crafty
    3. Wgrywa mrpack na QNAP (SCP)
    4. Czyści folder mods/ (zapobiega duplikatom starych/nowych wersji)
    5. Uruchamia mrpack-install w kontenerze docker

RÓŻNICA WZGLĘDEM update-server.sh (Fabric):
    Brak sprzątania loadera - NeoForge instaluje się raz przez installer.
EOF
    exit 0
fi

ALIAS="$1"

require_command ssh
require_command scp
require_command git

if ! server_alias_exists "$ALIAS"; then
    log_error "Nieznany alias serwera: $ALIAS"
    log_error "Dostępne aliasy: $(server_list_aliases)"
    exit 1
fi

UUID=$(server_get_uuid "$ALIAS")
PACK_NAME=$(server_get_pack "$ALIAS")
SERVER_NAME=$(server_get_name "$ALIAS")
REPO_ROOT="$(get_repo_root)"
PACK_DIR="$REPO_ROOT/neoforge/$PACK_NAME"

log_section "Aktualizacja serwera NeoForge: $SERVER_NAME"
log_info "Alias:    $ALIAS"
log_info "UUID:     $UUID"
log_info "Paczka:   $PACK_NAME"

require_pack_dir "$PACK_DIR"

# Szukamy mrpacka po wzorcu - nazwa pliku pochodzi z pola 'name' w pack.toml
# (np. "Roshar-1.0.0.mrpack"), które może różnić się wielkością liter od
# nazwy folderu/aliasu (np. "roshar").
LOCAL_MRPACK=$(ls "$PACK_DIR"/*.mrpack 2>/dev/null | head -1)

if [ -z "$LOCAL_MRPACK" ]; then
    log_error "Brak lokalnego mrpacka w: $PACK_DIR"
    log_error "Najpierw: cd $PACK_DIR && packwiz mr export"
    exit 1
fi
log_ok "Mrpack lokalny: $LOCAL_MRPACK ($(du -h "$LOCAL_MRPACK" | cut -f1))"

log_info "Sprawdzanie połączenia SSH do QNAP..."
qnap_check_connection || exit 1
log_ok "SSH OK"

log_section "Safety bramka"
log_warn "Jeśli serwer nadal działa - zatrzymaj go TERAZ w panelu Crafty."
echo ""
if ! confirm "Czy serwer '$SERVER_NAME' został zatrzymany w Crafty?" "N"; then
    log_warn "Anulowane."
    exit 0
fi

log_section "1/3 - Wgrywanie mrpacka na QNAP"
REMOTE_DIR=$(server_remote_dir "$ALIAS")
server_upload_mrpack "$ALIAS" "$LOCAL_MRPACK"
EXISTING_MRPACK=$(server_check_mrpack "$ALIAS")
[ -z "$EXISTING_MRPACK" ] && { log_error "Po SCP nie widać mrpacka na QNAP."; exit 1; }
log_ok "Weryfikacja: $EXISTING_MRPACK"

log_section "2/3 - Czyszczenie folderu mods/"
log_info "Kluczowy krok - zapobiega duplikatom (stara+nowa wersja tego samego moda)."
MODS_COUNT_BEFORE=$(qnap_exec "ls $REMOTE_DIR/mods/ 2>/dev/null | wc -l")
server_clear_mods "$ALIAS"
MODS_COUNT_AFTER=$(qnap_exec "ls $REMOTE_DIR/mods/ 2>/dev/null | wc -l")
log_ok "Przed: $MODS_COUNT_BEFORE plików -> Po: $MODS_COUNT_AFTER (powinno być 0)"

log_section "3/3 - Mrpack-install w kontenerze docker"
CONTAINER_DIR=$(server_container_dir "$ALIAS")
MRPACK_FILENAME=$(basename "$LOCAL_MRPACK")
qnap_docker_exec "$QNAP_MRPACK_INSTALL" "$CONTAINER_DIR/$MRPACK_FILENAME" --server-dir "$CONTAINER_DIR"
log_ok "Mrpack-install zakończony."

log_section "Zakończono aktualizację serwera: $SERVER_NAME"
log_info "Następne kroki:"
log_info "  1. Start serwera '$SERVER_NAME' w Crafty"
log_info "  2. Sprawdź log startu"
log_info "  3. PAMIĘTAJ: jeśli robiłeś packwiz update/remove/install przed tym"
log_info "     skryptem, upewnij się że jest 'git push' - inaczej klienci"
log_info "     z packwiz-installer-bootstrap nie dostaną tej zmiany."
