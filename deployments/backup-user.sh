#!/bin/bash
# Backup user data (agent persistence + desktop if exists)
# Usage: ./backup-user.sh <username> <backup-path>

set -e

USERNAME=$1
BACKUP_PATH=${2:-"./backups/${USERNAME}"}

if [ -z "$USERNAME" ]; then
  echo "Usage: $0 <username> [backup-path]"
  echo "Example: $0 john ./backups/john"
  exit 1
fi

echo "Backing up user: $USERNAME"
mkdir -p "$BACKUP_PATH"

# Backup agent persistence
echo "Backing up agent data..."
AGENT_NAMESPACE="agent-${USERNAME}"
AGENT_PVC=$(kubectl get pvc -n "$AGENT_NAMESPACE" -o jsonpath='{.items[0].metadata.name}' 2>/dev/null || echo "")

if [ -n "$AGENT_PVC" ]; then
  kubectl get pvc "$AGENT_PVC" -n "$AGENT_NAMESPACE" -o yaml > "$BACKUP_PATH/agent-pvc.yaml"
  echo "Agent PVC backed up"
fi

# Backup desktop persistence if exists
DESKTOP_NAMESPACE="desktop-${USERNAME}"
DESKTOP_PVC=$(kubectl get pvc -n "$DESKTOP_NAMESPACE" -o jsonpath='{.items[0].metadata.name}' 2>/dev/null || echo "")

if [ -n "$DESKTOP_PVC" ]; then
  kubectl get pvc "$DESKTOP_PVC" -n "$DESKTOP_NAMESPACE" -o yaml > "$BACKUP_PATH/desktop-pvc.yaml"
  echo "Desktop PVC backed up"
fi

echo "Backup complete: $BACKUP_PATH"
