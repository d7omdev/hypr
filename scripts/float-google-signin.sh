#!/usr/bin/env bash

# Precompute size once at startup
read -r mon_w mon_h < <(hyprctl monitors -j | jq -r '.[] | select(.focused) | "\(.width) \(.height)"')
W=$(( mon_w * 40 / 100 ))
H=$(( mon_h * 70 / 100 ))

handle() {
    local line="$1"
    if [[ "$line" =~ ^windowtitlev2\>\>([a-f0-9]+),Sign\ in\ -\ Google\ Accounts ]]; then
        local addr="${BASH_REMATCH[1]}"
        hyprctl --batch "dispatch focuswindow address:0x${addr}; dispatch togglefloating address:0x${addr}; dispatch resizewindowpixel exact $W $H,address:0x${addr}; dispatch centerwindow"
    fi
}

stdbuf -oL socat -U - "UNIX-CONNECT:${XDG_RUNTIME_DIR}/hypr/${HYPRLAND_INSTANCE_SIGNATURE}/.socket2.sock" \
    | while IFS= read -r line; do
        handle "$line"
    done
