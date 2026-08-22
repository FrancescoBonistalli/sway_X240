#!/bin/bash
# Audio menu for waybar's pulseaudio module (on-click). Same rofi -dmenu
# pattern as power_menu.sh; uses pactl to match the media-key bindings in
# sway/config rather than introducing wpctl as a second tool.

mute_state=$(pactl get-sink-mute @DEFAULT_SINK@ | awk '{print $2}')
if [ "$mute_state" = "yes" ]; then
    mute_label="Unmute output"
else
    mute_label="Mute output"
fi

chosen=$(printf "%s\nToggle mic mute\nChoose output device\nOpen mixer" "$mute_label" | rofi -dmenu -p " Audio")

case "$chosen" in
    "Mute output"|"Unmute output")
        pactl set-sink-mute @DEFAULT_SINK@ toggle
        ;;
    "Toggle mic mute")
        pactl set-source-mute @DEFAULT_SOURCE@ toggle
        ;;
    "Choose output device")
        sink=$(pactl list sinks short | awk -F'\t' '{print $2}' | rofi -dmenu -p " Output")
        if [ -n "$sink" ]; then
            pactl set-default-sink "$sink"
            # set-default-sink doesn't move streams already playing; migrate them too
            pactl list sink-inputs short | awk '{print $1}' | while read -r id; do
                pactl move-sink-input "$id" "$sink"
            done
        fi
        ;;
    "Open mixer")
        pavucontrol
        ;;
esac
