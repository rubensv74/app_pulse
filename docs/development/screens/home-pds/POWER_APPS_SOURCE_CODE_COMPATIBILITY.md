# HOME_PDS — Power Apps Source Code Compatibility Register

**Status:** Active  
**Screen:** `scr_Home_PDS`  
**Source baseline:** `3b71b860ed869a970a5a1b43cc137a580118b30c`

This file records compatibility rules that Home_PDS must respect while producing Source Code YAML. Power Apps Studio + App Checker remain the final acceptance authority.

## 1. Validation authority

Reusable components have separate gates:

```text
SOURCE_VALID
→ COMPONENT_DEFINITION_ACCEPTED
→ INSTANCE_SAFE
→ PUBLIC_CONTRACT_VALIDATED
→ VISUAL_QA_VALIDATED
→ READY_FOR_INTEGRATION
```

Normative gate:

```text
docs/development/POWER_APPS_COMPONENT_VALIDATION_GATE.md
```

## 2. Confirmed control families

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

Reuse demonstrated versions/patterns instead of inventing generic syntax.

## 3. Known PULSE rules

### PA-COMP-001 — `Classic/Button@2.2.0` AccessibleLabel

Do not add `AccessibleLabel` without a demonstrated compatible example. Previous validation produced PA2108.

### PA-COMP-002 — Components inside galleries

Do not introduce reusable Canvas components as gallery children in Home_PDS.

### PA-COMP-003 — Radius properties are control-specific

Do not assume every control supports `RadiusTopLeft`, `RadiusTopRight`, `RadiusBottomLeft`, `RadiusBottomRight`.

### PA-COMP-004 — Prefer AutoLayout for major screen geometry

Use `GroupContainer@1.5.0` AutoLayout for major shell geometry; ManualLayout is valid inside bounded modules.

### PA-COMP-005 — Hidden service controls are allowed but deliberate

Use only when they isolate a clear orchestration responsibility.

### PA-COMP-006 — Typed initialization before remote payloads

Initialize collections/variables with stable compatible types before remote use.

### PA-COMP-007 — Remote modules need explicit states

At minimum:

```text
No context / not requested
Loading
Loaded with data
Loaded empty
Error
Retry where meaningful
```

### PA-COMP-008 — Do not mutate component internals from the screen

Use declared public contracts only.

### PA-COMP-009 — Global variables inside reusable components require caution

Do not assume hidden `Set(...)` state is multi-instance safe.

### PA-COMP-010 — Visual tokens come from PDS

Avoid arbitrary new UI tokens when PDS already defines them.

### PA-COMP-011 — Construction operation labels are NOT PaYaml root nodes

`PATCH`, `ADD CHILD`, `REPLACE CONTROL`, etc. are construction metadata, not legal Source Code roots. A pasteable full module uses actual roots such as `Screens:` or `ComponentDefinitions:`.

Confirmed prior error:

```text
PA1001 / YamlInvalidSyntax
Property 'Patch' not found on type PaModule
```

### PA-COMP-012 — Definition acceptance does NOT prove instance safety

Confirmed during Home_PDS Block 02.

```text
component source exists
        ≠
definition accepted
        ≠
instance safe
        ≠
ready for target-screen integration
```

The corrected `cmp_PageHeaderPro` later passed isolated instantiation. The original technical crash cause remains narrower than a universal rule and must not be guessed.

### PA-COMP-013 — Component definition/instance safety does NOT prove host-source custom-property resolution

Confirmed during Home_PDS Block 03 on 2026-08-10.

Observed sequence:

```text
cmp_PageHeaderPro definition accepted          PASS
corrected default instance inserted            PASS
screen Source Code binds custom properties     PA2108
```

The same PA2108 pattern occurred in two different screen edit contexts:

```text
03  partial child/control Source Code
03A complete Screens: Source Code
```

Rejected properties included:

```text
Context1Interactive
Context1Value
Context2Interactive
Context3Interactive
Context3Value
ShowHelp
UtilityEnabled
```

Standard instance properties such as `Height` and `Width` were not among the reported failures.

Therefore the earlier edit-surface hypothesis is **refuted for this incident**.

Positive counterexample:

`cmp_SidebarNav` is declared with `CustomProperties:` and `scr_PunchReview` successfully serializes host assignments such as:

```yaml
Control: CanvasComponent
ComponentName: cmp_SidebarNav
Properties:
  ActiveKey: =...
  ProjectCode: =...
  ProjectName: =...
```

Interpretation supported by evidence:

> A component can be definition-valid and instance-safe while the current screen Source Code parser still does not resolve its component-specific properties for host-side assignment.

Do **not** infer an undocumented internal metadata mechanism as confirmed cause.

Corrective pattern:

```text
base instance using only standard CanvasComponent properties
→ save
→ configure custom inputs on the selected instance through Studio property selector/formula bar
→ save and let Studio own host-side binding representation
```

If the public properties are not visible in Studio's instance property selector, the next action is **public-contract re-registration in Studio**, not more screen YAML variants.

Status: **effect confirmed; internal metadata cause unknown; operational workaround defined**.

## 4. Reusable component observations

### `cmp_SidebarNav`

Positive reference for a host-visible public contract serialized from screen Source Code.

### `cmp_HeatMapPro`

Positive reference proving complex `CustomProperties:` contracts, outputs/events, galleries and internal bindings are valid patterns in PULSE.

### `cmp_PageHeaderPro`

Current evidence:

```text
DEFINITION_ACCEPTED = PASS
INSTANCE_SAFE       = PASS
HOST_SOURCE_CUSTOM_PROPERTY_BINDING = FAIL (PA2108)
```

Use Block 03B Studio-resolved host integration until the binding representation is captured and validated.

## 5. New-rule template

```text
ID: PA-COMP-NNN
Block: NN
Control/version:
Property/pattern:
Studio error/effect:
Confirmed cause or UNKNOWN:
Compatible replacement / diagnostic action:
Commit fixing issue:
Status: confirmed | effect confirmed / cause pending
```

A new compatibility error blocks the next dependent functional block until corrected and revalidated.
