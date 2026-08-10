# cmp_PageHeaderPro Validation Report — 2026-08-10

**Status:** isolated component stable / host Source Code custom-property binding unresolved  
**Component:** `cmp_PageHeaderPro`  
**Primary reference:** `cmp_HeatMapPro`  
**Secondary reference:** `cmp_SidebarNav`

## 1. Original instance-safety incident

The original full component definition could be accepted, but inserting an instance closed Power Apps Studio.

After comparison against stable PULSE components, the public Input contract was normalized to the proven complete pattern:

```text
PropertyKind
DisplayName
Description
DataType
Default
```

Events were normalized to the complete stable event form.

The corrected complete component was then inserted successfully:

```text
COMPONENT_DEFINITION_ACCEPTED = PASS
INSTANCE_SAFE                 = PASS
```

The original crash cause is not retroactively narrowed beyond that evidence.

## 2. Block 03 host integration incident

Block 03 attempted to assign `cmp_PageHeaderPro` custom properties from screen Source Code.

Studio returned `PA2108 Unknown property` for all component-specific properties tested while accepting the generic `CanvasComponent` structure and standard properties such as `Height` / `Width`.

Representative failures:

```text
Context1Interactive
Context1Value
Context2Interactive
Context3Interactive
Context3Value
ShowHelp
UtilityEnabled
```

## 3. Edit-surface hypothesis refuted

The first failure occurred in a partial child/control Source Code edit surface. A second candidate, Block 03A, rebuilt the complete `scr_Home_PDS` under a full `Screens:` root.

03A produced the same PA2108 pattern.

Therefore:

```text
partial edit surface is NOT sufficient to explain the failure
```

## 4. Positive PULSE reference

`cmp_SidebarNav` demonstrates that PULSE can serialize custom component instance properties from screen Source Code. `scr_PunchReview` contains working assignments to `ActiveKey`, `ProjectCode`, `ProjectName`, `UserRole`, and other component properties.

Thus the generic syntax is valid when the host resolves the component public contract.

## 5. Current evidence model

```text
SOURCE_VALID                            PASS
COMPONENT_DEFINITION_ACCEPTED           PASS
INSTANCE_SAFE                           PASS
HOST_SOURCE_CUSTOM_PROPERTY_RESOLUTION  FAIL / PA2108
PUBLIC_CONTRACT_HOST_BINDING            NOT YET VALIDATED
```

Interpretation:

> In the current app state, screen Source Code resolves `cmp_PageHeaderPro` as a generic CanvasComponent for host-side assignment but does not resolve its component-specific public properties.

This does not prove the internal metadata/registration mechanism responsible.

## 6. Block 03B corrective path

Do not rewrite the component again and do not continue producing equivalent screen YAML variants.

Use:

```text
base instance with only standard CanvasComponent properties
→ save
→ select the instance in Power Apps Studio
→ configure the seven required public inputs through Studio property selector / formula bar
→ save and let Studio own the host-side binding representation
```

Artifact:

```text
docs/development/screens/home-pds/blocks/03B_header_integration_studio_contract.md
```

If Studio exposes `Context1Value` and the remaining public properties on the instance, configure them in one pass and validate Block 03.

If Studio does not expose them, that is the decisive gate for **public-contract re-registration in Studio**.

## 7. Block consequence

```text
Block 02 = isolated component instance-safe
Block 03 = blocked until host-visible contract is validated
Block 04 = blocked by Block 03
```

No further micro-reduction is justified by the current evidence.
