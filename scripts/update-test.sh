#!/bin/bash
# update-test.sh - Aktualizacja modów w paczce testowej TiliNakor_test
#
# Tryby:
#   --check    Tylko raport co by się zaktualizowało (nic nie modyfikuje)
#   --apply    Aktualizacja + eksport mrpacka + commit + push
#   (default)  --check
#
# Użycie:
#   ./scripts/update-test.sh
#   ./scripts/update-test.sh --check
#   ./scripts/update-test.sh --apply

set -e  # zatrzymaj na pierwszym błędzie

# Załaduj wspólne funkcje
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/common.sh"

# ============================================================================
# KONFIGURACJA
# ============================================================================

readonly PACK_NAME="TiliNakor_test"
readonly REPO_ROOT="$(get_repo_root)"
readonly PACK_DIR="$REPO_ROOT/fabric/$PACK_NAME"

# ============================================================================
# WALIDACJA ŚRODOWISKA
# ============================================================================

require_command packwiz
require_command git
require_pack_dir "$PACK_DIR"

cd "$REPO_ROOT"
require_git_repo

# ============================================================================
# PARSOWANIE ARGUMENTÓW
# ============================================================================

MODE="check"  # default

case "${1:-}" in
    --check) MODE="check" ;;
    --apply) MODE="apply" ;;
    -h|--help)
        cat <<EOF
update-test.sh - aktualizacja modów w paczce testowej

UŻYCIE:
    ./scripts/update-test.sh [--check|--apply]

OPCJE:
    --check    Tylko raport (default): pokazuje co by się zaktualizowało
    --apply    Aktualizacja + eksport + commit + push

PRZYKŁADY:
    ./scripts/update-test.sh                # raport
    ./scripts/update-test.sh --check        # to samo, jawnie
    ./scripts/update-test.sh --apply        # faktyczna aktualizacja

ZAKRES:
    Operuje tylko na paczce $PACK_NAME.
    Dla paczek produkcyjnych użyj update-prod.sh.
EOF
        exit 0
        ;;
    "")
        # brak argumentu = default = check
        MODE="check"
        ;;
    *)
        log_error "Nieznana opcja: $1"
        log_error "Uruchom z --help aby zobaczyć dostępne opcje."
        exit 1
        ;;
esac

# ============================================================================
# TRYB CHECK
# ============================================================================

if [ "$MODE" = "check" ]; then
    log_section "Sprawdzanie aktualizacji dla $PACK_NAME"
    
    cd "$PACK_DIR"
    
    log_info "Uruchamiam packwiz update --all (tryb tylko raport, odpowiedź N)..."
    echo ""
    
    # Odpowiedź N automatycznie żeby tylko zobaczyć raport
    echo "N" | packwiz update --all
    
    echo ""
    log_ok "Raport zakończony. Żadne zmiany nie zostały zapisane."
    log_info "Aby zaaplikować aktualizacje uruchom: ./scripts/update-test.sh --apply"
    
    exit 0
fi

# ============================================================================
# TRYB APPLY
# ============================================================================

if [ "$MODE" = "apply" ]; then
    log_section "Aplikowanie aktualizacji dla $PACK_NAME"
    
    cd "$PACK_DIR"
    
    log_info "Uruchamiam packwiz update --all (tryb interaktywny)..."
    log_warn "Packwiz pokaże listę aktualizacji i poprosi o potwierdzenie [Y/n]."
    echo ""
    
    # Tryb interaktywny – user widzi listę i decyduje
    packwiz update --all
    
    echo ""
    log_section "Eksport mrpacka"
    
    log_info "Eksportuję mrpack..."
    packwiz modrinth export
    log_ok "Mrpack wyeksportowany."
    
    echo ""
    log_section "Sprawdzenie zmian git"
    
    cd "$REPO_ROOT"
    
    if ! git_has_changes; then
        log_warn "Brak zmian w gicie – packwiz nie zaktualizował żadnego moda."
        log_info "Możliwe że odpowiedziałeś N na pytanie packwiza, lub paczka była już aktualna."
        exit 0
    fi
    
    log_info "Zmiany do zacommit'owania:"
    git_show_status
    echo ""
    
    if ! confirm "Zacommit'ować i pushnąć zmiany?" "Y"; then
        log_warn "Pomijam commit + push. Zmiany pozostają lokalne."
        log_info "Aby skomitować ręcznie: cd $REPO_ROOT && git add -A && git commit -m '...' && git push"
        exit 0
    fi
    
    # Pytanie o opis commita
    DEFAULT_MSG="$PACK_NAME - aktualizacja modow"
    COMMIT_MSG=$(ask_input "Opis commita (Enter dla '$DEFAULT_MSG'):")
    if [ -z "$COMMIT_MSG" ]; then
        COMMIT_MSG="$DEFAULT_MSG"
    fi
    
    log_info "Commit z opisem: $COMMIT_MSG"
    git add -A
    git commit -m "$COMMIT_MSG"
    
    log_info "Push do origin..."
    git push
    
    echo ""
    log_ok "Aktualizacja zakończona!"
    log_info "Następne kroki:"
    log_info "  1. Odpal w Prismie instancję TiliNakor_test_auto, sprawdź klienta"
    log_info "  2. Jeśli mod jest 'both'/'server' – zaktualizuj serwer testowy mrpack-install"
    log_info "  3. Jeśli wszystko OK – odpal ./scripts/update-prod.sh"
    
    exit 0
fi
