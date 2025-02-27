#!/usr/bin/bash
url=$(playerctl metadata mpris:artUrl)
artist=$(playerctl metadata xesam:artist)
album=$(playerctl metadata xesam:album)
metadata=$(printf "%s - %s" "$artist" "$album")

mkdir -p "$HOME/.cache/albumart"

if [ "$url" == "No player found" ]; then
	exit
elif [ -f "$HOME/.cache/albumart/$metadata.png" ]; then
	echo "$HOME/.cache/albumart/$metadata.png"
else
	curl -s "$url" -o "$HOME/.cache/albumart/$metadata"
	magick "$HOME/.cache/albumart/$metadata" "$HOME/.cache/albumart/$metadata.png"
	rm "$HOME/.cache/albumart/$metadata"
	echo "$HOME/.cache/albumart/$metadata.png"
fi
