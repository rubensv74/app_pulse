# cmp_PageHeaderPro Validation Report — 2026-08-10

**Status:** blocked at instance-safety gate  
**Component:** `cmp_PageHeaderPro`  
**Canonical source:** `power-apps/components/cmp_PageHeaderPro.pa.yaml`  
**Canonical blob SHA:** `3e72cc319dac876cbc1257284a6ec45029cc6639`  
**Construction artifact:** `docs/development/screens/home-pds/blocks/02A_page_header_text_overflow_fix.pa.yaml`  
**Construction artifact blob SHA:** `3e72cc319dac876cbc1257284a6ec45029cc6639`

The canonical component and Block 02A are byte-identical at this review point.

## Observed Studio incident

Insertion of an instance of `cmp_PageHeaderPro` causes Power Apps Studio to close before a normal instance smoke test can be completed.

This is treated as:

```text
FAIL_INSTANCE
```

The user confirmed on 2026-08-10 that the requested full-component instance test cannot be completed because Studio closes. The technical root cause remains:

```text
UNKNOWN
```

Do not attribute the closure to `ModernText`, events, transparent buttons, ManualLayout or geometry formulas without a reduced reproducer.

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

The diagnostic sequence is therefore intentionally designed to separate:

```text
basic Canvas component instance safety
→ primitive child-control safety
→ CustomProperty authoring/serialization safety
→ event safety
→ full layout complexity
```

---

## Diagnostic reduction now activated

Do not test the full component again until the reduced chain identifies the failing surface.

```text
A   root container only; no CustomProperties
B   + hardcoded title/subtitle ModernText; still no CustomProperties
C1  + exactly one Input/Text CustomProperty authored in Source Code
C2  if C1 fails: recreate the same Input/Text property manually in Studio on the B baseline
D   + remaining non-event custom properties incrementally
E   + public Event properties and invocation
F   + context hit surfaces and final responsive geometry
```

This order deliberately tests the cross-project CustomProperty hypothesis before adding unrelated complexity.

### Stage A artifact

```text
docs/development/screens/home-pds/diagnostics/02D1_cmp_PageHeaderPro_diag_stage_A.pa.yaml
```

Diagnostic component identity:

```text
cmp_PageHeaderPro_DiagA
```

Stage A contains only a Canvas component, fixed Width/Height and one `GroupContainer@1.5.0`. It contains no custom properties, events, text, buttons, sibling formulas or data bindings.

Result semantics:

```text
PASS_A = definition can be created and one instance inserted without Studio closing
FAIL_A = Studio closes/rejects during definition creation or instance insertion
```

If `PASS_A`, Stage B is prepared next. If `FAIL_A`, stop: the problem is below the header contract/layout layer and must be investigated at the minimal Canvas-component authoring level.

---

## Block status consequence

```text
Block 02  = FAILED / DIAGNOSTIC REDUCTION ACTIVE
Block 03  = MUST NOT START
cmp_PageHeaderPro = REVIEW_REQUIRED
```

The component can return to `PDS_CANDIDATE` only after the instance-safety gate, contract smoke test and visual QA pass in Studio.
