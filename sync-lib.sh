#!/bin/bash
# Shared logic for sync.sh (live -> repo) and install.sh (repo -> live):
# diff the two copies, show what would change, ask before copying.
# Sourced, not executed.

# The config directories tracked by this repo. Both scripts use this list.
DIRS=(sway waybar alacritty swaylock swaync)

# git-style coloring: added lines green, removed red. Skipped when stdout
# isn't a terminal (piped to a file, a pager without -R, etc.).
colorize() {
    if [[ ! -t 1 ]]; then
        cat
        return
    fi
    awk '
        /^(\+\+\+|---|diff |=== |Only in )/ { printf "\033[1m%s\033[0m\n", $0; next }
        /^@@/                               { printf "\033[36m%s\033[0m\n", $0; next }
        /^\+/                               { printf "\033[32m%s\033[0m\n", $0; next }
        /^-/                                { printf "\033[31m%s\033[0m\n", $0; next }
                                            { print }
    '
}

# copy_configs <source root> <destination root> <destination label>
copy_configs() {
    local src_root="$1" dst_root="$2" dst_label="$3"
    local d src dst out answer
    local changed=()
    local diffs=""

    for d in "${DIRS[@]}"; do
        src="$src_root/$d"
        dst="$dst_root/$d"

        if [[ ! -d "$src" ]]; then
            echo "skipping $d: $src not found"
            continue
        fi

        if [[ ! -d "$dst" ]]; then
            changed+=("$d")
            diffs+="=== $d: new directory in $dst_label ==="$'\n\n'
            continue
        fi

        # destination -> source, so '+' lines are what would land in the
        # destination. Files that only exist in the destination are dropped:
        # cp never removes them.
        out="$(diff -ru "$dst" "$src" | awk -v p="Only in $dst:" 'index($0, p) == 1 { next } { print }')"

        if [[ -n "$out" ]]; then
            changed+=("$d")
            diffs+="=== $d ==="$'\n'"$out"$'\n\n'
        fi
    done

    if [[ ${#changed[@]} -eq 0 ]]; then
        echo "nothing to do"
        return 0
    fi

    printf '%s' "$diffs" | colorize
    echo "Will copy into $dst_label: ${changed[*]}"
    read -r -p "Apply? [y/N] " answer

    case "$answer" in
        [yY] | [yY][eE][sS]) ;;
        *)
            echo "Aborted."
            return 1
            ;;
    esac

    for d in "${changed[@]}"; do
        cp -r "$src_root/$d" "$dst_root/"
    done

    echo "Done!"
}
