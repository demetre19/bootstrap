---
name: ux-purpose-audit
description: "Audit app pages for UI elements that do not belong, are not wired up, have unclear purpose, missing affordances, weak labels, visual mismatch, or placeholder behavior using orchestrated subagents."
---

# UX Purpose Audit

Audit application UI for dead weight: elements that do not belong on the page, are not wired to real behavior, mislead users, or hide missing usability controls. The default output is an evidence-backed audit, not a redesign and not code changes.

Core rule:

> No UI object gets to exist unless it has a current purpose, a clear meaning, a working connection, and appropriate feedback.

Use this skill when the user asks for a UX audit, interface cleanup, dead button check, placeholder check, usability review, page element audit, "does anything not belong," "what UI is useless," "find broken controls," or similar.

---

## Operating Modes

### Quick Audit
Use when no running app or repo access exists. Review screenshots, DOM snapshots, pasted UI, or descriptions. Mark any finding based on inference as `[INFERENCE]`.

### Interactive Audit
Use when a running app is available. Inspect pages with browser tools, click controls, toggle state, submit safe forms, watch URL/DOM/state/network changes, and record actual observed behavior.

### Deep Audit
Use when code is available. Map visible elements to routes, components, handlers, state, API calls, permissions, and feedback. Use this mode for "is this hooked up?" proof.

Default: start with Interactive + Deep when both app and code are available.

---

## Orchestrator Responsibilities

The main agent is the audit orchestrator. It owns scope, element inventory, subagent fan-out, deduplication, scoring, and final recommendations.

### Step 1: Define Scope

Establish the audited surface:

- App URL or local run command if available.
- Pages/routes to inspect.
- User roles/permissions to consider.
- Important data states: empty, populated, loading, error, selected item, no selection, read-only, edit mode.
- Browser annotations if provided: viewport size, device scale, selected element selector, parent/container selector, neighboring element selectors, role/text snapshot, attributes such as `type`, `title`, `aria-*`, disabled state, semantic/destructive classes, truncated HTML fragments, and screenshot/DOM source.
- Explicit non-goals.

If the user does not specify scope, choose the smallest useful scope: current page plus obvious adjacent states. Do not ask unless the app cannot be accessed or the target page is unknowable.

### Step 2: Build Element Inventory

Create an inventory before judging. Include visible and actionable elements:

- Headers, nav items, tabs, breadcrumbs.
- Buttons, links, toggles, selects, filters, search, forms.
- Cards, labels, badges, empty states, toasts, modals.
- Icons, color-coded indicators, destructive controls.
- Bulk-action controls and selection controls.

For every element, record:

```md
Element ID:
Page/route:
Viewport/context:
Visible label/text/icon:
Role/type:
Location:
Selector/container/neighbor selectors:
Attributes/classes/title/aria:
Current state:
Expected user purpose:
Observed behavior:
Code owner if known:
Evidence:
```

### Browser Annotation Handling

When the user provides Brave/browser annotations, treat them as first-class evidence:

- Preserve selectors, container/parent/previous/next relationships, viewport, and device scale.
- Extract semantic attributes: `type`, `title`, `aria-label`, `aria-describedby`, `disabled`, `role`, and visible text.
- Use classes as evidence only when they imply user-facing state or semantics, such as `bg-destructive`, `disabled:opacity-50`, `hover:*`, `focus-visible:*`, sizing, truncation, or responsive visibility.
- Do not expose secrets from text or HTML. Keep masked values like `••••••` masked.
- Ignore browser-extension implementation attributes such as `data-dashlane-*` unless they visibly affect layout, labels, focus, or behavior.
- If an annotation is truncated, record it as partial evidence and avoid claims that require the missing portion.

### Step 3: Launch Specialist Subagents

Use the `task` tool when available. Spawn the widest independent batch. Subagents audit and report evidence; they do not run project-wide build, lint, format, or broad tests. They should not edit code unless the user explicitly asked for fixes.

Recommended grouping by evidence type:

#### Agent A: Purpose + Wiring + Feedback Integrity
Best combined because purpose cannot be trusted unless behavior is real.

Checks:
- Does the element have a current-page purpose?
- Is it wired to a handler, route, state update, API call, modal, or download?
- Does the action produce visible feedback?
- Does it fail silently?
- Does it appear usable when unavailable?
- Does disabled state explain why?
- Does behavior match label?

Proof ladder:

```text
Visible element
  -> accessible role / DOM node
  -> event handler / route / form action
  -> state mutation / API call / navigation / modal
  -> visible user feedback
  -> persisted or reversible result when expected
```

Hard fail if the chain breaks without a user-visible reason.

#### Agent B: Context Fit + Labels + Information Architecture
Group together because they depend on page meaning and user intent.

Checks:
- Does the element belong on this page, role, and data state?
- Is it legacy from an earlier app stage?
- Is it duplicated or competing with another control?
- Does the label name the actual result?
- Are terms consistent across pages?
- Are icons understandable without guessing?
- Are tooltips helping, or compensating for bad labels?

Examples:
- `Submit` that really means `Publish campaign`.
- `Delete` icon that archives.
- Global header action visible where it cannot operate.
- Filter label that no longer matches the data model.

#### Agent C: Visual Hierarchy + Semantic Styling
Group together because visual weight, color, icon scale, and spacing determine perceived importance.

Checks:
- Is the primary action visually primary?
- Are destructive actions visually distinct and not over-promoted?
- Are there multiple competing primary buttons?
- Do colors have consistent semantic meaning?
- Are icons proportional to nearby text and importance?
- Does spacing group related controls?
- Are decorative elements competing with task elements?
- Are there large aesthetic blocks that carry no information?

Apply the user preference for compact color swatches where relevant: use small square chips beside labels instead of oversized blocks for color pickers, palettes, and compact toggles.

#### Agent D: Missing Affordances + Workflow Completeness
Separate this from element critique because missing UI is invisible unless workflow is traced.

Checks for absent but expected controls:
- Select all / deselect all when bulk actions exist.
- Clear filters when filters exist.
- Reset, cancel, undo, or discard changes for risky edits.
- Delete/archive where users can create records.
- Empty-state CTA.
- Loading, success, and error recovery states.
- Confirmation or undo for destructive actions.
- Save feedback after edit.
- Search no-results recovery.
- Pagination or load-more where lists can grow.

#### Agent E: Accessibility + Keyboard + Interaction Semantics
Keep this separate because it requires a different inspection pass.

Checks:
- Tab order follows visual order.
- Focus state is visible.
- Buttons are buttons; links are links.
- Icon buttons have accessible names.
- Modals trap focus and close with Escape.
- Controls have sufficient hit area.
- Contrast is readable.
- Form inputs have labels and errors are announced or visible.
- Disabled controls are not the only path forward.

#### Optional Agent F: Adversarial Placeholder Hunter
Use for larger apps or when the user explicitly cares about placeholder removal.

Mission:
- Assume every polished-looking control may be fake.
- Try to disprove that the page is production-ready.
- Hunt for fake data, dummy nav, empty handlers, TODO labels, disabled-without-reason controls, broken icons, no-op filters, non-persisting toggles, and copied components left in the wrong context.

---

## Subagent Assignment Template

Use this structure when spawning audit agents:

```md
# Target
Audit these exact pages/routes/states: [list]. Do not edit code. Do not run project-wide build/lint/format/tests.

# Lens
Apply only this audit lens: [Purpose+Wiring+Feedback | Context+Labels | Visual+Semantic | Missing Affordances | Accessibility | Placeholder Hunter].

# Evidence Required
For every finding, include page/route, viewport/context when provided, element label or selector, observed behavior, expected behavior, severity, and proof. If code is available, cite file/function references. If browser annotations are provided, cite selector/container/neighbor selectors, relevant attributes/classes/title/aria values, and sanitized text snapshots without exposing secrets.

# Output
Return a concise findings table with: element, location, severity, evidence, recommendation, confidence.
```

---

## Scoring Rubric

Score each reviewed element. Do not score missing affordances as elements; record them separately as missing controls.

| Category | Points | Question |
|---|---:|---|
| Purpose | 0-2 | Does it serve a real current-page user goal? |
| Context fit | 0-2 | Does it belong for this page, role, and data state? |
| Wiring | 0-3 | Is it connected to real behavior with a complete action chain? |
| Label clarity | 0-2 | Does text/icon match the actual result? |
| Feedback | 0-2 | Does the user see loading/success/error/result? |
| Visual fit | 0-2 | Does visual weight and styling match importance/meaning? |
| Accessibility | 0-2 | Can keyboard/screen-reader users understand and operate it? |

Total: 15 points.

Verdicts:

| Score | Verdict |
|---:|---|
| 13-15 | Keep |
| 10-12 | Improve |
| 6-9 | Questionable |
| 0-5 | Remove or rebuild |

### Hard-Fail Overrides

Any hard fail makes the element `Remove/Rebuild before ship` regardless of score:

- Placeholder visible to users.
- Clickable element has no effect.
- Button/link/toggle performs a different action than its label implies.
- Destructive action has no confirmation, undo, or recovery path.
- Control appears usable but is unavailable in the current context.
- Fake data, fake stats, fake filters, fake navigation, or fake tabs.
- Disabled control lacks a visible reason when it blocks progress.
- Accessibility blocks keyboard operation or screen-reader understanding.
- Action fails silently.

---

## Severity Definitions

Use severity separately from score.

- **Critical:** Users can trigger data loss, cannot complete a core task, or are misled into trusting fake/broken UI.
- **High:** A visible control is dead, wrong, unavailable in context, or blocks a common workflow.
- **Medium:** Confusing label, weak feedback, missing expected convenience control, poor visual hierarchy.
- **Low:** Polish issue, minor icon sizing, minor copy inconsistency, non-blocking accessibility improvement.

---

## Debug-Deep Flow for Suspicious Elements

When an element might be dead or misplaced, trace it like a bug. If the `/debug-deep` skill is available, follow its evidence-first method.

Use this flow:

```text
FLOW: [Element label] - [Expected behavior]

Step 1: [VISIBLE ELEMENT]
  Page: [route]
  Element: [label/role/selector]
  Does: User sees/clicks/toggles/types
        |
        v
Step 2: [EVENT BINDING]
  File: [component path if known]
  Fn:   [handler]
  Does: [state update, validation, API call, navigation]
        |
        v
Step 3: [BOUNDARY]
  API/route/store: [endpoint/router/store]
  Does: [mutation/query/navigation]
        |
        v
Step 4: [USER FEEDBACK]
  UI result: [toast/modal/url/data update/loading/error]

BREAK POINT: [where expected behavior diverges from observed behavior]
```

Do not call an element unwired unless evidence shows the chain breaks or no chain exists.

---

## Final Report Format

Return a practical audit, not a lecture.

```md
# UX Purpose Audit

## Summary
- Pages/states audited:
- Browser/viewport evidence:
- Elements reviewed:
- Keep:
- Improve:
- Questionable:
- Remove/Rebuild:
- Missing affordances:
- Hard fails:

## Highest Priority Fixes
1. [Specific fix with page and element]
2. [Specific fix]
3. [Specific fix]

## Element Findings

| Element | Location | Score | Severity | Verdict | Evidence | Recommended Fix |
|---|---|---:|---|---|---|---|
| Export | Reports header | 4/15 | High | Remove/Rebuild | Click has no effect when report is empty; no disabled reason | Hide until report data exists, or disable with explanation and empty-state CTA |

## Missing Affordances

| Missing control | Location | Severity | Why it matters | Recommended Fix |
|---|---|---|---|---|
| Select all / deselect all | Contacts table | Medium | Bulk delete exists but selection is one-by-one | Add header checkbox with selected count and clear action |

## Hard Fail Details

For each hard fail, include the proof chain and break point.

## Recommended Cleanup Plan

Group fixes by safest implementation order:
1. Remove or hide dead placeholders.
2. Fix misleading labels and disabled-state explanations.
3. Wire broken controls or remove them.
4. Add missing workflow controls.
5. Adjust visual hierarchy and accessibility polish.

## Confidence and Gaps

State exactly what was observed, what was code-traced, and what remains unverified.
```

---

## Fix Mode

Only enter fix mode if the user explicitly asks to make changes.

Fix mode rules:

1. Start with hard fails and high-severity issues.
2. Prefer removing/hiding useless elements over inventing new behavior.
3. If an element should exist but is unwired, wire it at the real source: handler, state, API, route, permission, or feedback layer.
4. Preserve current design language unless the audit proves the design itself causes confusion.
5. Add or update focused tests only for behavior that can break: handlers, disabled states, permissions, bulk actions, destructive flows, persistence, and error handling.
6. Verify with the narrowest runnable scenario plus browser interaction when UI behavior changed.

Do not add placeholder fallbacks, fake confirmations, no-op handlers, or TODO comments as fixes.

---

## Quality Bar

A valid audit finding must include:

- Specific element.
- Specific page/state.
- Evidence from observation or code.
- Impact on user task.
- Concrete recommendation: keep, improve, hide, remove, rename, wire, move, or add missing control.

Reject vague findings like "make this cleaner" or "button could be better." Rewrite them into evidence-backed actions.
