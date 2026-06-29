# Minikube Deployment Guide

## Prerequisites

- minikube running with docker driver
- kubectl configured
- Helm 3.x installed

## Quick Start

```bash
# 1. Start minikube (if not running)
sudo minikube start --driver=docker --force --cpus=1 --memory=1024

# 2. Create workstation namespace
sudo kubectl create namespace workstation

# 3. Create PostgreSQL credentials
sudo kubectl create secret generic workstation-postgres-credentials \
  --namespace=workstation \
  --from-literal=POSTGRES_USER=workstation \
  --from-literal=POSTGRES_PASSWORD=workstation123 \
  --from-literal=POSTGRES_URL=postgresql://workstation:workstation123@postgres.workstation.svc.cluster.local:5432/workstation

# 4. Install base chart
sudo helm install workstation-base ./charts/base \
  --namespace workstation \
  --set global.namespace=workstation \
  --set mcpServer.enabled=false \
  --set services.postgres.existingSecret=workstation-postgres-credentials

# 5. Deploy infrastructure
sudo kubectl apply -f infrastructure/postgres.yaml -n workstation
sudo kubectl apply -f infrastructure/redis.yaml -n workstation

# 6. Verify installation
sudo kubectl get pods -n workstation
sudo helm list -n workstation
```

## Current Status

### Working Components
- ✅ PostgreSQL StatefulSet (15-alpine)
- ✅ Redis Deployment (7-alpine)
- ✅ Base Helm chart with RBAC
- ✅ Secrets management
- ✅ PVC for PostgreSQL data

### Pending Components
- ⏳ MCP Server (image not built yet)
- ⏳ Agent deployment (image not built yet)
- ⏳ Desktop deployment (Guacamole image not built yet)
- ⏳ KEDA (not installed yet)

## Next Steps

1. **Build MCP Server Image**
   ```bash
   # From the devops_mcp repo
   docker build -t workstation/mcp-server:latest .
   ```

2. **Build Agent Image**
   ```bash
   # Create agent Dockerfile
   # Build and push to registry
   ```

3. **Install KEDA**
   ```bash
   helm repo add kedacore https://kedacore.github.io/charts
   helm install keda kedacore/keda --namespace keda --create-namespace
   ```

4. **Test Agent Deployment**
   ```bash
   helm install agent-test ./charts/agent \
     --namespace agent-test \
     --create-namespace \
     --set agent.name=testuser \
     --set agent.userId=user-001
   ```

## Troubleshooting

### Pod stuck in ImagePullBackOff
- Image doesn't exist yet
- Need to build and push images

### PostgreSQL not starting
- Check secret exists: `kubectl get secret -n workstation`
- Check PVC bound: `kubectl get pvc -n workstation`

### Helm install fails
- Check namespace doesn't exist: `kubectl get ns`
- Or add Helm labels to existing namespace
