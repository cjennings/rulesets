---
name: finish-branch
description: Complete a feature branch with a forced-choice menu of outcomes (merge locally / push + open PR / keep as-is / discard). Runs verification before offering options (tests, lint, typecheck per the project's conventions — delegates to `verification.md`). Requires typed confirmation for destructive deletion (no accidental work loss). Handles git worktree cleanup correctly: tears down for merge and discard, preserves for keep and push (where the worktree may still be needed for follow-up review or fixes). References existing rules for commit conventions (`commits.md`), review discipline (`review-code`), and verification (`verification.md`) — this skill is the workflow scaffold, not a re-teach of the underlying standards. Use when implementation is complete and you need to wrap up a branch. Do NOT use for mid-development merges (that's normal git flow), for the wrap-up *of a whole session* (different scope — session-end is narrative + handoff, not branch integration), for creating a new branch (no skill for that — just `git checkout -b`), or when review hasn't happened yet (run `/review-code` first, then this).
---

# /finish-branch

Complete a development branch cleanly. Verify, pick one of four outcomes, execute, clean up.

## When to Use

- Implementation is done, tests are written, you believe the branch is ready to move forward
- You're about to ask "okay, now what?" — this skill exists to stop you asking and start you choosing
- You need to integrate, preserve, or discard a branch's work deliberately

## When NOT to Use

- Mid-development merges — that's regular git flow, not "finishing" a branch
- Full session wrap-up (closing the day's work, recording context for next time) — different scope, not about branch integration
- Creating a new branch — just `git checkout -b <name>`
- Before review has happened on a significant change — run `/review-code` first; this skill assumes the work has been judged ready

## Phase 1 — Verify

Before offering any option, run the project's verification. Delegate to `verification.md` discipline:

- Tests pass (full suite, not just the last one you wrote)
- Linter clean (no new warnings)
- Type checker clean (no new errors)
- Staged diff matches intent (no accidental additions)

Commands vary by stack. Use what the project's Makefile, `package.json` scripts, or convention dictates. Examples:

- JavaScript / TypeScript: `npm test && npm run lint && npx tsc --noEmit`
- Python: `pytest && ruff check . && pyright`
- Go: `go test ./... && go vet ./... && golangci-lint run`
- Elisp: `make test && make validate-parens && make validate-modules`

**If verification fails:** stop. Report the failures with file:line, do not offer the outcome menu. The branch isn't finished — fix the failures and re-invoke `/finish-branch`.

**If verification passes:** continue to Phase 2.

## Phase 2 — Determine Base Branch

The four outcomes need to know what the branch is being integrated into. Find the base:

```bash
git merge-base HEAD main 2>/dev/null \
  || git merge-base HEAD master 2>/dev/null \
  || git merge-base HEAD develop 2>/dev/null
```

If none resolves, ask: "I couldn't find a merge base against `main`, `master`, or `develop`. What's the base branch for this work?" Don't guess.

Also collect:
- Current branch name: `git branch --show-current`
- Commit range to integrate: `git log <base>..HEAD --oneline`
- Unpushed commits on the remote: `git log @{u}..HEAD` if the branch tracks a remote, otherwise all commits are local
- Whether the current directory is in a git worktree: `git worktree list | grep $(git branch --show-current)`

These details feed the outcome prompt and the execution phases.

## Phase 3 — Offer the Menu

Present exactly these four options. Don't editorialize. Don't add a "recommendation." The user picks.

```
Branch <branch-name> is ready. It has N commits on top of <base-branch>.

What would you like to do?

1. Merge locally into <base-branch>     (integrate now, delete the branch)
2. Push and open a Pull Request          (remote integration flow)
3. Keep as-is                             (preserve branch and worktree for later)
4. Discard                                (delete branch and commits — requires confirmation)

Pick a number.
```

If the branch already has a remote and the user chose 1 (merge locally), note: "The branch is pushed to `origin/<branch-name>`. After merging locally, do you also want to delete the remote branch?" Ask; don't assume.

**Stop and wait for the answer.** Don't guess, don't infer from context, don't proceed to Phase 4 until the user picks.

## Phase 4 — Execute the Chosen Outcome

### Option 1 — Merge Locally

```bash
git checkout <base-branch>
git pull                              # ensure base is current
git merge --no-ff <branch-name>       # --no-ff preserves the branch point in history
```

**Re-verify the merged result.** Run tests / lint / type check on the merged state — the merge may have integrated cleanly at the text level while breaking semantically.

If verification passes:
```bash
git branch -d <branch-name>           # safe delete (refuses unmerged branches, which this one is merged)
```

If the branch had a remote:
- If user confirmed removing the remote: `git push origin --delete <branch-name>`
- Otherwise: leave the remote branch, note that the user should clean it up manually

Clean up the worktree (Phase 5).

### Option 2 — Push and Open a Pull Request

```bash
git push -u origin <branch-name>      # -u sets upstream on first push
```

Open the PR. Use the project's `gh` CLI (install via `deps` target if missing):

```bash
gh pr create \
  --base <base-branch> \
  --title "<subject from the most recent commit, or user-provided>" \
  --body "$(cat <<'EOF'
## Summary

<two or three bullets summarizing what changed, pulled from the commit range>

## Test Plan

- [ ] <steps the reviewer should take to verify>
EOF
)"
```

**Commit message and PR body discipline:** no AI attribution, no "🤖 Generated with" footer, conventional message style — see `commits.md`. If the project has a `.github/pull_request_template.md`, use it instead of the template above.

**Do NOT clean up the worktree.** The branch is not yet merged; you may need the worktree for reviewer feedback, fixes, or rebase. (Phase 5 table.)

### Option 3 — Keep As-Is

No git state changes. Report:

```
Keeping branch <branch-name> as-is.
Worktree preserved at <worktree-path> (or "same working directory" if not a worktree).
Resume later with `git checkout <branch-name>` or re-invoke `/finish-branch`.
```

**Do NOT clean up the worktree.** The user explicitly wants to come back.

### Option 4 — Discard

**Confirmation gate — required.** Write out what will be permanently lost:

```
Discarding will permanently delete:

- Branch: <branch-name>
- Commits that exist only on this branch (N commits):
    <list, abbreviated if very long>
- Worktree at <worktree-path> (if applicable)
- Remote branch origin/<branch-name> (if it exists)

This cannot be undone via `git checkout` — only via the reflog (≤30 days by default).

To proceed, type exactly: discard
```

**Wait for the user to type the literal word `discard`.** Anything else — "yes," "y," "confirm," a number — does not qualify. Re-prompt.

If confirmed:

```bash
git checkout <base-branch>
git branch -D <branch-name>                           # force delete
git push origin --delete <branch-name> 2>/dev/null    # delete remote if it exists; ignore error if not
```

Clean up the worktree (Phase 5).

## Phase 5 — Worktree Cleanup

| Option | Cleanup worktree? |
|---|---|
| 1. Merge locally | **Yes** |
| 2. Push + PR | **No** (may still be needed for review feedback) |
| 3. Keep as-is | **No** (user explicitly wants it) |
| 4. Discard | **Yes** |

**If cleanup applies:**

```bash
git worktree list                                     # confirm you're in a worktree
git worktree remove <worktree-path>                   # non-destructive if clean
```

If `git worktree remove` refuses (unclean state somehow): surface the reason to the user. Don't force removal without their consent — a dirty worktree may contain work they intended to rescue.

**If no cleanup:** done. Report final state.

## Output

Short final report, not a celebration:

```
Branch <branch-name>:
  - Outcome: <1 | 2 | 3 | 4>
  - <specific state change, e.g. "merged into main; branch deleted; worktree removed">
  - Next: <what the user would do next — e.g. "await PR review", "resume work", "start a new branch">
```

No emojis. No "🎉 all done!" No AI attribution. See `commits.md`.

## Critical Rules

**DO:**
- Run verification before offering the outcome menu. No exceptions.
- Present exactly four options, clearly labeled. The forced choice is the point.
- Require the literal word `discard` for Option 4.
- Re-verify after a merge (Option 1) — merges can integrate textually while breaking semantically.
- Clean up worktrees only for Options 1 and 4.

**DON'T:**
- Offer options with failing verification — the branch isn't finished.
- Editorialize the menu ("you should probably do option 2"). The user picks.
- Accept "y" or "yes" for the discard gate. Literal word `discard`.
- Clean up worktrees after Option 2 or 3 — the user needs them.
- Add AI attribution to commit messages, PR descriptions, or output.

## Common Mistakes This Prevents

- **Open-ended "what now?" at the end of work.** Natural but corrosive — the user either has to improvise the workflow or restate their preference each time. The four-option menu ends the improvisation.
- **Accidental destructive deletes.** "Discard this branch?" → "y" → 3 days of work gone. The typed-word gate turns one muscle-memory keystroke into a deliberate action.
- **Merge-then-oops.** Text-level merge completes; semantic integration is broken; the user didn't notice because they didn't re-run the tests on the merged result. Phase 4 Option 1 re-verifies.
- **Worktree amnesia.** Cleaning up a worktree after Option 2 (push + PR) means losing local state just when the reviewer asks for a fix. The cleanup matrix keeps the worktree exactly when it's still needed.
- **"Generated by Claude Code" trailing into a PR.** The no-attribution rule from `commits.md` applies here too — the PR body is committed content under the project's identity, not Claude's.

## Integration with Other Skills

**Before this skill:**
- `/review-code` — run a review on the branch before finishing it for significant changes
- `/arch-evaluate` — if the branch touches architecture, audit against `.architecture/brief.md`

**After this skill:**
- If Option 2 (PR opened): reviewer feedback comes in → address → `/finish-branch` again on updated state
- If Option 1 (merged locally): branch is done; if this closes a ticket / ADR, update tracking
- If Option 3 (kept): resume later; re-invoke when ready
- If Option 4 (discarded): often paired with `/brainstorm` or `/arch-design` to retry the problem differently

**Companion rules (not skills) this skill defers to rather than re-teaching:**
- Verification discipline → `verification.md`
- Commit message conventions + no AI attribution → `commits.md`
- Review discipline (for anything pre-merge) → `review-code`
