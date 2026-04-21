# Global Hooks

Machine-wide Claude Code hooks that install into `~/.claude/hooks/` and apply to every project on this machine. These complement the per-project hooks installed by language bundles (e.g., `languages/elisp/claude/hooks/validate-el.sh`).

## What's here

| Hook | Trigger | Purpose |
|---|---|---|
| `precompact-priorities.sh` | `PreCompact` | Injects a priority-preservation block into Claude's compaction prompt so the generated summary retains information most expensive to reconstruct (unanswered questions, root causes with `file:line`, subagent findings, exact numbers/IDs, A-vs-B decisions, open TODOs, classified-data handling). |
| `git-commit-confirm.py` | `PreToolUse(Bash)` | Silent-unless-suspicious gate on `git commit`. Only prompts when the message contains AI-attribution patterns, the message can't be parsed (editor would open), no files are staged, or the git author is unusable. Clean commits pass through without a modal. Parses both HEREDOC and `-m`/`--message` forms. |
| `gh-pr-create-confirm.py` | `PreToolUse(Bash)` | Gates `gh pr create` behind a confirmation modal showing title, base←head, reviewers, labels, assignees, milestone, draft flag, and body (HEREDOC or quoted). |
| `destructive-bash-confirm.py` | `PreToolUse(Bash)` | Gates destructive commands (`git push --force`, `git reset --hard`, `git clean -f`, `git branch -D`, `rm -rf`) with a modal showing the command, local context (branch, uncommitted file counts, targeted paths), and a warning banner. Elevates severity when force-pushing protected branches or targeting root/home/wildcard paths. |

Shared library (not a hook): `_common.py` — `read_payload()`, `respond_ask()`, `scan_attribution()`. Installed as a sibling symlink so the two Python hooks can `from _common import …` at runtime.

Both confirm hooks emit a `systemMessage` warning alongside the confirmation modal when they detect AI-attribution patterns (`Co-Authored-By: Claude`, 🤖, "Generated with Claude Code", etc.) in the commit message or PR title/body — useful as an automated policy check for environments where AI credit is forbidden.

## Install

### One-liner (from this repo)

```bash
make -C ~/code/rulesets install-hooks
```

That symlinks each hook into `~/.claude/hooks/` and prints the `settings.json` snippet you need to merge into `~/.claude/settings.json` to wire them up.

### Manual install

```bash
mkdir -p ~/.claude/hooks
ln -sf ~/code/rulesets/hooks/precompact-priorities.sh ~/.claude/hooks/precompact-priorities.sh
ln -sf ~/code/rulesets/hooks/git-commit-confirm.py   ~/.claude/hooks/git-commit-confirm.py
ln -sf ~/code/rulesets/hooks/gh-pr-create-confirm.py ~/.claude/hooks/gh-pr-create-confirm.py
```

Then merge into `~/.claude/settings.json`:

```json
{
  "hooks": {
    "PreCompact": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "~/.claude/hooks/precompact-priorities.sh"
          }
        ]
      }
    ],
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "command",
            "command": "~/.claude/hooks/git-commit-confirm.py"
          },
          {
            "type": "command",
            "command": "~/.claude/hooks/gh-pr-create-confirm.py"
          }
        ]
      }
    ]
  }
}
```

Note: if `~/.claude/settings.json` already has `hooks` entries, merge arrays rather than replacing them. Both `git-commit-confirm.py` and `gh-pr-create-confirm.py` are safe to run on every `Bash` tool call — they no-op on anything that isn't their target command.

## Verify

After installing + reloading Claude Code (or using `/hooks` to reload):

```bash
# Test git commit gating
echo '{"tool_name":"Bash","tool_input":{"command":"git commit -m \"test\""}}' \
  | ~/.claude/hooks/git-commit-confirm.py

# Test gh pr create gating
echo '{"tool_name":"Bash","tool_input":{"command":"gh pr create --title test --body body"}}' \
  | ~/.claude/hooks/gh-pr-create-confirm.py

# Test precompact block (just prints the rules)
~/.claude/hooks/precompact-priorities.sh | head -20
```

Each should produce JSON output (the first two) or markdown (the third).

## Per-project vs global

These three live in `~/.claude/hooks/` because they're editor-agnostic and language-agnostic — you want them firing on every project. Per-language hooks (like `validate-el.sh` for Elisp or future equivalents for Python / TypeScript / Go) live in `languages/<lang>/claude/hooks/` and install *per-project* via `make install-<lang> PROJECT=<path>`.

## Hook output contract

The Python hooks emit JSON to stdout with `hookSpecificOutput`:

- `hookEventName: "PreToolUse"`
- `permissionDecision: "ask"`
- `permissionDecisionReason: "<formatted modal text>"`

Claude Code reads that and surfaces the modal to the user before running the tool. If the user declines, the tool call is cancelled. If they accept, it proceeds normally.

The PreCompact hook emits markdown prose to stdout, which Claude Code appends to the default compaction prompt before generating the summary.

## Dependencies

- `python3` — for the two Python hooks (any modern version; stdlib only)
- `bash` — for `precompact-priorities.sh`
- `git` — the commit hook queries `git diff --cached` and `git config user.name` / `user.email`
- No external Python packages required

## Sources

- PreCompact priority-preservation pattern + git/gh confirmation modal pattern: clean-room synthesis from fcakyon's `claude-codex-settings` (Apache-2.0), extended and adapted. See `docs/architecture/v2-todo.org` or skill-evaluation memory for context.
- Each hook is original content; patterns are ideas, not copied prose.
