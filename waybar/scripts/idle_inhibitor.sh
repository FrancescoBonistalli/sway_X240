#!/bin/bash
# Toggle/report a manual systemd-inhibit idle lock, for use as a waybar custom module.

PIDFILE="${XDG_RUNTIME_DIR:-/tmp}/waybar-idle-inhibitor.pid"

is_active() {
    [[ -f "$PIDFILE" ]] && kill -0 "$(cat "$PIDFILE")" 2>/dev/null
}

case "$1" in
    toggle)
        if is_active; then
            kill "$(cat "$PIDFILE")" 2>/dev/null
            rm -f "$PIDFILE"
        else
            systemd-inhibit --what=idle:sleep:handle-lid-switch --who="waybar-idle-inhibitor" --why="Manually inhibited" --mode=block sleep infinity &
            echo $! > "$PIDFILE"
            disown
        fi
        pkill -RTMIN+8 waybar
        ;;
    *)
        if is_active; then
            echo '{"text":"","alt":"activated","class":"activated","tooltip":"Idle inhibitor active"}'
        else
            rm -f "$PIDFILE"
            echo '{"text":"","alt":"deactivated","class":"deactivated","tooltip":"Idle inhibitor inactive"}'
        fi
        ;;
esac
