---
name: fix-issue
description: Ticket-driven implementation workflow — fetch issue details from the tracker (Linear / GitHub Issues / Jira), create a branch, implement against acceptance criteria with tests, and commit/push. Reads the issue, verifies the delivery matches intent, handles the full branch lifecycle. Use when you have an issue ID or a well-scoped task ready to implement. Do NOT use for open-ended bug investigation without a clear fix path (use debug first), for tracing an error through a long call stack to its origin (use root-cause-trace), for small unticketed edits (just do them), or when requirements aren't yet clear (use brainstorm or arch-design). Companion to debug — fix-issue is the workflow scaffold around implementing a known fix; debug is the upstream investigative phase.
---

# /fix-issue — Pick Up and Implement an Issue

Create a branch, implement the fix, test, and commit.

## Usage

```
/fix-issue [ISSUE_ID]
```

If no issue ID is given, prompt the user to provide one or describe the issue.

## Instructions

1. **Fetch the issue** from the project's issue tracker (Linear, GitHub Issues, Jira, etc.) or ask the user for the issue details (title, description, acceptance criteria).

2. **Create a branch** following the naming convention:
   - Bug: `fix/ISSUE_ID-short-description`
   - Feature: `feature/ISSUE_ID-short-description`
   - Chore: `chore/ISSUE_ID-short-description`

3. **Explore the codebase and find the root cause**:
   - Do NOT jump to a fix. Read the relevant modules, trace the data flow, and understand how the system works around the issue.
   - Identify the **root cause**, not just the surface symptom. If a value is wrong in a handler, trace it back through the service, model, schema, or migration — wherever the real problem lives.
   - Read callers, callees, and related tests to understand the full context of the change.
   - Follow the project's coding standards and conventions
   - Keep changes focused — only what the issue requires
   - If the change involves data flow, confirm API contracts (schemas, typed clients) exist or create them first
   - No drive-by refactoring or scope creep

4. **Write failing test first (TDD)** — before any implementation code:
   - Create a test file if one doesn't exist for the module
   - Write a test that demonstrates the bug or defines the desired behavior — this proves you understand the root cause
   - Run the test — confirm it **fails**
   - Commit: `test: Add failing test for [issue]`

5. **Implement the fix**:
   - Write the minimal code to make the failing test pass
   - Run the test — confirm it **passes**
   - Commit: `fix: [description]`

6. **Add edge case tests — be thorough**:
   - Add boundary and error case tests (normal, boundary, and error categories)
   - Think through all edge cases: empty inputs, nulls, concurrent access, large data, permission boundaries, and interactions with adjacent modules
   - Run the full test suite to confirm nothing is broken
   - Commit: `test: Add edge cases for [issue]`

7. **Refactor if needed**:
   - Clean up the implementation while all tests stay green
   - Commit: `refactor: [description]`

All commits must use conventional messages (`feat:`, `fix:`, `chore:`, `test:`, `refactor:`), reference the issue ID in the body, and contain no AI attribution.

8. **Report** what was done: files changed, tests added, and any open questions.
