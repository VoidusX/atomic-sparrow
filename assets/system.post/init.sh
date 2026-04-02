#!/bin/bash
set -euo pipefail

LOG_FILE="/var/log/sparrow-first-boot.log"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "${LOG_FILE}"
}

install_system_flatpaks() {
    local flatpaks_list="/etc/sparrow/installation.flatpaks.toml"

    if [[ -f "${flatpaks_list}" ]]; then
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

main() {
    log "First-boot setup starting..."

    install_system_flatpaks

    log "First-boot setup complete"
}

main "$@"
