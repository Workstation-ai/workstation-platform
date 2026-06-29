#!/bin/bash
# Inactivity monitor — shuts down desktop after N minutes of X11 idle
# Reads: IDLE_TIMEOUT_MIN (minutes), DISPLAY
# Sends SIGTERM to supervisord → graceful shutdown → KEDA scales to 0

IDLE_TIMEOUT_MIN="${IDLE_TIMEOUT_MIN:-60}"
IDLE_TIMEOUT_MS=$((IDLE_TIMEOUT_MIN * 60 * 1000))
CHECK_INTERVAL=30  # seconds

# Wait for X11 to be ready
sleep 5

echo "[inactivity] Monitor started — timeout: ${IDLE_TIMEOUT_MIN}min, display: ${DISPLAY}"

while true; do
    # Get X11 idle time in milliseconds
    IDLE_MS=$(xprintidle 2>/dev/null)

    if [ -n "$IDLE_MS" ] && [ "$IDLE_MS" -ge "$IDLE_TIMEOUT_MS" ]; then
        echo "[inactivity] Idle for $((IDLE_MS / 60000))min (threshold: ${IDLE_TIMEOUT_MIN}min) — shutting down"
        # Graceful shutdown: stop supervisord → pod dies → KEDA scales to 0
        kill -TERM $(cat /var/run/supervisord.pid 2>/dev/null || pidof supervisord) 2>/dev/null
        exit 0
    fi

    sleep $CHECK_INTERVAL
done
