#!/bin/bash
# Import a Docker image into k3s containerd
# Usage: bash import-image.sh <image:tag>
# Example: bash import-image.sh workstation/desktop:alpine-chromium

set -euo pipefail

IMAGE="${1:?Usage: import-image.sh <image:tag>}"

echo "=== Import Docker image to k3s ==="
echo "Image: $IMAGE"

# Check if image exists locally
if ! docker image inspect "$IMAGE" >/dev/null 2>&1; then
    echo "ERROR: Image '$IMAGE' not found in Docker. Pull or build it first."
    exit 1
fi

# Check k3s is running
if ! systemctl is-active k3s >/dev/null 2>&1; then
    echo "ERROR: k3s is not running. Start it with: systemctl start k3s"
    exit 1
fi

echo "Exporting from Docker and importing to k3s..."
docker save "$IMAGE" | gzip | sudo k3s ctr images import -

echo ""
echo "Verifying import..."
sudo k3s ctr images list | grep "$(echo $IMAGE | cut -d: -f1)" && echo "Import successful!" || echo "WARNING: Image not found after import."

echo ""
echo "Image available in k3s namespace 'k8s.io':"
sudo k3s ctr -n k8s.io images list | grep "$(echo $IMAGE | cut -d: -f1)" || true
