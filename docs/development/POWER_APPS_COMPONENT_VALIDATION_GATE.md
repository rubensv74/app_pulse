# Power Apps Reusable Component Validation Gate

**Status:** normative  
**Canonical:** yes  
**Version:** 1.3  
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

`DEFINITION_ACCEPTED` never implies `INSTANCE_SAFE`.

`CustomProperties:` is allowed in canonical Source Code when its structure follows patterns already demonstrated by instance-safe PULSE components. `cmp_HeatMapPro` and `cmp_SidebarNav` prove that Source-Code-authored Inputs, Outputs, Tables and Events can be valid in the active application.

---

## Gate 0 — Repository/static validation

Before giving a component YAML to the user, verify:

```text
[ ] source starts at a demonstrated PaYaml root (`ComponentDefinitions:`)
[ ] component identity is unique and consistent
[ ] every control family/version is demonstrated in the current repository or explicitly validated
[ ] closest INSTANCE_SAFE PULSE reference component has been identified
[ ] public property declarations are compared structurally with that reference
[ ] Input metadata shape is checked field by field (PropertyKind / DisplayName / Description / DataType / Default)
[ ] Output/Event declarations follow a known-good declaration of the same kind
[ ] body formulas and control patterns are compared with positive references where possible
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

If Studio rejects the definition or closes, stop before screen integration.

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

## Failure strategy — positive reference first

When a full component reaches `FAIL_INSTANCE`, **do not begin with a property-by-property microtest chain** while a comparable PULSE component already works.

Mandatory order:

```text
PROBLEM COMPONENT
        ↓
find closest PULSE INSTANCE_SAFE component(s)
        ↓
full structural diff
        ↓
identify objective deltas
        ↓
correct COMPLETE component using known-good patterns
        ↓
ONE isolated smoke test
        ↓
PASS → continue development
FAIL → controlled reduction
```

### Full structural diff must cover

Public contract:

```text
Inputs:  PropertyKind / DisplayName / Description / DataType / Default
Outputs: PropertyKind / DataType and proven metadata variant
Events:  PropertyKind / ReturnType / Default and proven metadata variant
```

Component body:

```text
component-property bindings
calculated outputs
OnReset / Set(...)
Gallery Items / Table schemas
ThisItem / Selected
LookUp / AddColumns / SortByColumns
Event invocation
transparent hit surfaces
control families and versions
unsupported properties
parent/sibling geometry dependencies
```

### Positive-counterexample rule

Before promoting a theory such as:

```text
CustomProperties are incompatible
Events are incompatible
ModernText is incompatible
Gallery inside this component is incompatible
```

search the current PULSE component set for an `INSTANCE_SAFE` component already using the same construction.

If such a component exists, the construction cannot be declared generally incompatible. Investigate the delta between the working and failing components.

### When reduction is allowed

Reduction begins only if the corrected complete component still fails, or if no sufficiently comparable positive reference exists.

Reduction must follow the differential found against the working reference rather than an arbitrary academic sequence.

Example:

```text
working reference
vs
problem component
      ↓
remaining structural delta
      ↓
remove/replace ONE delta
      ↓
smoke test
```

Manual creation of an equivalent property in Studio may be used as a comparator when necessary, but it must not be generalized beyond the specific evidence obtained.

---

## Efficiency rule

Runtime checks requested from the user must have a clear decision consequence.

Do not ask for repeated microtests if repository comparison can eliminate or correct the suspected delta first.

Preferred diagnostic outcome:

```text
1 comparative audit
1 corrected full candidate
1 smoke test
```

Only expand the test sequence after that smoke test fails.

---

## Required evidence record

For every failed component gate record:

```text
Component
Canonical source SHA/commit
Known-good reference component(s)
Studio/environment
Action being performed
Observed effect/error
Session ID if available
Full structural delta versus reference
Corrective full-component change
Instance insertion status
App Checker status
Confirmed technical cause or UNKNOWN
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
