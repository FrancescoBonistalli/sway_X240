#!/usr/bin/env python3
"""Flatten every tabbed/stacking container in the focused workspace back to splith.

Fixes the case where $mod+s (layout stacking) or $mod+w (layout tabbed) got
applied above the level that $mod+ctrl+s/$mod+ctrl+t reach, leaving a tab/stack
bar that plain "layout splith" on the focused window can't clear. This also
covers the workspace container itself, which "layout" commands scoped by
criteria don't reliably reach.
"""
import i3ipc

conn = i3ipc.Connection()
tree = conn.get_tree()
workspace = tree.find_focused().workspace()

targets = [workspace] + list(workspace.descendants())
prev_focused_id = tree.find_focused().id

for node in targets:
    if node.layout in ("tabbed", "stacking"):
        conn.command(f'[con_id={node.id}] focus')
        conn.command('layout splith')

conn.command(f'[con_id={prev_focused_id}] focus')
