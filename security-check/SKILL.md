# /security-check — Audit Changes for Security Issues

Scan staged or recent changes for secrets, OWASP vulnerabilities, and dependency risks.

## Usage

```
/security-check [FILE_OR_DIRECTORY]
```

If no argument is given, audit all staged changes (`git diff --cached`). If there are no staged changes, audit the diff from the last commit.

## Instructions

1. **Gather the changes** to audit:
   - Staged changes: `git diff --cached`
   - Or last commit: `git diff HEAD~1`
   - Or specific path if provided

2. **Check for hardcoded secrets** — scan for patterns:
   - AWS access keys (`AKIA...`)
   - Generic secret patterns (`sk-`, `sk_live_`, `sk_test_`)
   - Password assignments (`password=`, `passwd=`, `secret=`)
   - Private keys (`-----BEGIN.*PRIVATE KEY-----`)
   - `.env` file contents committed by mistake
   - API tokens, JWTs, or bearer tokens in source code

3. **OWASP Top 10 review**:
   - SQL injection: string concatenation in queries
   - XSS: unsanitized user input rendered in HTML/JSX
   - Broken authentication: missing permission checks on endpoints
   - Insecure deserialization: unsafe deserialization of untrusted data (e.g., eval, exec)
   - Security misconfiguration: debug mode enabled in production settings
   - Sensitive data exposure: PII or tokens in log statements

4. **Dependency audit**:
   - Run `pip-audit` if Python files changed
   - Run `npm audit` if JavaScript/TypeScript files changed
   - Flag any new dependencies added without version pinning

5. **Report findings** in a table:

   | Severity | File:Line | Finding | Recommendation |
   |----------|-----------|---------|----------------|

   Severity levels: CRITICAL, HIGH, MEDIUM, LOW, INFO

6. If no issues found, report "No security issues detected" with a summary of what was checked.
