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

# ── Launch desktop environment via supervisord ─────────────────────────
exec supervisord -c /etc/supervisor/conf.d/supervisord.conf
