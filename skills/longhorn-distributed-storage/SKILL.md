---
name: longhorn-distributed-storage
description: Install and configure Longhorn for persistent storage on Kubernetes. Use when setting up distributed block storage, creating PVCs, or managing persistent volumes for stateful applications.
compatibility: Requires kubectl, Helm 3, running Kubernetes cluster, Linux with iscsi-initiator-utils
metadata:
  author: workstation-ai
  version: "1.0"
---

# Longhorn Distributed Storage

Longhorn is a distributed block storage manager for Kubernetes. It provides persistent volumes with replication across nodes.

## Prerequisites

```bash
# Install iSCSI initiator (required by Longhorn)
apt-get install -y open-iscsi
systemctl enable --now iscsid
```

## Installation

### Via Helm (recommended)

```bash
helm repo add longhorn https://charts.longhorn.io
helm repo update

helm install longhorn longhorn/longhorn \
  --namespace longhorn-system \
  --create-namespace \
  --set defaultSettings.defaultReplicaCount=1 \
  --set defaultSettings.defaultDataLocality="best-effort" \
  --wait --timeout 300s
```

For single-node clusters, use `replicaCount=1` to avoidpending PVCs.

### Verify installation

```bash
kubectl get pods -n longhorn-system
kubectl get storageclasses
```

## Default StorageClass

Set Longhorn as the default StorageClass:

```bash
kubectl patch storageclass longhorn -p \
  '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'
```

## Creating a PVC

```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: my-pvc
spec:
  accessModes:
    - ReadWriteOnce
  storageClassName: longhorn
  resources:
    requests:
      storage: 10Gi
```

```bash
kubectl apply -f my-pvc.yaml
kubectl get pvc my-pvc
```

## Dashboard Access

```bash
kubectl port-forward -n longhorn-system svc/longhorn-frontend 8080:80
# Open http://localhost:8080 in browser
```

## Scripts

See [scripts/deploy.sh](scripts/deploy.sh) and [scripts/uninstall.sh](scripts/uninstall.sh).
