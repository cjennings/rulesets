#!/usr/bin/env bash
# Validate ruleset structure. Runs from the rulesets repo root.
# Checks:
#   - Every .md rule file starts with a top-level heading
#   - Every rule file has an 'Applies to:' header
#   - Every language CLAUDE.md has a top-level heading
#   - Every hook script has a shebang and is executable
#   - Every cross-reference to claude-rules/ from a SKILL.md or
#     claude-rules/*.md resolves to a real file (catches the install-layout
#     drift that the bridge symlink fixes)

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

check_md_links() {
  # Validate cross-references to claude-rules/ — the install-layout problem
  # solved by the bridge symlink in `make install`. Doesn't validate
  # example file names that skills cite illustratively (e.g. ADR templates,
  # arc42 section files), which are intentionally not real source files.
  local f="$1"
  [ -f "$f" ] || return 0
  local dir
  dir="$(dirname "$f")"
  while IFS= read -r link; do
    local url="${link##*\(}"
    url="${url%\)}"
    case "$url" in
      *claude-rules/*) ;;
      *) continue ;;
    esac
    url="${url%%#*}"
    url="${url%%\?*}"
    local resolved
    resolved="$(cd "$dir" 2>/dev/null && readlink -m "$url" 2>/dev/null)"
    if [ -z "$resolved" ] || [ ! -e "$resolved" ]; then
      warn "$f — broken claude-rules link: $url"
    fi
  done < <(grep -oE '\[[^]]*\]\([^)]+\)' "$f" 2>/dev/null || true)
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

# Markdown link validation across rules and skills
for f in claude-rules/*.md */SKILL.md; do
  [ -f "$f" ] || continue
  check_md_links "$f"
done

echo "---"
if [ "$errors" -eq 0 ]; then
  echo "All checks passed."
else
  echo "$errors warning(s)."
  exit 1
fi
