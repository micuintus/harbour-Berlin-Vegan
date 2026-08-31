#!/usr/bin/env bash
# Render the current platform layer through the harness and score it.
# Usage: tools/harness/run.sh <build-dir> <out-dir>
set -euo pipefail
BUILD="${1:-build-kirigami}"
OUT="${2:-harness-out}"
BIN="$BUILD/harbour-berlin-vegan.app/Contents/MacOS/harbour-berlin-vegan"
[ -x "$BIN" ] || BIN="$BUILD/harbour-berlin-vegan"

rm -rf "$OUT" "$HOME/.qttest"
BV_HARNESS_OUT="$OUT" \
BV_HARNESS_SETTLE_MS="${BV_HARNESS_SETTLE_MS:-7000}" \
BV_HARNESS_PAGES="${BV_HARNESS_PAGES:-0,1,2,3}" \
BV_HARNESS_W="${BV_HARNESS_W:-420}" \
BV_HARNESS_H="${BV_HARNESS_H:-880}" \
QT_QPA_PLATFORM=cocoa \
    "$BIN" >"$OUT.log" 2>&1 || { echo "harness exited $?" >&2; exit 1; }

python3 tools/harness/score.py "$OUT" "${@:3}"
