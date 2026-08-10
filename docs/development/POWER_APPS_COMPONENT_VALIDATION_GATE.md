# Power Apps Reusable Component Validation Gate

**Status:** normative  
**Canonical:** yes  
**Version:** 1.2  
**Last reviewed:** 2026-08-10

## Purpose

A reusable Canvas component must not be considered ready for screen integration merely because its `.pa.yaml` exists in Git or because the component definition can be created in Studio.

PULSE distinguishes:

```text
SOURCE_VALID
COMPONENT_DEFINITION_ACCEPTED
INSTANCE_SAFE
PUBLIC_CONTRACT_VALIDATED
VISUAL_QA_VALIDATED
READY_FOR_INTEGRATION
```

`CustomProperties:` is allowed in canonical Source Code when its schema is derived from an instance-safe PULSE reference. Working `cmp_HeatMapPro` and `cmp_SidebarNav` prove that Source-Code-authored Inputs, Outputs and Events can be valid in the active application.

---

## Gate 0 — Repository/static validation

Before giving a component YAML to the user, verify:

```text
[ ] source starts at a demonstrated PaYaml root (`ComponentDefinitions:`)
[ ] component identity is unique and consistent
[ ] every control family/version is demonstrated in the current repository or explicitly validated
[ ] public property declarations follow a known-good PULSE component pattern
[ ] Input metadata shape is compared with a working reference (PropertyKind / DisplayName / Description / DataType / Default)
[ ] Output/Event declarations follow a known-good declaration of the same kind
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

## Gate 1 — Component-definition acceptance

Use the complete candidate source, including its public contract when that contract follows a proven Source Code pattern.

```text
1. create/import/replace component source
2. save
3. wait for formula validation
4. review App Checker
```

Pass condition:

```text
COMPONENT_DEFINITION_ACCEPTED
```

If Studio rejects the definition or closes, stop and reduce the candidate.

---

## Gate 2 — Isolated instantiation smoke test

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

## Gate 3 — Public contract smoke test

Only after `INSTANCE_SAFE`, exercise the public contract in isolation:

```text
[ ] text inputs
[ ] Boolean inputs
[ ] number/color/table inputs where applicable
[ ] outputs
[ ] each event independently
[ ] multiple instances if required by the component contract
```

No consuming screen should reach into internal control names.

---

## Gate 4 — Visual QA

Validate with realistic content:

```text
[ ] no unintended scrollbar
[ ] no clipping
[ ] no overlap
[ ] no negative/off-canvas geometry in supported width range
[ ] hover/pressed/disabled states render correctly
[ ] PDS tokens are respected
```

---

## Gate 5 — Target-screen integration

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

When a component fails, compare it first with the closest **working component reference** rather than generalizing from one failed experiment.

Recommended reduction:

```text
A  component shell/root
B  primitive child controls
C  one public Input copied structurally from a working reference
D  binding to that Input
E  remaining property types incrementally
F  outputs/events
G  final hit surfaces/layout geometry
```

For each failing stage, inspect the delta against `cmp_HeatMapPro`, `cmp_SidebarNav` or another proven equivalent.

Manual creation of an equivalent property in Studio may be used as a comparator if a Source Code declaration fails, but that comparison does **not** prove that `CustomProperties:` is generally unsupported.

---

## Required evidence record

For every failed component gate record:

```text
Component
Canonical source SHA/commit
Known-good reference component
Studio/environment
Action being performed
Observed effect/error
Session ID if available
Property/control delta versus reference
Instance insertion status
App Checker status
Confirmed technical cause or UNKNOWN
Corrective change
Revalidation result
```

---

## Lifecycle mapping

```text
source created                              → REVIEW_REQUIRED
component definition accepted              → REVIEW_REQUIRED
INSTANCE_SAFE + contract + QA               → ACTIVE / PDS_CANDIDATE
FAIL_INSTANCE                               → REVIEW_REQUIRED + dependent block stopped
```

The component catalog must reflect this state.
