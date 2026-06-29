# Kubernetes Decision Tree

## Namespace Strategy

```
Need tenant isolation?
↓
Tenant type?
↓
User → agent-{username} / desktop-{username}
Team → team-{name}
Organization → org-{name}
↓
Resource needs?
↓
Small → 1 namespace per tenant
Medium → namespace with ResourceQuotas
Large → separate cluster or virtual cluster
```

## RBAC Strategy

```
Access level needed?
↓
Read-only → Role with get/list/watch
Read-write → Role with full CRUD
Admin → ClusterRole with namespace binding
Cross-namespace → ClusterRoleBinding (careful)
```

## Network Policy Strategy

```
Traffic flow?
↓
Allow all → No NetworkPolicy (default)
Deny all → Default deny + explicit allows
Partial → Selective ingress/egress rules
```
