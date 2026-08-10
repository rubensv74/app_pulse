# Power Apps Component Public Property Authoring Rule

**Status:** normative  
**Canonical:** yes  
**Version:** 1.1  
**Last reviewed:** 2026-08-10

## Purpose

Public Canvas-component properties may be represented successfully in Source Code YAML. PULSE already has working, instance-safe components such as `cmp_HeatMapPro` and `cmp_SidebarNav` whose canonical source contains `CustomProperties:` with Inputs, Outputs, Tables, Booleans, Colors and Events.

Therefore:

> `CustomProperties:` is **not** intrinsically unsafe and must not be prohibited as a category.

The correct rule is evidence-based: when authoring a new component contract, derive the property schema from a component that is already known to instantiate safely in the same app/schema, preserve its metadata shape, and validate the new component independently before target-screen integration.

## Proven reference models in PULSE

Primary references:

```text
power-apps/components/cmp_HeatMapPro.pa.yaml
power-apps/components/cmp_SidebarNav.pa.yaml
```

These prove that the following patterns can be valid in the active PULSE Source Code model:

```text
CustomProperties:
Input Text / Boolean / Number / Color / Table
Output Text / Boolean / Number / Record
Event ReturnType None
Default formulas
child controls bound to component inputs
child controls invoking component events
```

## Mandatory authoring rule

When a new reusable component needs a public contract:

1. choose the closest known-good PULSE component as schema reference;
2. copy the **structural metadata pattern**, not merely the conceptual property type;
3. for Input properties, include the metadata used by the proven model (`PropertyKind`, `DisplayName`, `Description`, `DataType`, `Default`) unless a known-good example proves a field may be omitted;
4. for Output/Event properties, follow a known-good pattern of the same kind;
5. keep the diagnostic increment small enough to isolate failure;
6. create/import the component definition;
7. insert one isolated instance;
8. only after `INSTANCE_SAFE` integrate it into a functional screen.

Manual Studio creation remains a useful **diagnostic comparator**, not the default replacement for Source Code contracts.

## Important correction from the 2026-08-10 incident

A reduced CMMS Functional Lab experiment showed one Source-Code-authored `Input/Text` property failing while the same property created manually in Studio was stable. That result was previously generalized too far.

The existence of working `cmp_HeatMapPro` and `cmp_SidebarNav` sources demonstrates that the valid conclusion is narrower:

```text
Observed failing YAML representation/path != proof that CustomProperties in YAML are generally unsafe
```

When such a contradiction appears, compare the failing property declaration with an instance-safe Source Code reference before changing the architectural authoring boundary.

## Repository representation

Reusable components remain self-contained canonical source where the validated schema supports it:

```text
power-apps/components/<component>.pa.yaml
    ComponentDefinitions
    + validated CustomProperties contract
    + component Properties
    + Children
```

The component specification under `docs/design-system/components/` documents semantics and acceptance criteria; it does not replace the canonical source contract.

## Failure interpretation

If a component with `CustomProperties:` closes Studio while a proven component with `CustomProperties:` does not, the investigation must focus on the **delta**:

```text
property metadata shape
default formula
property kind/data type
binding formula
event invocation
control combination
layout dependency
specific Studio/app state
```

Do not promote the broader container (`CustomProperties:`) to root cause unless a controlled comparison proves it.

## Related evidence

```text
power-apps/components/cmp_HeatMapPro.pa.yaml
power-apps/components/cmp_SidebarNav.pa.yaml
docs/development/POWER_APPS_COMPONENT_VALIDATION_GATE.md
docs/development/screens/home-pds/CMP_PAGE_HEADER_PRO_VALIDATION_REPORT_2026-08-10.md
```
