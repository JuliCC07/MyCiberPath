#!/usr/bin/bash
. /usr/lib/tuned/functions

USER_ID=$(id -u julicc)
NIRI_SOCK=$(ls /run/user/$USER_ID/niri.wayland-*.sock 2>/dev/null | head -n1)

niri_set_mode() {
    if [ -n "$NIRI_SOCK" ]; then
        local edp
        edp=$(NIRI_SOCKET="$NIRI_SOCK" niri msg outputs 2>/dev/null | grep -oP 'eDP-\d+' | head -n1)
        if [ -n "$edp" ]; then
            NIRI_SOCKET="$NIRI_SOCK" niri msg output "$edp" mode "$1" 2>/dev/null || true
        fi
    fi
}

start() {
    enable_usb_autosuspend
    enable_wifi_powersave
    legion_cli set-feature PlatformProfileFeature balanced 2>/dev/null || true

    for dev in /sys/bus/pci/devices/*/; do
        if [ -f "$dev/class" ] && grep -q "0x010802" "$dev/class" 2>/dev/null; then
            echo '5000' > "$dev/power/autosuspend_delay_ms" 2>/dev/null
            echo 'auto'  > "$dev/power/control" 2>/dev/null
        fi
    done

    niri_set_mode "2560x1600@60.000"
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

    niri_set_mode "2560x1600@240.000"
    return 0
}

process $@
