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
    disable_usb_autosuspend
    disable_wifi_powersave
    legion_cli set-feature PlatformProfileFeature custom 2>/dev/null || true

    # Custom power limits
    legion_cli set-feature CPULongtermPowerLimit 60 2>/dev/null || true
    legion_cli set-feature CPUShorttermPowerLimit 75 2>/dev/null || true
    legion_cli set-feature CPUPeakPowerLimit 80 2>/dev/null || true
    legion_cli set-feature CPUCrossLoadingPowerLimit 60 2>/dev/null || true
    legion_cli set-feature CPUAPUSPPTPowerLimit 0 2>/dev/null || true
    legion_cli set-feature GPUCTGPPowerLimit 120 2>/dev/null || true
    legion_cli set-feature GPUPPABPowerLimit 10 2>/dev/null || true
    legion_cli set-feature GPUTemperatureLimit 87 2>/dev/null || true

    for dev in /sys/bus/pci/devices/*/; do
        if [ -f "$dev/class" ] && grep -q "0x010802" "$dev/class" 2>/dev/null; then
            echo 'on' > "$dev/power/control" 2>/dev/null
        fi
    done

    niri_set_mode "2560x1600@240.000"
    return 0
}

stop() {
    return 0
}

process $@
