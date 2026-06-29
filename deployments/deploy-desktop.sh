#!/bin/bash
# Deploy a Workstation Center OS desktop with cloudflare tunnel
# Usage: ./deploy-desktop.sh <username> <user-id> [--type novnc]

set -e

USERNAME=$1
USER_ID=$2
DESKTOP_TYPE="novnc"

shift 2 || true
while [ $# -gt 0 ]; do
  case "$1" in
    --type) shift; DESKTOP_TYPE="${1:-novnc}"; shift ;;
    --type=novnc) DESKTOP_TYPE="novnc"; shift ;;
    *) shift ;;
  esac
done

if [ -z "$USERNAME" ] || [ -z "$USER_ID" ]; then
  echo "Usage: $0 <username> <user-id> [--type novnc]"
  echo ""
  echo "Examples:"
  echo "  $0 john john-123                    # noVNC desktop with Firefox"
  echo "  $0 john john-123 --type novnc       # same (default)"
  exit 1
fi

NAMESPACE="desktop-${USERNAME}"
RELEASE="desktop-${USERNAME}"

echo "Deploying Workstation Center OS for user: $USERNAME (ID: $USER_ID)"
echo "  Type: $DESKTOP_TYPE"
echo ""

# Delete existing release if present
helm uninstall "$RELEASE" -n "$NAMESPACE" 2>/dev/null || true
kubectl delete namespace "$NAMESPACE" --ignore-not-found 2>/dev/null || true
sleep 2

# Deploy
helm install "$RELEASE" ./charts/desktop \
  --namespace "$NAMESPACE" \
  --create-namespace \
  --set "desktop.name=${USERNAME}" \
  --set "desktop.userId=${USER_ID}" \
  --set "desktop.type=${DESKTOP_TYPE}" \
  --set "desktop.tunnel.enabled=true" \
  --wait

echo ""
echo "Desktop deployed. Waiting for tunnel URL..."
echo ""

# Wait for pod to be ready
kubectl wait --for=condition=ready pod -l "desktop.workstation.io/name=${USERNAME}" -n "$NAMESPACE" --timeout=120s 2>/dev/null || true

# Get tunnel URL from cloudflared logs
POD=$(kubectl get pod -l "desktop.workstation.io/name=${USERNAME}" -n "$NAMESPACE" -o jsonpath='{.items[0].metadata.name}' 2>/dev/null)

if [ -n "$POD" ]; then
  echo "Pod: $POD"
  echo ""
  
  # Wait for cloudflared to emit URL in logs
  for i in $(seq 1 30); do
    TUNNEL_URL=$(kubectl logs -n "$NAMESPACE" "$POD" -c cloudflared 2>/dev/null | grep -o 'https://[a-zA-Z0-9-]*\.trycloudflare\.com' | tail -1 || true)
    if [ -n "$TUNNEL_URL" ]; then
      echo "============================================"
      echo "  WORKSTATION CENTER OS"
      echo "  TUNNEL URL: $TUNNEL_URL"
      echo "  Desktop: $USERNAME ($DESKTOP_TYPE)"
      echo "  User: $USER_ID"
      echo "============================================"
      echo ""
      echo "  Open the URL in your browser."
      echo "  The desktop includes Firefox ESR, fluxbox, and noVNC."
      echo ""
      exit 0
    fi
    sleep 2
  done
  
  echo "Warning: Tunnel URL not yet available. Check logs:"
  echo "  kubectl logs -n $NAMESPACE $POD -c cloudflared | grep trycloudflare"
else
  echo "Error: Pod not found"
  exit 1
fi
