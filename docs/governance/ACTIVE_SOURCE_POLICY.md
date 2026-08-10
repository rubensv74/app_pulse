# PULSE Active Source and Legacy Deletion Policy

**Status:** normative  
**Canonical:** yes  
**Last reviewed:** 2026-08-10

## Active source rule

Canonical Power Apps source lives under:

```text
power-apps/
├── screens/
├── components/
├── contracts/
├── mappings/
├── tests/
└── CHANGELOG.md
```

The Git branch may be named `main`; the repository source folder must not also be called `main`.

## New reusable components

When current work requires a new reusable Canvas component:

1. create the component source under `power-apps/components/` in the same development cycle;
2. update `docs/design-system/COMPONENT_CATALOG.md` immediately;
3. for reusable PDS components, create or update the component specification under `docs/design-system/components/`;
4. if the component is being developed through incremental blocks, keep those construction artifacts under `docs/development/screens/<screen>/blocks/` until Studio validation;
5. after validation, ensure the canonical complete component source under `power-apps/components/` matches the accepted implementation.

A component must never exist only in chat, a temporary download, a construction-block folder or an archive if it is part of current product work.

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

Examples at the time this policy was adopted:

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
→ validate in Power Apps Studio / target runtime
→ update canonical source
→ remove legacy dependency
→ document reusable lesson if applicable
```

Repository cleanup must never silently break a validated screen.
