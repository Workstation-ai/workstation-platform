#!/bin/bash
# Deploy Longhorn distributed storage
set -euo pipefail

echo "=== Deploying Longhorn ==="

# Install iSCSI if not present
if ! systemctl is-active iscsid >/dev/null 2>&1; then
    echo "Installing iSCSI initiator..."
    apt-get install -y open-iscsi
    systemctl enable --now iscsid
fi

helm repo add longhorn https://charts.longhorn.io 2>/dev/null || true
helm repo update

helm install longhorn longhorn/longhorn \
  --namespace longhorn-system \
  --create-namespace \
  --set defaultSettings.defaultReplicaCount=1 \
  --set defaultSettings.defaultDataLocality="best-effort" \
  --wait --timeout 300s

# Set as default StorageClass
kubectl patch storageclass longhorn -p \
  '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}' 2>/dev/null || true

echo ""
echo "Longhorn deployed. Dashboard: kubectl port-forward -n longhorn-system svc/longhorn-frontend 8080:80"
