# cmp_OperationalSkylinePro — Studio validation

**Component:** `cmp_OperationalSkylinePro`  
**Canonical source:** `power-apps/components/cmp_OperationalSkylinePro.pa.yaml`  
**Current lifecycle:** `REVIEW_REQUIRED`

## Static audit already applied

Closest positive references:

- `power-apps/components/cmp_HeatMapPro.pa.yaml`
- `power-apps/components/cmp_SidebarNav.pa.yaml`

Compatibility rules checked before authoring:

- no `Radius*` on `Label@2.5.1`;
- no `AccessibleLabel` on `Classic/Button@2.2.0`;
- no `Reset()` assumption on modern controls;
- no inline SVG;
- no `CanvasComponent` instance dependency;
- no new hidden global variable used as per-instance state;
- only control families already demonstrated in current PULSE source:
  - `GroupContainer@1.5.0`
  - `Label@2.5.1`
  - `Gallery@2.15.0`;
- `CustomProperties` follows the canonical Source Code component pattern.

Static outcome:

```text
PASS_WITH_RUNTIME_RISK
```

Reason: Power Apps Studio remains the authority for component-definition acceptance and instance safety.

## Gate 1 — definition acceptance

1. Open the active PULSE app in Power Apps Studio.
2. Add/import the component source using the supported Source Code workflow.
3. Use the complete canonical file:
   `power-apps/components/cmp_OperationalSkylinePro.pa.yaml`.
4. Save.
5. Wait for formula validation.
6. Run App Checker.

Expected result:

```text
COMPONENT_DEFINITION_ACCEPTED
```

If Studio rejects the source or closes, stop. Record the full error, line, Session ID and action in the compatibility register before changing the component.

## Gate 2 — isolated instance

Create a blank diagnostic screen and insert exactly one instance of:

```text
cmp_OperationalSkylinePro
```

Do not connect real Punch data yet.

Validate:

- component inserts without Studio closing;
- default sample skyline renders;
- title, legend, summary chips and bars are visible;
- horizontal gallery does not clip the last slot;
- no unexpected vertical scrollbar;
- selected slot uses PULSE selected background and border;
- marker pill renders;
- today accent renders;
- save succeeds;
- close/reopen succeeds;
- App Checker has no new component-attributable error.

Expected result:

```text
INSTANCE_SAFE
```

## Gate 3 — public contract

Exercise only one property family at a time.

### Text / Boolean / Number

Set:

```text
Title = "Punch Skyline"
Subtitle = "Open punches by planned week"
AxisLabel = "PLANNED WEEK"
ShowMarkers = true
ShowStatus = true
ShowLegend = true
ShowSummary = true
ShowValues = true
SlotWidth = 78
MaxValue = 0
```

### Table

Use a small local test table with four to eight slots and the exact documented contract.

### Output

Confirm that selecting a slot updates:

```text
SelectedSlotKey
SelectedSlotLabel
SelectedSlotValue
SelectedStatusText
SelectedSlot
```

### Event

Bind `OnSlotSelect` temporarily to a harmless diagnostic action, for example a local notification or label update owned by the diagnostic screen.

### Multiple-instance test

Insert a second component instance with different `Slots`.

Select different slots in each instance.

Pass condition:

```text
selection in instance A does not change instance B
```

This test is mandatory because the component intentionally avoids `Set()`-based selection state.

## Gate 4 — visual QA

Test at minimum:

```text
Width = 560
Width = 760
Width = 1000
Width = 1280
```

Check:

- title/subtitle do not collide with summary chips;
- summary chips hide cleanly below 760 px;
- legend remains legible;
- bars share a common baseline;
- largest bar remains within plot bounds;
- zero-segment fallback bar uses `BarColorHex`;
- segment stack fills the full bar height;
- value label does not collide with marker on the peak bar;
- long `SlotLabel`, `SlotCaption`, `StatusText` and tooltip values degrade acceptably;
- horizontal scroll works for long horizons;
- PDS text never drops below size 8;
- no shadow is introduced on standard panel surfaces.

## Gate 5 — first integration

Only after Gates 1–4 pass:

1. create a diagnostic Skyline screen or approved consuming block;
2. shape Punch data outside the component;
3. bind the resulting table to `Slots`;
4. bind `OnSlotSelect` to the host filtering behavior;
5. validate App Checker and target-screen behavior.

Recommended first data slice:

```text
OPEN Punches
grouped by PLANNED_DATE week
7–12 weekly slots
```

Do not begin with all individual punches.

## Validation result record

Update this file after Studio validation:

```text
Definition accepted:
Instance safe:
Public contract validated:
Two-instance isolation:
Visual QA:
Studio Session ID:
App Checker:
Validated by:
Date:
Notes:
```

After all mandatory checks pass, update `docs/design-system/COMPONENT_CATALOG.md` from `REVIEW_REQUIRED` to `PDS_CANDIDATE` or `ACTIVE` according to the validated scope.
