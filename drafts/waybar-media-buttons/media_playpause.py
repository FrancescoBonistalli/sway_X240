#!/usr/bin/env python3
"""Stream the active MPRIS player's play/pause state to waybar's
custom/media_playpause module (icon only; on-click toggles via playerctl).

Same long-running/re-attach pattern as mediaplayer.py, since waybar runs
this once (no "interval" in config.jsonc) and treats each stdout line as
a fresh update.
"""
import json
import subprocess
import time

PLAY_ICON = "\uf04b"
PAUSE_ICON = "\uf04c"


def emit(icon):
    print(json.dumps({"text": icon}), flush=True)


def follow():
    proc = subprocess.Popen(
        ["playerctl", "--follow", "status"],
        stdout=subprocess.PIPE, stderr=subprocess.DEVNULL, text=True, bufsize=1,
    )
    for line in proc.stdout:
        status = line.strip()
        emit(PLAY_ICON if status == "Playing" else PAUSE_ICON)
    proc.wait()


def main():
    emit(PAUSE_ICON)
    while True:
        follow()  # returns when playerctl exits (no player / player closed)
        time.sleep(2)


if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        pass
