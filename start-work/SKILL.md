---
name: start-work
description: Pick up a task (Linear ticket, GitHub issue, todo.org task, or a described scope) and take it through Claim, Justify, Approach, Implement, Verify, and Hand-off. Three user-approval gates separate the phases. The Justify gate covers benefits, costs, engineer/user impact, urgency, effort, alternatives, and a ticket-quality check. The Approach gate covers root cause, risk, refactor prerequisites, test strategy (unit, integration, e2e, pairwise, characterization), migration and backwards-compat, feature-flag question, commit decomposition, and branch name. Implementation uses TDD (red, green, edge cases, refactor pass). A verify phase exercises the feature end-to-end in the local environment (Playwright against localhost for web projects, scripted manual test otherwise) before the final gate confirms readiness and hands off to the Review-and-Publish flow in commits.md. Use when starting work on a specific task where both "should we" and "how exactly" are worth deliberating. Do NOT use for open-ended bug investigation without a clear target (use debug first), for architectural paradigm exploration (use arch-design), for architectural decision recording (use arch-decide), when the task is trivial and obvious (just do it), or when requirements are still being shaped (use brainstorm).
---

# /start-work: pick up a task, justify it, plan it, build it

Three review gates separate the phases. The user can redirect or kill the work at each one.

1. **Claim.** Mark in-progress, assign, label, verify project.
2. **Justify (gate 1).** Benefits, costs, impact, urgency, effort, alternatives, ticket quality. Stop for approval.
3. **Approach (gate 2).** Root cause, risk, tests, migration, flag, commit decomposition. Stop for approval.
4. **Implement.** TDD red, green, edge cases, refactor pass.
5. **Verify.** End-to-end or scripted manual test in the local environment.
6. **Ready to commit (gate 3).** Report, stop for approval.
7. **Hand off** to the Review-and-Publish flow in `commits.md`.

## Usage

```
/start-work <task-ref>
```

`<task-ref>` can be:

- A Linear ticket ID or URL: `SE-170`, `https://linear.app/deepsat/issue/SE-170`
- A GitHub issue URL or number
- A todo.org heading reference or description: `todo.org:mission-sync refactor`
- A free-form scope description: "update the mission-card fallback"

If the reference is ambiguous, ask the user to clarify before proceeding.

## Phase 0: eligibility

Skip with a short note and stop if any apply:

- Task is already Done, closed, or merged.
- Task is assigned to someone else and the user has not asked to take it over.
- Task is an obvious duplicate of something in-progress.
- Task description is so vague that even the Justify gate cannot engage. Route to `/brainstorm`.

## Phase 1: claim

Make ownership explicit before any other work starts. The exact steps depend on where the task lives.

### Linear ticket

1. Fetch the ticket with the Linear MCP tools.
2. Move status to **In Progress**.
3. Assign the user. If another assignee is already present, add the user as a second assignee. If the Linear API does not accept multiple assignees, post a comment ("Picking this up alongside <existing assignee>") and proceed.
4. Verify the ticket has exactly one of these labels: **Bug**, **Test**, **Chore**, or **Feature**. If missing or wrong, ask the user which applies and set it.
5. Verify the ticket's project. If unset or wrong, ask the user which project it belongs to.

### GitHub issue

1. Fetch with `gh issue view <n> --json title,body,state,assignees,labels`.
2. Assign to the user: `gh issue edit <n> --add-assignee @me`.
3. Verify the Bug / Test / Chore / Feature label. Add if missing.
4. Post a comment noting you are starting work.

### Todo.org task

1. Locate the heading the user referenced.
2. Change the TODO keyword to `DOING`.
3. Add exactly one tag: `:bug:`, `:feature:`, `:test:`, or `:chore:`. Ask the user which applies if none is obvious. Todo.org is personal, so there is no assignee step.

### Unticketed

1. Note in the session that the work is unticketed.
2. Ask the user whether to create a ticket or issue retroactively before continuing. If no, proceed but flag in the final commit message that there is no linked ticket.

## Phase 2: justify (gate 1)

Read the task description end to end. Skim the code it references.

Then produce a justification that covers all of these, concisely:

1. **Benefits.** What is better after this lands? Concrete, not abstract.
2. **Costs.** Time, risk, reviewer bandwidth, ceremony overhead.
3. **Engineer impact.** Does it make someone's life easier? Catch a class of bug? Remove friction?
4. **End-user impact.** Behavioral change? Visible? Invisible-but-protective?
5. **Downsides.** What do we lose? Where would we regret doing this?
6. **Urgency and priority fit.** Does this align with current goals or an upcoming deadline? If the project has committed deadlines, explicitly check this against them. Anything not obviously on the critical path should be called out as "deferrable."
7. **Effort estimate.** S (under 1 hour), M (1 hour to 1 day), L (over 1 day). Rough is fine.
8. **Alternatives considered.** Is there a cheaper way? Can we defer? Can we address the root cause via a different path?
9. **Ticket quality check.** Is scope clear, are acceptance criteria concrete, are reproduction steps present for bugs? If **not clear**, stop and ask the user to choose one of:
   - (a) Bounce to `/brainstorm` to refine the ticket first.
   - (b) Ping the ticket author for clarification.
   - (c) Supply the missing info themselves right now, if it is easy for them to do so.

### Gate

Present the justification to the user. Stop. Wait for questions and explicit approval ("approved", "proceed", or equivalent) before starting Phase 3.

Do not generate the approach while waiting. The user may kill the task at this gate, and any pre-generated approach would be wasted work.

If the user kills the task, roll back the Phase 1 claim: move the ticket back to its prior status, remove the assignment you added, and remove the label you added (if any).

## Phase 3: approach (gate 2)

Read the referenced code end to end. Understand the surrounding context: callers, callees, existing tests, adjacent modules.

Then produce an approach that covers:

1. **Root cause.** For bugs, where the bug originates, not just where it surfaces. For features, which layer owns the new behavior.
2. **Code that changes.** Files and functions, with a rough line-count estimate.
3. **Risk.** Who and what does this affect? Local (one file) or does it ripple? Flag anything that touches shared state, public APIs, or core data flow.
4. **Refactor prerequisites.** Does the codebase need restructuring before this fix is easy? If yes, that is a separate ticket and should be done first.
5. **Characterization tests.** If modifying existing untested code, write characterization tests first to lock behavior before changing it (see `testing.md`).
6. **Test strategy decomposition.** Which of these are needed, and roughly how many of each:
   - Unit tests.
   - Integration tests.
   - E2E tests.
   - Pairwise or combinatorial tests, if parameter-heavy (see `/pairwise-tests`).
7. **Migration and backwards-compat surface.** DB migration? API contract change? Frontend consumer impact? Config shape change? Flag if yes and describe the scope.
8. **Feature flag.** Does this ship behind a flag or direct? Always worth asking once.
9. **Commit decomposition.** One commit, or N commits? Each commit should be one logical change per `commits.md`. Size the Review-and-Publish ceremony ahead of time.
10. **Branch name.** Following the project convention: `fix/<ID>-slug`, `feature/<ID>-slug`, `chore/<ID>-slug`, or `test/<ID>-slug`. Unticketed work uses a short descriptive slug.

### Gate

Present the approach to the user. Stop. Wait for questions and explicit approval before starting Phase 4.

If the user redirects the approach, update the plan and re-present rather than silently adjusting during implementation.

## Phase 4: implement (TDD)

Follow the red-green-refactor cycle from `testing.md`.

1. **Create the branch** using the name decided in Phase 3.
2. **Red.** Write a failing test that demonstrates the bug or captures the new desired behavior. Run it. Confirm it fails for the right reason, not because the test itself is broken. Commit as `test: <desc>`.
3. **Green.** Write the minimal code to make the test pass. Do not generalize yet. Do not add features the test does not require. Commit as `fix:` or `feat:`.
4. **Edge cases.** Add tests in all three categories per `testing.md`:
   - Normal: happy path, typical input.
   - Boundary: empty inputs, nulls, minimum and maximum values, single-element collections, Unicode, long strings, time and timezone boundaries, concurrent access.
   - Error: invalid inputs, missing required parameters, permission denied, resource exhaustion, malformed data, network failures.
   Commit as `test: add edge cases for <desc>`.
5. **Refactor pass.** After tests are green, do a deliberate pass over the code you wrote or touched in this task. Keep tests green throughout. If they go red during the pass, you have changed behavior, not just form — stop and decide whether the change is intentional before proceeding.

   Review each of the following, in order. The checklist is language-agnostic. The same smells appear in Python, TypeScript, Go, Elisp, Rust, shell, SQL, and anything else.

   a. **Stale documentation.** Comments, docstrings, file headers, module-level summaries, READMEs, ADRs, architectural diagrams, or any prose that now contradicts the code. Update or delete. Prefer deletion when the documentation duplicates what the code, the tooling, or the runtime config already communicates — duplicated information is rotted documentation waiting to happen. The test: if a future reader would learn nothing from the doc that the code does not already say, drop it.

   b. **Duplication.** Three distinct kinds:
      - *Logic duplication*: the same computation or control flow appearing in multiple places. Extract when it appears three or more times, or when the duplication crosses an abstraction boundary, or when a future divergence between the copies would be a real bug. Two occurrences of a simple expression usually does not justify extraction. Three similar lines beats a premature abstraction.
      - *Literal duplication*: repeated strings, regexes, magic numbers, paths, URLs, error codes, keywords — any value that would need to change together. A shared constant is cheap insurance and makes the intent explicit.
      - *Intra-function expression duplication*: the same non-trivial expression evaluated twice inside one scope. Bind it to a local name once. Shorter function and no risk of the two expressions drifting apart when someone edits one.

   c. **Naming drift.** Names that describe what the identifier used to do, not what it does now. Names that mix abstraction levels (a high-level operation named after its implementation detail). Inconsistency across the module: `get_foo` next to `fetch_bar` next to `load_baz` for operations that are semantically the same. Pick one verb per concept and rename. Renaming is cheap in any language with a competent tool, and clarity compounds.

   d. **Scope and cohesion.** Functions doing two things — a name with "and" or two clauses joined by commas is the tell. Split. Related functions scattered across the file. Cluster them with a comment header or section break. Unrelated functions grouped only by a superficial property (all private, all on the same keybinding, all using the same framework feature). Group by purpose, not accident. Code reads like a book. Related concepts should be neighbors.

   e. **Premature abstraction.** Helpers with one caller that do not document intent better than the inline version — inline them. Parameters always passed the same value by every caller — drop them. Configuration knobs that no caller varies — delete them. Interfaces with a single implementation and no realistic second — collapse them. Abstractions built "for future flexibility" that have not been exercised are carrying cost with no benefit. Speculative generality is a tax you pay on every read.

   f. **Dead code.** Unused imports, uncalled functions, variables never referenced, parameters never consumed inside the body, types no one uses. Commented-out blocks kept "in case we need it later." You will not need them, and if you do, the version control history has them. Delete.

   g. **Error handling parity.** Similar operations emitting different error shapes (exceptions vs. return values vs. log-and-continue vs. silent swallow). Error messages that expose internal state unhelpfully, or that strip the context a caller needs to act. Guards present in some parallel paths but missing in others. Parity beats novelty — if three siblings behave the same way, the fourth should too, or have a documented reason not to.

   h. **Test smells.** Tests are code and rot the same way. Copy-pasted fixtures that should parametrize. Assertions that lock to implementation (exact strings, internal structure, field order) rather than behavior. Dead mocks that stub something the test no longer exercises. Mocks of internal helpers rather than external boundaries. See `testing.md` "Signs of overmocking."

   i. **Scope boundary respect.** If you find a smell in code *outside* the surface you intentionally touched in this task, flag it as a follow-up — do not fix it here. Drive-by refactors balloon review time and muddy the commit history. Exception: a rename or structural change that would leave the codebase inconsistent if shipped half-done is fair game, and in fact required.

   **Decision for each candidate:**

   - *Do it now, fold into the feature commit*: tiny, on code you just wrote in this task, obviously clearer, no new risk surface.
   - *Do it as a separate `refactor:` commit on this branch*: on code you touched tangentially during this task, larger in scope, or changing the shape of something non-trivial. Separating it keeps the feature commit focused for review.
   - *File as follow-up*: smell is entirely outside this task's surface. Open a ticket, add a TODO with a link, or raise it in the handoff report.
   - *Skip*: speculative cleanup with no concrete clarity gain, a change that would conflict with existing project style, or a nit that only bothers you. Not every smell is worth cleaning. Cost-of-change matters.

   **Stop condition.** Ask: "Would a reasonable reviewer flag this in review?" If the answer is no, stop. Refactoring can go on forever if you let it. Shipping beats polishing.

   Commit: group meaningful refactors into a `refactor: <desc>` commit when they stand on their own. Fold small tweaks into the associated feature or fix commit when they are tied to the same scope. The commit history should let a future reader see intent per commit, not a mixture of "did the thing" and "also cleaned up five unrelated corners."

### Constraints

- **Root cause, not symptom.** If the task is a bug, fix where the bug originates, not where it surfaces.
- **No drive-by refactoring.** Only change code the task requires. Unrelated cleanups go in a separate ticket.
- **No hypothetical-future code.** Solve the current problem. Do not design for requirements that have not been asked.
- **Framework and library code is trusted.** Mock at boundaries (network, time, file I/O), not at internal helpers (see `testing.md` "Signs of overmocking").

## Phase 5: verify end-to-end

Unit tests prove the internals are green. They cannot prove the feature works for the user. Before the ready-to-commit gate, exercise the feature end-to-end on your local machine — a running dev server on localhost for web work, the actual editor or CLI for everything else. Never production. Production verification is a separate concern that belongs to release procedures, not to a pre-merge workflow. Skipping this phase is how "all tests green" becomes "shipped broken" — it caught a one-second browser-open timeout in local testing that no unit test had any way to see.

Pick the verification mode that matches the project's stack.

### If the project has browser-automatable UI

Web apps, dashboards, SPAs, admin tools, any feature reachable through a browser. Write a Playwright end-to-end test that exercises:

- The happy path the feature was built for, clicking through as a user would.
- Any boundary or error cases that unit tests could not reach: authentication, cross-page navigation, state across reloads, deep-link URLs, permission-denied flows.
- The user-observable failure mode of any known upstream dependency, mocked or stubbed where needed.

The E2E test lives in the repo alongside the feature and runs in CI like any other test. Delegate the test authoring to `/playwright-js` for JavaScript or TypeScript stacks, `/playwright-py` for Python stacks. Do not write Playwright code from scratch when those skills are available.

### If the project has no browser UI

CLI tools, libraries, Emacs or editor configuration, shell scripts, daemons, anything where there is no DOM to automate. Lead the user through a scripted manual test. Provide:

1. **An explicit sequence of steps.** Specific commands to run, specific keys to press, specific files to open. Not "try the feature" but "open file X, press C-; h d, pick draft Y."
2. **The expected observable outcome at each step.** What message should appear in the echo area, what buffer should show, what file should change on disk, what exit code the process should return, what the browser should display. One expected outcome per step so failures pinpoint where.
3. **Failure signals.** What broken looks like. "If you see nothing in the echo area, the binding did not fire. If you see `No #+hugo_draft keyword`, the buffer has no Hugo front matter." Pattern-matching against known failure modes shortens diagnosis.

Wait for the user to walk through the steps and report back. Do not skip ahead. Do not assume success without the user's confirmation. If the user reports a failure, route the failure back through Phase 3 (if the approach was wrong) or Phase 4 (if the implementation was wrong), then re-verify.

### In both modes

- **Run against a clean environment.** Restart the process, clear the cache, open a fresh browser session, re-evaluate the loaded module. Stale state masks real bugs — today's "toggling the draft doesn't work" turned out to be stale code in a running Emacs.
- **Verify failure paths, not just the happy path.** A feature that works when nothing goes wrong is half-tested. Force an error path if the feature has one.
- **If verification reveals a unit-test gap, add the missing unit test before gate 3.** A bug you hit manually is a bug worth locking in with a test so it cannot regress.
- **Keep the verification artifact.** For browser work, the Playwright test stays in the repo. For manual scripts, paste the steps into the Phase 6 handoff report so a reviewer can re-verify on request.

### Stop condition

Every verified scenario produces its expected observable outcome. Any failure is routed back to Phase 3 or Phase 4 — not papered over, not marked as "known issue" without filing a follow-up ticket.

## Phase 6: ready to commit (gate 3)

Before handing off to the Review-and-Publish flow, stop and report:

- What was done. Files changed, tests added, test-suite result.
- What was verified in Phase 5, and how. For manual scripts, paste the step list so a reviewer can re-run the verification. For Playwright tests, name the test file.
- Any deviations from the Phase 3 approach that happened during implementation, and why.
- Any follow-up tickets surfaced along the way that should be filed separately (not rolled into this PR).

Wait for explicit approval before starting the commit and PR ceremony.

If deviations are significant, the user may want to loop back and revise the approach before publishing.

## Phase 7: hand off to Review-and-Publish

Follow `commits.md` exactly. Summary of the flow:

1. Run `/review-code --staged` before each commit, or `/review-code` on the whole branch before the PR. Block on Critical or Important findings.
2. Draft the commit message to `/tmp/commit-<slug>.md`. Run `humanizer`. Apply the plain-English pass. Replace semicolons. Stop for approval.
3. After approval, commit.
4. Draft the PR body to `/tmp/pr-<ticket-or-slug>.md`. Body must include a `Linear:` or equivalent cross-link line. Run `humanizer`. Apply the plain-English pass. Replace semicolons. Stop for approval.
5. After approval, push and run `gh pr create`.
6. Post the PR URL back to the Linear ticket, GitHub issue, or todo.org entry.
7. Move the Linear or GitHub status to **Dev Review**. Todo.org has no equivalent. Leave the todo.org entry as `DOING` until the PR merges.

## Anti-patterns

- **Skipping the Justify gate.** "This is obviously worth doing" is exactly what the gate exists to verify. If the answer really is obvious, the gate takes thirty seconds.
- **Skipping the Approach gate.** Implementation without a plan is how scope creep happens. It is also how the user loses the chance to redirect.
- **Marking a task In Progress before Phase 2 approval.** If the Justify gate kills the task, the Claim should roll back cleanly.
- **Blurring the gates.** Write the justification, stop, wait. Do not pre-generate the approach while waiting. The user may kill the task and the pre-work gets wasted.
- **Treating Feature tasks as skippable on the Approach gate.** Features especially need the migration, backwards-compat, and feature-flag questions answered up front.
- **Letting the TDD cycle drift.** If the test passes before the implementation is written, the test is wrong. Confirm the red before moving to green.
- **Skipping the refactor pass.** A green test suite is necessary, not sufficient. Five minutes with the refactor checklist catches the stale comment, the naming drift, and the duplicated expression that a reviewer will otherwise flag. Leave the code better than you found it, within scope.
- **Skipping the verify phase.** Green unit tests do not mean the feature works for the user. A one-second delay that looks fine on a mocked process is a broken experience on a real Hugo build. Five minutes of scripted manual testing or a Playwright run catches the gap before a reviewer does.

## Cross-references

- `commits.md`: the Review-and-Publish flow used in Phase 7.
- `testing.md`: TDD discipline, edge case categories, characterization tests, overmocking signals.
- `subagents.md`: dispatch contract for parallel code research during Phase 3 if the code surface is large.
- `/review-code`: runs inside Phase 7.
- `/brainstorm`: route here from the Phase 2 ticket-quality branch.
- `/arch-design`: route here if Phase 3 reveals an architectural question the task cannot answer on its own.
- `/arch-decide`: route here if Phase 3 surfaces a decision worth recording as an ADR.
- `/debug`: route here if Phase 2 reveals the task needs investigation before it can be justified.
- `/pairwise-tests`: route here from Phase 3 if the test matrix warrants combinatorial coverage.
- `/playwright-js`, `/playwright-py`: route here from Phase 5 to author E2E tests for web projects.
