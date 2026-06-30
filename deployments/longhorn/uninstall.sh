#!/bin/bash
# Longhorn Distributed Storage — Uninstall
set -euo pipefail

KUBECONFIG="${KUBECONFIG:-/etc/rancher/k3s/k3s.yaml}"
export KUBECONFIG

echo "[longhorn] Removing Longhorn..."

# Delete all PVCs first
kubectl delete pvc --all -n longhorn-system 2>/dev/null || true

helm uninstall longhorn -n longhorn-system 2>/dev/null || true
kubectl delete namespace longhorn-system 2>/dev/null || true

echo "[longhorn] Longhorn removed."
