---
name: k8s-desktop-deploy
description: "Trigger: deploy desktop, k8s desktop, pod desktop, create desktop pod. Deploy Workstation Center OS desktops in Kubernetes with Cloudflare tunnels."
license: Apache-2.0
metadata:
  author: "Workstation AI"
  version: "1.0"
---

# K8s Desktop Deployment

Deploy browser-accessible virtual desktops on Kubernetes.

## Activation Contract

Use this skill when:
- Deploying a Workstation Center OS desktop to a K8s cluster
- Creating a desktop pod with Cloudflare tunnel
- Scaling desktop deployments
- Debugging desktop pod issues

## Hard Rules

- Always use `imagePullPolicy: IfNotPresent` for locally-built images
- Always set `runAsUser: 0` and `runAsGroup: 0` for the desktop container
- Cloudflare tunnel container must use `imagePullPolicy: Always` (quick tunnel images update frequently)
- Never hardcode VNC passwords in manifests — use secrets or disable VNC password for web access
- Namespace must exist before deployment — use `--create-namespace` or pre-create

## Quick Deploy (kubectl)

```bash
kubectl create namespace <namespace> 2>/dev/null || true

cat <<EOF | kubectl apply -n <namespace> -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: desktop
spec:
  replicas: 1
  selector:
    matchLabels:
      app: desktop
  template:
    metadata:
      labels:
        app: desktop
    spec:
      securityContext:
        runAsUser: 0
        runAsGroup: 0
      containers:
      - name: desktop
        image: workstation/desktop:alpine-https
        imagePullPolicy: IfNotPresent
        ports:
        - containerPort: 6080
        - containerPort: 5900
        resources:
          requests:
            cpu: "250m"
            memory: "256Mi"
          limits:
            cpu: "1"
            memory: "1Gi"
      - name: cloudflared
        image: cloudflare/cloudflared:latest
        imagePullPolicy: Always
        command: ["cloudflared", "tunnel", "--no-autoupdate", "--url", "http://localhost:6080"]
        resources:
          requests:
            cpu: "50m"
            memory: "32Mi"
          limits:
            cpu: "200m"
            memory: "128Mi"
EOF
```

## Helm Deploy

```bash
helm install desktop-<username> ./charts/desktop \
  --namespace desktop-<username> \
  --create-namespace \
  --set desktop.name=<username> \
  --set desktop.userId=<user-id> \
  --set desktop.profile=small
```

## Resource Profiles

| Profile | CPU req/limit | RAM req/limit |
|---------|--------------|---------------|
| small | 250m / 1 | 256Mi / 1Gi |
| medium | 500m / 2 | 512Mi / 2Gi |
| large | 1 / 4 | 1Gi / 4Gi |

## Get Tunnel URL

```bash
kubectl logs <pod> -c cloudflared | grep -o 'https://[a-zA-Z0-9-]*\.trycloudflare\.com' | tail -1
```

## Troubleshooting

- **CrashLoopBackOff**: check `kubectl describe pod <pod>` — usually image pull or resource pressure
- **522 error**: tunnel disconnected — pod may be restarting, check `kubectl get pods`
- **404**: tunnel working but nginx not ready — wait 5s after pod starts
- **ImagePullBackOff**: image not in cluster — use `minikube image load` or push to registry

## References

- `charts/desktop/` — Helm chart
- `deployments/quick-deploy.sh` — quick deploy script
- `images/desktop-novnc/` — Dockerfile and configs
