#!/bin/bash
# Uninstall Popeye
set -euo pipefail

echo "=== Uninstalling Popeye ==="
helm uninstall popeye -n popeye 2>/dev/null || echo "Popeye not installed"
kubectl delete namespace popeye 2>/dev/null || echo "Namespace not found"
echo "Popeye removed."
