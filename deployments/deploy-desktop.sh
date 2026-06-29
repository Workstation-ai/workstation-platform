#!/bin/bash
# Deploy a desktop with cloudflare tunnel
# Usage: ./deploy-desktop.sh <username> <user-id> [--type novnc|guacamole] [--edition tiny|pro]

set -e

USERNAME=$1
USER_ID=$2
DESKTOP_TYPE="novnc"
EDITION="tiny"

shift 2 || true
while [ $# -gt 0 ]; do
  case "$1" in
    --type) shift; DESKTOP_TYPE="${1:-novnc}"; shift ;;
    --type=novnc) DESKTOP_TYPE="novnc"; shift ;;
    --type=guacamole) DESKTOP_TYPE="guacamole"; shift ;;
    --edition) shift; EDITION="${1:-tiny}"; shift ;;
    --edition=tiny) EDITION="tiny"; shift ;;
    --edition=pro) EDITION="pro"; shift ;;
    *) shift ;;
  esac
done

if [ -z "$USERNAME" ] || [ -z "$USER_ID" ]; then
  echo "Usage: $0 <username> <user-id> [--type novnc|guacamole] [--edition tiny|pro]"
  echo ""
  echo "Examples:"
  echo "  $0 john john-123                          # noVNC lightweight desktop"
  echo "  $0 john john-123 --type guacamole          # Guacamole desktop"
  echo "  $0 john john-123 --type guacamole --edition pro  # Guacamole XFCE4"
  exit 1
fi

NAMESPACE="desktop-${USERNAME}"
RELEASE="desktop-${USERNAME}"

echo "Deploying desktop for user: $USERNAME (ID: $USER_ID)"
echo "  Type: $DESKTOP_TYPE"
echo "  Edition: $EDITION"
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
  --set "desktop.desktopEnv=${EDITION}" \
  --set "desktop.tunnel.enabled=true" \
  --set "namespace.create=false" \
  --wait

echo ""
echo "Desktop deployed. Waiting for tunnel URL..."
echo ""

# Wait for pod to be ready
kubectl wait --for=condition=ready pod -l "desktop.workstation.io/name=${USERNAME}" -n "$NAMESPACE" --timeout=120s 2>/dev/null || true

# Wait for tunnel URL
POD=$(kubectl get pod -l "desktop.workstation.io/name=${USERNAME}" -n "$NAMESPACE" -o jsonpath='{.items[0].metadata.name}' 2>/dev/null)

if [ -n "$POD" ]; then
  echo "Pod: $POD"
  echo ""
  
  # Wait for cloudflared to write URL
  for i in $(seq 1 30); do
    TUNNEL_URL=$(kubectl exec -n "$NAMESPACE" "$POD" -c cloudflared -- cat /tmp/tunnel/URL 2>/dev/null || true)
    if [ -n "$TUNNEL_URL" ]; then
      echo "============================================"
      echo "  TUNNEL URL: $TUNNEL_URL"
      echo "  Desktop: $USERNAME ($DESKTOP_TYPE)"
      echo "  User: $USER_ID"
      echo "============================================"
      echo ""
      echo "  Login:"
      echo "    Username: guacadmin"
      echo "    Password: bux2026"
      echo ""
      exit 0
    fi
    sleep 2
  done
  
  echo "Warning: Tunnel URL not yet available. Check logs:"
  echo "  kubectl logs -n $NAMESPACE $POD -c cloudflared"
else
  echo "Error: Pod not found"
  exit 1
fi
