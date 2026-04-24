#!/usr/bin/env bash
# Builds BatterySafe for epix2pro42mm using the Connect IQ SDK.
# Developer key is read from $GARMIN_DEVELOPER_KEY or the macOS default location.

set -e

REPO_ROOT="$(cd "$(dirname "$0")" && pwd)"
DEVICE="epix2pro42mm"
OUTPUT="$REPO_ROOT/bin/BatterySafe-${DEVICE}.prg"
JUNGLE="$REPO_ROOT/monkey.jungle"
MACOS_DEFAULT_KEY="$HOME/Library/Application Support/Garmin/ConnectIQ/developer_key.der"

# Check monkeyc availability
if ! command -v monkeyc &>/dev/null; then
    echo "Error: monkeyc not found in PATH." >&2
    echo "Install the Connect IQ SDK and add its bin/ directory to PATH." >&2
    exit 1
fi

# Discover developer key
if [ -n "$GARMIN_DEVELOPER_KEY" ]; then
    KEY="$GARMIN_DEVELOPER_KEY"
elif [ -f "$MACOS_DEFAULT_KEY" ]; then
    KEY="$MACOS_DEFAULT_KEY"
else
    echo "Error: developer key not found." >&2
    echo "Set \$GARMIN_DEVELOPER_KEY or place your key at:" >&2
    echo "  $MACOS_DEFAULT_KEY" >&2
    exit 1
fi

mkdir -p "$REPO_ROOT/bin"

echo "Device : $DEVICE"
echo "Key    : $KEY"
echo "Output : $OUTPUT"

monkeyc -d "$DEVICE" -f "$JUNGLE" -o "$OUTPUT" -y "$KEY"

echo "Build successful: $OUTPUT"
