# Getting Started with Workstation Platform

## Prerequisites

- Kubernetes cluster (minikube, kind, k3s, or cloud)
- Helm 3.x
- kubectl configured
- Cloud provider credentials (optional)

## Quick Start

### 1. Clone and Setup

```bash
git clone https://github.com/gastonzarate/devops_mcp.git
cd devops_mcp
chmod +x scripts/*.sh deployments/*.sh
```

### 2. Setup Kubernetes

```bash
# For minikube
./scripts/setup-k8s.sh minikube

# For kind
./scripts/setup-k8s.sh kind

# For existing cluster
./scripts/setup-k8s.sh existing
```

### 3. Configure Cloud Credentials

```bash
kubectl edit secret -n workstation workstation-base-cloud-credentials
```

Add your credentials:

```yaml
data:
  AWS_ACCESS_KEY_ID: <base64-encoded>
  AWS_SECRET_ACCESS_KEY: <base64-encoded>
  AZURE_CLIENT_ID: <base64-encoded>
  AZURE_CLIENT_SECRET: <base64-encoded>
  AZURE_TENANT_ID: <base64-encoded>
  HETZNER_TOKEN: <base64-encoded>
```

### 4. Create First User

```bash
# Create user with agent only
./deployments/create-user.sh john john-001

# Create user with agent and desktop
./deployments/create-user.sh jane jane-001 --desktop
```

### 5. Access User Resources

```bash
# Get agent pod
kubectl get pods -n agent-john

# Get desktop URL (if created)
kubectl get ingress -n desktop-jane
```

## Testing

### Test Persistence

```bash
./scripts/test-persistence.sh john
```

### Test KEDA Scaling

```bash
./scripts/test-keda-scaling.sh workstation 60
```

### Test Multicloud

```bash
./scripts/test-multicloud.sh all
```

## Cleanup

### Delete User

```bash
# Delete agent only
./deployments/delete-user.sh john

# Delete agent and desktop
./deployments/delete-user.sh jane --with-desktop
```

### Uninstall Platform

```bash
helm uninstall workstation-base -n workstation
kubectl delete namespace workstation
```

## Troubleshooting

### Pod Stuck in Pending

```bash
kubectl describe pod <pod-name> -n <namespace>
kubectl get events -n <namespace>
```

### PVC Not Binding

```bash
kubectl get pvc -n <namespace>
kubectl describe pvc <pvc-name> -n <namespace>
```

### KEDA Not Scaling

```bash
kubectl get scaledobjects -n workstation
kubectl describe scaledobject <name> -n workstation
kubectl get events -n keda
```
