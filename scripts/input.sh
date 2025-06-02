input=$(
	hyprctl devices -j | jq -r '.keyboards[] | select(.main == true) | .active_keymap | if . | test("English") then "En" else if . | test("Arabic") then "Ar" else "Unknown" end end'
)

echo "  $input "
