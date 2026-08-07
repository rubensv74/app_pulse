# HOME_PDS — Power Apps Source Code Compatibility Register

**Status:** Active  
**Screen:** `scr_Home_PDS`  
**Source baseline:** `3b71b860ed869a970a5a1b43cc137a580118b30c`  

This file records compatibility rules that Home_PDS must respect while producing Source Code YAML. It is a living register: every new Studio incompatibility discovered during construction must be added here after confirmation.

---

## 1. Validation authority

Static repository review can confirm patterns and existing control versions, but **Power Apps Studio + App Checker** remain the authority for compilation/acceptance.

No block may be reported as compiled merely because its YAML looks structurally valid.

---

## 2. Confirmed control families in the audited baseline

Examples present in the current PULSE source include:

```text
GroupContainer@1.5.0
Gallery@2.15.0
Classic/Button@2.2.0
Classic/Icon@2.5.0
Classic/TextInput@2.3.2
Label@2.5.1
ModernText@1.0.0
ModernButton@1.0.0
ModernCombobox@1.1.1
Spinner@1.4.6
CanvasComponent
Rectangle@2.3.0
Image@2.2.3
```

A block must reuse a demonstrated version/pattern where possible rather than assume the latest generic Power Apps syntax.

---

## 3. Known PULSE rules

### PA-COMP-001 — `Classic/Button@2.2.0` AccessibleLabel

Do not add an `AccessibleLabel` property to `Classic/Button@2.2.0` in this Source Code schema unless a later repository/Studio example proves support.

Previous PULSE validation produced PA2108 for this combination.

### PA-COMP-002 — Components inside galleries

Do not introduce reusable Canvas components as gallery children in Home_PDS. Existing PULSE implementation rules treat this as a compatibility/stability risk.

Use primitive controls inside galleries or move the reusable component outside the gallery boundary.

### PA-COMP-003 — Radius properties are control-specific

Do not assume every control supports `RadiusTopLeft`, `RadiusTopRight`, `RadiusBottomLeft`, `RadiusBottomRight`.

Before applying radius to a control type, copy a demonstrated pattern from the audited source or leave radius to a container that is known to support it.

### PA-COMP-004 — Prefer AutoLayout for major screen geometry

PULSE currently demonstrates `GroupContainer@1.5.0` AutoLayout successfully for root/shell layout.

Home_PDS major geometry should use AutoLayout. ManualLayout remains valid inside bounded modules where exact positioning is required.

### PA-COMP-005 — Hidden service controls are allowed but deliberate

The current PULSE source uses invisible service buttons/timers to isolate reusable Power Fx actions.

Allowed pattern:

```text
Visible = false
Width   = 1
Height  = 1
```

Use only when it clearly separates a reusable orchestration responsibility. Do not turn hidden controls into an unstructured second code-behind layer.

### PA-COMP-006 — Typed initialization before remote payloads

Collections and variables that later receive parsed JSON or remote results must be initialized with stable compatible types before use.

Punch Review is the current reference pattern for typed collections.

### PA-COMP-007 — Remote modules need explicit states

Every remote Home_PDS module must have at least:

```text
No context / not requested
Loading
Loaded with data
Loaded empty
Error
Retry where meaningful
```

Do not implement only the successful-data path.

### PA-COMP-008 — Do not mutate component internals from the screen

Home_PDS interacts with components only through declared custom properties/events/outputs.

If a needed contract does not exist, modify/version the shared component in an isolated component block rather than depend on internal control names from the consuming screen.

### PA-COMP-009 — Global variables inside reusable components require caution

A reusable component must not use screen/global variables as hidden per-instance state where multiple component instances could collide.

Prefer component inputs/outputs or demonstrably instance-safe patterns. Any legacy component using globals internally must be inspected before adding a second simultaneous instance.

### PA-COMP-010 — Visual tokens come from PDS

New Home_PDS code must not introduce new arbitrary hardcoded colors/radii/spacing when a PDS token exists.

Data-visualization colors such as discipline colors are the explicit exception and must remain semantically data-bound.

---

## 4. Reusable component observations

### `cmp_SidebarNav`

Uses `GroupContainer@1.5.0`, `Gallery@2.15.0`, classic icons and the established `NavItems`/`ActiveKey` contract. Safe reference for Block 01 shell.

### `cmp_KpiCardPro`

Uses `GroupContainer@1.5.0` and `Classic/Button@2.2.0`; screen should use only declared component properties. PDS visual hardening can be performed independently if needed.

### `cmp_HeatMapPro`

Already exposes state, selection, surface, border and accent contracts. Do not rebuild heatmap internals in the Home_PDS screen.

### `cmp_DonutPro`

Exposes segment table, selected segment outputs, center presentation and state. Preferred candidate for Home_PDS discipline distribution.

### `cmp_ActionToolbarPro`

Consumes a table of action definitions. Home_PDS must provide its own action semantics; do not rely on the component's demonstration/default `CLEAR_FILTERS` danger tone.

### `cmp_DataTableProV2`

Exposes external rows/pagination/sorting/selection contracts. Backend/page orchestration belongs to Home_PDS services, not the component.

---

## 5. New-rule template

When Studio identifies a new incompatibility, append:

```text
ID: PA-COMP-NNN
Block: NN
Control/version:
Property/pattern:
Studio error:
Confirmed cause:
Compatible replacement:
Commit fixing issue:
Status: confirmed
```

A new compatibility error blocks the next dependent functional block until corrected and revalidated.
