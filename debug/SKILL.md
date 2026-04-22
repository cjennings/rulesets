---
name: debug
description: Investigate a bug or test failure methodically through four phases — understand the symptom (reproduce, read logs, locate failure point, trace data flow), isolate variables (minimal repro, bisect), form and test hypotheses, then fix at the root. Captures evidence before proposing fixes; rejects shotgun debugging; escalates to architectural investigation after three failed fix attempts. Use when the failure mode is unclear, the failure reproduces inconsistently, or you're about to start guessing. Do NOT use for clear local bugs where the fix site is obvious (just fix it), for ticket-driven implementation work with a known fix (use start-work), for backward-walking a specific error up the call stack (use root-cause-trace), or for process/organizational root-cause analysis of recurring incidents (use five-whys). Companion to start-work / root-cause-trace / five-whys — debug is the broad investigative workflow; the others specialize.
---

# /debug — Systematic Debugging

Investigate a bug or test failure methodically. No guessing, no shotgun fixes.

## Usage

```
/debug [description of the problem]
```

If no description is given, prompt the user to describe the symptom.

## Instructions

Work through four phases in order. Do not skip to a fix.

### Phase 1: Understand the Symptom

1. **Reproduce the failure** — run the failing test or trigger the bug. Capture the exact error message, stack trace, or incorrect output. If you can't reproduce it, say so — don't guess.
2. **Check logs and observability** — review application logs, error tracking, and metrics around the time of failure. For deployed services, check structured logs, APM traces, and alerting dashboards. Logs often reveal context that code reading alone cannot.
3. **Locate the failure point** — identify the exact file and line where the error occurs. Read the surrounding code. Understand what the code is trying to do, not just where it fails.
4. **Trace the data flow** — follow the inputs from their origin to the failure point. Read callers, callees, models, serializers, and middleware in the path. Understand how the data got into the state that caused the failure.

Do not propose any fix during this phase. You are gathering evidence.

### Phase 2: Identify the Root Cause

5. **Ask "why?" at least three times** — if a value is wrong in a view, why? Because the service returned bad data. Why? Because the model query missed a filter. Why? Because the migration didn't add the index. That's the root cause.
6. **Check for related symptoms** — search for similar patterns elsewhere in the codebase. If the bug is in one endpoint, check sibling endpoints for the same mistake. Bugs often travel in packs.
7. **Form a hypothesis** — state the root cause clearly: "The bug is caused by [X] in [file:line] because [reason]." If you have multiple hypotheses, rank them by likelihood.

### Phase 3: Verify the Hypothesis

8. **Write a failing test** that proves your hypothesis — the test should fail for the reason you identified, not just any reason. If the test passes, your hypothesis is wrong. Go back to Phase 2.
9. **Confirm the test fails for the right reason** — read the failure output. Does it match your hypothesis? A test that fails for a different reason than expected is not evidence.

### Phase 4: Fix and Verify

10. **Write the minimal fix** — change only what is necessary to address the root cause. Do not refactor, clean up, or improve adjacent code.
11. **Run the failing test** — confirm it passes.
12. **Add boundary and error case tests** — cover edge cases around the fix.
13. **Run the full test suite** — confirm no regressions.
14. **Commit** following conventional commit format.

## Escalation Rule

If you've attempted 3 fixes and the bug persists, stop. The problem is likely architectural, not local. Report what you've learned and recommend a broader investigation rather than attempting fix #4.

When fanning out investigation across multiple independent files or subsystems, follow `subagents.md` — use parallel read-only agents for exploration, never for concurrent writes, and dispatch a fresh fix-agent on failure rather than retrying in the main context.

## What Not to Do

- Don't propose fixes before completing Phase 2
- Don't change multiple things at once — isolate variables
- Don't suppress errors or add try/catch to hide symptoms
- Don't add logging as a fix (logging is a diagnostic, not a solution)
- Don't delete or skip a failing test to "fix" the suite
