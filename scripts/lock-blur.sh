#!/bin/sh
# Capture each monitor BEFORE the session-lock surface is raised, so the
# lockscreen can show a blurred frame of the real desktop. Once locked, the
# compositor stops painting apps into the output, so any capture after this
# point would be black — that is why this must run before the lock IPC.

OUT_DIR="${XDG_RUNTIME_DIR:-/tmp}"

for m in $(hyprctl -j monitors | jq -r '.[].name'); do
	# -t ppm is uncompressed and fastest; we only need it for a split second.
	grim -o "$m" -t ppm "$OUT_DIR/noctalia-lock-$m.ppm" 2>/dev/null
done

exec qs -c noctalia-shell ipc call lockScreen lock
