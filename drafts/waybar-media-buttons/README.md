# Waybar media control buttons (shelved)

Adds three buttons to `modules-left`, right after `custom/media` (the title):
previous / play-pause / next, backed by `playerctl`. Built and debugged
2026-09-05, then shelved in favor of the `$mod+k` sway keybinding
(`playerctl play-pause`, alongside the pre-existing `$mod+p`) instead of a
waybar button.

## What's in this folder

Full copies of the files as they stood when this was working, not a diff:

- `config.jsonc` — the whole `waybar/config.jsonc` with `custom/media_prev`,
  `custom/media_playpause`, `custom/media_next` added to `modules-left` and
  defined below `custom/media`.
- `style.css` — the whole `waybar/style.css` with color/padding rules for
  the three new modules.
- `media_playpause.py` — goes in `waybar/scripts/`. Follows `playerctl
  --follow status` (same long-running/re-attach pattern as
  `mediaplayer.py`) to show a play (``) / pause (``) icon that
  tracks actual state.

`custom/media_prev`/`custom/media_next` need no script — they're static-icon
buttons whose `on-click` shells out directly to `playerctl previous`/`next`.

## Reapplying

1. Copy `media_playpause.py` into `waybar/scripts/` (`chmod +x` it).
2. Diff `config.jsonc` and `style.css` here against the live `waybar/`
   versions and merge in whatever's changed there since — don't just
   overwrite, since `waybar/config.jsonc`/`style.css` may have moved on.
3. Add a one-line mention back to the top-level `CLAUDE.md` Layout section
   and to `sway/DEPENDENCIES.md`'s `playerctl` row (see git history around
   2026-09-05 for the exact wording used last time).
4. `./install.sh`, then reload waybar.

## Known gotcha hit while building this

Font Awesome private-use-area glyphs (the icon characters themselves)
silently came out as **empty strings** when first typed into the icon
constants/format fields — the buttons rendered with no visible glyph and
no clickable content. Fix: write icons as explicit `\uXXXX` escapes
(`` step-backward, `` play, `` pause, ``
step-forward) instead of pasting the literal character, and verify with
`grep | cat -A` / `xxd` that the bytes actually landed before trusting it
visually.
