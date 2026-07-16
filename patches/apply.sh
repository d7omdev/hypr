#!/usr/bin/env bash
# Reapply all end4-pC customization patches after a fresh clone.
# Idempotent: forward-applies each patch; detects already-applied ones by a
# reverse --check so re-runs are safe. Empty patches are skipped.
set -u

REPO="${1:-$HOME/.config/quickshell/end4-pC}"
PATCHES="$(cd "$(dirname "$0")" && pwd)"

for p in "$PATCHES"/end4-pC-*.patch; do
    name="$(basename "$p")"
    [ "$(stat -c%s "$p")" -gt 1 ] || { echo "· skipped $name (empty)"; continue; }

    if git -C "$REPO" apply "$p" 2>/dev/null; then
        echo "✓ applied $name"
    elif git -C "$REPO" apply --reverse --check "$p" 2>/dev/null; then
        echo "· skipped $name (already applied)"
    else
        echo "✗ FAILED  $name (conflict — apply manually)"
    fi
done
