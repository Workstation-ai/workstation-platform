#!/bin/bash
# Validate AGENTS.md and skills/ directory
# Usage: bash validate.sh [repo-root]
set -euo pipefail

REPO="${1:-.}"
ERRORS=0

echo "=== Validating agent docs in $REPO ==="
echo ""

# ── AGENTS.md ──────────────────────────────────────────────────────────
echo "--- AGENTS.md ---"
if [ -f "$REPO/AGENTS.md" ]; then
    echo "  [OK] AGENTS.md exists"

    # Check required sections
    for section in "Setup Commands" "Build Commands" "Test Commands"; do
        if grep -qi "## $section" "$REPO/AGENTS.md"; then
            echo "  [OK] Has '$section'"
        else
            echo "  [WARN] Missing '$section'"
            ERRORS=$((ERRORS + 1))
        fi
    done

    # Check for generic advice (anti-pattern)
    if grep -qi "write clean code\|follow SOLID\|best practices" "$REPO/AGENTS.md"; then
        echo "  [WARN] Contains generic advice — remove non-project-specific content"
        ERRORS=$((ERRORS + 1))
    fi

    LINES=$(wc -l < "$REPO/AGENTS.md")
    echo "  [INFO] $LINES lines"
else
    echo "  [MISSING] AGENTS.md not found"
    ERRORS=$((ERRORS + 1))
fi

echo ""

# ── Skills Directory ───────────────────────────────────────────────────
echo "--- skills/ ---"
if [ -d "$REPO/skills" ]; then
    echo "  [OK] skills/ exists"

    SKILL_COUNT=0
    for skill_md in "$REPO"/skills/*/SKILL.md; do
        [ -f "$skill_md" ] || continue
        SKILL_COUNT=$((SKILL_COUNT + 1))

        skill_dir=$(dirname "$skill_md" | xargs basename)
        echo ""
        echo "  [$skill_dir]"

        # Check name matches directory
        name=$(head -30 "$skill_md" | grep "^name:" | awk '{print $2}' | tr -d '"' | tr -d "'")
        if [ "$name" = "$skill_dir" ]; then
            echo "    [OK] name matches directory"
        else
            echo "    [ERROR] name='$name' doesn't match directory='$skill_dir'"
            ERRORS=$((ERRORS + 1))
        fi

        # Check name format (lowercase, hyphens, no consecutive)
        if echo "$name" | grep -qP '^[a-z0-9]([a-z0-9-]*[a-z0-9])?$'; then
            echo "    [OK] name format valid"
        else
            echo "    [ERROR] name format invalid: must be lowercase, hyphens, no leading/trailing hyphen"
            ERRORS=$((ERRORS + 1))
        fi

        if echo "$name" | grep -q '\-\-'; then
            echo "    [ERROR] name has consecutive hyphens"
            ERRORS=$((ERRORS + 1))
        fi

        # Check description exists and is meaningful
        desc=$(head -30 "$skill_md" | grep "^description:" | sed 's/^description: *//' | tr -d '"' | tr -d "'")
        if [ -n "$desc" ]; then
            desc_len=${#desc}
            if [ "$desc_len" -gt 20 ]; then
                echo "    [OK] description is specific ($desc_len chars)"
            else
                echo "    [WARN] description is too short ($desc_len chars) — be more specific"
                ERRORS=$((ERRORS + 1))
            fi
        else
            echo "    [ERROR] missing description"
            ERRORS=$((ERRORS + 1))
        fi

        # Check SKILL.md length
        skill_lines=$(wc -l < "$skill_md")
        if [ "$skill_lines" -le 500 ]; then
            echo "    [OK] $skill_lines lines (under 500)"
        else
            echo "    [WARN] $skill_lines lines (over 500) — move details to references/"
            ERRORS=$((ERRORS + 1))
        fi

        # Check for scripts/ directory
        if [ -d "$(dirname "$skill_md")/scripts" ]; then
            script_count=$(find "$(dirname "$skill_md")/scripts" -type f | wc -l)
            echo "    [OK] scripts/ has $script_count file(s)"
        fi

        # Check for references/ directory
        if [ -d "$(dirname "$skill_md")/references" ]; then
            ref_count=$(find "$(dirname "$skill_md")/references" -type f | wc -l)
            echo "    [OK] references/ has $ref_count file(s)"
        fi
    done

    echo ""
    echo "  [INFO] $SKILL_COUNT skill(s) found"
else
    echo "  [MISSING] skills/ not found"
fi

echo ""

# ── Summary ────────────────────────────────────────────────────────────
echo "=== Summary ==="
if [ "$ERRORS" -eq 0 ]; then
    echo "All checks passed."
else
    echo "$ERRORS issue(s) found. Review above."
fi

exit $ERRORS
