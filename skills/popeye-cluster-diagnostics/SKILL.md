---
name: popeye-cluster-diagnostics
description: Install and run Popeye for Kubernetes cluster diagnostics. Use when scanning a cluster for misconfigurations, wasted resources, potential health issues, or orphaned resources.
compatibility: Requires kubectl, Helm 3, running Kubernetes cluster
metadata:
  author: workstation-ai
  version: "1.0"
---

# Popeye Cluster Diagnostics

Popeye is a live Kubernetes cluster sanitizer that checks for misconfigurations, wasted resources, and potential health issues.

## What Popeye Checks

- Orphaned resources (Services without endpoints, PVCs not bound)
- Unused ConfigMaps and Secrets
- Container resource requests/limits hygiene
- Pod restart counts and crash loops
- Service selector mismatches
- Deprecated API usage
- Security contexts
- Liveness/readiness probe configuration

## Installation

### Via Helm (recommended)

```bash
helm repo add popeye https://charts.popeye.io
helm repo update

helm install popeye popeye/popeye \
  --namespace popeye \
  --create-namespace \
  --set serviceAccount.create=true \
  --set serviceAccount.name=popeye
```

### Verify installation

```bash
kubectl get pods -n popeye
# NAME                      READY   STATUS    RESTARTS   AGE
# popeye-popeye-0           1/1     Running   0          30s
```

## Usage

### Run scan (interactive)

```bash
kubectl exec -it popeye-popeye-0 -n popeye -- popeye -o stdout
```

### Run scan (save to file)

```bash
kubectl exec -it popeye-popeye-0 -n popeye -- popeye -o stdout -r 2>&1 | tee popeye-report.txt
```

### Scan specific namespace

```bash
kubectl exec -it popeye-popeye-0 -n popeye -- popeye -o stdout -n default
```

### Spin (live refresh)

```bash
kubectl exec -it popeye-popeye-0 -n popeye -- popeye -o stdout --spin
```

## Output Severity Levels

- 🔴 **ERROR** — Must fix (misconfiguration, broken resource)
- 🟡 **WARN** — Should fix (wasted resources, hygiene)
- 🔵 **INFO** — Consider fixing (best practices)
- ⚪ **OK** — No issues found

## Uninstall

```bash
helm uninstall popeye -n popeye
kubectl delete namespace popeye
```

## Scripts

See [scripts/deploy.sh](scripts/deploy.sh) and [scripts/uninstall.sh](scripts/uninstall.sh).
