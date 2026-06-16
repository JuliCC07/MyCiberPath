#!/bin/bash
# Ajustes de monitor KDE — corre como servicio de usuario

MONITOR="eDP-2"

apply_monitor() {
  local PROFILE
  PROFILE=$(tuned-adm active 2>/dev/null | grep -oP '(?<=Current active profile: ).+')

  case "$PROFILE" in
  legion-powersave | legion-balanced-battery)
    kscreen-doctor output.$MONITOR.mode.2560x1600@60
    ;;
  legion-balanced | legion-performance)
    kscreen-doctor output.$MONITOR.mode.2560x1600@240
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
