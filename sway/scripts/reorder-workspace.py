#!/usr/bin/env python3
"""Swap the focused workspace's number with its neighbor, reordering it
in place (like GNOME's workspace-reordering extension) instead of moving
windows to a different workspace like `move container to workspace`.

Usage: reorder-workspace.py up|down
"up" swaps with the next-lower number, "down" with the next-higher one.
"""
import sys

import i3ipc

direction = sys.argv[1] if len(sys.argv) > 1 else None
if direction not in ("up", "down"):
    sys.exit("usage: reorder-workspace.py up|down")

conn = i3ipc.Connection()
workspaces = sorted(conn.get_workspaces(), key=lambda w: w.num)
current = conn.get_tree().find_focused().workspace()
idx = next(i for i, w in enumerate(workspaces) if w.num == current.num)

target_idx = idx - 1 if direction == "up" else idx + 1
if not (0 <= target_idx < len(workspaces)):
    sys.exit(0)  # already at an edge, nothing to swap with

other = workspaces[target_idx]
a_name, a_num = current.name, current.num
b_name, b_num = other.name, other.num

conn.command(f'rename workspace "{a_name}" to "__reorder_tmp__"')
conn.command(f'rename workspace "{b_name}" to "{a_num}"')
conn.command(f'rename workspace "__reorder_tmp__" to "{b_num}"')
conn.command(f'workspace number {b_num}')
