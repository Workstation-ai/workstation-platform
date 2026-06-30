#!/bin/bash
# Uninstall Longhorn
set -euo pipefail

echo "=== Uninstalling Longhorn ==="

# Remove default annotation first
kubectl patch storageclass longhorn -p \
  '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"false"}}}' 2>/dev/null || true

helm uninstall longhorn -n longhorn-system 2>/dev/null || echo "Longhorn not installed"
kubectl delete namespace longhorn-system 2>/dev/null || echo "Namespace not found"
echo "Longhorn removed. PVs may remain — check with: kubectl get pv"
