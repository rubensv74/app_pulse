# Power Apps Visual QA Guardrails

**Status:** Normative  
**Version:** 1.0  
**Scope:** PULSE Canvas Power Apps screens and reusable components  
**Applies to:** humans, ChatGPT, Codex and other agents producing Power Apps Source Code / Power Fx

---

## 1. Purpose

This document records recurring **visible UI defects** found during real Power Apps Studio validation and converts them into reusable implementation and acceptance rules.

The goal is not to document isolated cosmetic incidents. The goal is to prevent small implementation details from degrading the perceived quality of otherwise well-designed SaaS interfaces.

Every new or modified PULSE screen/component must use this document as a visual QA reference together with:

```text
docs/design-system/PULSE_DESIGN_SYSTEM.md
docs/design-system/SAAS_INTERFACE_ARCHETYPES.md
docs/development/PROTOCOLO_CONSTRUCCION_MODULAR_PANTALLAS_POWER_APPS.md
```

A block can be functionally correct and still fail its visual gate.

---

# 2. Non-negotiable principle

> **Static UI text must never display an unintended scrollbar.**

Scrollbars are valid only when scrolling is an intentional part of the interaction model: scroll containers, long editable text, lists, galleries, tables or other explicitly scrollable regions.

A scrollbar inside a title, label, metadata line, field value, badge, KPI caption, context selector or other static text surface is a visual defect.

---

# 3. VQA-001 — Small text control shows internal scrollbar

## Origin

First formally recorded during Studio validation of:

```text
Screen construction: HOME_PDS
Block: 02 — PDS Page Header
Component: cmp_PageHeaderPro
Date: 2026-08-07
```

## Observed symptom

Compact `ModernText` controls used for context labels and values displayed very small vertical scrollbars.

The component layout, colors and spacing were otherwise correct, but the scrollbars produced an obvious visual-quality defect.

This type of defect is easy to miss in Source Code review and immediately visible in Studio.

## Typical cause

The risk appears when a text control combines:

```text
small font
+ fixed Height
+ wrapping/overflow behavior
+ insufficient vertical room for the rendered line box
```

The numeric font size alone is not sufficient to determine a safe control height. Rendering, line metrics, browser scaling and control implementation can make a seemingly adequate fixed height too small.

Microsoft documents `AutoHeight` for the modern Text control specifically to let the control increase its height when its content exceeds the visible area.

Reference:

```text
https://learn.microsoft.com/power-apps/maker/canvas-apps/controls/modern-controls/modern-control-text
```

Microsoft also records improvements related to AutoHeight and unintended scrollbars in the modern Text control. This reinforces the rule that text sizing must be explicit rather than assumed.

---

# 4. Mandatory text sizing strategy

Every static text control must deliberately use one of the following two modes.

## MODE A — CONTENT_DRIVEN

Use when the complete text must remain visible and vertical growth is acceptable.

Typical uses:

- page subtitle;
- panel explanatory text;
- descriptions;
- validation messages;
- empty/error-state explanations;
- comments or read-only narrative content;
- labels whose content can legitimately wrap.

Preferred pattern when supported by the control:

```yaml
AutoHeight: =true
Wrap: =true
```

The parent layout must also be capable of accommodating the resulting height.

Do not enable AutoHeight inside a rigid container without checking the effect on sibling controls and the parent height.

---

## MODE B — SINGLE_LINE_CONSTRAINED

Use when the UI contract requires one compact line.

Typical uses:

- context-selector labels;
- context-selector values;
- metadata;
- table headers;
- compact field labels;
- KPI captions;
- pills/badges where applicable;
- toolbar labels.

Pattern:

```yaml
AutoHeight: =false
Wrap: =false
Height: =[validated safe height]
```

The fixed height must be validated in Studio. It must not be chosen only from the font-size number.

If meaningful dynamic text may exceed the available width, the design must define the intended behavior explicitly: wider control, clipping/truncation, tooltip/detail surface or a different layout. It must not accidentally become an internal scroll region.

---

# 5. Prohibited pattern

The following combination is a visual-risk pattern and must not be introduced without explicit Studio validation:

```text
ModernText
+ small font (especially 8–10)
+ small fixed Height
+ Wrap/default overflow behavior
```

A reusable component containing this pattern cannot pass visual QA merely because formulas are valid.

---

# 6. PULSE default guidance for compact text

These values are **starting geometry**, not substitutes for Studio validation.

| PDS text role | Font size | Recommended strategy | Initial safe-height target |
|---|---:|---|---:|
| Page title | 20 | CONTENT_DRIVEN or validated fixed | 28–32 |
| Page subtitle | 10 | CONTENT_DRIVEN | 20–24 |
| Section title | 12 | SINGLE_LINE or CONTENT_DRIVEN | 22–24 |
| Panel subtitle | 9 | CONTENT_DRIVEN | 18–22 |
| Body/value | 9 | Depends on contract | 20–24 |
| Label/metadata | 8 | SINGLE_LINE or CONTENT_DRIVEN | 18–20 |
| Badge | 8 | SINGLE_LINE_CONSTRAINED | container-driven |
| KPI label | 10 | SINGLE_LINE or CONTENT_DRIVEN | 20–24 |

If a tested component needs more height than this table suggests, the tested value wins.

The PDS typography floor remains unchanged: new reusable UI text must not use sizes below 8 unless a documented exception exists.

---

# 7. Current Page Header application

For `cmp_PageHeaderPro`, the intended contract is:

```text
Title                  CONTENT_DRIVEN / adequate fixed height
Subtitle               CONTENT_DRIVEN / adequate fixed height
Context labels         SINGLE_LINE_CONSTRAINED
Context values         SINGLE_LINE_CONSTRAINED
Chevron                 fixed icon/text geometry
Utility buttons         fixed control geometry
```

For the compact context labels/values, explicitly disable wrapping and allocate a Studio-validated safe height.

Recommended correction starting point for the current component:

```text
Context label:  Size 8, Height 18, Wrap false
Context value:  Size 9, Height 22, Wrap false
```

Reposition the value if required so both lines remain vertically balanced inside the 52 px context surface.

Do not consider these numbers validated until the actual component is checked in Studio.

---

# 8. Visual QA gate for text controls

Every component/screen visual gate must include the following checks:

```text
[ ] No unintended vertical scrollbar inside static text.
[ ] No unintended horizontal scrollbar inside static text.
[ ] No text is clipped vertically at normal browser zoom.
[ ] Text remains legible at 125% browser zoom.
[ ] Critical/static text remains usable at 150% browser zoom where feasible.
[ ] Dynamic values have an explicit overflow strategy.
[ ] Long realistic content has been tested where the field is data-driven.
[ ] Blank/null content does not collapse or distort the layout unexpectedly.
[ ] AutoHeight controls do not overlap siblings or escape their parent layout.
[ ] Fixed-height text controls have been visually validated in Studio.
```

The absence of App Checker errors does **not** satisfy these visual checks.

---

# 9. Agent implementation rule

Before publishing any reusable Power Apps component or screen block, the implementing agent must inspect every text-bearing control and classify it as:

```text
CONTENT_DRIVEN
or
SINGLE_LINE_CONSTRAINED
```

The agent must not rely on an implicit/default text-overflow behavior.

When reviewing existing Source Code, a text control with a small fixed `Height` and no explicit sizing/overflow strategy must be treated as a visual QA risk.

If Studio evidence reveals an unintended scrollbar, the current block remains `corrected` / `pending revalidation`; the defect must not be carried into the next dependent block as accepted behavior.

---

# 10. Lessons-learned register

| ID | Date | Origin | Lesson | Preventive rule |
|---|---|---|---|---|
| VQA-001 | 2026-08-07 | HOME_PDS Block 02 / `cmp_PageHeaderPro` | Small fixed-height text controls can expose internal scrollbars even when the layout otherwise appears correct | Every static text control must use an explicit content-driven or single-line sizing strategy and pass the no-scrollbar Studio gate |

Future recurring visual defects should be added to this register and expanded into a dedicated rule when they can affect more than one screen/component.

---

# 11. Acceptance statement

A PULSE screen is not visually complete when it merely has correct colors, fonts, spacing and component placement.

It must also be free of implementation artifacts such as unintended scrollbars, clipping, overlap, hidden focus states, accidental wrapping, inconsistent alignment and other small defects that materially reduce perceived SaaS quality.
