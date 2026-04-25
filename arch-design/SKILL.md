---
name: arch-design
description: Shape the architecture of a new or restructured software project through structured intake (quality attributes, stakeholders, constraints, scale, change drivers), then propose candidate architectural paradigms with honest trade-off analysis and a recommended direction. Paradigm-agnostic — evaluates options across layered, hexagonal, microservices, event-driven, CQRS, modular-monolith, serverless, pipe-and-filter, DDD, and others. Outputs a brief at `.architecture/brief.md` that downstream skills (arch-decide, arch-document, arch-evaluate) read. Use when starting a new project or service, restructuring an existing one, choosing a tech stack, or formalizing architecture before implementation. Do NOT use for bug fixing, code review, small feature additions, documenting an existing architecture (use arch-document), evaluating an existing architecture against a brief (use arch-evaluate), or recording specific individual decisions (use arch-decide). Part of the architecture suite (arch-design / arch-decide / arch-document / arch-evaluate + c4-analyze / c4-diagram for notation-specific diagramming).
---

# Architecture Design

Elicit the problem, surface the real drivers, propose a fit, and commit it to writing. One working session yields a `.architecture/brief.md` that anchors every downstream architectural decision.

## When to Use This Skill

- Starting a new project, service, or major subsystem
- Restructuring or re-platforming an existing system
- Selecting a primary tech stack for a green-field effort
- Establishing a formal architecture before a team scales
- Preparing a spike or prototype you want to keep coherent

## When NOT to Use This Skill

- Bug fixing or defect investigation
- Small feature additions inside an existing architecture
- Recording a single decision (use `arch-decide`)
- Producing formal documentation from a known architecture (use `arch-document`)
- Auditing an existing codebase against its stated architecture (use `arch-evaluate`)

## Workflow

The skill runs in five phases. Each produces a section of the output brief. Do not skip phases — the trade-off analysis is only as good as the intake.

1. **Intake** — elicit stakeholders, domain, scale, timeline, team
2. **Quality attributes** — prioritize (can't have everything)
3. **Constraints** — technical, organizational, legal, cost
4. **Candidate paradigms** — shortlist 2-4 with honest trade-off analysis
5. **Recommendation** — pick one, justify it, flag open questions for ADRs

## Phase 1 — Intake

Ask the user to answer each. Short answers are fine; vague answers mean return to the question.

**System identity**
- What is this system? (One sentence.)
- Who uses it? Human end users, other services, both?
- What domain is it in? (commerce, health, comms, finance, ops, etc.)

**Scale**
- Expected traffic at launch and in 12 months? (RPS, MAU, payload sizes)
- Data volume at launch and in 12 months? (rows/docs, GB)
- Geographic distribution? (single region, multi-region, edge)

**Team**
- Team size now? Growing?
- Existing language/stack expertise?
- Operational maturity? (on-call rotation, observability tooling, CI/CD)

**Timeline**
- When does it need to be in production?
- Is this replacing something? What's the migration path?

**Change drivers**
- What forces are likely to reshape this system? (new markets, regulatory, volume, organizational)

## Phase 2 — Quality Attributes

List the relevant quality attributes and force the user to rank them 1-5 (1 = critical, 5 = nice-to-have). You can't optimize everything; the ranking surfaces real priorities.

Standard list (use this set; add domain-specific ones if relevant):

- **Performance** (latency, throughput under load)
- **Scalability** (horizontal, vertical, elastic)
- **Availability** (uptime target, failure tolerance)
- **Reliability** (data durability, correctness under partial failure)
- **Security** (authn/z, data protection, threat model)
- **Maintainability** (readability, testability, onboarding speed)
- **Observability** (logs, metrics, tracing, debuggability)
- **Deployability** (release cadence, rollback speed)
- **Cost** (infra, operational, total cost of ownership)
- **Compliance** (regulatory, audit, data residency)
- **Interoperability** (integration with existing systems, APIs, standards)
- **Flexibility / evolvability** (ease of adding features, changing direction)

Document the ranking verbatim in the brief. Future decisions hinge on it.

## Phase 3 — Constraints

Enumerate what's fixed. Each constraint narrows the design space — make them explicit so trade-offs don't hide.

- **Technical**: existing infrastructure, mandated languages/platforms, integration points that can't move
- **Organizational**: team structure (Conway's Law — the org shape becomes the arch shape), existing expertise, hiring plan
- **Legal/regulatory**: GDPR, HIPAA, FedRAMP, data residency, audit retention
- **Cost**: budget ceiling, licensing limits, infra cost targets
- **Timeline**: hard dates from business, regulatory deadlines
- **Compatibility**: backward-compatibility with existing clients, API contracts, data formats

## Phase 4 — Candidate Paradigms

Pick 2-4 candidates that plausibly fit the quality-attribute ranking and constraints. Analyze each honestly — include the reasons it would fail, not just succeed.

Common paradigms to consider:

| Paradigm | Fits when… | Doesn't fit when… |
|---|---|---|
| **Modular monolith** | Small team, fast iteration, strong module boundaries, single deployment OK | Independent team scaling, different availability SLAs per module, polyglot requirements |
| **Microservices** | Multiple teams, independent deploy cadences, polyglot, different scaling needs | Small team, tight transactional consistency needs, low operational maturity |
| **Layered (n-tier)** | CRUD-heavy, clear request/response, team familiar with MVC | Complex domain logic, event-driven needs, async workflows dominate |
| **Hexagonal / Ports & Adapters** | Business logic isolation, multiple interface types (HTTP + CLI + queue), testability priority | Trivial domains, overhead outweighs benefit |
| **Event-driven / pub-sub** | Async workflows, fan-out to multiple consumers, decoupled evolution | Strong ordering + consistency needs, small team, low operational maturity |
| **CQRS** | Read/write workload asymmetry, different optimization needs, audit trail required | Simple CRUD, no asymmetry, overhead not justified |
| **Event sourcing** | Audit trail critical, temporal queries needed, reconstruction from events valuable | Simple state, team lacks event-sourcing expertise, storage cost prohibitive |
| **Serverless (FaaS)** | Event-driven + variable load + fast iteration + accept vendor lock-in | Steady high load, latency-sensitive, long-running processes, tight cost control |
| **Pipe-and-filter / pipeline** | Data transformation workflows, ETL, stream processing | Interactive request/response, low-latency |
| **Space-based / in-memory grid** | Extreme throughput, elastic scale, in-memory OK | Strong durability required from day one, small scale |
| **DDD (tactical)** | Complex domain, domain experts available, long-lived system | Simple CRUD, no real domain complexity, short-lived system |

For each candidate, document:

- **Summary** — one paragraph on what the architecture would look like
- **Why it fits** — map to the ranked quality attributes
- **Why it might not** — the honest cons for this specific context
- **Cost** — team learning curve, operational overhead, infra impact
- **Open questions** — what would need to be answered or decided via ADR

## Phase 5 — Recommendation

Choose one paradigm. Justify it by:

- Which top-3 quality attributes the choice serves
- Which constraints it respects
- Why the rejected alternatives were rejected (not just "we picked X"; say why *not* Y)
- What you're trading away (be explicit)

Flag items that need their own ADRs — use `arch-decide` to record them. Examples:

- Primary database choice
- Message bus vs. direct calls
- Sync vs. async inter-service comms
- Multi-tenancy approach
- Authentication/authorization boundary

## Output: `.architecture/brief.md`

Write the final brief to `.architecture/brief.md` in the project root. Use this structure:

```markdown
# Architecture Brief — <Project Name>

**Date:** <YYYY-MM-DD>
**Authors:** <names>
**Status:** Draft | Accepted | Revised

## 1. System

<One-paragraph description of what the system does.>

## 2. Stakeholders and Users

- **Primary users:** …
- **Secondary users:** …
- **Operators:** …
- **Integrators / dependent systems:** …

## 3. Scale Targets

| Metric | Launch | +12 months |
|---|---|---|
| RPS | … | … |
| Data volume | … | … |
| Geographic spread | … | … |

## 4. Quality Attributes (Prioritized)

| Rank | Attribute | Notes |
|---|---|---|
| 1 | … | critical driver |
| 2 | … | … |

## 5. Constraints

- **Technical:** …
- **Organizational:** …
- **Legal/Regulatory:** …
- **Cost:** …
- **Timeline:** …

## 6. Candidates Considered

### Candidate A — <paradigm>

Summary. Fit. Cons. Cost. Open questions.

### Candidate B — <paradigm>

…

## 7. Recommendation

**Chosen paradigm:** …

**Rationale:**
- …

**Trade-offs accepted:**
- …

**Rejected alternatives and why:**
- …

## 8. Open Decisions (Candidates for ADRs)

- [ ] Primary database — driver: …
- [ ] …

## 9. Next Steps

- Run `arch-decide` for each open decision above
- Run `arch-document` to produce the full arc42 document
- Run `arch-evaluate` once implementation begins to audit conformance
```

## Review Checklist

Before marking the brief Accepted:

- [ ] Every quality attribute is ranked; no "all critical"
- [ ] Every constraint is explicit; no "we probably can't"
- [ ] At least 2 candidates considered; each has real cons
- [ ] Recommendation names what it's trading away
- [ ] Open decisions listed; each will become an ADR via `arch-decide`
- [ ] Stakeholders have seen and (ideally) approved

## Anti-Patterns

- **"All quality attributes are critical."** They aren't. Force ranking.
- **"Let's go microservices."** Without a ranking, constraints, and team context, that's cargo-culting.
- **Single candidate.** One option means the user already decided; you're documenting, not designing.
- **Silent trade-offs.** If you choose availability, you're trading latency or cost. Say so.
- **No open decisions.** A real architecture has open questions. Listing none means you haven't looked hard.
- **"Design doc" with no implementation implications.** The brief must be actionable — it drives ADRs, documentation, and evaluation.

## Hand-Off

After the brief is Accepted:

- `arch-decide` — record each Open Decision as an ADR under `docs/adr/`
- `arch-document` — expand into a full arc42-structured document under `docs/architecture/` with C4 diagrams
- `arch-evaluate` — once code exists, audit it against this brief

## Content scope

Output this skill produces that gets committed or shared with the team must follow the *Content scope for public artifacts* rule in [`commits.md`](../claude-rules/commits.md): no local paths, no private repo names, no personal tooling references.
