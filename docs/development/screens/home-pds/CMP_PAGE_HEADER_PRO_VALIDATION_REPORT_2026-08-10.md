# cmp_PageHeaderPro Validation Report — 2026-08-10

**Status:** corrected full candidate / one Studio smoke test pending  
**Component:** `cmp_PageHeaderPro`  
**Primary instance-safe reference:** `cmp_HeatMapPro`  
**Secondary instance-safe reference:** `cmp_SidebarNav`

## Confirmed incident

The original full `cmp_PageHeaderPro` definition could be accepted by Power Apps Studio, but inserting an instance caused Studio to close.

```text
DEFINITION_ACCEPTED = PASS
INSTANCE_SAFE       = FAIL
```

The technical root cause is not claimed beyond the evidence available.

## Method correction

The investigation initially moved too quickly into micro-reduction and over-generalized a separate CustomProperty experiment.

That approach is replaced by the following rule:

```text
PROBLEM COMPONENT
      ↓
find comparable PULSE INSTANCE_SAFE component
      ↓
full contract + body structural diff
      ↓
correct COMPLETE component
      ↓
one isolated smoke test
      ↓
only reduce if the corrected full component still fails
```

`cmp_HeatMapPro` is the primary positive reference because it proves that PULSE Source Code can safely contain complex `CustomProperties:` contracts with Inputs, Outputs, Tables, Colors, Booleans, Numbers, Records and Events. `cmp_SidebarNav` is the secondary reference because it also proves Inputs/Outputs/Events plus galleries, transparent hit surfaces and event-driven navigation.

## Structural comparison

### CustomProperties

Original header Inputs used a reduced declaration such as:

```yaml
Title:
  PropertyKind: Input
  DataType: Text
  Default: ="Punch Control Tower"
```

The instance-safe references normally use the complete Input metadata shape:

```yaml
Title:
  PropertyKind: Input
  DisplayName: Title
  Description: Component title
  DataType: Text
  Default: ="Heat Map"
```

This is the principal objective delta found across the header contract.

The corrected candidate now uses:

```text
PropertyKind
DisplayName
Description
DataType
Default
```

for every Input, following the stable PULSE reference pattern.

Events now also use the complete metadata form demonstrated by `cmp_SidebarNav`:

```text
PropertyKind
DisplayName
Description
ReturnType
Default
```

This does not assert that `DisplayName` or `Description` are universally mandatory. It deliberately removes an avoidable schema delta by copying the fuller known-good contract pattern.

### Body comparison

The remaining header constructions all have positive precedents in the stable PULSE components or have already passed reduced tests:

```text
ModernText@1.0.0                         → reduced PASS_B
GroupContainer@1.5.0                     → reduced PASS_A
Classic/Button@2.2.0                     → used by instance-safe PULSE components
Event invocation from control            → used by HeatMap and Sidebar
Transparent hit surface                  → used by Sidebar
Component-property bindings              → extensively used by HeatMap and Sidebar
Sibling/parent geometry formulas         → used throughout stable PULSE component layouts
CustomProperties Text/Boolean/Color      → proven in HeatMap/Sidebar
```

No unsupported `AccessibleLabel` is present on `Classic/Button@2.2.0` and no `Label@2.5.1 + Radius*` incompatibility exists in the candidate.

The header is structurally simpler than `cmp_HeatMapPro`: it has no Table input, Gallery, calculated Output, `Set(...)` state or nested data projection.

## Corrected full candidate

Canonical source:

```text
power-apps/components/cmp_PageHeaderPro.pa.yaml
```

Correction commit:

```text
ccaccacd2de75263edc20751eed0efec3c78da83
```

The canonical source is again self-contained and includes the complete `CustomProperties:` contract plus body.

## Required Studio validation — one test only

Do not run further property-by-property diagnostics before this test.

```text
1. replace/create cmp_PageHeaderPro from the corrected COMPLETE Source Code
2. save and allow formula validation
3. review App Checker for new component-attributable errors
4. insert one new instance on the isolated diagnostic screen
5. save
6. close/reopen Studio/app if insertion is stable
```

Result:

```text
PASS
→ INSTANCE_SAFE
→ proceed to public-contract/visual smoke validation and then Block 03

FAIL
→ only then resume controlled reduction, guided by the remaining structural delta against the stable references
```

## Current block consequence

```text
Block 02  = CORRECTED / PENDING ONE INSTANCE-SAFETY SMOKE TEST
Block 03  = BLOCKED UNTIL THAT TEST PASSES
cmp_PageHeaderPro = REVIEW_REQUIRED
```

No further microtest is requested unless the corrected complete component still fails.