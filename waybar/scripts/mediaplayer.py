#!/usr/bin/env python3
"""Stream the active MPRIS player's track to waybar's custom/media module.

Waybar runs this once (no "interval" in config.jsonc) and treats each line
of stdout as a fresh update, so it must stay alive and re-attach to
playerctl whenever no player is running / the player disappears.
"""
import json
import subprocess
import time

FORMAT = "{{status}}\t{{playerName}}\t{{artist}}\t{{title}}"


def emit(text="", alt="default", cls="", tooltip=""):
    print(json.dumps({"text": text, "alt": alt, "class": cls, "tooltip": tooltip}), flush=True)


def follow():
    proc = subprocess.Popen(
        ["playerctl", "--follow", "metadata", "--format", FORMAT],
        stdout=subprocess.PIPE, stderr=subprocess.DEVNULL, text=True, bufsize=1,
    )
    for line in proc.stdout:
        parts = line.rstrip("\n").split("\t", 3)
        if len(parts) != 4:
            continue
        status, player, artist, title = parts
        if status != "Playing" or not title:
            emit()
            continue
        text = f"{artist} - {title}" if artist else title
        emit(text=text, alt=player.lower(), cls=player.lower(), tooltip=f"{player}: {text}")
    proc.wait()


def main():
    emit()
    while True:
        follow()  # returns when playerctl exits (no player / player closed)
        time.sleep(2)


if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        pass
