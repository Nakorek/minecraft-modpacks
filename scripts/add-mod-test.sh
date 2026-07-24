#!/bin/bash
# add-mod-test.sh - Dodanie moda z Modrinth do paczki testowej TiliNakor_test
#
# Wykonuje:
#   1. Sprawdza czy mod już istnieje (jeśli tak - przerywa)
#   2. packwiz modrinth add
#   3. packwiz modrinth export
#   4. Commit + push (jeśli coś się zmieniło)
#
# Użycie:
#   ./scripts/add-mod-test.sh <slug>
#   ./scripts/add-mod-test.sh --project-id <ID> --version-id <ID>
#
# Po sukcesie: test w Prismie, jeśli OK - ./scripts/add-mod-prod.sh <slug>
#
# UWAGA: obsługuje TYLKO Modrinth. Mody z CurseForge dodawaj ręcznie.

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/common.sh"

# ============================================================================
# KONFIGURACJA
# ============================================================================

readonly PACK_NAME="TiliNakor_test"
readonly REPO_ROOT="$(get_repo_root)"
readonly PACK_DIR="$REPO_ROOT/fabric/$PACK_NAME"

# ============================================================================
# WALIDACJA
# ============================================================================

require_command packwiz
require_command git
require_pack_dir "$PACK_DIR"

cd "$REPO_ROOT"
require_git_repo

# ============================================================================
# HELP
# ============================================================================

show_help() {
    cat <<EOF
add-mod-test.sh - dodanie moda z Modrinth do paczki testowej

UŻYCIE:
    ./scripts/add-mod-test.sh <slug>
    ./scripts/add-mod-test.sh --project-id <ID> --version-id <ID>

ARGUMENTY:
    <slug>                Slug moda z Modrinth (część URL, np. 'krypton')
                          Pobiera NAJNOWSZĄ wersję dla obecnej MC.

    --project-id <ID>     Ustala konkretną wersję. Wymaga --version-id.
    --version-id <ID>     Musi być podane razem z --project-id.

CO ROBI:
    1. Sprawdza czy mod nie jest już w paczce (jeśli tak - przerywa)
    2. Dodaje mod do TiliNakor_test
    3. Eksportuje mrpack
    4. Commit + push

PO SUKCESIE:
    1. Odpal klienta testowego (TiliNakor_test_auto w Prismie)
    2. Sprawdź w grze że mod działa
    3. Jeśli mod jest 'both' lub 'server' - zaktualizuj serwer testowy:
       ./scripts/update-server.sh test
    4. Jeśli wszystko OK - dodaj do produkcji:
       ./scripts/add-mod-prod.sh <slug>

NIE OBSŁUGUJE:
    - Modów z CurseForge (pułapki z podmianą bibliotek). Dodawaj ręcznie:
      cd fabric/$PACK_NAME && packwiz curseforge add <slug>
EOF
}

if [ $# -eq 0 ] || [ "${1:-}" = "-h" ] || [ "${1:-}" = "--help" ]; then
    show_help
    exit 0
fi

# ============================================================================
# PARSOWANIE ARGUMENTÓW
# ============================================================================

MODE=""
SLUG=""
PROJECT_ID=""
VERSION_ID=""

if [ "$1" = "--project-id" ] || [ "$1" = "--version-id" ]; then
    MODE="version"
    while [ $# -gt 0 ]; do
        case "$1" in
            --project-id)
                PROJECT_ID="$2"
                shift 2
                ;;
            --version-id)
                VERSION_ID="$2"
                shift 2
                ;;
            *)
                log_error "Nieoczekiwany argument: $1"
                log_error "Użyj --help aby zobaczyć składnię."
                exit 1
                ;;
        esac
    done
    
    if [ -z "$PROJECT_ID" ] || [ -z "$VERSION_ID" ]; then
        log_error "Musisz podać zarówno --project-id jak i --version-id."
        exit 1
    fi
else
    MODE="slug"
    SLUG="$1"
fi

# ============================================================================
# INFO PRZED STARTEM
# ============================================================================

log_section "Dodawanie moda do paczki testowej"

if [ "$MODE" = "slug" ]; then
    log_info "Slug: $SLUG (najnowsza wersja)"
else
    log_info "project-id: $PROJECT_ID"
    log_info "version-id: $VERSION_ID"
fi
log_info "Paczka:  $PACK_NAME"
echo ""

# ============================================================================
# SPRAWDZENIE CZY MOD JUŻ ISTNIEJE (tylko dla trybu slug)
# ============================================================================

if [ "$MODE" = "slug" ]; then
    PW_FILE="$PACK_DIR/mods/${SLUG}.pw.toml"
    if [ -f "$PW_FILE" ]; then
        log_error "Mod '$SLUG' już istnieje w paczce $PACK_NAME."
        log_error "Plik: $PW_FILE"
        log_warn "Aby zaktualizować mod, użyj:"
        log_warn "  cd $PACK_DIR && packwiz update $SLUG"
        log_warn "Aby usunąć i dodać ponownie:"
        log_warn "  cd $PACK_DIR && packwiz remove $SLUG && packwiz modrinth add $SLUG"
        exit 1
    fi
fi

# ============================================================================
# DODANIE MODA
# ============================================================================

log_section "Dodawanie moda"

cd "$PACK_DIR"

if [ "$MODE" = "slug" ]; then
    packwiz modrinth add "$SLUG"
else
    packwiz modrinth add --project-id "$PROJECT_ID" --version-id "$VERSION_ID"
fi

cd "$REPO_ROOT"

# ============================================================================
# WERYFIKACJA + WYCIĄGNIĘCIE NAZWY
# ============================================================================

# Znajdź najświeższy pw.toml (ostatnio zmodyfikowany)
FRESH_PW=$(ls -t "$PACK_DIR/mods/"*.pw.toml | head -1)
MOD_NAME=$(grep '^name = ' "$FRESH_PW" | sed 's/name = "//' | sed 's/"$//')
MOD_FILE=$(grep '^filename = ' "$FRESH_PW" | sed 's/filename = "//' | sed 's/"$//')
MOD_SIDE=$(grep '^side = ' "$FRESH_PW" | sed 's/side = "//' | sed 's/"$//')

log_ok "Dodano: $MOD_NAME ($MOD_FILE)"
log_info "Side: $MOD_SIDE"

# ============================================================================
# EKSPORT
# ============================================================================

log_section "Eksport mrpacka"

cd "$PACK_DIR"
packwiz modrinth export
cd "$REPO_ROOT"
log_ok "Mrpack wyeksportowany."

# ============================================================================
# COMMIT + PUSH (tylko jeśli coś się zmieniło)
# ============================================================================

log_section "Commit + push"

if ! git_has_changes; then
    log_warn "Brak zmian w gicie. Nic do commit'a."
    log_info "Prawdopodobnie mod był już identyczny."
    exit 0
fi

log_info "Zmiany do zacommit'owania:"
git_show_status
echo ""

DEFAULT_MSG="$PACK_NAME - dodanie $MOD_NAME"

COMMIT_MSG=$(ask_input "Opis commita (Enter dla '$DEFAULT_MSG'):")
if [ -z "$COMMIT_MSG" ]; then
    COMMIT_MSG="$DEFAULT_MSG"
fi

log_info "Commit z opisem: $COMMIT_MSG"
git add -A
git commit -m "$COMMIT_MSG"

log_info "Push do origin..."
git push

# ============================================================================
# PODSUMOWANIE
# ============================================================================

log_section "Zakończono dodawanie do testowej"
log_ok "Mod: $MOD_NAME ($MOD_FILE, side=$MOD_SIDE)"
echo ""
log_info "Następne kroki:"
log_info ""
log_info "1. Klient testowy:"
log_info "   Odpal TiliNakor_test_auto w Prismie - bootstrap pobierze moda."
log_info "   Sprawdź w grze że działa."
log_info ""

if [ "$MOD_SIDE" = "both" ] || [ "$MOD_SIDE" = "server" ]; then
    log_info "2. Serwer testowy (mod jest '$MOD_SIDE'):"
    log_info "   ./scripts/update-server.sh test"
    log_info "   (najpierw Stop w Crafty)"
    log_info ""
    log_info "3. Test w grze na serwerze"
    log_info ""
    log_info "4. Jeśli OK - dodaj do produkcji:"
else
    log_info "2. Mod jest 'client' - serwer nie wymaga aktualizacji."
    log_info ""
    log_info "3. Jeśli klient działa - dodaj do produkcji:"
fi

if [ "$MODE" = "slug" ]; then
    log_info "   ./scripts/add-mod-prod.sh $SLUG"
else
    log_info "   ./scripts/add-mod-prod.sh --project-id $PROJECT_ID --version-id $VERSION_ID"
fi
