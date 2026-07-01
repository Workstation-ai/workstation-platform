# Workstation Platform

Multi-tenant Kubernetes platform for AI agents and on-demand desktops with multi-cloud support.

## Setup Commands

```bash
# Install dependencies
# No npm/pip — this is a Helm/K8s project. Tools needed:
# - Docker
# - kubectl
# - helm
# - cloudflared

# Setup local K8s (k3s recommended, minikube also works)
curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="--disable traefik --write-kubeconfig-mode 644" sh -
export KUBECONFIG=/etc/rancher/k3s/k3s.yaml

# Or use minikube
minikube start --driver=docker --cpus=4 --memory=8192

# Import desktop image to k3s
docker save workstation/desktop:alpine-chromium | gzip | sudo k3s ctr images import -
```

## Build Commands

```bash
# Build desktop image (chromium, default)
docker build --build-arg BROWSER=chromium --no-cache -t workstation/desktop:alpine-chromium images/desktop-novnc/

# Build desktop image (firefox, smaller)
docker build --build-arg BROWSER=firefox --no-cache -t workstation/desktop:alpine-firefox images/desktop-novnc/

# Build MCP server image
docker build -t workstation/mcp-server images/mcp-server/

# Helm lint
helm lint charts/desktop/
```

## Test Commands

```bash
# Quick deploy (no Helm, uses kubectl directly)
./deployments/quick-deploy.sh desktop-name alpine-chromium

# Deploy via Helm
helm install desktop ./charts/desktop \
  --set desktop.name=my-desktop \
  --set desktop.userId=user-001 \
  --set desktop.profile=small

# Verify deployment
kubectl get pods -l app=my-desktop
kubectl get svc -l app=my-desktop

# Get tunnel URL
kubectl logs <pod-name> -c cloudflared | grep trycloudflare

# Test persistence
./scripts/test-persistence.sh <username>

# Test KEDA scaling
./scripts/test-keda-scaling.sh <namespace> <timeout>

# Helm template validation
helm template desktop ./charts/desktop --set desktop.browser=chromium
helm template desktop ./charts/desktop --set desktop.profile=large
```

## Code Style

- **Shell scripts**: `set -euo pipefail` at top, double-quote variables, use `[[ ]]` over `[ ]`
- **Helm templates**: Use `{{ include "workstation.labels" . }}` from `_helpers.tpl` for labels
- **YAML**: 2-space indent, no tabs
- **Dockerfile**: Multi-stage not needed (Alpine is small), single layer for cleanup
- **Git**: Conventional commits (`feat:`, `fix:`, `chore:`), no AI attribution
- **Commit author**: Ignacio del Corro <ignacio@workstation.center>

## Project Structure

```
charts/
  desktop/          # Helm chart for desktop deployment
    templates/
      _helpers.tpl    # Label/selector helpers, resource profiles
      deployment.yaml # Desktop + cloudflared sidecar
      service.yaml    # ClusterIP service
      networkpolicy.yaml # Ingress-only rules
      keda-scaledobject.yaml # Event-driven autoscaling
      NOTES.txt       # Post-install instructions
    values.yaml       # Default values (browser, profile, KEDA, etc.)
images/
  desktop-novnc/    # Alpine desktop image (Dockerfile + config)
    Dockerfile        # ARG BROWSER=chromium, supervisord, nginx
    supervisord.conf  # 5 services: xvfb, fluxbox, x11vnc, websockify, nginx
    nginx/            # HTTPS redirect + WebSocket proxy
    entrypoint.sh     # Startup script
    inactivity-monitor.sh # xprintidle → graceful shutdown
skills/             # Agent skills (agentskills.io format)
  alpine-desktop-image/    # Image build patterns
  cloudflare-tunnel-sidecar/ # Tunnel setup
  k3s-cluster-setup/       # k3s installation
  k8s-desktop-deploy/      # Desktop deployment
  helm-chart-patterns/     # Chart conventions
  freestyle-vm-management/ # Freestyle.sh VMs (limitations)
  popeye-cluster-diagnostics/ # Cluster health
  longhorn-distributed-storage/ # PVC storage
deployments/        # Deploy scripts
  quick-deploy.sh     # kubectl-based quick deploy
  deploy-desktop.sh   # Helm-based deploy
  create-user.sh      # User creation
  delete-user.sh      # User cleanup
infrastructure/     # K8s manifests
  keda.yaml           # KEDA operator
  postgres.yaml       # PostgreSQL StatefulSet
  redis.yaml          # Redis Deployment
docs/               # Documentation
  architecture.md     # Architecture overview
  cluster-roadmap.md  # 7-phase cluster roadmap
```

## Architecture

```
Browser → Cloudflare Edge (HTTPS) → Tunnel → nginx (6080) → websockify (6081) → noVNC
                                                                    ↓
                                                                x11vnc (5900) → Xvfb (:99) → fluxbox
```

- **nginx**: HTTP→HTTPS redirect via `X-Forwarded-Proto` header + reverse proxy (port 6080)
- **websockify**: WebSocket bridge to VNC (port 6081)
- **x11vnc**: VNC server (port 5900)
- **Xvfb**: Virtual framebuffer, display :99 (1920x1080x24)
- **fluxbox**: Window manager (lightweight, no desktop icons)
- **cloudflared**: Cloudflare quick tunnel sidecar (ephemeral HTTPS URL)
- **supervisord**: Process manager for all 5 services

## Key Configuration

| Variable | Default | Description |
|----------|---------|-------------|
| `desktop.browser` | `chromium` | `chromium` or `firefox` |
| `desktop.profile` | `small` | `small`, `medium`, or `large` |
| `desktop.autoShutdown.timeoutMinutes` | `60` | X11 idle minutes before shutdown (0=disabled) |
| `desktop.keda.enabled` | `false` | Event-driven autoscaling to zero |
| `desktop.persistence.enabled` | `false` | PVC for user files |

## Resource Profiles

| Profile | CPU req/limit | RAM req/limit | Use case |
|---------|--------------|---------------|----------|
| small | 250m / 1 | 256Mi / 1Gi | Dev/test, constrained clusters |
| medium | 500m / 2 | 512Mi / 2Gi | Production single-tenant |
| large | 1 / 4 | 1Gi / 4Gi | Power users, multi-tab |

## Skills Reference

Skills live in `skills/` and follow [agentskills.io](https://agentskills.io) format. Load before working on related tasks.

| Skill | Trigger | Covers |
|-------|---------|--------|
| [alpine-desktop-image](skills/alpine-desktop-image/SKILL.md) | build image, dockerfile, browser | Alpine image build, browser selection, supervisord |
| [cloudflare-tunnel-sidecar](skills/cloudflare-tunnel-sidecar/SKILL.md) | tunnel, https, cloudflare | Quick tunnel setup, HTTPS enforcement, error codes |
| [k3s-cluster-setup](skills/k3s-cluster-setup/SKILL.md) | k3s, install cluster, k3s setup | k3s installation, flags, image import |
| [k8s-desktop-deploy](skills/k8s-desktop-deploy/SKILL.md) | deploy desktop, k8s desktop | Desktop deployment in K8s |
| [helm-chart-patterns](skills/helm-chart-patterns/SKILL.md) | helm chart, values, profiles | Chart conventions, resource profiles |
| [freestyle-vm-management](skills/freestyle-vm-management/SKILL.md) | freestyle, freestyle.sh vm | Freestyle.sh CLI and VMs (read limitations first!) |
| [popeye-cluster-diagnostics](skills/popeye-cluster-diagnostics/SKILL.md) | popeye, cluster health | Cluster scanning and diagnostics |
| [longhorn-distributed-storage](skills/longhorn-distributed-storage/SKILL.md) | longhorn, persistent storage | Distributed PVC storage |
| [skill-factory](skills/skill-factory/SKILL.md) | create skill, generate AGENTS.md, agent docs | Create skills and AGENTS.md for any repo |

## Security Considerations

- Cloudflare quick tunnel URLs are **ephemeral** — change every pod restart
- VNC is **not password-protected** for web-only access (via nginx on 6080)
- Network policies restrict ingress but **not egress** (cloudflared needs unrestricted outbound)
- Desktop runs as non-root `desktop` user (UID 1000)
- guacamole auth: `guacadmin` / `bux2026` (change in production)
- No secrets in Helm values — use Kubernetes secrets or external secret managers
- `--no-sandbox` is required for Chromium in containers (reduced security, acceptable for desktop isolation)

## Gotchas

- **Chromium needs special flags**: `--no-sandbox --disable-gpu --disable-dev-shm-usage --disable-setuid-sandbox` — without these, blank screen
- **nginx required for HTTPS redirect**: Cloudflare quick tunnels serve HTTP+HTTPS on same port; nginx checks `X-Forwarded-Proto`
- **`setsid` required for X services**: `nohup`+`disown` is NOT sufficient when bash is killed by timeout
- **k3s uses containerd**: Cannot `docker pull` directly — use `docker save | k3s ctr images import -`
- **k3s disk pressure**: Configure eviction threshold in `/etc/rancher/k3s/config.yaml`
- **Freestyle.sh VMs**: Kernel too restricted for K8s pod networking — use standard VPS instead
- **Alpine packages**: Use `font-dejavu` (not `fonts-dejavu`), `gnome-themes-extra` (not `adwaita-dark-theme`)
- **Image tag auto-derivation**: Helm chart derives `image.tag` from `desktop.browser` — don't set both
- **`imagePullPolicy: Never`** required for local containerd images in k3s
