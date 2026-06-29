# Kubernetes Anti-Patterns

## Don't: Use ClusterRoleBinding for Tenants

```yaml
# WRONG - gives cluster-wide access
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: tenant-admin
subjects:
  - kind: ServiceAccount
    name: tenant-sa
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: admin
```

## Do: Use RoleBinding per Namespace

```yaml
# RIGHT - scoped to namespace
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: tenant-admin
  namespace: tenant-{id}
subjects:
  - kind: ServiceAccount
    name: tenant-sa
    namespace: tenant-{id}
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: tenant-admin
```

## Don't: Skip ResourceQuotas

Without quotas, one tenant can consume all cluster resources:

```bash
# One tenant deploys 100 pods, others get OOMKilled
kubectl top nodes  # CPU/Memory at 100%
```

## Don't: Use Default Namespace

```bash
# WRONG
kubectl apply -f deployment.yaml  # Goes to default namespace

# RIGHT
kubectl apply -f deployment.yaml -n tenant-{id}
```

## Don't: Share ServiceAccounts

Each namespace should have its own ServiceAccount with minimal permissions.
