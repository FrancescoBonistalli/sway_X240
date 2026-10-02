#!/bin/sh
# Region screenshot → file in ~/Pictures/Screenshots + clipboard, single
# instance: while slurp is waiting for a selection, further presses are ignored
# instead of stacking extra selectors. The lock is released as soon as the
# selection is made or cancelled (Esc).
exec 9>"${XDG_RUNTIME_DIR:-/tmp}/sway-screenshot.lock"
flock -n 9 || exit 0
geom=$(slurp 9>&-) || exit 0
exec 9>&-
dir="$(xdg-user-dir PICTURES 2>/dev/null || echo "$HOME/Pictures")/Screenshots"
mkdir -p "$dir"
file="$dir/Screenshot From $(date "+%Y-%m-%d %H-%M-%S").png"
grim -g "$geom" "$file" || exit 1
wl-copy --type image/png < "$file"
notify-send -i "$file" "Screenshot saved" "Copied to clipboard · $(basename "$file")"
