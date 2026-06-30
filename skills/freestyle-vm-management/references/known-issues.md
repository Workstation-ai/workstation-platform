# Freestyle.sh Known Issues

## Kernel Limitations

Freestyle VMs run kernel `6.1.0-15-freestyle`, a stripped-down build missing critical modules:

- **No `/proc/modules`** — Cannot inspect loaded kernel modules
- **No `multiport` iptables extension** — kube-router panics with: `Extension multiport revision 0 not supported, missing kernel module?`
- **No `modprobe` initially** — Must install `kmod` package first
- **Bridge networking broken** — Pods can ping their gateway (cni0) but traffic never reaches host interface (eth0)

## Kubernetes (k3s) Issues

### What works
- k3s installs successfully
- Node shows `Ready` status
- System pods (CoreDNS, metrics-server, local-path-provisioner) run
- Individual containers start (runc works on most VMs)

### What doesn't work
- **Pod networking is broken** — No DNS, no internet, no external access from pods
- **kube-router crashes** — Must use `--disable-network-policy` flag
- **Flannel host-gw fails** — MASQUERADE rules never trigger; use `--flannel-backend=vxlan` instead
- **Cilium fails** — Cannot read `/proc/modules`
- **Kaniko cannot build** — Needs to pull base images from Docker Hub, which requires pod networking

### Required k3s flags for Freestyle (if you must try)

```bash
# Install kmod first
apt-get install -y kmod iptables
update-alternatives --set iptables /usr/sbin/iptables-legacy

# Install k3s
curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="server \
  --disable traefik \
  --flannel-backend=vxlan \
  --disable-network-policy \
  --write-kubeconfig-mode 644" sh -
```

Even with these flags, pods will have no external network access.

## Container Runtime Variations

- Some VMs: runc works, containers start normally
- Some VMs: runc segfaults immediately (transient issue, not reproducible)
- No pattern identified — appears to be a Freestyle infrastructure inconsistency

## Recommendation

**Do not use Freestyle for:**
- Kubernetes clusters
- Container workloads requiring network access
- Any workload that needs DNS resolution from pods

**Safe to use for:**
- Serverless functions (Freestyle's intended use case)
- Simple VM tasks (file processing, builds without network)
- Testing k3s installation commands (not pod networking)
