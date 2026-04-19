#!/usr/bin/env bash
# Diff installed rulesets in a target project vs the repo source.
# Usage: diff-lang.sh <language> <project-path>
#
# Walks every file the installer would copy and shows a unified diff for
# any that differ. Files missing in the target are flagged separately.

set -u

LANG="${1:-}"
PROJECT="${2:-}"

if [ -z "$LANG" ] || [ -z "$PROJECT" ]; then
  echo "Usage: $0 <language> <project-path>" >&2
  exit 1
fi

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SRC="$REPO_ROOT/languages/$LANG"

[ -d "$SRC" ]     || { echo "ERROR: no ruleset for '$LANG'" >&2; exit 1; }
[ -d "$PROJECT" ] || { echo "ERROR: project path does not exist: $PROJECT" >&2; exit 1; }
PROJECT="$(cd "$PROJECT" && pwd)"

changed=0
missing=0

compare_file() {
  local src="$1" dst="$2"
  if [ ! -f "$dst" ]; then
    echo "MISSING: $dst"
    missing=$((missing + 1))
    return
  fi
  if ! diff -q "$src" "$dst" >/dev/null 2>&1; then
    echo "--- $src"
    echo "+++ $dst"
    diff -u "$src" "$dst" | tail -n +3
    echo
    changed=$((changed + 1))
  fi
}

echo "Comparing '$LANG' ruleset against $PROJECT"
echo

# Generic rules (claude-rules/*.md → .claude/rules/)
for f in "$REPO_ROOT/claude-rules"/*.md; do
  [ -f "$f" ] || continue
  name="$(basename "$f")"
  compare_file "$f" "$PROJECT/.claude/rules/$name"
done

# Language .claude/ tree
if [ -d "$SRC/claude" ]; then
  while IFS= read -r f; do
    rel="${f#$SRC/claude/}"
    compare_file "$f" "$PROJECT/.claude/$rel"
  done < <(find "$SRC/claude" -type f)
fi

# CLAUDE.md is seed-only (install won't overwrite without FORCE=1), so skip it
# in normal diff output. Users can diff it manually if curious.

# githooks/
if [ -d "$SRC/githooks" ]; then
  while IFS= read -r f; do
    rel="${f#$SRC/githooks/}"
    compare_file "$f" "$PROJECT/githooks/$rel"
  done < <(find "$SRC/githooks" -type f)
fi

echo "---"
if [ "$changed" -eq 0 ] && [ "$missing" -eq 0 ]; then
  echo "No differences."
else
  echo "Summary: $changed differ, $missing missing."
  [ "$changed" -gt 0 ] && exit 1
  [ "$missing" -gt 0 ] && exit 2
fi
