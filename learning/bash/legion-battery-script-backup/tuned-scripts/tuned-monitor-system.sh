#!/bin/bash
# Ajustes de energía que requieren root — corre como servicio de sistema

apply_power() {
  local PROFILE
  PROFILE=$(tuned-adm active 2>/dev/null | grep -oP '(?<=Current active profile: ).+')

  case "$PROFILE" in
  legion-powersave | legion-balanced-battery)
    nvidia-smi -pl 35
    iw dev wlan0 set power_save on
    echo '1500' >/sys/bus/pci/devices/*/power/autosuspend_delay_ms
    echo 'auto' >/sys/bus/pci/devices/*/power/control
    ;;
  legion-balanced | legion-performance)
    nvidia-smi -pl 115
    iw dev wlan0 set power_save off
    echo 'on' >/sys/bus/pci/devices/*/power/control
    ;;
  *)
    echo "Perfil desconocido: $PROFILE"
    ;;
  esac

  echo "$(date): [system] Perfil aplicado -> $PROFILE"
}

apply_power

gdbus monitor \
  --system \
  --dest com.redhat.tuned \
  --object-path /Tuned \
  2>/dev/null |
  while read -r line; do
    if echo "$line" | grep -q "profile_changed"; then
      sleep 0.5
      apply_power
    fi
  done
