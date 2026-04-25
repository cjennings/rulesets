---
name: review-code
description: Review code changes against engineering standards. Accepts a PR number, a SHA range (BASE..HEAD), the current branch's diff against main, staged changes, or a described scope ("the last 3 commits"). Audits CLAUDE.md adherence (reads root + per-directory CLAUDE.md), intent-vs-delivery (when given a plan/ADR/ticket), security, testing (TDD evidence + three-category coverage), conventions (conventional commits + no AI attribution), root-cause discipline, architecture (layering + scope), API contracts. Produces a structured report — Strengths, per-criterion PASS/WARN/FAIL, per-issue Critical/Important/Minor severity — ending with an explicit verdict (Approve / Request Changes / Needs Discussion) plus 1-2 sentence reasoning. Self-filters low-confidence findings; never flags pre-existing issues, lint/typecheck issues (CI handles those), or changes on unmodified lines. Use before merging a PR, before pushing a branch, or when reviewing a teammate's work. Do NOT use for proposing features (use brainstorm or arch-design), drafting implementation (use start-work or add-tests), standalone security audits (use security-check), or narrow style-only checks (a linter handles those).
---

# /review-code

Review code changes against engineering standards. Produce a structured report with strengths, per-criterion audit, severity-tagged issues, and an explicit verdict.

## Usage

Point the skill at code being reviewed in any of these ways:

- `/review-code [PR_NUMBER]` — fetch the PR diff via `gh pr view` + `gh pr diff`
- `/review-code BASE_SHA..HEAD_SHA` — any git range
- `/review-code` (no args) — the current branch's diff against its merge base with `main`
- `/review-code --staged` — only staged changes (pre-commit scrutiny)
- Or describe it: "review my changes in the current branch" / "review the last 3 commits"

Optionally, provide intent context for delivery grading:

- `plan=docs/design/<feature>.md`
- `adr=docs/adr/<NNNN>-<title>.md`
- `ticket=LINEAR-<id>` (fetches the ticket for comparison)

When intent context is given, the review grades "does this match what was asked?" on top of code hygiene. When not, that section is marked N/A.

## Execution Model

For substantive reviews on large diffs: **dispatch the perspective passes as parallel sub-agents** via the Agent tool. Each sub-agent starts with a clean context window — the reviewer shouldn't inherit the implementer's mental model. For small single-commit tweaks, run inline.

## Phase 0 — Eligibility Gate

Before reviewing, confirm the review is worth running. Skip with a short note if any apply:

- PR is closed or merged (reviewing merged code is after-the-fact observation, not a gate)
- PR is a draft not marked ready-for-review
- Change is an automated dep bump (dependabot, renovate) — trust the bot + CI
- Change is trivial (whitespace-only, typo-only, revert with obvious justification)
- A `/review-code` report already exists for this SHA range (no new commits since)

If skipping, report: "Skipped — <reason>" and stop.

## Phase 1 — Gather Context

1. **Resolve the input to a concrete diff:**
   - PR: `gh pr view <n> --json title,body,baseRefName,headRefName,files` + `gh pr diff <n>`
   - SHA range: `git diff <base>..<head>` + `git log <base>..<head> --format='%h %s%n%b'`
   - Current branch: `git merge-base HEAD main` → diff from there
   - `--staged`: `git diff --cached`

2. **Collect CLAUDE.md files to audit against:**
   - Root project `CLAUDE.md` if present
   - Any `CLAUDE.md` in directories whose files the diff modified
   - Their paths go into the audit; their content guides the CLAUDE.md adherence criterion

3. **If intent context was provided**, fetch and read it. Extract: stated goal, scope, non-goals, acceptance criteria, linked ADRs.

4. **Scope summary** — record for the final report: file count, added/removed lines, commit count, touched modules.

## Phase 2 — Multi-Perspective Pass

Each perspective is a distinct review angle. For substantial changes, dispatch them as parallel sub-agents. For small changes, run sequentially inline.

Follow `subagents.md` for the dispatch contract — each perspective's prompt needs explicit scope, pasted diff context, constraints (don't flag unmodified lines, don't rewrite the PR), and a required output format. Perspectives are read-only and independent, so parallel fan-out is always safe here.

### Perspective A — CLAUDE.md Adherence

Read the CLAUDE.md files collected in Phase 1. For each rule they state, check whether the diff honors it. CLAUDE.md is writing guidance, so not every rule applies at review time — focus on rules that are *assertions about what committed code should look like*.

Example: if CLAUDE.md says "prefer `cast()` over `# type: ignore`," flag any `# type: ignore` in the diff. If it says "always run `make validate-parens` before commit," that's process guidance, not a reviewable code attribute.

### Perspective B — Shallow Bug Scan

Read the file changes in the diff. Ignore context beyond the changes themselves. Focus on **large, obvious bugs**:

- Null / undefined dereferences on values the code can't guarantee
- Off-by-one errors in boundary conditions
- Incorrect error handling (swallowing exceptions, returning success on failure paths)
- Data mutation under concurrent access without coordination
- Incorrect SQL / query shape (wrong join, missing where clause)
- Obvious crashes (`raise` without arguments, typed nil, etc.)

Avoid small issues and nitpicks; those are for the Minor severity tier, if worth mentioning at all.

### Perspective C — Git History Context

Run `git blame` on the modified lines. Read recent commits that touched the same files. Check:

- Is this change contradicting a recent deliberate choice? (Someone just fixed X; now this PR re-introduces it.)
- Is there a pattern of the same bug being fixed repeatedly here?
- Is the surrounding code style / convention consistent with what's being added?

### Perspective D — Prior PR Comments

`gh pr list` the PRs that previously touched these files. Check their review comments. If prior reviewers flagged a pattern, check whether the current diff repeats it.

### Perspective E — Code Comments In Scope

Read comments in the modified files (both touched and nearby). If the code has guidance ("DO NOT call this before X is initialized"), check the diff complies.

## Phase 3 — Criteria Audit

For each criterion below, report **PASS / WARN / FAIL** with file:line references. WARN and FAIL findings become issues in the Phase 4 summary.

### Intent vs Delivery (when intent context provided)

- Does the implementation match the plan / ADR / ticket?
- Are acceptance criteria demonstrably met?
- Scope creep: changes not in the plan?
- Missing requirements: plan items unimplemented?

Skip if no intent context; note "not evaluated" in the report.

### Security

- No hardcoded secrets, tokens, API keys, or credentials
- All user input validated at system boundary
- Parameterized queries only (no SQL string concatenation)
- No sensitive data logged (PII, tokens, passwords)
- Dependencies pinned and auditable

### Testing (TDD Evidence)

- Tests exist for all new code
- Test commits **precede** implementation commits (TDD workflow)
- Three categories covered: Normal, Boundary, Error per function; thorough on edge cases
- Tests are independent — no shared mutable state
- Mocking at external boundaries only (network, file I/O, time) — domain logic tested directly
- Test naming follows project convention
- Coverage does not decrease without justification
- Parameter-heavy functions: author considered pairwise coverage via `/pairwise-tests`? (Not required; worth noting if missing.)

### Conventions

- Type annotations on all functions (including return types)
- Conventional commit messages (`feat:`, `fix:`, `chore:`, etc.)
- **No AI attribution anywhere** — code, comments, commits, PR descriptions — see `commits.md`
- One logical change per commit
- Docstrings on public functions/classes

### Root Cause & Thoroughness

- Bug fixes address the root cause, not surface symptoms
- Changes demonstrate understanding of surrounding code
- Edge cases covered comprehensively, not just the happy path

### Architecture

- Request handlers thin; business logic in services/domain
- No unnecessary abstractions or over-engineering
- Changes scoped to what was asked (no drive-by refactoring)
- Stated architecture respected — if `.architecture/brief.md` exists, check conformance (see `arch-evaluate`)

### API Contracts

- New endpoints have typed contracts or schemas defined
- No raw dict/object responses bypassing the contract layer
- Client-side types match server-side output
- Data flows through the API layer, not direct data access from handlers

## Phase 4 — Filter and Categorize

### Confidence Filter

For each issue surfaced by any perspective or criterion, self-scrutinize: **am I really sure this is a real issue, or could I be wrong?** Rate your confidence honestly:

- **High** — verified by reading the code; matches a pattern that causes bugs in practice; or a direct CLAUDE.md violation you can cite
- **Medium** — likely real but contingent on context you didn't fully verify
- **Low** — looks off but you can't confirm; might be a false positive

**Drop Low-confidence issues before the final report.** Medium and High issues appear; Medium ones noted as such where uncertainty is relevant.

### False-Positive Filter

Do **not** flag any of these as issues:

- **Pre-existing issues** on unmodified lines — note separately as "for follow-up," don't block this PR
- **Lint / typecheck / test failures** — CI handles those; don't run builds yourself
- **Nitpicks a senior engineer wouldn't call out** — unless CLAUDE.md explicitly requires them
- **Style issues** — formatters and linters handle these
- **Issues explicitly silenced in code** (e.g., `# type: ignore[...]` with a reason, lint ignore comments) unless the silencing is unjustified
- **Intentional changes** in functionality clearly related to the PR's stated goal
- **Changes in unmodified lines** (real issues in files the PR touches but on lines it doesn't change)
- **Framework behavior being tested** — see `testing.md` anti-patterns

### Severity Categorization

Remaining issues get tagged:

- **Critical** — merge-blockers: security holes, broken functionality, data loss risk, missing acceptance criteria, AI attribution in committed content
- **Important** — should fix: architecture problems, test gaps, error handling holes, pattern violations
- **Minor** — nice to have: missing docstrings, docstring drift, small optimizations

## Phase 5 — Output

```markdown
# Code Review — <PR title / branch name / SHA range>

**Scope:** <N files, +X / -Y lines, Z commits>
**Input:** <pr#N / base..head / current branch>
**Intent context:** <plan/ADR/ticket link, or "none provided">
**CLAUDE.md files audited:** <list of paths>

## Strengths

Three minimum. Specific, with file:line.

- <Specific positive>
- <Specific positive>
- <Specific positive>

## Per-Criterion Audit

| Criterion | Status | Notes |
|---|---|---|
| CLAUDE.md Adherence | PASS / WARN / FAIL | ... |
| Intent vs Delivery | PASS / WARN / FAIL / N/A | ... |
| Security | PASS / WARN / FAIL | ... |
| Testing (TDD Evidence) | PASS / WARN / FAIL | ... |
| Conventions | PASS / WARN / FAIL | ... |
| Root Cause & Thoroughness | PASS / WARN / FAIL | ... |
| Architecture | PASS / WARN / FAIL | ... |
| API Contracts | PASS / WARN / FAIL | ... |

## Issues

### Critical (must fix before merge)

1. **<Title>**
   - File: `<path>:<line>`
   - Problem: <what's wrong>
   - Why it matters: <impact>
   - Fix: <concrete suggestion>

### Important (should fix)

1. **<Title>** — `<file>:<line>` — <one-sentence description>

### Minor (nice to have)

1. **<Title>** — `<file>:<line>`

## Recommendations

Meta-level suggestions: process changes, follow-up tickets, architectural drift observations.

## Verdict

**<Approve / Request Changes / Needs Discussion>**

**Reasoning:** <1-2 sentences. Grounded in the audit.>
```

## Critical Rules

**DO:**
- Categorize issues by actual severity — not everything is Critical
- Cite specifics — `file:line`, not vague prose
- Explain why each issue matters, not just what it is
- Acknowledge strengths — mandatory; three minimum
- Give a clear verdict with reasoning
- Trust CI for lint, typecheck, test runs; don't re-run them
- Self-filter low-confidence findings before reporting

**DON'T:**
- Say "looks good" without citing what was checked
- Mark style nitpicks as Critical
- Give feedback on code you didn't actually read
- Flag pre-existing issues as PR-blockers
- Use emojis or marketing-adjacent language
- Skip the verdict or hedge it
- Add any AI attribution to the output

## Example Output

```markdown
# Code Review — feat: add inventory export CSV (#447)

**Scope:** 8 files, +312 / -24 lines, 5 commits
**Input:** PR #447
**Intent context:** docs/design/inventory-export.md
**CLAUDE.md files audited:** CLAUDE.md, api/CLAUDE.md

## Strengths

- Characterization tests added before refactor (`tests/test_inventory_export.py:12-89`) — TDD evidence clear across commit order
- Export batches via generators rather than loading full inventory (`inventory/export.py:42-78`) — handles the 50k-row case without OOM
- API schema versioned from day one (`api/schemas/export.py:5`) — cleaner than most first-endpoints

## Per-Criterion Audit

| Criterion | Status | Notes |
|---|---|---|
| CLAUDE.md Adherence | PASS | No `# type: ignore` without justification; conventional commits clean |
| Intent vs Delivery | PASS | Matches plan §3.2; acceptance criteria met |
| Security | WARN | User-provided filename not sanitized (see Important #1) |
| Testing (TDD Evidence) | PASS | 5 test commits precede 3 implementation commits |
| Conventions | PASS | All conventional, no AI attribution detected |
| Root Cause & Thoroughness | PASS | Empty inventory, Unicode, large batches all covered |
| Architecture | PASS | Handler thin; logic in inventory service |
| API Contracts | PASS | Schema defined; TS types match in client/ |

## Issues

### Critical

None.

### Important

1. **Filename injection via user input**
   - File: `api/views/inventory.py:42`
   - Problem: User-provided `filename` passed directly to `Content-Disposition` header
   - Why it matters: CRLF injection → header smuggling; also sets up a path-traversal risk if ever used for disk writes
   - Fix: `secure_filename(user_filename)` (werkzeug) or regex-strip to `[A-Za-z0-9._-]+`

### Minor

1. **Missing type on private helper** — `inventory/export.py:22` — `_chunked()` return type unspecified
2. **Docstring drift** — `inventory/service.py:104` — docstring describes pre-batch behavior

## Recommendations

- Consider `/pairwise-tests` on the `export_options` function (4 parameters × 2-3 values each); currently 3 hand-written tests cover a fraction of the combinatorial space

## Verdict

**Request Changes**

**Reasoning:** Core implementation is strong — TDD evidence, thin handler, proper schema, good edge coverage. The filename-injection issue is a must-fix before merge; once resolved this is a clean approve.
```

## Anti-Patterns

- **All-caps everything.** If everything is Critical, nothing is. Be honest about severity.
- **No Strengths section.** Reviews that only list problems are inaccurate — you missed what's right. Minimum three.
- **Verdict without reasoning.** "Request Changes" alone is unhelpful. One or two sentences on why.
- **Criteria skipped silently.** If you didn't check API contracts, say "N/A — no API changes in this diff," not silence.
- **Reviewing code you didn't read.** Don't feedback on files you skimmed.
- **Running the build yourself.** CI does that. Don't re-verify what CI is for.
- **Hedging ("might be an issue").** If you can't commit to it, it's Low-confidence — drop it.

## Hand-Off

- **Critical** → must be addressed before merge; author fixes, re-review via `/review-code` on the updated SHA
- **Important** → fix, or deliberately defer with an ADR (run `/arch-decide`)
- **Minor** → follow-up issues or a cleanup PR
- **Intent-vs-Delivery gaps** → either file tickets for the missing pieces or update the plan to reflect reality

## Content scope

Output this skill produces that gets committed or shared with the team must follow the *Content scope for public artifacts* rule in [`commits.md`](../claude-rules/commits.md): no local paths, no private repo names, no personal tooling references.
