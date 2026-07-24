#!/bin/bash
# add-mod-prod.sh - Dodanie moda z Modrinth do paczek produkcyjnych
#
# Zakres: TiliNakor + kTiliNakor
# Zakłada że mod został przetestowany w TiliNakor_test.
#
# Wykonuje:
#   1. Safety bramka: pyta czy test przeszedł pomyślnie
#   2. Sprawdza czy mod nie jest już w paczkach (jeśli tak - przerywa)
#   3. packwiz modrinth add w każdej paczce
#   4. packwiz modrinth export w każdej paczce
#   5. Commit + push
#
# Użycie:
#   ./scripts/add-mod-prod.sh <slug>
#   ./scripts/add-mod-prod.sh --project-id <ID> --version-id <ID>

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/common.sh"

# ============================================================================
# KONFIGURACJA
# ============================================================================

readonly PROD_PACKS="TiliNakor kTiliNakor"
readonly REPO_ROOT="$(get_repo_root)"

# ============================================================================
# WALIDACJA
# ============================================================================

require_command packwiz
require_command git

cd "$REPO_ROOT"
require_git_repo

# ============================================================================
# HELP
# ============================================================================

show_help() {
    cat <<EOF
add-mod-prod.sh - dodanie moda z Modrinth do paczek produkcyjnych

UŻYCIE:
    ./scripts/add-mod-prod.sh <slug>
    ./scripts/add-mod-prod.sh --project-id <ID> --version-id <ID>

ARGUMENTY:
    <slug>                Slug moda z Modrinth (np. 'krypton')
    --project-id <ID>     Ustala konkretną wersję. Wymaga --version-id.
    --version-id <ID>     Musi być podane razem z --project-id.

CO ROBI:
    1. Pyta czy mod został przetestowany na testowej (safety bramka)
    2. Sprawdza że mod nie jest już w paczkach TiliNakor / kTiliNakor
    3. Dodaje mod do TiliNakor i kTiliNakor
    4. Eksportuje mrpacki
    5. Commit + push

PACZKI:
    TiliNakor    obsługuje serwery TiliNakor (produkcja) + Pandora
    kTiliNakor   obsługuje serwer kTiliNakor (creative)

WYMAGANIA:
    - Wcześniej wykonaj: ./scripts/add-mod-test.sh <slug>
    - Sprawdź mod w grze na kliencie testowym
    - Zaktualizuj serwer testowy jeśli mod jest 'both'/'server'
    - Dopiero wtedy uruchom ten skrypt

NIE OBSŁUGUJE:
    - Modów z CurseForge (dodawaj ręcznie w każdej paczce osobno)
    - Selektywnego dodawania (skrypt dodaje do OBU produkcyjnych paczek)
      Jeśli chcesz tylko do jednej - użyj ręcznie:
      cd fabric/<paczka> && packwiz modrinth add <slug>
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

log_section "Dodawanie moda do paczek produkcyjnych"

if [ "$MODE" = "slug" ]; then
    log_info "Slug: $SLUG (najnowsza wersja)"
else
    log_info "project-id: $PROJECT_ID"
    log_info "version-id: $VERSION_ID"
fi
log_info "Paczki:  $PROD_PACKS"
echo ""

# ============================================================================
# SAFETY BRAMKA
# ============================================================================

log_warn "Ten skrypt zaktualizuje paczki produkcyjne."
log_warn "Klienci Prisma pobiorą moda przy najbliższym uruchomieniu instancji."
echo ""

if ! confirm "Czy mod został przetestowany na paczce TiliNakor_test (klient + serwer)?" "N"; then
    log_warn "Przerwane. Najpierw uruchom:"
    log_warn "  1. ./scripts/add-mod-test.sh <slug>"
    log_warn "  2. Test w Prismie (klient testowy)"
    log_warn "  3. ./scripts/update-server.sh test (jeśli mod jest 'both'/'server')"
    log_warn "  4. Test w grze"
    log_warn "  5. Wróć do tego skryptu"
    exit 0
fi

# ============================================================================
# SPRAWDZENIE CZY MOD JUŻ ISTNIEJE (tylko dla trybu slug)
# ============================================================================

if [ "$MODE" = "slug" ]; then
    for pack in $PROD_PACKS; do
        PW_FILE="$REPO_ROOT/fabric/$pack/mods/${SLUG}.pw.toml"
        if [ -f "$PW_FILE" ]; then
            log_error "Mod '$SLUG' już istnieje w paczce $pack."
            log_error "Plik: $PW_FILE"
            log_warn "Aby zaktualizować mod, użyj:"
            log_warn "  cd fabric/$pack && packwiz update $SLUG"
            exit 1
        fi
    done
fi

# ============================================================================
# DODANIE DO KAŻDEJ PACZKI
# ============================================================================

log_section "Dodawanie moda do paczek"

for pack in $PROD_PACKS; do
    log_info "Dodawanie do $pack..."
    cd "$REPO_ROOT/fabric/$pack"
    
    if [ "$MODE" = "slug" ]; then
        packwiz modrinth add "$SLUG"
    else
        packwiz modrinth add --project-id "$PROJECT_ID" --version-id "$VERSION_ID"
    fi
    
    log_ok "Dodano do $pack."
    cd "$REPO_ROOT"
done

# ============================================================================
# WERYFIKACJA + WYCIĄGNIĘCIE NAZWY
# ============================================================================

# Znajdź najświeższy pw.toml (z pierwszej paczki - powinny być identyczne)
FRESH_PW=$(ls -t "$REPO_ROOT/fabric/TiliNakor/mods/"*.pw.toml | head -1)
MOD_NAME=$(grep '^name = ' "$FRESH_PW" | sed 's/name = "//' | sed 's/"$//')
MOD_FILE=$(grep '^filename = ' "$FRESH_PW" | sed 's/filename = "//' | sed 's/"$//')
MOD_SIDE=$(grep '^side = ' "$FRESH_PW" | sed 's/side = "//' | sed 's/"$//')

# ============================================================================
# EKSPORT MRPACKÓW
# ============================================================================

log_section "Eksport mrpacków"

for pack in $PROD_PACKS; do
    log_info "Eksport $pack..."
    cd "$REPO_ROOT/fabric/$pack"
    packwiz modrinth export
done

cd "$REPO_ROOT"
log_ok "Oba mrpacki wyeksportowane."

# ============================================================================
# COMMIT + PUSH
# ============================================================================

log_section "Commit + push"

if ! git_has_changes; then
    log_warn "Brak zmian w gicie. Nic do commit'a."
    log_info "Prawdopodobnie mod był już identyczny w obu paczkach."
    exit 0
fi

log_info "Zmiany do zacommit'owania:"
git_show_status
echo ""

DEFAULT_MSG="TiliNakor + kTiliNakor - dodanie $MOD_NAME"

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

log_section "Zakończono dodawanie do produkcji"
log_ok "Mod: $MOD_NAME ($MOD_FILE, side=$MOD_SIDE)"
log_ok "Dodany do paczek: $PROD_PACKS"
echo ""
log_info "Następne kroki:"
log_info ""
log_info "1. Klienci Prisma:"
log_info "   Pobiorą moda przy najbliższym uruchomieniu instancji (auto-bootstrap)."
log_info ""

if [ "$MOD_SIDE" = "both" ] || [ "$MOD_SIDE" = "server" ]; then
    log_info "2. Serwery produkcyjne (mod jest '$MOD_SIDE'):"
    log_info "   Zaktualizuj przez update-server.sh:"
    log_info "     ./scripts/update-server.sh pandora     # najmniej krytyczny"
    log_info "     ./scripts/update-server.sh ktilinakor  # creative"
    log_info "     ./scripts/update-server.sh tilinakor   # produkcja - ostrzeż graczy!"
    log_info ""
    log_info "   Alternatywa dla pojedynczego moda (szybciej): wget bezpośrednio"
    log_info "   z URL w pw.toml na każdy serwer w folder mods/."
else
    log_info "2. Mod jest 'client' - serwery NIE wymagają aktualizacji."
    log_info "   Gracze dostaną moda przez bootstrap i będą mogli używać na wszystkich serwerach."
fi
