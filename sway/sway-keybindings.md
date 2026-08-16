# Sway Keybindings Cheatsheet

The **Mod key** is `Super` (Windows key).

## Launching
| Keybind | Action |
|---|---|
| `Super + Return` | Open terminal |
| `Super + D` | App launcher |
| `Super + B` | Browser |
| `Super + F` | File manager |
| `Super + Shift + L` | Lock screen |
| `Super + N` | Toggle night light (wlsunset) |
| `Super + V` | Clipboard history picker (cliphist + rofi) — selecting an entry only copies it; focus the target field and press `Ctrl+V` to paste |

## Window management
| Keybind | Action |
|---|---|
| `Super + Shift + Q` | Close window |
| `Super + Shift + F` | Intermediate fullscreen: hide/show waybar only |
| `Super + Shift + Space` | Toggle floating |
| `Super + Space` | Toggle focus between tiled/floating |
| `Super + R` | Resize mode (arrows to resize, `Escape` to exit) |

## Focus & movement
| Keybind | Action |
|---|---|
| `Super + H/J/K/L` | Focus left/down/up/right |
| `Super + Down/Up` | Focus down/up (arrow-key alternative; left/right use workspace switching instead) |
| `Super + Shift + Arrows` | Move window left/down/up/right |

## Layout
| Keybind | Action |
|---|---|
| `Super + Ctrl + S` | Split horizontal |
| `Super + Ctrl + T` | Split vertical |
| `Super + S` | Toggle waybar visibility *(temporary — was Stacking layout, reverted until the stuck-stacking bug is fixed)* |
| `Super + W` | Tabbed layout |
| `Super + Shift + S` | Reset stuck tabbed/stacking layout back to tiling (whole workspace) |
| `Super + Z` | Toggle split direction |
| `Super + A` | Focus parent container |

## Workspaces
| Keybind | Action |
|---|---|
| `Super + 1..0` | Switch to workspace 1–10 |
| `Super + Shift + 1..0` | Move window to workspace 1–10 |
| `Super + scroll` (anywhere over a window) | Previous/next workspace — same as scrolling over the workspace numbers in waybar |
| `Super + Ctrl + Up/Down` | Reorder the *current* workspace with its neighbor (swaps numbers, stays on the same content — like GNOME's workspace-reordering extension), instead of moving windows between workspaces |

## Scratchpad
| Keybind | Action |
|---|---|
| `Super + Shift + -` | Send window to scratchpad |
| `Super + -` | Show/hide scratchpad |

## Screenshots
| Keybind | Action |
|---|---|
| `Print` | Region screenshot → clipboard |

## Media & brightness
| Keybind | Action |
|---|---|
| `XF86AudioRaiseVolume` / `XF86AudioLowerVolume` | Volume up/down |
| `XF86AudioMute` | Mute toggle |
| `XF86AudioPlay/Next/Prev` | Media controls |
| `$mod + P` | Play/pause media (playerctl) |
| `XF86MonBrightnessUp/Down` | Brightness up/down |

## System
| Keybind | Action |
|---|---|
| `Super + Shift + C` | Reload sway config |
| `Super + Shift + E` | Exit sway (with confirmation) |
