#!/bin/bash
set -euo pipefail

# Post-install systemd service runner
# Called by greeter to handle autologin and post-install tasks

POST_INSTALL_CONF="/etc/sparrow/post-install.conf"
POSTSCRIPTS_DIR="/usr/share/sparrow/postscripts"
LOG_FILE="/var/log/sparrow-post-install.log"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "${LOG_FILE}"
}

# Install system flatpaks from list.toml
install_system_flatpaks() {
    local flatpaks_list="${POSTSCRIPTS_DIR}/flatpaks_list.toml"
    
    if [[ -f "${flatpaks_list}" ]]; then
        # Parse core_apps from [system] section
        local core_apps_line=$(grep -A 20 '^\[system\]' "${flatpaks_list}" 2>/dev/null | grep '^core_apps' || true)
        if [[ -n "${core_apps_line}" ]]; then
            local flatpaks=$(echo "${core_apps_line}" | sed -n 's/.*\[\(.*\)\].*/\1/p' | tr -d '"' | tr -d ' ')
            if [[ -n "${flatpaks}" ]]; then
                log "Installing system flatpaks: ${flatpaks}..."
                for pkg in ${flatpaks}; do
                    flatpak install -y --system "${pkg}" 2>/dev/null || true
                done
                log "System flatpak installation complete"
            fi
        fi
    fi
}

# Check if test user exists - if yes, always do greetd IPC autologin
if id test &>/dev/null; then
    log "Test user exists, using greetd IPC for autologin..."
    
    # Use greetd IPC via bash to autologin
    if [[ -S /run/greetd.sock ]]; then
        # Create IPC greeter script
        cat > /usr/local/bin/greetd-ipc-autologin << 'GREETER'
#!/bin/bash
# Greetd IPC client using bash/socat

send_msg() {
    local type="$1"
    local username="${2:-}"
    local cmd="${3:-}"
    
    local payload
    if [[ "${type}" == "create_session" ]]; then
        payload="{\"type\": \"create_session\", \"username\": \"${username}\"}"
    elif [[ "${type}" == "start_session" ]]; then
        payload="{\"type\": \"start_session\", \"cmd\": [\"${cmd}\"], \"env\": []}"
    fi
    
    local len=$(printf '%d' "${#payload}")
    local len_hex=$(printf '%08x' "$len")
    
    # Convert hex to binary and send
    echo -en "\\x${len_hex:0:2}\\x${len_hex:2:2}\\x${len_hex:4:2}\\x${len_hex:6:2}"
    echo -n "${payload}"
}

# Connect to greetd socket
SOCKET="/run/greetd.sock"

# Create session for test user
DATA=$(send_msg "create_session" "test")
echo -n "${DATA}" | socat - UNIX-CONNECT:"${SOCKET}" | {
    # Read response length
    read -r -n 4 len_bytes
    # Read response body
    read -r -n 1000 response
    
    if echo "${response}" | grep -q '"type".*"success"'; then
        # Start session
        START_DATA=$(send_msg "start_session" "" "Hyprland")
        echo -n "${START_DATA}" | socat - UNIX-CONNECT:"${SOCKET}" >/dev/null
    fi
}
GREETER
        chmod +x /usr/local/bin/greetd-ipc-autologin
        exec /usr/local/bin/greetd-ipc-autologin
    else
        log "Greetd socket not available"
        exit 1
    fi
fi

# Test user doesn't exist - check config
if [[ ! -f "${POST_INSTALL_CONF}" ]]; then
    log "No config and no test user - exit"
    exit 0
fi

# Check if create_test_user is enabled
CREATE_TEST_USER=false
if grep -q '^create_test_user = true' "${POST_INSTALL_CONF}" 2>/dev/null; then
    CREATE_TEST_USER=true
fi

if [[ "${CREATE_TEST_USER}" != "true" ]]; then
    log "create_test_user not enabled - installing flatpaks only"
    install_system_flatpaks
    rm -f "${POST_INSTALL_CONF}"
    exit 0
fi

# Create test user
log "Creating test user..."
useradd -m -G video,wheel,input -s /bin/bash test
echo "test:test" | chpasswd
log "Test user created"

# Install system flatpaks
install_system_flatpaks

# Now use greetd IPC to autologin test user
log "Using greetd IPC for autologin..."
rm -f "${POST_INSTALL_CONF}"

if [[ -S /run/greetd.sock ]]; then
    cat > /usr/local/bin/greetd-ipc-autologin << 'GREETER'
#!/bin/bash
send_msg() {
    local type="$1"
    local username="${2:-}"
    local cmd="${3:-}"
    
    local payload
    if [[ "${type}" == "create_session" ]]; then
        payload="{\"type\": \"create_session\", \"username\": \"${username}\"}"
    elif [[ "${type}" == "start_session" ]]; then
        payload="{\"type\": \"start_session\", \"cmd\": [\"${cmd}\"], \"env\": []}"
    fi
    
    local len=$(printf '%d' "${#payload}")
    local len_hex=$(printf '%08x' "$len")
    
    echo -en "\\x${len_hex:0:2}\\x${len_hex:2:2}\\x${len_hex:4:2}\\x${len_hex:6:2}"
    echo -n "${payload}"
}

SOCKET="/run/greetd.sock"
DATA=$(send_msg "create_session" "test")
echo -n "${DATA}" | socat - UNIX-CONNECT:"${SOCKET}" | {
    read -r -n 4 len_bytes
    read -r -n 1000 response
    if echo "${response}" | grep -q '"type".*"success"'; then
        START_DATA=$(send_msg "start_session" "" "Hyprland")
        echo -n "${START_DATA}" | socat - UNIX-CONNECT:"${SOCKET}" >/dev/null
    fi
}
GREETER
    chmod +x /usr/local/bin/greetd-ipc-autologin
    exec /usr/local/bin/greetd-ipc-autologin
else
    log "Greetd socket not available"
    exit 1
fi