#!/usr/bin/bash

# Cache directory setup
CACHE_DIR="$HOME/.cache/albumart"
mkdir -p "$CACHE_DIR"
HISTORY_FILE="$CACHE_DIR/history.txt"

# Maximum number of history entries and cached files to maintain
MAX_ENTRIES=5

# Fallback image path
FALLBACK_IMAGE="$HOME/.config/hypr/hyprlock/nope.jpg"

# Generate a unique ID for the current track
get_track_id() {
	local player="$1"
	date +"%s_${player}"
}

# Clean up unreferenced album art files
cleanup_cache() {
	# Extract currently referenced art files from history
	local keep_files=()
	while IFS='|' read -r _ file; do
		keep_files+=("$file")
	done <"$HISTORY_FILE"

	# Find and remove unreferenced PNG files
	find "$CACHE_DIR" -name "*.png" | while read -r file; do
		if ! printf '%s\n' "${keep_files[@]}" | grep -Fxq "$file"; then
			rm -f "$file"
		fi
	done
}

# Convert an image to PNG format
convert_to_png() {
	local input_file="$1"
	local output_file="$2"

	if convert "$input_file" "$output_file" 2>/dev/null; then
		return 0
	else
		return 1
	fi
}

# Fetch current track metadata and handle art caching
fetch_current_album_art() {
	# Get active player
	local player=$(playerctl -l 2>/dev/null | head -1)

	# If no player is running, return the fallback image
	if [ -z "$player" ]; then
		echo "$FALLBACK_IMAGE"
		return 0
	fi

	# Get track metadata
	local url=$(playerctl -p "$player" metadata mpris:artUrl 2>/dev/null)
	local artist=$(playerctl -p "$player" metadata xesam:artist 2>/dev/null || echo "Unknown")
	local album=$(playerctl -p "$player" metadata xesam:album 2>/dev/null || echo "Unknown")
	[ -z "$url" ] && return 1

	# Create safe filename and paths
	local safe_metadata=$(printf "%s - %s" "$artist" "$album" | tr -dc '[:alnum:] -_.')
	local art_file="$CACHE_DIR/${safe_metadata}.png"

	# Skip if the file already exists and is valid
	if [ -f "$art_file" ]; then
		echo "$art_file"
		return 0
	fi

	# Download the image to a temporary file
	local temp_file=$(mktemp -p "$CACHE_DIR")
	if ! curl -sL "$url" -o "$temp_file"; then
		rm -f "$temp_file"
		return 1
	fi

	# Convert the downloaded image to PNG
	if ! convert_to_png "$temp_file" "$art_file"; then
		rm -f "$temp_file"
		return 1
	fi

	# Clean up temporary file
	rm -f "$temp_file"

	# Update history with new entry
	local track_id=$(get_track_id "$player")
	local tmp_history=$(mktemp)

	# Add new entry at top
	echo "$track_id|$art_file" >"$tmp_history"

	# Append existing entries, skipping duplicates
	grep -vF "|$art_file" "$HISTORY_FILE" | head -n $((MAX_ENTRIES - 1)) >>"$tmp_history"

	# Replace history file and clean up
	mv "$tmp_history" "$HISTORY_FILE"
	cleanup_cache

	echo "$art_file"
}

# Retrieve historical art entry by index
get_art_by_index() {
	local index="${1:-1}"
	local line_num=1

	# Calculate line number from index
	if [ "$index" -lt 0 ]; then
		line_num=$((-index + 1))
	else
		line_num=$index
	fi

	# Extract art path from history
	local art_file=$(sed -n "${line_num}p" "$HISTORY_FILE" 2>/dev/null | cut -d'|' -f2)

	# Fallback to current art if invalid
	if [ ! -f "$art_file" ]; then
		art_file=$(fetch_current_album_art)
	fi

	# If no art file is found, return the fallback image
	if [ ! -f "$art_file" ]; then
		art_file="$FALLBACK_IMAGE"
	fi

	local player=$(playerctl -l 2>/dev/null | head -1)
	# If no player is running, return
	if [ -z "$player" ]; then
		return 0
	fi

	echo "${art_file:-}"
}

# Main execution flow
main() {
	# Handle current track request
	if [[ "$1" == "-0" ]] || [ $# -eq 0 ]; then
		fetch_current_album_art
	# Handle history requests
	else
		get_art_by_index "$1"
	fi
}

main "$@"
