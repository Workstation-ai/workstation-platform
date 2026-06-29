# Workstation Platform

Multi-tenant Kubernetes platform for AI agents and on-demand desktops with multi-cloud support.

## Features

- **AI Agents per User**: Each user gets their own AI agent with persistence
- **On-Demand Desktops**: Guacamole/VNC desktops for paid users
- **Multi-Cloud Management**: AWS, Azure, Hetzner Cloud via MCP server
- **Event-Driven Scaling**: KEDA for automatic scaling
- **Enterprise Security**: RBAC, network policies, secrets management

## Quick Start

```bash
# Clone repository
git clone https://github.com/gastonzarate/devops_mcp.git
cd devops_mcp

# Setup Kubernetes
./scripts/setup-k8s.sh minikube

# Create first user
./deployments/create-user.sh john john-001 --desktop

# Access desktop
kubectl get ingress -n desktop-john
```

## Architecture

```
User → Agent → MCP Server → Cloud Providers
                ↓
        PostgreSQL / Redis
                ↓
        KEDA Scaling
```

## Documentation

- [Architecture](docs/architecture.md)
- [Getting Started](docs/getting-started.md)
- [Roadmap](roadmap.md)

## Components

| Component | Description |
|-----------|-------------|
| Base Chart | Core platform infrastructure |
| Agent Chart | Per-user AI agent deployment |
| Desktop Chart | On-demand desktop via Guacamole |
| MCP Server | Multi-cloud management API |

## Testing

```bash
# Test persistence
./scripts/test-persistence.sh john

# Test KEDA scaling
./scripts/test-keda-scaling.sh workstation 60

# Test multicloud
./scripts/test-multicloud.sh all
```

## Contributing

1. Fork the repository
2. Create feature branch
3. Commit changes
4. Push to branch
5. Create Pull Request

## License

MIT License - see [LICENSE](LICENSE) for details
