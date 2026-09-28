---
name: micro-interactions
description: "Designs fast, accessible CSS-first micro-interactions for this Next.js/Tailwind app without animation libraries unless explicitly justified."
---

# Micro-interactions Skill

Use this skill when designing page transitions, hover states, tap feedback, loading feedback, or small UI motion for the AI Business Center / Oh My Pi Next.js app.

## Goal

Create motion that feels fast, natural, and useful without adding runtime weight.

Default stack for this app:
- CSS-first motion in `app/globals.css`.
- Tailwind utility classes only when the motion is static and readable.
- No Framer Motion or animation package unless the user explicitly asks for complex choreographed enter/exit states.
- Minimal React state. Existing tab state may key a wrapper; avoid extra timers, RAF loops, observers, or per-item JS.

## Decision Rules

1. Speed first.
   - Page/tab transitions: 160–220ms.
   - Button hover/tap feedback: 120–200ms.
   - Loading/skeleton loops: subtle, slow enough to avoid visual noise.

2. Animate only compositor-friendly properties.
   - Prefer `opacity`, `transform`, `filter` sparingly.
   - Avoid animating `width`, `height`, `top`, `left`, margins, padding, shadows at large scale, or layout-affecting properties.

3. Respect user control.
   - If the app has a motion setting, gate custom motion behind `.micro-motion` or equivalent.
   - Always include `prefers-reduced-motion: reduce` safeguards.
   - Motion off must return to the current static UI, not a second animated style.

4. Keep business UI calm.
   - Motion should confirm state, guide attention, or add polish to true CTAs.
   - Do not animate every card or every row by default.
   - Avoid bouncy/ecommerce motion unless specifically requested.

5. Brand hierarchy.
   - True CTAs may get a tiny glint, lift, or color polish.
   - Secondary toggles stay neutral; selected state should remain mostly static with border/color indication.

## Recommended Patterns

### Page/tab transition

CSS:
```css
@keyframes page-panel-enter {
  from { opacity: 0; transform: translate3d(0, 8px, 0) scale(0.995); }
  to { opacity: 1; transform: translate3d(0, 0, 0) scale(1); }
}

.micro-motion .page-transition {
  animation: page-panel-enter 180ms cubic-bezier(0.22, 1, 0.36, 1);
  will-change: opacity, transform;
}

@media (prefers-reduced-motion: reduce) {
  .micro-motion .page-transition { animation: none; }
}
```

React:
```tsx
<div key={activeTab} className={motionEnabled ? 'page-transition' : undefined}>
  {activeTab === 'research' && <ResearchPanel />}
</div>
```

Why: one keyed wrapper, no animation library, no timers, transform/opacity only.

### CTA hover polish

CSS:
```css
.micro-motion button:not(:disabled) {
  transition: background-color 180ms cubic-bezier(0.22, 1, 0.36, 1),
    border-color 180ms cubic-bezier(0.22, 1, 0.36, 1),
    color 180ms cubic-bezier(0.22, 1, 0.36, 1),
    transform 180ms cubic-bezier(0.22, 1, 0.36, 1);
}

.micro-motion button:not(:disabled):hover { transform: translateY(-1px); }
.micro-motion button:not(:disabled):active { transform: translateY(0) scale(0.985); }
```

Use a special class only for true primary CTAs when adding a glint:
```tsx
<Button className="cta-sparkle">New Thumbnail</Button>
```

## Anti-patterns

- Do not install Framer Motion for simple page fade/slide transitions.
- Do not add JS timers or animation state for CSS-only interactions.
- Do not animate whole long lists; use one container transition or no motion.
- Do not make secondary toggle buttons colorful or flashy.
- Do not ignore the app-level motion toggle or reduced-motion media query.

## Acceptance Checklist

Before shipping:
- Motion setting defaults on and persists.
- Motion off removes page transition and CTA hover polish.
- `prefers-reduced-motion` disables animated transforms.
- `pnpm typecheck && pnpm lint` passes.
- Browser verification confirms a tab switch uses `.page-transition` only when motion is on.
