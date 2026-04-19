---
name: brainstorm
description: Refine a vague idea into a validated design through structured one-question-at-a-time dialogue, diverse option exploration (three conventional + three tail samples), and chunked validation (200-300 words at a time). Produces `docs/design/<topic>.md` as the output artifact. Use when shaping a new feature, service, or workflow before implementation begins — or when a "we should probably…" idea needs to become concrete enough to build. Do NOT use for mechanical well-defined work (renames, reformats, dependency bumps), for system-level architecture choices (use arch-design), for recording a single decision that has already been made (use arch-decide), or for debugging an existing error (use root-cause-trace or debug). Synthesized from the Agentic-Context-Engineering / SDD brainstorm pattern — probabilistic diversity sampling originated there.
---

# Brainstorm

Turn a rough idea into a design document concrete enough to implement. One question at a time, diverse options considered honestly, design validated in chunks.

## When to Use

- Shaping a new feature, component, service, or workflow before code exists
- Translating "we should probably …" into something buildable
- Converting a noticed-but-unshaped problem into a design
- Exploring whether an idea is worth building before committing to it

## When NOT to Use

- Mechanical, well-defined work (rename, reformat, upgrade a dependency, apply a migration)
- System-level architecture (use `arch-design`)
- Recording a specific decision already made (use `arch-decide`)
- Debugging an existing error (use `root-cause-trace` or `debug`)
- Writing code whose shape is already clear to you

## Workflow

Three phases. Each converges a little more. Each is validated before moving to the next.

### Phase 1 — Understand the Idea

Dialogue, not interrogation. Before the first question, read the project context: the relevant directory, recent commits, any existing docs, the language and stack. Ground your questions in what's already there.

**Rules:**

- **One question per message.** Never batch. Respondents answer the easiest question and skip the rest when you batch.
- **Prefer multiple choice.** Easier to answer, faster to skim, surfaces the option space for free.
- **Open-ended when the option space is too large to enumerate.** Then refine with follow-ups.
- **Focus the first questions on purpose, not mechanism.** Mechanism comes in phase 2.

**Topics to cover (not a script — skip what's already clear):**

- What problem does this solve?
- Who is the user or caller?
- What's the smallest version that would be useful?
- What's explicitly out of scope?
- What are the success criteria (measurable if possible)?
- What constraints apply — team size, timeline, existing code, stack?

**Stop when** you can state the idea back in one sentence and the user confirms. Don't keep asking for the sake of thoroughness.

### Phase 2 — Explore Approaches

Before committing to a direction, generate **six candidate approaches**. Force diversity.

**Composition:**

- **Three conventional approaches** — the paths a reasonable engineer with relevant experience would consider. Each has a high prior probability of being right (roughly ≥80%).
- **Three tail samples** — approaches from genuinely different regions of the solution space. Each individually unlikely (roughly ≤10%), but together they expand what's been considered. These are the ones that surprise.

Why tail samples matter: most teams converge on the first conventional option. The tail samples either reveal a better solution you hadn't considered, or they clarify *why* the conventional option is the right one. Either way, the recommendation that follows is stronger.

**For each candidate, state:**

- One-paragraph summary
- Honest pros
- Honest cons (no selling; if you can't name real cons, you haven't thought hard enough)

**End with:**

- Your recommendation
- Why — explicit mapping to the constraints and success criteria from phase 1
- What's being traded away
- What becomes an open decision for `arch-decide` later

### Phase 3 — Present the Design

Once a direction is chosen, describe it in **200-300 word chunks**. After each chunk, ask "does this look right so far?" Never dump a wall of design prose — the user skims walls.

**Typical sections, one chunk each:**

1. **Architecture** — components, boundaries, key interfaces
2. **Data flow** — what moves through where, in what shape
3. **Persistence** — what's stored, where, for how long, with what durability
4. **Error handling** — expected failures, responses, user-facing behavior
5. **Testing approach** — what correctness means here, how it gets verified
6. **Observability** — what gets logged, measured, traced

Skip sections that don't apply. Add domain-specific ones (auth flow, concurrency model, migration plan, rollout strategy) where relevant.

**Be willing to back up.** If a chunk surfaces a question that invalidates an earlier chunk, revise. Committing to a wrong direction to avoid rework is the expensive path.

## Output

Write the validated design to `docs/design/<topic>.md`. Use this skeleton (omit sections that don't apply):

```markdown
# Design: <topic>

**Date:** <YYYY-MM-DD>
**Status:** Draft | Accepted | Implemented

## Problem

One paragraph. What, who, why now.

## Non-Goals

Bullet list of what this explicitly does not address. Prevents scope creep.

## Approaches Considered

### Recommended: <name>

Summary, pros, cons.

### Rejected: <name>

Why not. Brief.

(Include 2-3 rejected options — showing alternatives were weighed is itself valuable.)

## Design

### Architecture

### Data Flow

### Persistence

### Error Handling

### Testing

### Observability

## Open Questions

Items that need decisions before or during implementation.

- [ ] Question — likely candidate for an ADR via `arch-decide`
- [ ] Question — …

## Next Steps

- Open questions → `arch-decide`
- If this implies system-level structural change → `arch-design`
- Implementation → <agreed next action>
```

If `docs/design/` doesn't exist, create it. If a design with the same topic name exists, ask before overwriting.

## Hand-Off

After the design is written and agreed:

- **Each open question** → run `arch-decide` to record as an ADR
- **System-level implications** → run `arch-design` to update the architecture brief
- **Implementation** → whatever the project's implementation path is (`fix-issue`, `add-tests`, or direct work)

Link the design doc from wherever it's being implemented (PR description, ticket, commit).

## Review Checklist

Before declaring the design accepted:

- [ ] Problem stated in one paragraph that a newcomer could understand
- [ ] Non-goals listed (at least 1-2)
- [ ] At least 6 approaches considered, with 3 genuinely in the tail
- [ ] Recommendation names what it's trading away
- [ ] Each design chunk was individually validated
- [ ] Open questions listed; each has a clear path forward
- [ ] User has confirmed the design reflects their intent

## Anti-Patterns

- **Asking three questions in one message.** The user answers the easiest. Ask one.
- **Leading questions.** "Don't you think Postgres is right here?" isn't exploration.
- **Skipping tail samples.** If all six options are minor variations on the conventional answer, diversity wasn't actually attempted.
- **Dumping the whole design at once.** Eight hundred words without validation checkpoints means the user skims and misses the thing they'd want to push back on.
- **Hiding trade-offs.** Every approach has real cons. State them or the evaluation is theatre.
- **"We'll figure it out in implementation."** If a design question is ducked here, it becomes a larger, costlier problem during coding. Resolve now or explicitly defer with an ADR.
- **Over-specifying.** The design should be detailed enough to implement, not so detailed it's already the implementation. If you're writing function bodies in the design, stop.

## Key Principles

- **One question at a time.** Non-negotiable.
- **Multiple choice beats open-ended** when the option space is small enough to enumerate.
- **Six approaches, three in the tail.** Discipline around diversity.
- **Validate in chunks.** 200-300 words, then check.
- **YAGNI ruthlessly.** Remove anything not justified by the problem statement.
- **Back up when needed.** Revising early beats committing to wrong.
