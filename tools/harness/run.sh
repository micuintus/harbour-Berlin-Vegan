#!/usr/bin/env bash
# Render the current platform layer through the harness and score it.
# Usage: tools/harness/run.sh <build-dir> <out-dir> [extra score.py args]
#
# Startup is not bit-reproducible (async data load, lazy attached pages), so a
# single pass samples a random subset of what can go wrong. Run several and let
# score.py union them; BV_HARNESS_PASSES controls how many.
set -euo pipefail
BUILD="${1:-build-kirigami}"
OUT="${2:-harness-out}"
PASSES="${BV_HARNESS_PASSES:-3}"
BIN="$BUILD/harbour-berlin-vegan.app/Contents/MacOS/harbour-berlin-vegan"
[ -x "$BIN" ] || BIN="$BUILD/harbour-berlin-vegan"

rm -rf "$OUT"
DIRS=()
for pass in $(seq 1 "$PASSES"); do
    rm -rf "$HOME/.qttest"
    DIR="$OUT/pass$pass"
    mkdir -p "$DIR"
    BV_HARNESS_OUT="$DIR" \
    BV_HARNESS_SETTLE_MS="${BV_HARNESS_SETTLE_MS:-9000}" \
    BV_HARNESS_PAGES="${BV_HARNESS_PAGES:-0,1,2,3}" \
    BV_HARNESS_W="${BV_HARNESS_W:-840}" \
    BV_HARNESS_H="${BV_HARNESS_H:-900}" \
    QT_QPA_PLATFORM=cocoa \
        "$BIN" >"$OUT/pass$pass.log" 2>&1 || { echo "pass $pass exited $?" >&2; exit 1; }
    DIRS+=("$DIR")
done

python3 tools/harness/score.py "${DIRS[@]}" "${@:3}"
