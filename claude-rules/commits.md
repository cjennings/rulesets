# Commit Rules

Applies to: `**/*`

## Author Identity

All commits are authored as the user (repo owner / maintainer), never as
Claude, Claude Code, Anthropic, or any AI tool. Git uses the configured
`user.name` and `user.email` — do not modify git config to attribute
otherwise.

## No AI Attribution — Anywhere

Absolutely no AI/LLM/Claude/Anthropic attribution in:

- Commit messages (subject or body)
- PR descriptions and titles
- Issue comments and reviews
- Code comments
- Commit trailers
- Release notes, changelogs, and any public-facing artifact

This means:

- **No** `Co-Authored-By: Claude …` (or Claude Code, or any AI) trailers
- **No** "Generated with Claude Code" footers or equivalents
- **No** 🤖 emojis or similar markers implying AI authorship
- **No** references to "Claude", "Anthropic", "LLM", "AI tool" as a credited contributor
- **No** attribution added via template defaults — strip them before committing

If a tool, template, or default config inserts attribution, remove it. If
settings.json needs it, set `attribution.commit: ""` and `attribution.pr: ""`
to suppress the defaults.

## Commit Message Format

Conventional prefixes:

- `feat:` — new feature
- `fix:` — bug fix
- `refactor:` — code restructuring, no behavior change
- `test:` — adding or updating tests
- `docs:` — documentation only
- `chore:` — build, tooling, meta

Subject line ≤72 characters. Body explains the *why* when not obvious.
Skip the body entirely when the subject line is self-explanatory.

Do not hard-wrap body lines. Write each paragraph and each bullet as a
single logical line and let the renderer (GitHub, Linear, `git log`) soft-
wrap. Hard wraps shrink the visible render width in web UIs and cause
awkward mid-sentence breaks. The subject-line limit still applies to line
1. The same rule applies to PR bodies.

Commit messages describe what changed and why, not the process that
produced the change. Do not reference code review, linting, test runs, or
other workflow steps in the body (e.g. "from local review," "review
surfaced," "flagged by reviewer"). Reviewers and future archaeologists
want the what and the why; how you got there belongs in the PR
discussion, not the commit.

## Voice and Focus

Applies to commit bodies, PR descriptions, and any longer-form prose in
PR comments.

Write in the user's voice. First person when it fits ("I added X", "I
retyped Y") reads like a person making a change. "This PR introduces X"
or "This change restores Y" read as press-release self-narration. The
commit *is* the change — don't announce it. When another author's prior
work is the subject, name them ("Kostya's PR #116 did X"); otherwise
skip the self-reference.

Focus on what was wrong and what was corrected. Not the mechanics.
Readers skimming `git log` or a PR want the before-state, the
after-state, and the reason. They don't need a TypeScript-variance
lesson, a compiler-inference walkthrough, or a trip through an API's
internals. Keep the "why" to one sentence unless a subtle invariant
genuinely needs more.

Don't stack technical terms. A sentence that chains three or more type
signatures, API names, or compiler concepts reads as a jargon wall.
Break it into shorter sentences and translate to reader-facing
language. "The mock returns `Promise<Mission>`, so the resolver's
argument is `Mission`, not `unknown`" beats the full inference chain
that produces that signature. Keep the terms a reader will grep for,
drop the ones that name compiler internals.

## Review and Publish

Commits and PRs are team-visible, permanent, and hard to amend once shared
(especially after push or after a reviewer has replied). Before executing
`git commit` or `gh pr create`, the change must pass a local code review
*and* the message must be reviewed by the user. The flow has two steps, in
order.

### Step 1: local code review (mandatory)

Run the `review-code` skill against the change:

- Before a commit: `/review-code --staged`
- Before a PR: `/review-code` (branch diff against `main` merge-base)
- Before commenting on someone else's PR: `/review-code <PR#>`

Surface **all** findings to the user: Critical, Important, and Minor.

**Default block:** any Critical or Important finding stops the flow. Fix the
issues and re-run `/review-code` until the diff is clean. Minor findings are
shown but do not block.

**Override:** the user can bypass the block with an explicit "proceed anyway"
(or equivalent wording). Without the explicit override, do not proceed to
Step 2.

The `review-code` skill already has a Phase 0 eligibility gate that handles
trivial and ineligible diffs (whitespace-only, revert with obvious
justification, already-reviewed SHA). Trust that gate; there is no "trivial
enough to skip review" exemption on top of it.

### Step 2: draft, review, publish

**For commit messages:**

1. Write the proposed message to `/tmp/commit-<short-slug>.md`.
2. Open it in the user's editor (e.g. `emacsclient -n /tmp/commit-<short-slug>.md`).
3. Run the `humanizer` skill on the file. Always — commit messages get the same prose-review treatment as PR descriptions. After humanizing, re-scan the output and (a) rewrite dev-jargon fragments ("Empty X throws", "Hard throw not a clamp", "all green") as plain, brief, complete sentences a low- or mid-level engineer who is not a native English speaker can read without stumbling, (b) replace semicolons with either a period or a comma, (c) prefer contractions ("it's", "that's", "don't", "we're") over their expanded forms, and (d) break up long sentences. Few engineers use semicolons in prose. They make the writing feel unnecessarily literary. Uncontracted English reads stiff in a short prose body unless a negation or emphasis needs the weight. A sentence that stacks three or four clauses with commas and conjunctions reads easier as two or three shorter ones. If you can split it on a conjunction ("so", "and", "but") without losing meaning, split it.
4. Stop and tell the user the draft is open for review. Wait for explicit approval.
5. After approval, commit with `git commit -F /tmp/commit-<short-slug>.md`.

**For PR descriptions:**

1. Write the title as line 1 and the body below it to `/tmp/pr-<ticket-or-slug>.md`.
2. The body must include a `Linear: [<TICKET-ID>](<linear-url>)` line so the
   ticket and PR are cross-linked. If there is no ticket, state that
   explicitly ("Linear: n/a") so reviewers know it was considered.
3. Open it in the user's editor (e.g. `emacsclient -n /tmp/pr-<ticket-or-slug>.md`).
4. Run the `humanizer` skill on the file. After humanizing, re-scan for dev-jargon fragments and rewrite them as plain, brief, complete sentences a low- or mid-level engineer who is not a native English speaker can read without stumbling. Replace semicolons with periods or commas. Few engineers use semicolons in prose. Prefer contractions ("it's", "that's", "don't", "we're") over their expanded forms. Uncontracted English reads stiff in a short prose body. Break up long sentences. A sentence that stacks three or four clauses with commas and conjunctions reads easier as two or three shorter ones. If you can split it on a conjunction ("so", "and", "but") without losing meaning, split it.
5. Stop and tell the user the draft is open for review. Wait for explicit approval.
6. After approval, split the file on the first blank line and pass the title
   and body to `gh pr create --title "..." --body "$(tail -n +3 <file>)"` (or
   a heredoc) so formatting is preserved.
7. After `gh pr create` returns a URL, post a comment on the linked Linear
   ticket with the PR URL (use the Linear MCP `save_comment` tool, or open
   the ticket manually if MCP is unavailable). This closes the ticket→PR
   direction of the cross-link.
8. Move the Linear ticket to the "Dev Review" status (use `save_issue` with
   the Dev Review state ID, or the Linear UI). The ticket should not remain
   "In Progress" once a PR is open against it.

**Exception:** trivial one-liners the user dictated verbatim in the
conversation (e.g. "commit this as `chore: bump version`") can skip the
draft-file step in Step 2, but `/review-code --staged` in Step 1 still runs.

### Hook-level authorization

The Step 1 code review plus the Step 2 user approval together constitute the
authorization gate for the publish action. No separate hook-level approval
prompt is needed on `git commit`, `gh pr create`, `git push`, or their
variants once Step 2 has been approved. If a hook is configured, rely on the
flow above to be the source of truth; do not treat the hook as a second
independent gate.

## Before Committing

1. Check author identity: `git log -1 --format='%an <%ae>'` — should be the user.
2. Scan the message for AI-attribution language (including emojis and footers).
3. Review the diff — only intended changes staged; no unrelated files.
4. Run tests and linters (see `verification.md`).

## If You Catch Yourself

Typing any of the following — stop, delete, rewrite:

- `Co-Authored-By: Claude`
- `🤖 Generated with …`
- "Created with Claude Code"
- "Assisted by AI"

Rewrite the commit as the user would write it: concise, focused on the
change, no mention of how the change was produced.
