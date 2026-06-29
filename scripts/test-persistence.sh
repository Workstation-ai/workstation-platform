#!/bin/bash
# Test persistence by creating files and verifying they survive pod restarts
# Usage: ./test-persistence.sh <username>

set -e

USERNAME=$1
NAMESPACE="agent-${USERNAME}"

if [ -z "$USERNAME" ]; then
  echo "Usage: $0 <username>"
  exit 1
fi

echo "Testing persistence for user: $USERNAME"

# Get agent pod
POD=$(kubectl get pods -n "$NAMESPACE" -l "app.kubernetes.io/name=workstation-agent" -o jsonpath='{.items[0].metadata.name}' 2>/dev/null || echo "")

if [ -z "$POD" ]; then
  echo "Error: Agent pod not found"
  exit 1
fi

echo "Agent pod: $POD"

# Create test file
TEST_FILE="/home/agent/persistence/test-$(date +%s).txt"
TEST_CONTENT="Persistence test at $(date)"
echo "Creating test file: $TEST_FILE"
kubectl exec -n "$NAMESPACE" "$POD" -- sh -c "echo '$TEST_CONTENT' > '$TEST_FILE'"

# Get pod UID for comparison
POD_UID=$(kubectl get pod -n "$NAMESPACE" "$POD" -o jsonpath='{.metadata.uid}')
echo "Current pod UID: $POD_UID"

# Delete pod to trigger recreation
echo "Deleting pod to test persistence..."
kubectl delete pod -n "$NAMESPACE" "$POD" --wait=false

# Wait for new pod
echo "Waiting for new pod..."
kubectl wait --for=condition=ready pod -l "app.kubernetes.io/name=workstation-agent" -n "$NAMESPACE" --timeout=120s

# Get new pod
NEW_POD=$(kubectl get pods -n "$NAMESPACE" -l "app.kubernetes.io/name=workstation-agent" -o jsonpath='{.items[0].metadata.name}')
NEW_POD_UID=$(kubectl get pod -n "$NAMESPACE" "$NEW_POD" -o jsonpath='{.metadata.uid}')
echo "New pod UID: $NEW_POD_UID"

if [ "$POD_UID" = "$NEW_POD_UID" ]; then
  echo "Warning: Pod was not recreated"
fi

# Verify file exists
echo "Verifying test file..."
kubectl exec -n "$NAMESPACE" "$NEW_POD" -- cat "$TEST_FILE"

# Cleanup
echo "Cleaning up test file..."
kubectl exec -n "$NAMESPACE" "$NEW_POD" -- rm "$TEST_FILE"

echo ""
echo "Persistence test complete!"
