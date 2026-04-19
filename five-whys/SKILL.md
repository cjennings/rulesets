---
name: five-whys
description: Drive iterative "why?" questioning from an observed problem to its actual root cause, then propose fixes that target the root rather than the symptom. Default depth is five, but the real stop condition is reaching a cause that, if eliminated, would prevent every observed symptom in the chain — that may take three whys or eight. Handles branching (multiple contributing causes, each explored separately), validates the chain by working backward from root to symptom, and rejects "human error" as a terminal answer (keep asking why the process allowed that error). Use for process, decision, and organizational failures — missed code reviews, recurring incidents, slow deploys, flaky releases, "we've fixed this three times already" problems. Do NOT use for debugging a stack trace (use root-cause-trace, which walks the call chain), for tactical defect investigation where the fix site is local and obvious, or for blame attribution (the skill refuses to terminate at a person). Companion to root-cause-trace — that's for code execution; this is for process/decision root-causes.
---

# Five Whys

A structured way to drive from a visible symptom to the underlying cause, and from there to a fix that prevents the whole class rather than the single instance. Simple, old, still works — provided the stop condition is real root cause, not the fifth why.

## Core Idea

Start with what happened. Ask why it happened. The answer becomes the next "what." Ask why again. Repeat until further questioning stops producing new information — that's the root. Then fix *there*, not at the symptom.

Five is a convention, not a quota. Some chains terminate at three; others need eight. The depth isn't the point; reaching a cause that, if eliminated, prevents every symptom in the chain is the point.

## When to Use

- Process failures: a code review missed something important; a deploy broke prod; a release was late
- Recurring incidents: "we've fixed this three times already"
- Organizational / workflow issues: CI is slow; PRs pile up; on-call gets paged at the same time of night
- Decision post-mortems: a choice was made that later proved wrong; why was that choice available / appealing / undetected?

## When NOT to Use

- Debugging a stack trace (use `root-cause-trace` — different technique, walks the call chain, not the causal chain)
- Local defect fixes where the fix site is obvious (just fix it)
- Blame-finding exercises — this skill actively rejects "human error" as a terminal answer
- Situations where there's genuinely no causal chain (a truly random hardware failure doesn't have five whys)

## Workflow

### 1. State the Problem Precisely

Fuzzy problems produce fuzzy answers. Write the observed fact in one sentence. Include when, what, measurable impact.

Good: "The 2026-04-17 release was rolled back at 14:02 after the cart-checkout endpoint returned 500 on ~8% of traffic."

Bad: "Our releases are flaky."

### 2. Ask Why — One Answer

Not three possible answers. One best-supported answer, based on evidence you can point to. If the question genuinely has multiple independent causes, you'll branch in step 4.

```
Why did the release roll back?
  → The cart-checkout endpoint returned 500 on ~8% of traffic.
```

### 3. Take the Answer as the New Question

```
Why did cart-checkout return 500?
  → The database query for inventory timed out under load.

Why did it time out under load?
  → Query plan changed; a new index wasn't picked up.

Why wasn't the index picked up?
  → The query uses a function on an indexed column; the index wasn't a functional index.

Why was that only a problem now?
  → Traffic crossed the threshold where the non-functional scan dominates.
```

Four whys in; we've gone from "release rolled back" to "missing functional index for an 8-month-old query."

### 4. Branch When Honest

Some chains fork. When an answer is *and* rather than *just*, explore each branch separately.

```
Why wasn't this caught in testing?
  → (a) Staging load is 1/100 of production
  → (b) The index was added during a migration that didn't run in staging

Pursue (a): Why is staging load so low?
  → Staging runs on cheaper infra; no one funded realistic load testing.
    → Organizational: load-test budget not in ops budget.

Pursue (b): Why did the migration not run in staging?
  → Migrations run manually per-env; nobody ran it in staging.
    → Process: manual migrations are fragile; no automation requires them pre-prod.
```

Each branch gets its own root. The eventual fix usually touches more than one.

### 5. Validate by Walking Backward

Once a chain looks complete, walk it from root to symptom. If each step produces the next, the chain is sound.

```
No functional index on an indexed-column function
  → query plan scans the column under load
  → query times out under load
  → cart-checkout returns 500
  → release rolls back
```

Every arrow should read as "therefore." If one doesn't, the chain has a gap — a why you skipped or an answer that wasn't actually the cause.

### 6. Reject Convenient Stops

Stop conditions that seem terminal but aren't:

- **"Human error."** Always has a why behind it. *Why* did the system allow the human error? *Why* was the error easy to make? "Alice forgot to run the migration" isn't root — the root is "migration execution was manual, undocumented, and unchecked."
- **"Budget / staffing."** Often correct at *some* level, but almost never the deepest cause. *Why* wasn't this funded? *Why* wasn't it prioritized? The answer may be organizational (we don't track incident cost well) or informational (the bug's frequency wasn't visible).
- **"Just a one-off."** If it happened once, you don't need this skill. You're using this skill because the problem is patterned.

Keep asking until the cause is a missing mechanism (a check, an automation, a doc, a visibility tool) — not a person and not a shortfall of will.

### 7. Propose Fixes at the Root

For each root cause found, propose a fix that's structural. Good fixes are almost always one of:

- A **check** added to a pipeline that would have caught the issue
- An **automation** that removes a manual step where the error occurred
- A **documentation / onboarding change** that makes the requirement discoverable
- A **visibility tool** (dashboard, metric, alert) that would have surfaced the problem earlier

Fixes that treat symptoms (adding a try/except, a retry, a "remember to X" in the runbook without a mechanism to enforce X) are not root-cause fixes — they're patches.

## Output

Produce a short markdown report:

```markdown
## Five Whys: <incident / problem name>

**Problem:** <one-sentence precise statement>

**Chain:**

1. Why did X happen?
   → <answer>
2. Why did that happen?
   → <answer>
3. ...
4. Root: <root cause>

**Branches** (if any):

- Branch A: <fork question> → ... → Root A
- Branch B: <fork question> → ... → Root B

**Validation (backward):**

Root → step N → step N-1 → … → symptom. Each step follows.

**Root-cause fixes:**

- [ ] <Structural fix at Root A> — who / when
- [ ] <Structural fix at Root B> — who / when

**Not fixes (patches to avoid):**

- <what NOT to do as a substitute for root-cause work>
```

## Anti-Patterns

- **Stopping at exactly five whys.** Five is a convention, not a stop condition. Stop when further questioning yields no new information.
- **Accepting "human error" as root.** Always has a deeper why — the system that allowed the error.
- **Skipping a why because the answer feels obvious.** Write it down. Obvious answers sometimes reveal themselves as wrong when explicit.
- **One answer per why when honest branching is present.** Fork when the chain really forks.
- **Fix that adds a runbook entry.** Runbook entries without enforcement are a wish, not a fix.
- **Blaming the tool or vendor.** Sometimes true, but usually there's a why upstream about why the tool was chosen or why its behavior wasn't validated.
- **Confusing this with a stack-trace walk.** Different technique, different skill (`root-cause-trace`). This one is for process and decision chains, not code execution chains.

## Related Patterns

- **Plan → Do → Check → Act** — iterative improvement cycle after root-cause work; useful for systemic changes that can't be one-shot. Not covered by this skill; do the PDCA manually when the root-cause fix is itself a multi-week program.
- **Cause-and-effect / Ishikawa diagram** — useful when a problem has many contributing factors and you need to categorize before drilling. Five whys works well *inside* each branch of an Ishikawa.
- **`root-cause-trace`** — the code-execution counterpart. Use that for stack-trace bugs; use this for process / decision bugs.

## Hand-Off

- **Root-cause fix is structural and well-scoped** → implement it; add tests / checks / automation as relevant
- **Root-cause fix is a multi-week program** → open a tracking issue; assign; consider applying PDCA cycles to its rollout
- **Several whys revealed preserveable insights** → run `memorize` to capture the patterns
- **Root is architectural** → run `arch-evaluate` to see if the same structural gap exists elsewhere

## Key Principles

- **Precision in the problem statement.** One sentence. Measurable. When, what, how bad.
- **One best-supported answer per why** — or an honest branch, not a shrug.
- **Keep asking until the cause is a missing mechanism, not a person.**
- **Validate backwards.** "Therefore" should read plausibly at every step.
- **Fix at the root.** Structural changes, not patches.
