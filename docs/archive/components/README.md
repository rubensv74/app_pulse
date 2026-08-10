# Archived PULSE Components

**Status:** archived  
**Canonical:** no  
**Last reviewed:** 2026-08-10

This directory retains historical Canvas component source that is no longer used by current canonical screens and is not part of active planned/PDS work.

Archived components are preserved for traceability only. They are not normal reuse candidates and must not be reintroduced into `main/components/` without a new explicit need, a dependency/design review and an update to `docs/design-system/COMPONENT_CATALOG.md`.

## Current archived components

- `cmp_ExecutiveKpiCard.pa.yaml`
- `cmp_ExecutiveInsightCard.pa.yaml`

Both were moved from `main/components/` after the 2026-08-10 canonical-screen usage audit found no active screen references.

## Active component policy

`main/components/` is reserved for:

1. components required by current runtime screens;
2. components actively planned for approved work;
3. components being created or evolved for PDS/current product development.

When a new reusable component is required, its canonical source must be created in `main/components/` in the same development cycle in which it is introduced. Its lifecycle/reuse guidance must also be added to `docs/design-system/COMPONENT_CATALOG.md`, and a reusable PDS component should additionally receive a specification under `docs/design-system/components/`.
