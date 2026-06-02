#!/bin/bash
# Smart focus: moves between windows in scrolling layout,
# or switches workspace when at edge

DIRECTION="$1" # "left" or "right"

# Get current workspace
CURRENT_WS=$(hyprctl activeworkspace -j | jq -r .id)

# Get all workspaces sorted by ID
WORKSPACES=$(hyprctl workspaces -j | jq -r '.[].id' | sort -n)

# Try layoutmsg for scrolling layout first
hyprctl dispatch layoutmsg "focus${DIRECTION}"

# Check if focus actually changed by comparing active window
# If focus didn't change, we're at edge - switch workspace
sleep 0.05
NEW_WS=$(hyprctl activeworkspace -j | jq -r .id)

if [ "$CURRENT_WS" != "$NEW_WS" ]; then
	exit 0 # Focus moved within workspace, we're done
fi

# Still same workspace, so we're at edge - switch workspace
if [ "$DIRECTION" = "left" ]; then
	hyprctl dispatch workspace r-1
elif [ "$DIRECTION" = "right" ]; then
	hyprctl dispatch workspace r+1
fi
