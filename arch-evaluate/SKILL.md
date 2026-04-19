---
name: arch-evaluate
description: Audit an existing codebase against its stated architecture brief and ADRs. Runs framework-agnostic checks (cyclic dependencies, stated-layer violations, public API drift) that work on any language without setup, and opportunistically invokes language-specific linters (dependency-cruiser for TypeScript, import-linter for Python, go vet + depguard for Go) when they're already configured in the repo — augmenting findings, never replacing. Produces a report with severity levels (error / warning / info) and pointers to the relevant brief section or ADR for each violation. Use when auditing conformance before a release, during code review, when an architecture is suspected to have drifted, or as a pre-merge CI gate. Do NOT use for designing an architecture (use arch-design), recording decisions (use arch-decide), or producing documentation (use arch-document). Part of the architecture suite (arch-design / arch-decide / arch-document / arch-evaluate + c4-analyze / c4-diagram for notation-specific diagramming).
---

# Architecture Evaluation

Audit an implementation against its stated architecture. Framework-agnostic by default; augmented by language-specific linters when they're configured in the repo. Reports violations with severity and the rule they break.

## When to Use This Skill

- Auditing a codebase before a major release
- During code review of a structurally significant change
- When architecture is suspected to have drifted from its documented intent
- As a pre-merge check (output can feed CI)
- Before an architecture review meeting

## When NOT to Use This Skill

- No brief or ADRs exist (run `arch-design` and `arch-decide` first)
- Shaping a new architecture (use `arch-design`)
- Recording a single decision (use `arch-decide`)
- Generating documentation (use `arch-document`)
- Deep code-quality review (this skill checks *structural* conformance, not line-level quality — use a code review skill for that)

## Inputs

1. `.architecture/brief.md` — the source of truth for paradigm, layers, quality attributes
2. `docs/adr/*.md` — specific decisions that the code must honor
3. `docs/architecture/*.md` — if present, used for additional structural context
4. The codebase itself

If the brief is missing, stop and tell the user to run `arch-design` first. Do not guess at intent.

## Workflow

1. **Load the brief and ADRs.** Extract: declared paradigm, layers (if any), forbidden dependencies, module boundaries, API contracts that matter.
2. **Detect repo languages and linters.** Inspect `package.json`, `pyproject.toml`, `go.mod`, `pom.xml`, etc.
3. **Run framework-agnostic checks.** Always. These never need tooling.
4. **Run language-specific tools if configured.** Opportunistic — only if the repo already has `.dependency-cruiser.cjs`, `.importlinter`, `.golangci.yml` with import rules, etc. Never install tooling.
5. **Combine findings.** Deduplicate across sources. Label each finding with provenance (native / tool).
6. **Produce report.** Severity-sorted markdown at `.architecture/evaluation-<date>.md`.

## Framework-Agnostic Checks

These work on any language. Claude reads the code and applies the policy from the brief.

### 1. Cyclic Dependencies

Scan imports/requires/includes across the codebase. Build the module graph. Report any cycles.

**Severity:** Error (cycles are almost always architecture bugs).

**Scale limit:** for codebases over ~100k lines, this check is noisy — prefer the language-specific tool output (much faster and complete).

### 2. Stated-Layer Violations

If the brief declares layers (e.g., `presentation → application → domain → infrastructure`), scan imports for arrows that go the wrong way.

**Policy format in the brief:**

```
Layers (outer → inner):
  presentation → application → domain
  presentation → application → infrastructure
  application → infrastructure (repositories only)
  domain → (none)
```

**Check:** each import statement's target must be reachable from the source via the declared arrows. Flag any that isn't.

**Severity:** Error when the violation crosses a top-level layer. Warning when it's a within-layer oddity.

### 3. Public API Drift

If the brief or an ADR documents the public interface of a module/package (exported types, functions, endpoints), compare the declared interface to what the code actually exports.

**Sources for expected interface:**

- ADRs with code-block signatures
- Brief §7 or Candidate description
- Any `docs/architecture/05-building-blocks.md` section

**Check:** listed public names exist; no additional exports are marked public unless recorded.

**Severity:** Warning (intended additions may just lack an ADR yet).

### 4. Open Decision vs Implementation

For each item in brief §8 (Open Decisions): has it been decided via an ADR? Is the implementation consistent with that ADR?

**Severity:** Warning (drift here usually means someone made a decision without recording it).

### 5. Forbidden Dependencies

The brief may list forbidden imports explicitly. Example: "Domain module must not import from framework packages (Django, FastAPI, etc.)." Check.

**Severity:** Error.

## Language-Specific Tools (Opportunistic)

These run only if the user's repo has a config file already present. If not configured, skip silently — the framework-agnostic checks still run.

### TypeScript — dependency-cruiser

**Detected when:** `.dependency-cruiser.cjs`, `.dependency-cruiser.js`, or `dependency-cruiser` config in `package.json`.

**Invocation:**

```bash
npx dependency-cruiser --validate .dependency-cruiser.cjs src/
```

**Parse:** JSON output (`--output-type json`). Each violation becomes a finding with severity mapped from the rule's `severity`.

### Python — import-linter

**Detected when:** `.importlinter`, `importlinter.ini`, or `[tool.importlinter]` in `pyproject.toml`.

**Invocation:**

```bash
lint-imports
```

**Parse:** exit code + text output. Contract failures are errors; contract warnings are warnings.

### Python — grimp (supplementary)

If `import-linter` isn't configured but Python code is present, a lightweight check using `grimp` can still detect cycles:

```bash
python -c "import grimp; g = grimp.build_graph('your_package'); print(g.find_shortest_chains('a.module', 'b.module'))"
```

Skip unless the user enables it.

### Go — go vet + depguard

**Detected when:** `.golangci.yml` or `.golangci.yaml` contains a `depguard` linter entry.

**Invocation:**

```bash
go vet ./...
golangci-lint run --disable-all --enable=depguard ./...
```

**Parse:** standard Go-style output. Depguard violations mapped to layer rules in the brief.

### Future Languages

For Java, C, C++ — tooling exists (ArchUnit, include-what-you-use, cpp-linter) but isn't integrated in v1. Framework-agnostic checks still apply.

## Tool Install Commands (for reference)

Included so the skill can tell the user what to install if they want the tool-augmented checks. The skill never installs; the user does.

### Python

```bash
pipx install import-linter     # or: pip install --user import-linter
pipx install grimp             # optional, supplementary
```

### TypeScript / JavaScript

```bash
npm install --save-dev dependency-cruiser
```

### Go

```bash
# golangci-lint includes depguard
brew install golangci-lint     # macOS
# or
go install github.com/golangci/golangci-lint/cmd/golangci-lint@latest
```

### Java (future v2+)

```xml
<!-- pom.xml -->
<dependency>
  <groupId>com.tngtech.archunit</groupId>
  <artifactId>archunit-junit5</artifactId>
  <version>1.3.0</version>
  <scope>test</scope>
</dependency>
```

### C / C++ (future v2+)

```bash
brew install include-what-you-use
# or on Linux: package manager, or build from source
```

## Config Generation

The skill does not auto-generate linter configs. That's v2+. For now, if the user wants tool-augmented checks, they configure the linter themselves, using the brief as a guide. Document the desired rules in the brief so humans (and future Claude sessions) can translate consistently.

Example — mapping brief layers to `import-linter` contracts:

```ini
# .importlinter
[importlinter]
root_package = myapp

[importlinter:contract:layers]
name = Core layers
type = layers
layers =
    myapp.presentation
    myapp.application
    myapp.domain
    myapp.infrastructure
```

## Output: `.architecture/evaluation-<date>.md`

Write the report to `.architecture/evaluation-<YYYY-MM-DD>.md`. Use this structure:

```markdown
# Architecture Evaluation — <Project Name>

**Date:** <YYYY-MM-DD>
**Brief version:** <commit hash or date of `.architecture/brief.md`>
**Checks run:** framework-agnostic + <detected tools>

## Summary

- **Errors:** <N>
- **Warnings:** <N>
- **Info:** <N>

## Findings

### Errors

#### E1. Cyclic dependency: domain/user ↔ domain/order

- **Source:** framework-agnostic
- **Files:** `src/domain/user.py:14`, `src/domain/order.py:7`
- **Rule:** Brief §7 — "Domain modules must not form cycles."
- **Fix:** extract shared abstraction into a new module, or break the cycle by inverting one direction.

#### E2. Forbidden dependency: domain imports Django

- **Source:** import-linter (contract: framework_isolation)
- **Files:** `myapp/domain/user.py:3`
- **Rule:** Brief §5 — "Domain layer must not depend on framework packages."
- **Related ADR:** [ADR-0004 Framework isolation](../docs/adr/0004-framework-isolation.md)
- **Fix:** move the Django-specific logic to `myapp/infrastructure`.

### Warnings

#### W1. Public API drift: `OrderService.cancel()` added without ADR

- **Source:** framework-agnostic
- **File:** `src/domain/order.py:142`
- **Rule:** Brief §8 — "Public API additions require an ADR."
- **Fix:** run `arch-decide` to record the rationale, or make `cancel()` non-public.

### Info

#### I1. Open decision unresolved: message bus vs direct calls

- **Source:** framework-agnostic
- **Rule:** Brief §8 item 3.
- **Fix:** run `arch-decide` to select and record.

## Tool Output (raw)

<Collapsed raw output from each tool that ran, for reference.>

## Next Steps

- Address all Errors before merge
- Triage Warnings: either fix, record as ADR, or update the brief
- Review Info items at the next architecture meeting
```

## Severity Mapping

| Severity | Meaning | Action |
|---|---|---|
| **Error** | Structural violation of declared architecture. Code contradicts brief/ADR. | Block merge. Fix or update the brief (with an ADR). |
| **Warning** | Deviation that may be intentional but wasn't recorded. | Discuss. Record via `arch-decide` or fix. |
| **Info** | Open question or unresolved decision. Not a violation, but attention-worthy. | Triage. |

## Review Checklist

Before handing off the report:

- [ ] All framework-agnostic checks ran
- [ ] Detected linters ran if configured; skipped silently if not
- [ ] Each finding has: severity, source (native or tool name), file/line, rule reference, suggested fix
- [ ] Each finding links to the brief section or ADR that establishes the rule
- [ ] Raw tool output preserved at the bottom for traceability
- [ ] Report timestamped and commit-referenced

## Anti-Patterns

- **Silent failures.** A tool that errored out is a finding too — report it (Info: "dependency-cruiser failed to parse config; no TypeScript import checks ran").
- **Swallowing open decisions.** An unresolved item in brief §8 is a legitimate warning. Don't treat it as "not a violation."
- **Tool-only reports.** If the language-specific tool is configured and clean, don't skip the framework-agnostic checks — they cover things the tool doesn't (API drift, open decisions).
- **Rule references missing.** Every finding must cite the rule. If you can't find the rule, the finding isn't actionable.
- **Error inflation.** Reserve Error for real violations. Warnings exist to avoid crying wolf.

## Integration with CI (future)

v1 produces a markdown report. v2+ will add:

- JSON output (machine-readable)
- Exit-code behavior (non-zero when any Error)
- `--fail-on-warnings` flag for strict mode
- Delta mode (only report *new* findings since last evaluation)
- Auto-generation of linter configs from the brief

See `docs/architecture/v2-todo.org` in the rulesets repo for the full deferred list.

## Hand-Off

After the report:

- **Errors** → fix or justify (each justification becomes an ADR via `arch-decide`)
- **Warnings** → record ADRs for the deliberate ones; fix the rest
- **Info** → resolve open decisions via `arch-decide`
- After significant fixes, re-run `arch-evaluate` to verify
- Consider re-running `arch-document` if the brief or ADRs changed as a result
