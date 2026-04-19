---
name: root-cause-trace
description: Given an error that manifests deep in the call stack, trace backward through the call chain to find the original trigger, then fix at the source and add defense-in-depth at each intermediate layer. Covers the backward-trace workflow (observe symptom → identify immediate cause → walk up the chain → find origin → fix + layer defenses), when and how to add instrumentation (stack capture before the dangerous operation, not after), and the bisection pattern for identifying which test pollutes shared state. Use when an error appears in the middle or end of an execution path, when a stack trace shows a long chain, when invalid data has unknown origin, or when a failure reproduces inconsistently across runs. Do NOT use for clear local bugs where the fix site is obvious (just fix it), for design-level root-cause analysis of processes/decisions (use five-whys instead), for performance regressions (different class of investigation), or when there's no symptom yet to trace from. Companion to the general `debug` skill — `debug` is broader; `root-cause-trace` is specifically the backward-walk technique.
---

# Root-Cause Trace

Bugs often surface far from their origin. The instinct is to patch where the error appears. That usually hides the real problem and leaves the next victim to find it again. This skill documents the systematic backward walk to the actual trigger, plus the defense layers that make the bug impossible rather than merely fixed.

## Core Principle

**Trace backward through the call chain until you find the original trigger. Fix at the source. Add validation at each intermediate layer that could have caught it.**

Fixing only the symptom creates debt. The same invalid value will flow into the next downstream call site eventually.

## When to Use

- The error appears deep in execution, not at the entry point
- A stack trace shows a long chain and it's unclear which level introduced the problem
- Invalid data's origin is unknown — "how did this null / empty / wrong value get here?"
- A failure reproduces inconsistently and seems to depend on earlier state
- You catch yourself about to "just add a null check" without knowing why it's null

## When NOT to Use

- Simple, local bugs where the fix site is obvious (just fix it; don't over-engineer)
- Root-cause analysis of processes, decisions, or organizational issues (use `five-whys`)
- Performance regressions — different kind of investigation (profiling, benchmarking)
- You have no concrete symptom yet; you're still hunting for the bug — use general `debug` first

## Workflow

Five steps. Don't skip any; each changes what the next is looking for.

### 1. Observe the Symptom

State the symptom precisely. Paste the error. Note where it occurred.

```
Observed: `TypeError: Cannot read property 'name' of undefined`
  at  src/service/order.ts:142  in  formatOrderLine()
```

Precision matters because the next step depends on *exactly* what failed.

### 2. Identify the Immediate Cause

What code directly produced the error? Not the root cause — the thing right before the failure.

```
formatOrderLine(order) {
  return `${order.customer.name} — ${order.total}`;  // ← here
}
```

Immediate cause: `order.customer` is undefined. The formatting line runs on a malformed order.

### 3. Walk the Call Chain Up

Ask: *what called this, and with what arguments?*

```
formatOrderLine(order) ← called from renderInvoice(orderList)
  → orderList came from fetchOrders()
    → fetchOrders() came from the cron job handler
      → the cron job handler received an empty list and mapped over it
```

At each level, note:

- Which function called the next
- What argument / value was passed
- Was the value wrong at this level or did it look OK?

Keep walking until you find the point where the value *became* wrong.

### 4. Find the Original Trigger

The trigger is the point where reality diverged from the expected state. Examples:

- A config default was empty, and nothing validated it
- A test fixture was accessed before its setup hook ran
- An API response changed shape and no parser rejected the old shape
- A database row was written in a partial state

State the trigger in one sentence:

```
Trigger: `orderList` was `[undefined, ...]` because the database query used
`LEFT JOIN` where `INNER JOIN` was intended; customer-less orders entered the
result set for the first time after the Oct 2 schema change.
```

Now you understand the bug.

### 5. Fix at the Source, Then Add Defense

Two actions, in order:

**a. Fix at the trigger.** In the example: change the query to `INNER JOIN`, or explicitly handle customer-less orders (depending on intent).

**b. Add defense-in-depth.** For each layer between the trigger and the symptom, ask: *could this layer have caught the bad value?* If yes, add the check.

- Parser/validator layer: reject rows without `customer_id`
- Service layer: throw if `order.customer` is nil instead of passing it downstream
- Formatter layer: render "Unknown customer" rather than crashing

Each defense means the next time something similar happens, it surfaces earlier and with better context. The goal isn't any single check — it's that the bad value can't propagate silently.

## Adding Instrumentation

When the chain is long or the trigger is hard to identify, add stack-capturing logs **before** the suspect operation, not after it fails.

Capture, at minimum:

- The value being operated on
- The current working directory / environment / relevant globals
- A full stack trace via the language's native mechanism

Language examples:

```typescript
// Before calling a function that might fail
function callDangerousOp(arg: string) {
  console.error('TRACE dangerous-op entry', {
    arg,
    cwd: process.cwd(),
    nodeEnv: process.env.NODE_ENV,
    stack: new Error().stack,
  });
  return dangerousOp(arg);
}
```

```python
import traceback, logging

def call_dangerous_op(arg):
    logging.error(
        "TRACE dangerous-op entry: arg=%r cwd=%s\n%s",
        arg, os.getcwd(), ''.join(traceback.format_stack())
    )
    return dangerous_op(arg)
```

```go
func callDangerousOp(arg string) error {
    log.Printf("TRACE dangerous-op entry: arg=%q stack=%s", arg, debug.Stack())
    return dangerousOp(arg)
}
```

**Tactical rules:**

- **Use stderr / equivalent, not framework loggers.** In tests, the framework logger is often suppressed or buffered; stderr survives.
- **Log before the dangerous operation, not after.** If the op crashes, post-call logs never fire.
- **Include enough context.** The value alone isn't enough; you need cwd, relevant env, and the full stack.
- **Name the trace uniquely.** `grep TRACE dangerous-op` should find only these lines.

## Identifying Test Pollution

When a failure appears during a test run but the offending test is unclear, bisect:

1. Run tests one at a time, in file order, until the failure first appears
2. The failure's first-appearance test is either the polluter, or ran after the polluter and observed the polluted state

A small shell helper can automate:

```bash
# For each test file, run it and check for the pollution symptom.
# Replace the symptom-check with something specific to your failure.
for t in tests/test-*.el; do
  clean_state
  run_test "$t" >/dev/null 2>&1
  if symptom_present; then
    echo "First symptom after: $t"
    break
  fi
done
```

Once identified, trace backward (steps 2-4 above) from the polluting operation.

## Real-World Patterns

- **Empty string as path.** An uninitialized or early-read config value often presents as `""`. Many system calls silently treat `""` as `.` or the current directory. Symptom: file appears in an unexpected place. Trigger: a getter was accessed before its initializer ran.
- **Stale cache / wrong TTL.** Symptom: new code behaves like old code. Trigger: a cached value from before the change is still live.
- **Partial write / torn state.** Symptom: data looks half-correct. Trigger: a multi-step write wasn't atomic and crashed between steps.
- **Fixture access ordering.** Symptom: test fails only when run alone or only when run with others. Trigger: a fixture is read before its setup hook or mutated by a prior test.

When you recognize one of these shapes, you can shortcut the trace — but *verify* the shape before committing to the pattern-match.

## Anti-Patterns

- **Catching the error and returning a safe default.** Now every caller gets sanitized output without knowing the upstream bug exists. Defense-in-depth means *logging and surfacing* the bad value, not silencing it.
- **Fixing at the symptom site.** You treated a symptom; the next invocation of the same flow fails the same way.
- **Adding a null check at every layer.** That's defense-by-armor, not defense-by-validation. Each check should reject and report, not coerce and hide.
- **Logging after the failure.** Post-call logs don't fire when the call crashes. Log before.
- **Using the framework logger in tests.** Buffered, sometimes redirected, often invisible. Use stderr.
- **Stopping at the first "cause" that seems plausible.** Keep asking "what made *that* happen?" until you reach the real trigger, not a convenient intermediate.

## Output

After the trace, produce a concise summary:

```
## Root Cause Trace: <short name>

**Symptom:** <what the user saw>
**Immediate cause:** <failing operation + direct reason>
**Trace chain:**
  1. formatOrderLine called with undefined customer
  2. renderInvoice passed the order through unchecked
  3. fetchOrders returned a list including customer-less orders
  4. Query used LEFT JOIN where INNER JOIN was intended (trigger)

**Fix at source:** changed query to INNER JOIN; added test for schema change.
**Defenses added:**
  - parser rejects rows without customer_id
  - service layer throws on null customer
  - formatter renders "Unknown" instead of crashing

**Memorize-worthy insight:** <if any>
```

The last line is a hand-off to `memorize` if the pattern is worth preserving.

## Hand-Off

- If the trace revealed a pattern worth preserving → run `memorize`
- If the trace revealed a process/decision failure (a check that should have existed in CI, a review that should have caught it) → run `five-whys` on the process
- If the trace revealed an architectural violation (layer boundary crossed, contract broken) → run `arch-evaluate` to see if other places have the same issue

## Key Principle — Restated

**Never fix just where the error appears.** Trace back. Fix at the trigger. Make the bug impossible rather than merely absent in this one path.
