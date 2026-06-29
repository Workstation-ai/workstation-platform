#!/bin/bash
# Get tunnel URL for an existing desktop
# Usage: ./get-tunnel-url.sh <username>

set -e

USERNAME=$1

if [ -z "$USERNAME" ]; then
  echo "Usage: $0 <username>"
  exit 1
fi

NAMESPACE="desktop-${USERNAME}"
POD=$(kubectl get pod -l "desktop.workstation.io/name=${USERNAME}" -n "$NAMESPACE" -o jsonpath='{.items[0].metadata.name}' 2>/dev/null)

if [ -z "$POD" ]; then
  echo "No desktop pod found for user: $USERNAME"
  exit 1
fi

echo "Pod: $POD"
echo ""

# Try to get URL from shared volume
TUNNEL_URL=$(kubectl exec -n "$NAMESPACE" "$POD" -c cloudflared -- cat /tmp/tunnel/URL 2>/dev/null || true)

if [ -n "$TUNNEL_URL" ]; then
  echo "Tunnel URL: $TUNNEL_URL"
else
  echo "Tunnel URL not yet available."
  echo ""
  echo "Checking cloudflared logs..."
  kubectl logs -n "$NAMESPACE" "$POD" -c cloudflared --tail=20 2>/dev/null || true
fi
