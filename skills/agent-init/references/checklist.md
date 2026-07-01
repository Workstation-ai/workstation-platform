# Skill Creation Checklist

Use this checklist when creating a new skill for any repository.

## Before Creating

- [ ] Read existing `skills/` — don't duplicate
- [ ] Read `AGENTS.md` — understand project context
- [ ] Identify the **trigger**: what task makes agents load this skill?
- [ ] Identify the **gotchas**: what will agents get wrong without this?
- [ ] Verify the knowledge: run the task yourself, note what works

## SKILL.md Creation

- [ ] Directory name: lowercase, hyphens, matches `name` field
- [ ] Frontmatter has `name` and `description` (required)
- [ ] `name` is 1-64 chars, matches directory
- [ ] `description` is 1-1024 chars, specific and keyword-rich
- [ ] Body has: overview, when-to-use, step-by-step instructions
- [ ] Body has: gotchas section with non-obvious issues
- [ ] Body is under 500 lines
- [ ] Detailed content moved to `references/` if long

## Scripts (if applicable)

- [ ] Scripts in `scripts/` are executable (`chmod +x`)
- [ ] Scripts handle errors gracefully
- [ ] Scripts have helpful error messages
- [ ] Scripts are self-contained or document dependencies

## References (if applicable)

- [ ] Reference files are focused (one topic each)
- [ ] SKILL.md tells agents WHEN to load each reference
- [ ] References use relative paths from skill root

## Validation

- [ ] `bash skills/skill-factory/scripts/validate.sh .` passes
- [ ] Skill activates on relevant prompts (test it)
- [ ] Skill doesn't activate on irrelevant prompts (no false positives)

## What NOT to Create

- [ ] NOT a skill for generic tasks (git, file editing)
- [ ] NOT a skill for one-off scripts
- [ ] NOT a skill without gotchas (if nothing non-obvious, skip it)
- [ ] NOT a skill that duplicates AGENTS.md content
- [ ] NOT a skill with generic advice ("write clean code")
