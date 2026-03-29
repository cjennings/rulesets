# /review-pr — Review a Pull Request

Review a PR against engineering standards.

## Usage

```
/review-pr [PR_NUMBER]
```

If no PR number is given, review the current branch's open PR.

## Instructions

1. Fetch the PR diff and description using `gh pr view` and `gh pr diff`.
2. Review against these criteria, reporting each as PASS / WARN / FAIL:

### Security
- No hardcoded secrets, tokens, API keys, or credentials
- All user input validated at system boundary
- Parameterized queries only (no SQL string concatenation)
- No sensitive data logged (PII, tokens, passwords)
- Dependencies pinned and auditable

### Testing (TDD Evidence)
- Tests exist for all new code — check for test commits **before** implementation commits (TDD workflow)
- All three categories covered: normal (happy path), boundary, and error cases — edge cases must be thorough, not token
- Tests are independent — no shared mutable state between tests
- Mocking is at external boundaries only (network, file I/O, time) — domain logic tested directly
- Test naming follows project convention
- Coverage does not decrease — flag PRs that lower coverage without justification

### Conventions
- Type annotations on all functions (including return types)
- Conventional commit messages (`feat:`, `fix:`, `chore:`, etc.)
- No AI attribution anywhere (code, comments, commits, PR descriptions)
- One logical change per commit
- Docstrings on public functions/classes

### Root Cause & Thoroughness
- Bug fixes address the root cause, not surface symptoms — if the fix is a band-aid, flag it
- Changes demonstrate understanding of the surrounding code (not just the changed lines)
- Edge cases are covered comprehensively, not just the obvious happy path

### Architecture
- Request handlers deal with request/response only — business logic in services or domain layer
- No unnecessary abstractions or over-engineering
- Changes scoped to what was asked (no drive-by refactoring)

### API Contracts
- New endpoints have typed contracts or schemas defined
- No raw dict/object responses bypassing the contract layer
- Client-side types match server-side output
- Data flows through the API layer, not direct data access from handlers

3. Summarize findings with a clear verdict: **Approve**, **Request Changes**, or **Needs Discussion**.
4. For each WARN or FAIL, include the file and line number with a brief explanation.
