#!/usr/bin/env bash

getdate() {
	date '+%Y-%m-%d_%H.%M.%S'
}

getaudiooutput() {
	pactl list sources | grep 'Name' | grep 'monitor' | cut -d ' ' -f2
}

getactivemonitor() {
	hyprctl monitors -j | jq -r '.[] | select(.focused == true) | .name'
}

getmonitorlist() {
	hyprctl monitors -j | jq -r '.[].name' | zenity --list --title="Select Monitor" --column="Available Monitors"
}

mkdir -p "$HOME/Videos/ScreenRecordings"
cd "$HOME/Videos/ScreenRecordings" || exit

recording_file="$HOME/Videos/ScreenRecordings/recording_$(getdate).mp4"

# Check if wf-recorder is running
if pgrep wf-recorder >/dev/null; then
	# Stop recording
	pkill wf-recorder &
	notify-send -a "record-script.sh" "Recording Stopped" "Click to open the recorded video." -i "video" --action="open_video=Open Video" &
	sleep 1
	read -r -p "Press enter to open the recording folder..." &&
		xdg-open "$HOME/Videos/ScreenRecordings" &
	sleep 0.5 &&
		recent_video=$(ls -t "$HOME/Videos/ScreenRecordings" | head -n 1) &&
		xdg-open "$HOME/Videos/ScreenRecordings/$recent_video"
else
	# Ask user for recording type
	recording_mode=$(zenity --list --title="Select Recording Mode" --radiolist --column="Select" --column="Option" \
		TRUE "Region (Drag to select)" \
		FALSE "Fullscreen")

	if [[ -z "$recording_mode" ]]; then
		exit 1
	fi

	# Ask if user wants sound
	include_sound=$(zenity --question --title="Sound Recording" --text="Do you want to record system audio?" && echo "yes" || echo "no")

	# Ask user for display (if fullscreen is selected)
	if [[ "$recording_mode" == "Fullscreen" ]]; then
		selected_monitor=$(getmonitorlist)
		if [[ -z "$selected_monitor" ]]; then
			exit 1
		fi
	fi

	notify-send "Starting recording" "recording_$(getdate).mp4" -a 'record-script.sh'
	sleep 1

	# Start recording based on selection
	if [[ "$recording_mode" == "Region (Drag to select)" ]]; then
		if [[ "$include_sound" == "yes" ]]; then
			wf-recorder --pixel-format yuv420p -f "$recording_file" -t --geometry "$(slurp)" --audio="$(getaudiooutput)" &
		else
			wf-recorder --pixel-format yuv420p -f "$recording_file" -t --geometry "$(slurp)" &
		fi
	else
		if [[ "$include_sound" == "yes" ]]; then
			wf-recorder -o "$selected_monitor" --pixel-format yuv420p -f "$recording_file" -t --audio="$(getaudiooutput)" &
		else
			wf-recorder -o "$selected_monitor" --pixel-format yuv420p -f "$recording_file" -t &
		fi
	fi
	disown
fi
