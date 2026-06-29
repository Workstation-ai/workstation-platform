# Helm Charts Skill

## What problem does it solve?

Helm charts package Kubernetes manifests into reusable, configurable deployments. This skill covers chart structure, templating, values management, and best practices.

## When should it be used?

- Packaging Kubernetes applications
- Creating reusable deployment templates
- Managing multiple environments (dev/staging/prod)
- Sharing deployment patterns across teams

## When should NOT it be used?

- Simple single-file deployments (kubectl apply is fine)
- When Kustomize is preferred
- Dynamic configurations better handled by operators

## Decision Tree

```
Need to package K8s manifests?
↓
Multiple environments?
↓
Yes → Helm chart with values-{env}.yaml
No → Single values.yaml
↓
Reusable across projects?
↓
Yes → Library chart
No → Application chart
↓
Complex templates?
↓
Yes → Use helpers (_helpers.tpl)
No → Simple templates
```

## Best Practices

1. **Chart.yaml** - Semantic versioning, descriptive metadata
2. **values.yaml** - Sensible defaults, documented options
3. **_helpers.tpl** - Reusable template functions
4. **templates/** - One file per resource type
5. **charts/** - Dependencies as subcharts

## Anti-Patterns

- Don't hardcode values in templates
- Don't skip values validation
- Don't create monolithic charts (split into subcharts)
- Don't ignore helm lint warnings

## References

- [Helm Documentation](https://helm.sh/docs/)
- [Chart Best Practices](https://helm.sh/docs/chart_best_practices/)
