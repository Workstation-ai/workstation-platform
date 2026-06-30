#!/bin/bash
# Popeye Cluster Diagnostics — Deploy
# Scans live cluster and reports misconfigurations, wasted resources, and health issues
set -euo pipefail

KUBECONFIG="${KUBECONFIG:-/etc/rancher/k3s/k3s.yaml}"
export KUBECONFIG

echo "[popeye] Deploying Popeye cluster scanner..."

helm repo add popeye https://holmquist.github.io/helm-charts 2>/dev/null
helm repo update

helm install popeye popeye/popeye \
  --namespace popeye \
  --create-namespace \
  --set rbac.create=true \
  --set serviceAccount.create=true \
  --wait --timeout 3m

echo "[popeye] Popeye deployed!"
echo "[popeye] Run scan: kubectl exec -n popeye deploy/popeye -- popeye -o stdout"
echo "[popeye] Or: kubectl exec -n popeye deploy/popeye -- popeye -o yaml"
