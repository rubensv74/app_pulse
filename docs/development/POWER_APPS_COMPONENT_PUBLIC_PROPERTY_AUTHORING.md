# Power Apps Component Public Property Authoring Rule

**Status:** normative  
**Canonical:** yes  
**Version:** 1.0  
**Last reviewed:** 2026-08-10

## Purpose

PULSE separates two authoring surfaces for reusable Canvas components:

```text
PUBLIC COMPONENT CONTRACT  → created and maintained in Power Apps Studio
COMPONENT BODY SOURCE       → maintained as pasteable Source Code YAML
```

This rule exists because a component body can be valid and instance-safe while a `CustomProperties:` block injected through Source Code can produce an unstable authoring path. In the current PULSE workflow, public properties must therefore be created in Studio rather than declared by the AI inside pasteable component YAML.

## Mandatory rule

> Do not include `CustomProperties:` in pasteable reusable-component YAML unless that exact authoring path has been explicitly proven `INSTANCE_SAFE` in the active app/version.

For current PULSE component work:

1. define the required public contract in documentation;
2. create each Input / Output / Event property manually in Power Apps Studio;
3. save the component definition;
4. paste/update only the component body Source Code;
5. bind internal controls to the Studio-created properties by name;
6. insert one instance and validate Studio stability;
7. only then integrate the component into a functional screen.

## Repository representation

A reusable component under active development is represented by two coordinated artifacts:

```text
power-apps/components/<component>.pa.yaml
    component body Source Code; must not invent Studio-managed public-property metadata

docs/design-system/components/<component-spec>.md
    public contract, defaults, types, interaction semantics and Studio setup
```

The repository remains the engineering source of truth for the contract, but Studio remains the authoring authority for the public-property metadata that the tested Source Code surface does not reliably represent.

## AI rule

An AI agent must not generate a `CustomProperties:` block for a reusable Canvas component merely because it knows the conceptual schema or has seen an example elsewhere.

Before giving component code to the user, it must provide:

```text
1. exact Studio public properties to create
2. property type / direction / data type
3. default value where applicable
4. complete body YAML to paste after the properties exist
5. one instance-safety validation step
```

## Failure interpretation

If the component body without `CustomProperties:` is instance-safe, but a full YAML version containing `CustomProperties:` closes Studio, the operational cause for this workflow is considered the unsupported/unsafe public-property authoring path.

The internal Microsoft serialization/hydration mechanism may remain unknown; it is not necessary to block implementation once the safe Studio-authored contract path is established.

## Related evidence

```text
docs/development/POWER_APPS_COMPONENT_VALIDATION_GATE.md
docs/development/screens/home-pds/CMP_PAGE_HEADER_PRO_VALIDATION_REPORT_2026-08-10.md
```
