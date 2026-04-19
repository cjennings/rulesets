# Responsive

Mobile is the dominant traffic profile for consumer web; desktop dominates operational and enterprise contexts. Commit to a primary viewport early — retrofitting responsive behavior into a desktop-only design is more expensive than building with breakpoints from the start.

## Decision: Mobile-First or Desktop-First

**Mobile-first** (build the small-screen layout first, scale up):
- Consumer web, marketing, e-commerce, public-facing apps
- Progressive enhancement ethos — base experience works everywhere, more features at larger sizes
- CSS reads as `/* default (mobile) */` → `@media (min-width: X)` overrides
- Simpler to keep working on constrained devices

**Desktop-first** (design for a big screen, gracefully degrade):
- Operational dashboards, ISR displays, pro tools, internal enterprise apps
- Information density is the point; mobile is a fallback or unsupported
- CSS reads as `/* default (desktop) */` → `@media (max-width: X)` overrides
- Harder to keep working when the small screen is an afterthought

Pick one deliberately. Hybrids (different viewport designs for "phone / tablet / desktop" with no progression ethos) usually produce three mediocre layouts rather than one good one.

## Breakpoints

Use **named, consistent** breakpoints — not magic numbers scattered across files. A design-system variable keeps them coherent.

**Typical set** (Tailwind's values are reasonable defaults):

| Name | Width | Use |
|---|---|---|
| sm | 640px | Large phones, phablets |
| md | 768px | Tablets, small laptops |
| lg | 1024px | Laptops |
| xl | 1280px | Desktops |
| 2xl | 1536px | Large desktops, wide monitors |

**Don't** introduce a breakpoint at an arbitrary exact pixel. If content reflows badly at 820px, push `md` up to 840px or decide the design needs an actual rearrangement at that size — not a pixel workaround.

**Container queries** (`@container`) are now broadly supported and are often a better answer than viewport breakpoints for components that live in varied contexts. A card that's 300px wide in a sidebar and 900px wide on a detail page should branch on *its* size, not the viewport's.

## Aesthetic Translation by Archetype

Archetypes don't all respond to screen size the same way. Match the translation strategy to the direction chosen:

| Archetype | Small-screen translation |
|---|---|
| Maximalist chaos | Simplify, don't dilute. Fewer layered effects; preserve the rule-breaking layout feel. |
| Brutally minimal | Scales naturally. Ensure spacing scales with viewport — "generous" at 1920px ≠ "generous" at 375px. |
| Retro-futuristic | Stacked vertical scroll with preserved detail. Don't lose the motif elements (grids, glows, terminal text) even if resized. |
| Organic / natural | Reflow gracefully; the aesthetic comes from shape and color, not grid. Near-free on mobile. |
| Luxury / refined | Preserve whitespace proportions. The whitespace *is* the design. Don't cram. |
| Playful / toy-like | Often translates well; the whimsy is in shapes/colors/animations, not layout. |
| Editorial / magazine | Hardest. Magazine spreads assume two-page layouts. Single column on mobile, but preserve type hierarchy and whitespace choreography. |
| Brutalist / raw | Scales naturally. Monospace and visible-grid aesthetics don't fight small screens. |
| Art deco / geometric | Retain the geometric motifs as accents; simplify complex patterns. |
| Soft / pastel | Reflow easily. Watch contrast on smaller screens where brightness shifts. |
| Industrial / utilitarian | Operational dashboards often unsupported on mobile — that's a legitimate product decision. If mobile is required, prioritize scanning over interaction. |

## Responsive Typography

- Use `clamp(min, preferred, max)` for fluid type that never breaks the layout:
  ```css
  h1 { font-size: clamp(2rem, 5vw + 1rem, 4rem); }
  ```
- Line length: aim for 45-75 characters per line at the primary viewport. On mobile, 30-40 is fine for body text.
- Line height scales inversely — tighter on headlines, looser on body, typically `1.2` → `1.6`.

## Images and Media

- `max-width: 100%` is the baseline; `object-fit: cover` for images that need to fill a container at different aspect ratios
- Use `<picture>` for art direction (different crops per viewport), not just different sizes
- `srcset` for resolution switching; browsers handle the choice automatically
- Hero backgrounds at 4K don't belong on mobile — deliver appropriately sized assets

## Operational Dashboard Note

For DeepSat-style ISR / operational work: the primary viewport is almost always a large desktop monitor. Mobile is unsupported. Don't pretend otherwise. If mobile is a declared requirement:

- Prioritize *read-only* scanning over interactive manipulation
- Key metrics first, secondary details collapsed behind interactions
- Assume poor bandwidth + intermittent connectivity — data-sparing matters
- Don't split the canonical desktop layout 1:4 onto mobile tiles — design a separate layout with the same information priorities

## Smoke Checklist

- [ ] Primary viewport decided and documented in the rationale
- [ ] Named breakpoints — no magic pixel values in CSS
- [ ] Works at `sm`, `md`, `lg`, `xl` tests (at minimum)
- [ ] Typography scales fluidly or has tuned ramps per breakpoint
- [ ] Images use appropriate sizes per viewport
- [ ] At 200% browser zoom, layout still holds
- [ ] No horizontal scroll (unintentional) on any common viewport
