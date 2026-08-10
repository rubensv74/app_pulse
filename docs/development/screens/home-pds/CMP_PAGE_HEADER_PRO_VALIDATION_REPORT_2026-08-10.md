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

The user confirmed on 2026-08-10 that the requested full-component instance test cannot be completed because Studio closes. The exact authoring surface of every reproduction has not yet been reduced to a minimal candidate, so the technical root cause remains:

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
PASS  public Event property pattern matches an already used PULSE Canvas component pattern
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

## Diagnostic reduction now activated

The full component is no longer used as the next diagnostic test. Reduction starts at Stage A.

```text
A  root container only
B  + title/subtitle identity
C  + three static context containers/text, no hit buttons/events
D  + action buttons with no component events
E  + public events and hit surfaces
F  + final full geometry/content
```

### Stage A artifact

```text
docs/development/screens/home-pds/diagnostics/02D1_cmp_PageHeaderPro_diag_stage_A.pa.yaml
```

Diagnostic component identity:

```text
cmp_PageHeaderPro_DiagA
```

Stage A contains only a Canvas component, fixed Width/Height and one `GroupContainer@1.5.0`. It deliberately contains no custom properties, events, text, buttons, sibling formulas or data bindings.

Result semantics:

```text
PASS_A = definition can be created and one instance inserted without Studio closing
FAIL_A = Studio closes/rejects during definition creation or instance insertion
```

The first failing stage becomes the smallest suspect surface and determines the next correction.

---

## Block status consequence

```text
Block 02  = FAILED / DIAGNOSTIC REDUCTION ACTIVE
Block 03  = MUST NOT START
cmp_PageHeaderPro = REVIEW_REQUIRED
```

The component can return to `PDS_CANDIDATE` only after the instance-safety gate, contract smoke test and visual QA pass in Studio.
