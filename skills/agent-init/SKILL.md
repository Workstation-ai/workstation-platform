---
name: agent-init
description: "Initialize agent-friendly development in any repository. Analyzes the repo and generates the complete foundation: AGENTS.md (agents.md standard), skills/ directory (agentskills.io standard), and validation. Use when onboarding to a new repo, setting up agent docs, or after major architecture changes. Covers repo analysis, content generation, what NOT to create, and validation."
license: Apache-2.0
compatibility: Requires git, access to repo files. Works with any coding agent that supports AGENTS.md or Agent Skills (Codex, Jules, Cursor, opencode, Aider, goose, Claude Code, Copilot, and 60k+ projects).
metadata:
  author: workstation-ai
  version: "1.0"
---

# Agent Init

Initialize the complete agent development foundation for any repository. This is the single entry point for making a repo agent-friendly.

## What This Generates

| Artifact | Standard | Purpose |
|----------|----------|---------|
| `AGENTS.md` | [agents.md](https://agents.md) | Instructions for coding agents (setup, build, test, style, gotchas) |
| `skills/` | [agentskills.io](https://agentskills.io) | Specialized skills with domain knowledge and workflows |
| Validation | — | Automated checks for both artifacts |

## When to Use

- Onboarding to a new repository with no agent docs
- User says "set up agents for this repo" or "make this repo agent-friendly"
- After major architecture changes that agents should know about
- Repository has outdated or incomplete `AGENTS.md`
- Migrating from another agent system to agents.md/agentskills.io

## Phase 1: Repo Analysis (Read Only)

**Do NOT write anything yet.** Understand the repository first.

### Files to Read

```
□ README.md              — What the project is
□ package.json           — Dependencies, scripts (Node.js)
□ go.mod / Cargo.toml / pyproject.toml / pom.xml / build.gradle  — Language
□ Makefile               — Build commands
□ docker-compose.yml     — Services
□ .github/workflows/     — CI/CD pipeline
□ Helm charts/ or k8s/   — K8s deployment
□ Existing AGENTS.md     — If present, what's missing?
□ Existing skills/       — If present, what exists?
□ src/ or lib/           — Main code structure
□ .env.example           — Configuration
□ .pre-commit-config.yaml — Hooks
```

### Analysis Questions

Answer these before writing. If you can't answer from files, note "needs verification" — don't guess.

| Question | Why |
|----------|-----|
| What language(s)? | Build/test commands |
| What framework(s)? | Architecture description |
| How to install deps? | Setup commands |
| How to build? | Build commands |
| How to test? | Test commands |
| How to run locally? | Dev environment |
| What's the deployment target? | Architecture |
| What are the gotchas? | Gotchas section |
| What conventions exist? | Code style |
| What security concerns? | Security section |

## Phase 2: Generate AGENTS.md

### What AGENTS.md Is

A plain Markdown file at the repo root. No frontmatter. A **README for agents** — predictable place for context and instructions that would clutter a README.

Compatible with: Codex, Jules, Cursor, opencode, Aider, goose, VS Code, Claude Code, Copilot, and 60k+ projects.

### Required Sections

```markdown
# Project Name

One-sentence description.

## Setup Commands

```bash
# Install dependencies
<exact commands>
```

## Build Commands

```bash
# Build the project
<exact commands>
```

## Test Commands

```bash
# Run all tests
<exact commands>
```
```

### Recommended Sections

| Section | When to include |
|---------|----------------|
| `## Code Style` | Linting config, formatting rules, conventions |
| `## Project Structure` | Monorepo or complex layout |
| `## Architecture` | Multi-service or layered systems |
| `## Key Configuration` | Non-obvious env vars, config files, flags |
| `## Skills Reference` | Skills exist in `skills/` |
| `## Security Considerations` | Auth, secrets, sensitive data |
| `## Gotchas` | Non-obvious behaviors, workarounds |

### What NOT to Put in AGENTS.md

| Skip | Use instead |
|------|-------------|
| Project history | CHANGELOG.md |
| Detailed API docs | docs/ directory |
| Contributing guidelines | CONTRIBUTING.md |
| License text | LICENSE file |
| "Write clean code" | (agent already knows) |
| "Follow SOLID" | (agent already knows) |
| Git basics | (agent already knows) |
| What is HTTP | (agent already knows) |

### Template

See [assets/AGENTS-template.md](assets/AGENTS-template.md).

## Phase 3: Generate Skills

### When to Create a Skill

| Create a skill when | Don't create when |
|---------------------|-------------------|
| Repetitive multi-step task | Simple one-line task |
| Domain knowledge agents lack | Generic knowledge |
| Multi-step workflow with deps | Single command |
| Gotchas that cause real failures | Nothing non-obvious |
| Project-specific tooling | Agent handles it well |

### Skill Directory Structure

```
skills/
├── skill-name/
│   ├── SKILL.md          # Required: metadata + instructions
│   ├── scripts/          # Optional: executable code
│   ├── references/       # Optional: detailed docs
│   └── assets/           # Optional: templates, resources
```

### SKILL.md Format

```markdown
---
name: skill-name
description: "What this skill does AND when to use it. Be specific — agents use this to decide activation."
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

## Quick Reference

| Item | Value |
|------|-------|
| Command | `exact command` |

## Step-by-Step Instructions

1. First step with exact command
2. Second step with exact command

## Gotchas

- **Gotcha 1**: Non-obvious behavior and workaround

## Scripts

See [scripts/example.sh](scripts/example.sh).

## References

- `references/deep-dive.md` — When to load: detailed reference
```

### Naming Rules (agentskills.io)

| Rule | Valid | Invalid |
|------|-------|---------|
| Lowercase only | `my-skill` | `My-Skill` |
| Hyphens, no spaces | `my-skill` | `my skill` |
| No consecutive hyphens | `my-skill` | `my--skill` |
| No leading/trailing hyphen | `my-skill` | `-my-skill-` |
| Max 64 chars | `my-skill` | (over 64) |
| Match directory name | `my-skill/SKILL.md` | `other-name/SKILL.md` |

### Description Rules

The `description` field is how agents decide to activate. It must:
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

| Skip | Why |
|------|-----|
| Generic tasks (git, editing) | Agent already handles |
| One-off scripts | Not reusable |
| Documentation for docs/ | Wrong location |
| Configuration files | Use project config |
| Skills without gotchas | Nothing non-obvious = not a skill |

### Progressive Disclosure

Keep `SKILL.md` under 500 lines. Move detailed content to `references/`:

```markdown
For detailed API reference, read [references/api-reference.md](references/api-reference.md).
Load it when: API returns non-200 status.
```

## Phase 4: Validate

Run the validation script:

```bash
bash skills/agent-init/scripts/validate.sh .
```

### Manual Checklist

**AGENTS.md:**
- [ ] Exists at repo root
- [ ] Has Setup, Build, Test commands
- [ ] Commands are copy-pasteable
- [ ] No generic advice
- [ ] Gotchas section covers known issues

**Skills:**
- [ ] Each `SKILL.md` has valid frontmatter
- [ ] `name` matches directory name
- [ ] `name` follows naming rules
- [ ] `description` is specific and keyword-rich
- [ ] `SKILL.md` is under 500 lines
- [ ] Scripts are executable

## Phase 5: Commit

```
docs: initialize agent-friendly development

- AGENTS.md: setup, build, test, architecture, gotchas
- skills/<name>: <brief description>
```

## Reference: Decision Tree

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
