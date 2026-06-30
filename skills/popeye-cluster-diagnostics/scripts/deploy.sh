#!/bin/bash
# Deploy Popeye for cluster diagnostics
set -euo pipefail

echo "=== Deploying Popeye ==="

helm repo add popeye https://charts.popeye.io 2>/dev/null || true
helm repo update

helm install popeye popeye/popeye \
  --namespace popeye \
  --create-namespace \
  --set serviceAccount.create=true \
  --set serviceAccount.name=popeye \
  --wait --timeout 120s

echo ""
echo "Popeye deployed. Run a scan with:"
echo "  kubectl exec -it popeye-popeye-0 -n popeye -- popeye -o stdout"
