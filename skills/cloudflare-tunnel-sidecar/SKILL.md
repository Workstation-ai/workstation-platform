---
name: cloudflare-tunnel-sidecar
description: "Trigger: cloudflare tunnel, tunnel sidecar, https redirect, quick tunnel. Set up Cloudflare quick tunnels with HTTPS enforcement in K8s pods."
license: Apache-2.0
metadata:
  author: "Workstation AI"
  version: "1.0"
---

# Cloudflare Tunnel Sidecar

Run Cloudflare quick tunnels as a sidecar container for public HTTPS access to K8s pods.

## Activation Contract

Use this skill when:
- Adding Cloudflare tunnel access to a K8s pod
- Debugging tunnel connectivity (522, 530, 1033 errors)
- Setting up HTTPS redirect for tunnel users
- Configuring WebSocket proxying through tunnels

## Hard Rules

- cloudflared has NO shell — use direct command array, not shell script
- Quick tunnel URLs are ephemeral — change every pod restart
- Always use `imagePullPolicy: Always` for cloudflared
- HTTP→HTTPS redirect requires nginx or application-level handling — Cloudflare doesn't auto-redirect
- Tunnel connects to localhost — the sidecar and main container share the pod network

## Sidecar Container Spec

```yaml
- name: cloudflared
  image: cloudflare/cloudflared:latest
  imagePullPolicy: Always
  command:
    - "cloudflared"
    - "tunnel"
    - "--no-autoupdate"
    - "--url"
    - "http://localhost:6080"
  resources:
    requests:
      cpu: "50m"
      memory: "32Mi"
    limits:
      cpu: "200m"
      memory: "128Mi"
```

## HTTPS Enforcement

Cloudflare quick tunnels serve HTTP and HTTPS on the same port. The backend can't distinguish them. Use nginx with `X-Forwarded-Proto`:

```nginx
server {
    listen 6080;
    if ($http_x_forwarded_proto = "http") {
        return 301 https://$host$request_uri;
    }
    location / {
        proxy_pass http://127.0.0.1:6081/;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
    }
}
```

## Tunnel Error Codes

| Code | Meaning | Fix |
|------|---------|-----|
| 522 | Connection timed out | Pod restarting — check `kubectl get pods` |
| 530 | Origin DNS error | Pod not ready — wait for Ready state |
| 1033 | Tunnel not connected | URL expired — get new URL from logs |

## Get Tunnel URL

```bash
kubectl logs <pod> -c cloudflared | grep -o 'https://[a-zA-Z0-9-]*\.trycloudflare\.com' | tail -1
```

## References

- `images/desktop-novnc/nginx/workstation.conf` — nginx HTTPS redirect config
- `images/desktop-novnc/supervisord.conf` — process manager config
