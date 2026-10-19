#!/bin/bash
# ==============================================================================
# Script: script_usuarios.sh
# Purpose: Automated user and group provisioning for Linux system administration
#          and enterprise lab environments (ASIR).
# Usage: sudo ./script_usuarios.sh
# ==============================================================================

set -euo pipefail

if [[ $EUID -ne 0 ]]; then
   echo "[!] Este script debe ejecutarse con privilegios de root (sudo)." >&2
   exit 1
fi

DEPARTAMENTOS=("sistemas" "desarrollo")
GRUPO_PRINCIPAL="informatica"
CANTIDAD_USUARIOS=5

echo "[*] Creando grupo general: $GRUPO_PRINCIPAL"
if ! getent group "$GRUPO_PRINCIPAL" >/dev/null; then
    addgroup "$GRUPO_PRINCIPAL"
fi

for depto in "${DEPARTAMENTOS[@]}"; do
    echo "[*] Configurando departamento: $depto"
    if ! getent group "$depto" >/dev/null; then
        addgroup "$depto"
    fi

    for i in $(seq 1 "$CANTIDAD_USUARIOS"); do
        username=$(printf "%s%02d" "$depto" "$i")
        if id "$username" >/dev/null 2>&1; then
            echo "    [-] El usuario $username ya existe. Saltando."
        else
            echo "    [+] Creando usuario: $username"
            adduser --disabled-password --gecos "" --ingroup "$depto" "$username"
            usermod -aG "$GRUPO_PRINCIPAL" "$username"
        fi
    done
done

echo "[*] Aprovisionamiento de usuarios completado exitosamente."
