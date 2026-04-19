#!/usr/bin/env bash
# Validate ruleset structure. Runs from the rulesets repo root.
# Checks:
#   - Every .md rule file starts with a top-level heading
#   - Every rule file has an 'Applies to:' header
#   - Every language CLAUDE.md has a top-level heading
#   - Every hook script has a shebang and is executable

set -u

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$REPO_ROOT"

errors=0

warn() {
  printf '  WARN: %s\n' "$1"
  errors=$((errors + 1))
}

check_md_heading() {
  local f="$1"
  [ -f "$f" ] || return 0
  if ! head -1 "$f" | grep -q '^# '; then
    warn "$f — missing top-level heading"
  fi
}

check_md_applies_to() {
  local f="$1"
  [ -f "$f" ] || return 0
  if ! grep -q '^Applies to:' "$f"; then
    warn "$f — missing 'Applies to:' header"
  fi
}

check_hook() {
  local f="$1"
  [ -f "$f" ] || return 0
  if ! head -1 "$f" | grep -q '^#!'; then
    warn "$f — missing shebang"
  fi
  if [ ! -x "$f" ]; then
    warn "$f — not executable (chmod +x)"
  fi
}

echo "Linting rulesets in $REPO_ROOT"

# Generic rules
for f in claude-rules/*.md; do
  [ -f "$f" ] || continue
  check_md_heading "$f"
  check_md_applies_to "$f"
done

# Per-language rule files
for rules_dir in languages/*/claude/rules; do
  [ -d "$rules_dir" ] || continue
  for f in "$rules_dir"/*.md; do
    [ -f "$f" ] || continue
    check_md_heading "$f"
    check_md_applies_to "$f"
  done
done

# Per-language CLAUDE.md templates
for claude_md in languages/*/CLAUDE.md; do
  [ -f "$claude_md" ] || continue
  check_md_heading "$claude_md"
done

# Hook scripts
for h in languages/*/claude/hooks/*.sh languages/*/githooks/*; do
  [ -f "$h" ] || continue
  check_hook "$h"
done

# Shared install/diff/lint scripts (sanity check)
for s in scripts/*.sh; do
  [ -f "$s" ] || continue
  check_hook "$s"
done

echo "---"
if [ "$errors" -eq 0 ]; then
  echo "All checks passed."
else
  echo "$errors warning(s)."
  exit 1
fi
