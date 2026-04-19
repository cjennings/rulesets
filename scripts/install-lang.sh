#!/usr/bin/env bash
# Install a language ruleset into a target project.
# Usage: install-lang.sh <language> <project-path> [force]
#
# Copies the language's ruleset files into the project. Re-runnable
# (authoritative source overwrites). CLAUDE.md is preserved unless
# force=1, to avoid trampling project-specific customizations.

set -euo pipefail

LANG="${1:-}"
PROJECT="${2:-}"
FORCE="${3:-}"

if [ -z "$LANG" ] || [ -z "$PROJECT" ]; then
  echo "Usage: $0 <language> <project-path> [force]" >&2
  exit 1
fi

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SRC="$REPO_ROOT/languages/$LANG"

if [ ! -d "$SRC" ]; then
  echo "ERROR: no ruleset for language '$LANG' (expected $SRC)" >&2
  exit 1
fi

if [ ! -d "$PROJECT" ]; then
  echo "ERROR: project path does not exist: $PROJECT" >&2
  exit 1
fi

# Resolve to absolute path
PROJECT="$(cd "$PROJECT" && pwd)"

echo "Installing '$LANG' ruleset into $PROJECT"

# 1. Generic rules from claude-rules/ (shared across all languages)
if [ -d "$REPO_ROOT/claude-rules" ]; then
  mkdir -p "$PROJECT/.claude/rules"
  cp "$REPO_ROOT/claude-rules"/*.md "$PROJECT/.claude/rules/" 2>/dev/null || true
  count=$(ls -1 "$REPO_ROOT/claude-rules"/*.md 2>/dev/null | wc -l)
  echo "  [ok] .claude/rules/ — $count generic rule(s) from claude-rules/"
fi

# 2. .claude/ — language-specific rules, hooks, settings (authoritative, always overwrite)
if [ -d "$SRC/claude" ]; then
  mkdir -p "$PROJECT/.claude"
  cp -rT "$SRC/claude" "$PROJECT/.claude"
  if [ -d "$PROJECT/.claude/hooks" ]; then
    find "$PROJECT/.claude/hooks" -type f -name '*.sh' -exec chmod +x {} \;
  fi
  echo "  [ok] .claude/ — language-specific content"
fi

# 2. githooks/ — pre-commit etc.
if [ -d "$SRC/githooks" ]; then
  mkdir -p "$PROJECT/githooks"
  cp -rT "$SRC/githooks" "$PROJECT/githooks"
  find "$PROJECT/githooks" -type f -exec chmod +x {} \;
  if [ -d "$PROJECT/.git" ]; then
    git -C "$PROJECT" config core.hooksPath githooks
    echo "  [ok] githooks/ installed, core.hooksPath=githooks"
  else
    echo "  [ok] githooks/ installed (not a git repo — skipped core.hooksPath)"
  fi
fi

# 3. CLAUDE.md — seed on first install, don't overwrite unless FORCE=1
if [ -f "$SRC/CLAUDE.md" ]; then
  if [ -f "$PROJECT/CLAUDE.md" ] && [ "$FORCE" != "1" ]; then
    echo "  [skip] CLAUDE.md already exists (use FORCE=1 to overwrite)"
  else
    cp "$SRC/CLAUDE.md" "$PROJECT/CLAUDE.md"
    echo "  [ok] CLAUDE.md installed"
  fi
fi

# 4. .gitignore — append missing lines (deduped, skip comments)
if [ -f "$SRC/gitignore-add.txt" ]; then
  touch "$PROJECT/.gitignore"
  header="# --- $LANG ruleset ---"
  added=0
  while IFS= read -r line || [ -n "$line" ]; do
    # Skip blank lines and comments in the source file
    [ -z "$line" ] && continue
    case "$line" in \#*) continue ;; esac
    # Only add if not already present
    if ! grep -qxF "$line" "$PROJECT/.gitignore"; then
      # Prepend header only if it isn't already in the file
      if [ "$added" -eq 0 ] && ! grep -qxF "$header" "$PROJECT/.gitignore"; then
        printf '\n%s\n' "$header" >> "$PROJECT/.gitignore"
      fi
      echo "$line" >> "$PROJECT/.gitignore"
      added=$((added + 1))
    fi
  done < "$SRC/gitignore-add.txt"
  if [ "$added" -gt 0 ]; then
    echo "  [ok] .gitignore: $added line(s) added"
  else
    echo "  [skip] .gitignore entries already present"
  fi
fi

echo ""
echo "Install complete."
