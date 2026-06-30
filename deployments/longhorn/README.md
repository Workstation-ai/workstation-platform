# Longhorn Distributed Storage
#
# Provides replicated block storage for Kubernetes.
# Each node contributes disk space to the storage pool.
# PVCs are replicated across nodes for high availability.
#
# Prerequisites:
#   - k3s with at least 2 worker nodes (for replication)
#   - Single-node: works with replicaCount=1 (no HA)
#   - Each node needs: iscsi-initiator-utils, open-iscsi, nfs-utils
#
# Install:
#   ./deployments/longhorn/deploy.sh
#
# Uninstall:
#   ./deployments/longhorn/uninstall.sh
#
# Usage in Helm:
#   helm install desktop ./charts/desktop \
#     --set desktop.persistence.storageClass=longhorn \
#     --set desktop.persistence.enabled=true
#
# Dashboard:
#   kubectl port-forward svc/longhorn-frontend 8080:80 -n longhorn-system
#
# Default StorageClass:
#   kubectl get storageclass -> longhorn (default)
