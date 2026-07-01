---
name: skill-factory
description: "Analyze any repository and generate AGENTS.md + skills/ directory following agents.md and agentskills.io standards. Use when onboarding to a new repo, setting up agent-friendly documentation, or creating skills from discovered patterns. Covers repo analysis, content generation, validation, and what NOT to create."
license: Apache-2.0
compatibility: Requires git, access to repo files. Works with any coding agent that supports AGENTS.md or Agent Skills.
metadata:
  author: workstation-ai
  version: "1.0"
---

# Skill Factory

Generate agent-friendly documentation for any repository: `AGENTS.md` (agents.md standard) and `skills/` directory (agentskills.io standard).

## When to Use

- Onboarding to a new repository
- User asks to "set up agent docs" or "create skills for this repo"
- Repository has no `AGENTS.md` or `skills/` directory
- After major architecture changes that agents should know about

## Phase 1: Repo Analysis (Read Only)

Before writing anything, understand the repository. Read these files first:

```
□ README.md          — What the project is
□ package.json       — Dependencies, scripts (Node.js)
□ go.mod / Cargo.toml / pyproject.toml / pom.xml  — Language-specific
□ Makefile           — Build commands
□ docker-compose.yml — Services
□ .github/workflows/ — CI/CD pipeline
□ Helm charts/       — K8s deployment
□ Existing AGENTS.md — If present, what's missing?
□ skills/            — If present, what exists?
□ src/ or lib/       — Main code structure
```

### Analysis Checklist

Answer these questions before writing:

| Question | Why it matters |
|----------|---------------|
| What language(s)? | Build/test commands |
| What framework(s)? | Architecture description |
| How to install deps? | Setup commands section |
| How to build? | Build commands section |
| How to test? | Test commands section |
| How to run locally? | Dev environment tips |
| What's the deployment target? | Architecture section |
| What are the gotchas? | Gotchas section |
| What conventions exist? | Code style section |
| What security concerns? | Security section |

If you can't answer a question from reading files, note it as "needs verification" — don't guess.

## Phase 2: Generate AGENTS.md

### Format (agents.md standard)

AGENTS.md is plain Markdown at the repo root. No frontmatter, no special syntax. Structure it with sections that help agents work effectively.

### Required Sections

```markdown
# Project Name

One-sentence description of what this project is.

## Setup Commands

```bash
# Install dependencies
<exact commands>

# Start dev server
<exact commands>
```

## Build Commands

```bash
# Build the project
<exact commands>

# Build for production
<exact commands>
```

## Test Commands

```bash
# Run all tests
<exact commands>

# Run specific test
<exact commands>

# Run linter
<exact commands>
```
```

### Recommended Sections (add if relevant)

| Section | When to include |
|---------|----------------|
| `## Code Style` | Project has linting config, formatting rules, or conventions |
| `## Project Structure` | Monorepo or complex directory layout |
| `## Architecture` | Multiple services, layers, or components |
| `## Key Configuration` | Important env vars, config files, or flags |
| `## Skills Reference` | Skills exist in `skills/` directory |
| `## Security Considerations` | Auth, secrets, network policies, or sensitive data |
| `## Gotchas` | Non-obvious behaviors, known issues, workarounds |

### What NOT to Put in AGENTS.md

- **Project history** or changelog (use CHANGELOG.md)
- **Detailed API docs** (use docs/ directory)
- **Contributing guidelines** (use CONTRIBUTING.md)
- **License text** (use LICENSE file)
- **Generic programming advice** ("write clean code", "follow SOLID")
- **What the agent already knows** (HTTP, databases, Git basics)

### Template

See [assets/AGENTS-template.md](assets/AGENTS-template.md) for a complete template.

## Phase 3: Generate Skills

### When to Create a Skill

Create a skill when:
- There's a **repetitive task** agents do (deploy, test, lint)
- There's **domain knowledge** agents lack (internal APIs, conventions)
- There's a **multi-step workflow** that must be followed precisely
- There are **gotchas** that agents will hit without guidance

Don't create a skill when:
- The task is simple enough for AGENTS.md instructions
- The agent already handles it well
- The knowledge is generic (not project-specific)

### Skill Directory Structure

```
skills/
├── skill-name/
│   ├── SKILL.md          # Required: metadata + instructions
│   ├── scripts/          # Optional: executable code
│   ├── references/       # Optional: detailed documentation
│   └── assets/           # Optional: templates, resources
```

### SKILL.md Format

```markdown
---
name: skill-name
description: "What this skill does and when to use it. Be specific — agents use this to decide activation."
license: Apache-2.0
compatibility: Requires <specific tools or environment>
metadata:
  author: <org-or-author>
  version: "1.0"
---

# Skill Title

One paragraph: what this skill enables.

## When to Use

- Specific trigger scenario 1
- Specific trigger scenario 2
- Specific trigger scenario 3

## Quick Reference

| Item | Value |
|------|-------|
| Command | `exact command` |
| Config | `path/to/config` |
| Default | `value` |

## Step-by-Step Instructions

1. First step with exact command
2. Second step with exact command
3. Validation step

## Gotchas

- **Gotcha 1**: Description of non-obvious behavior and workaround
- **Gotcha 2**: Description of another gotcha

## Scripts

See [scripts/example.sh](scripts/example.sh) for the automation script.

## References

- `references/deep-dive.md` — When to load: detailed technical reference
```

### Skill Naming Rules (agentskills.io spec)

| Rule | Valid | Invalid |
|------|-------|---------|
| Lowercase only | `my-skill` | `My-Skill` |
| Hyphens, no spaces | `my-skill` | `my skill` |
| No consecutive hyphens | `my-skill` | `my--skill` |
| No leading/trailing hyphen | `my-skill` | `-my-skill-` |
| Max 64 chars | `my-skill` | (over 64) |
| Match directory name | `my-skill/SKILL.md` | `other-name/SKILL.md` |

### Description Writing Rules

The `description` field is how agents decide to activate your skill. It must:
- Describe what the skill does AND when to use it
- Include specific keywords agents will match
- Be 1-1024 characters

**Good:**
```yaml
description: "Build Alpine Docker images with browser selection, supervisord, and nginx. Use when creating desktop container images for Kubernetes."
```

**Bad:**
```yaml
description: "Helps with Docker."
```

### What NOT to Create as a Skill

- **Generic tasks** the agent already handles (git commit, file editing)
- **One-off scripts** that aren't reusable
- **Documentation** that belongs in `docs/` directory
- **Configuration files** (use project config instead)
- **Skills without gotchas** — if there's nothing non-obvious, it's not a skill

### Progressive Disclosure

Keep `SKILL.md` under 500 lines. Move detailed content to `references/`:

```markdown
## Deep Dive

For detailed API reference, read [references/api-reference.md](references/api-reference.md).
Tell the agent WHEN to load it: "Read references/api-reference.md if the API returns non-200."
```

## Phase 4: Validate

### AGENTS.md Validation

- [ ] File exists at repo root
- [ ] Has Setup, Build, Test commands
- [ ] Commands are copy-pasteable (not vague)
- [ ] No generic advice (only project-specific)
- [ ] Gotchas section covers known issues

### Skills Validation

- [ ] Each skill has `SKILL.md` with valid frontmatter
- [ ] `name` matches directory name
- [ ] `name` follows naming rules (lowercase, hyphens, no consecutive)
- [ ] `description` is specific and keyword-rich
- [ ] `SKILL.md` is under 500 lines
- [ ] Detailed content moved to `references/` if long
- [ ] Scripts in `scripts/` are executable (`chmod +x`)
- [ ] File references use relative paths

### Quick Validation Script

```bash
# Check AGENTS.md exists
test -f AGENTS.md && echo "OK: AGENTS.md exists" || echo "MISSING: AGENTS.md"

# Check skills directory
test -d skills && echo "OK: skills/ exists" || echo "MISSING: skills/"

# Validate skill frontmatter
for skill in skills/*/SKILL.md; do
  name=$(head -20 "$skill" | grep "^name:" | awk '{print $2}')
  dir=$(dirname "$skill" | xargs basename)
  if [ "$name" = "$dir" ]; then
    echo "OK: $skill"
  else
    echo "MISMATCH: $skill (name=$name, dir=$dir)"
  fi
done
```

## Phase 5: Commit

Commit message format:

```
docs: add AGENTS.md and skills for agent-friendly development

- AGENTS.md: setup, build, test, architecture, gotchas
- skills/<name>: <brief description>
```

## Reference: Existing Skills in This Repo

Before creating new skills, check if similar skills exist:

| Skill | Trigger | Covers |
|-------|---------|--------|
| [alpine-desktop-image](../alpine-desktop-image/SKILL.md) | build image, dockerfile | Alpine image build |
| [cloudflare-tunnel-sidecar](../cloudflare-tunnel-sidecar/SKILL.md) | tunnel, cloudflare | Tunnel setup |
| [k3s-cluster-setup](../k3s-cluster-setup/SKILL.md) | k3s, cluster | k3s installation |
| [k8s-desktop-deploy](../k8s-desktop-deploy/SKILL.md) | deploy desktop | K8s deployment |
| [helm-chart-patterns](../helm-chart-patterns/SKILL.md) | helm chart | Chart conventions |
| [freestyle-vm-management](../freestyle-vm-management/SKILL.md) | freestyle | Freestyle.sh VMs |
| [popeye-cluster-diagnostics](../popeye-cluster-diagnostics/SKILL.md) | popeye, health | Cluster scanning |
| [longhorn-distributed-storage](../longhorn-distributed-storage/SKILL.md) | longhorn, storage | PVC storage |

Don't duplicate existing skills — extend them if needed.
