# Generate vs Skip Reference

Quick reference for what to generate and what to skip when setting up agent docs.

## AGENTS.md: Generate vs Skip

### GENERATE

| Section | When | Why |
|---------|------|-----|
| Setup Commands | Always | Agents need to install deps |
| Build Commands | Always | Agents need to build |
| Test Commands | Always | Agents need to verify |
| Code Style | Project has linting/formatting | Agents need to follow conventions |
| Project Structure | Monorepo or complex layout | Agents need to navigate |
| Architecture | Multi-service or layered | Agents need to understand components |
| Key Configuration | Non-obvious env vars/flags | Agents need to configure correctly |
| Skills Reference | skills/ directory exists | Agents need to discover skills |
| Security Concerns | Auth, secrets, sensitive data | Agents need to avoid mistakes |
| Gotchas | Non-obvious behaviors | Agents will hit these without warning |

### SKIP

| Content | Why Skip |
|---------|----------|
| Project history | Use CHANGELOG.md |
| Detailed API docs | Use docs/ directory |
| Contributing guidelines | Use CONTRIBUTING.md |
| License text | Use LICENSE file |
| "Write clean code" | Agent already knows |
| "Follow SOLID" | Agent already knows |
| "Use good naming" | Agent already knows |
| Git basics | Agent already knows |
| What is HTTP | Agent already knows |
| What is a database | Agent already knows |

## Skills: Generate vs Skip

### GENERATE a Skill When

| Scenario | Example |
|----------|---------|
| Repetitive multi-step task | Deploy pipeline, CI/CD |
| Domain knowledge agents lack | Internal API patterns, conventions |
| Multi-step workflow with dependencies | Build → Test → Deploy |
| Gotchas that cause real failures | Package name differences, kernel limitations |
| Project-specific tooling | Custom scripts, internal tools |
| Complex configuration | Helm values, K8s manifests |

### SKIP a Skill When

| Scenario | Why Skip |
|----------|----------|
| Simple one-line task | `git commit` doesn't need a skill |
| Generic knowledge | HTTP, databases, Git |
| One-off script | Not reusable across tasks |
| Already in AGENTS.md | Don't duplicate |
| No gotchas | If nothing non-obvious, it's not a skill |
| Agent handles it well | Test first — only create if agent struggles |

## Decision Tree

```
Is this project-specific knowledge?
├─ NO → Skip (agent already knows)
├─ YES ↓
Is it a single command or simple task?
├─ YES → Put in AGENTS.md
├─ NO ↓
Does it have gotchas or non-obvious steps?
├─ NO → Put in AGENTS.md
├─ YES ↓
Is it reusable across multiple tasks?
├─ NO → Put in AGENTS.md (gotchas section)
├─ YES → Create a skill
```

## Example Decisions

| Knowledge | Decision | Location |
|-----------|----------|----------|
| `npm install` | AGENTS.md | Setup Commands |
| "Use `font-dejavu` not `fonts-dejavu`" | AGENTS.md | Gotchas |
| Helm chart resource profiles | Skill | skills/helm-chart-patterns/ |
| Alpine Docker build with browser ARG | Skill | skills/alpine-desktop-image/ |
| "TypeScript strict mode" | AGENTS.md | Code Style |
| KEDA autoscaling config | Skill | skills/k8s-desktop-deploy/ |
| Cloudflare tunnel error codes | Skill | skills/cloudflare-tunnel-sidecar/ |
| "Run `pytest` to test" | AGENTS.md | Test Commands |
