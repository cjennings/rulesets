# /respond-to-review — Evaluate and Implement Code Review Feedback

Evaluate code review feedback technically before implementing. Verify suggestions against the actual codebase — don't implement blindly.

## Usage

```
/respond-to-review [PR_NUMBER]
```

If no PR number is given, check the current branch's open PR for pending review comments.

## Instructions

### 1. Gather the Feedback

- Fetch review comments using `gh api repos/{owner}/{repo}/pulls/{number}/comments` (for inline review comments) and `gh api repos/{owner}/{repo}/issues/{number}/comments` (for top-level PR conversation comments)
- Read each comment in full. Group related comments — reviewers often raise connected issues across multiple comments.

### 2. Evaluate Each Item

For each review comment, before implementing anything:

1. **Restate the suggestion in your own words** — make sure you understand what's being asked. If you can't restate it clearly, ask for clarification before touching code.
2. **Verify against the codebase** — check whether the reviewer's premise is correct. Reviewers sometimes misread code, miss context, or reference outdated patterns. Read the actual code they're commenting on.
3. **Check YAGNI** — if the reviewer suggests a "more proper" or "more robust" implementation, grep the codebase for actual usage. If nothing uses the suggested pattern today, flag it: "This would add complexity without current consumers. Should we defer until there's a concrete need?"
4. **Assess the suggestion** — categorize as:
   - **Correct and actionable** — implement it
   - **Correct but out of scope** — acknowledge and create a follow-up issue
   - **Debatable** — present your reasoning and ask for the reviewer's perspective
   - **Incorrect** — explain why with evidence (file paths, test results, documentation)

### 3. Respond

- Lead with technical substance, not agreement
- If you disagree, explain why with code references — not opinion
- If you're unsure, say so and ask a specific question
- Never implement a suggestion you don't understand

### 4. Implement

- Address simple fixes first, complex ones after
- Test each change individually — don't batch unrelated fixes into one commit
- Run the full test suite after all changes
- Commit with conventional messages referencing the review: `fix: Address review — [description]`

### 5. Report

- Summarize what was implemented, what was deferred, and what needs discussion
- Link any follow-up issues created for out-of-scope suggestions

## Content scope

Output this skill produces that gets committed or shared with the team must follow the *Content scope for public artifacts* rule in [`commits.md`](../claude-rules/commits.md): no local paths, no private repo names, no personal tooling references.
