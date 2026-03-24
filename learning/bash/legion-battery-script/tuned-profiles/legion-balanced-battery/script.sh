#!/usr/bin/bash
. /usr/lib/tuned/functions

start() {
    enable_wifi_powersave

    # NVMe autosuspend moderado
    for dev in /sys/bus/pci/devices/*/; do
        if [ -f "$dev/class" ] && grep -q "0x010802" "$dev/class" 2>/dev/null; then
            echo '5000' > "$dev/power/autosuspend_delay_ms" 2>/dev/null
            echo 'auto'  > "$dev/power/control" 2>/dev/null
        fi
    done

    return 0
}

stop() {
    disable_wifi_powersave

    for dev in /sys/bus/pci/devices/*/; do
        if [ -f "$dev/class" ] && grep -q "0x010802" "$dev/class" 2>/dev/null; then
            echo 'on' > "$dev/power/control" 2>/dev/null
        fi
    done

    return 0
}

process $@
