#!/bin/bash
# server.sh - Funkcje pomocnicze do operacji na serwerach QNAP
# Sourceuj po common.sh: source "$(dirname "$0")/lib/server.sh"
#
# Wymaga skonfigurowanego ssh: "ssh qnap" musi działać bez hasła.
# Zobacz README sekcja "SSH na QNAP".

# ============================================================================
# KONFIGURACJA QNAP
# ============================================================================

readonly QNAP_SSH_HOST="qnap"  # alias z ~/.ssh/config
readonly QNAP_SERVERS_BASE="/share/Container/crafty/servers"
# Ta sama ścieżka widziana z wnętrza kontenera Crafty (bind mount).
# Host: /share/Container/crafty/servers -> Container: /crafty/servers
readonly QNAP_SERVERS_BASE_CONTAINER="/crafty/servers"
readonly QNAP_DOCKER_CONTAINER="crafty_container"
readonly QNAP_MRPACK_INSTALL="/crafty/import/tools/mrpack-install-linux"
# Docker na QNAP jest w niestandardowej lokalizacji (Container Station).
# Non-interactive SSH nie ładuje PATH z profile, więc podajemy pełną ścieżkę.
readonly QNAP_DOCKER_BIN="/share/ZFS530_DATA/.qpkg/container-station/bin/docker"

# ============================================================================
# MAPOWANIE ALIASÓW SERWERÓW
# ============================================================================

# Zwraca UUID serwera dla podanego aliasu
# Użycie: uuid=$(server_get_uuid test)
server_get_uuid() {
    case "$1" in
        test)        echo "fc17ba3e-b41b-4fd3-b012-52749bd58833" ;;
        tilinakor)   echo "5071df24-5a62-48d9-b038-c910d088898f" ;;
        pandora)     echo "7d468085-bc02-4e7b-b53a-54ad9f4b03e3" ;;
        ktilinakor)  echo "eff8a0a1-9645-4d4b-a1d5-74fe9bfabf30" ;;
        *)           echo "" ;;
    esac
}

# Zwraca nazwę paczki (folder w fabric/) dla serwera
# Użycie: pack=$(server_get_pack test)
server_get_pack() {
    case "$1" in
        test)        echo "TiliNakor_test" ;;
        tilinakor)   echo "TiliNakor" ;;
        pandora)     echo "TiliNakor" ;;  # ta sama paczka co TiliNakor
        ktilinakor)  echo "kTiliNakor" ;;
        *)           echo "" ;;
    esac
}

# Zwraca przyjazną nazwę serwera dla komunikatów
# Użycie: name=$(server_get_name test)
server_get_name() {
    case "$1" in
        test)        echo "TiliNakor test" ;;
        tilinakor)   echo "TiliNakor (produkcja)" ;;
        pandora)     echo "Pandora (zamrożony)" ;;
        ktilinakor)  echo "kTiliNakor (creative)" ;;
        *)           echo "" ;;
    esac
}

# Lista wszystkich dostępnych aliasów (do help)
server_list_aliases() {
    echo "test, tilinakor, pandora, ktilinakor"
}

# Sprawdza czy alias istnieje. Zwraca 0 jeśli tak, 1 jeśli nie.
server_alias_exists() {
    local uuid
    uuid=$(server_get_uuid "$1")
    [ -n "$uuid" ]
}

# ============================================================================
# OPERACJE SSH/SCP NA QNAP
# ============================================================================

# Sprawdza czy SSH do QNAP działa bez hasła
qnap_check_connection() {
    if ! ssh -o BatchMode=yes -o ConnectTimeout=5 "$QNAP_SSH_HOST" "true" 2>/dev/null; then
        log_error "Nie mogę połączyć się z QNAP przez SSH (host: $QNAP_SSH_HOST)."
        log_error "Sprawdź:"
        log_error "  1. Czy QNAP jest dostępny w sieci (ping 172.20.20.10)"
        log_error "  2. Czy ssh-key został wgrany (test: ssh qnap 'echo ok')"
        log_error "  3. Czy ~/.ssh/config zawiera wpis dla 'qnap'"
        return 1
    fi
    return 0
}

# Wykonuje komendę na QNAP przez SSH
# Użycie: qnap_exec "ls /share/Container/crafty/servers"
qnap_exec() {
    ssh "$QNAP_SSH_HOST" "$@"
}

# Wykonuje komendę w docker_container Crafty
# Użycie: qnap_docker_exec /crafty/import/tools/mrpack-install-linux arg1 arg2 ...
# 
# Naśladujemy zachowanie: ssh qnap "/path/docker" exec container cmd arg1 arg2
# (docker binary w cudzysłowach żeby chronić przed word splitting przez ssh,
#  reszta argumentów przekazywana bez modyfikacji - ssh składa je w string)
qnap_docker_exec() {
    ssh "$QNAP_SSH_HOST" "$QNAP_DOCKER_BIN" exec "$QNAP_DOCKER_CONTAINER" "$@"
}

# Kopiuje plik z Maca na QNAP przez SCP
# Użycie: qnap_scp_to /local/path /remote/path
qnap_scp_to() {
    local local_path="$1"
    local remote_path="$2"
    scp "$local_path" "$QNAP_SSH_HOST:$remote_path"
}

# ============================================================================
# WYSOKOPOZIOMOWE OPERACJE NA SERWERZE
# ============================================================================

# Zwraca pełną ścieżkę do folderu serwera na QNAP (widok hosta)
# Użycie: dir=$(server_remote_dir test)
server_remote_dir() {
    local alias="$1"
    local uuid
    uuid=$(server_get_uuid "$alias")
    if [ -z "$uuid" ]; then
        return 1
    fi
    echo "$QNAP_SERVERS_BASE/$uuid"
}

# Zwraca ścieżkę do folderu serwera widoczną z WNĘTRZA kontenera Crafty
# (bind mount /share/Container/crafty/servers -> /crafty/servers).
# Do użycia w komendach 'docker exec' - mrpack-install i inne widzą tę ścieżkę.
# Użycie: dir=$(server_container_dir test)
server_container_dir() {
    local alias="$1"
    local uuid
    uuid=$(server_get_uuid "$alias")
    if [ -z "$uuid" ]; then
        return 1
    fi
    echo "$QNAP_SERVERS_BASE_CONTAINER/$uuid"
}

# Sprawdza czy mrpack istnieje w folderze serwera na QNAP
# Zwraca nazwę pliku mrpacka lub pusty string
# Użycie: mrpack=$(server_check_mrpack test)
server_check_mrpack() {
    local alias="$1"
    local remote_dir
    remote_dir=$(server_remote_dir "$alias")
    qnap_exec "ls $remote_dir/*.mrpack 2>/dev/null | head -1"
}

# Wgrywa lokalny mrpack na QNAP do folderu serwera
# Użycie: server_upload_mrpack test /local/path/to/file.mrpack
server_upload_mrpack() {
    local alias="$1"
    local local_mrpack="$2"
    local remote_dir
    remote_dir=$(server_remote_dir "$alias")
    
    qnap_scp_to "$local_mrpack" "$remote_dir/"
}

# Czyści folder mods na serwerze (rm mods/*.jar)
# Użycie: server_clear_mods test
server_clear_mods() {
    local alias="$1"
    local remote_dir
    remote_dir=$(server_remote_dir "$alias")
    
    qnap_exec "rm -f $remote_dir/mods/*.jar"
}

# Uruchamia mrpack-install w kontenerze docker dla serwera
# Użycie: server_run_mrpack_install test <nazwa-paczki>
# gdzie <nazwa-paczki> to np. "TiliNakor_test" (foldername paczki)
server_run_mrpack_install() {
    local alias="$1"
    local pack_name="$2"
    # Używamy ścieżek widocznych z WNĘTRZA kontenera (bind mount).
    # Host /share/Container/crafty/servers/<UUID> = kontener /crafty/servers/<UUID>
    local container_dir
    container_dir=$(server_container_dir "$alias")
    local mrpack_path="$container_dir/${pack_name}-1.0.0.mrpack"
    
    qnap_docker_exec "$QNAP_MRPACK_INSTALL" "$mrpack_path" --server-dir "$container_dir"
}

# Sprawdza stan plików fabric-server.jar na serwerze
# Zwraca multi-line z ls -la
# Użycie: server_check_fabric_jars test
server_check_fabric_jars() {
    local alias="$1"
    local remote_dir
    remote_dir=$(server_remote_dir "$alias")
    
    qnap_exec "ls -la $remote_dir/fabric-server*.jar 2>/dev/null"
}

# Zwraca rozmiar pliku w bajtach
# Użycie: size=$(server_file_size test /path/to/file)
server_file_size() {
    local alias="$1"
    local file_path="$2"
    qnap_exec "stat -c %s '$file_path' 2>/dev/null"
}

# Usuwa pobrany duplikat fabric-server (gdy MC ta sama)
# Użycie: server_remove_duplicate_fabric_jar test
server_remove_duplicate_fabric_jar() {
    local alias="$1"
    local remote_dir
    remote_dir=$(server_remote_dir "$alias")
    
    # Znajdź plik typu fabric-server-mc.X-loader.Y-launcher.Z.jar (nowo pobrany duplikat)
    qnap_exec "rm -f $remote_dir/fabric-server-mc.*-loader.*-launcher.*.jar"
}

# Podmienia fabric-server.jar na nowy (gdy MC/Loader się zmieniło)
# Zmieni: fabric-server.jar -> fabric-server.jar.old_<opis>
#         fabric-server-mc.X-loader.Y-launcher.Z.jar -> fabric-server.jar
# Użycie: server_replace_fabric_jar test "26.1.2"
server_replace_fabric_jar() {
    local alias="$1"
    local old_label="$2"  # np. "26.1.2"
    local remote_dir
    remote_dir=$(server_remote_dir "$alias")
    
    # Bezpieczna procedura: każdy krok osobno, weryfikacja po drodze
    # UWAGA: nie używamy 'sudo chmod' - testujemy czy uprawnienia z mv wystarczą.
    # Jeśli serwer nie startuje przez prawa - dorzucimy sudo lub passwordless sudo w sudoers.
    local result
    result=$(qnap_exec "cd $remote_dir && \
        mv fabric-server.jar fabric-server.jar.old_$old_label && \
        mv fabric-server-mc.*-loader.*-launcher.*.jar fabric-server.jar && \
        echo OK_REPLACED" 2>&1)
    
    if echo "$result" | grep -q "OK_REPLACED"; then
        # Safety check - weryfikuj uprawnienia po mv
        local perms
        perms=$(qnap_exec "ls -la $remote_dir/fabric-server.jar 2>/dev/null | awk '{print \$1}'")
        log_info "Uprawnienia po mv: $perms"
        if [[ "$perms" != *"rwx"* ]]; then
            log_warn "Plik fabric-server.jar może mieć ograniczone prawa wykonania."
            log_warn "Jeśli serwer nie startuje - sprawdź uprawnienia ręcznie (chmod 777)."
        fi
        return 0
    else
        log_error "Podmiana fabric-server.jar nie powiodła się:"
        log_error "$result"
        return 1
    fi
}
