#!/bin/bash
set -e

echo "=== Starting noVNC Desktop ==="

# Start Xvfb
echo "Starting Xvfb..."
Xvfb :1 -screen 0 1920x1080x24 &
sleep 2

# Start fluxbox
echo "Starting fluxbox..."
fluxbox &
sleep 2

# Start x11vnc
echo "Starting x11vnc..."
x11vnc -display :1 -forever -shared -rfbport 5900 -rfbauth /home/user/.vnc/passwd &
sleep 2

# Start websockify + noVNC
echo "Starting noVNC on port 6080..."
websockify --web /usr/share/novnc 6080 localhost:5900 &
sleep 2

echo "=== Desktop ready ==="
echo "  VNC: localhost:5900"
echo "  noVNC: http://localhost:6080"
echo ""

# Keep running
wait
