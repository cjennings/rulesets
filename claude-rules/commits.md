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

Commit messages follow the [Conventional Commits](https://www.conventionalcommits.org/) spec.

### Structure

    <type>[optional scope]: <description>

    [optional body]

    [optional footer(s)]

### Types

- `feat:` — new feature (correlates with MINOR in SemVer)
- `fix:` — bug fix (correlates with PATCH in SemVer)
- `refactor:` — code restructuring, no behavior change
- `perf:` — performance improvement
- `test:` — adding or updating tests
- `docs:` — documentation only
- `style:` — formatting, whitespace, missing semicolons (no code-behavior change)
- `build:` — build system or external dependencies
- `ci:` — CI configuration and scripts
- `chore:` — anything else: tooling, meta, housekeeping

The Conventional Commits spec doesn't mandate the type list. Add a new type only when the existing ones genuinely don't fit and the team will agree on what it means.

### Scope

A scope MAY follow the type, in parentheses, naming the affected area of the codebase: `feat(parser): add ability to parse arrays`. Use a single noun.

### Breaking changes

Either append `!` after the type or scope, or include a `BREAKING CHANGE:` footer (uppercase — required). Both at once is fine and adds detail. `!` alone is enough.

    feat!: drop support for Node 6

    BREAKING CHANGE: uses JavaScript features not available in Node 6.

### Subject line

Imperative mood. ≤72 characters. No trailing period. The full subject is `<type>[scope]: <description>` — the 72-char limit covers the whole thing.

### Body

Optional. Begins one blank line after the subject. Free-form, multiple paragraphs allowed. Don't hard-wrap body lines — write each paragraph and each bullet as a single logical line and let the renderer (GitHub, Linear, `git log`) soft-wrap. Hard wraps shrink the visible render width in web UIs and cause awkward mid-sentence breaks. The same soft-wrap rule applies to PR bodies.

Skip the body when the subject line covers the change.

### Footers

Optional. One blank line after the body. One per line. Format: `Token: value` or `Token #value` — the git trailer convention. The token uses `-` in place of whitespace (e.g. `Reviewed-by`, `Refs`, `Acked-by`). `BREAKING CHANGE:` is the one token allowed to contain a space, and `BREAKING-CHANGE:` is treated as a synonym.

### How to write the message

Write commit messages as if you're explaining the change to someone debugging a failure six months from now. Focus on what changed and why, not the play-by-play of how you typed it. Short imperative summaries like "Validate input before processing" age better than diary-style notes.

The body, when you need it, is where context belongs — the constraint, bug, or tradeoff that forced the change. Over time the body becomes a lightweight decision log, which is more valuable than perfectly formatted messages.

Commit messages describe what changed and why, not the process that produced the change. Don't reference code review, linting, test runs, or other workflow steps in the body (e.g. "from local review," "review surfaced," "flagged by reviewer"). Reviewers and future archaeologists want the what and the why. How you got there belongs in the PR discussion, not the commit.

### Examples

**Subject only:**

    docs: correct spelling of CHANGELOG

**With scope:**

    feat(lang): add Polish language

**With body and footer:**

    fix: prevent racing of requests

    Introduce a request id and a reference to the latest request. Dismiss incoming responses other than from the latest request.

    Remove timeouts which were used to mitigate the racing issue but are obsolete now.

    Refs: #123

**Breaking change with `!`:**

    feat(api)!: send an email to the customer when a product is shipped

**Breaking change in footer:**

    feat: allow provided config object to extend other configs

    BREAKING CHANGE: `extends` key in config file is now used for extending other config files.

## Voice and Focus

Applies to commit bodies, PR descriptions, and PR comments (review replies, follow-up notes, thread responses).

**Write as if to a colleague.** The reader is a teammate who'll see this in `git log`, a PR feed, or a Linear thread. "I" is allowed where natural. Don't sound abstract — name the file, the function, the constraint, the symptom. Press-release voice ("This change improves...") and committee voice ("It is recommended that...") both come out. The message has to read like one engineer talking to another, not like a generated artifact.

**No felt-experience narration.** Don't tell the reader how the change will feel or how often you'll use it. Phrases like "I'll feel this every time I commit", "this will be a relief", "I'm excited about" — these read as performance, not communication. State what changed and let the reader decide what to do with it.

**Don't noun-ify verbs.** "The ask", "a learn", "a reveal", "the spend", "a build" — use the real noun: "the request", "the lesson", "the finding", "the budget", "the system". Verb-as-noun reads as corporate-speak and makes the sentence feel performed.

**No sentence fragments in prose.** Every prose sentence needs a subject and a verb. "Two changes." or "Fix incoming." or "Body as decision log." read as bullet-list shorthand even when they're standing alone in a paragraph. Bullets and headings can be fragments — prose sentences cannot.

**"I" is the author, not the user.** First person is for what *I* did or decided in this commit ("I dropped the legacy fallback because..."). It's not for describing how the software or rule behaves for whoever uses it next. "The dialog only opens if I ask" is wrong when the rule is read by someone else — that "I" becomes ambiguous. Use third-person or passive for behavior: "opens on request", "opens when asked", "opens when the user invokes it". Code and systems are the actor; "I" stays for decisions.

**First person where it fits.** When the subject is you or a decision you made, use "I" ("I added X", "I kept the parameter as `Any` because..."). When the subject is a team decision or shared rationale, "we" fits. When another author's prior work is the subject, name them ("Kostya's PR #116 did X"). Third-person constructions like "This PR introduces X" or "This change restores Y" read as press-release self-narration. The commit *is* the change, so don't announce it. Code and systems can stay third-person when they're the actor ("the guard rejects...", "the serializer returns...") — first person is for describing what you did or decided, not for narrating how the code behaves.

**Brief. Terse is preferred.** A one-sentence body beats a paragraph saying the same thing. If the subject line covers it, skip the body entirely. Cut every clause that restates what the diff or the PR card already shows. Length is not a proxy for care. Rhetorical padding ("worth noting", "it's important to understand") always comes out; keep what a reader will actually use.

**Kind.** PR comments and review replies are directed at a specific person. Acknowledge them when it fits ("thanks for the review") without pouring it on. When you disagree or push back, frame it as your read rather than a correction ("I think...", "my read was...", "did you mean X?"). Leave room for the other person to have seen something you didn't. A polite question beats a defensive explanation. Kindness is free and makes the next review cheaper.

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

## Content scope for public artifacts

PR descriptions, Linear ticket bodies, and PR review comments are
visible to the team and to anyone with read access to the repo or
project. Don't mention:

- Local file paths on the user's personal machine.
- Private repos by name (e.g. a personal notes repo, a career repo).
- Personal tooling or workflow the team doesn't share.
- Anything a teammate couldn't reproduce or act on from public sources.

Rule of thumb: if a teammate couldn't find the referenced thing without
the user's help, don't reference it.

**Personal-tooling files.** The rules and skills that drive my workflow are private. Treat the following as personal tooling and don't cite them as authority in any commit message, PR description, PR comment, Linear ticket, or other shared artifact:

- Anything in `~/code/rulesets/claude-rules/` (`commits.md`, `testing.md`, `verification.md`, `subagents.md`, and any others added later).
- Any `CLAUDE.md`, `AGENTS.md`, or similar project-level rules file.
- Anything under `~/.claude/`, project `.claude/`, or project `.ai/`.
- Any skill definition (`SKILL.md`) under `~/code/rulesets/`.

Don't write "per `testing.md`, integration tests must hit a real DB" or "the rule in `commits.md` says…". State the reason directly: "integration tests hit a real DB so the migration is exercised end-to-end." The personal rule doesn't matter to a teammate. The reason does.

Edge case: when one of these files *is* the change (a commit in the rulesets repo, an edit to a project's `CLAUDE.md`), describe what changed and why without invoking the wider personal-rules layer around it. The commit can absolutely say "tighten testing rule for legacy code". It shouldn't say "per the personal-rules layer this file is loaded into…".

Different artifact types carry different content. Don't duplicate.

**Linear ticket bodies:** two sections, in order.

1. **Problem** — what's wrong, with enough detail that a teammate can
   recognize the same failure mode in their own work.
2. **Fix** — what changed (or what's proposed).

The causal "why" and the test verification belong in the PR, not the
ticket. Linear's GitHub integration auto-cross-links once the PR body
includes the `Linear:` line, so the ticket reader reaches the PR
without needing a body-level link.

**PR descriptions:** four sections, in order. Same first two as the
ticket, plus:

3. **Why this fixes it** — causal link, one or two sentences.
4. **How it was tested** — skip for proposals, specs, or discussions;
   required for shipped fixes.

The PR is the technical artifact. It carries the detail.

**PR review comments** are conversational and don't follow this
structure — they follow the Voice and Focus rules above.

Verbose preambles, motivational language, and context unrelated to the
problem belong out. Same conciseness pressure as commit-message bodies.

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
2. Run the `humanizer` skill on the file. Always — commit messages get the same prose-review treatment as PR descriptions.
3. Apply the personal-style passes in order on the humanized output: (a) rewrite dev-jargon fragments ("Empty X throws", "Hard throw not a clamp", "all green") as plain, brief, complete sentences a low- or mid-level engineer who is not a native English speaker can read without stumbling; (b) replace semicolons with either a period or a comma; (c) prefer contractions ("it's", "that's", "don't", "we're") over their expanded forms; (d) break up long sentences. Few engineers use semicolons in prose — they make the writing feel unnecessarily literary. Uncontracted English reads stiff in a short prose body unless a negation or emphasis needs the weight. A sentence that stacks three or four clauses with commas and conjunctions reads easier as two or three shorter ones. If you can split it on a conjunction ("so", "and", "but") without losing meaning, split it. Also re-check the colleague-tone framing in *Voice and Focus* — the message should read like one engineer talking to another.
4. Print the final draft inline in the terminal. Every line, exactly as it'll be committed. No truncation, no summary. Name the passes that ran (e.g. "humanizer + jargon + semicolons + contractions + sentence-split — all applied").
5. Ask: approve, request changes, or open in editor. Wait for an explicit answer. Do not open the file in `emacsclient` (or any editor) by default — print first, edit only if asked.
   - **Approve** → commit with `git commit -F /tmp/commit-<short-slug>.md`.
   - **Request changes** → make them, re-run `humanizer`, re-apply the personal-style passes, re-print inline, ask again.
   - **Open in editor** → only if the user asks. `emacsclient -n /tmp/commit-<short-slug>.md`. After the editor closes, re-read the file, re-print the contents inline, and ask again.

**For PR descriptions:**

1. Write the title as line 1 and the body below it to `/tmp/pr-<ticket-or-slug>.md`. **Title format:** `<conventional-commit subject> (<TICKET-ID>)` — the ticket ID goes at the end in parentheses (e.g. `refactor: remove dead if-count-is-not-None check in admin (SE-289)`). If there is no ticket, omit the parenthetical. The body must also include a `Linear: [<TICKET-ID>](<linear-url>)` line so Linear's GitHub integration auto-cross-links the PR to the ticket. If there is no ticket, state that explicitly ("Linear: n/a") so reviewers know it was considered.
2. Run the `humanizer` skill on the file.
3. Apply the personal-style passes in order on the humanized output: (a) rewrite dev-jargon fragments as plain, brief, complete sentences a low- or mid-level engineer who is not a native English speaker can read without stumbling; (b) replace semicolons with periods or commas — few engineers use semicolons in prose, they make the writing feel unnecessarily literary; (c) prefer contractions ("it's", "that's", "don't", "we're") over their expanded forms — uncontracted English reads stiff in a short prose body; (d) break up long sentences. A sentence that stacks three or four clauses with commas and conjunctions reads easier as two or three shorter ones. If you can split it on a conjunction ("so", "and", "but") without losing meaning, split it. Also re-check the colleague-tone framing in *Voice and Focus*.
4. Print the final draft inline in the terminal. Title on line 1, blank line, then body — exactly as it'll be posted. Name the passes that ran.
5. Ask: approve, request changes, or open in editor. Wait for an explicit answer. Do not open the file in `emacsclient` (or any editor) by default.
   - **Approve** → continue to step 6.
   - **Request changes** → make them, re-run `humanizer`, re-apply the personal-style passes, re-print inline, ask again.
   - **Open in editor** → only if the user asks. `emacsclient -n /tmp/pr-<ticket-or-slug>.md`. After the editor closes, re-read the file, re-print inline, ask again.
6. Split the file on the first blank line and pass the title and body to `gh pr create --title "..." --body "$(tail -n +3 <file>)"` (or a heredoc) so formatting is preserved. Add `--reviewer <user[,user...]>` in the same call when you already know who should review.
7. Request reviewers on the new PR if you didn't pass `--reviewer` at create time. Use `gh pr edit <N> --add-reviewer <user>`. If the repo has a `CODEOWNERS` file, GitHub auto-suggests based on touched paths. Still issue the explicit request so the reviewer gets notified. Pick reviewers per the team's convention for the area touched (often documented in the per-repo `CLAUDE.md`). For follow-up PRs, consider tagging the parent PR's author if their context would help. PRs without a human reviewer request stall — "checks passed" is not a substitute for review.
8. After `gh pr create` returns a URL, post a comment on the linked Linear ticket with the PR URL (use the Linear MCP `save_comment` tool, or open the ticket manually if MCP is unavailable). This closes the ticket→PR direction of the cross-link.
9. Move the Linear ticket to the "Dev Review" status (use `save_issue` with the Dev Review state ID, or the Linear UI). The ticket should not remain "In Progress" once a PR is open against it.

**For PR review comments and replies (review verdicts, threaded discussion, follow-up notes on someone else's PR or your own):**

1. Write the proposed comment to `/tmp/pr-<N>-comment.md` (or `/tmp/pr-<ticket>-comment.md` if the ticket ID is clearer).
2. Run the `humanizer` skill on the file. Always.
3. Apply the personal-style passes in order on the humanized output: (a) rewrite dev-jargon fragments as plain, brief, complete sentences a low- or mid-level engineer who is not a native English speaker can read without stumbling; (b) replace semicolons with periods or commas; (c) prefer contractions ("it's", "that's", "don't", "we're") over their expanded forms; (d) break up long sentences on conjunctions ("so", "and", "but"). The *Voice and Focus* rules — especially the colleague-tone framing — matter the most here. The comment is directed at a specific person who will reply, and the thread is public.
4. Print the final draft inline in the terminal. Name the passes that ran.
5. Ask: approve, request changes, or open in editor. Wait for an explicit answer. Do not open the file in `emacsclient` (or any editor) by default.
   - **Approve** → continue to step 6.
   - **Request changes** → make them, re-run `humanizer`, re-apply the personal-style passes, re-print inline, ask again.
   - **Open in editor** → only if the user asks. `emacsclient -n /tmp/pr-<N>-comment.md`. After the editor closes, re-read the file, re-print inline, ask again.
6. Post with the `gh` command that matches the comment type:
   - Review-shaped comment (the reviewer's overall verdict on the PR): `gh pr review <N> --comment --body-file /tmp/pr-<N>-comment.md` (use `--approve` or `--request-changes` in place of `--comment` when formally approving or blocking).
   - Issue-thread comment (general PR discussion, not a formal review): `gh pr comment <N> --body-file /tmp/pr-<N>-comment.md`.
   - Inline code comment pinned to a specific line/hunk: no direct `gh` flag — use `gh api /repos/<owner>/<repo>/pulls/<N>/comments -F body=@/tmp/pr-<N>-comment.md -F commit_id=... -F path=... -F line=...`.
7. Verify the comment landed. `gh api /repos/<owner>/<repo>/pulls/<N>/reviews` for review-shaped comments, `gh api /repos/<owner>/<repo>/issues/<N>/comments` for issue-thread comments.

**Exception:** trivial one-liners the user dictated verbatim in the
conversation (e.g. "commit this as `chore: bump version`", "reply just
'thanks for the review'") can skip the draft-file step in Step 2.
`/review-code` in Step 1 still runs when it applies; Phase 0 of that skill
handles trivial diffs, and acknowledgment-only replies don't need it at all.

**Multi-pass gate.** Each of the three subflows above runs `humanizer` and four personal-style passes (jargon rewrite, semicolon swap, contractions, sentence split) before printing the draft. All five are mandatory — the printed draft must have been through every one. When the user asks mid-flow for "both passes" or "all the passes" or just "the humanizer step" on an in-progress draft, that means re-run *every* pass — not just the first or a representative subset. Always name the passes that ran when announcing the printed draft (e.g. "humanizer + jargon + semicolons + contractions + sentence-split — all applied"). Skipping a pass without flagging it is a defect.

### Hook-level authorization

The Step 1 code review plus the Step 2 user approval together constitute the
authorization gate for the publish action. No separate hook-level approval
prompt is needed on `git commit`, `gh pr create`, `git push`, or their
variants once Step 2 has been approved. If a hook is configured, rely on the
flow above to be the source of truth; do not treat the hook as a second
independent gate.

## Merge Strategy

- *Squash-merge is the default* for feature branches. It avoids carrying
  WIP and fix-up commits into the target branch history and produces one
  logical change per merge.
- State the planned merge approach (squash, rebase, or merge commit) and
  the target branch *before* pushing or merging. Wait for explicit user
  confirmation before `git push`, `gh pr merge`, or any equivalent. The
  Review and Publish flow above approves the *content*; merge strategy is
  a separate decision that needs its own confirmation.
- Override the squash default only when there's a concrete reason: a
  clean per-commit review history the user has explicitly asked for, a
  multi-commit semantic narrative the team values, etc. Squash is the
  safe default; document why when deviating.

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
