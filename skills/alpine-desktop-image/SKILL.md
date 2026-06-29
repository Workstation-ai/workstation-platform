---
name: alpine-desktop-image
description: "Trigger: build desktop image, alpine desktop, dockerfile, desktop docker. Build lightweight Alpine-based desktop images with Firefox and noVNC."
license: Apache-2.0
metadata:
  author: "Workstation AI"
  version: "1.0"
---

# Alpine Desktop Image

Build lightweight, self-contained desktop images for Kubernetes.

## Activation Contract

Use this skill when:
- Building or modifying the desktop Docker image
- Adding packages to the desktop environment
- Customizing branding (logo, wallpaper, menu)
- Debugging image build issues

## Hard Rules

- Base image: `alpine:3.20` — not debian (47% smaller)
- Alpine font package: `font-dejavu` (NOT `fonts-dejavu`)
- `x11vnc -storepasswd` is interactive — skip VNC password for web-only access
- Use supervisord, NOT shell scripts with `&` — survives parent process exit
- noVNC is cloned from GitHub at build time — pin to a tag for reproducibility
- Branding assets downloaded at build time — verify URL is accessible

## Package List

```
xvfb x11vnc websockify fluxbox nginx supervisor
firefox-esr font-dejavu bash curl git
```

## Supervisord Config

```ini
[supervisord]
nodaemon=true
user=root

[program:xvfb]
command=Xvfb :99 -screen 0 1920x1080x24 -ac
autorestart=true
priority=10

[program:fluxbox]
command=fluxbox
environment=DISPLAY=":99",HOME="/home/desktop"
user=desktop
autorestart=true
priority=20

[program:x11vnc]
command=x11vnc -display :99 -nopw -forever -shared -rfbport 5900
autorestart=true
priority=30

[program:websockify]
command=websockify --web /usr/share/novnc 6081 localhost:5900
autorestart=true
priority=40

[program:nginx]
command=nginx -g "daemon off;"
autorestart=true
priority=50
```

## Build & Load

```bash
# Build on host
docker build -t workstation/desktop:alpine-https images/desktop-novnc/

# Load into minikube
minikube image load workstation/desktop:alpine-https

# Or pipe (avoids minikube cache)
docker save workstation/desktop:alpine-https | docker exec -i minikube docker load
```

## Disk Space Notes

- `docker save` needs 2x image size in temp space
- Clean Docker first: `docker system prune -af`
- Minikube KIC base image uses ~16GB overlay2 — not reclaimable
- Alpine image: ~524MB vs Debian: ~995MB

## Branding

- Logo: `curl -fsSL https://workstation.center/logo.png -o /usr/share/workstation/branding/logo.png`
- Fluxbox menu: custom `[begin] (Workstation Center OS)` with app launcher
- Wallpaper: copied to `/home/desktop/.workstation/wallpaper.png` at runtime

## Port Map

| Port | Service | Purpose |
|------|---------|---------|
| 6080 | nginx | HTTPS entry point + HTTP→HTTPS redirect |
| 6081 | websockify | WebSocket bridge + noVNC static files |
| 5900 | x11vnc | VNC protocol |
| :99 | Xvfb | Virtual framebuffer |

## References

- `images/desktop-novnc/Dockerfile` — image definition
- `images/desktop-novnc/supervisord.conf` — process manager
- `images/desktop-novnc/nginx/workstation.conf` — HTTPS proxy
- `images/desktop-novnc/entrypoint.sh` — startup script
