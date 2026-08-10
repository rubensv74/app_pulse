# PULSE Active Source and Legacy Deletion Policy

**Status:** normative  
**Canonical:** yes  
**Version:** 1.1  
**Last reviewed:** 2026-08-10

## Active source rule

PULSE canonical technical source is organized by runtime:

```text
power-apps/      Canvas screens, components, Power Apps contracts/mappings/tests
power-automate/  active flow definitions and flow interface contracts
sql/             executable database source, schema snapshots and SQL tooling
office-scripts/  active Office Scripts source
```

The Git branch may be named `main`; the repository source folder must not also be called `main`.

## New reusable components

When current work requires a new reusable Canvas component:

1. create the component source under `power-apps/components/` in the same development cycle;
2. update `docs/design-system/COMPONENT_CATALOG.md` immediately;
3. for reusable PDS components, create or update the component specification under `docs/design-system/components/`;
4. if the component is being developed through incremental blocks, keep those construction artifacts under `docs/development/screens/<screen>/blocks/` until Studio validation;
5. before allowing a screen to depend on it, perform the component validation gate: static source review, compatibility review, isolated Studio creation/import validation, isolated instantiation validation, and App Checker/visual checks;
6. only after successful validation should the canonical complete component source under `power-apps/components/` be treated as ready for normal screen integration.

A component must never exist only in chat, a temporary download, a construction-block folder or a historical copy if it is part of current product work.

## Active Power Automate source

When a current Power Apps feature depends on a flow, the target repository state is:

```text
power-automate/flows/      real exported/deployable active flow definition
power-automate/contracts/  stable caller/response contract when useful
```

Rules:

- never invent a missing flow definition from `.Run(...)` calls;
- progressively capture the real flow from the Power Automate environment;
- the environment remains execution authority until the real definition is captured and validated;
- when the flow changes, its repository source/contract changes in the same development cycle;
- obsolete flow definitions are deleted from the working tree after migration and validation.

## Legacy definition

An artifact is `LEGACY` when it is superseded and is not required by current runtime, current contracts, current specifications, current validation evidence or current reusable knowledge.

Legacy files should be deleted from the working tree rather than retained indefinitely in active or archive folders. Git history provides historical recovery.

## Temporary legacy support

A component or file may remain `LEGACY_SUPPORTED` only when current runtime still depends on it.

Such an artifact:

- remains in the canonical source tree temporarily;
- is not a preferred reuse candidate;
- must identify its replacement target where known;
- is deleted only after the dependent runtime is migrated and validated in the real tool.

Current examples:

```text
cmp_DashboardSectionHeader   current scr_Home dependency
cmp_ExecutiveAlertBanner     current scr_Home dependency
cmp_DetailDrawer_old         current scr_Punches dependency
```

These are not authorization to keep equivalent legacy patterns after their dependencies disappear.

## Incremental architecture protection

Deletion or migration of a live dependency is a functional increment, not repository housekeeping.

Therefore it must follow the incremental protocol:

```text
audit dependency
→ define replacement
→ implement isolated increment
→ save in repository
→ validate in target runtime
→ update canonical source
→ remove legacy dependency
→ document reusable lesson if applicable
```

Repository cleanup must never silently break a validated screen.
