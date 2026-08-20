# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

> **Keep this file up to date.** Whenever you make a significant change in this repo (new config section, new script, renamed/removed keybindings, changed workflow), update the relevant part of this file in the same session.

## What this is

A personal dotfiles backup for a Lenovo ThinkPad X240 running Sway (Wayland). It is a pure backup/sync repo, not a build project — there is no build, lint, or test tooling. Files here are copies of the live configs under `~/.config/`.

## Workflow

- `./sync.sh` — pulls the live configs from `~/.config/` into this repo.
- `./install.sh` — pushes the repo's configs out to `~/.config/`. This is how repo changes get applied to the live machine; don't hand-copy or reload configs instead of it.
- `sync-lib.sh` — sourced by both of the above; holds the tracked-directory list (`DIRS`), the repo-only exclude patterns (`EXCLUDES`) and the `copy_configs <src root> <dst root> <label>` function they both call, so the two directions can't drift. **Add a new config directory here, in `DIRS`, and nowhere else.**

`EXCLUDES` is what keeps documentation out of `~/.config`: `*.md`, `sway-config` (the alternate draft), `notes.txt`, `*.bak` and `.claude` live in the repo only — nothing reads them at runtime. The patterns match basenames and apply to both the diff and the copy in both directions, so `install.sh` won't push a `.md` out and `sync.sh` won't pull a stray one back in. The copy uses `tar` piped into `tar` rather than `cp -r` precisely so it can honour the same excludes the diff used; like `cp -r` it overwrites and merges but never deletes. Adding a doc or scratch file to a config dir means adding its pattern here too.

Both directions behave the same way: diff destination → source (so `+` lines are what would land in the destination), print the diff colored git-style, then ask `Apply? [y/N]` — answering anything but `y`/`yes` aborts with exit 1 and copies nothing. Only the directories that actually differ get copied. If nothing differs, they print `nothing to do`. Files that exist only in the destination (e.g. `sway/sway-config` and the `.md` docs, which live in the repo but not in `~/.config/sway`) are filtered out of the diff, since `cp` never deletes them.
- `./push.sh` — `git add . && git commit -m "update configs" && git push` (note: always uses the same generic commit message).

Typical loop: edit configs live under `~/.config/...` → test them on the actual machine → run `sync.sh` to pull the changes into the repo → commit/push (manually, or via `push.sh`).

Because `push.sh` always commits with the literal message "update configs", check `git log`/`git diff` for real context on what changed in a given commit rather than trusting the message.

## Layout

- `packages.txt` — flat list of dnf package names, one per line, no comments (`sudo dnf install $(< packages.txt)`). Contains **only packages verified installed on this machine** with `rpm -q`; anything the config references but that isn't installed belongs in `sway/DEPENDENCIES.md` section 3, not here. `sway/DEPENDENCIES.md` is the annotated companion — which line of which config execs each binary, plus the cliphist COPR dance.
- `sway/config` — the **active** Sway config (this is what `sync.sh` copies to/from `~/.config/sway/config`). Uses `alacritty` + `rofi`, Catppuccin-orange accent border, natural scroll enabled, `us` keyboard layout.
- `sway/sway-config` — an **alternate/draft** Sway config, not the live one, not touched by `sync.sh`. Uses `foot` + `wofi`, Catppuccin-blue accent, `it` keyboard layout with `caps:escape`, natural scroll disabled. Diverges from `sway/config` in keybindings too (e.g. `$mod+h/v` for split vs `$mod+ctrl+s/t`, focus bound directly to `$mod+$left/$right` vs `$mod+ctrl+$left/$right`). When editing keybindings or input settings, check which of the two files is actually intended — they are easy to confuse and can drift.
- `sway/sway-keybindings.md` — human-readable keybinding cheatsheet. Reflects `sway/config` (the active one); update it when active keybindings change.
- `sway/scripts/` — helper scripts invoked from the Sway config (`workspace_compact.py` renumbers workspaces via i3ipc on window/workspace events, `toggle-theme.sh` flips GNOME/GTK light-dark via `gsettings`, `brightness-down.sh` wraps `brightnessctl` with a floor).
- `sway/wallpaper.jpg` — background image, also referenced by `swaylock/config`.
- `waybar/config.jsonc`, `waybar/style.css` — Waybar bar config/styling. `waybar/power_menu.sh` (+ `power_menu.xml`) implements the custom power-menu module. `waybar/notes.txt` is a scratch/snippet file, not authoritative config.
- `alacritty/alacritty.toml` — Alacritty terminal config.
- `swaylock/config` — swaylock (lock screen) config; Catppuccin Mocha color scheme, shares the Sway wallpaper.
- `swaync/config.json`, `swaync/style.css` — SwayNotificationCenter (notification daemon + notification center) config/styling. Started from `sway/config` (`exec swaync`) and toggled with `$mod+shift+n` (`swaync-client -t -sw`).

## Conventions

- Color scheme across configs is Catppuccin (Mocha base, `#1e1e2e` background); keep new UI-facing config consistent with this palette unless intentionally deviating (as `sway-config` does).
- Target hardware is specifically the X240: 1366x768 internal display (`eDP-1`), Synaptics touchpad + TrackPoint, battery/thermal considerations in Waybar config. Don't assume settings need to generalize to other machines.
