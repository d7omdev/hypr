#!/bin/bash

# Check if the argument is provided
if [ -z "$1" ]; then
    echo "Usage: $0 [up|down|left|right]"
    exit 1
fi

# Prevent execution in Kitty terminal
if [ "$TERM" = "xterm-kitty" ]; then
    echo "This script cannot be run in Kitty terminal."
    exit 1
fi

# Set the key based on the argument
case "$1" in
up)
    key="Up"
    ;;
down)
    key="Down"
    ;;
left)
    key="Left"
    ;;
right)
    key="Right"
    ;;
*)
    echo "Invalid argument: $1. Use up, down, left, or right."
    exit 1
    ;;
esac

# Send a keydown event
xdotool keydown "$key"

# Wait until the key is released
read -n 1 -s -r -p "Press any key to stop... "
xdotool keyup "$key"
