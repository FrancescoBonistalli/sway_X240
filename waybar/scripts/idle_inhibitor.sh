#!/bin/bash
# Toggle/report a manual systemd-inhibit idle lock, for use as a waybar custom module.
#
# The inhibitor runs as a transient user unit rather than a backgrounded process
# tracked by a pidfile: the unit name is unique, so overlapping or repeated toggles
# (waybar clicks can fire more than once) can never leave a second, untracked
# inhibitor behind blocking suspend.

UNIT="waybar-idle-inhibitor.service"
LOCKFILE="${XDG_RUNTIME_DIR:-/tmp}/waybar-idle-inhibitor.lock"
DEBOUNCE_MS=400

is_active() {
    systemctl --user --quiet is-active "$UNIT"
}

case "$1" in
    toggle)
        # Serialize toggles, and drop any that land right after the previous one.
        exec 9>>"$LOCKFILE"
        flock 9
        now=$(date +%s%3N)
        last=$(cat "$LOCKFILE" 2>/dev/null)
        if [[ "$last" =~ ^[0-9]+$ ]] && (( now - last < DEBOUNCE_MS )); then
            exit 0
        fi
        echo "$now" > "$LOCKFILE"

        if is_active; then
            systemctl --user stop "$UNIT"
        else
            systemd-run --user --quiet --collect --unit="$UNIT" \
                systemd-inhibit --what=idle:sleep:handle-lid-switch --who="waybar-idle-inhibitor" --why="Manually inhibited" --mode=block sleep infinity
        fi
        pkill -RTMIN+8 waybar
        ;;
    *)
        if is_active; then
            echo '{"text":"","alt":"activated","class":"activated","tooltip":"Idle inhibitor active"}'
        else
            echo '{"text":"","alt":"deactivated","class":"deactivated","tooltip":"Idle inhibitor inactive"}'
        fi
        ;;
esac
