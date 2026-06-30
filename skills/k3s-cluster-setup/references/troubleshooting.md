# k3s Troubleshooting

## Common Issues

### Node stuck in NotReady

```bash
kubectl get nodes
# NAME    STATUS     ROLES           AGE   VERSION
# node1   NotReady   control-plane   5m    v1.36.2+k3s1

# Check kubelet
journalctl -u k3s -n 50 --no-pager
```

**Causes:**
- Missing kernel modules (install `kmod`)
- iptables nf_tables incompatibility (switch to iptables-legacy)
- Network plugin not ready (check flannel/Cilium pods)

### kube-router crash loop

```
FATAL: Failed to verify rule exists in KUBE-ROUTER-INPUT chain
iptables: Extension multiport revision 0 not supported
```

**Fix:** Disable network policy and use vxlan:
```bash
/usr/local/bin/k3s-uninstall.sh
apt-get install -y kmod
update-alternatives --set iptables /usr/sbin/iptables-legacy
curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="server \
  --disable traefik \
  --flannel-backend=vxlan \
  --disable-network-policy \
  --write-kubeconfig-mode 644" sh -
```

### Pods can't resolve DNS

```bash
# Test DNS from a pod
kubectl run dnstest --image=busybox:1.36 --rm -it --restart=Never -- nslookup kubernetes.default

# If timeout, check CoreDNS
kubectl get pods -n kube-system -l k8s-app=kube-dns
kubectl logs -n kube-system -l k8s-app=kube-dns
```

### Pod has no internet access

```bash
# Test from pod
kubectl run nettest --image=busybox:1.36 --rm -it --restart=Never -- wget -qO- --timeout=5 http://1.1.1.1

# Check NAT rules
iptables -t nat -L FLANNEL-POSTRTG -n -v
iptables -t nat -L POSTROUTING -n -v | head -10

# Check forwarding
iptables -L FORWARD -n -v | head -10
sysctl net.ipv4.ip_forward
```

### Image pull errors in pods

k3s uses containerd, not Docker. Images must be imported:

```bash
# Import
docker save myimage:tag | sudo k3s ctr images import -

# Or pull directly with crictl
sudo k3s ctr images pull docker.io/library/alpine:3.20
```

### k3s service keeps restarting

```bash
journalctl -u k3s -n 30 --no-pager | grep -i "fatal\|panic\|error"
```

Common causes:
- Corrupted database: Delete `/var/lib/rancher/k3s/server/db/` and restart
- Port 6443 already in use: `ss -tlnp | grep 6443`
- Insufficient disk space: `df -h /var/lib/rancher/k3s/`

## Useful Commands

```bash
# Check all system resources
kubectl top nodes
kubectl top pods -A

# Check events
kubectl get events -A --sort-by='.lastTimestamp' | tail -20

# Check component status
kubectl get componentstatuses

# Reset k3s completely
/usr/local/bin/k3s-uninstall.sh
```
