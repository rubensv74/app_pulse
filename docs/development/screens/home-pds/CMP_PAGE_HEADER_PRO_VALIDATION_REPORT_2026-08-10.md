# cmp_PageHeaderPro Validation Report — 2026-08-10

**Status:** blocked at instance-safety gate / diagnostic reduction active  
**Component:** `cmp_PageHeaderPro`  
**Canonical source:** `power-apps/components/cmp_PageHeaderPro.pa.yaml`  
**Canonical blob SHA:** `3e72cc319dac876cbc1257284a6ec45029cc6639`  
**Construction artifact:** `docs/development/screens/home-pds/blocks/02A_page_header_text_overflow_fix.pa.yaml`  
**Construction artifact blob SHA:** `3e72cc319dac876cbc1257284a6ec45029cc6639`

The canonical component and Block 02A are byte-identical at this review point.

## Observed Studio incident

Insertion of an instance of the full `cmp_PageHeaderPro` causes Power Apps Studio to close before a normal instance smoke test can be completed.

This remains:

```text
FAIL_INSTANCE
```

The technical root cause remains:

```text
UNKNOWN
```

Do not attribute the closure to `ModernText`, events, transparent buttons, ManualLayout, custom properties or geometry formulas until the reduced chain isolates the first failing stage.

---

## Static validation result

```text
PASS_WITH_RUNTIME_RISK
```

### Checks passed

```text
PASS  valid top-level Source Code root: ComponentDefinitions:
PASS  component identity is cmp_PageHeaderPro
PASS  GroupContainer@1.5.0 is already demonstrated in PULSE
PASS  ModernText@1.0.0 is already demonstrated in PULSE
PASS  Classic/Button@2.2.0 is already demonstrated in PULSE
PASS  Rectangle@2.3.0 is already demonstrated in PULSE
PASS  no invalid protocol-level Patch: root exists
PASS  no AccessibleLabel is declared on Classic/Button@2.2.0
PASS  no Canvas component is nested inside a gallery
PASS  no global var* state is used inside cmp_PageHeaderPro
PASS  all inspected static ModernText controls use AutoHeight=true
PASS  no AutoHeight=false remains in the current component source
PASS  no explicit circular sibling geometry formula was found statically
```

### Derived geometry preflight

For instance width `W`:

```text
Actions.X  = W - 164
Context3.X = W - 356
Context2.X = W - 544
Context1.X = W - 732
Identity.Width = Max(250, W - 760)
```

Therefore:

```text
W >= 1010  → intended gap preserved
W ~= 998   → identity/context gap collapses
W < 998    → overlap begins
W < 732    → Context1 begins off-canvas
```

This is a confirmed layout limitation but **not** a confirmed cause of the Studio closure.

---

## Cross-project evidence that changes diagnostic priority

The reusable knowledge repository contains a separately reduced Power Apps case (`LL-PA-UI-003`) where:

```text
minimal component without CustomProperties                       PASS
same baseline + Input/Text CustomProperty authored in YAML       FAIL_INSTANCE
same functional Input/Text property created manually in Studio   PASS
```

That evidence does **not** prove that `cmp_PageHeaderPro` has the same root cause, but it makes Source-Code-authored `CustomProperties` a high-priority hypothesis because the current header defines many Text/Boolean/Color/Event custom properties.

The diagnostic sequence deliberately separates:

```text
basic Canvas component instance safety
→ primitive child-control safety
→ CustomProperty authoring/serialization safety
→ event safety
→ full layout complexity
```

---

## Diagnostic reduction results

### Stage A — root container only

Artifact:

```text
docs/development/screens/home-pds/diagnostics/02D1_cmp_PageHeaderPro_diag_stage_A.pa.yaml
```

Diagnostic identity:

```text
cmp_PageHeaderPro_DiagA
```

Content:

```text
CanvasComponent
+ fixed Width/Height
+ one GroupContainer@1.5.0
```

Excluded:

```text
CustomProperties
Events
ModernText
Buttons
Sibling geometry formulas
Transparent hit surfaces
Screen variables
Flows/data bindings
```

Studio result reported by the user on 2026-08-10:

```text
PASS_A
```

Observed effect:

```text
The instance inserts and Power Apps Studio remains open.
```

Confirmed consequence:

> The minimal Canvas component shell and a single `GroupContainer@1.5.0` are **not sufficient to reproduce the Studio closure**.

This does not prove those primitives can never participate in a later interaction, but it removes the bare component/root-container layer as the current smallest reproducer.

### Stage B — hardcoded ModernText, no CustomProperties

Artifact:

```text
docs/development/screens/home-pds/diagnostics/02D2_cmp_PageHeaderPro_diag_stage_B.pa.yaml
```

Diagnostic identity:

```text
cmp_PageHeaderPro_DiagB
```

Stage B adds only:

```text
hardcoded title ModernText@1.0.0
hardcoded subtitle ModernText@1.0.0
AutoHeight=true
Wrap=false
```

It still contains no custom properties, events, buttons, sibling-to-sibling geometry formulas or external bindings.

Result semantics:

```text
PASS_B = definition can be created and one instance inserted without Studio closing
FAIL_B = Studio closes/rejects during definition creation or instance insertion
```

If `PASS_B`, the next diagnostic is Stage C1: exactly one `Input/Text` CustomProperty authored in Source Code.

If `FAIL_B`, `ModernText`/its authoring combination becomes the first reduced failing surface and CustomProperties are not tested yet.

---

## Current diagnostic chain

```text
A   root container only                                  PASS_A
B   + hardcoded title/subtitle ModernText                PENDING
C1  + exactly one Input/Text CustomProperty in YAML      NOT STARTED
C2  if C1 fails: same property created manually Studio   NOT STARTED
D   + remaining non-event custom properties              NOT STARTED
E   + public Event properties and invocation              NOT STARTED
F   + context hit surfaces and final geometry             NOT STARTED
```

---

## Block status consequence

```text
Block 02  = FAILED / DIAGNOSTIC REDUCTION ACTIVE
Block 03  = MUST NOT START
cmp_PageHeaderPro = REVIEW_REQUIRED
```

The component can return to `PDS_CANDIDATE` only after the instance-safety gate, contract smoke test and visual QA pass in Studio.
