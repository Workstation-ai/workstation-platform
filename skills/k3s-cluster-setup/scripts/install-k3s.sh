#!/bin/bash
# k3s installation script with prechecks
# Usage: bash install-k3s.sh [flags]
# Default: server mode, traefik disabled, vxlan flannel

set -euo pipefail

K3S_FLAGS="${1:-}"
DEFAULT_FLAGS="server --disable traefik --flannel-backend=vxlan --disable-network-policy --write-kubeconfig-mode 644"
FLAGS="${K3S_FLAGS:-$DEFAULT_FLAGS}"

echo "=== k3s Installation ==="
echo "Flags: $FLAGS"

# Prechecks
echo ""
echo "--- Prechecks ---"

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    echo "ERROR: Must run as root (use sudo)"
    exit 1
fi

# Check OS
if ! grep -qiE 'ubuntu|debian|fedora|centos|rhel' /etc/os-release 2>/dev/null; then
    echo "WARNING: Untested OS. Proceed with caution."
fi

# Check available memory
FREE_MEM=$(free -m | awk '/^Mem:/{print $7}')
if [ "$FREE_MEM" -lt 512 ]; then
    echo "WARNING: Only ${FREE_MEM}MB free RAM. k3s needs at least 512MB."
fi

# Check disk space
FREE_DISK=$(df -m / | awk 'NR==2{print $4}')
if [ "$FREE_DISK" -lt 1000 ]; then
    echo "WARNING: Only ${FREE_DISK}MB free disk. k3s needs at least 1GB."
fi

# Check internet
if ! curl -sf https://get.k3s.io >/dev/null 2>&1; then
    echo "ERROR: Cannot reach https://get.k3s.io — check internet"
    exit 1
fi

echo "Prechecks passed."

# Install kmod if needed (for iptables)
if ! command -v modprobe &>/dev/null; then
    echo ""
    echo "--- Installing kmod ---"
    apt-get update -qq && apt-get install -y -qq kmod
fi

# Switch to iptables-legacy if nf_tables is default
if command -v update-alternatives &>/dev/null; then
    if update-alternatives --query iptables 2>/dev/null | grep -q "nf_tables"; then
        echo ""
        echo "--- Switching to iptables-legacy ---"
        update-alternatives --set iptables /usr/sbin/iptables-legacy 2>/dev/null || true
        update-alternatives --set ip6tables /usr/sbin/ip6tables-legacy 2>/dev/null || true
    fi
fi

# Install k3s
echo ""
echo "--- Installing k3s ---"
curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="$FLAGS" sh -

# Wait for node to be ready
echo ""
echo "--- Waiting for node ---"
export KUBECONFIG=/etc/rancher/k3s/k3s.yaml

for i in $(seq 1 60); do
    if kubectl get nodes 2>/dev/null | grep -q " Ready"; then
        echo "Node is Ready!"
        break
    fi
    sleep 2
    echo "Waiting... ($i/60)"
done

# Show status
echo ""
echo "=== Installation Complete ==="
kubectl get nodes
kubectl get pods -A
echo ""
echo "KUBECONFIG: /etc/rancher/k3s/k3s.yaml"
echo "To use: export KUBECONFIG=/etc/rancher/k3s/k3s.yaml"
