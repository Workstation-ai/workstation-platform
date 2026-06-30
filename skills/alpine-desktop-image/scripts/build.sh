#!/bin/bash
# Build Alpine desktop image with browser selection
# Usage: BROWSER=chromium bash build.sh
set -euo pipefail

BROWSER="${BROWSER:-firefox}"
REGISTRY="${REGISTRY:-workstation/desktop}"
TAG="${TAG:-alpine-${BROWSER}}"

echo "=== Building Alpine Desktop Image ==="
echo "Browser: $BROWSER"
echo "Image: ${REGISTRY}:${TAG}"

# Validate browser
if [[ "$BROWSER" != "firefox" && "$BROWSER" != "chromium" ]]; then
    echo "ERROR: BROWSER must be 'firefox' or 'chromium'"
    exit 1
fi

# Check Docker
if ! command -v docker &>/dev/null; then
    echo "ERROR: Docker not found"
    exit 1
fi

# Build
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
CONTEXT="$(dirname "$SCRIPT_DIR")/images/desktop-novnc"

if [ ! -f "$CONTEXT/Dockerfile" ]; then
    echo "ERROR: Dockerfile not found at $CONTEXT"
    exit 1
fi

docker build \
    --build-arg BROWSER="$BROWSER" \
    --no-cache \
    -t "${REGISTRY}:${TAG}" \
    "$CONTEXT"

echo ""
echo "=== Build Complete ==="
docker images "${REGISTRY}:${TAG}"
echo ""
echo "Import to k3s:"
echo "  docker save ${REGISTRY}:${TAG} | gzip | sudo k3s ctr images import -"
