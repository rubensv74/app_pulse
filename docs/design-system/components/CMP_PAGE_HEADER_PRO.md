# cmp_PageHeaderPro — PDS Component Specification

**Status:** Proposed / Block 02 implementation contract  
**Design System:** PULSE Design System v1  
**Component:** `cmp_PageHeaderPro`  
**Primary first consumer:** `scr_Home_PDS`  
**Future consumers:** Operational Review Workspace, Configuration Studio, Data Explorer and other PULSE screens

---

## 1. Purpose

`cmp_PageHeaderPro` is the canonical PULSE page-header component.

It provides a consistent top-level page identity and context surface without turning the header into a decorative card. It separates three responsibilities:

```text
PAGE IDENTITY      CONTEXT                         UTILITIES
Title / subtitle   Project / template / scope    Refresh / back / help
```

The component must be reusable across different SaaS archetypes. It defines the visual grammar of the page header, not the business logic of a specific screen.

---

## 2. Design principles

The component follows these PDS rules:

- white/surface background;
- subtle bottom divider;
- no normal-card shadow;
- no decorative outer radius;
- page title uses the PDS page-title hierarchy;
- context blocks are compact controls, not independent cards;
- one interaction blue only;
- utility actions do not compete visually with the page's operational primary action;
- context may be interactive or informational;
- all behavior is exposed through component events;
- no hidden global state is owned by the component;
- static `ModernText` uses `AutoHeight=true` by default to prevent internal mini-scrollbars.

The page's main operational action normally belongs to the body/action context, not the Page Header. The header is for identity, global/local context and utilities.

---

## 3. First Home_PDS usage

Target mapping:

```text
Title       Punch Control Tower
Subtitle    Open punch concentration, discipline distribution and operational drill-through

Context 1   Project       → selected project / interactive
Context 2   Template      → selected punch template / interactive
Context 3   Last refresh  → timestamp / informational

Utility     Refresh
Help        ?
```

Block 02 creates the reusable component only. Binding it to Home_PDS is Block 03.

---

## 4. Future Punch Review usage

The same component contract can later represent:

```text
Title       Punch Review Workspace
Subtitle    Sequential review, comments and custom fields

Context 1   Project
Context 2   Template
Context 3   Queue scope

Utility     Back to Punches
Help        ?
```

This demonstrates why the component contract uses generic context slots rather than Home-specific properties.

---

## 5. Public contract

### Identity inputs

```text
Title               Text
Subtitle            Text
```

### Context slot 1

```text
Context1Label        Text
Context1Value        Text
Context1Visible      Boolean
Context1Interactive  Boolean
OnContext1Select     Event
```

### Context slot 2

```text
Context2Label        Text
Context2Value        Text
Context2Visible      Boolean
Context2Interactive  Boolean
OnContext2Select     Event
```

### Context slot 3

```text
Context3Label        Text
Context3Value        Text
Context3Visible      Boolean
Context3Interactive  Boolean
OnContext3Select     Event
```

### Utility actions

```text
UtilityText          Text
ShowUtility          Boolean
UtilityEnabled       Boolean
ShowHelp              Boolean
OnUtility            Event
OnHelp               Event
```

### Visual inputs

```text
SurfaceColor               Color
SurfaceAltColor            Color
BorderColor                Color
TextColor                  Color
MutedTextColor             Color
AccentColor                Color
AccentSoftColor            Color
AccentHoverOverlayColor    Color
AccentPressedOverlayColor  Color
```

The two overlay colors are deliberately translucent. They are used only by the transparent click surface above an interactive context block so the underlying label/value remain readable on hover/press.

---

## 6. Deliberate exclusions from v1

The first version does **not** own:

- project/template data loading;
- ComboBox state;
- dropdown internals;
- navigation decisions;
- refresh logic;
- business primary action;
- badges/status banners;
- persistent global variables;
- responsive stacking logic beyond the stable desktop contract.

If Home_PDS needs a real selector UI, the screen owns the selector/popover and binds it through the context event. This prevents the Page Header from becoming a business-specific mega-component.

---

## 7. Visual geometry

Default component geometry:

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

The title/subtitle area has higher visual priority than context metadata, while utilities remain subordinate.

### 7.1. Text rendering rule

Studio validation of the first implementation exposed small internal scrollbars in several `ModernText@1.0.0` controls. A second attempt based on larger fixed heights plus `Wrap=false` still reproduced the defect while `AutoHeight=false` remained in place.

Therefore the canonical v1 contract is:

```text
Title          AutoHeight=true + Wrap=false
Subtitle       AutoHeight=true + Wrap=false
Context label  AutoHeight=true + Wrap=false
Context value  AutoHeight=true + Wrap=false
Chevron text   AutoHeight=true + Wrap=false
```

A fixed `Height` may remain as base geometry, but `AutoHeight=true` is the default protection against internal vertical overflow.

`AutoHeight=false` in a static `ModernText` is a documented exception and requires visual evidence in Studio that it produces neither scrollbar nor clipping.

Normative reference:

```text
docs/design-system/POWER_APPS_VISUAL_QA_GUARDRAILS.md
```

---

## 8. Interaction behavior

For an interactive context slot:

- default: SurfaceAlt + Border;
- hover: translucent ActionPrimary overlay that preserves label/value readability;
- press: slightly stronger translucent overlay;
- a `›` affordance is visible;
- click triggers the corresponding component event.

For an informational context slot:

- SurfaceAlt + Border remains;
- no chevron;
- no hover affordance;
- no action event is expected from the consuming screen.

Utility button:

- neutral surface;
- border + primary text/accent;
- soft blue hover;
- never rendered as destructive.

Help:

- neutral compact control;
- `?` visible label in v1;
- detailed accessibility hardening is performed in the dedicated accessibility block using only properties supported by the current Power Apps Source Code schema.

---

## 9. State ownership

`cmp_PageHeaderPro` is intentionally stateless.

The consuming screen owns:

```text
selected project
selected template
last refresh timestamp
open/closed selector state
refresh/loading state
navigation destination
```

The component only renders supplied values and raises events.

---

## 10. Acceptance criteria

Block 02 is acceptable when:

```text
[ ] cmp_PageHeaderPro can be created in Power Apps Studio
[ ] no screen must be modified to create the component
[ ] title and subtitle render with PDS hierarchy
[ ] three context slots render from public inputs
[ ] each context slot can be hidden independently
[ ] interactive context slots expose a clear affordance
[ ] hover/press overlay does not hide context text
[ ] informational context slots do not imply click behavior
[ ] utility action can be hidden/disabled
[ ] help can be hidden
[ ] events compile through the existing CanvasComponent event pattern
[ ] no global variable is used internally
[ ] no normal-card shadow is present
[ ] every static ModernText in the component uses AutoHeight=true unless a documented Studio-proven exception exists
[ ] no unintended vertical/horizontal scrollbar appears inside static text
[ ] no text is clipped or overlaps neighboring controls
[ ] no unsupported AccessibleLabel is added to Classic/Button@2.2.0
[ ] App Checker reports no new PA1001 / PA2108 attributable to the component
```

Only after Studio validation should the component be considered eligible for canonical consolidation under `main/components/`.
