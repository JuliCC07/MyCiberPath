#!/usr/bin/bash
. /usr/lib/tuned/functions

USER_NAME="julicc"
USER_ID=$(id -u "$USER_NAME")
NIRI_CMD="sudo -u $USER_NAME WAYLAND_DISPLAY=wayland-1 XDG_RUNTIME_DIR=/run/user/$USER_ID niri msg output eDP-1"

start() {
    enable_usb_autosuspend
    enable_wifi_powersave

    for dev in /sys/bus/pci/devices/*/; do
        if [ -f "$dev/class" ] && grep -q "0x010802" "$dev/class" 2>/dev/null; then
            echo '2000' > "$dev/power/autosuspend_delay_ms" 2>/dev/null
            echo 'auto'  > "$dev/power/control" 2>/dev/null
        fi
    done

    # Bajar refresco con Niri IPC a 60Hz
    $NIRI_CMD set-mode "2560x1600@60.000" 2>/dev/null || true

    return 0
}

stop() {
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

process $@
