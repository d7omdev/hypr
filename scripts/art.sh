#!/usr/bin/bash

# Album Art Caching Script
# Fetches and caches album art from media players
# Usage: ./script.sh [-0|N] where N is an index in history

set -o pipefail

# Configuration
CACHE_DIR="$HOME/.cache/albumart"
HISTORY_FILE="$CACHE_DIR/history.txt"
MAX_ENTRIES=5
FALLBACK_IMAGE="$HOME/.config/hypr/hyprlock/nope.jpg"
LOG_FILE="$CACHE_DIR/albumart.log"

# Ensure cache directory exists
mkdir -p "$CACHE_DIR"
touch "$HISTORY_FILE"

# Logging function
log() {
	local level="$1"
	local message="$2"
	local timestamp="$(date +"%Y-%m-%d %H:%M:%S")"
	echo "[$timestamp] [$level] $message" >>"$LOG_FILE"

	# Trim log file if it gets too large (keep last 1000 lines)
	if [ "$(wc -l <"$LOG_FILE")" -gt 1000 ]; then
		tail -n 1000 "$LOG_FILE" >"${LOG_FILE}.tmp"
		mv "${LOG_FILE}.tmp" "$LOG_FILE"
	fi
}

# Get the active media player
get_active_player() {
	# Try to get the active player first
	local player=$(playerctl -l 2>/dev/null | grep -v chromium | head -1)

	# Check if player is actually playing something
	if [ -n "$player" ]; then
		local status=$(playerctl -p "$player" status 2>/dev/null)
		if [ "$status" = "Playing" ] || [ "$status" = "Paused" ]; then
			echo "$player"
			return 0
		fi
	fi

	# Try all available players
	for p in $(playerctl -l 2>/dev/null); do
		local status=$(playerctl -p "$p" status 2>/dev/null)
		if [ "$status" = "Playing" ] || [ "$status" = "Paused" ]; then
			echo "$p"
			return 0
		fi
	done

	return 1
}

# Generate a unique ID for the current track
get_track_id() {
	local player="$1"
	local artist=$(playerctl -p "$player" metadata xesam:artist 2>/dev/null || echo "Unknown")
	local title=$(playerctl -p "$player" metadata xesam:title 2>/dev/null || echo "Unknown")
	local album=$(playerctl -p "$player" metadata xesam:album 2>/dev/null || echo "Unknown")

	# Create a more unique ID using track metadata instead of just timestamp
	echo "${player}_${artist}_${album}_${title}" | tr -dc '[:alnum:]_'
}

# Convert an image to PNG format with error handling
convert_to_png() {
	local input_file="$1"
	local output_file="$2"

	# Check input file exists and is not empty
	if [ ! -s "$input_file" ]; then
		log "ERROR" "Input file for conversion is empty or doesn't exist: $input_file"
		return 1
	fi

	# Try to identify the image format first
	if ! identify "$input_file" &>/dev/null; then
		log "ERROR" "Not a valid image file: $input_file"
		return 1
	fi

	# Convert image to PNG
	if convert "$input_file" -resize 512x512\> "$output_file" 2>/dev/null; then
		log "INFO" "Successfully converted image to PNG: $output_file"
		return 0
	else
		log "ERROR" "Failed to convert image: $input_file"
		return 1
	fi
}

# Clean up unreferenced album art files
cleanup_cache() {
	log "INFO" "Starting cache cleanup"

	# Keep track of files to keep
	local keep_files=()

	# Always keep the fallback image
	keep_files+=("$FALLBACK_IMAGE")

	# Extract currently referenced art files from history
	while IFS='|' read -r _ file; do
		if [ -n "$file" ] && [ -f "$file" ]; then
			keep_files+=("$file")
		fi
	done <"$HISTORY_FILE"

	# Find and remove unreferenced PNG files
	local removed=0
	find "$CACHE_DIR" -name "*.png" -type f | while read -r file; do
		local keep=0
		for kf in "${keep_files[@]}"; do
			if [ "$file" = "$kf" ]; then
				keep=1
				break
			fi
		done

		if [ "$keep" -eq 0 ]; then
			rm -f "$file"
			removed=$((removed + 1))
		fi
	done

	log "INFO" "Removed $removed unreferenced cache files"

	# Clean up temporary files older than 1 day
	find "$CACHE_DIR" -name "tmp.*" -type f -mtime +1 -delete
}

# Fetch current track metadata and handle art caching
fetch_current_album_art() {
	# Get active player
	local player=$(get_active_player)

	# If no player is active, return the fallback image
	if [ -z "$player" ]; then
		log "INFO" "No active player found, using fallback image"
		echo "$FALLBACK_IMAGE"
		return 0
	fi

	# Get track metadata
	local url=$(playerctl -p "$player" metadata mpris:artUrl 2>/dev/null)
	local artist=$(playerctl -p "$player" metadata xesam:artist 2>/dev/null || echo "Unknown")
	local album=$(playerctl -p "$player" metadata xesam:album 2>/dev/null || echo "Unknown")
	local title=$(playerctl -p "$player" metadata xesam:title 2>/dev/null || echo "Unknown")

	log "INFO" "Playing: $artist - $title ($album) on $player"

	# If no album art URL is available, return fallback
	if [ -z "$url" ]; then
		log "WARNING" "No art URL available for current track"
		echo "$FALLBACK_IMAGE"
		return 0
	fi

	# Create safe filename
	local safe_metadata=$(printf "%s_%s_%s" "$player" "$artist" "$album" | tr -dc '[:alnum:]_-' | head -c 100)
	local art_file="$CACHE_DIR/${safe_metadata}.png"

	# Skip if the file already exists and is valid
	if [ -f "$art_file" ]; then
		log "INFO" "Using cached album art: $art_file"
		echo "$art_file"

		# Update history to keep this file at the top
		local track_id=$(get_track_id "$player")
		local tmp_history=$(mktemp "$CACHE_DIR/tmp.XXXXXX")

		# Add current entry at top
		echo "$track_id|$art_file" >"$tmp_history"

		# Append existing entries, skipping duplicates
		grep -vF "|$art_file" "$HISTORY_FILE" | head -n $((MAX_ENTRIES - 1)) >>"$tmp_history"

		# Replace history file
		mv "$tmp_history" "$HISTORY_FILE"

		return 0
	fi

	log "INFO" "Fetching album art from URL: $url"

	# Download the image to a temporary file
	local temp_file=$(mktemp "$CACHE_DIR/tmp.XXXXXX")

	if [[ "$url" == file://* ]]; then
		# Local file URLs
		local file_path="${url#file://}"

		if [ -f "$file_path" ]; then
			cp "$file_path" "$temp_file"
		else
			log "ERROR" "Local file doesn't exist: $file_path"
			rm -f "$temp_file"
			echo "$FALLBACK_IMAGE"
			return 0
		fi
	else
		# Network URLs
		if ! curl -sL --max-time 5 "$url" -o "$temp_file"; then
			log "ERROR" "Failed to download image from URL: $url"
			rm -f "$temp_file"
			echo "$FALLBACK_IMAGE"
			return 0
		fi
	fi

	# Check if the downloaded file is a valid image
	if ! identify "$temp_file" &>/dev/null; then
		log "ERROR" "Downloaded file is not a valid image"
		rm -f "$temp_file"
		echo "$FALLBACK_IMAGE"
		return 0
	fi

	# Convert the downloaded image to PNG
	if ! convert_to_png "$temp_file" "$art_file"; then
		log "ERROR" "Failed to convert image to PNG"
		rm -f "$temp_file"
		echo "$FALLBACK_IMAGE"
		return 0
	fi

	# Clean up temporary file
	rm -f "$temp_file"

	# Update history with new entry
	local track_id=$(get_track_id "$player")
	local tmp_history=$(mktemp "$CACHE_DIR/tmp.XXXXXX")

	# Add new entry at top
	echo "$track_id|$art_file" >"$tmp_history"

	# Append existing entries, skipping duplicates
	grep -vF "|$art_file" "$HISTORY_FILE" | head -n $((MAX_ENTRIES - 1)) >>"$tmp_history"

	# Replace history file
	mv "$tmp_history" "$HISTORY_FILE"

	# Run cleanup in the background to avoid delaying output
	(cleanup_cache) &

	log "INFO" "Successfully cached album art: $art_file"
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

	# Check if history file exists and has enough entries
	if [ ! -f "$HISTORY_FILE" ] || [ "$(wc -l <"$HISTORY_FILE")" -lt "$line_num" ]; then
		log "WARNING" "History entry $line_num not found, fetching current art instead"
		fetch_current_album_art
		return $?
	fi

	# Extract art path from history
	local art_file=$(sed -n "${line_num}p" "$HISTORY_FILE" 2>/dev/null | cut -d'|' -f2)

	# Check if the file exists
	if [ ! -f "$art_file" ]; then
		log "WARNING" "Art file not found: $art_file, fetching current art instead"
		fetch_current_album_art
		return $?
	fi

	log "INFO" "Returning historical art: $art_file (index $index)"
	echo "$art_file"
}

# Main execution flow
main() {
	# Initialize log file with rotation if needed
	if [ -f "$LOG_FILE" ] && [ "$(stat -c %s "$LOG_FILE")" -gt 1048576 ]; then # 1MB
		mv "$LOG_FILE" "${LOG_FILE}.old"
	fi

	log "INFO" "===== Album Art Script Started ====="

	# Handle current track request
	if [[ "$1" == "-0" ]] || [ $# -eq 0 ]; then
		fetch_current_album_art
	# Handle history requests
	else
		# Check if input is a valid number
		if [[ "$1" =~ ^-?[0-9]+$ ]]; then
			get_art_by_index "$1"
		else
			log "ERROR" "Invalid parameter: $1"
			echo "$FALLBACK_IMAGE"
			return 1
		fi
	fi
}

# Trap for cleanup on exit
trap 'log "INFO" "Script execution completed"; exit 0' EXIT

# Run the main function with all arguments
main "$@"
