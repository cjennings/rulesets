# Subagents — When, How, and When Not To

Applies to: `**/*`

Subagents exist to protect the main thread's context and parallelize
independent work. They are not free — every spawn pays a prompt-construction
cost and breaks the chain of context from the current conversation. Use them
deliberately, not reflexively.

## When to Spawn a Subagent

### Parallel-safe (spawn multiple in parallel)

- **Read-only investigation across independent domains** — "what uses
  function X?", "what are the three logging libraries in this repo?", etc.
  spread across different subsystems.
- **N independent test-file failures** where each is its own diagnosis.
- **Library/API research across unrelated topics** — doc fan-out.
- **Analysis scans over different parts of a codebase** — e.g. C4 diagram
  generation scanning distinct services.

### Sequential-with-review (one at a time, review between)

- **Plan-task execution** where each task may depend on the last.
- **Coupled edits** — related files that must stay in sync (schema + migration
  + seed script).
- **Anything where mid-course correction is likely** — the review gate is
  where course correction happens.

### Never Parallel

- **Concurrent writes to the same files or directories** — race conditions,
  conflicting edits, lost work.
- **Ordered edits where sequence matters** — e.g. add a config flag, then
  read it in code; don't fan these out.

### Don't Subagent At All

- **The target is already known** and the work fits in under ~10 tool calls.
- **Single-function logic** — one Read + one Edit is faster than briefing
  an agent.
- **You can see the answer from context** — don't spawn a researcher for
  something already on screen.

## Prompt Contract

Every Agent spawn must include four fields. Missing any one produces
shallow, generic work:

1. **Scope** — one bounded task, named file or domain. Not "fix the bugs"
   but "find the root cause of the NPE in `order_service.py:process_refund`."
2. **Context** — paste the relevant output, error, or prior finding. The
   subagent cannot see this conversation. If you learned something from an
   earlier turn, include it verbatim; don't paraphrase.
3. **Constraints** — explicit "do NOT" list. "Do not refactor surrounding
   code." "Do not add tests." "Do not touch files outside `src/billing/`."
4. **Output format** — what to return and in what shape. "Report root cause
   + file:line + proposed fix in under 200 words" beats "investigate this."

If you can't fill all four fields, you don't yet understand the task well
enough to delegate it. Do it yourself, or think more before dispatching.

## Context-Pollution Rule

Subagents exist to absorb noise the main thread shouldn't carry. When one
fails or produces unexpected results:

- **Do not retry the task manually in the orchestrator context.** That
  re-imports the exact noise the subagent was meant to contain — failed
  approaches, dead ends, irrelevant exploration.
- **Dispatch a fix subagent** with the failure report as its context
  (paste the subagent's output verbatim). New scope, fresh context.
- **If two fix attempts fail**, stop and surface the problem to the user.
  Don't keep spawning.

The corollary: if you're tempted to "just quickly fix it myself after the
agent failed," you are about to pollute your context. Dispatch.

## Review-Gate Cadence

Subagent output is not verified work — it's a claim about what was done.
Review before moving on:

- **Sequential execution** — review after each task completes. Read the
  diff, run the relevant tests, confirm the claim matches reality (see
  `verification.md`). Then spawn the next task.
- **Parallel execution** — review after every batch of ~3 tasks. Larger
  batches compound bugs; smaller batches make review overhead dominate.
- **Never chain subagents past a failed review.** If the review finds a
  problem, dispatch a fix subagent before continuing the plan.

## Delegation vs Understanding

Subagents execute; they do not understand *for you*. Never write prompts
like:

- "Based on your findings, fix the bug" — synthesis pushed onto the agent
- "Investigate and implement" — scope too broad, no contract

Do the understanding step yourself (read the agent's report, decide the
fix), then dispatch the fix with a specific contract.

## Anti-Patterns

- **Parallel implementation agents on overlapping files** — they will
  conflict. Fan-out is for investigation, not concurrent writes.
- **Broad prompts** — "fix the failing tests" sends the agent exploring;
  "fix the assertion at `test_cart.py:142`" gets a diff.
- **Timeout-tuning to quiet flaky tests** — the flake is usually a race
  condition. Diagnose, don't mask.
- **Retrying a failed subagent task in the orchestrator** — pollutes
  context. Dispatch a fix agent instead.
- **Subagenting trivial work** — one Read + one Edit doesn't need an
  agent; spawn overhead exceeds benefit.
- **Skipping review between tasks** — compounding bugs are much harder to
  unwind than any single bug.
- **Letting the agent decide scope** — "figure out what needs changing"
  produces sprawling, unfocused work. You decide scope; the agent
  executes it.

## Cross-References

- Completion claims must be verified regardless of who produced them —
  see `verification.md`.
- Testing discipline applies to subagent-produced tests too — see
  `testing.md`.
