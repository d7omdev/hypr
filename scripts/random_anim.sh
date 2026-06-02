#!/usr/bin/env bash
# Randomize Hyprland windowsIn / windowsOut animation styles.
# Listens to socket2 IPC and rerolls on openwindow / closewindow events.

set -euo pipefail

STYLES_IN=(
  "popin 80%"
  "popin 60%"
  "popin 50%"
  "slide"
  "slidevert"
  "slidefade"
  "slidefadevert"
  "gnomed"
)

STYLES_OUT=(
  "popin 90%"
  "popin 70%"
  "popin 50%"
  "slide"
  "slidevert"
  "slidefade"
  "slidefadevert"
  "gnomed"
)

pick() {
  local arr=("$@")
  echo "${arr[RANDOM % ${#arr[@]}]}"
}

reroll() {
  local in_style out_style
  in_style="$(pick "${STYLES_IN[@]}")"
  out_style="$(pick "${STYLES_OUT[@]}")"
  hyprctl --batch "\
    keyword animation windowsIn,1,3,emphasizedDecel,${in_style} ; \
    keyword animation windowsOut,1,2,emphasizedDecel,${out_style}" \
    >/dev/null
}

reroll

SOCK="${XDG_RUNTIME_DIR}/hypr/${HYPRLAND_INSTANCE_SIGNATURE}/.socket2.sock"

if [[ ! -S "$SOCK" ]]; then
  echo "random_anim: socket2 not found at $SOCK" >&2
  exit 1
fi

socat -U - UNIX-CONNECT:"$SOCK" | while IFS= read -r line; do
  case "$line" in
    openwindow\>\>*|closewindow\>\>*) reroll ;;
  esac
done
