#!/bin/bash
# Quick deploy: branded desktop in any namespace
# Usage: ./quick-deploy.sh [namespace] [image-tag]

set -e

NAMESPACE="${1:-desktop-guac}"
IMAGE_TAG="${2:-alpine}"

echo "Deploying Workstation Center OS to namespace: $NAMESPACE"

# Create namespace
kubectl create namespace "$NAMESPACE" 2>/dev/null || true

# Apply deployment
cat <<EOF | kubectl apply -n "$NAMESPACE" -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: desktop
  namespace: $NAMESPACE
spec:
  replicas: 1
  selector:
    matchLabels:
      app: desktop
  template:
    metadata:
      labels:
        app: desktop
      annotations:
        desktop.workstation.io/name: "desktop"
        desktop.workstation.io/type: "novnc"
    spec:
      securityContext:
        runAsUser: 0
        runAsGroup: 0
      containers:
      - name: desktop
        image: workstation/desktop:${IMAGE_TAG}
        imagePullPolicy: IfNotPresent
        ports:
        - containerPort: 6080
          name: novnc
        - containerPort: 5900
          name: vnc
        resources:
          requests:
            cpu: "250m"
            memory: "256Mi"
          limits:
            cpu: "1"
            memory: "1Gi"
        livenessProbe:
          tcpSocket:
            port: novnc
          initialDelaySeconds: 15
          periodSeconds: 10
      - name: cloudflared
        image: cloudflare/cloudflared:latest
        imagePullPolicy: Always
        command:
        - cloudflared
        - tunnel
        - --no-autoupdate
        - --url
        - http://localhost:6080
        resources:
          requests:
            cpu: "50m"
            memory: "32Mi"
          limits:
            cpu: "200m"
            memory: "128Mi"
EOF

echo "Waiting for pod..."
kubectl wait --for=condition=ready pod -l app=desktop -n "$NAMESPACE" --timeout=120s

POD=$(kubectl get pod -l app=desktop -n "$NAMESPACE" -o jsonpath='{.items[0].metadata.name}')
echo ""
echo "Pod: $POD"
echo ""

# Get tunnel URL
for i in $(seq 1 30); do
  URL=$(kubectl logs "$POD" -n "$NAMESPACE" -c cloudflared 2>/dev/null | grep -o 'https://[a-zA-Z0-9-]*\.trycloudflare\.com' | tail -1)
  if [ -n "$URL" ]; then
    echo "============================================"
    echo "  WORKSTATION CENTER OS"
    echo "  TUNNEL: $URL"
    echo "============================================"
    exit 0
  fi
  sleep 2
done

echo "Check logs: kubectl logs $POD -n $NAMESPACE -c cloudflared | grep trycloudflare"
