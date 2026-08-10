# cmp_PageHeaderPro Validation Report — 2026-08-10

**Status:** diagnostic closed / corrective authoring path adopted  
**Component:** `cmp_PageHeaderPro`  
**Canonical source:** `power-apps/components/cmp_PageHeaderPro.pa.yaml`

## Confirmed observed problem

The full component source contained a `CustomProperties:` block authored through Source Code. An instance of the full component caused Power Apps Studio to close.

Reduced validation produced:

```text
PASS_A  CanvasComponent + root GroupContainer
PASS_B  + hardcoded ModernText title/subtitle
PASS_C1 + Input/Text public property created manually in Studio
```

Cross-project evidence already available in the reusable knowledge base also demonstrates that a public property created manually in Studio can be stable while the equivalent `CustomProperties:` path authored through Source Code is not.

## Operational conclusion

Further binary diagnosis is stopped because it is no longer proportionate to the implementation goal.

For PULSE incremental component construction, the accepted operational boundary is:

```text
PUBLIC COMPONENT PROPERTIES
→ create/maintain in Power Apps Studio

COMPONENT BODY
→ maintain/paste through Source Code YAML
```

Therefore:

> The current `CustomProperties:` authoring path is not approved for pasteable reusable-component YAML in PULSE.

This conclusion is operational. It does not claim knowledge of the internal Microsoft serialization/hydration defect.

## Corrective action for cmp_PageHeaderPro

The component must be rebuilt using this order:

```text
1. create the required public properties manually in Studio
2. save the component
3. paste a body-only `ComponentDefinitions:` source that references those properties
4. insert one isolated instance
5. perform one App Checker + visual smoke test
6. integrate into scr_Home_PDS only if stable
```

The previous full-source version containing `CustomProperties:` must not be used for import/paste.

Normative rule:

```text
docs/development/POWER_APPS_COMPONENT_PUBLIC_PROPERTY_AUTHORING.md
```

## Diagnostic chain closure

```text
A   root container only                                  PASS_A
B   + hardcoded title/subtitle ModernText                PASS_B
C1  + one Input/Text property created manually Studio    PASS_C1
C2  binding micro-test                                    CANCELLED — no longer required
D   property-type-by-property-type diagnostics            CANCELLED — no longer required
E   event micro-diagnostics                               CANCELLED — no longer required
F   full binary reconstruction                            CANCELLED — no longer required
```

Reason for cancellation: the safe authoring boundary has been established sufficiently for implementation, and continuing micro-tests would delay delivery without proportionate value.

## Block consequence

```text
Block 02 = CORRECTIVE REBUILD REQUIRED
Block 03 = remains blocked until rebuilt header passes one isolated instance smoke test
```

The next deliverable is not another diagnostic component. It is the production `cmp_PageHeaderPro` rebuilt for the Studio-authored public-property workflow.
