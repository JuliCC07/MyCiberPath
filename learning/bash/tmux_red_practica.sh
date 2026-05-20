#!/bin/bash

# Variables
session="red_practica"
vms=("helldoor" "ubuserver" "debianserver" "it-router")
esperar=false

# Comprobar estado y encender VMs si es necesario
for vm in "${vms[@]}"; do
  estado=$(virsh domstate "$vm" 2>/dev/null)
  if [ "$estado" != "running" ]; then
    echo "Iniciando $vm..."
    virsh start "$vm"
    esperar=true
  fi
done

if [ "$esperar" = true ]; then
  sleep 15
fi

# Iniciar sesión de tmux y crear los panes"
tmux new-session -d -s "$session" -n "Practica9" "ssh ${vms[0]}; bash"

tmux split-window -h -t "$session:1" "ssh ${vms[1]}; bash"
tmux split-window -v -t "$session:1.2" "ssh ${vms[2]}; bash"
tmux split-window -v -t "$session:1.1" "ssh ${vms[3]}; bash"

tmux select-layout -t "$session:1" tiled

tmux select-pane -t "$session:1.1"
tmux attach-session -t "$session"
