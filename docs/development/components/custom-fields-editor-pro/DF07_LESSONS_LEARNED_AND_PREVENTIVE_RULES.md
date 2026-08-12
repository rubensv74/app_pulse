# cmp_CustomFieldsEditorPro — DF-07 lessons learned and preventive rules

**Date:** 2026-08-12  
**Scope:** `cmp_CustomFieldsEditorPro` integrated as modal editor in `scr_PunchReview`  
**Evidence:** Power Apps Studio visual validation after DF-07A  
**Status:** functional behavior retained; UX improved; final visual approval still pending residual filtering-layout cleanup.

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

## 2. Residual issue visible after DF-07A

The compacting pass exposed a second-order visual defect in the **Filtering** section:

- labels/state text around `Filterable` and `More filters` can wrap, clip or overlap;
- the disabled filter controls below are geometrically correct, but the state labels above need independent spacing validation.

This is important: **a density improvement can create a new defect in adjacent text even when the controls themselves become smaller.**

Therefore DF-07A is an improvement but should not yet be declared `VISUAL_APPROVED`.

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

The original `Save / Cancel` area was positioned for the component's ideal design height while the real Punch Review modal could render with a smaller host height.

### PULSE rule

Persistent form actions must be anchored to the **actual available container height**, not to a fixed coordinate derived from the ideal component size.

Before approval, validate at least:

```text
minimum supported host height
nominal host height
maximum/desktop host height
```

And repeat the test with a field type that expands the editor, especially `Choice` / `MultiChoice`.

---

## PR-CF-UX-003 — Compact switches use external semantic labels

Large toggles with embedded state text created unnecessary visual weight.

### PULSE rule

For dense administration forms:

```text
small switch + external caption + optional small state text
```

Prefer this over a wide switch containing labels such as `Optional`, `Pinned`, `Active`, `Not filterable`, etc.

After compacting a switch, revalidate neighboring captions. Do not assume smaller control geometry means the whole row is visually safe.

---

## PR-CF-UX-004 — Visual density changes require a second-order clipping pass

A change intended to reduce control size can produce:

- wrapped captions;
- clipped state text;
- overlap with the next row;
- reduced click/focus area;
- disabled controls that no longer align with their labels.

### Mandatory post-density check

Inspect the **entire parent section**, not only the control changed.

For this editor the minimum sections are:

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

Earlier versions compressed explanatory and metadata text to very small sizes to make the editor fit.

### PULSE rule

Do not solve geometry primarily by shrinking text.

For dense PULSE editors:

- normal compact metadata should generally remain around the established readable component scale;
- sizes equivalent to 5–6 should be exceptional and require explicit Studio visual evidence;
- prefer reclaiming space through container geometry, spacing, control density and wrapping rules first.

`VISUAL_APPROVED` requires readable text at the actual runtime dimensions.

---

## PR-CF-UX-006 — Administration modals must expose real scope context

A project-level editor must show the project being modified.

### PULSE rule

Prefer:

```text
ProjectCode · ProjectName · Entity scope
```

over generic text such as:

```text
Current project
```

This is not decorative metadata; it is a safety/context control for administrative operations.

---

## PR-CF-UX-007 — Functional freeze and visual approval are separate gates

The editor backend and host contract can be functionally correct while the rendered form still has clipping or density defects.

Use distinct status:

```text
BACKEND / CONTRACT   FUNCTIONAL_FROZEN
FORM BEHAVIOR        FUNCTIONAL_FROZEN
VISUAL DENSITY       IN_VALIDATION
COLOR                PENDING or VISUAL_APPROVED independently
```

Do not infer `VISUAL_APPROVED` from the absence of formula errors.

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

---

## Current status after the 2026-08-12 Studio validation

```text
THREE-COLUMN ARCHITECTURE     FROZEN
BACKEND HOST CONTRACT         FUNCTIONAL_FROZEN
INTERNAL KEY MODEL            IMPROVED / VALIDATED VISUALLY
BOTTOM ACTION VISIBILITY      IMPROVED / VALIDATED VISUALLY
TOGGLE DENSITY                IMPROVED / VALIDATED VISUALLY
PROJECT CONTEXT               IMPROVED / VALIDATED VISUALLY
FILTERING CAPTION LAYOUT      NEEDS FINAL POLISH
FINAL VISUAL APPROVAL         PENDING
```

## Next visual checkpoint

`DF-07B` should be limited to final visual finishing, especially the Filtering section, spacing, clipping, typography consistency and Live Preview balance. It must not reopen backend behavior or the frozen three-column architecture.