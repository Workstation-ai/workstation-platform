# Workstation Platform — Agent Instructions

This repo provides **Workstation Center OS**: browser-accessible virtual desktops on Kubernetes with Cloudflare tunnels.

## Quick Start

```bash
# Deploy a desktop (quick deploy, no Helm)
./deployments/quick-deploy.sh desktop-guac alpine-https

# Deploy via Helm
./deployments/deploy-desktop.sh <username> <user-id>

# Build the desktop image
docker build -t workstation/desktop:alpine-https images/desktop-novnc/
```

## Skills

Specialized skills for this project live in `skills/`. Load them before working on related tasks.

| Skill | Trigger | What it covers |
|-------|---------|----------------|
| [k8s-desktop-deploy](skills/k8s-desktop-deploy/SKILL.md) | deploy desktop, k8s desktop, pod desktop | Deploying Workstation Center OS desktops in Kubernetes |
| [cloudflare-tunnel-sidecar](skills/cloudflare-tunnel-sidecar/SKILL.md) | cloudflare tunnel, tunnel sidecar, https redirect | Cloudflare quick tunnel setup with HTTPS enforcement |
| [alpine-desktop-image](skills/alpine-desktop-image/SKILL.md) | build desktop image, alpine desktop, dockerfile | Building lightweight Alpine-based desktop images |
| [helm-chart-patterns](skills/helm-chart-patterns/SKILL.md) | helm chart, chart values, resource profile | Helm chart patterns and resource profiles for this project |

## Architecture

```
Browser → Cloudflare Edge (HTTPS) → Tunnel → nginx (6080) → websockify (6081) → noVNC
                                                                        ↕
                                                                    x11vnc (5900) → Xvfb (:99) → fluxbox
```

- **nginx**: HTTP→HTTPS redirect + reverse proxy (port 6080)
- **websockify**: WebSocket bridge to VNC (port 6081)
- **x11vnc**: VNC server (port 5900)
- **Xvfb**: Virtual framebuffer (display :99)
- **fluxbox**: Window manager
- **cloudflared**: Cloudflare tunnel sidecar (ephemeral HTTPS URL)
- **supervisord**: Process manager for all services

## Image Details

- Base: `alpine:3.20`
- Size: ~524MB
- Packages: xvfb, x11vnc, websockify, fluxbox, nginx, supervisor, firefox-esr, font-dejavu
- noVNC: cloned from GitHub at build time
- Branding: workstation.center logo downloaded at build time

## Resource Profiles

| Profile | CPU req/limit | RAM req/limit | Use case |
|---------|--------------|---------------|----------|
| small | 250m / 1 | 256Mi / 1Gi | Dev/test, constrained clusters |
| medium | 500m / 2 | 512Mi / 2Gi | Production single-tenant |
| large | 1 / 4 | 1Gi / 4Gi | Power users, multi-tab |

Usage: `helm install desktop ./charts/desktop --set desktop.profile=large`

## Lessons Learned

- Cloudflare quick tunnels serve HTTP and HTTPS on the same port — use nginx with `X-Forwarded-Proto` to redirect
- Alpine packages: `font-dejavu` (not `fonts-dejavu`)
- `x11vnc -storepasswd` is interactive — skip VNC password for web-only access
- Minikube KIC base image layers consume ~16GB — `docker system prune -af` frees space
- `docker save` needs 2x image size in temp space — clean Docker before loading
- supervisord is simpler than complex initContainer scripts in Helm
- All services must start via `setsid` or supervisord to survive parent process exit

## Git Conventions

- Author: Ignacio del Corro <ignacio@workstation.center>
- Conventional commits
- No AI attribution
