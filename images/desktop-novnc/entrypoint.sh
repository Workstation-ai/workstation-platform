#!/bin/bash
set -e

# ── Branding: set wallpaper from workstation.center logo ────────────────
BRANDING_DIR="/usr/share/workstation/branding"
WALLPAPER="/home/desktop/.workstation/wallpaper.png"

if [ -f "$BRANDING_DIR/logo.png" ]; then
    cp "$BRANDING_DIR/logo.png" "$WALLPAPER"
    chown desktop:desktop "$WALLPAPER"
fi

# ── Set window title via xprop (if X is ready) ─────────────────────────
export DISPLAY=:99

# ── Inactivity monitor (background) ─────────────────────────────────────
# IDLE_TIMEOUT_MIN controls auto-shutdown: 0 = disabled, N = shutdown after N min idle
if [ "${IDLE_TIMEOUT_MIN:-0}" -gt 0 ] 2>/dev/null; then
    /usr/local/bin/inactivity-monitor.sh &
    echo "[entrypoint] Inactivity monitor enabled: ${IDLE_TIMEOUT_MIN}min"
else
    echo "[entrypoint] Inactivity monitor disabled (IDLE_TIMEOUT_MIN=0)"
fi

# ── Launch desktop environment via supervisord ─────────────────────────
exec supervisord -c /etc/supervisor/conf.d/supervisord.conf
