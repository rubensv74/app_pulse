# Power Apps Visual QA Guardrails

**Status:** Normative  
**Version:** 1.2  
**Scope:** PULSE Canvas Power Apps screens and reusable components  
**Applies to:** humans, ChatGPT, Codex and other agents producing Power Apps Source Code / Power Fx

---

## 1. Purpose

This document records recurring **visible UI defects** found during real Power Apps Studio validation and converts them into reusable implementation and acceptance rules.

A block can be functionally correct and still fail its visual gate.

Use this document together with:

```text
docs/design-system/PULSE_DESIGN_SYSTEM.md
docs/design-system/SAAS_INTERFACE_ARCHETYPES.md
docs/development/PROTOCOLO_CONSTRUCCION_MODULAR_PANTALLAS_POWER_APPS.md
```

---

## 2. Non-negotiable principle

> **Static UI text must never display an unintended scrollbar.**

Scrollbars are valid only where scrolling is an intentional interaction: scroll containers, long editable text, lists, galleries, tables or explicit scroll regions.

A scrollbar inside a title, subtitle, metadata line, field label/value, badge, KPI caption, context selector or other static text surface is a visible defect.

---

## 3. VQA-001 — Static ModernText shows an internal mini-scrollbar

### Origin

First formally detected during Studio validation of:

```text
HOME_PDS
Block 02 / 02A
Component: cmp_PageHeaderPro
```

### Evidence

Two successive Studio validations showed the same visual defect:

1. compact `ModernText` with small fixed heights produced internal scrollbars;
2. increasing the fixed height and setting `Wrap=false` while keeping `AutoHeight=false` did **not** reliably remove them.

Therefore the previous assumption —that a sufficiently large fixed height was an adequate default for compact `ModernText`— is rejected for new PULSE UI.

### Confirmed preventive rule

For **static `ModernText@1.0.0`** controls in reusable PULSE components/screens:

```text
AutoHeight = true
```

is the **default**.

If the visual contract is intentionally one line, combine it with:

```text
AutoHeight = true
Wrap       = false
```

A fixed `Height` may remain as base/minimum geometry, but it must not be relied upon as the only overflow protection.

### Exception

`AutoHeight=false` is allowed only when all of the following are true:

```text
- the rigid height is functionally necessary;
- the exact control/version has been validated in Power Apps Studio;
- no vertical or horizontal scrollbar appears;
- no clipping appears at normal zoom and agreed zoom checks;
- the exception is documented when used in a reusable component.
```

The burden of proof is therefore on the fixed-height exception, not on AutoHeight.

---

## 4. Text strategies

Every static text control must have an explicit overflow strategy.

### A. CONTENT_DRIVEN

Use when full content should remain visible and vertical growth is acceptable.

```text
AutoHeight = true
Wrap       = true
```

Typical uses:

- descriptions;
- explanations;
- validation messages;
- empty/error-state copy;
- comments/read-only narrative;
- subtitles that may legitimately wrap.

The parent layout must be able to accommodate growth.

### B. SINGLE_LINE_AUTOHEIGHT

**Preferred PULSE pattern for compact static ModernText.**

```text
AutoHeight = true
Wrap       = false
```

Typical uses:

- page titles designed as one line;
- context-selector labels;
- context-selector values;
- metadata;
- compact field labels;
- KPI captions;
- toolbar labels;
- textual chevrons/compact static glyphs when ModernText is used.

Width overflow must have an intentional strategy: wider control, truncation/clipping where supported, tooltip/detail surface, or different layout.

### C. FIXED_HEIGHT_EXCEPTION

```text
AutoHeight = false
Wrap       = false
Height     = Studio-validated value
```

Use only as a documented exception after Studio validation.

---

## 5. Prohibited risk pattern

Do not introduce this pattern as a default:

```text
ModernText
+ small font
+ fixed Height
+ AutoHeight=false
```

Adding `Wrap=false` or a few pixels of extra height does not by itself make this safe.

---

## 6. Guidance for compact PDS text

The following numbers are geometry starting points, not validation substitutes.

| PDS role | Font | Default strategy |
|---|---:|---|
| Page title | 20 | SINGLE_LINE_AUTOHEIGHT or CONTENT_DRIVEN |
| Page subtitle | 10 | SINGLE_LINE_AUTOHEIGHT or CONTENT_DRIVEN |
| Section title | 12 | SINGLE_LINE_AUTOHEIGHT |
| Panel subtitle | 9 | CONTENT_DRIVEN when wrapping is possible |
| Body/value | 9 | CONTENT_DRIVEN or SINGLE_LINE_AUTOHEIGHT according to contract |
| Label/metadata | 8 | SINGLE_LINE_AUTOHEIGHT |
| KPI label | 10 | SINGLE_LINE_AUTOHEIGHT |

The PDS typography floor remains unchanged: new reusable UI text should not use sizes below 8 without a documented exception.

---

## 7. Page Header application

For `cmp_PageHeaderPro` the intended text contract is now:

```text
Title          AutoHeight=true + Wrap=false
Subtitle       AutoHeight=true + Wrap=false
Context label  AutoHeight=true + Wrap=false
Context value  AutoHeight=true + Wrap=false
Chevron text   AutoHeight=true + Wrap=false
```

This rule is implemented in HOME_PDS Block `02A_page_header_text_overflow_fix.pa.yaml` and must be visually revalidated in Studio before Block 02 closes.

---

## 8. Mandatory visual QA gate for text

Every component/screen visual gate must include:

```text
[ ] No unintended vertical scrollbar inside static text.
[ ] No unintended horizontal scrollbar inside static text.
[ ] No text clipped vertically at normal zoom.
[ ] Static ModernText uses AutoHeight=true by default.
[ ] Any AutoHeight=false exception has explicit Studio evidence.
[ ] Dynamic values have an explicit width-overflow strategy.
[ ] Long realistic content has been tested where data-driven.
[ ] Blank/null content does not distort the layout.
[ ] AutoHeight growth does not overlap siblings or escape the parent.
[ ] Layout remains legible at 125% zoom.
[ ] Critical content is checked at 150% when feasible.
```

App Checker success does not satisfy this gate.

---

## 9. Agent implementation rule

Before publishing a reusable Power Apps component or screen block, the implementing agent must inspect **every text-bearing control**.

For `ModernText@1.0.0`, the default generation rule is:

```text
static text → AutoHeight=true
```

Then choose deliberately:

```text
Wrap=true   → content may grow to multiple lines
Wrap=false  → one-line visual contract
```

An agent must not generate `AutoHeight=false` for static ModernText merely to keep a compact layout unless that pattern is already proven safe for that exact control in Studio.

If Studio shows an internal scrollbar, the block remains open and the defect must be corrected before dependent blocks treat the implementation as canonical.

---

## 10. VQA-002 — Equal SVG viewBox does not imply equal optical icon size

### Origin

Detected during real Power Apps Studio validation of the PULSE custom SVG sidebar icon set on 2026-08-13.

Eight icons were placed in `20×20` Image controls using `ImagePosition.Fit`. Every SVG used the same `viewBox="0 0 24 24"`, yet several glyphs appeared materially smaller or weaker than their neighbors.

### Confirmed lesson

Mathematical equality is not optical equality.

A shared viewBox, stroke grammar and host size are necessary for consistency but are not sufficient. Perceived size also depends on:

```text
- occupied silhouette area;
- dominant-axis span;
- internal counters/negative space;
- detail density;
- visual center;
- stroke mass;
- recognizability at the target pixel size.
```

### Preventive rule

For primary PULSE navigation SVGs:

```text
viewBox             = 0 0 24 24
preferred host      = 20×20 px
ImagePosition       = Fit
optical test        = simultaneous side-by-side comparison
validation surface  = actual target surface, especially BrandDark sidebar
```

As a starting geometry envelope, the primary silhouette should normally occupy approximately **17–18 units on its dominant 24-unit axis**. This is not a rigid formula; perceived balance overrides mathematical equality.

Do not approve an icon family by inspecting isolated SVG source or individual controls. Compare the complete navigation family together.

### Acceptance checks

```text
[ ] No icon appears materially smaller/larger than its siblings at 20 px.
[ ] Stroke mass feels consistent across the family.
[ ] Visual centers align despite different metaphors.
[ ] Internal detail remains legible and does not collapse.
[ ] The silhouette is recognizable without relying on the label.
[ ] Active and inactive variants preserve the same geometry.
[ ] The family is checked on the actual dark sidebar.
[ ] 16 px and 24 px fallbacks are checked after the 20 px baseline passes.
```

---

## 11. Lessons-learned register

| ID | Origin | Lesson | Preventive rule |
|---|---|---|---|
| VQA-001 | HOME_PDS Block 02/02A · `cmp_PageHeaderPro` | Fixed-height ModernText can show mini-scrollbars; increasing Height + `Wrap=false` is not a reliable cure | Static ModernText defaults to `AutoHeight=true`; fixed-height usage is an exception requiring Studio proof |
| VQA-002 | PULSE SVG sidebar validation · 2026-08-13 | Common viewBox and identical Image size do not guarantee equal perceived icon size | Normalize and approve icon families optically at 20 px through simultaneous comparison on the actual target surface |

Future recurring defects must be added here and promoted into a dedicated rule when reusable across screens/components.

---

## 12. Acceptance statement

A PULSE interface is not visually complete merely because its formulas, colors, fonts and component placement are correct.

It must also be free of implementation artifacts such as unintended scrollbars, clipping, overlap, accidental wrapping, hidden focus states, inconsistent alignment and inconsistent icon weight that reduce perceived enterprise SaaS quality.
