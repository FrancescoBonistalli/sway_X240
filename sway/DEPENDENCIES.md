# Software dependencies

Everything this config execs, either directly from `config` or from `scripts/`
and `~/.config/waybar/`. Traced from the actual `exec`/`bindsym`/`on-click`
lines, not from memory — re-run the grep below after editing `config` to
catch drift:

```
grep -oE '(exec |exec_always )[^;]*' config
```

## 1. Base install (Fedora / dnf)

```
sudo dnf install sway swaylock swayidle swaybg swaybar swaynag \
    waybar alacritty rofi mako \
    NetworkManager-applet blueman polkit-gnome \
    wlsunset wl-clipboard grim slurp \
    brightnessctl playerctl pulseaudio-utils libnotify \
    i3ipc python3 python3-i3ipc \
    gnome-themes-extra glib2 \
    pavucontrol nautilus firefox
```

Some of these (`swaylock`, `swayidle`, `swaybg`, `swaybar`, `swaynag`) may
already be pulled in as dependencies of the `sway` package itself on some
distros — check with `rpm -q swaylock` etc. before assuming a separate
install is needed on a non-Fedora system.

`cliphist` is deliberately **not** in the list above — it's not in Fedora's
official repos, only in third-party COPRs. Install it separately, then
disable the COPR so it doesn't get pulled into future `dnf upgrade` runs
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
to cliphist (`config:88`, `config:109`).

## 2. Traced list, by where it's used

| Binary / package | Referenced at | Purpose |
|---|---|---|
| `sway` | — | the WM itself |
| `alacritty` | `config:13` (`$term`) | terminal |
| `rofi` | `config:14` (`$menu`), `waybar/scripts/power_menu.sh:2` | app launcher, power menu picker |
| `firefox` | `config:15` (`$browser`) | browser |
| `nautilus` | `config:16` (`$filemanager`) | file manager |
| `swaylock` | `config:19` (`$lock`) | screen locker |
| `swaybg` | `config:28` (`output ... background`) | wallpaper (invoked internally by sway) |
| `polkit-gnome` (`/usr/libexec/polkit-gnome-authentication-agent-1`) | `config:83` | polkit auth prompts |
| `mako` | `config:84` | notification daemon |
| `network-manager-applet` (`nm-applet`, `nm-connection-editor`) | `config:85`, `config:233` | network tray icon + editor |
| `blueman` (`blueman-applet`) | `config:86`, `config:232` | bluetooth tray icon + manager |
| `wlsunset` | `config:87`, `scripts/toggle-nightlight.sh` | night light / color temp |
| `wl-clipboard` (`wl-paste`, `wl-copy`) | `config:88`, `config:187` | clipboard read + screenshot copy |
| `cliphist` | `config:88` (store), `config:109` (`Super+V` picker) | clipboard history store + picker |
| `swayidle` | `config:89` | idle timeout → lock/dpms |
| `swaynag` | `config:105` | exit confirmation dialog |
| `python3` + `i3ipc` (pip/dnf `python3-i3ipc`) | `scripts/reset-layout.sh`, `scripts/workspace_compact.py`, `scripts/reorder-workspace.py` | layout reset, workspace compaction, workspace reordering |
| `grim`, `slurp` | `config:187` | region screenshot |
| `libnotify` (`notify-send`) | `config:187` | screenshot confirmation toast |
| `pulseaudio-utils`/`pipewire-pulseaudio` (`pactl`) | `config:193-196` | volume/mute keys |
| `playerctl` | `config:197-200` | media keys |
| `brightnessctl` | `config:203`, `scripts/brightness-down.sh` | brightness keys |
| `glib2`/`gsettings-desktop-schemas` (`gsettings`) | `config:216-219`, `scripts/toggle-theme.sh` | GTK theme + dark mode toggle |
| `gnome-themes-extra` | same as above | provides the `Adwaita`/`Adwaita-dark` GTK theme names |
| `waybar` | `config:226` | status bar |
| `pavucontrol` | `config:231` (window rule), `waybar/config.jsonc:147` (pulseaudio on-click) | volume mixer GUI |
| `systemd` (`systemd-inhibit`, `systemctl`, `loginctl`) | `waybar/scripts/idle_inhibitor.sh`, `waybar/scripts/power_menu.sh` | idle inhibit toggle, power actions |

## 3. Known gaps

~~`waybar/config.jsonc:158` execs `~/.config/waybar/mediaplayer.py`...~~
Fixed 2026-07-16: `waybar/mediaplayer.py` now exists, wrapping `playerctl
--follow metadata` and streaming waybar's custom-module JSON format. No new
package dependency — it only needs `playerctl` (already listed above) and
`python3`.

Fixed 2026-07-16: `cliphist` is now installed via the `alternateved/cliphist`
COPR (see section 1 for why not `wef/cliphist`). `swaymsg reload` (or
re-login) so `config:88`'s watcher starts before `Super+V` (`config:109`)
will have anything to show.

## 4. Not config-traced, but implied

- A Wayland session/login manager to actually launch sway (e.g. a
  `sway.desktop` entry via `greetd`/`gdm`/`sddm`, or launching from a TTY).
- A polkit *policy* provider is separate from the polkit *agent* above —
  usually pulled in transitively by desktop packages; not exec'd from this
  config so not traced here.
