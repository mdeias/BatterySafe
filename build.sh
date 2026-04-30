#!/usr/bin/env bash
# Builds BatterySafe for epix2pro42mm using the Connect IQ SDK.
# Developer key discovery order:
#   1. $GARMIN_DEVELOPER_KEY environment variable
#   2. monkeyC.developerKeyPath in VS Code user settings (JSONC)
#   3. macOS standard path

set -e

REPO_ROOT="$(cd "$(dirname "$0")" && pwd)"
DEVICE="epix2pro42mm"
OUTPUT="$REPO_ROOT/bin/BatterySafe-${DEVICE}.prg"
JUNGLE="$REPO_ROOT/monkey.jungle"

# Overridable for test isolation
_VSCODE_SETTINGS="${GARMIN_VSCODE_SETTINGS:-$HOME/Library/Application Support/Code/User/settings.json}"
_STANDARD_KEY="${GARMIN_STANDARD_KEY_PATH:-$HOME/Library/Application Support/Garmin/ConnectIQ/developer_key.der}"

if ! command -v monkeyc &>/dev/null; then
    echo "Error: monkeyc not found in PATH." >&2
    echo "Install the Connect IQ SDK and add its bin/ directory to PATH." >&2
    exit 1
fi

# Developer key discovery
KEY=""

# 1. Environment variable
if [ -n "$GARMIN_DEVELOPER_KEY" ]; then
    KEY="$GARMIN_DEVELOPER_KEY"
fi

# 2. VS Code settings (monkeyC.developerKeyPath)
if [ -z "$KEY" ] && [ -f "$_VSCODE_SETTINGS" ] && command -v python3 &>/dev/null; then
    _vscode_key=$(python3 -c "
import json, re, sys
try:
    raw = open(sys.argv[1]).read()
    data = re.sub(r'//[^\n]*', '', raw)
    data = re.sub(r',\s*([}\]])', r'\1', data)
    print(json.loads(data).get('monkeyC.developerKeyPath', ''))
except Exception:
    pass
" "$_VSCODE_SETTINGS" 2>/dev/null || true)
    if [ -n "$_vscode_key" ] && [ -f "$_vscode_key" ]; then
        KEY="$_vscode_key"
    fi
fi

# 3. macOS standard path
if [ -z "$KEY" ] && [ -f "$_STANDARD_KEY" ]; then
    KEY="$_STANDARD_KEY"
fi

if [ -z "$KEY" ]; then
    echo "Error: developer key not found." >&2
    echo "Provide the key via one of:" >&2
    echo "  1. \$GARMIN_DEVELOPER_KEY environment variable" >&2
    echo "  2. monkeyC.developerKeyPath in VS Code user settings" >&2
    echo "  3. $_STANDARD_KEY" >&2
    exit 1
fi

mkdir -p "$REPO_ROOT/bin"

echo "Device : $DEVICE"
echo "Key    : $KEY"
echo "Output : $OUTPUT"

monkeyc -d "$DEVICE" -f "$JUNGLE" -o "$OUTPUT" -y "$KEY"

echo "Build successful: $OUTPUT"
