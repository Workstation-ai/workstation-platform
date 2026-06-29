# Multi-Cloud Skill

## What problem does it solve?

Manage resources across multiple cloud providers (AWS, Azure, Hetzner) with a unified interface. Avoid vendor lock-in and enable failover between providers.

## When should it be used?

- Applications requiring high availability across clouds
- Cost optimization across providers
- Compliance requirements (data sovereignty)
- Disaster recovery planning
- Gradual migration between clouds

## When should NOT it be used?

- Single-cloud applications (adds complexity)
- Small projects (cloud abstraction overhead not worth it)
- When vendor-specific features are needed
- When team lacks multi-cloud expertise

## Decision Tree

```
Need multi-cloud?
↓
Primary reason?
↓
Cost optimization → Compare pricing, use spot/preemptible
High availability → Active-passive or active-active
Compliance → Data sovereignty requirements
Avoid lock-in → Abstract with Terraform/Pulumi
↓
Complexity budget?
↓
Low → Single cloud with multi-region
Medium → 2 clouds with manual failover
High → Multi-cloud with service mesh
```

## Best Practices

1. **Terraform/Pulumi** - Infrastructure as Code across providers
2. **Abstraction layers** - Don't use provider-specific APIs directly
3. **Unified monitoring** - Single pane of glass for all clouds
4. **Cost tracking** - Monitor spending per provider
5. **Security** - Rotate credentials, use IAM roles

## Anti-Patterns

- Don't use multi-cloud just because (complexity cost)
- Don't skip cost monitoring (surprise bills)
- Don't hardcode cloud-specific values
- Don't ignore latency between clouds
- Don't assume same API across providers

## References

- [Terraform](https://www.terraform.io/)
- [Pulumi](https://www.pulumi.com/)
- [AWS SDK](https://aws.amazon.com/sdk/)
- [Azure SDK](https://learn.microsoft.com/en-us/azure/developer/javascript/azure-sdk-library-package)
- [Hetzner Cloud](https://docs.hetzner.cloud/)
