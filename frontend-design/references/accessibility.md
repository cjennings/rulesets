# Accessibility

Default target: WCAG 2.1 AA. For government, healthcare, finance, or other regulated contexts: AAA on specific criteria (verify with the user). Don't wait for a retrofit — apply during build.

## Color Contrast

**WCAG AA thresholds:**
- Normal text (< 18pt / < 14pt bold): **4.5:1** minimum
- Large text (≥ 18pt or ≥ 14pt bold): **3:1** minimum
- UI components and graphics (borders, icons, focus indicators): **3:1** minimum against adjacent colors
- Decorative or disabled elements are exempt — but a "disabled" button the user might still try to click is NOT decorative

**Practical:**
- Use a checker during palette lock-in (WebAIM Contrast Checker, or `npx check-color-contrast`)
- Light text on saturated backgrounds (e.g., white on red-500) often fails — check, don't assume
- Gradient backgrounds mean text contrast varies across the gradient — check against the *worst-case* point under the text
- Ambient/atmospheric effects (dust, grain overlays, gradient meshes) can push borderline contrast below the line — verify after the effect is applied

## Keyboard

**Every interactive element reachable via keyboard alone.** Test by putting away the mouse and Tab / Shift-Tab / Enter / Space / arrow keys through the interface.

- Focus order follows visual order (not DOM order if CSS reorders)
- `Tab` moves between controls; `Enter` / `Space` activates buttons and links; `Esc` dismisses modals/menus; arrow keys navigate within composite widgets (menus, radio groups, sliders)
- Custom controls (non-native buttons, non-native select): implement full keyboard behavior, not just `onClick`
- Skip-to-content link at the top of every page — invisible until focused

**Focus visibility:**
- The default browser focus ring is ugly but functional. Don't delete it without a replacement.
- Custom focus styles need ≥ 3:1 contrast against the adjacent background
- `:focus-visible` (not `:focus`) for keyboard-only focus rings — lets mouse clicks stay clean without losing keyboard clarity

## Semantic HTML

Prefer native elements over `<div role="button" tabIndex="0" onClick={...}>`. Native buttons, links, form controls, and landmarks come with keyboard behavior, focus management, and screen reader semantics for free.

**Landmarks:**
- `<header>`, `<nav>`, `<main>`, `<aside>`, `<footer>` — at most one `<main>` per page
- Heading hierarchy: one `<h1>`, then `<h2>`s, then `<h3>`s — don't skip levels
- `<section>` needs an `aria-labelledby` or it's just a `<div>` to a screen reader

**Forms:**
- Every input has a visible `<label>`. Placeholder text is not a label.
- Error messages associated via `aria-describedby`; form-level errors announced via `aria-live="polite"` (non-urgent) or `assertive` (urgent; use sparingly)
- Required fields marked both visually (color or `*`) and programmatically (`required` attribute)

## ARIA (when native isn't enough)

- `aria-label` / `aria-labelledby` for elements without visible text (icon-only buttons, close ✕ buttons)
- `aria-expanded` on disclosure controls (accordions, menus)
- `aria-controls` to connect a control to the region it toggles
- `aria-hidden="true"` for decorative icons
- `role="alert"` or `aria-live` regions for dynamic announcements

**Rules of ARIA (from the WAI):**
1. If a native HTML element or attribute exists for what you need, use that first.
2. Don't change native semantics with ARIA unless absolutely necessary.
3. All interactive ARIA controls must be keyboard-accessible.
4. Don't use `role="presentation"` / `aria-hidden="true"` on focusable elements.
5. Interactive elements must have an accessible name.

## Reduced Motion

Respect `prefers-reduced-motion` for animations, transitions, parallax, auto-playing video, scroll-triggered reveals. The aesthetic doesn't have to disappear — just slow down or still the motion.

```css
@media (prefers-reduced-motion: reduce) {
  *, *::before, *::after {
    animation-duration: 0.01ms !important;
    animation-iteration-count: 1 !important;
    transition-duration: 0.01ms !important;
    scroll-behavior: auto !important;
  }
}
```

Override per-element for critical motion (a loading spinner should still spin, just perhaps slower). The blanket rule above is a baseline; tune for context.

## Images, Icons, and Media

- `alt=""` for decorative images; descriptive `alt` for meaningful ones
- SVG icons that carry meaning: `role="img"` + `aria-label`; purely decorative SVGs: `aria-hidden="true"`
- Video: captions for any spoken content; autoplay muted; controls not hidden
- Audio-only: transcript

## Smoke Checklist (for quick audits)

- [ ] All text meets contrast (spot-check worst-case regions)
- [ ] Tab order matches visual order; all interactive elements reachable
- [ ] Visible focus ring on every focusable element
- [ ] Semantic HTML used where a native element exists
- [ ] Icon-only buttons have `aria-label` or visible text
- [ ] Form fields have labels; errors are associated
- [ ] `prefers-reduced-motion` respected
- [ ] No keyboard trap (you can Tab *out* of every modal/menu)
- [ ] Page heading hierarchy is sensible (one `<h1>`, no skipped levels)

## Testing

- **Manual keyboard:** Tab through the whole page
- **axe-core / Lighthouse** for automated audits (both run in Chrome DevTools)
- **Screen reader spot-check:** VoiceOver (macOS), NVDA (Windows), Orca (Linux). Hit the main flows once.
- **zoom test:** 200% browser zoom — does layout hold?

Automated tools catch ~30-40% of accessibility issues. Manual + screen reader catches most of the rest.

## Operational Context Note

For defense / ISR / operational dashboards — accessibility is especially not optional. Users operating complex systems under time pressure depend on clear focus, unambiguous contrast, and keyboard control. Industrial / brutalist / utilitarian aesthetics *can* be highly accessible if designed with care; they can also be less accessible if monochrome palettes push contrast near the floor.
