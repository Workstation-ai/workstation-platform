---
name: cloudflare-tunnel-sidecar
description: "Set up Cloudflare quick tunnels as K8s sidecar containers with HTTPS enforcement. Use when exposing pod services publicly, debugging tunnel errors (522, 530, 1033), or configuring WebSocket proxying through tunnels."
license: Apache-2.0
compatibility: Requires Kubernetes cluster, cloudflared container image
metadata:
  author: workstation-ai
  version: "3.0"
---

# Cloudflare Tunnel Sidecar

Run Cloudflare quick tunnels as a sidecar container for public HTTPS access to K8s pods.

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

**CRITICAL:** cloudflared has NO shell — use direct command array, not shell script.

## HTTPS Enforcement

Cloudflare quick tunnels serve HTTP and HTTPS on same port without auto-redirect. Backend uses `X-Forwarded-Proto` header:

```nginx
if ($http_x_forwarded_proto = "http") {
    return 301 https://$host$request_uri;
}
```

Without this, users get redirected to HTTP and see nothing.

## Get Tunnel URL

```bash
kubectl logs <pod> -c cloudflared | grep -o 'https://[a-zA-Z0-9-]*\.trycloudflare\.com' | tail -1
```

**Note:** URLs are ephemeral — change every pod restart.

## Tunnel Error Codes

| Code | Meaning | Fix |
|------|---------|-----|
| 522 | Connection timed out | Pod restarting — wait or check logs |
| 530 | Origin DNS error | Pod not ready — check readiness |
| 1033 | Tunnel not connected | URL expired — get new URL from logs |
| 404 | No content | nginx not running or wrong path |
| 403 | Forbidden | File permissions — chown to app user |

## Hard Rules

- Quick tunnel URLs are ephemeral — always capture fresh URL after pod restart
- HTTP→HTTPS redirect requires nginx or app-level handling
- Tunnel connects to localhost — sidecar and main container share pod network
- Use `imagePullPolicy: Always` for cloudflared
- Network policies must allow egress on port 7844 (QUIC/UDP) for cloudflared

## Network Policy Considerations

Cloudflared needs unrestricted outbound:
- UDP 7844 (QUIC protocol)
- HTTPS 443 (fallback)
- DNS 53

Do NOT restrict egress in network policies if using cloudflared sidecar.

## Scripts

See [scripts/deploy-tunnel.sh](scripts/deploy-tunnel.sh) for a complete deployment example.

## References

- `images/desktop-novnc/nginx/workstation.conf` — nginx HTTPS redirect config
- `charts/desktop/templates/deployment.yaml` — Helm deployment with sidecar
