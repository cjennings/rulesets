# Architecture Suite

Four chained Claude Code skills for the full architecture lifecycle: **design**, **decide**, **document**, **evaluate**. Paradigm-agnostic (supports layered, hexagonal, microservices, event-driven, CQRS, DDD, and others). Language-aware (framework-agnostic checks work everywhere; language-specific linters augment when configured).

## The Chain

```
                 ┌─────────────────┐
  New project →  │   arch-design   │ → .architecture/brief.md
                 └────────┬────────┘
                          │
             (for each open decision)
                          │
                          ▼
                 ┌─────────────────┐
                 │   arch-decide   │ → docs/adr/NNNN-*.md
                 └────────┬────────┘
                          │
          (when ready to formalize)
                          │
                          ▼
                 ┌─────────────────┐
                 │  arch-document  │ → docs/architecture/*.md
                 └────────┬────────┘      (dispatches to c4-analyze, c4-diagram)
                          │
           (once code exists, periodically)
                          │
                          ▼
                 ┌─────────────────┐
                 │  arch-evaluate  │ → .architecture/evaluation-YYYY-MM-DD.md
                 └─────────────────┘
```

Skills are standalone — invoke any one directly. The flow above is the canonical path; you can enter at any point if the prerequisite artifacts already exist.

## What Each Skill Does

### [arch-design](../../arch-design/SKILL.md)

Elicits the architecture: intake (stakeholders, scale, team, timeline), quality-attribute prioritization, constraints, then proposes 2-4 candidate paradigms with honest trade-off analysis. Picks one with rationale. Lists open decisions that become ADRs.

**Output:** `.architecture/brief.md`

### [arch-decide](../../arch-decide/SKILL.md)

Records significant technical decisions as ADRs. Five template variants (MADR, Nygard, Y-statement, lightweight, RFC). Covers ADR lifecycle (proposed / accepted / deprecated / superseded), review checklist, and `adr-tools` automation.

**Output:** `docs/adr/NNNN-<title>.md`, plus an index at `docs/adr/README.md`.

**Forked from [wshobson/agents](https://github.com/wshobson/agents) — MIT.**

### [arch-document](../../arch-document/SKILL.md)

Produces full arc42-structured documentation from the brief + ADRs + codebase. All twelve arc42 sections. Dispatches to `c4-analyze` (for code-present systems) and `c4-diagram` (for textual descriptions) for the diagrams in sections 3, 5, 6, and 7.

**Output:** `docs/architecture/01-introduction.md` through `12-glossary.md`, plus diagrams under `docs/architecture/diagrams/`.

### [arch-evaluate](../../arch-evaluate/SKILL.md)

Audits the codebase against the brief + ADRs. Four framework-agnostic checks (cyclic deps, stated-layer violations, public API drift, forbidden deps). Opportunistically invokes language-specific linters if they're already configured in the repo.

**Output:** `.architecture/evaluation-YYYY-MM-DD.md`

## Installation

These skills live in this rulesets repo alongside the other skills (`debug`, `add-tests`, `c4-analyze`, etc.). Install globally once:

```bash
make -C ~/code/rulesets install
```

This symlinks every skill (including the four `arch-*`) into `~/.claude/skills/`. Any Claude Code session on this machine will see them.

To uninstall:

```bash
make -C ~/code/rulesets uninstall
```

To check install state:

```bash
make -C ~/code/rulesets list
```

## Optional: Language-Specific Linters

`arch-evaluate` works without any external tooling — its framework-agnostic checks cover cycles, layer violations, API drift, and forbidden deps on any language Claude can read. **Installing the linters below is optional** and augments those checks with dedicated tooling: faster on large codebases, CI-friendly, and precise.

Install only the ones you need for your active languages.

### Python — import-linter

Declarative import contracts. Config in `.importlinter` or `[tool.importlinter]` in `pyproject.toml`.

```bash
pipx install import-linter
# or: pip install --user import-linter
# or (in a uv-managed project): uv add --dev import-linter
```

Verify:

```bash
lint-imports --help
```

Example config (`.importlinter`):

```ini
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

[importlinter:contract:framework_isolation]
name = Domain isolation
type = forbidden
source_modules =
    myapp.domain
forbidden_modules =
    django
    fastapi
```

### TypeScript / JavaScript — dependency-cruiser

Rich import analysis with a JS config file. The de-facto standard for TS architectural linting.

```bash
npm install --save-dev dependency-cruiser
# or globally: npm install -g dependency-cruiser
```

Verify:

```bash
npx dependency-cruiser --version
```

Generate an initial config:

```bash
npx dependency-cruiser --init
```

Then edit `.dependency-cruiser.cjs` to encode your architecture. Example rule:

```javascript
module.exports = {
  forbidden: [
    {
      name: 'domain-no-infrastructure',
      severity: 'error',
      from: { path: '^src/domain' },
      to:   { path: '^src/infrastructure' },
    },
  ],
  options: { tsPreCompilationDeps: true, tsConfig: { fileName: 'tsconfig.json' } },
};
```

### Go — golangci-lint (with depguard)

`go vet` (part of the stdlib) covers built-in checks. `depguard` (via golangci-lint) enforces import rules.

```bash
# macOS
brew install golangci-lint

# Linux / anywhere with Go
go install github.com/golangci/golangci-lint/cmd/golangci-lint@latest
```

Verify:

```bash
golangci-lint --version
go vet ./...
```

Example `.golangci.yml`:

```yaml
linters:
  disable-all: true
  enable:
    - depguard

linters-settings:
  depguard:
    rules:
      domain:
        list-mode: lax
        files:
          - "$all"
          - "!**/infrastructure/**"
        deny:
          - pkg: "github.com/yourorg/yourapp/infrastructure"
            desc: "domain must not depend on infrastructure"
```

### Java — ArchUnit (v2+)

Test-driven: architectural rules live in JUnit tests. Not invoked by `arch-evaluate` in v1.

**Maven:**

```xml
<dependency>
  <groupId>com.tngtech.archunit</groupId>
  <artifactId>archunit-junit5</artifactId>
  <version>1.3.0</version>
  <scope>test</scope>
</dependency>
```

**Gradle:**

```groovy
testImplementation 'com.tngtech.archunit:archunit-junit5:1.3.0'
```

Example rule (`src/test/java/archtest/LayerRules.java`):

```java
@AnalyzeClasses(packages = "com.yourorg.yourapp")
class LayerRules {
  @ArchTest
  static final ArchRule layered =
    layeredArchitecture().consideringAllDependencies()
      .layer("Presentation").definedBy("..presentation..")
      .layer("Application").definedBy("..application..")
      .layer("Domain").definedBy("..domain..")
      .whereLayer("Presentation").mayNotBeAccessedByAnyLayer()
      .whereLayer("Application").mayOnlyBeAccessedByLayers("Presentation")
      .whereLayer("Domain").mayOnlyBeAccessedByLayers("Application", "Presentation");
}
```

Then run `mvn test` or `gradle test`.

### C / C++ — include-what-you-use (v2+)

Checks each source file's `#include` discipline. Not invoked by `arch-evaluate` in v1; listed for completeness.

```bash
# macOS
brew install include-what-you-use

# Arch Linux
sudo pacman -S include-what-you-use

# Ubuntu/Debian
sudo apt install iwyu
```

Integrate via CMake:

```cmake
set(CMAKE_CXX_INCLUDE_WHAT_YOU_USE include-what-you-use)
```

Verify:

```bash
include-what-you-use --version
```

## Typical Flow

### New project

```bash
# 1. Shape the architecture
# In Claude Code:
/arch-design
# Answer intake questions, rank quality attributes, review candidates.
# Output: .architecture/brief.md

# 2. Record each open decision
/arch-decide
# Once per significant decision. Output: docs/adr/0001-*.md, 0002-*.md, etc.

# 3. Formalize (when ready)
/arch-document
# Generates all twelve arc42 sections + diagrams.
# Output: docs/architecture/*.md

# 4. Audit (once code exists)
/arch-evaluate
# Report at .architecture/evaluation-YYYY-MM-DD.md
```

### Existing project with no architecture docs

```bash
# 1. Retroactively capture
/arch-design      # reconstruct the brief from what exists
/arch-decide      # write ADRs for past decisions (date them honestly)
/arch-document    # produce current-state arc42 docs

# 2. Audit against the reconstructed intent
/arch-evaluate
```

### Continuous

- Re-run `/arch-evaluate` periodically (on PR, before release, monthly)
- Every significant new decision → `/arch-decide`
- Brief or ADR changes → `/arch-document` to refresh

## Where Things Land

```
<project-root>/
├── .architecture/
│   ├── brief.md                          ← arch-design
│   └── evaluation-YYYY-MM-DD.md          ← arch-evaluate
├── docs/
│   ├── adr/
│   │   ├── README.md                     ← arch-decide (index)
│   │   └── NNNN-<title>.md               ← arch-decide
│   └── architecture/
│       ├── README.md                     ← arch-document (index)
│       ├── 01-introduction.md …          ← arch-document
│       ├── 12-glossary.md
│       └── diagrams/                     ← arch-document (via c4-*)
│           ├── context.svg
│           ├── container.svg
│           └── runtime-<scenario>.svg
```

## Dependencies Between Skills

- `arch-decide` is standalone; nothing required from the others
- `arch-document` reads the brief and ADRs; without them, it stubs sections as TODO
- `arch-evaluate` requires the brief; without it, the skill stops and tells the user to run `arch-design`
- `arch-document` dispatches to `c4-analyze` (if code exists) and `c4-diagram` (otherwise) — both live in this same rulesets repo

## Versioning and Deferred Work

v1 covers the four core skills with the chain above. The deferred feature list — CI integration, auto-generated linter configs, ArchUnit integration, DDD aggregate boundaries, etc. — is tracked at [`v2-todo.org`](v2-todo.org).

## Licensing

- `arch-design`, `arch-document`, `arch-evaluate` — part of this rulesets repo
- `arch-decide` — forked from [wshobson/agents](https://github.com/wshobson/agents), **MIT**. See `arch-decide/LICENSE`.

## Contributing / Modifying

These are personal skills; fork as needed. If you change a skill and want to re-sync the global install symlink, re-run `make -C ~/code/rulesets install`. Symlinks point back at this repo, so edits propagate without re-install.
