# Power Apps Reusable Component Validation Gate

**Status:** normative  
**Canonical:** yes  
**Version:** 1.1  
**Last reviewed:** 2026-08-10

## Purpose

A reusable Canvas component must not be considered ready for screen integration merely because its `.pa.yaml` exists in Git or because the component definition can be created in Studio.

PULSE distinguishes:

```text
BODY_SOURCE_VALID
PUBLIC_CONTRACT_CREATED_IN_STUDIO
COMPONENT_DEFINITION_ACCEPTED
INSTANCE_SAFE
PUBLIC_CONTRACT_VALIDATED
VISUAL_QA_VALIDATED
READY_FOR_INTEGRATION
```

The public-property authoring rule is defined in:

```text
docs/development/POWER_APPS_COMPONENT_PUBLIC_PROPERTY_AUTHORING.md
```

## Mandatory authoring boundary

For the current incremental PULSE workflow:

```text
Public Inputs / Outputs / Events → create in Power Apps Studio
Component body controls/formulas → maintain in Source Code YAML
```

Do **not** inject a `CustomProperties:` block into pasteable reusable-component YAML unless that exact path has independently demonstrated `INSTANCE_SAFE` in the active app/version.

The repository still documents the complete component contract, but Studio is the authoring authority for public-property metadata.

---

## Gate 0 — Repository/static body validation

Before giving component body YAML to the user, verify:

```text
[ ] source starts at a demonstrated PaYaml root (`ComponentDefinitions:`)
[ ] component identity is unique and consistent
[ ] no `CustomProperties:` block is included under the current Studio-authored-contract rule
[ ] required Studio public contract is documented separately
[ ] every control family/version is demonstrated in the current repository or verified
[ ] properties are compatible with declared control versions
[ ] no protocol operation label is represented as an invalid PaYaml node
[ ] no unsupported property already recorded in compatibility registers is present
[ ] no hidden global variable is used as per-instance state unless explicitly audited
[ ] no prohibited component nesting pattern is introduced
[ ] sibling/parent formulas have no circular dependency
[ ] geometry formulas have a defined safe range
[ ] static ModernText follows the current AutoHeight/Wrap QA rule
```

Static result values:

```text
PASS_STATIC
FAIL_STATIC
PASS_WITH_RUNTIME_RISK
```

Static review can never produce `READY_FOR_INTEGRATION` by itself.

---

## Gate 1 — Studio public contract creation

Before pasting body YAML that references public properties, create those properties manually in Studio from the documented contract.

For each property record:

```text
Name
Property type / direction
Data type
Default value if applicable
Purpose
```

Pass condition:

```text
PUBLIC_CONTRACT_CREATED_IN_STUDIO
```

If adding a Studio-created property itself destabilizes the component, stop and isolate that property type.

---

## Gate 2 — Component-body acceptance

After the public contract exists in Studio:

```text
1. paste/replace the component body Source Code
2. save
3. wait for formula validation
4. review App Checker
```

Pass condition:

```text
COMPONENT_DEFINITION_ACCEPTED
```

If Studio rejects the body or closes, stop before target-screen integration.

---

## Gate 3 — Isolated instantiation smoke test

Insert exactly one instance on a blank diagnostic screen with default properties.

Validate:

```text
[ ] instance inserts without Studio closing
[ ] component renders at its default size
[ ] save succeeds
[ ] reopen succeeds
[ ] App Checker shows no new component-attributable error
```

Pass condition:

```text
INSTANCE_SAFE
```

A Studio crash/forced close during insertion is an automatic `FAIL_INSTANCE`.

---

## Gate 4 — Public contract smoke test

Only after `INSTANCE_SAFE`, exercise the public contract in isolation:

```text
[ ] text inputs
[ ] Boolean inputs
[ ] color inputs only when actually needed
[ ] outputs, if any
[ ] each event independently
[ ] multiple instances if required by the component contract
```

No consuming screen should reach into internal control names.

---

## Gate 5 — Visual QA

Validate with realistic content:

```text
[ ] no unintended scrollbar
[ ] no clipping
[ ] no overlap
[ ] no negative/off-canvas geometry in supported width range
[ ] hover/pressed/disabled states render correctly
[ ] PDS tokens are respected
```

For text controls, apply `docs/design-system/POWER_APPS_VISUAL_QA_GUARDRAILS.md`.

---

## Gate 6 — Target-screen integration

Only now may a feature block insert the component into a real target screen.

Integration responsibilities:

```text
bind real inputs
bind events
bind context/navigation
validate target screen
run App Checker
confirm no regression in fallback/current screen
```

---

## Failure isolation

Do not repeatedly retest the same full component after a confirmed authoring-path problem.

Reduce only when needed to distinguish between:

```text
component shell
primitive child controls
Studio-created public contract
body-to-public-property bindings
events
layout/geometry
```

Once a safe authoring boundary is demonstrated, adopt it as the implementation rule and stop spending time trying to make the unsafe path work.

---

## Required evidence record

For every failed component gate record:

```text
Component
Canonical source SHA/commit
Studio/environment
Action being performed
Observed effect/error
Session ID if available
Public contract authoring path
Instance insertion status
App Checker status
Confirmed operational cause or UNKNOWN
Corrective authoring path
Revalidation result
```

---

## Lifecycle mapping

```text
body source created                         → REVIEW_REQUIRED
Studio public contract created              → REVIEW_REQUIRED
component body accepted                     → REVIEW_REQUIRED
INSTANCE_SAFE + contract + QA                → ACTIVE / PDS_CANDIDATE
FAIL_INSTANCE                                → REVIEW_REQUIRED + dependent block stopped
```

The component catalog must reflect this state.
