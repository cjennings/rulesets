---
name: codify
description: Codify concrete, actionable insights from recent session work into the project's `CLAUDE.md` so they survive across sessions and compound over time. Harvests patterns that worked, anti-patterns that bit, API gotchas, specific thresholds, and verification checks. Filters against quality gates (atomic, evidence-backed, non-redundant, verifiable, safe, stable). Writes into a dedicated `## Codified Insights` section rather than scattering entries. Use after a productive session, a bug fix that revealed a non-obvious pattern, or an explicit review where you want learnings preserved as rules. Supports `--dry-run` to preview, `--max=N` to cap output, `--target=<path>` to write elsewhere, `--section=<name>` to override the destination section. Flags insights that look cross-project and suggests promotion to `~/code/rulesets/claude-rules/` instead. Do NOT use for session wrap-up / progress summaries (not insights), for private personal context (auto-memory handles that, not a tracked file), or for formal rules that belong in `.claude/rules/`. Informed by Agentic Context Engineering (ACE, arXiv:2510.04618) — grow-and-refine without context collapse.
---

# Codify

Turn transient session insights into durable, actionable entries in the project's `CLAUDE.md`. Each invocation should make the next session measurably better without diluting what's already there. Select carefully, phrase specifically, commit deliberately.

## When to Use

- End of a productive session where you want concrete patterns preserved
- After a bug fix that revealed a non-obvious constraint or gotcha
- After a review where a pattern was identified as worth repeating (or avoiding)
- When you notice yourself re-deriving the same insight — it belongs written down

## When NOT to Use

- For a session wrap-up summary (that's narrative, not an insight)
- For personal/private context (auto-memory at `~/.claude/projects/<cwd>/memory/` captures that — see below)
- For formal project rules — those belong in `.claude/rules/*.md`
- When you have no specific, evidence-backed insight yet — skip rather than fabricate

## Relationship to Other Memory Systems

Three distinct systems, zero overlap:

| System | Location | Scope | Purpose |
|---|---|---|---|
| **auto-memory** | `~/.claude/projects/<cwd>/memory/` | Private, per-working-directory | Session-bridging context about the user and project (feedback, user traits, project state). Written continuously by the agent. |
| **`/codify` (this skill)** | Project `CLAUDE.md` | Public, tracked, per-project | Explicit, curated rules and patterns. Written deliberately by the user invocation. |
| **Formal rules** | `.claude/rules/*.md`, `~/code/rulesets/claude-rules/` | Public, tracked, per-project or global | Stable policy (style, conventions, verification). Authored once, rarely updated. |

Use the right system for the right content.

## Workflow

Four phases. Each can be skipped if it has no content; none should be silently merged.

### Phase 1 — Harvest

Identify candidate insights from recent work. Look at:

- The session transcript (or files referenced by `--source`)
- Recent commits and their messages
- Any `.architecture/evaluation-*.md` from `arch-evaluate`
- Reflection or critique outputs if they exist
- Anti-patterns you caught yourself falling into

**Extract only:**

- **Patterns that worked** — preferably with a minimum precondition and a worked example or reference
- **Anti-patterns that bit** — with the observable symptom and the reason
- **API / tool gotchas** — auth quirks, rate limits, idempotency, error codes
- **Verification items** — concrete checks that would catch regressions next time
- **Specific thresholds** — "pagination above 50 items" not "pagination when needed"

**Exclude:**

- Progress narrative ("today we shipped X")
- Personal preferences ("I like functional style")
- Vague aphorisms ("write good code")
- Unverified claims (if you can't cite code, docs, or repeated observation, skip)

### Phase 2 — Filter (Grow-and-Refine)

For each candidate insight, apply these gates. Fail any → drop the entry.

- **Actionable.** A reader could apply this immediately. "Write good code" fails; "For dataset lookups under ~100 items, Object outperforms Map in V8" passes.
- **Specific.** Names a threshold, a file, a flow, a version, or a named tool. Generic insights are noise.
- **Evidence-backed.** Derived from code you just read, docs you just verified, or a pattern observed more than once. Speculation doesn't count.
- **Atomic.** One idea per bullet. If the insight has two distinct parts, it's two bullets.
- **Non-redundant.** Check existing `CLAUDE.md` content. If something similar exists, prefer merging or skipping over duplicating. If the new one is genuinely more specific and evidence-backed than the existing one, append it and mark the older one with `(candidate for consolidation)` — don't auto-delete prior user content.
- **Safe.** No secrets, tokens, private URLs, or PII. Nothing that would leak in a public commit.
- **Stable.** Prefer patterns that'll remain valid. If version-specific, say so.

### Phase 3 — Write

Write approved insights to a dedicated section of `CLAUDE.md`. Default section name: **`## Codified Insights`**. Override with `--section=<name>`.

**Discipline:**

- **One section only.** Don't scatter entries across CLAUDE.md. All codified content in one place means future `/codify` runs and human readers find it fast.
- **Create the section if absent.** Place it near the end of CLAUDE.md, before any footer links.
- **Preserve chronology within the section.** Newer entries appended; don't shuffle.
- **Include provenance.** Each entry gets a date and, where useful, a one-word source hint (`pattern:`, `gotcha:`, `threshold:`, `anti-pattern:`, `verify:`).

**Entry format:**

```markdown
- **<short title or rule>.** <One or two sentences. Concrete. Actionable.> (`<source-hint>` — YYYY-MM-DD)
```

Examples:

```markdown
- **Pagination threshold.** Fetch endpoints returning >50 items must paginate; clients assume everything ≤50 is complete. (`threshold` — 2026-04-19)
- **Map vs Object for small lookups.** In V8, Object outperforms Map for <~100 keys; Map wins at 10k+. Use Object for hot config lookups. (`pattern` — 2026-04-19)
- **Never log `load-file-name` from batch-compile context.** Both `load-file-name` and `buffer-file-name` are nil during top-level evaluation; `file-name-directory nil` raises `stringp, nil`. (`gotcha` — 2026-04-19)
```

### Phase 4 — Validate

After writing, check:

- [ ] Every entry passed all Phase 2 gates
- [ ] Each entry is atomic (one idea)
- [ ] No near-duplicates were created
- [ ] The `## Codified Insights` section is coherent — entries flow, categories aren't interleaved randomly

If the validation surfaces a problem, fix before exiting.

## Cross-Project Promotion

Some insights apply to *all* your projects, not just this one. Examples:

- "Always emit JSON with a stable key order for git diffs"
- "For TypeScript libraries, expose types via `package.json#exports`"

When an insight reads as general rather than project-specific, the skill emits a **promotion hint** at the end of the run:

```
Promotion candidates:
- "JSON stable key order" — reads as general. Consider adding to:
    ~/code/rulesets/claude-rules/style.md
  (would apply to every project via global install)

Keep as project-specific, promote, or drop? [k/p/d]
```

Promotion happens manually — the skill doesn't edit the rulesets repo automatically. The hint is a nudge to think about scope.

## Arguments

- **`--dry-run`** — show the proposed entries and where they'd be written; do not modify any files.
- **`--max=N`** — cap output to the top N insights by specificity + evidence.
- **`--target=<path>`** — write to a different file. Defaults to `./CLAUDE.md`. Use e.g. `docs/learnings.md` if the project prefers a separate file.
- **`--section=<name>`** — override the default `## Codified Insights` section name.
- **`--source=<spec>`** — scope what gets harvested. Values: `last` (most recent message), `selection` (a user-highlighted region if supported), `chat:<id>` (a specific past conversation), `commits:<range>` (e.g., `commits:HEAD~10..`). Defaults to a reasonable window of recent session context.

## Output

On a real run (not `--dry-run`):

1. Short summary — "added N entries to `<target>`: X patterns, Y gotchas, Z thresholds."
2. Any promotion candidates flagged for global-rules consideration.
3. Confirmation of the file path modified.

On `--dry-run`:

1. Preview of each proposed entry with the section it would land in.
2. Flagged promotions.
3. Explicit confirmation nothing was written.

## Anti-Patterns

- **Summarizing the session instead of extracting insights.** "Today we refactored X" is narrative. "X's public API requires parameters in Y order due to Z" is an insight.
- **Writing entries without evidence.** If you can't point to code, docs, or multiple observations, the entry is speculation.
- **Overwriting prior content.** Mark conflicts for consolidation; don't auto-delete what the user wrote.
- **Scattering entries.** One section. Grep-able. Coherent.
- **Batch-writing 20 entries in one session.** If the session generated 20 real insights, many of them aren't. Filter harder. 3-5 genuine entries per run is typical.
- **Adding to `CLAUDE.md` when auto-memory is the right system.** Private user-context goes in auto-memory; public project rules go here; static policy goes in `.claude/rules/`.
- **Promoting too eagerly.** "This applies to all projects" is a strong claim. If you can't name three unrelated projects where the rule would fire, it's project-specific.

## Review Checklist

Before accepting the additions:

- [ ] Each entry has a source hint and a date
- [ ] Each entry passes the atomic / specific / evidence-backed / non-redundant / safe / stable gates
- [ ] The `## Codified Insights` section exists exactly once in the target
- [ ] Promotion candidates (if any) have been flagged, not silently promoted
- [ ] `--dry-run` was used at least once if the target file is under active template management (e.g. bundled CLAUDE.md from rulesets install)

## Maintenance

`CLAUDE.md` accumulates over time. Periodically:

- **Consolidate.** Entries marked `(candidate for consolidation)` deserve a look. Often the older entry is superseded; sometimes it's a special case of the newer one.
- **Retire.** Entries about deprecated tools or obsolete versions should be removed explicitly (with a commit message noting the retirement).
- **Promote.** Re-scan for entries that have started firing across multiple projects — those belong in `~/code/rulesets/claude-rules/`.
- **Trim.** If the section grows past ~40 entries, either the project is complex enough to warrant splitting `CLAUDE.md` into multiple files, or the entries haven't been curated aggressively enough.

## Theoretical Background

The grow-and-refine / evidence-backed approach draws on Agentic Context Engineering (Zhang et al., *Agentic Context Engineering: Evolving Contexts for Self-Improving Language Models*, arXiv:2510.04618). Key ideas borrowed:

- **Generation → Reflection → Curation** as distinct phases, not a single compression step
- **Grow-and-refine** — accumulate granular knowledge rather than over-compressing to vague summaries
- **Avoiding context collapse** — resist the temptation to rewrite old entries into smoother prose; specificity is the value

This skill implements the Curation phase. Reflection and Generation happen in the main conversation.

## Content scope

Output this skill produces that gets committed or shared with the team must follow the *Content scope for public artifacts* rule in [`commits.md`](../claude-rules/commits.md): no local paths, no private repo names, no personal tooling references.
