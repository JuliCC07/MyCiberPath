#!/bin/bash

# Variables
ISO_PATH="/home/julicc/VirtualMachines/ISOs/systemrescue"
servers=("ubuserver" "debianserver")
DEST_DIR="/home/julicc/"

echo "Iniciando transferencia a la red Servers"

for machine in "${servers[@]}"; do
  echo "Copiando a $machine"
  scp "$ISO_PATH" "${machine}":"${DEST_DIR}"
done

echo "Proceso completado"
