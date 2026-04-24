#!/usr/bin/env bash
# Launches BatterySafe in the Connect IQ simulator for epix2pro42mm.
# Run ./build.sh first to compile the .prg before using this script.

set -e

REPO_ROOT="$(cd "$(dirname "$0")" && pwd)"
DEVICE="epix2pro42mm"
PRG="$REPO_ROOT/bin/BatterySafe-${DEVICE}.prg"

if [ ! -f "$PRG" ]; then
    echo "Error: $PRG not found." >&2
    echo "Run ./build.sh first to compile the app." >&2
    exit 1
fi

echo "Launching $PRG on $DEVICE..."
monkeydo "$PRG" "$DEVICE"
