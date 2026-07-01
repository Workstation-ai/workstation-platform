# Agentskills.io Specification Summary

Source: https://agentskills.io/specification

## Directory Structure

```
skill-name/
├── SKILL.md          # Required: metadata + instructions
├── scripts/          # Optional: executable code
├── references/       # Optional: documentation
├── assets/           # Optional: templates, resources
└── ...               # Any additional files or directories
```

## SKILL.md Frontmatter

| Field | Required | Constraints |
|-------|----------|-------------|
| `name` | Yes | 1-64 chars. Lowercase letters, numbers, hyphens only. No leading/trailing hyphen. No consecutive hyphens. Must match directory name. |
| `description` | Yes | 1-1024 chars. Non-empty. Describes what the skill does AND when to use it. |
| `license` | No | License name or reference to bundled license file. |
| `compatibility` | No | 1-500 chars. Environment requirements (tools, packages, network). |
| `metadata` | No | Arbitrary key-value mapping. |
| `allowed-tools` | No | Space-separated pre-approved tools (experimental). |

## Progressive Disclosure

1. **Metadata** (~100 tokens): `name` and `description` loaded at startup
2. **Instructions** (<5000 tokens recommended): Full `SKILL.md` body loaded on activation
3. **Resources** (as needed): Files in `scripts/`, `references/`, `assets/` loaded on demand

## Name Validation Rules

| Rule | Valid | Invalid |
|------|-------|---------|
| Lowercase only | `my-skill` | `My-Skill` |
| Hyphens, no spaces | `my-skill` | `my skill` |
| No consecutive hyphens | `my-skill` | `my--skill` |
| No leading/trailing hyphen | `my-skill` | `-my-skill-` |
| Max 64 chars | `my-skill` | (over 64) |
| Match directory name | `my-skill/SKILL.md` | `other-name/SKILL.md` |
| No uppercase | `my-skill` | `my-Skill` |
| Numbers allowed | `my-skill-2` | — |

## Description Best Practices

**Good:**
```yaml
description: "Extract text and tables from PDF files, fill PDF forms, and merge multiple PDFs. Use when working with PDF documents or when the user mentions PDFs, forms, or document extraction."
```

**Bad:**
```yaml
description: "Helps with PDFs."
```

Rules:
- Describe what the skill does AND when to use it
- Include specific keywords agents will match
- Be 1-1024 characters
- Don't be vague

## File References

Use relative paths from skill root:

```markdown
See [the reference guide](references/REFERENCE.md) for details.
Run the extraction script: scripts/extract.py
```

Keep references one level deep from SKILL.md. Avoid deeply nested chains.

## Scripts Best Practices

- Self-contained or clearly document dependencies
- Include helpful error messages
- Handle edge cases gracefully
- Make executable: `chmod +x script.sh`

## Validation Tool

```bash
skills-ref validate ./my-skill
```

Requires: https://github.com/agentskills/agentskills/tree/main/skills-ref
