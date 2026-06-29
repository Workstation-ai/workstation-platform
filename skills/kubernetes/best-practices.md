# Kubernetes Best Practices

## Namespace Isolation

```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: tenant-{id}
  labels:
    tenant: {id}
    managed-by: platform
```

## Resource Quotas

```yaml
apiVersion: v1
kind: ResourceQuota
metadata:
  name: tenant-quota
  namespace: tenant-{id}
spec:
  hard:
    requests.cpu: "2"
    requests.memory: 4Gi
    limits.cpu: "4"
    limits.memory: 8Gi
    persistentvolumeclaims: "5"
    pods: "20"
```

## Network Policies

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: deny-cross-tenant
  namespace: tenant-{id}
spec:
  podSelector: {}
  policyTypes:
    - Ingress
    - Egress
  ingress:
    - from:
        - podSelector: {}
        - namespaceSelector:
            matchLabels:
              tenant: {id}
  egress:
    - to:
        - podSelector: {}
```

## RBAC

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: tenant-admin
  namespace: tenant-{id}
rules:
  - apiGroups: ["", "apps", "networking.k8s.io"]
    resources: ["*"]
    verbs: ["*"]
```
