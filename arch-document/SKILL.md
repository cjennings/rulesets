---
name: arch-document
description: Produce a complete arc42-structured architecture document from a project's architecture brief and ADRs. Generates all twelve arc42 sections (Introduction & Goals, Constraints, Context & Scope, Solution Strategy, Building Block View, Runtime View, Deployment View, Crosscutting Concepts, Architecture Decisions, Quality Requirements, Risks & Technical Debt, Glossary). Dispatches to the c4-analyze and c4-diagram skills for building-block, container, and context diagrams. Outputs one file per section under `docs/architecture/`. Use when formalizing an architecture that already has a brief + ADRs, preparing documentation for a review, onboarding new engineers, or satisfying a compliance requirement. Do NOT use for shaping a new architecture (use arch-design), recording individual decisions (use arch-decide), auditing code against an architecture (use arch-evaluate), or for simple systems where a brief alone suffices. Part of the arch-* suite (arch-design / arch-decide / arch-document / arch-evaluate).
---

# Architecture Documentation (arc42)

Turn an architecture brief and a set of ADRs into a full arc42-structured document. The result is the authoritative reference for the system — engineers, auditors, and new hires read this to understand what exists and why.

## When to Use This Skill

- A project has completed `arch-design` and has a `.architecture/brief.md`
- Open decisions from the brief have been answered via `arch-decide` (ADRs)
- The team needs documentation suitable for review, onboarding, or compliance
- An existing system needs retroactive architecture docs

## When NOT to Use This Skill

- Before a brief exists (run `arch-design` first)
- For small systems where a brief alone is sufficient (don't over-document)
- To record a single decision (use `arch-decide`)
- To audit code (use `arch-evaluate`)
- When the team doesn't need arc42 — a lighter structure may serve better

## Inputs

Expected files, in order of preference:

1. `.architecture/brief.md` — output of `arch-design`
2. `docs/adr/*.md` — ADRs from `arch-decide`
3. Codebase (for inferring module structure, dispatched to `c4-analyze`)
4. Existing `docs/architecture/` contents (if updating rather than creating)

If `.architecture/brief.md` is absent, stop and tell the user to run `arch-design` first. Do not fabricate the brief.

## Workflow

1. **Load and validate inputs** — brief present? ADRs found? Any existing arc42 docs?
2. **Plan section coverage** — which of the twelve sections need content from the brief, ADRs, code, or user?
3. **Generate each section** — draft from available inputs; explicitly mark gaps
4. **Dispatch to C4 skills** — for sections needing diagrams (Context & Scope, Building Block View, Runtime View, Deployment View)
5. **Cross-link** — ensure every ADR is referenced; every diagram has a narrative
6. **Output** — one file per section under `docs/architecture/`, plus an index

## The Twelve arc42 Sections

For each: what it's for, what goes in it, where the content comes from, and what to dispatch.

### 1. Introduction and Goals → `01-introduction.md`

**Purpose:** Why does this system exist? What are the top business goals?

**Content:**
- One-paragraph system description (from brief §1)
- Top 3-5 business goals (from brief §1-2)
- Top 3 stakeholders and their concerns (from brief §2)
- Top 3 quality goals (from brief §4, pulling the top-ranked attributes)

**Sources:** brief §1, §2, §4.

### 2. Architecture Constraints → `02-constraints.md`

**Purpose:** What's non-negotiable? What narrows the solution space?

**Content:**
- Technical constraints (stack mandates, integration points)
- Organizational constraints (team, expertise, timeline)
- Conventions (style guides, naming, review process)
- Legal/regulatory/compliance

**Sources:** brief §5. Expand with any inherited constraints not in the brief.

### 3. Context and Scope → `03-context.md`

**Purpose:** What's inside the system? What's outside? What are the boundaries?

**Content:**
- **Business context:** external users, upstream/downstream systems, human actors. One diagram.
- **Technical context:** protocols, data formats, deployment boundaries. One diagram or table.

**Dispatch:** call the `c4-diagram` skill with a C4 System Context diagram request. Pass the brief's §1-2 (system identity + stakeholders) + integration points from §5 constraints.

### 4. Solution Strategy → `04-solution-strategy.md`

**Purpose:** The fundamental decisions that shape everything else.

**Content:**
- Primary architectural paradigm (from brief §7, the recommendation)
- Top-level technology decisions (link to ADRs)
- Decomposition strategy (how the system breaks into modules/services)
- Approach to the top 3 quality goals (one sentence each: how does the strategy achieve performance / availability / security / whatever ranked highest)

**Sources:** brief §7, ADRs.

### 5. Building Block View → `05-building-blocks.md`

**Purpose:** Static decomposition. Layer-by-layer breakdown.

**Content:**
- **Level 1** (whiteboard view): the handful of major components
- **Level 2** (for significant components): internal structure
- For each component: responsibility, key interfaces, dependencies, quality properties

**Dispatch:** call `c4-analyze` on the codebase if code exists; it produces Container and Component diagrams. Embed those diagrams + narrative here. If no code exists, call `c4-diagram` with the decomposition from brief §7.

### 6. Runtime View → `06-runtime.md`

**Purpose:** Dynamic behavior. The interesting interactions.

**Content:** 3-5 scenarios that matter (not every flow — the ones that illustrate key architecture). Each scenario:
- What triggers it
- Which components participate
- Data flow
- Error handling / failure modes

**Dispatch:** sequence diagrams via `c4-diagram`. One per scenario.

### 7. Deployment View → `07-deployment.md`

**Purpose:** Where does the system run? How is it packaged?

**Content:**
- Deployment environments (dev, staging, prod; regions; edge)
- Infrastructure topology (VMs, containers, serverless, managed services)
- Allocation of building blocks to infrastructure
- Network boundaries, data flow across them

**Dispatch:** deployment diagram via `c4-diagram`.

### 8. Crosscutting Concepts → `08-crosscutting.md`

**Purpose:** Concerns that span the system — not owned by one module.

**Content:** one subsection per concept. Typical concepts:
- Security (authn/z, data protection, secrets management)
- Error handling (retries, circuit breakers, dead-letter queues)
- Logging, metrics, tracing
- Configuration and feature flags
- Persistence patterns (ORM? repository? direct SQL?)
- Concurrency model
- Caching strategy
- Internationalization
- Testability approach

Only include concepts that are actually crosscutting in *this* system. If error handling is owned by one service, it's not crosscutting.

### 9. Architecture Decisions → `09-decisions.md`

**Purpose:** Index of the significant decisions. Not the ADRs themselves — a curated summary.

**Content:** a table linking out to every ADR in `docs/adr/`:

| ADR | Decision | Status | Date |
|---|---|---|---|
| [0001](../adr/0001-database.md) | Primary database: PostgreSQL | Accepted | 2024-01-10 |

Plus a one-sentence summary of *why this set of decisions, not others*. The meta-rationale.

**Sources:** `docs/adr/*.md`. Auto-generate the table from the filesystem; update on each run.

### 10. Quality Requirements → `10-quality.md`

**Purpose:** Measurable quality targets. Not "the system should be fast" — specific scenarios.

**Content:**
- **Quality tree** — the ranked quality attributes from brief §4, each with refinements
- **Quality scenarios** — specific, testable. Format: "Under [condition], the system should [response] within [measure]."

Example:

> Under peak traffic (10,000 concurrent users), a cart checkout should complete in under 2 seconds at the 95th percentile.

Minimum 1 scenario per top-3 quality attribute.

**Sources:** brief §4, §7 (rationale).

### 11. Risks and Technical Debt → `11-risks.md`

**Purpose:** Known risks and liabilities. A snapshot of what could go wrong.

**Content:**

| Risk / Debt | Impact | Likelihood | Mitigation / Plan |
|---|---|---|---|
| Single DB becomes bottleneck at 50k RPS | High | Medium (12mo) | Add read replicas; monitor query latency |

Plus a short narrative on known technical debt, what caused it, and when it'll be addressed.

**Sources:** brief §7 (trade-offs accepted), team knowledge. Refresh regularly.

### 12. Glossary → `12-glossary.md`

**Purpose:** Shared vocabulary. Terms, acronyms, and domain-specific words with agreed definitions.

**Content:** table, alphabetical.

| Term | Definition |
|---|---|
| Cart | A customer's in-progress selection of items before checkout. |
| Order | A confirmed, paid transaction resulting from a checked-out cart. |

Keep disciplined: when two people use the same word differently, the glossary is where the disagreement surfaces.

## Output Layout

```
docs/architecture/
├── README.md                  # Index; generated from the 12 sections
├── 01-introduction.md
├── 02-constraints.md
├── 03-context.md
├── 04-solution-strategy.md
├── 05-building-blocks.md
├── 06-runtime.md
├── 07-deployment.md
├── 08-crosscutting.md
├── 09-decisions.md
├── 10-quality.md
├── 11-risks.md
├── 12-glossary.md
└── diagrams/                  # C4 outputs land here
    ├── context.svg
    ├── container.svg
    ├── component-<module>.svg
    └── runtime-<scenario>.svg
```

### README.md (auto-generated index)

```markdown
# Architecture Documentation — <Project Name>

arc42-structured documentation. Read top to bottom for context; skip to a
specific section via the index.

## Sections

1. [Introduction and Goals](01-introduction.md)
2. [Architecture Constraints](02-constraints.md)
3. [Context and Scope](03-context.md)
4. [Solution Strategy](04-solution-strategy.md)
5. [Building Block View](05-building-blocks.md)
6. [Runtime View](06-runtime.md)
7. [Deployment View](07-deployment.md)
8. [Crosscutting Concepts](08-crosscutting.md)
9. [Architecture Decisions](09-decisions.md)
10. [Quality Requirements](10-quality.md)
11. [Risks and Technical Debt](11-risks.md)
12. [Glossary](12-glossary.md)

## Source Documents

- Brief: [`.architecture/brief.md`](../../.architecture/brief.md)
- Decisions: [`../adr/`](../adr/)

## Last Updated

<YYYY-MM-DD> — regenerate by running `arch-document` after brief or ADR changes.
```

## Dispatch to C4 Skills

Several sections need diagrams. The `arch-document` skill does not generate diagrams directly; it dispatches:

- **Section 3 (Context and Scope)** → `c4-diagram` for a System Context diagram. Input: system name, external actors, external systems.
- **Section 5 (Building Block View)** → `c4-analyze` if the codebase exists (it infers Container + Component diagrams). Otherwise `c4-diagram` with decomposition from brief.
- **Section 6 (Runtime View)** → `c4-diagram` for sequence diagrams, one per scenario.
- **Section 7 (Deployment View)** → `c4-diagram` for a deployment diagram.

When dispatching, include: the relevant section narrative + the specific diagram type + any identifiers needed. Capture outputs in `docs/architecture/diagrams/` and embed via relative markdown image links.

## Gap Handling

If information is missing for a section:

- **Brief gap:** stop and ask the user, or mark the section `TODO: resolve with arch-design`
- **ADR gap:** stub the section with a `TODO: run arch-decide for <decision>` and proceed
- **Code gap:** if dispatching to c4-analyze fails (no code yet), fall back to c4-diagram with brief-derived decomposition

Never fabricate content. A `TODO` is honest; a plausible-sounding but made-up detail is misleading.

## Review Checklist

Before marking the documentation complete:

- [ ] Every section has either real content or an explicit TODO
- [ ] Every ADR is referenced in section 9
- [ ] Diagrams are present for sections 3, 5, 6, 7
- [ ] Quality scenarios (§10) are specific and measurable
- [ ] Risks (§11) include likelihood and mitigation
- [ ] Glossary (§12) captures domain terms, not just jargon
- [ ] README index lists all sections with correct relative links

## Anti-Patterns

- **Template filling without thought.** Copying section headings but making up the content. If you don't have the data, mark TODO.
- **Diagrams without narrative.** A diagram in isolation tells half the story. Each diagram needs a paragraph saying what to notice.
- **Every concept as crosscutting.** If security is owned by one service, it's not crosscutting — put it in that service's building-block entry.
- **Uncurated ADR dump.** Section 9 should be a curated index with the *reason* these decisions hang together, not just a directory listing.
- **Vague quality requirements.** "The system should be fast" is useless. Specify scenarios with measurable bounds.
- **Risk-free architecture.** Every real system has risks. A blank risks section means you didn't look.

## Maintenance

arc42 is a living document. Re-run `arch-document` when:

- A new ADR is added → section 9 refreshes
- The brief is revised → sections 1, 4, 10 may change
- The codebase restructures → section 5 (via re-running c4-analyze)
- A new deployment target is added → section 7
- A scenario's behavior or SLO changes → section 6 or 10

Commit each regeneration. The document's Git history is part of the architecture record.
