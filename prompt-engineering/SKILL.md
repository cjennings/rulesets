---
name: prompt-engineering
description: Craft prompts (commands, hooks, skill descriptions, sub-agent instructions, system prompts, one-shot requests to other LLMs) that do what they're meant to and resist common failure modes. Covers four moves that determine whether a prompt holds up: classify the prompt type (discipline-enforcing / guidance / collaborative / reference) to pick the right tone and techniques; apply the persuasion framework appropriate to that type (seven principles from Meincke et al. 2025, including which to avoid — notably Liking, which breeds sycophancy); match task fragility to degrees of freedom (high/medium/low); and spend the context window like a shared resource. Also contains a brief reference for classical techniques (few-shot, chain-of-thought, system prompts, templates). Use both in design mode (asking for help writing a new prompt from scratch) and critique mode (paste a draft, get it rewritten to resist common failure modes). Do NOT use for prose editing unrelated to LLM prompts (use a writing skill), for implementing application code that uses an LLM (different scope), or for content moderation / prompt-injection defense (adjacent but separate domain).
---

# Prompt Engineering

Every command, hook, skill description, sub-agent instruction, and system prompt is a prompt. This skill helps make them resist the failures that chew through engineering time: sycophantic sub-agents, vague rules agents rationalize around, verbose instructions that cost tokens without changing behavior, trigger descriptions that don't actually trigger.

Two modes of use:

- **Design mode** — you need a new prompt. Ask what you're building, and this skill walks through type-classification and technique selection.
- **Critique mode** — you have a draft. Paste it, and this skill identifies the prompt type, flags failure risks, and rewrites.

## When to Use

- Writing a new Claude Code command, hook, skill SKILL.md, or sub-agent instruction
- Writing a system prompt for any LLM interaction
- Debugging a prompt that's misbehaving (sub-agent drifts, skill under-triggers, rule gets rationalized around)
- Reviewing someone else's prompt before it ships

## When NOT to Use

- General prose editing unrelated to LLM prompts (use a writing skill)
- Implementation code that calls an LLM (different scope — covered by language skills)
- Prompt-injection defense / content moderation (adjacent; separate discipline)
- Casual single-turn requests where a prompt's behavior isn't production-critical

## The First Move: Classify the Prompt Type

Prompts fail in different ways depending on what they're for. Before writing technique, name the type. Four categories:

### 1. Discipline-enforcing

**What it is:** The prompt must produce the *same* behavior every time, under any condition. No judgment calls, no rationalization.

**When you have one:** Security checks, deployment gates, safety rules, pre-commit hooks, FedRAMP-style compliance verifiers, PII scanners, rate-limit enforcers.

**Failure mode:** The model finds reasons to deviate ("but in this case, maybe..."). Soft verbs like "should try" or "generally" are rationalization fuel.

**Success criteria:** Identical output on edge cases. The model never "makes an exception."

### 2. Guidance / technique

**What it is:** The prompt teaches a technique and expects the model to apply it with judgment. Outcome varies with context.

**When you have one:** Refactoring patterns, debugging workflows, test-writing guidance, architecture advice, code review checklists.

**Failure mode:** Either over-constrained (turns judgment into cargo-culting) or under-constrained (model freelances and misses the pattern).

**Success criteria:** Technique applied correctly across varied inputs; model can explain why it deviated when it did.

### 3. Collaborative

**What it is:** Peer-level work. Review, brainstorm, pair-editing, technical feedback. The user wants an honest second opinion, not a cheerleader.

**When you have one:** Code review agents, design-review agents, editing help, technical critique sub-agents, brainstorming partners.

**Failure mode:** **Sycophancy.** Soft-pedaling real issues because the default LLM tone is agreeable. This is the Liking principle firing by default, and for collaborative prompts it's usually *bad*.

**Success criteria:** Honest assessment. Willing to say "this is wrong" or "there are no issues." Structured output to prevent hand-waving.

### 4. Reference

**What it is:** Metadata, index content, trigger descriptions, glossaries, API references. The prompt's job is to be findable and clear, not to change behavior.

**When you have one:** Skill frontmatter descriptions, API endpoint docs, keyword lists for search, glossary entries.

**Failure mode:** Under-triggering (skill never fires) or ambiguity (reader can't tell scope).

**Success criteria:** Triggers reliably on the intended phrases; explicit about what's in and out of scope.

## The Persuasion Framework

LLMs are parahuman — they were trained on human text that's full of persuasion signals, and they respond to those same signals. Use this deliberately, not unconsciously.

### The Seven Principles

Adapted from Meincke et al., *Persuasion and Compliance in Large Language Models* (2025, N≈28,000 conversations). Two-principle combinations shifted compliance rates from ~33% to ~72%.

- **Authority** — Non-negotiable framing. "YOU MUST", "Never", "Always", "No exceptions."
- **Commitment** — Force explicit action. "Announce the rule you're applying before applying it." "Output your checklist with each item checked."
- **Scarcity** — Time-bound or sequence-bound. "Before proceeding." "Immediately after X." "First, then."
- **Social Proof** — Universal pattern language. "Every time." "The failure mode is always…". "Skipping this step = bug in production."
- **Unity** — Collaborative framing. "We're colleagues." "Our codebase." "Let's work through this."
- **Reciprocity** — Exchanges of effort. Rarely needed for prompts; often reads as manipulative.
- **Liking** — Warmth and agreement. **Creates sycophancy.** Usually actively harmful for work where you need honest assessment.

### Which Principles By Prompt Type

| Prompt Type | Use | Avoid |
|---|---|---|
| Discipline-enforcing | Authority + Commitment + Social Proof | Liking, Reciprocity |
| Guidance | Moderate Authority + Unity | Heavy Authority (feels dogmatic); Liking |
| Collaborative | Unity + Commitment | Authority (hostile), **Liking (sycophancy)** |
| Reference | Clarity alone — minimize persuasion | All persuasion framings |

### Why This Matters

- **Bright-line rules reduce rationalization.** "Never commit without running tests" leaves no exception space. "Try to run tests before committing" invites "well, this is just a typo fix, surely…"
- **Implementation intentions create automatic behavior.** "When you see X, do Y" beats "generally, do Y where appropriate."
- **Liking is the default LLM tone.** If you don't actively counteract it on collaborative prompts, you'll get agreement bias.

## Degrees of Freedom

Match prompt specificity to how much the task tolerates variation.

- **Low freedom** — exact script, exact format, no deviation. Use when consistency is the whole point: deployment commands, migration scripts, checksum comparisons. "Run `python scripts/migrate.py --verify --backup`" not "run the migration script."
- **Medium freedom** — parameterized pattern or pseudocode skeleton. The model fills in pieces within a named structure. Most common. Use for most skills and commands.
- **High freedom** — open instructions, multiple valid approaches. Use when context drives the answer and you trust the model to navigate. Code review, brainstorming, exploratory debugging.

Mismatches to avoid:

- High-freedom prompt for a low-tolerance task (deployment, security, crypto): the model improvises; production breaks
- Low-freedom prompt for an open task (code review, design): the model produces identical output regardless of context; signal is lost

## Context Window Economics

The context window is a shared resource. Every token spent on verbose instructions is a token not available for the actual work or for other loaded context.

Questions to ask of each sentence in a prompt:

- Does the model need this? Or can it be assumed?
- Is this stable enough to go in the system prompt, freeing up the user-message budget?
- Does this paragraph justify its token cost, or is it restating what a nearby paragraph already said?
- Would a short example convey what three sentences of description do?

**Progressive disclosure for skills specifically:** Skill metadata (name + description) is always in context; the SKILL.md body loads only when the skill triggers; referenced files load only when needed. Put triggering content in the frontmatter, procedural content in the body, exhaustive reference material in linked files.

## Classical Techniques — Brief Reference

Covered extensively elsewhere (Anthropic docs, OpenAI cookbook, the prompt-engineering literature). Short pointers:

- **Few-shot learning** — Include 2-5 input/output examples rather than describing the pattern in prose. Best for consistent formatting, edge case handling, subtle behaviors that are easier to show than tell.
- **Chain-of-thought** — Request step-by-step reasoning before the answer. Add "think through this step by step" for zero-shot; include a worked reasoning trace for few-shot. Best for multi-step logic; significant accuracy gains on analytical tasks.
- **System prompts** — For stable role, constraints, and output format that persist across turns. Keep user messages for the varying task content.
- **Templates** — Parameterize prompts with variables for reuse. Version-control them as code.

These are well-documented; don't re-teach here. Lean toward the four moves (type, persuasion, freedom, economics) — those are what most prompt work actually needs.

## Design Mode Workflow

When asked to design a prompt from scratch:

1. **Classify the type.** Ask the user to pick one, explaining each:

   > - **Discipline-enforcing** — must behave identically every time (security, deployment, safety)
   > - **Guidance** — teaches a technique the model applies with judgment (refactoring, debugging)
   > - **Collaborative** — peer work; honest assessment matters more than agreement (review, critique)
   > - **Reference** — metadata, index, trigger description (skill frontmatter, glossary)

2. **Confirm success criteria.** How will the user know the prompt works? One measurable sentence.

3. **Pick persuasion principles** from the by-type matrix. Name them to the user so the framing is deliberate.

4. **Match degrees of freedom** to task fragility. Explain the choice.

5. **Draft and review.** Write the prompt; walk the user through the choices. Short draft beats long. Bold imperative beats hedging.

6. **Apply the ethics test** (see below). If the prompt would embarrass the user if its recipient understood the techniques being used, revise.

## Critique Mode Workflow

When handed an existing draft:

1. **Classify what type it actually is** — often different from what the user thinks it is. A "review" agent phrased in soft Liking language is a collaborative prompt failing at sycophancy.
2. **Audit for principle mismatches.** Is a collaborative prompt using Authority? Is a discipline prompt hedging? Is Liking sneaking into a review prompt?
3. **Check degrees of freedom** against task fragility.
4. **Check token economy.** Redundancy, restated instructions, unnecessary preamble.
5. **Check for footguns** from the anti-patterns list.
6. **Rewrite** — show before/after. Name the changes.

## Ethics Test

Use persuasion to make prompts reliable, not to manipulate. Before shipping any prompt that uses strong Authority, Commitment, or Social Proof framing:

> If the person being persuaded (the LLM, yes, but also any human user downstream of its output) fully understood the techniques in use, would they still consent to the behavior being requested?

If the answer is "no" or "I'd rather they didn't think about it" — revise. Legitimate uses: preventing security slips, enforcing reliability, protecting the user's genuine interests. Illegitimate: extracting consent, bypassing reasonable caution, guilt-inducing framing to force output.

Don't confuse discipline with manipulation. Discipline serves the user; manipulation serves the prompt author's convenience at the user's expense.

## Anti-Patterns

- **Liking by default on a collaborative prompt.** Soft, agreeable language in a review or critique agent produces "looks good to me" theatre. Use Unity + Commitment; strip Liking explicitly.
- **Hedging on a discipline-enforcing prompt.** "Please try to" and "generally" are loopholes. If the rule is absolute, use absolute language.
- **Authority stack on a guidance prompt.** All-caps MUSTs on a technique skill feel dogmatic and cargo-cult; the model obeys surface form while missing the idea.
- **High freedom on a fragile task.** "Deploy the service" invites improvisation; "run `deploy.sh --env prod --verify`" doesn't.
- **Restating the instruction in prose.** If a sentence is repeating what the previous one said, cut one of them.
- **Example pollution.** 12 few-shot examples when 3 would do. The model generalizes better from fewer good examples than from many with subtle inconsistencies.
- **Instruction buried below prose.** Put the action up front. "Read this and then do X" gets the action; "Here's some context about Y, and also we want Z, and consider that…" buries it.
- **Ambiguous scope in reference prompts.** Trigger descriptions without explicit *do-not-trigger* conditions under-fire and mis-fire.
- **Persuasion without purpose.** Adding "YOU MUST" or "Every time" because it sounds rigorous — if the task tolerates variance, strong framing just hardens the wrong behaviors.

## Review Checklist

Before declaring a prompt done:

- [ ] The type is classified (discipline / guidance / collaborative / reference)
- [ ] The persuasion principles match the type (and Liking is explicitly excluded for collaborative)
- [ ] Degrees of freedom match the task's fragility
- [ ] Each sentence earns its tokens
- [ ] Trigger phrases and (for reference prompts) explicit negative conditions are present
- [ ] Sycophancy traps (for collaborative) and rationalization loopholes (for discipline) are closed
- [ ] The ethics test passes

## Output

Return the drafted or critiqued prompt, with a short note explaining:

1. Prompt type you identified
2. Persuasion principles applied (and which you explicitly avoided)
3. Degrees-of-freedom level chosen
4. One or two things the revision improved

No long explanations. The prompt itself should demonstrate the principles, not narrate them.

## Related Skills

- **`codify`** — after shipping a prompt that worked well, capture the pattern into `CLAUDE.md`
- **`brainstorm`** — when the *shape* of the prompt isn't clear yet, run brainstorm first to nail down the requirement, then return here for the prompt itself
- **`arch-decide`** — if a prompt-design choice is significant enough to document (e.g., "we standardize on Authority + Commitment for all deployment prompts"), record it as an ADR

## References

- Meincke, L., et al. (2025). *Persuasion and Compliance in Large Language Models.* N≈28,000 AI conversations; 7 persuasion principles; compliance shifts of ~2x with appropriate combinations.
- Anthropic prompt engineering guidance — context window as shared resource; progressive disclosure; degrees-of-freedom framing.
- Classical prompt engineering literature (few-shot, CoT, system prompts) — assumed background; not re-taught here.
