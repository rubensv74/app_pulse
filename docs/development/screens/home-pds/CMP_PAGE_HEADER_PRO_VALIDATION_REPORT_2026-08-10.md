# cmp_PageHeaderPro Validation Report — 2026-08-10

**Status:** blocked at instance-safety gate / diagnostic reduction active  
**Component:** `cmp_PageHeaderPro`  
**Canonical source:** `power-apps/components/cmp_PageHeaderPro.pa.yaml`  
**Canonical blob SHA:** `3e72cc319dac876cbc1257284a6ec45029cc6639`  
**Construction artifact:** `docs/development/screens/home-pds/blocks/02A_page_header_text_overflow_fix.pa.yaml`  
**Construction artifact blob SHA:** `3e72cc319dac876cbc1257284a6ec45029cc6639`

## Observed Studio incident

Insertion of an instance of the full `cmp_PageHeaderPro` causes Power Apps Studio to close.

```text
FAIL_INSTANCE
Technical root cause: UNKNOWN
```

Do not attribute the closure to `ModernText`, events, transparent buttons, ManualLayout, custom properties or geometry formulas until the reduced chain isolates the first failing stage.

---

## Static validation result

```text
PASS_WITH_RUNTIME_RISK
```

Confirmed statically:

```text
PASS  ComponentDefinitions root
PASS  demonstrated control families/versions
PASS  no Patch: root
PASS  no AccessibleLabel on Classic/Button@2.2.0
PASS  no Canvas component nested in gallery
PASS  no global var* state inside component
PASS  static ModernText uses AutoHeight=true
PASS  no explicit circular sibling geometry formula found
```

Confirmed layout limitation for instance width `W`:

```text
Actions.X  = W - 164
Context3.X = W - 356
Context2.X = W - 544
Context1.X = W - 732
Identity.Width = Max(250, W - 760)

W >= 1010  → intended gap preserved
W ~= 998   → gap collapses
W < 998    → overlap begins
W < 732    → Context1 begins off-canvas
```

This limitation is not a confirmed cause of the Studio closure.

---

## Diagnostic strategy

Cross-project evidence in the knowledge repository shows that a Source-Code-authored `CustomProperties:` path can be unsafe even when the same functional property created manually in Studio is stable. Therefore the diagnostic sequence avoids deliberately injecting a custom property through YAML and instead tests the Studio-created contract path.

```text
A   root container only
B   + hardcoded title/subtitle ModernText
C1  + one Input/Text property created manually in Studio
C2  + bind title ModernText to the Studio-created property
D   + remaining non-event public properties incrementally
E   + public Event properties and invocation
F   + context hit surfaces and final geometry
```

---

## Diagnostic results

### Stage A — root container only

Artifact:

```text
docs/development/screens/home-pds/diagnostics/02D1_cmp_PageHeaderPro_diag_stage_A.pa.yaml
```

Result reported by user on 2026-08-10:

```text
PASS_A
```

Observed:

```text
instance inserts and Studio remains open
```

Conclusion:

> Bare CanvasComponent + one `GroupContainer@1.5.0` is not sufficient to reproduce the closure.

### Stage B — hardcoded ModernText, no CustomProperties

Artifact:

```text
docs/development/screens/home-pds/diagnostics/02D2_cmp_PageHeaderPro_diag_stage_B.pa.yaml
```

Result reported by user on 2026-08-10:

```text
PASS_B
```

Observed:

```text
instance inserts and Studio remains open
```

Conclusion:

> Adding the current hardcoded `ModernText@1.0.0` title/subtitle pattern with `AutoHeight=true` and `Wrap=false` is not sufficient to reproduce the closure.

This materially reduces the probability that the crash is caused by the bare ModernText pattern alone.

### Stage C1 — one Studio-created Input/Text property

Baseline artifact:

```text
docs/development/screens/home-pds/diagnostics/02D3_cmp_PageHeaderPro_diag_stage_C_baseline.pa.yaml
```

Diagnostic identity:

```text
cmp_PageHeaderPro_DiagC
```

The Stage C baseline is equivalent in complexity to the PASS_B candidate and deliberately contains no `CustomProperties:` block.

After baseline insertion succeeds, create exactly one public property manually in Studio:

```text
Property name: TitleText
Property kind/direction: Data / Input
Data type: Text
Default: "Punch Control Tower"
```

Do not bind the title to the property yet.

Result semantics:

```text
PASS_C1 = property can be created manually, component saved, and a new instance inserted without Studio closing
FAIL_C1 = Studio closes/rejects after property creation or during instance insertion
```

Only after PASS_C1 should Stage C2 bind `lblPHDC_Title.Text` to:

```powerfx
cmp_PageHeaderPro_DiagC.TitleText
```

---

## Current diagnostic chain

```text
A   root container only                                  PASS_A
B   + hardcoded title/subtitle ModernText                PASS_B
C1  + one Input/Text property created manually Studio    PENDING
C2  + bind title to Studio-created property              NOT STARTED
D   + remaining non-event property types incrementally   NOT STARTED
E   + public Event properties and invocation             NOT STARTED
F   + context hit surfaces and final geometry            NOT STARTED
```

---

## Block consequence

```text
Block 02  = FAILED / DIAGNOSTIC REDUCTION ACTIVE
Block 03  = MUST NOT START
cmp_PageHeaderPro = REVIEW_REQUIRED
```

The component can return to `PDS_CANDIDATE` only after the instance-safety gate, public-contract smoke test and visual QA pass in Studio.
