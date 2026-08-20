# Software dependencies

Everything this config execs, either directly from `config` or from `scripts/`
and `~/.config/waybar/`. Traced from the actual `exec`/`bindsym`/`on-click`
lines, not from memory — re-run the grep below after editing `config` to
catch drift:

```
grep -oE '(exec |exec_always )[^;]*' config
```

## 1. Base install (Fedora / dnf)

The machine-readable list lives in **`../packages.txt`** at the repo root —
one package name per line, no comments, so it can be fed straight to dnf:

```
sudo dnf copr enable alternateved/cliphist   # see below; cliphist is in the list
sudo dnf install $(< packages.txt)
sudo dnf copr disable alternateved/cliphist
```

`packages.txt` lists **only what is actually installed on this machine** —
every entry was checked with `rpm -q`, so the file reproduces the working
setup rather than an aspirational one. Things the config references but that
aren't installed here are tracked in section 3 instead, not in the list.
Re-verify after editing it:

```
while read -r p; do rpm -q "$p" >/dev/null || echo "MISSING $p"; done < packages.txt
```

Keep `packages.txt` and the table in section 2 in step when adding a
dependency. Package names were verified against Fedora 43 with
`rpm -q` / `dnf list` — several differ from the obvious guess:
`network-manager-applet` (not `NetworkManager-applet`),
`SwayNotificationCenter` (provides `swaync`/`swaync-client`), and
`python3-i3ipc` (there is no plain `i3ipc` package).

`swaybar` and `swaynag` are **not** separate packages on Fedora — both
binaries ship inside `sway` itself (`rpm -qf $(command -v swaynag)`), so only
`swaylock`, `swayidle` and `swaybg` are listed alongside it. On a non-Fedora
system check whether even those are already pulled in transitively.

Fonts are in the list too, and are easy to forget: `waybar/style.css:2` asks
for `Noto Sans Mono` + `Font Awesome 6 Free`/`Brands` — without the Font
Awesome ones the bar renders tofu boxes instead of icons. (`config:67` also
sets `pango:JetBrains Mono`, but that font isn't installed here — section 3.)

`cliphist` is in the list but is **not** in Fedora's official repos, only in
third-party COPRs — hence the `copr enable` before the install above, and the
`copr disable` after, so it doesn't get pulled into future `dnf upgrade` runs
(the package stays installed, just pinned):
```
sudo dnf copr enable alternateved/cliphist
sudo dnf install cliphist
sudo dnf copr disable alternateved/cliphist
```
Note: the `wef/cliphist` COPR (linked from cliphist's own GitHub instructions)
has **no `fedora-43-x86_64` chroot** as of 2026-07-16, so `dnf copr enable
wef/cliphist` fails with "Chroot not found in the given Copr project" on
this machine. `alternateved/cliphist` does have that chroot and is what's
actually installed here (`cliphist-0.7.0-2.fc43`). If upgrading to a newer
Fedora release breaks this again, check
`https://copr.fedorainfracloud.org/api_3/project?ownername=<owner>&projectname=cliphist`
for available chroots before assuming a given COPR maintainer covers your release.

Fedora ships two official-repo alternatives if you'd rather avoid COPR
entirely — `clipman` (fedora repo, built for wlroots/sway specifically) or
`gpaste` (updates repo, GNOME's clipboard manager) — but this config commits
to cliphist (`config:94`, `config:116`).

## 2. Traced list, by where it's used

| Binary / package | Referenced at | Purpose |
|---|---|---|
| `sway` | — | the WM itself; also ships `swaybar`, `swaynag`, `swaymsg` |
| `alacritty` | `config:9` (`$term`) | terminal |
| `rofi` | `config:10` (`$menu`), `waybar/scripts/power_menu.sh:2` | app launcher, power menu picker |
| `firefox` | `config:11` (`$browser`) | browser |
| `nautilus` | `config:12` (`$filemanager`) | file manager |
| `swaylock` | `config:15` (`$lock`) | screen locker |
| `swaybg` | `config:24` (`output ... background`) | wallpaper (invoked internally by sway) |
| `lxpolkit` | `config:89` | polkit authentication agent — draws the "authentication required" password dialog |
| `SwayNotificationCenter` (`swaync`, `swaync-client`) | `config:90` (daemon), `config:114` (`Super+Shift+N` toggle) | notification daemon + notification center. Replaced `mako` on 2026-08-20; configured in `swaync/` at the repo root |
| `network-manager-applet` (`nm-applet`) | `config:91` | network tray icon |
| `nm-connection-editor` | `config:235` (window rule), waybar tray menu | network connection editor |
| `blueman` (`blueman-applet`, `blueman-manager`) | `config:92`, `config:234` | bluetooth tray icon + manager |
| `wlsunset` | `config:93`, `scripts/toggle-nightlight.sh` | night light / color temp |
| `wl-clipboard` (`wl-paste`, `wl-copy`) | `config:94`, `config:194` | clipboard read + screenshot copy |
| `cliphist` | `config:94` (store), `config:116` (`Super+V` picker) | clipboard history store + picker |
| `swayidle` | `config:95` | idle timeout → lock/dpms |
| `swaynag` (in `sway`) | `config:111` | exit confirmation dialog |
| `python3` + `python3-i3ipc` | `scripts/reset-layout.sh`, `scripts/workspace_compact.py`, `scripts/reorder-workspace.py`, `waybar/scripts/mediaplayer.py` | layout reset, workspace compaction, workspace reordering, media module |
| `grim`, `slurp` | `config:194` | region screenshot |
| `libnotify` (`notify-send`) | `config:194` | screenshot confirmation toast |
| `pulseaudio-utils`/`pipewire-pulseaudio` (`pactl`) | `config:200-203` | volume/mute keys |
| `playerctl` | `config:204-207`, `waybar/scripts/mediaplayer.py` | media keys, waybar media module |
| `brightnessctl` | `config:210-211`, `scripts/brightness-down.sh` | brightness keys |
| `glib2`/`gsettings-desktop-schemas` (`gsettings`) | `config:223-226`, `scripts/toggle-theme.sh` | GTK theme + dark mode toggle |
| `gnome-themes-extra` | same as above | provides the `Adwaita`/`Adwaita-dark` GTK theme names |
| `waybar` | `config:83` (`swaybar_command`) | status bar |
| `pavucontrol` | `config:233` (window rule), `waybar/config.jsonc:136` (pulseaudio on-click) | volume mixer GUI |
| `google-noto-sans-mono-vf-fonts`, `fontawesome-6-free-fonts`, `fontawesome-6-brands-fonts` | `waybar/style.css:2` | waybar text + icon glyphs |
| `jetbrains-mono-fonts` | `config:67` (`font pango:`) | titlebar/UI font |
| `systemd` (`systemd-inhibit`, `systemctl`, `loginctl`) | `waybar/scripts/idle_inhibitor.sh`, `waybar/scripts/power_menu.sh` | idle inhibit toggle, power actions |

## 3. Known gaps

Fixed 2026-08-20: **the polkit agent**. `config:89` used to exec
`/usr/libexec/polkit-gnome-authentication-agent-1`, but `polkit-gnome` was
dropped from the Fedora 43 repos, so that file didn't exist and the exec
failed silently — `polkitd` was running with no way to prompt, so every action
needing authentication was denied and surfaced as a vague GUI error. Now
`exec lxpolkit` (`/usr/bin/lxpolkit`), chosen over `mate-polkit`/`xfce-polkit`/
`polkit-kde` for having no desktop-environment deps and a stable binary path
rather than a versioned one under `/usr/libexec`. Verify with `pkexec true`:
a graphical prompt means the agent is live, a terminal prompt means it isn't
(that's `pkttyagent`, polkit's fallback).

**Open (2026-08-20): `pavucontrol` is not installed** (`config:233` window
rule, `waybar/config.jsonc:136` pulseaudio on-click) — clicking the volume
module currently does nothing. Not in `packages.txt` (installed-only list);
`sudo dnf install pavucontrol`, then add it there.

**Open (2026-08-20): `jetbrains-mono-fonts` is not installed** — `fc-list`
returns no JetBrains face, so `config:67`'s `pango:JetBrains Mono 10` silently
falls back to the default monospace. Cosmetic only. Not in `packages.txt`;
`sudo dnf install jetbrains-mono-fonts`, then add it there.

**Open (2026-08-20): `gnome-themes-extra` is not installed** — `config:223-226`
and `scripts/toggle-theme.sh` set the GTK theme to `Adwaita`/`Adwaita-dark`.
The dark variant still resolves via libadwaita on GTK4 apps, but GTK3 apps may
not get the named theme. Not in `packages.txt`; install and add it there if
GTK3 apps look wrong.

~~`waybar/config.jsonc:158` execs `~/.config/waybar/mediaplayer.py`...~~
Fixed 2026-07-16: `waybar/mediaplayer.py` now exists, wrapping `playerctl
--follow metadata` and streaming waybar's custom-module JSON format. No new
package dependency — it only needs `playerctl` (already listed above) and
`python3`.

Fixed 2026-07-16: `cliphist` is now installed via the `alternateved/cliphist`
COPR (see section 1 for why not `wef/cliphist`). `swaymsg reload` (or
re-login) so `config:94`'s watcher starts before `Super+V` (`config:116`)
will have anything to show.

## 4. Not config-traced, but implied

- A Wayland session/login manager to actually launch sway (e.g. a
  `sway.desktop` entry via `greetd`/`gdm`/`sddm`, or launching from a TTY).
- A polkit *policy* provider is separate from the polkit *agent* above —
  usually pulled in transitively by desktop packages; not exec'd from this
  config so not traced here.
