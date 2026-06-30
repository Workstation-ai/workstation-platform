---
name: k3s-cluster-setup
description: Install and configure k3s Kubernetes on a Linux VPS. Use when setting up a single-node k3s cluster, importing Docker images, troubleshooting kube-router or flannel issues, or configuring container networking.
compatibility: Requires Linux with systemd, root/sudo access, internet access
metadata:
  author: workstation-ai
  version: "1.0"
---

# k3s Cluster Setup

k3s is a lightweight Kubernetes distribution ideal for single-node deployments and edge computing.

## Prerequisites

- Linux with systemd (Ubuntu, Debian, Fedora, etc.)
- Root or sudo access
- Internet access for initial install
- At least 1GB RAM, 1 CPU core, 1GB disk free

## Installation

### Standard install (works on most VPS)

```bash
curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="server \
  --disable traefik \
  --write-kubeconfig-mode 644" sh -
```

### Install with host-gw flannel (faster, requires L2 adjacency)

```bash
curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="server \
  --disable traefik \
  --flannel-backend=host-gw \
  --write-kubeconfig-mode 644" sh -
```

### Install with network policy disabled (for kernels missing iptables multiport)

```bash
# First install kmod and switch to iptables-legacy
apt-get install -y kmod iptables
update-alternatives --set iptables /usr/sbin/iptables-legacy
update-alternatives --set ip6tables /usr/sbin/ip6tables-legacy

# Then install k3s
curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="server \
  --disable traefik \
  --flannel-backend=vxlan \
  --disable-network-policy \
  --write-kubeconfig-mode 644" sh -
```

## Configuration flags explained

| Flag | Purpose |
|------|---------|
| `--disable traefik` | Disable built-in Traefik ingress (we use nginx/cloudflared instead) |
| `--flannel-backend=vxlan` | Use VXLAN overlay (works everywhere, slightly slower than host-gw) |
| `--flannel-backend=host-gw` | Use host-gw routing (faster, requires all nodes on same L2 network) |
| `--disable-network-policy` | Disable kube-router network policies (needed when iptables multiport module missing) |
| `--write-kubeconfig-mode 644` | Make kubeconfig readable by non-root users |

## KUBECONFIG

After install, set up kubectl:

```bash
export KUBECONFIG=/etc/rancher/k3s/k3s.yaml
# Or copy to default location:
mkdir -p ~/.kube
cp /etc/rancher/k3s/k3s.yaml ~/.kube/config
chmod 600 ~/.kube/config
```

## Importing Docker Images

k3s uses containerd, not Docker. Import images with:

```bash
# Export from Docker, import to k3s
docker save myimage:tag | gzip | sudo k3s ctr images import -

# Verify import
sudo k3s ctr images list | grep myimage
```

## Verify installation

```bash
kubectl get nodes
kubectl get pods -A
```

All system pods should be Running:
- `coredns` — DNS resolution
- `local-path-provisioner` — Dynamic PV provisioning
- `metrics-server` — Resource metrics

## Helper Scripts

See [scripts/install-k3s.sh](scripts/install-k3s.sh) for automated installation with prechecks.
See [scripts/import-image.sh](scripts/import-image.sh) for Docker-to-k3s image import.

## Troubleshooting

See [references/troubleshooting.md](references/troubleshooting.md) for common issues.
