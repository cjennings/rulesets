# /add-tests

Add test coverage to existing code by analyzing, proposing, writing, and reporting.

## Usage

`/add-tests [path]` — Analyze code at path (file, directory, or module) and add tests.

`/add-tests` — Analyze the entire project.

## Core Principle — Refactor for Testability First

If a function mixes business logic with UI, framework APIs, or interactive I/O, testing it cleanly requires heavy mocking — which tends to test the mock instead of the code. Split the function first:

- **Pure helper** — All logic, explicit parameters, deterministic, no side effects. Takes real inputs, returns values or raises. 100% testable with zero mocking.
- **Interactive wrapper** — Thin layer that gets input from user/framework/context and delegates to the helper. Not unit-tested — testing it would test the framework.

Identify refactor-first candidates during Phase 1 and surface them in the Phase 2 proposal. The user decides per function: refactor now, skip testing it this round, or accept heavy mocking (not recommended).

## Instructions

Work through four phases in order. Do not skip phases.

### Phase 1: Analyze

1. **Explore the codebase thoroughly** before proposing any tests. Read the modules in scope, trace their data flows, and understand how components interact. Understand the code's intent — not just its structure — so tests target real behavior and real risks.
2. Discover the test infrastructure: runner, config files, existing test directories, fixtures, helpers, and shared utilities. Check for `pytest.ini`, `pyproject.toml [tool.pytest]`, `jest.config.*`, `vitest.config.*`, or equivalent.
3. Inventory source files in scope. For each file, determine: public function/method count, whether tests exist (full, partial, or none), what external dependencies would need mocking, and whether any functions are **testability-blocked** — so tightly coupled to UI or framework that testing would require mocking the code under test itself. Flag blocked functions as refactor-first candidates for the Phase 2 proposal.
4. Identify external boundaries that need mocks: API clients, database calls, file I/O, time/date, third-party services. Follow the mocking rules in `testing.md` — mock at external boundaries only, never mock code under test.
5. Prioritize files by risk using the coverage targets from `testing.md`:
   - Business logic / domain: 90%+
   - API endpoints: 80%+
   - UI components: 70%+
   - Untested files with high public function counts rank highest.

### Phase 2: Propose

6. Present a test plan as a markdown table with columns: File, Functions, Current Coverage, Proposed Tests, Priority (P0/P1/P2).
7. For each proposed test, specify: target function, category (Normal / Boundary / Error), one-line description, and any mocking required. All three categories are required per function — see `testing.md` for category definitions.
8. **Surface the coverage choice for parameter-heavy functions.** If a function has 3+ parameters with multiple values each, category-based cases (Normal/Boundary/Error per parameter individually) miss interaction bugs, while exhaustive cases explode combinatorially. Ask the user, citing specific numbers:

   > "Function `<name>` has N parameters (M^N = Y exhaustive combinations). Pairwise or exhaustive?
   > - **Pairwise** (`/pairwise-tests`): ~X cases covering every 2-way parameter interaction; catches 60-90% of combinatorial bugs.
   > - **Exhaustive**: Y hand-written cases covering every combination; only needed in regulated / provably-complete-coverage contexts."

   Pairwise is the pragmatic default. Exhaustive only when the user names a specific reason (regulatory, safety-critical, audit evidence). If the user doesn't pick explicitly, proceed with pairwise for that function and continue with category coverage for the rest.
9. **For each testability-blocked function**, present it separately in the proposal: "Function `<name>` is testability-blocked — refactor into pure helper + interactive wrapper before testing, skip testing it this round, or accept heavy mocking (not recommended)?" Decide per function.
10. For large codebases, group the plan into batches (e.g., "Batch 1: core domain models, Batch 2: API endpoints").
11. **Stop and ask the user for confirmation.** The user may add, remove, or reprioritize tests before you proceed. Do not write any test files until the user approves.

### Phase 3: Write

10. Create test files following the organization from `testing.md`:
    ```
    tests/
      unit/           # One test file per source file
      integration/    # Multi-component workflows
    ```
11. Follow the naming convention: `test_<module>_<function>_<scenario>_<expected>`. Example: `test_satellite_calculate_position_null_input_raises_error`.
12. Write all three test categories (normal, boundary, error) for every function in the approved plan. Be thorough with edge cases — cover boundary conditions, error states, and interactions that could realistically fail.
13. Use language-specific standards:
    - **Python:** Follow `python-testing.md` — use `pytest` (never `unittest`), fixtures for setup, `@pytest.mark.parametrize` for category coverage, `@pytest.mark.django_db` for DB tests, `freezegun`/`time-machine` for time mocking.
    - **TypeScript/JavaScript:** Follow `typescript-testing.md` — use Jest + React Testing Library, query priority (`getByRole` > `getByLabelText` > `getByText` > `getByTestId`), `waitFor` for async, type-safe test helpers in `tests/helpers/`.
14. Mock only at external boundaries. Never mock the code under test, domain logic, or framework behavior.
15. Run the tests after writing each batch. Confirm they pass. If a test fails against the current code, that is a discovered bug — do not delete the test or make it pass artificially. Note it for the report.
16. **When a test fails, diagnose whether the test or the production code is wrong.** Don't reflexively "fix" either side.
    - Read the test's intent (name, arrange, assertion).
    - Read the production code path.
    - Decide: if the expected behavior is reasonable and defensive but the code doesn't match, it's a production bug — fix the code, keep the test. If the test expectation itself is wrong (miscounted, misread the spec), fix the test. If the spec is unclear, stop and ask the user.
    - Common patterns: null/nil input crashing where a graceful return was expected → production bug (add guard). Test asserted 10 replacements but the input had 9 trigger chars → test bug. Regex silently fails to match valid URLs → production bug (real defect surfaced by testing).
    - Record production bugs discovered for the Phase 4 report. Tests that correctly fail against current code are bugs *found*, not failures to suppress.

### Phase 4: Report

17. Summarize what was created:
    - Test files created (with paths)
    - Test count by category (normal / boundary / error)
    - Coverage change (if a coverage tool is configured and measurable)
    - Bugs discovered (tests that correctly fail against current code)
    - Suggested follow-up: integration tests needed, areas that need refactoring before they are testable, additional mocking infrastructure to build
