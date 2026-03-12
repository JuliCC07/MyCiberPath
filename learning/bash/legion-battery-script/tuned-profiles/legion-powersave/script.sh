#!/usr/bin/bash
. /usr/lib/tuned/functions

start() {
    enable_usb_autosuspend
    enable_wifi_powersave

    for dev in /sys/bus/pci/devices/*/; do
        if [ -f "$dev/class" ] && grep -q "0x010802" "$dev/class" 2>/dev/null; then
            echo '2000' > "$dev/power/autosuspend_delay_ms" 2>/dev/null
            echo 'auto'  > "$dev/power/control" 2>/dev/null
        fi
    done

    if ! bluetoothctl info 2>/dev/null | grep -q "Connected: yes"; then
        rfkill block bluetooth 2>/dev/null
    fi

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

    rfkill unblock bluetooth 2>/dev/null
    return 0
}

process $@
