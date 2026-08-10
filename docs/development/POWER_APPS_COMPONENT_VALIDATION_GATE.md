# Power Apps Reusable Component Validation Gate

**Status:** normative  
**Canonical:** yes  
**Version:** 1.0  
**Last reviewed:** 2026-08-10

## Purpose

A reusable Canvas component must not be considered ready for screen integration merely because its `.pa.yaml` exists in Git or because the component definition can be created in Studio.

PULSE distinguishes three different facts:

```text
SOURCE_VALID
COMPONENT_DEFINITION_ACCEPTED
INSTANCE_SAFE
```

Only after all three, plus App Checker/visual QA, may the component be marked `READY_FOR_INTEGRATION`.

This gate was formalized after `cmp_PageHeaderPro` could exist as a component source but Power Apps Studio closed when an instance was inserted into `scr_Home_PDS`.

The Studio closure is a confirmed **effect**. Its technical root cause is not yet confirmed and must not be guessed.

---

## Gate 0 — Repository/static validation

Before asking the user to import/create the component, verify:

```text
[ ] source starts at a demonstrated PaYaml root (`ComponentDefinitions:`)
[ ] component identity is unique and consistent
[ ] every control family/version is demonstrated in the current repository or verified against current platform documentation
[ ] properties are compatible with the declared control versions
[ ] no protocol operation label is represented as an invalid PaYaml node
[ ] no unsupported property already recorded in compatibility registers is present
[ ] event definitions/invocations follow a proven component pattern
[ ] no hidden global variable is used as per-instance state unless explicitly audited
[ ] no component is nested inside a gallery when prohibited by current compatibility rules
[ ] sibling/parent formulas have no circular dependency
[ ] geometry formulas have a defined safe range
[ ] static ModernText follows the current AutoHeight/Wrap QA rule
[ ] canonical component source and validated construction artifact are synchronized
```

Static result values:

```text
PASS_STATIC
FAIL_STATIC
PASS_WITH_RUNTIME_RISK
```

Static review can never produce `READY_FOR_INTEGRATION` by itself.

---

## Gate 1 — Isolated component-definition validation

Use Power Apps Studio in an isolated authoring context before touching the target screen.

Recommended order:

```text
1. open a safe/sandbox copy or isolated test surface in the same Power Apps environment
2. create/import the reusable component from the complete canonical source
3. save
4. wait for formula validation
5. review App Checker
6. close/reopen Studio if useful to prove persistence
```

Pass condition:

```text
COMPONENT_DEFINITION_ACCEPTED
```

If Studio rejects the source or closes, stop. Do not continue to instance validation.

---

## Gate 2 — Isolated instantiation smoke test

A component definition can be accepted while an instance still triggers an authoring/runtime problem.

Therefore create a blank isolated test screen and insert exactly one instance with default properties only.

Do not bind project variables, collections, flows or navigation yet.

Validate:

```text
[ ] instance can be inserted without Studio closing
[ ] component renders at its default size
[ ] resize narrower/wider within intended range does not corrupt authoring
[ ] save succeeds
[ ] reopen succeeds
[ ] App Checker shows no new component-attributable error
```

Pass condition:

```text
INSTANCE_SAFE
```

A Studio crash/forced close during insertion is an automatic **FAIL_INSTANCE**.

---

## Gate 3 — Public contract smoke test

Only after `INSTANCE_SAFE`, exercise the public component contract in isolation:

```text
[ ] text inputs
[ ] Boolean visibility/enabled inputs
[ ] color/theme inputs
[ ] outputs, if any
[ ] each event independently
[ ] multiple instances if the component is intended to support them
```

No consuming screen should reach into internal control names.

---

## Gate 4 — Visual QA

Validate with realistic text/content:

```text
[ ] no unintended scrollbar
[ ] no clipping
[ ] no overlap
[ ] no negative/off-canvas geometry in supported width range
[ ] hover/pressed/disabled states render correctly
[ ] PDS tokens are respected
[ ] zoom/authoring view does not expose obvious layout corruption
```

For text controls, apply `docs/design-system/POWER_APPS_VISUAL_QA_GUARDRAILS.md`.

---

## Gate 5 — Target-screen integration

Only now may a feature block insert the component into a real target screen.

Integration block responsibilities:

```text
bind real inputs
bind events
bind context/navigation
validate the target screen
run App Checker
confirm no regression in fallback/current screen
```

A component that has not reached `INSTANCE_SAFE` must never be introduced into an active screen block.

---

## Failure isolation / binary reduction

When definition import succeeds but instance insertion crashes Studio, do not immediately rewrite the entire component.

Create controlled reduced candidates and add responsibilities incrementally:

```text
A. root container only
B. identity/text only
C. static context containers
D. actions without events
E. public events / transparent hit surfaces
F. full geometry and responsive formulas
```

The first stage that reproduces the crash identifies the smallest suspect surface.

Each reduced candidate is a diagnostic artifact, not canonical product source.

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
Definition import status
Instance insertion status
App Checker status
Smallest reproducing candidate
Confirmed cause or UNKNOWN
Corrective change
Revalidation result
```

Never convert correlation into a confirmed root cause without a reproducer.

---

## Lifecycle mapping

```text
source created                    → REVIEW_REQUIRED
PASS_STATIC                       → REVIEW_REQUIRED
COMPONENT_DEFINITION_ACCEPTED     → REVIEW_REQUIRED
INSTANCE_SAFE + contract + QA     → ACTIVE / PDS_CANDIDATE as appropriate
FAIL_INSTANCE                     → REVIEW_REQUIRED + dependent block stopped
```

The component catalog must reflect this state.
