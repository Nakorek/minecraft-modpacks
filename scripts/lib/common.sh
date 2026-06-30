#!/bin/bash
# common.sh - Wspólne funkcje dla skryptów minecraft-modpacks
# Sourceuj na początku skryptu: source "$(dirname "$0")/lib/common.sh"

# ============================================================================
# KOLORY
# ============================================================================

# Sprawdza czy terminal wspiera kolory (czy stdout to terminal)
if [ -t 1 ]; then
    readonly C_RESET='\033[0m'
    readonly C_RED='\033[0;31m'
    readonly C_GREEN='\033[0;32m'
    readonly C_YELLOW='\033[0;33m'
    readonly C_BLUE='\033[0;34m'
    readonly C_MAGENTA='\033[0;35m'
    readonly C_CYAN='\033[0;36m'
    readonly C_BOLD='\033[1m'
else
    readonly C_RESET=''
    readonly C_RED=''
    readonly C_GREEN=''
    readonly C_YELLOW=''
    readonly C_BLUE=''
    readonly C_MAGENTA=''
    readonly C_CYAN=''
    readonly C_BOLD=''
fi

# ============================================================================
# FUNKCJE LOGOWANIA
# ============================================================================

# Komunikat informacyjny (niebieski)
log_info() {
    echo -e "${C_BLUE}[INFO]${C_RESET} $*"
}

# Komunikat sukcesu (zielony)
log_ok() {
    echo -e "${C_GREEN}[OK]${C_RESET} $*"
}

# Komunikat ostrzeżenia (żółty)
log_warn() {
    echo -e "${C_YELLOW}[OSTRZEŻENIE]${C_RESET} $*"
}

# Komunikat błędu (czerwony) – na stderr
log_error() {
    echo -e "${C_RED}[BŁĄD]${C_RESET} $*" >&2
}

# Nagłówek sekcji (cyan, bold)
log_section() {
    echo ""
    echo -e "${C_BOLD}${C_CYAN}═══ $* ═══${C_RESET}"
}

# ============================================================================
# WALIDACJA
# ============================================================================

# Sprawdza czy komenda jest dostępna w PATH
# Użycie: require_command packwiz
require_command() {
    local cmd="$1"
    if ! command -v "$cmd" >/dev/null 2>&1; then
        log_error "Komenda '$cmd' nie jest dostępna w PATH."
        log_error "Sprawdź konfigurację ~/.zshrc i upewnij się że PATH zawiera odpowiednie katalogi."
        exit 1
    fi
}

# Sprawdza czy katalog paczki istnieje i jest paczką packwiz
# Użycie: require_pack_dir "/path/do/paczki"
require_pack_dir() {
    local dir="$1"
    if [ ! -d "$dir" ]; then
        log_error "Katalog paczki nie istnieje: $dir"
        exit 1
    fi
    if [ ! -f "$dir/pack.toml" ]; then
        log_error "Brak pack.toml w katalogu: $dir"
        log_error "To nie wygląda jak paczka packwiz."
        exit 1
    fi
}

# Sprawdza czy jesteśmy w repo gita (lub że można dostać się do repo z wyższego poziomu)
require_git_repo() {
    if ! git rev-parse --git-dir >/dev/null 2>&1; then
        log_error "Nie jestem w repozytorium git."
        exit 1
    fi
}

# ============================================================================
# INTERAKCJA Z UŻYTKOWNIKIEM
# ============================================================================

# Pyta o potwierdzenie Y/N. Domyślnie N.
# Użycie: if confirm "Czy kontynuować"; then ...
# Zwraca 0 jeśli Y/y, 1 w przeciwnym razie
confirm() {
    local prompt="$1"
    local default="${2:-N}"
    local yn_hint="[y/N]"
    
    if [ "$default" = "Y" ] || [ "$default" = "y" ]; then
        yn_hint="[Y/n]"
    fi
    
    echo -en "${C_YELLOW}${prompt} ${yn_hint}${C_RESET} "
    read -r answer
    
    # Jeśli puste, użyj default
    if [ -z "$answer" ]; then
        answer="$default"
    fi
    
    case "$answer" in
        [Yy]|[Yy][Ee][Ss]) return 0 ;;
        *) return 1 ;;
    esac
}

# Pyta o tekst (np. opis commita)
# Użycie: msg=$(ask_input "Opis commita:")
ask_input() {
    local prompt="$1"
    echo -en "${C_CYAN}${prompt}${C_RESET} " >&2
    read -r input
    echo "$input"
}

# ============================================================================
# ŚCIEŻKI – wykrywanie głównego katalogu repo
# ============================================================================

# Zwraca absolutną ścieżkę do głównego katalogu repo (minecraft-modpacks/)
# Działa niezależnie od miejsca uruchomienia skryptu
get_repo_root() {
    local script_dir
    script_dir="$(cd "$(dirname "${BASH_SOURCE[1]}")" && pwd)"
    # Skrypt jest w scripts/, więc repo root to wyżej
    echo "$(dirname "$script_dir")"
}

# ============================================================================
# OPERACJE GIT
# ============================================================================

# Sprawdza czy są jakieś zmiany w gicie (zwraca 0 jeśli są)
git_has_changes() {
    if [ -n "$(git status --porcelain)" ]; then
        return 0
    else
        return 1
    fi
}

# Pokazuje status (kolorowy)
git_show_status() {
    git status --short
}
