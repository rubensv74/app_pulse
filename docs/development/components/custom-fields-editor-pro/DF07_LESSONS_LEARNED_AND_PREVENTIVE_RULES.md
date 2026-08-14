# cmp_CustomFieldsEditorPro — DF-07 lessons learned and preventive rules

**Date:** 2026-08-14  
**Scope:** `cmp_CustomFieldsEditorPro` integrated as modal editor in `scr_PunchReview`  
**Evidence:** Power Apps Studio visual validation through DF-06E-FIX4 and DF-07B preparation  
**Status:** functional behavior retained; UX improved; final visual approval pending readability-floor validation.

## Purpose

Capture the concrete rework observed while building the premium Custom Fields editor so the same mistakes are not repeated in this component, other PULSE components, or future Power Apps screens.

This document is project-specific. Reusable rules are also published in `rubensv74/functional-engineering-knowledge-base`.

---

## 1. What DF-07A corrected successfully

The Studio validation after DF-07A confirms that the following corrections materially improved the component:

1. **Internal Key is no longer treated as a normal user-authored business field.**
   - In `ADD`, the key is derived automatically from the field label.
   - The key control is disabled/read-only from the user's point of view.
   - The UI explicitly explains that the key is generated automatically.

2. **The form action bar is visible.**
   - `Cancel` and `Save` are no longer clipped below the modal viewport.
   - The action area is visually separated from the editable sections.

3. **Behavior toggles are materially more compact.**
   - Requirement, Pinning and Availability no longer dominate the center form.
   - The semantic labels remain readable outside the switch itself.

4. **Project context is now specific.**
   - The modal header shows the real project code/name instead of the generic `Current project` placeholder.
   - This reduces the risk of administering definitions in the wrong project context.

5. **Overall three-column architecture remains valid.**
   - `Field catalog → Field configuration → Live preview` continues to work and must remain structurally frozen unless a later requirement explicitly reopens it.

---

## 2. Active/Inactive host contract — validated lesson

DF-06E showed that multiple transient output properties can diverge from the visible draft state. The reliable host mutation was obtained by reading the stable `DraftDefinition` output instead of depending on separate `ActiveChangeFieldKey` / `ActiveChangeTarget` outputs.

### PULSE rule

When a reusable component exposes an aggregate draft contract that already contains the authoritative field values, host persistence should prefer that stable aggregate contract over several transient outputs unless there is a demonstrated reason not to.

---

## 3. Residual issue visible before DF-07B

The compacting passes successfully reduced visual weight, but the component still contains multiple texts at `Size = 5`, `6` and `7`. In the real Punch Review host these become microtext, particularly in:

- General captions;
- Behavior captions;
- Filtering captions;
- Options metadata;
- Live Preview flags and metadata;
- small catalog metadata.

This is important: **density is not premium when the user needs browser zoom or visual effort to decode secondary information.**

Therefore DF-07B-FIX1 introduces a readability floor without increasing input size or reopening geometry.

---

# Preventive rules for PULSE

## PR-CF-UX-001 — Classify technical identifiers before building the form

Before drawing a form, classify every field as one of:

```text
USER_AUTHORED
DERIVED
SYSTEM_MANAGED
IMMUTABLE_AFTER_CREATE
```

`FieldKey / Internal Key` belongs to the technical contract, not to normal business editing.

### PULSE rule

- `ADD`: derive `FieldKey` from the user-facing label.
- `EDIT`: keep the persisted `FieldKey` stable even when Label changes.
- always retain backend uniqueness validation.
- never let a visual convenience silently change an identifier used by integrations, filters or stored values.

---

## PR-CF-UX-002 — Do not position persistent action bars with design-time fixed Y assumptions

Persistent form actions must be anchored to the actual available container height, not to a fixed coordinate derived from the ideal component size.

Before approval, validate minimum supported host height, nominal host height and desktop/max host height, including Choice/MultiChoice.

---

## PR-CF-UX-003 — Compact switches use external semantic labels

For dense administration forms prefer:

```text
small switch + external caption + optional small state text
```

After compacting a switch, revalidate neighboring captions.

---

## PR-CF-UX-004 — Visual density changes require a second-order clipping pass

Inspect the entire parent section, not only the control changed. Minimum sections:

```text
General
Behavior
Filtering
Options
Form actions
Live preview
```

---

## PR-CF-UX-005 — Avoid microtypography as a substitute for layout work

Do not solve geometry primarily by shrinking text.

### PULSE readability floor for dense admin modals

```text
15 pt  modal title
10 pt  panel titles
9 pt   important field labels
8 pt   body/captions/normal metadata/buttons
7 pt   micro-badges or very secondary metadata only
<7 pt  not allowed without explicit exception and Studio evidence
```

If raising text creates overlap, fix spacing or container geometry. Do not revert to unreadable type solely to make the layout fit.

---

## PR-CF-UX-006 — Administration modals must expose real scope context

Prefer:

```text
ProjectCode · ProjectName · Entity scope
```

over generic `Current project` text.

---

## PR-CF-UX-007 — Functional freeze and visual approval are separate gates

Use distinct status:

```text
BACKEND / CONTRACT   FUNCTIONAL_FROZEN
FORM BEHAVIOR        FUNCTIONAL_FROZEN
VISUAL DENSITY       IN_VALIDATION
COLOR                PENDING or VISUAL_APPROVED independently
```

---

## PR-CF-UX-008 — Stable aggregate outputs beat transient event outputs for host persistence

If the component already publishes a complete current draft such as `DraftDefinition`, prefer that contract for host-owned persistence. Transient event outputs are acceptable for signaling intent, but should not become the only source of truth when they can diverge from the visible draft.

---

# Visual QA matrix required before final freeze

Before `cmp_CustomFieldsEditorPro` becomes `FINAL_FROZEN`, test in Power Apps Studio with real modal dimensions:

| Scenario | Required validation |
|---|---|
| ADD Text | generated key, Save/Cancel visible |
| ADD Number | preview and numeric control geometry |
| ADD Choice | Options editor expands without overlapping actions |
| ADD MultiChoice | multiple options, scrolling and action bar |
| EDIT persisted field | FieldKey remains immutable when Label changes |
| Required on/off | compact switch + captions |
| Pinned on/off | compact switch + captions |
| Active on/off | host mutation + local state + captions |
| Filterable on/off | filtering labels, mode/order controls, no clipping |
| Quick filter on/off | dependent state remains legible |
| Active only catalog on/off | compact catalog switch does not dominate header |
| Minimum modal height | no clipped actions or sections |
| Long label/help text | no unintended overlap |
| Long project name | header context remains readable |
| Readability floor | no text below 7 pt; normal captions/metadata readable at runtime |

---

## Current status after DF-06E-FIX4

```text
THREE-COLUMN ARCHITECTURE     FROZEN
BACKEND HOST CONTRACT         FUNCTIONAL_FROZEN
ACTIVE / INACTIVE              VALIDATED
INTERNAL KEY MODEL            VALIDATED
BOTTOM ACTION VISIBILITY      VALIDATED
TOGGLE DENSITY                VALIDATED
PROJECT CONTEXT               VALIDATED
READABILITY FLOOR             PENDING STUDIO VALIDATION
FINAL VISUAL APPROVAL         PENDING
```

## Next visual checkpoint

`DF-07B-FIX1` is limited to typography/readability. It must not reopen backend behavior or the frozen three-column architecture.