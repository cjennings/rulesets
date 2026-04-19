# Workflow

Four phases for non-trivial frontend work. Cheap to skip individual phases when context warrants, but don't short-circuit the chain by default.

## Phase 1 — Intake

Before coding, understand what's being built and for whom. Ask these, one at a time, multiple-choice where possible. Don't batch.

**Purpose**
- What is this interface for? (landing page / dashboard / component / marketing site / internal tool / client demo / design exploration / other)
- What problem does it solve? One sentence.

**Audience**
- Who uses this? (general public / executives / technical users / operators / customers / internal team)
- What's their expected device / context? (desk on a big screen / mobile on the move / constrained environment)

**Operational context**
- Consumer-facing or operational? (consumer → aesthetic distinctiveness helps; operational → readability + scannability matter more)
- Is there a design system to respect, or is this greenfield?
- Any brand guidelines or existing visual language to match / deliberately depart from?

**Functional priority**
- Density vs scannability vs delight — which wins when they conflict?
- Read-only, interactive, or input-heavy?

**Technical constraints**
- Framework / stack (React / Next / Vue / Svelte / vanilla HTML+CSS / static site / other)
- Existing design system (Tailwind / shadcn / custom / none)
- Performance budget (if any)
- Accessibility target (WCAG AA is default; AAA for some contexts)
- Browser support (modern-only OK, or need IE11-style fallbacks?)

**References**
- Any moodboard links, screenshots, sites you like / dislike?
- Brand color palette, logos, fonts already in use?

**Success criteria**
- What does "good" look like for this? One-sentence test ("looks professional but not corporate" / "feels like a game" / "hides complexity behind calm surfaces" / etc.)
- How will we know when to stop iterating?

Stop asking when you can state the goal back in one sentence and the user confirms.

## Phase 2 — Commitment

Before writing code, lock the aesthetic direction explicitly. State all of these out loud (in output) so the user can push back before time is spent:

- **Archetype chosen.** One of: brutally minimal, maximalist chaos, retro-futuristic, organic/natural, luxury/refined, playful/toy-like, editorial/magazine, brutalist/raw, art deco/geometric, soft/pastel, industrial/utilitarian, or a named variant.
- **Why this archetype fits** the purpose and audience from Phase 1.
- **What's being traded away.** (Maximalism trades subtlety; minimalism trades information density; playful trades gravitas; etc.)
- **Font pairing**, one line. Display + body, both named. Not Inter, Roboto, Arial, or system defaults unless specifically justified.
- **Palette**, one line. 2-3 dominant colors + 1-2 sharp accents. Not "purple gradient on white."
- **Motion philosophy**, one line. ("Staggered page-load reveal, subtle hover states, no scroll-jacking" or "no motion — stillness and typography do the work" or "aggressive hover interactions — this is supposed to feel alive.")
- **Layout approach**, one line. (Asymmetric grid / classic 12-col / brutalist stack / magazine spreads / whatever fits the archetype.)

**If the user pushes back**, revise before building. Cheaper to pivot now than after implementation.

## Phase 3 — Build

With the commitment locked, implement. The aesthetic guidance in `../SKILL.md` is the main reference for taste decisions.

**Layout-significant work?** Load [responsive.md](responsive.md) and plan the breakpoint strategy *before* committing to a primary viewport layout.

**Interactive components (forms, dialogs, menus, complex controls)?** Load [accessibility.md](accessibility.md) and apply the discipline during build, not as a retrofit.

**Match implementation complexity to aesthetic vision.** Maximalism needs elaborate code (layered animations, custom cursors, grain overlays, scroll effects). Minimalism needs precision (impeccable spacing, considered typography scale, restraint in color). Don't build the wrong kind of effort.

## Phase 4 — Review

Before handoff, self-audit. Load [design-review.md](design-review.md) and walk the checklist:

- Did the build hit the chosen archetype?
- Any AI-slop defaults slip back in? (Inter, purple-on-white, predictable card layouts, etc.)
- Accessibility smoke check (contrast, keyboard, focus, reduced-motion)
- Responsive smoke check (does the aesthetic translate to mobile?)
- Does the code quality match the aesthetic? (Lazy code under ornate design is a failure.)

Emit a `design-rationale.md` using [rationale-template.md](rationale-template.md) so the next iteration or the next engineer has context for the choices made.

## When to skip phases

- **One-line style tweak** ("change the heading color to match the brand"): skip phases 1, 2, 4. Just apply the change.
- **Refactoring existing code without design changes**: not this skill — use the general refactor skill.
- **Bug fix in existing design**: skip phase 1 (context is already there) and phase 2 (don't pivot the archetype for a bug fix). Build and review.
- **Complete rebuild / new design**: don't skip any phase.

The discipline is there to prevent bad decisions at speed. Skipping for genuinely trivial work is fine; skipping because "it's faster" on non-trivial work is how AI slop wins.
