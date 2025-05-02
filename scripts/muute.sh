#!/bin/bash

# Get current volume and mute state using wpctl
volume_info=$(wpctl get-volume @DEFAULT_AUDIO_SINK@)
current_volume=$(echo "$volume_info" | grep -oP '\d+\.\d+(?=%)') # Get volume percentage
mute_status=$(echo "$volume_info" | grep -o '\[MUTED\]')         # Check if muted

# Toggle mute based on current status
if [ -n "$mute_status" ]; then
	# Unmute the audio and restore the volume
	wpctl set-volume @DEFAULT_AUDIO_SINK@ 0%
	echo "Audio unmuted and restored to $current_volume"
else
	# Mute the audio
	wpctl set-volume @DEFAULT_AUDIO_SINK@ "$current_volume"
	echo "Audio muted at $current_volume"
fi

# Update the indicator
ags run-js 'indicator.popup(1);'
