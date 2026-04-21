#!/usr/bin/env python3
"""Compact sway workspaces: renumber them 1..N with no gaps."""
import i3ipc
import threading

_timer = None

def schedule_compact(i3, event):
    global _timer
    if _timer is not None:
        _timer.cancel()
    _timer = threading.Timer(0.3, do_compact)
    _timer.daemon = True
    _timer.start()

def do_compact():
    conn = i3ipc.Connection()
    workspaces = sorted(conn.get_workspaces(), key=lambda w: w.num)
    for idx, ws in enumerate(workspaces, start=1):
        if ws.num != idx:
            conn.command(f'rename workspace "{ws.name}" to "{idx}"')

conn = i3ipc.Connection()
conn.on(i3ipc.Event.WINDOW_CLOSE, schedule_compact)
conn.on(i3ipc.Event.WINDOW_MOVE, schedule_compact)
conn.on(i3ipc.Event.WORKSPACE_FOCUS, schedule_compact)
conn.main()
