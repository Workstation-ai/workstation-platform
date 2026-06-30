#!/bin/bash
# Deploy a pod with Cloudflare tunnel sidecar
# Usage: bash deploy-tunnel.sh <namespace> <pod-name> <image>
set -euo pipefail

NAMESPACE="${1:-default}"
POD_NAME="${2:-desktop}"
IMAGE="${3:-workstation/desktop:alpine-chromium}"

cat <<EOF | kubectl apply -n "$NAMESPACE" -f -
apiVersion: v1
kind: Pod
metadata:
  name: $POD_NAME
  labels:
    app: $POD_NAME
spec:
  containers:
  - name: desktop
    image: $IMAGE
    ports:
    - containerPort: 6080
      name: https
    - containerPort: 5900
      name: vnc
    env:
    - name: IDLE_TIMEOUT_MIN
      value: "60"
    resources:
      requests:
        cpu: "500m"
        memory: "512Mi"
      limits:
        cpu: "2"
        memory: "2Gi"
  - name: cloudflared
    image: cloudflare/cloudflared:latest
    imagePullPolicy: Always
    command:
      - "cloudflared"
      - "tunnel"
      - "--no-autoupdate"
      - "--url"
      - "http://localhost:6080"
    resources:
      requests:
        cpu: "50m"
        memory: "32Mi"
      limits:
        cpu: "200m"
        memory: "128Mi"
  restartPolicy: Never
EOF

echo "Pod $POD_NAME created in namespace $NAMESPACE"
echo ""
echo "Get tunnel URL:"
echo "  kubectl logs $POD_NAME -n $NAMESPACE -c cloudflared | grep trycloudflare"
