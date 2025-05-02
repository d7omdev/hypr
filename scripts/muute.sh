#!/bin/bash

# Define file to store volume
VOLUME_FILE="/tmp/current_volume.txt"

volume_info=$(wpctl get-volume @DEFAULT_AUDIO_SINK@)
current_volume=$(echo "$volume_info" | grep -oP '\d+\.\d+')

volume_percentage=$(echo "$current_volume * 100" | bc -l | cut -d. -f1)

if [ "$volume_percentage" -eq 0 ]; then
	if [ -f "$VOLUME_FILE" ]; then
		stored_volume=$(cat "$VOLUME_FILE")
		wpctl set-volume @DEFAULT_AUDIO_SINK@ "$stored_volume%"
		rm "$VOLUME_FILE"
	else
		wpctl set-volume @DEFAULT_AUDIO_SINK@ 70%
	fi
else
	echo "$volume_percentage" >"$VOLUME_FILE"
	wpctl set-volume @DEFAULT_AUDIO_SINK@ 0%
fi

# Update indicator
ags run-js 'indicator.popup(1);'
