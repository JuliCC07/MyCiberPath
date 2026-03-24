#!/bin/bash
# Ajustes de monitor GNOME — corre como servicio de usuario

MONITOR="eDP-1"
RES_HQ="2560x1600@240.000+vrr"
RES_SAVE="2560x1600@60.000"

apply_monitor() {
  local PROFILE
  PROFILE=$(tuned-adm active 2>/dev/null | grep -oP '(?<=Current active profile: ).+')

  case "$PROFILE" in
  legion-powersave | legion-balanced-battery)
    gnome-monitor-config set -L -p -M "$MONITOR" -m "$RES_SAVE"
    ;;
  legion-balanced | legion-performance)
    gnome-monitor-config set -L -p -M "$MONITOR" -m "$RES_HQ"
    ;;
  *)
    echo "Perfil desconocido: $PROFILE"
    ;;
  esac

  echo "$(date): [user] Monitor aplicado -> $PROFILE"
}

apply_monitor

gdbus monitor \
  --system \
  --dest com.redhat.tuned \
  --object-path /Tuned \
  2>/dev/null |
  while read -r line; do
    if echo "$line" | grep -q "profile_changed"; then
      sleep 0.5
      apply_monitor
    fi
  done
