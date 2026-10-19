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
    echo "Uso: $0 -i <ruta_iso> [-d <directorio_destino>] <servidor1> [servidor2 ...]"
    echo ""
    echo "Opciones:"
    echo "  -i  Ruta al archivo ISO local a transferir (Requerido)"
    echo "  -d  Directorio remoto de destino (Por defecto: $DEFAULT_DEST)"
    echo "  -h  Muestra este mensaje de ayuda"
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
    echo "[!] Error: Se debe especificar el archivo ISO y al menos un servidor objetivo."
    usage
fi

if [[ ! -f "$ISO_PATH" ]]; then
    echo "[!] Error: El archivo ISO '$ISO_PATH' no existe."
    exit 1
fi

echo "[*] Iniciando despliegue de ISO: $(basename "$ISO_PATH")"
echo "[*] Destino remoto: $DEST_DIR"

for server in "$@"; do
    echo "[+] Transfiriendo a $server..."
    if scp "$ISO_PATH" "${server}:${DEST_DIR}/"; then
        echo "[✓] Transferencia a $server completada."
    else
        echo "[✗] Error al transferir a $server." >&2
    fi
done

echo "[*] Despliegue finalizado."
