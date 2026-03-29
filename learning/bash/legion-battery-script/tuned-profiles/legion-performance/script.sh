#!/usr/bin/bash
. /usr/lib/tuned/functions

start() {
    disable_wifi_powersave
    rfkill unblock bluetooth 2>/dev/null

    for dev in /sys/bus/pci/devices/*/; do
        if [ -f "$dev/class" ] && grep -q "0x010802" "$dev/class" 2>/dev/null; then
            echo 'on' > "$dev/power/control" 2>/dev/null
        fi
    done

    return 0
}

stop() {
    return 0
}

process $@
