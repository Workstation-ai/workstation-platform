# Open Agent Skills (OAS)

This repository defines a vendor-neutral way to organize reusable AI knowledge for multi-tenant Kubernetes platforms.

## Mission

Build an open collection of reusable Skills for cloud-native infrastructure.

A Skill is **not** a prompt.  
A Skill is **not** an agent.  
A Skill is a structured knowledge package that helps an AI solve problems within a specific domain.

## Repository Layout

```text
skills/
    <skill-name>/
        README.md
        metadata.yaml
        decision-tree.md
        best-practices.md
        anti-patterns.md
        examples.md
        references/
```

## Available Skills

| Skill | Description |
|-------|-------------|
| [kubernetes](skills/kubernetes/) | K8s deployment patterns for multi-tenant platforms |
| [helm-charts](skills/helm-charts/) | Helm chart best practices and conventions |
| [remote-desktop](skills/remote-desktop/) | Browser-based desktop technologies (Guacamole, VNC) |
| [multicloud](skills/multicloud/) | Multi-cloud management (AWS, Azure, Hetzner) |
| [ai-agents](skills/ai-agents/) | AI agent deployment and persistence patterns |
| [keda](skills/keda/) | Event-driven scaling with KEDA |
| [persistence](skills/persistence/) | PVC, S3, and state management patterns |

## Philosophy

The repository should remain useful even if every current AI vendor disappears.

Avoid coupling Skills to specific AI tools.  
The knowledge should remain portable across:
- Claude Code
- Codex / OpenCode
- Gemini CLI
- Cursor
- Roo Code / Cline
- Future tools

## Agent Behavior

When working inside this repository:

- Prefer extending existing Skills over creating duplicates
- Reuse references whenever possible
- Keep files concise
- Prefer decision trees over long prose
- Prefer examples over abstract explanations
- Keep documentation maintainable

If a new domain appears, create a new Skill.  
If existing knowledge can be improved, update it instead.  
Always optimize for long-term maintainability rather than short-term convenience.
