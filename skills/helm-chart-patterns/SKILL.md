---
name: helm-chart-patterns
description: "Trigger: helm chart, chart values, resource profile, deploy helm. Helm chart patterns and resource profiles for Workstation Platform."
license: Apache-2.0
metadata:
  author: "Workstation AI"
  version: "1.0"
---

# Helm Chart Patterns

Helm chart conventions for the Workstation Platform.

## Activation Contract

Use this skill when:
- Modifying Helm chart templates
- Adding new chart values
- Deploying via Helm
- Debugging Helm releases

## Hard Rules

- Use `namespace.create: false` — let `--create-namespace` handle it to avoid ownership conflicts
- Use `.Release.Namespace` in templates, not hardcoded namespace values
- Resource profiles override explicit resource values when set
- All labels must include `desktop.workstation.io/name` and `desktop.workstation.io/user`

## Resource Profiles

Defined in `_helpers.tpl` as `desktop.resources`:

| Profile | CPU req/limit | RAM req/limit | Use case |
|---------|--------------|---------------|----------|
| small | 250m / 1 | 256Mi / 1Gi | Dev/test, constrained clusters |
| medium | 500m / 2 | 512Mi / 2Gi | Production single-tenant |
| large | 1 / 4 | 1Gi / 4Gi | Power users, multi-tab |

Usage: `--set desktop.profile=large`

## Values Structure

```yaml
desktop:
  name: ""
  userId: ""
  profile: "small"  # small | medium | large
  type: "novnc"
  image:
    repository: workstation/desktop
    tag: "alpine-https"
    pullPolicy: IfNotPresent
  tunnel:
    enabled: true
    type: "quick"
  persistence:
    enabled: false
    storageClass: "standard"
    size: "5Gi"
```

## Template Helpers

- `desktop.fullname` — release + name, truncated to 63 chars
- `desktop.namespace` — uses `.Values.namespace.name` or `.Release.Namespace`
- `desktop.labels` — common labels for all resources
- `desktop.selectorLabels` — pod selector labels
- `desktop.resources` — profile-aware resource resolution

## Deploy Commands

```bash
# Quick (kubectl)
./deployments/quick-deploy.sh <namespace> <image-tag>

# Helm
helm install desktop-<user> ./charts/desktop \
  --namespace desktop-<user> \
  --create-namespace \
  --set desktop.name=<user> \
  --set desktop.userId=<id> \
  --set desktop.profile=medium

# Upgrade
helm upgrade desktop-<user> ./charts/desktop \
  --namespace desktop-<user> \
  --set desktop.profile=large
```

## Debugging

```bash
# Check release
helm list -n <namespace>
helm status desktop-<user> -n <namespace>

# Check pod
kubectl get pods -n <namespace>
kubectl describe pod <pod> -n <namespace>
kubectl logs <pod> -c desktop -n <namespace>
kubectl logs <pod> -c cloudflared -n <namespace>

# Template debug
helm template desktop-<user> ./charts/desktop \
  --namespace desktop-<user> \
  --set desktop.name=<user> \
  --debug
```

## References

- `charts/desktop/` — the Helm chart
- `charts/desktop/values.yaml` — configurable values
- `charts/desktop/templates/_helpers.tpl` — template helpers
- `charts/desktop/templates/deployment.yaml` — main deployment
