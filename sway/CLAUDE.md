# Sway config

Personal sway config. `$mod` = `Mod4` (Super).

- `config` — main config, sourced by sway at `~/.config/sway/config`.
- `scripts/` — helper scripts invoked via `bindsym ... exec`.
- `sway-keybindings.md` — human-facing cheatsheet; keep in sync with `config` when bindings change.
- `DEPENDENCIES.md` — traced list of every binary/package this config execs, for bootstrapping a new machine; re-trace with `grep -oE '(exec |exec_always )[^;]*' config` after adding new exec lines.
- Apply edits with `swaymsg reload` (no restart needed).

## Known gotcha: layout resets

`layout` commands (`splith`/`splitv`/`stacking`/`tabbed`) apply to the focused
container's immediate parent, or to the focused container itself if it's
already a split container. A **workspace** is itself a container and can
independently be `tabbed`/`stacking`, one level above any inner split
container — so `Super+Ctrl+S` (`splith`) on the focused window may look like
it does nothing if the *workspace*, not the inner container, is the one stuck
in tabbed/stacking.

Fix: `Super+Shift+S` runs `scripts/reset-layout.sh`, which walks the focused
workspace (including the workspace node itself, not just descendants) and
resets every `tabbed`/`stacking` container to `splith`.

When scripting sway layout changes via `swaymsg`/`i3ipc`: prefer `[con_id=X]
focus` followed by a plain `layout ...` command over `[con_id=X] layout ...`
in one shot — criteria-scoped `layout` doesn't reliably apply to non-leaf
containers (workspaces, split containers).

## Known gotcha: screenshot save-to-file binding

Tried binding save-to-file screenshots to `Shift+Print` (2026-07-16) and it
didn't fire. The usual cause is that XKB remaps `Shift+PrintScreen` to the
`Sys_Req` keysym instead of `shift+Print` — `bindsym Sys_Req ...` was tried
as a fallback and also didn't fire, so on this machine the cause is still
unconfirmed (could be a keyboard/firmware quirk, a different modifier
combination, or something intercepting the key before sway sees it).

Current state: only plain `Print` (region screenshot → clipboard) is bound;
there's no save-to-file binding. Before re-adding one, check what keysym the
key combo actually produces — run `wev` (may need `sudo dnf install wev`)
and watch the key event output while pressing the intended combo, rather
than guessing at keysym names again.

## Known gotcha: tray icon startup race (nm-applet / blueman-applet)

`nm-applet` and `blueman-applet` are SNI tray apps: on launch they register
their icon with waybar's StatusNotifierWatcher and silently exit if no
watcher is listening yet — they don't retry later. Sway runs `exec` lines
and the `bar` block in file order, so the `bar` block (which starts waybar)
must appear *before* the `### Autostart ###` execs for these two apps:

1. sway reaches the `bar { swaybar_command waybar }` block (`config:86`) and
   starts waybar, which brings up the tray host.
2. sway reaches `### Autostart ###` (`config:91`) and launches `nm-applet
   --indicator` / `blueman-applet`.
3. Both register successfully because waybar's tray already exists.

This ordering only takes effect on a fresh sway start (login/reboot) —
plain `exec` lines do **not** re-run on `swaymsg reload` (only
`exec_always` does), so if either applet dies mid-session (e.g. waybar
restarts), reloading won't bring it back; relaunch it manually
(`nm-applet --indicator &` / `blueman-applet &`) or via a wrapper script
bound to the reload key.
