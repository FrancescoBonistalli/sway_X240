# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

> **Keep this file up to date.** Whenever you make a significant change in this repo (new config section, new script, renamed/removed keybindings, changed workflow), update the relevant part of this file in the same session.

## What this is

A personal dotfiles backup for a Lenovo ThinkPad X240 running Sway (Wayland). It is a pure backup/sync repo, not a build project — there is no build, lint, or test tooling. Files here are copies of the live configs under `~/.config/`.

## Workflow

- `./sync.sh` — pulls the live configs from `~/.config/{sway,waybar,alacritty,swaylock}` into this repo (overwrites repo copies with what's currently on disk).
- `./push.sh` — `git add . && git commit -m "update configs" && git push` (note: always uses the same generic commit message).

Typical loop: edit configs live under `~/.config/...` → test them on the actual machine → run `sync.sh` to pull the changes into the repo → commit/push (manually, or via `push.sh`).

Because `push.sh` always commits with the literal message "update configs", check `git log`/`git diff` for real context on what changed in a given commit rather than trusting the message.

## Layout

- `sway/config` — the **active** Sway config (this is what `sync.sh` copies to/from `~/.config/sway/config`). Uses `alacritty` + `rofi`, Catppuccin-orange accent border, natural scroll enabled, `us` keyboard layout.
- `sway/sway-config` — an **alternate/draft** Sway config, not the live one, not touched by `sync.sh`. Uses `foot` + `wofi`, Catppuccin-blue accent, `it` keyboard layout with `caps:escape`, natural scroll disabled. Diverges from `sway/config` in keybindings too (e.g. `$mod+h/v` for split vs `$mod+ctrl+s/t`, focus bound directly to `$mod+$left/$right` vs `$mod+ctrl+$left/$right`). When editing keybindings or input settings, check which of the two files is actually intended — they are easy to confuse and can drift.
- `sway/sway-keybindings.md` — human-readable keybinding cheatsheet. Reflects `sway/config` (the active one); update it when active keybindings change.
- `sway/scripts/` — helper scripts invoked from the Sway config (`workspace_compact.py` renumbers workspaces via i3ipc on window/workspace events, `toggle-theme.sh` flips GNOME/GTK light-dark via `gsettings`, `brightness-down.sh` wraps `brightnessctl` with a floor).
- `sway/wallpaper.jpg` — background image, also referenced by `swaylock/config`.
- `waybar/config.jsonc`, `waybar/style.css` — Waybar bar config/styling. `waybar/power_menu.sh` (+ `power_menu.xml`) implements the custom power-menu module. `waybar/notes.txt` is a scratch/snippet file, not authoritative config.
- `alacritty/alacritty.toml` — Alacritty terminal config.
- `swaylock/config` — swaylock (lock screen) config; Catppuccin Mocha color scheme, shares the Sway wallpaper.

## Conventions

- Color scheme across configs is Catppuccin (Mocha base, `#1e1e2e` background); keep new UI-facing config consistent with this palette unless intentionally deviating (as `sway-config` does).
- Target hardware is specifically the X240: 1366x768 internal display (`eDP-1`), Synaptics touchpad + TrackPoint, battery/thermal considerations in Waybar config. Don't assume settings need to generalize to other machines.
