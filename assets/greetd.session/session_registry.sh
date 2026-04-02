#!/bin/bash
set -euo pipefail

LOG_FILE="/var/log/sparrow-session-registry.log"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "${LOG_FILE}" 2>/dev/null || true
}

is_live_mode() {
    if [[ -f /proc/cmdline ]] && grep -q 'sparrow.live=1' /proc/cmdline 2>/dev/null; then
        return 0
    fi
    return 1
}

main() {
    if is_live_mode; then
        log "Live mode: autologin test user via dms-shell"
        exec dms-shell --session Hyprland --user test
    else
        log "Normal mode, starting dms-greeter"
        exec dms-greeter --command Hyprland
    fi
}

main "$@"