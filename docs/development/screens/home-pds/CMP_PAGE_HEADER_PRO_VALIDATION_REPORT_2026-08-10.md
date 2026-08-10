# cmp_PageHeaderPro Validation Report — 2026-08-10

**Status:** `INSTANCE_SAFE = PASS` / public-contract + final visual smoke pending  
**Component:** `cmp_PageHeaderPro`  
**Primary instance-safe reference:** `cmp_HeatMapPro`  
**Secondary instance-safe reference:** `cmp_SidebarNav`

## Original incident

The original full `cmp_PageHeaderPro` definition could be accepted by Power Apps Studio, but inserting an instance caused Studio to close.

```text
DEFINITION_ACCEPTED = PASS
INSTANCE_SAFE       = FAIL
```

The technical cause was not proven and is not retroactively narrowed beyond the evidence.

## Corrective method

The component was compared structurally against PULSE components already known to be instance-safe before performing further reduction.

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

Primary comparison references:

```text
cmp_HeatMapPro
cmp_SidebarNav
```

## Principal structural delta corrected

The original header used reduced Input declarations such as:

```yaml
Title:
  PropertyKind: Input
  DataType: Text
  Default: ="Punch Control Tower"
```

The stable PULSE references normally use the fuller Input contract shape:

```yaml
Title:
  PropertyKind: Input
  DisplayName: Title
  Description: Component title
  DataType: Text
  Default: ="Heat Map"
```

The corrected `cmp_PageHeaderPro` now models every Input using:

```text
PropertyKind
DisplayName
Description
DataType
Default
```

and Events using the complete pattern demonstrated by stable PULSE components:

```text
PropertyKind
DisplayName
Description
ReturnType
Default
```

This correction does **not** prove that `DisplayName` or `Description` are individually or universally mandatory. The demonstrated result is narrower: rebuilding the complete component contract from a known-good PULSE pattern removed the failing condition in this candidate.

## Body comparison

The remaining constructions either have positive precedents in stable PULSE components or passed prior reduced checks:

```text
GroupContainer@1.5.0                     → reduced PASS_A
ModernText@1.0.0                         → reduced PASS_B
Classic/Button@2.2.0                     → proven in stable PULSE components
Event invocation from control            → proven in HeatMap / Sidebar
Transparent hit surface                  → proven in Sidebar
Component-property bindings              → proven extensively
Sibling/parent geometry formulas         → proven pattern in PULSE layouts
CustomProperties Text/Boolean/Color      → proven in HeatMap / Sidebar
```

No unsupported `AccessibleLabel` exists on `Classic/Button@2.2.0` and no `Label@2.5.1 + Radius*` incompatibility was introduced.

## Corrected complete candidate

Canonical source:

```text
power-apps/components/cmp_PageHeaderPro.pa.yaml
```

Correction commit:

```text
ccaccacd2de75263edc20751eed0efec3c78da83
```

The source is self-contained and includes the complete `CustomProperties:` contract plus body.

## Studio result — 2026-08-10

The user created a new instance of the corrected complete component in Power Apps Studio and reported that everything remained stable.

```text
COMPONENT_DEFINITION_ACCEPTED = PASS
INSTANCE_SAFE                 = PASS
```

Confirmed consequence:

> The corrected complete `cmp_PageHeaderPro`, modeled against the stable PULSE component contract pattern, can now be instantiated without reproducing the Studio closure.

This closes the instance-safety incident. No further reduction is justified unless a later regression reproduces the failure.

## Remaining gate before normal Home_PDS integration

One compact public-contract/visual smoke validation remains. It should test multiple representative capabilities in one pass rather than restarting micro-diagnostics:

```text
Text input change
Boolean visibility change
one Event invocation
visual check for clipping / scrollbar / overlap
```

If that combined smoke test passes:

```text
PUBLIC_CONTRACT_VALIDATED = PASS
VISUAL_QA_VALIDATED       = PASS
Block 02                  = VALIDATED
Block 03                  = UNBLOCKED
```

## Current block consequence

```text
Block 02          = INSTANCE_SAFE / FINAL COMBINED SMOKE PENDING
Block 03          = BLOCKED ONLY BY THAT FINAL SMOKE
cmp_PageHeaderPro = REVIEW_REQUIRED until contract + visual smoke passes
```
