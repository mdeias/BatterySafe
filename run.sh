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

if ! pgrep -f "ConnectIQ.app/Contents/MacOS" > /dev/null 2>&1; then
    echo "Connect IQ simulator not running — launching..."
    open -a ConnectIQ

    WAIT=0
    TIMEOUT=15
    until pgrep -f "ConnectIQ.app/Contents/MacOS" > /dev/null 2>&1; do
        sleep 1
        WAIT=$((WAIT + 1))
        if [ $WAIT -ge $TIMEOUT ]; then
            echo "" >&2
            echo "Error: Connect IQ simulator did not start within ${TIMEOUT} seconds." >&2
            echo "Try launching it manually, then re-run: ./run.sh" >&2
            exit 1
        fi
    done
    # Process exists before the simulator is ready to accept connections; give it a moment.
    sleep 5
    echo "Simulator ready."
fi

echo "Launching $PRG on $DEVICE..."

STDERR_FILE=$(mktemp)
set +e
monkeydo "$PRG" "$DEVICE" 2>"$STDERR_FILE"
EXIT=$?
set -e

cat "$STDERR_FILE" >&2

if [ $EXIT -ne 0 ] && grep -qi "unable to connect to simulator" "$STDERR_FILE"; then
    echo "" >&2
    echo "Error: Connect IQ simulator is not running." >&2
    echo "" >&2
    echo "Start the simulator first, then re-run ./run.sh:" >&2
    echo "  Option 1: Open the Connect IQ companion app and launch the simulator from there." >&2
    echo "  Option 2: In VS Code, press Cmd+Shift+P → 'Monkey C: Run App'." >&2
    echo "" >&2
    echo "Once the simulator is open, re-run: ./run.sh" >&2
fi

rm -f "$STDERR_FILE"
exit $EXIT
