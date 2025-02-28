#!/bin/bash

# Get the current battery percentage
battery_percentage=$(cat /sys/class/power_supply/BAT0/capacity)

# Get the battery status (Charging or Discharging)
battery_status=$(cat /sys/class/power_supply/BAT0/status)

# Define the battery icons for each 10% segment
battery_icons=("󰂃" "󰁺" "󰁻" "󰁼" "󰁽" "󰁾" "󰁿" "󰂀" "󰂁" "󰁹")

# Define the charging icon
charging_icon="󰂄"

# Calculate the index for the icon array
icon_index=$((battery_percentage / 10))

# Ensure the index is within the bounds of the array
if [ "$icon_index" -ge "${#battery_icons[@]}" ]; then
	icon_index=$((${#battery_icons[@]} - 1))
fi

# Get the corresponding icon
battery_icon=${battery_icons[icon_index]}

# Check if the battery is charging
if [ "$battery_status" = "Charging" ]; then
	battery_icon="$charging_icon"
fi

# Output the battery percentage and icon
echo "$battery_percentage% $battery_icon"
