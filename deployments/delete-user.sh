#!/bin/bash
# Delete a user and all their resources
# Usage: ./delete-user.sh <username> [--with-desktop]

set -e

USERNAME=$1
WITH_DESKTOP=${2:-""}

if [ -z "$USERNAME" ]; then
  echo "Usage: $0 <username> [--with-desktop]"
  echo "Example: $0 john --with-desktop"
  exit 1
fi

echo "Deleting user: $USERNAME"

# Delete agent
echo "Deleting agent..."
helm uninstall "agent-${USERNAME}" --namespace "agent-${USERNAME}" 2>/dev/null || true
kubectl delete namespace "agent-${USERNAME}" 2>/dev/null || true

# Delete desktop if requested
if [ "$WITH_DESKTOP" = "--with-desktop" ]; then
  echo "Deleting desktop..."
  helm uninstall "desktop-${USERNAME}" --namespace "desktop-${USERNAME}" 2>/dev/null || true
  kubectl delete namespace "desktop-${USERNAME}" 2>/dev/null || true
fi

echo "User deleted successfully"
