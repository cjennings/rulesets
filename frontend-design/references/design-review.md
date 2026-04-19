# Design Review

Self-audit before handoff. The goal isn't "did I follow the rules" — it's "does the build match the commitment, and are any AI-slop defaults hiding in here?" Assume defaults crept in somewhere; find them.

## Archetype Check

Pull up the commitment from Phase 2 (or the `design-rationale.md` if you emitted one). Answer honestly:

- [ ] Does the build read as the chosen archetype to a stranger?
- [ ] Are the font pairing, palette, motion philosophy, and layout approach the ones committed to, or did they drift?
- [ ] Is the archetype recognizable on the first five seconds of viewing, or does it require explanation?

A build that "sort of" hits the archetype usually hits none cleanly. Better to overshoot than hedge.

## Anti-Pattern Grep

These are specific defaults that sneak back in even after you committed to something else. Check for each:

**Fonts:**
- [ ] No Inter, Roboto, Arial, Helvetica (unless deliberately justified for this archetype)
- [ ] No "system-ui" family unless the archetype is literally "system-native"
- [ ] Display font is distinct from body font — if both are the same (e.g., all Inter), that's a miss
- [ ] Variable fonts with too many weights load-heavy — pick 2-3 weights max

**Palette:**
- [ ] No purple-to-pink gradient on white
- [ ] No "evenly-distributed" palette — 6 colors all at 50% saturation reading as "gray blah"
- [ ] Dominant colors take more space than accents; accents have real contrast
- [ ] No "generic teal" (#14b8a6 and its cousins) unless the archetype specifically earns it

**Layout:**
- [ ] Not a cards-in-a-grid with no hierarchy
- [ ] Not centered-column-of-text-with-a-hero-image (the default blog post)
- [ ] Not three-equal-feature-boxes (the default SaaS landing page)
- [ ] There's at least one layout choice the reader will remember

**Motion:**
- [ ] Hover states exist and surprise (not just `opacity: 0.8`)
- [ ] Page load has a considered reveal (staggered, or deliberately instant — not "jump in as DOM parses")
- [ ] `prefers-reduced-motion` respected
- [ ] No unrequested scroll-jacking or mandatory scroll animations

**Background / Atmosphere:**
- [ ] Not plain white or plain `#0a0a0a` background (unless that's the archetype's literal point)
- [ ] Some depth: gradient mesh, noise, dramatic shadow, decorative border, ambient texture — something
- [ ] Whatever's chosen, it feels *designed* not *applied* (random noise texture on anything = lazy)

**Components:**
- [ ] Buttons don't look like every shadcn button ever
- [ ] Cards aren't the generic "rounded-lg shadow-md bg-white p-6" pattern
- [ ] Form fields have considered states (hover, focus, error, disabled, loading)
- [ ] Custom cursor, custom selection color, custom scrollbar where fitting for the archetype

## Code Quality Match

The aesthetic and the code have to agree. Red flags:

- [ ] Ornate maximalist design + 40 lines of CSS = mismatch (ornate needs elaborate code)
- [ ] Claimed "minimalism" + 2000 lines of utility classes + 5 dependencies = mismatch (minimal aesthetic needs restrained code)
- [ ] No CSS variables in a multi-page design = palette will drift across components
- [ ] Inline styles scattered in JSX = the system hasn't been thought through

Elegance in the code is part of the deliverable, not an afterthought.

## Accessibility Smoke Check

Run through [accessibility.md](accessibility.md)'s smoke checklist at minimum. If the build will ship, run Lighthouse + axe as well; fix CRITICAL and SERIOUS findings before handoff.

## Responsive Smoke Check

Resize the viewport to `sm` (~640px) and `lg` (~1024px). Does the aesthetic translate, or does the layout collapse to the AI-default "one centered column of stacked elements"? Some archetypes *should* collapse to a single column on mobile — but that's a choice, not a fallback. Verify via [responsive.md](responsive.md)'s checklist.

## Performance Sanity

- [ ] No 5MB hero image
- [ ] No autoplay video that isn't essential
- [ ] Font loading isn't blocking render (use `font-display: swap` or similar)
- [ ] Animations don't thrash layout (use `transform` and `opacity`, not `width` / `top` / `left`)
- [ ] Third-party scripts loaded async / deferred

If the aesthetic requires heavy assets (hero videos, WebGL, etc.), that's fine — but it's a documented trade-off, not an accident.

## Convergence Check

If you've used this skill recently, what did the last build look like? If the last three builds all picked "brutally minimal" or all used the same font pairing — convergence. Break the pattern deliberately on the next invocation. The aesthetic space is large; defaulting to the same corner repeatedly is a failure.

## Final: The One-Sentence Test

Can you write one sentence describing what's memorable about this build? Not "it's clean and modern" — that applies to everything and nothing. A real answer: "The asymmetric terminal-green monospace hero with the brutalist grid and tiny rotating pixel cursor." If the sentence is vague, the design didn't commit hard enough.

## Handoff

Emit a `design-rationale.md` via [rationale-template.md](rationale-template.md) so the next iteration has context. Commit the rationale alongside the code — future work starts with it loaded, not with the aesthetic forgotten.
