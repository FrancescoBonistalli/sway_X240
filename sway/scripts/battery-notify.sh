#!/bin/bash
# Low-battery notifications: sits on UPower's D-Bus signals (no polling) and
# sends a notification when its combined battery (BAT0 + BAT1) reaches the
# "low" / "critical" / "action" warning level — the Percentage* thresholds in
# /etc/UPower/UPower.conf. UPower only raises a level while discharging.
# Single instance: sway's `exec` doesn't kill this on logout, so the lock keeps
# a second login from stacking another one and doubling every notification.
exec 9>"${XDG_RUNTIME_DIR:-/tmp}/sway-battery-notify.lock"
flock -n 9 || exit 0

dev=/org/freedesktop/UPower/devices/DisplayDevice
last=1  # UPower warning levels: 1 none, 3 low, 4 critical, 5 action

prop() {
    busctl get-property org.freedesktop.UPower "$dev" org.freedesktop.UPower.Device "$1" | cut -d' ' -f2
}

check() {
    level=$(prop WarningLevel)
    [ -n "$level" ] || return
    # notify only when the level gets worse, not on every update at that level
    if [ "$level" -gt "$last" ]; then
        pct=$(printf '%.0f' "$(prop Percentage)")
        case $level in
            3) notify-send -u normal -i battery-low "Battery low" "$pct% remaining" ;;
            4) notify-send -u critical -i battery-caution "Battery critical" "$pct% remaining — plug in now" ;;
            5) notify-send -u critical -i battery-empty "Battery empty" "$pct% remaining — the system is about to power down" ;;
        esac
    fi
    last=$level
}

check
while read -r line; do
    case $line in *WarningLevel*) check ;; esac
done < <(gdbus monitor --system --dest org.freedesktop.UPower --object-path "$dev" 9>&-)
