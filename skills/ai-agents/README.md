# AI Agents Skill

## What problem does it solve?

Deploy and manage AI agents per user in a multi-tenant environment. Each user gets their own agent with persistence, model configuration, and tool access.

## When should it be used?

- SaaS platforms offering AI assistants
- Multi-user AI development environments
- Training/education with AI tutoring
- Enterprise AI deployments with data isolation

## When should NOT it be used?

- Single-user personal AI tools
- Simple chatbot applications (use shared deployment)
- When user data isolation is not required
- When cost per user is critical (shared is cheaper)

## Decision Tree

```
Need per-user AI agents?
↓
Data isolation required?
↓
Yes → Separate agent per user
No → Shared agent with user context
↓
Persistence needed?
↓
Yes → PVC for conversation history
No → Stateless agents
↓
Model access?
↓
Shared API key → Single deployment
Per-user keys → Separate deployments
↓
Desktop access needed?
↓
Yes → Agent + Desktop deployment
No → Agent only
```

## Best Practices

1. **Namespace per user** - Isolate resources and data
2. **Persistent volumes** - Survive pod restarts
3. **Resource limits** - Prevent one user from consuming all resources
4. **API key management** - Never hardcode, use secrets
5. **Health checks** - Monitor agent availability

## Anti-Patterns

- Don't store API keys in ConfigMaps
- Don't skip resource limits (one user can starve others)
- Don't use hostPath for persistence
- Don't share PVCs between users
- Don't forget auto-scaling for cost control

## References

- [OpenAI API](https://platform.openai.com/docs/)
- [Anthropic API](https://docs.anthropic.com/)
- [Kubernetes Volumes](https://kubernetes.io/docs/concepts/storage/volumes/)
