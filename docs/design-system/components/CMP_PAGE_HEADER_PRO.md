# cmp_PageHeaderPro — PDS Component Specification

**Status:** PDS candidate / Block 02 implementation contract  
**Design System:** PULSE Design System v1  
**Component:** `cmp_PageHeaderPro`  
**Canonical source:** `power-apps/components/cmp_PageHeaderPro.pa.yaml`  
**Primary first consumer:** `scr_Home_PDS`

---

## 1. Purpose

`cmp_PageHeaderPro` is the canonical PULSE page-header component.

It provides a consistent top-level page identity and context surface without turning the header into a decorative card. It separates three responsibilities:

```text
PAGE IDENTITY      CONTEXT                         UTILITIES
Title / subtitle   Project / template / scope    Refresh / back / help
```

The component is reusable across SaaS archetypes and defines page-header visual grammar rather than screen-specific business logic.

---

## 2. Design principles

- surface background;
- subtle bottom divider;
- no normal-card shadow;
- no decorative outer radius;
- PDS page-title hierarchy;
- compact context controls rather than nested cards;
- one interaction blue;
- utilities do not compete with the page's operational primary action;
- behavior is exposed through component events;
- no hidden global state;
- static `ModernText` uses `AutoHeight=true` by default to prevent internal mini-scrollbars.

---

## 3. Home_PDS mapping

```text
Title       Punch Control Tower
Subtitle    Open punch concentration, discipline distribution and operational drill-through
Context 1   Project       → interactive
Context 2   Template      → interactive
Context 3   Last refresh  → informational
Utility     Refresh
Help        ?
```

Block 02 creates/validates the reusable component. Screen binding is handled by the following integration block.

---

## 4. Reusable public contract

### Identity

```text
Title               Text
Subtitle            Text
```

### Context slots 1..3

Each slot exposes:

```text
ContextNLabel        Text
ContextNValue        Text
ContextNVisible      Boolean
ContextNInteractive  Boolean
OnContextNSelect     Event
```

### Utilities

```text
UtilityText          Text
ShowUtility          Boolean
UtilityEnabled       Boolean
ShowHelp             Boolean
OnUtility            Event
OnHelp               Event
```

### Visual inputs

```text
SurfaceColor
SurfaceAltColor
BorderColor
TextColor
MutedTextColor
AccentColor
AccentSoftColor
AccentHoverOverlayColor
AccentPressedOverlayColor
```

---

## 5. Deliberate exclusions

The component does not own project/template loading, selector internals, navigation decisions, refresh business logic, primary business actions, persistent global variables or large screen-level responsive decisions.

The consuming screen owns business state and binds it through inputs/events.

---

## 6. Visual geometry

```text
Height             80
Horizontal padding 16
Internal gap       12
Context height     52
Context radius     8
Utility height     36
Help size          36
Bottom divider     1
```

Typography:

```text
Page title         20 / Semibold
Page subtitle      10 / Normal
Context label       8 / Normal / muted
Context value       9 / Semibold
Utility             9 / Semibold
```

---

## 7. Text rendering rule

Studio validation exposed small internal scrollbars in compact `ModernText@1.0.0` controls. Increasing rigid height while leaving `AutoHeight=false` did not reliably remove the defect.

Canonical rule:

```text
Title          AutoHeight=true + Wrap=false
Subtitle       AutoHeight=true + Wrap=false
Context label  AutoHeight=true + Wrap=false
Context value  AutoHeight=true + Wrap=false
Chevron text   AutoHeight=true + Wrap=false
```

A fixed `Height` may remain as base geometry, but `AutoHeight=true` protects static text from vertical overflow. `AutoHeight=false` requires explicit Studio evidence that no scrollbar or clipping occurs.

Normative reference:

```text
docs/design-system/POWER_APPS_VISUAL_QA_GUARDRAILS.md
```

---

## 8. Interaction behavior

Interactive context slot:

- SurfaceAlt + Border by default;
- translucent primary overlay on hover/press;
- `›` affordance;
- click raises the slot event.

Informational context slot:

- SurfaceAlt + Border;
- no chevron;
- no implied action.

Utility and Help remain visually subordinate to the page's primary operational action.

---

## 9. State ownership

The consuming screen owns:

```text
selected project
selected template
last refresh timestamp
selector open/closed state
refresh/loading state
navigation destination
```

The component renders supplied state and raises events only.

---

## 10. Acceptance criteria

```text
[ ] component is accepted by Power Apps Studio
[ ] title/subtitle/context hierarchy matches PDS
[ ] context slots can be hidden independently
[ ] interactive slots expose affordance without hiding text
[ ] informational slots do not imply click behavior
[ ] utility can be hidden/disabled
[ ] help can be hidden
[ ] no hidden global state
[ ] no normal-card shadow
[ ] static ModernText uses AutoHeight=true unless a documented exception exists
[ ] no unintended internal scrollbar
[ ] no clipping/overlap
[ ] no unsupported AccessibleLabel on Classic/Button@2.2.0
[ ] App Checker introduces no PA1001/PA2108 attributable to the component
[ ] accepted complete source is synchronized to `power-apps/components/cmp_PageHeaderPro.pa.yaml`
```
