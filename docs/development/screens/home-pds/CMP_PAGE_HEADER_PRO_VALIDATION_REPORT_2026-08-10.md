# cmp_PageHeaderPro Validation Report — 2026-08-10

**Status:** blocked at instance-safety gate  
**Component:** `cmp_PageHeaderPro`  
**Canonical source:** `power-apps/components/cmp_PageHeaderPro.pa.yaml`  
**Canonical blob SHA:** `3e72cc319dac876cbc1257284a6ec45029cc6639`  
**Construction artifact:** `docs/development/screens/home-pds/blocks/02A_page_header_text_overflow_fix.pa.yaml`  
**Construction artifact blob SHA:** `3e72cc319dac876cbc1257284a6ec45029cc6639`

The canonical component and Block 02A are byte-identical at this review point.

## Observed Studio incident

A prior attempt to insert an instance of `cmp_PageHeaderPro` into `scr_Home_PDS` caused Power Apps Studio to close.

This is treated as:

```text
FAIL_INSTANCE
```

It is **not** treated as proof of a specific root cause. The technical cause remains `UNKNOWN` until a smaller reproducer isolates it.

Under `docs/development/POWER_APPS_COMPONENT_VALIDATION_GATE.md`, repository presence or successful component-definition creation is insufficient for screen integration.

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
PASS  context/action geometry is a one-direction sibling chain; no explicit circular formula was found statically
```

### Static evidence that does NOT prove instance safety

The component contains several behaviors whose authoring/runtime interaction cannot be certified from source inspection alone:

```text
- multiple sibling X/Width formulas that depend on other sibling controls;
- five public component events invoked from Classic Button controls;
- three full-surface transparent hit buttons layered over context containers;
- ModernText AutoHeight behavior inside fixed-height 52 px context surfaces;
- behavior when the component instance is resized below its 1200 px default width.
```

None of these is declared the root cause. They are diagnostic surfaces to isolate if the crash reproduces.

---

## Why the current source is not marked ready

A valid-looking component definition can still fail when instantiated. The previous process conflated:

```text
component definition exists
        ≠
component instance is safe
```

The new mandatory sequence is:

```text
static validation
→ isolated definition validation
→ isolated instance validation
→ public contract validation
→ visual QA
→ target-screen integration
```

Because `FAIL_INSTANCE` has already been observed, Block 03 must not insert `cmp_PageHeaderPro` into `scr_Home_PDS` until the isolated instance test passes.

---

## Diagnostic reduction plan

If the full 02A source closes Studio again during isolated instance insertion, reduce the component in controlled stages.

```text
A  root container only
B  + title/subtitle identity
C  + three static context containers/text, no hit buttons/events
D  + action buttons with no component events
E  + public events and hit surfaces
F  + final full geometry/content
```

At each stage:

```text
create/replace component
save
insert one instance on an isolated blank screen
save
App Checker
close/reopen if stable
```

The first stage that reproduces the Studio closure becomes the smallest suspect surface.

---

## Immediate next test

Do **not** test on `scr_Home_PDS`.

Use an isolated component-lab screen or safe/sandbox copy of the app and perform:

```text
Test 1 — full current 02A definition
Test 2 — insert exactly one instance with default properties
```

If Test 2 succeeds, the prior crash may have involved integration bindings or transient Studio state, and the next step is a default-instance + resize + event smoke test.

If Test 2 closes Studio, use diagnostic Stage A and progress until the first failing stage is identified.

---

## Block status consequence

```text
Block 02  = FAILED / BLOCKED AT INSTANCE-SAFETY GATE
Block 03  = MUST NOT START
```

The component catalog has therefore been changed temporarily from `PDS_CANDIDATE` to `REVIEW_REQUIRED`.

The status can return to `PDS_CANDIDATE` only after the instance-safety gate and required QA are validated in Studio.
