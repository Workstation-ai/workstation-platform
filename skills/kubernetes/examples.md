# Kubernetes Examples

## Create Tenant Namespace with Quotas

```bash
# Create namespace
kubectl create namespace tenant-john

# Apply resource quota
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: ResourceQuota
metadata:
  name: tenant-quota
  namespace: tenant-john
spec:
  hard:
    requests.cpu: "2"
    requests.memory: 4Gi
    limits.cpu: "4"
    limits.memory: 8Gi
EOF
```

## Deploy to Tenant Namespace

```bash
# Deploy with namespace
helm install agent-john ./charts/agent \
  --namespace tenant-john \
  --create-namespace

# Or with kubectl
kubectl apply -f deployment.yaml -n tenant-john
```

## Check Tenant Resources

```bash
# List pods in tenant namespace
kubectl get pods -n tenant-john

# Check resource usage
kubectl top pods -n tenant-john

# View quotas
kubectl describe resourcequota -n tenant-john
```
