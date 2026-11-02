#!/bin/bash
# ==============================================================================
# Script: iso_copy.sh
# Purpose: Automated ISO image deployment and transfer utility for virtualized
#          lab servers and hypervisors.
# Usage: ./iso_copy.sh [-i <iso_path>] [-d <dest_dir>] <server1> [server2 ...]
# ==============================================================================

set -euo pipefail

DEFAULT_DEST="/var/tmp"
ISO_PATH=""
DEST_DIR="$DEFAULT_DEST"

usage() {
    echo "Usage: $0 -i <iso_path> [-d <dest_dir>] <server1> [server2 ...]"
    echo ""
    echo "Options:"
    echo "  -i  Path to local ISO file to transfer (Required)"
    echo "  -d  Remote destination directory (Default: $DEFAULT_DEST)"
    echo "  -h  Display this help message"
    exit 1
}

while getopts "i:d:h" opt; do
    case "$opt" in
        i) ISO_PATH="$OPTARG" ;;
        d) DEST_DIR="$OPTARG" ;;
        h|*) usage ;;
    esac
done
shift $((OPTIND - 1))

if [[ -z "$ISO_PATH" || $# -eq 0 ]]; then
    echo "[!] Error: Must specify an ISO file and at least one target server." >&2
    usage
fi

if [[ ! -f "$ISO_PATH" ]]; then
    echo "[!] Error: ISO file '$ISO_PATH' not found." >&2
    exit 1
fi

echo "[*] Starting ISO deployment: $(basename "$ISO_PATH")"
echo "[*] Remote destination: $DEST_DIR"

for server in "$@"; do
    echo "[+] Transferring to $server..."
    if scp "$ISO_PATH" "${server}:${DEST_DIR}/"; then
        echo "[+] Transfer to $server completed successfully."
    else
        echo "[!] Error transferring to $server." >&2
    fi
done

echo "[*] ISO deployment completed."
