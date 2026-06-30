# Workstation Platform — Cluster Deployment Roadmap

## Phase 1: VPS Upgrade (NOW)
- [ ] Expand EBS volume from 19GB → 30GB (AWS Console)
- [ ] OR upgrade instance type: t3.medium → t3.large (4GB RAM)
- [ ] Verify disk space: `df -h /` should show >20GB

## Phase 2: k3s Cluster Bootstrap
- [x] Install k3s v1.36.2+k3s1
- [x] Configure kubelet eviction thresholds (disk pressure)
- [ ] Add worker node(s) for multi-node cluster
- [ ] Configure k3s agent on worker nodes

## Phase 3: Storage Layer (Longhorn)
- [ ] Install iSCSI initiator on all nodes:
  ```bash
  apt-get install -y open-iscsi nfs-common
  systemctl enable --now iscsid
  ```
- [ ] Deploy Longhorn: `./deployments/longhorn/deploy.sh`
- [ ] Verify StorageClass: `kubectl get storageclass`
- [ ] Set Longhorn as default: `kubectl patch storageclass longhorn -p '{"metadata":{"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'`

## Phase 4: Monitoring & Diagnostics (Popeye)
- [ ] Deploy Popeye: `./deployments/popeye/deploy.sh`
- [ ] Run initial scan: `kubectl exec -n popeye deploy/popeye -- popeye -o stdout`
- [ ] Schedule as CronJob for daily scans

## Phase 5: Desktop Infrastructure
- [ ] Build and import browser images:
  ```bash
  docker build --build-arg BROWSER=chromium -t workstation/desktop:alpine-chromium .
  docker save workstation/desktop:alpine-chromium | sudo k3s ctr images import -
  ```
- [ ] Deploy KEDA for autoscaling: `helm install keda kedacore/keda --namespace keda --create-namespace`
- [ ] Deploy desktop: `helm install desktop ./charts/desktop --set desktop.browser=chromium`

## Phase 6: Multi-User
- [ ] Create per-user namespaces
- [ ] Configure Longhorn PVC per user
- [ ] Set up KEDA ScaledObject per user
- [ ] Configure auto-shutdown (inactivity monitor)
- [ ] Test scale-to-zero and restore

## Phase 7: Production Hardening
- [ ] Network policies (egress rules for cloudflared)
- [ ] RBAC per user
- [ ] Monitoring (Prometheus + Grafana)
- [ ] Logging (Loki or EFK stack)
- [ ] Backup strategy (Longhorn snapshots + offsite)

## Architecture

```
┌─────────────────────────────────────────────────┐
│                 Cloudflare Tunnel                │
│            (HTTPS entry, auto-renew)            │
└────────────────────┬────────────────────────────┘
                     │
┌────────────────────▼────────────────────────────┐
│              k3s Control Plane                   │
│  ┌──────────┐ ┌──────────┐ ┌──────────────────┐ │
│  │   KEDA   │ │  Popeye  │ │   Longhorn CSI   │ │
│  │ (scale)  │ │ (health) │ │  (storage pool)  │ │
│  └──────────┘ └──────────┘ └──────────────────┘ │
└────────────────────┬────────────────────────────┘
                     │
┌────────────────────▼────────────────────────────┐
│           Per-User Desktop Namespace            │
│  ┌─────────────────────────────────────────────┐│
│  │  Desktop Pod (chromium/firefox + noVNC)     ││
│  │  - Xvfb + fluxbox + x11vnc + websockify    ││
│  │  - nginx (HTTPS redirect)                  ││
│  │  - cloudflared sidecar (tunnel)            ││
│  │  - inactivity monitor (auto-shutdown)      ││
│  └─────────────────────────────────────────────┘│
│  ┌─────────────────────────────────────────────┐│
│  │  Longhorn PVC (/home/desktop)              ││
│  │  - Persistent across pod restarts          ││
│  │  - Replicated across nodes                 ││
│  └─────────────────────────────────────────────┘│
└─────────────────────────────────────────────────┘
```

## Resource Requirements

| Component | CPU | RAM | Disk |
|-----------|-----|-----|------|
| k3s server | 0.5 | 512MB | 1GB |
| k3s agent | 0.25 | 256MB | 500MB |
| Longhorn per node | 0.5 | 512MB | 20GB+ |
| Desktop per user | 1-4 | 1-4GB | 5-10GB |
| KEDA | 0.25 | 256MB | 100MB |
| **Total (4 users)** | **4-10** | **4-10GB** | **30-50GB** |

## Recommended Instance

- **Minimum**: t3.large (2 vCPU, 8GB RAM, 30GB EBS)
- **Recommended**: t3.xlarge (4 vCPU, 16GB RAM, 50GB EBS)
- **Production**: t3.2xlarge (8 vCPU, 32GB RAM, 100GB EBS)
