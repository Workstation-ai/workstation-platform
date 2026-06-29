# Kubernetes Multi-Tenant Skill

## What problem does it solve?

Deploying multi-tenant applications on Kubernetes requires proper isolation between users/teams. This skill covers namespace isolation, RBAC, network policies, and resource quotas.

## When should it be used?

- Deploying applications that serve multiple users/teams
- Needing isolation between tenants
- Implementing role-based access control
- Setting up network segmentation

## When should NOT it be used?

- Single-tenant applications
- Simple deployments without isolation requirements
- Development/testing environments (unless testing multi-tenant patterns)

## Decision Tree

```
Need multi-tenant isolation?
↓
How many tenants?
↓
< 10 → Shared namespace with ResourceQuotas
10-100 → Separate namespaces per tenant
> 100 → Virtual clusters or separate clusters
↓
Need network isolation?
↓
Yes → NetworkPolicies
No → Shared network
↓
Need RBAC?
↓
Yes → Role/ClusterRole per namespace
No → Default ServiceAccount
```

## Best Practices

1. **Namespace per tenant** - Isolate resources, quotas, and RBAC
2. **ResourceQuotas** - Prevent one tenant from consuming all resources
3. **NetworkPolicies** - Restrict traffic between namespaces
4. **RBAC** - Least-privilege access per tenant
5. **Labels** - Consistent labeling for resource management

## Anti-Patterns

- Don't use cluster-wide permissions for tenant workloads
- Don't share ServiceAccounts between namespaces
- Don't skip ResourceQuotas (one tenant can starve others)
- Don't use default namespace for anything

## References

- [Kubernetes Namespaces](https://kubernetes.io/docs/concepts/overview/working-with-objects/namespaces/)
- [Resource Quotas](https://kubernetes.io/docs/concepts/policy/resource-quotas/)
- [Network Policies](https://kubernetes.io/docs/concepts/services-networking/network-policies/)
- [RBAC Authorization](https://kubernetes.io/docs/reference/access-authn-authz/rbac/)
