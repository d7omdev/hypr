#!/bin/bash

# Continuously sync Wayland clipboard to X11 clipboard
wl-paste --watch "xclip -selection clipboard" &
wl_watch_pid=$!

# Continuously sync X11 clipboard to Wayland clipboard
while true; do
	xclip_content=$(xclip -selection clipboard -o 2>/dev/null)
	if [[ $? -eq 0 ]]; then
		echo -n "$xclip_content" | wl-copy
	fi
	sleep 1
done

# Kill the background process on script exit
trap "kill $wl_watch_pid" EXIT
