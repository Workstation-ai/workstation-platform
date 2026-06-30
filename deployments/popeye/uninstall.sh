#!/bin/bash
# Popeye Cluster Diagnostics — Uninstall
set -euo pipefail

KUBECONFIG="${KUBECONFIG:-/etc/rancher/k3s/k3s.yaml}"
export KUBECONFIG

echo "[popeye] Removing Popeye..."

helm uninstall popeye -n popeye 2>/dev/null || true
kubectl delete namespace popeye 2>/dev/null || true

echo "[popeye] Popeye removed."
