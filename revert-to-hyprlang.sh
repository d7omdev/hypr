#!/usr/bin/env bash
# Emergency revert: swap Lua entry back to hyprlang.
# Run from a tty if the Lua config breaks login.

set -euo pipefail
cd "$(dirname "$(readlink -f "$0")")"

if [[ -f hyprland.lua ]]; then
    mv hyprland.lua hyprland.lua.draft
    echo "moved hyprland.lua -> hyprland.lua.draft"
fi

if [[ -f hyprland.conf.hyprlang.disabled ]]; then
    mv hyprland.conf.hyprlang.disabled hyprland.conf
    echo "restored hyprland.conf"
elif [[ -f hyprland.conf.bak ]]; then
    cp hyprland.conf.bak hyprland.conf
    echo "restored hyprland.conf from .bak"
else
    echo "no backup found — manual recovery needed" >&2
    exit 1
fi

echo
echo "done. Log in again to load the old hyprlang config."
