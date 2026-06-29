#!/bin/bash
# Test KEDA scaling by generating load
# Usage: ./test-keda-scaling.sh [namespace] [duration]

set -e

NAMESPACE=${1:-"workstation"}
DURATION=${2:-60}

echo "Testing KEDA scaling in namespace: $NAMESPACE"
echo "Duration: $DURATION seconds"

# Check if KEDA is installed
if ! kubectl get crd scaledobjects.keda.sh &> /dev/null; then
  echo "Error: KEDA is not installed"
  exit 1
fi

# Get MCP server deployment
DEPLOYMENT="workstation-mcp-server"
echo "Current replicas: $(kubectl get deployment "$DEPLOYMENT" -n "$NAMESPACE" -o jsonpath='{.spec.replicas}')"

# Generate load
echo "Generating load for $DURATION seconds..."
END_TIME=$(($(date +%s) + DURATION))

while [ $(date +%s) -lt $END_TIME ]; do
  # Simulate API requests
  kubectl exec -n "$NAMESPACE" deployment/workstation-mcp-server -- \
    curl -s http://localhost:8080/health > /dev/null 2>&1 || true
  
  sleep 0.1
done

# Check scaling
echo ""
echo "After load test:"
echo "  Current replicas: $(kubectl get deployment "$DEPLOYMENT" -n "$NAMESPACE" -o jsonpath='{.spec.replicas}')"
echo "  HPA status:"
kubectl get hpa -n "$NAMESPACE" 2>/dev/null || echo "  No HPA found"
echo ""
echo "  KEDA ScaledObjects:"
kubectl get scaledobjects -n "$NAMESPACE" 2>/dev/null || echo "  No ScaledObjects found"

echo ""
echo "Scaling test complete!"
