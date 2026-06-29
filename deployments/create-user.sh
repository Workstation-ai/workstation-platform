#!/bin/bash
# Create a new user with agent and optional desktop
# Usage: ./create-user.sh <username> <user-id> [--desktop]

set -e

USERNAME=$1
USER_ID=$2
WITH_DESKTOP=${3:-""}

if [ -z "$USERNAME" ] || [ -z "$USER_ID" ]; then
  echo "Usage: $0 <username> <user-id> [--desktop]"
  echo "Example: $0 john john-123 --desktop"
  exit 1
fi

echo "Creating user: $USERNAME (ID: $USER_ID)"

# Create agent namespace and deployment
echo "Deploying AI agent..."
helm install "agent-${USERNAME}" ./charts/agent \
  --namespace "agent-${USERNAME}" \
  --create-namespace \
  --set "agent.name=${USERNAME}" \
  --set "agent.userId=${USER_ID}" \
  --wait

echo "Agent deployed successfully"

# Optionally create desktop
if [ "$WITH_DESKTOP" = "--desktop" ]; then
  echo "Deploying desktop environment..."
  helm install "desktop-${USERNAME}" ./charts/desktop \
    --namespace "desktop-${USERNAME}" \
    --create-namespace \
    --set "desktop.name=${USERNAME}" \
    --set "desktop.userId=${USER_ID}" \
    --wait
  
  echo "Desktop deployed successfully"
  
  # Get desktop URL
  DESKTOP_URL=$(kubectl get ingress -n "desktop-${USERNAME}" -o jsonpath='{.items[0].spec.rules[0].host}')
  echo "Desktop accessible at: http://${DESKTOP_URL}"
fi

echo ""
echo "User setup complete!"
echo "  Agent: agent-${USERNAME}.workstation.svc.cluster.local"
if [ "$WITH_DESKTOP" = "--desktop" ]; then
  echo "  Desktop: http://${DESKTOP_URL}"
fi
