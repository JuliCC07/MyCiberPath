#!/usr/bin/bash
. /usr/lib/tuned/functions

USER_NAME="julicc"
USER_ID=$(id -u "$USER_NAME")
WAYLAND_SOCKET=$(ls /run/user/$USER_ID/wayland-* 2>/dev/null | head -n 1)
W_DISPLAY=$(basename "$WAYLAND_SOCKET")
NIRI_CMD="sudo -u $USER_NAME WAYLAND_DISPLAY=${W_DISPLAY:-wayland-1} XDG_RUNTIME_DIR=/run/user/$USER_ID niri msg output eDP-1"

start() {
    disable_usb_autosuspend
    disable_wifi_powersave

    for dev in /sys/bus/pci/devices/*/; do
        if [ -f "$dev/class" ] && grep -q "0x010802" "$dev/class" 2>/dev/null; then
            echo 'on' > "$dev/power/control" 2>/dev/null
        fi
    done

    # Subir refresco con Niri IPC a 240Hz
    $NIRI_CMD set-mode "2560x1600@240.000" 2>/dev/null || true

    return 0
}

stop() {
    # Al detener el perfil AC, no forzamos estado de bajo consumo aquí,
    # ya que el perfil de batería que se active después lo hará en su start().
    return 0
}

process $@
