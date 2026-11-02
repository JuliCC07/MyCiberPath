#!/bin/bash
# ==============================================================================
# Script: user_provisioning.sh
# Purpose: Automated user and group provisioning for Linux system administration
#          and enterprise lab environments (ASIR).
# Usage: sudo ./user_provisioning.sh
# ==============================================================================

set -euo pipefail

if [[ $EUID -ne 0 ]]; then
    echo "[!] This script must be run with root privileges (sudo)." >&2
    exit 1
fi

DEPARTMENTS=("systems" "development")
PRIMARY_GROUP="it_staff"
USER_COUNT=5

echo "[*] Creating primary group: $PRIMARY_GROUP"
if ! getent group "$PRIMARY_GROUP" >/dev/null; then
    addgroup "$PRIMARY_GROUP"
fi

for dept in "${DEPARTMENTS[@]}"; do
    echo "[*] Configuring department: $dept"
    if ! getent group "$dept" >/dev/null; then
        addgroup "$dept"
    fi

    for i in $(seq 1 "$USER_COUNT"); do
        username=$(printf "%s%02d" "$dept" "$i")
        if id "$username" >/dev/null 2>&1; then
            echo "    [-] User $username already exists. Skipping."
        else
            echo "    [+] Creating user: $username"
            adduser --disabled-password --gecos "" --ingroup "$dept" "$username"
            usermod -aG "$PRIMARY_GROUP" "$username"
        fi
    done
done

echo "[*] User provisioning completed successfully."
