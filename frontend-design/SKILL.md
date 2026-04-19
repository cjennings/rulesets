---
name: frontend-design
description: Create distinctive, production-grade frontend interfaces with high design quality. Use this skill when the user asks to build web components, pages, artifacts, posters, or applications (examples include websites, landing pages, dashboards, React components, HTML/CSS layouts, or when styling/beautifying any web UI). Generates creative, polished code and UI design that avoids generic AI aesthetics. Do NOT use for narrow maintenance tasks (single CSS bug fix, dependency upgrade, accessibility-only retrofit), for projects where the stakeholder has explicitly specified "minimal, functional, no creative direction," for backend / API / data-pipeline work, for non-web UIs (mobile native apps, desktop apps, terminal apps), or when the requested work is code refactoring without a visible design component.
license: Complete terms in LICENSE.txt
---

This skill guides creation of distinctive, production-grade frontend interfaces that avoid generic "AI slop" aesthetics. Implement real working code with exceptional attention to aesthetic details and creative choices.

The user provides frontend requirements: a component, page, application, or interface to build. They may include context about the purpose, audience, or technical constraints.

## Design Thinking

Before coding, understand the context and commit to a BOLD aesthetic direction:
- **Purpose**: What problem does this interface solve? Who uses it?
- **Tone**: Pick an extreme: brutally minimal, maximalist chaos, retro-futuristic, organic/natural, luxury/refined, playful/toy-like, editorial/magazine, brutalist/raw, art deco/geometric, soft/pastel, industrial/utilitarian, etc. There are so many flavors to choose from. Use these for inspiration but design one that is true to the aesthetic direction.
- **Constraints**: Technical requirements (framework, performance, accessibility).
- **Differentiation**: What makes this UNFORGETTABLE? What's the one thing someone will remember?

**CRITICAL**: Choose a clear conceptual direction and execute it with precision. Bold maximalism and refined minimalism both work - the key is intentionality, not intensity.

Then implement working code (HTML/CSS/JS, React, Vue, etc.) that is:
- Production-grade and functional
- Visually striking and memorable
- Cohesive with a clear aesthetic point-of-view
- Meticulously refined in every detail

## Frontend Aesthetics Guidelines

Focus on:
- **Typography**: Choose fonts that are beautiful, unique, and interesting. Avoid generic fonts like Arial and Inter; opt instead for distinctive choices that elevate the frontend's aesthetics; unexpected, characterful font choices. Pair a distinctive display font with a refined body font.
- **Color & Theme**: Commit to a cohesive aesthetic. Use CSS variables for consistency. Dominant colors with sharp accents outperform timid, evenly-distributed palettes.
- **Motion**: Use animations for effects and micro-interactions. Prioritize CSS-only solutions for HTML. Use Motion library for React when available. Focus on high-impact moments: one well-orchestrated page load with staggered reveals (animation-delay) creates more delight than scattered micro-interactions. Use scroll-triggering and hover states that surprise.
- **Spatial Composition**: Unexpected layouts. Asymmetry. Overlap. Diagonal flow. Grid-breaking elements. Generous negative space OR controlled density.
- **Backgrounds & Visual Details**: Create atmosphere and depth rather than defaulting to solid colors. Add contextual effects and textures that match the overall aesthetic. Apply creative forms like gradient meshes, noise textures, geometric patterns, layered transparencies, dramatic shadows, decorative borders, custom cursors, and grain overlays.

NEVER use generic AI-generated aesthetics like overused font families (Inter, Roboto, Arial, system fonts), cliched color schemes (particularly purple gradients on white backgrounds), predictable layouts and component patterns, and cookie-cutter design that lacks context-specific character.

Interpret creatively and make unexpected choices that feel genuinely designed for the context. No design should be the same. Vary between light and dark themes, different fonts, different aesthetics. NEVER converge on common choices (Space Grotesk, for example) across generations.

**IMPORTANT**: Match implementation complexity to the aesthetic vision. Maximalist designs need elaborate code with extensive animations and effects. Minimalist or refined designs need restraint, precision, and careful attention to spacing, typography, and subtle details. Elegance comes from executing the vision well.

Remember: Claude is capable of extraordinary creative work. Don't hold back, show what can truly be created when thinking outside the box and committing fully to a distinctive vision.

---

## Workflow (Added)

For non-trivial work, walk these four phases. Load the referenced files only when that phase is active — keeps context lean for simple component requests.

1. **Intake** — see [references/workflow.md](references/workflow.md) for the question set. Establishes purpose, audience, operational context, functional priorities, technical constraints, brand references, success criteria.
2. **Commitment** — same file: pick one archetype from the list in *Design Thinking* above, state what you're trading away, lock font pairing / palette / motion philosophy / layout approach as one-line decisions.
3. **Build** — code it. Keep the chosen direction visible in every choice; the aesthetic guidance above applies here. Pull [references/responsive.md](references/responsive.md) if the component is layout-significant, [references/accessibility.md](references/accessibility.md) for interactive pieces.
4. **Review** — see [references/design-review.md](references/design-review.md). Self-audit against the archetype and the anti-pattern list before handoff. Emit a short rationale using [references/rationale-template.md](references/rationale-template.md) so the next iteration has context.

For **simple component tweaks, quick polish, or one-line style changes**, skip the workflow — apply the aesthetic guidance inline.

## References (Added)

| File | Load when |
|---|---|
| [workflow.md](references/workflow.md) | Starting a new interface / non-trivial redesign |
| [accessibility.md](references/accessibility.md) | Building interactive components; accessibility audit |
| [responsive.md](references/responsive.md) | Layout-significant component or page; multi-viewport concerns |
| [design-review.md](references/design-review.md) | Review phase; auditing existing frontend code |
| [rationale-template.md](references/rationale-template.md) | Emitting a `design-rationale.md` alongside the build |

---

## Attribution

Forked from [anthropics/skills/skills/frontend-design](https://github.com/anthropics/skills/tree/main/skills/frontend-design) — Apache 2.0 licensed. See `LICENSE.txt` in this directory for the original copyright and terms.

**Local additions** (not upstream):
- The description above now lists explicit negative triggers (narrow maintenance, operational-only, backend, non-web UI, refactoring without visible design).
- The *Workflow* and *References* sections at the end of this file are local additions.
- The files under `references/` are local additions authored for this fork. They extend the upstream's aesthetic guidance with intake questions, a design-review checklist, accessibility and responsive discipline, and a rationale-doc template.

The upstream skill's aesthetic-direction content is intact; the additions are additive and load progressively (references only pull into context when a phase needs them).
