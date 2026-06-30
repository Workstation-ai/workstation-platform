#!/bin/bash
# Longhorn Distributed Storage — Deploy
# Prerequisites: k3s cluster with at least 2 nodes (or single-node with local storage)
set -euo pipefail

KUBECONFIG="${KUBECONFIG:-/etc/rancher/k3s/k3s.yaml}"
export KUBECONFIG

echo "[longhorn] Deploying Longhorn distributed storage..."

# Install Longhorn via Helm
helm repo add longhorn https://charts.longhorn.io 2>/dev/null
helm repo update

helm install longhorn longhorn/longhorn \
  --namespace longhorn-system \
  --create-namespace \
  --set defaultSettings.defaultReplicaCount=1 \
  --set defaultSettings.defaultDataLocality=best-effort \
  --set defaultSettings.createDefaultDiskLabeledNodes=true \
  --set persistence.defaultClassReplicaCount=1 \
  --wait --timeout 5m

echo "[longhorn] Waiting for Longhorn manager..."
kubectl wait --for=condition=ready pod -l app=longhorn-manager -n longhorn-system --timeout=120s

echo "[longhorn] Longhorn deployed successfully!"
echo "[longhorn] Dashboard: kubectl port-forward svc/longhorn-frontend 8080:80 -n longhorn-system"
echo "[longhorn] Default StorageClass: longhorn"
