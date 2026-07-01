#!/bin/bash
# update-prod.sh - Aktualizacja modów w paczkach produkcyjnych
#
# Zakres:
#   - TiliNakor (obsługuje serwery TiliNakor + Pandora)
#   - kTiliNakor (obsługuje serwer kTiliNakor)
#
# Wykonuje:
#   1. Safety: potwierdź że test przeszedł pomyślnie
#   2. Dla każdej paczki produkcyjnej (interaktywnie Y/N):
#      - packwiz update --all (packwiz sam pyta o Y/N)
#      - packwiz modrinth export
#   3. Commit + push (pyta o opis)
#   4. Info końcowe: co dalej (update-server.sh)
#
# Użycie:
#   ./scripts/update-prod.sh
#
# Nota: paczka TiliNakor_test ma osobny skrypt update-test.sh

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/common.sh"

# ============================================================================
# KONFIGURACJA
# ============================================================================

# Lista paczek produkcyjnych w kolejności aktualizacji
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

if [ "${1:-}" = "-h" ] || [ "${1:-}" = "--help" ]; then
    cat <<EOF
update-prod.sh - aktualizacja modów w paczkach produkcyjnych

UŻYCIE:
    ./scripts/update-prod.sh

CO ROBI:
    1. Pyta czy test przeszedł pomyślnie (safety bramka)
    2. Dla każdej paczki produkcyjnej (TiliNakor, kTiliNakor):
       - pyta Y/N czy aktualizować
       - jeśli Y: uruchamia packwiz update --all interaktywnie
       - eksportuje świeży mrpack
    3. Commit + push zaktualizowanych zmian
    4. Podpowiada następne kroki (update-server.sh)

PACZKI:
    TiliNakor    obsługuje serwery TiliNakor (produkcja) + Pandora
    kTiliNakor   obsługuje serwer kTiliNakor (creative)

WYMAGANIA:
    - Test na paczce TiliNakor_test przeszedł pomyślnie
    - Klient testowy sprawdzony w Prismie
    - Serwer testowy zaktualizowany i sprawdzony w grze

PRZED PRODUKCJĄ:
    - Uruchom ./scripts/update-test.sh --apply (test paczki)
    - Zaktualizuj serwer testowy: ./scripts/update-server.sh test
    - Sprawdź w grze że wszystko działa
    - DOPIERO POTEM uruchom ten skrypt
EOF
    exit 0
fi

# ============================================================================
# SAFETY BRAMKA
# ============================================================================

log_section "Aktualizacja paczek produkcyjnych"
log_warn "Ten skrypt zaktualizuje paczki TiliNakor i kTiliNakor."
log_warn "Po pushu klienci Prisma pobiorą nowe wersje modów przy uruchomieniu instancji."
log_warn "Serwery produkcyjne będą wymagały osobnej aktualizacji przez update-server.sh."
echo ""

if ! confirm "Czy test na paczce TiliNakor_test przeszedł pomyślnie (klient + serwer testowy)?" "N"; then
    log_warn "Przerwane. Najpierw uruchom:"
    log_warn "  1. ./scripts/update-test.sh --apply"
    log_warn "  2. ./scripts/update-server.sh test"
    log_warn "  3. Sprawdź w grze"
    log_warn "  4. Wróć do tego skryptu"
    exit 0
fi

# ============================================================================
# ITERACJA PRZEZ PACZKI PRODUKCYJNE
# ============================================================================

# Lista paczek które user zaakceptował do aktualizacji (do commita)
UPDATED_PACKS=""

for PACK_NAME in $PROD_PACKS; do
    PACK_DIR="$REPO_ROOT/fabric/$PACK_NAME"
    
    log_section "Paczka: $PACK_NAME"
    
    if [ ! -d "$PACK_DIR" ]; then
        log_error "Katalog paczki nie istnieje: $PACK_DIR"
        log_warn "Pomijam $PACK_NAME."
        continue
    fi
    
    if ! confirm "Zaktualizować paczkę $PACK_NAME?" "Y"; then
        log_info "Pominięto $PACK_NAME."
        continue
    fi
    
    cd "$PACK_DIR"
    
    log_info "Uruchamiam packwiz update --all (tryb interaktywny)..."
    log_warn "Packwiz pokaże listę i poprosi o Y/N."
    echo ""
    
    packwiz update --all
    
    echo ""
    log_info "Eksportuję mrpack..."
    packwiz modrinth export
    log_ok "Mrpack $PACK_NAME wyeksportowany."
    
    UPDATED_PACKS="$UPDATED_PACKS $PACK_NAME"
    
    cd "$REPO_ROOT"
done

# ============================================================================
# COMMIT + PUSH
# ============================================================================

log_section "Commit + push"

if [ -z "$UPDATED_PACKS" ]; then
    log_warn "Żadna paczka nie została zaktualizowana. Kończę."
    exit 0
fi

# Trim wiodące spacje
UPDATED_PACKS=$(echo "$UPDATED_PACKS" | sed 's/^ *//')

if ! git_has_changes; then
    log_warn "Brak zmian w gicie (packwiz nie zaktualizował nic pomimo Y)."
    log_info "Możliwe że paczki były już aktualne."
    exit 0
fi

log_info "Zmiany do zacommit'owania:"
git_show_status
echo ""

if ! confirm "Zacommit'ować i pushnąć zmiany?" "Y"; then
    log_warn "Pomijam commit + push. Zmiany pozostają lokalne."
    log_info "Aby skomitować ręcznie:"
    log_info "  cd $REPO_ROOT && git add -A && git commit -m '...' && git push"
    exit 0
fi

# Buduj domyślny opis commita
DEFAULT_MSG="$(echo "$UPDATED_PACKS" | tr ' ' '+') - aktualizacja modow"

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
# PODSUMOWANIE + NASTĘPNE KROKI
# ============================================================================

log_section "Zakończono aktualizację paczek produkcyjnych"
log_ok "Zaktualizowane paczki:$UPDATED_PACKS"
echo ""
log_info "Następne kroki:"
log_info ""
log_info "1. Klienci Prisma:"
log_info "   Przy następnym uruchomieniu instancji bootstrap pobierze nowe wersje modów."
log_info "   Nic ręcznie nie trzeba - kolejny launch = auto-update."
log_info ""
log_info "2. Serwery produkcyjne - zaktualizuj przez update-server.sh:"

# Sugestie zależne od zaktualizowanych paczek
if echo "$UPDATED_PACKS" | grep -q "TiliNakor$\|TiliNakor "; then
    log_info "   ./scripts/update-server.sh pandora     # najpierw najmniej krytyczny"
    log_info "   ./scripts/update-server.sh tilinakor   # produkcja - ostrzeż graczy!"
fi
if echo "$UPDATED_PACKS" | grep -q "kTiliNakor"; then
    log_info "   ./scripts/update-server.sh ktilinakor  # creative"
fi

log_info ""
log_info "3. Przed każdym update-server.sh zatrzymaj serwer w Crafty."
