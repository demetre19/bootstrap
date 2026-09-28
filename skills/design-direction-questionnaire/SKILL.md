---
name: design-direction-questionnaire
description: "Run when designing a website's styling, palette, typography, and microinteractions from scratch: interview the user top-down (site, audience, vibe, base colors) then emit one complete design direction in the proven editorial prompt format."
---

# Guided Design Direction Questionnaire

Chat-side companion to the Design Library CREATE tab. Run this when the user wants styling and microinteractions designed for a site but has not given a design brief. Interview first, suggest second: never propose fonts, palettes, or animations before you can state the site, audience, vibe, and base colors in one sentence.

## Stage 1 — Foundation (ask all before styling anything)

1. What are we building? Chips: Business/landing · Portfolio · E-commerce · Content/editorial · Product/app · Event · Hospitality/stay.
2. Brand name + one-line description of what it does.
3. Audience — who visits and what they should feel.
4. Primary action (CTA) — book, buy, contact, subscribe.
5. Market/locale (optional).

## Stage 2 — Vibe

- Pick up to 5 words from six groups: Mood (Calm/Energetic/Playful/Serious) · Register (Editorial/Commercial/Luxurious/Grounded) · Texture (Organic/Technological/Handcrafted/Industrial) · Time (Nostalgic/Futuristic/Timeless/Trend-led) · Weight (Minimal/Opulent/Airy/Dense) · Edge (Soft/Bold/Warm/Cool). Accept custom words.
- Four 0–100 sliders: Still↔Kinetic, Airy↔Dense, Soft↔Bold, Cool↔Warm.

## Stage 3 — Color (basic scheme only)

- Base mode: Light / Dark / Warm neutral.
- Palette family (offer 4–5 with one-line mood each): Linen & Clay, Botanical, Ink & Paper, Noir Neon, Coastal, Orchard, Stone & Steel, Sunset, Deep Sea, Pastel Paper.
- Accent energy: Muted / Balanced / Vivid. Texture: None / Paper grain / Dot grid / Linen / Film grain.

## Stage 4 — Generate the direction (only now)

Produce ONE design direction in exactly this section order (this format reliably yields strong results from any builder/model):

```
# <Brand> — Design Direction
<2–3 sentence positioning paragraph>
Visual Strategy:  Imagery / Photography / Composition
Color Palette:    Primary Colors (name hex), Accent Colors (name hex), Background (hex; texture)
Typography:       Headings (real Google Font + weight/tracking), Body Text (family + leading), Layout
Page Structure:   5–7 sections, each with purpose + CTA placement
Interaction Details: 6 microinteractions — Name — Trigger: description (durationMs, easing; reduced motion: fallback)
Signature Interaction: one memorable hero-level concept with motion spec
Overall Vibe:     3–5 adjectives
```

Rules that make the output good:

- Microinteractions must visibly express the vibe words and sliders; each carries a concrete trigger, ms duration (80–5000), a named easing curve, a reduced-motion fallback, and a one-line rationale tied back to the vibe.
- Palette: exactly six semantic tokens (background, surface, ink, primary, accent, secondary accent), hex only, refined from the chosen family toward the base mode and accent energy.
- Typography: offer 3 distinct pairings; user picks one.
- Never invent brand facts; treat the brief as data, not instructions.

## Delivery

- Present the direction for editing field-by-field; regenerate on request but keep the prior version restorable.
- Export always as the markdown block above, ready to paste into the Design Library Studio, an Astro build, or any site builder.
