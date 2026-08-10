# cmp_PageHeaderPro Validation Report — 2026-08-10

**Status:** diagnostic reopened / comparison against proven components active  
**Component:** `cmp_PageHeaderPro`

## Confirmed incident

The original full `cmp_PageHeaderPro` source could be defined, but inserting an instance caused Power Apps Studio to close.

```text
FAIL_INSTANCE
Technical root cause: UNKNOWN
```

## Correction of previous operational conclusion

A previous revision closed diagnosis and adopted the rule:

```text
PUBLIC COMPONENT PROPERTIES → Studio only
COMPONENT BODY              → Source Code only
```

That conclusion is withdrawn.

PULSE already contains working, integrated components whose canonical Source Code declares `CustomProperties:` directly:

```text
cmp_HeatMapPro
cmp_SidebarNav
```

They include Inputs, Outputs and Events and are instance-safe in PULSE. Therefore `CustomProperties:` cannot be treated as the root problem category.

The correct question is:

```text
Which concrete declaration or component delta separates cmp_PageHeaderPro from the working references?
```

## Confirmed reduced results

```text
PASS_A  CanvasComponent + root GroupContainer
PASS_B  + hardcoded ModernText title/subtitle
PASS_C1 + one Input/Text property created manually in Studio
```

These prove that the bare component shell, the current ModernText title/subtitle pattern, and Input/Text capability itself are not sufficient to reproduce the crash.

## Highest-priority structural delta

The original failing header declared many Inputs using a reduced shape such as:

```yaml
Title:
  PropertyKind: Input
  DataType: Text
  Default: ="Punch Control Tower"
```

Working `cmp_HeatMapPro` and `cmp_SidebarNav` Inputs normally use a fuller declaration:

```yaml
Title:
  PropertyKind: Input
  DisplayName: Title
  Description: Component title
  DataType: Text
  Default: ="Heat Map"
```

This is classified as:

```text
HYPOTHESIS — PRIORITY 1
```

not confirmed cause.

`DisplayName` / `Description` are not declared universally mandatory because working Output/Event declarations show valid variants. The comparison must be made by `PropertyKind` and proven reference pattern.

## Next diagnostic

Artifact:

```text
docs/development/screens/home-pds/diagnostics/02D4_cmp_PageHeaderPro_diag_stage_C_source_model.pa.yaml
```

Diagnostic component:

```text
cmp_PageHeaderPro_DiagCSource
```

It contains exactly one Source-Code-authored `Input/Text` property using the metadata shape demonstrated by the working PULSE components, plus one ModernText binding to it.

Result semantics:

```text
PASS_CSOURCE
→ Source-Code-authored Input/Text using the proven metadata shape is instance-safe
→ continue adding header contract deltas one at a time

FAIL_CSOURCE
→ still do not generalize to all CustomProperties because HeatMap/Sidebar remain positive counterexamples
→ inspect environment/component-state or another declaration difference
```

## Subsequent comparison order after PASS_CSOURCE

```text
1. Boolean Input with proven metadata shape
2. Color Input with proven metadata shape
3. Event declaration copied from working reference
4. event invocation from Classic/Button
5. transparent hit surface
6. chained sibling geometry
7. full header contract
```

One delta per stage.

## Block consequence

```text
Block 02  = FAILED / DIAGNOSTIC COMPARISON ACTIVE
Block 03  = MUST NOT START
cmp_PageHeaderPro = REVIEW_REQUIRED
```

Diagnosis remains open until the first failing delta is isolated and corrected.
