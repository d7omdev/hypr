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

# NOTE: This script is currently ORPHANED (nothing invokes it) and was written
# for Noctalia, whose lock screen consumed these pre-captured ppm frames.
# end4-pC's lock (modules/common/panels/lock) self-renders its own background,
# so the grim pre-capture above is almost certainly obsolete. Kept + repointed
# rather than deleted — remove it if you confirm nothing else uses it.
exec hyprctl dispatch 'hl.dsp.global("quickshell:lock")'
