# Rationale Template

Drop the following into a `design-rationale.md` alongside the code at handoff. Brief, specific, honest. Future iterations of the interface start by reading this.

---

```markdown
# Design Rationale — <component / page / project name>

**Date:** YYYY-MM-DD
**Author:** <name or "AI-assisted via /frontend-design">
**Invoked from:** <initial user prompt or request summary, 1-2 lines>

## 1. Purpose

<One paragraph. What is this for, who uses it, what problem it solves.>

## 2. Archetype

**Chosen:** <brutally minimal / maximalist chaos / retro-futuristic / organic / luxury / playful / editorial / brutalist / art deco / soft / industrial / custom variant>

**Why:** <One sentence tying archetype to purpose + audience.>

**Trading away:** <What this direction sacrifices. "Maximalism trades subtlety and scannability for memorability" / "Minimalism trades information density for focus" / etc.>

## 3. Locked decisions

- **Font pairing:** <display font> for headings, <body font> for text. <One-line why.>
- **Palette:** <primary colors> with <accent colors>. <Where dominants live, where accents appear.>
- **Motion philosophy:** <In one line — staggered page-load / aggressive hover / no motion / whatever.>
- **Layout approach:** <Asymmetric grid / classic 12-col / brutalist stack / magazine spread / whatever.>

## 4. Deliberately absent

<List what's NOT in the design even though someone might expect it. "No card drop shadows — monochrome blocks define structure instead." "No hero image — typography carries the emotional weight." Explicitly naming the absences prevents the next iteration from adding them back by default.>

## 5. Accessibility notes

- Contrast verified at <AA / AAA> against <palette elements>
- Keyboard navigation: <summary of focus order and any custom controls>
- `prefers-reduced-motion`: <handled / not applicable>
- Known concerns: <anything below threshold, noted for follow-up>

## 6. Responsive notes

- Primary viewport: <desktop / mobile-first / specific breakpoint>
- Translation approach: <how the aesthetic holds at smaller sizes>
- Unsupported viewports (if any): <below X px, behavior is Y>

## 7. Implementation notes

- Framework: <React / Vue / plain HTML / etc.>
- Dependencies added: <list; keep short>
- Integration assumptions: <what the consuming codebase must provide>
- Known tradeoffs: <perf vs aesthetic, dep weight, etc.>

## 8. Open questions / follow-ups

- [ ] <item>
- [ ] <item>

## 9. References

- Brand guide: <link if used>
- Moodboard: <link if used>
- Similar designs consulted: <list>
```

---

## Filled example (abbreviated)

```markdown
# Design Rationale — SOCOM demo landing

**Date:** 2026-04-19
**Author:** AI-assisted via /frontend-design
**Invoked from:** "Build a landing page for the SOCOM demo; feels technical
without being sterile."

## 1. Purpose
Public-facing landing for the SOCOM ATAC demo. Audience: procurement
officers + technical evaluators. Must feel precise, credible, and
operationally-serious without reading as generic defense-contractor-beige.

## 2. Archetype
**Chosen:** industrial/utilitarian with restrained editorial accents.
**Why:** Audience is operational; aesthetic distinctiveness comes from
precision, not decoration.
**Trading away:** Decorative delight; warmth. In exchange, seriousness and
signal density.

## 3. Locked decisions
- **Font pairing:** IBM Plex Mono for headings; IBM Plex Sans for body.
  (Mono carries the operational signal; sans keeps body readable.)
- **Palette:** Near-black (#0a0e0f) dominant, cool slate (#3a4851) secondary,
  single desaturated amber accent (#c88c3a) used only for ATAC callouts.
- **Motion philosophy:** No motion on page load; hover states are snap-fast
  (80ms). Stillness = precision.
- **Layout approach:** Grid visible as 1px cool-slate rules; content sits
  inside named cells. Hero aligns to a single numbered row, not centered.

## 4. Deliberately absent
- No hero video, no animated gradient
- No card shadows; cells share the grid rules instead
- No purple, no consumer-fintech palette cues
- No "book a demo" urgency; CTA is "Contact procurement"

## 5. Accessibility notes
- AA verified on all text/button states
- Focus rings: 2px amber outline + offset, `:focus-visible` only
- `prefers-reduced-motion`: applies; hover transitions drop to 0ms

## 6. Responsive notes
- Primary: desktop 1440px
- Mobile: single column, grid rules preserved; named cells stack vertically
  in document order
- Below 360px: layout is acceptable but not designed for

## 7. Implementation notes
- Framework: Next.js 14 (App Router) + Tailwind + IBM Plex (self-hosted)
- No additional deps
- Uses existing design tokens from ./lib/tokens.ts
- Integration: expects `@/components/grid` and `@/components/cell` primitives

## 8. Open questions
- [ ] Is the amber accent readable in direct sunlight on outdoor demos?
- [ ] Legal has approved the "ATAC" wordmark treatment

## 9. References
- Brand guide: internal/DeepSat-brand-2026-03.pdf
- Moodboard: Monokuma.com, Field Notes, NASA technical manuals
```
