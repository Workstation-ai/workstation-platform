---
name: alpine-desktop-image
description: "Build lightweight Alpine-based desktop images with configurable browser (chromium/firefox), supervisord, nginx HTTPS proxy, inactivity monitor, and branding. Use when building desktop container images for Kubernetes."
license: Apache-2.0
compatibility: Requires Docker, internet access for package installation
metadata:
  author: workstation-ai
  version: "3.0"
---

# Alpine Desktop Image

Build lightweight, self-contained desktop images for Kubernetes with browser selection, HTTPS reverse proxy, inactivity monitoring, and branding.

## Overview

Alpine 3.20 base (~8MB) with configurable browser, supervisord process manager, and 5 services.

## Quick Reference

| Component | Firefox | Chromium |
|-----------|---------|----------|
| Image size | ~525MB | ~808MB |
| Package | `firefox-esr` | `chromium` |
| Startup | ~3s | ~5s |
| Web compat | Good | Excellent |

## Browser Selection

Dockerfile ARG controls which browser is installed:

```bash
# Build Firefox version (default, smaller)
docker build --build-arg BROWSER=firefox -t desktop:firefox .

# Build Chromium version (better compat, larger)
docker build --build-arg BROWSER=chromium -t desktop:chromium .
```

### Chromium Flags (REQUIRED in containers)

Chromium needs special flags or it shows a blank screen:

```
--no-sandbox --disable-gpu --disable-dev-shm-usage --disable-setuid-sandbox --window-size=1920,1080
```

## Supervisord (5 Services)

Process manager handles all services — no shell scripts with `&`:

| Priority | Service | Command | Port |
|----------|---------|---------|------|
| 10 | Xvfb | `Xvfb :99 -screen 0 1920x1080x24` | :99 |
| 20 | Fluxbox | `fluxbox` (DISPLAY=:99) | — |
| 30 | x11vnc | `x11vnc -display :99 -nopw -forever` | 5900 |
| 40 | websockify | `websockify 6081 localhost:5900` | 6081 |
| 50 | nginx | `nginx -g 'daemon off;'` | 6080 |

## Nginx HTTPS Proxy

nginx on port 6080 handles HTTP→HTTPS redirect via `X-Forwarded-Proto` header:

```nginx
server {
    listen 6080;
    if ($http_x_forwarded_proto = "http") {
        return 301 https://$host$request_uri;
    }
    location / {
        proxy_pass http://127.0.0.1:6081;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
    }
}
```

## Inactivity Monitor

Uses `xprintidle` to detect X11 idle time and shut down supervisord:

```bash
# Environment variable
IDLE_TIMEOUT_MIN=60  # minutes, 0=disabled
```

## Branding

- Logo: `https://workstation.center/logo.png`
- Wallpaper: downloaded at runtime, set via `fbsetbg`
- Title: "Workstation Center OS"
- Menu: custom fluxbox menu with app launcher

## Port Map

| Port | Service | Purpose |
|------|---------|---------|
| 6080 | nginx | HTTPS entry + HTTP→HTTPS redirect |
| 6081 | websockify | WebSocket bridge + noVNC files |
| 5900 | x11vnc | VNC protocol |
| :99 | Xvfb | Virtual framebuffer |

## Helm Resource Profiles

```yaml
desktop:
  profile: small  # small (250m/256Mi), medium (500m/512Mi), large (1/1Gi)
  browser: chromium  # chromium or firefox
  image:
    tag: alpine-chromium  # auto-derived from browser
```

## Scripts

See [scripts/build.sh](scripts/build.sh) for the build script.

## References

- `images/desktop-novnc/Dockerfile` — Full Dockerfile
- `images/desktop-novnc/supervisord.conf` — Process manager
- `images/desktop-novnc/nginx/workstation.conf` — HTTPS proxy
- `images/desktop-novnc/entrypoint.sh` — Startup script
- `images/desktop-novnc/inactivity-monitor.sh` — Idle detection
