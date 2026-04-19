# /add-tests

Add test coverage to existing code by analyzing, proposing, writing, and reporting.

## Usage

`/add-tests [path]` — Analyze code at path (file, directory, or module) and add tests.

`/add-tests` — Analyze the entire project.

## Instructions

Work through four phases in order. Do not skip phases.

### Phase 1: Analyze

1. **Explore the codebase thoroughly** before proposing any tests. Read the modules in scope, trace their data flows, and understand how components interact. Understand the code's intent — not just its structure — so tests target real behavior and real risks.
2. Discover the test infrastructure: runner, config files, existing test directories, fixtures, helpers, and shared utilities. Check for `pytest.ini`, `pyproject.toml [tool.pytest]`, `jest.config.*`, `vitest.config.*`, or equivalent.
3. Inventory source files in scope. For each file, determine: public function/method count, whether tests exist (full, partial, or none), and what external dependencies would need mocking.
4. Identify external boundaries that need mocks: API clients, database calls, file I/O, time/date, third-party services. Follow the mocking rules in `testing.md` — mock at external boundaries only, never mock code under test.
5. Prioritize files by risk using the coverage targets from `testing.md`:
   - Business logic / domain: 90%+
   - API endpoints: 80%+
   - UI components: 70%+
   - Untested files with high public function counts rank highest.

### Phase 2: Propose

6. Present a test plan as a markdown table with columns: File, Functions, Current Coverage, Proposed Tests, Priority (P0/P1/P2).
7. For each proposed test, specify: target function, category (Normal / Boundary / Error), one-line description, and any mocking required. All three categories are required per function — see `testing.md` for category definitions.
8. **If a function has 3+ parameters with multiple values each, surface `/pairwise-tests`.** For that function, hand-writing exhaustive or even category-based cases risks either an explosion (N × M exhaustive) or under-coverage (3-5 ad-hoc tests miss pair interactions). Tell the user: "Function `<name>` has N parameters — would you rather generate a pairwise-covering matrix via `/pairwise-tests` for that function, or continue with normal `/add-tests` category coverage?" Default to continuing unless they pick pairwise. When in doubt, suggest pairwise for the combinatorial function and fall back to `/add-tests` for the rest.
9. For large codebases, group the plan into batches (e.g., "Batch 1: core domain models, Batch 2: API endpoints").
10. **Stop and ask the user for confirmation.** The user may add, remove, or reprioritize tests before you proceed. Do not write any test files until the user approves.

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

### Phase 4: Report

16. Summarize what was created:
    - Test files created (with paths)
    - Test count by category (normal / boundary / error)
    - Coverage change (if a coverage tool is configured and measurable)
    - Bugs discovered (tests that correctly fail against current code)
    - Suggested follow-up: integration tests needed, areas that need refactoring before they are testable, additional mocking infrastructure to build
