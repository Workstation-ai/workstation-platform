# Workstation Platform Architecture

## Overview

Workstation Platform is a multi-tenant Kubernetes platform that provides:
- **AI Agents** per user with persistence
- **On-demand desktops** via Guacamole/VNC
- **Multi-cloud management** via MCP server
- **Event-driven scaling** with KEDA

## Components

```
┌─────────────────────────────────────────────────────────────┐
│                    Workstation Platform                      │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │
│  │   Agent A    │  │   Agent B    │  │   Agent C    │      │
│  │  (User: A)   │  │  (User: B)   │  │  (User: C)   │      │
│  └──────┬───────┘  └──────┬───────┘  └──────┬───────┘      │
│         │                 │                 │                │
│  ┌──────┴─────────────────┴─────────────────┴──────┐       │
│  │              MCP Server (Multicloud)            │       │
│  │     AWS / Azure / Hetzner Cloud / SSH           │       │
│  └─────────────────────┬───────────────────────────┘       │
│                        │                                    │
│  ┌─────────────────────┴───────────────────────────┐       │
│  │              Infrastructure Layer               │       │
│  │    PostgreSQL    Redis    KEDA    Ingress        │       │
│  └─────────────────────────────────────────────────┘       │
│                                                              │
│  ┌─────────────────────────────────────────────────┐       │
│  │         Desktops (On-Demand, Per User)          │       │
│  │    Desktop A    Desktop B    Desktop C           │       │
│  │   (Guacamole)  (Guacamole)  (Guacamole)         │       │
│  └─────────────────────────────────────────────────┘       │
│                                                              │
└─────────────────────────────────────────────────────────────┘
```

## Namespaces

- **workstation**: Core platform (MCP server, PostgreSQL, Redis)
- **agent-<name>**: Per-user agent namespace
- **desktop-<name>**: Per-user desktop namespace
- **keda**: KEDA operators and controllers

## Data Flow

1. **User Request** → MCP Server → Cloud Provider API
2. **Agent Request** → Agent Pod → MCP Server → Cloud Provider
3. **Desktop Request** → Guacamole → VNC → Desktop Pod

## Persistence

- **Agent data**: PVC mounted at `/home/agent/persistence`
- **Desktop data**: PVC mounted at `/home/user`
- **PostgreSQL**: StatefulSet with persistent storage
- **Redis**: Optional persistence for session data

## Scaling

- **MCP Server**: KEDA ScaledObject based on CPU/Memory
- **Agents**: Manual scaling per user
- **Desktops**: On-demand creation/deletion

## Security

- **RBAC**: Per-namespace roles
- **Network Policies**: Isolation between tenants
- **Secrets**: Cloud credentials, VNC passwords
- **Policies**: Pod security, resource limits

## Multi-Cloud

- **AWS**: S3, EC2, Lambda via boto3
- **Azure**: VMs, Storage, ARM via Azure SDK
- **Hetzner**: Cloud servers via hcloud
- **SSH**: Remote command execution

## Monitoring

- **Prometheus**: Metrics collection
- **Grafana**: Dashboards
- **Alerts**: KEDA scaling, pod failures

## Future Enhancements

- **Service Mesh**: Istio/Linkerd for advanced networking
- **GitOps**: ArgoCD for deployment automation
- **Cost Tracking**: Per-user resource usage
- **GPU Support**: AI model training
