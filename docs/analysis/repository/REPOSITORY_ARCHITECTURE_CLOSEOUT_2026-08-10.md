# PULSE Repository Architecture Closeout — 2026-08-10

**Status:** closed  
**Date:** 2026-08-10  
**Scope:** repository structure, source authority, legacy policy and Power Automate source architecture

## Final canonical repository architecture

```text
/
├── README.md
├── power-apps/
│   ├── screens/
│   ├── components/
│   ├── contracts/
│   ├── mappings/
│   ├── tests/
│   └── CHANGELOG.md
├── power-automate/
│   ├── README.md
│   ├── FLOW_COVERAGE.md
│   ├── flows/
│   └── contracts/
├── sql/
│   ├── export/
│   ├── import/
│   ├── schema/
│   └── tools/
├── office-scripts/
└── docs/
    ├── README.md
    ├── governance/
    ├── architecture/
    ├── design-system/
    ├── specifications/
    ├── development/
    ├── reference/
    ├── analysis/
    └── guides/
```

There is deliberately no `main/` source directory. `main` is the Git branch.

## Closed architecture decisions

### Technology roots

PULSE source is organized by runtime boundary:

```text
power-apps
power-automate
sql
office-scripts
```

Documentation is separated under `docs/`.

### Active-source policy

The working tree contains current source, current contracts/specifications, current validation knowledge and temporary `LEGACY_SUPPORTED` dependencies only.

Superseded-only material is removed after safe migration. Git history is the historical archive.

### Component lifecycle

`power-apps/components/` is an active component source set, not a historical component library.

A newly required reusable component is created there in the same development cycle, registered in the component catalog and, when reusable/PDS, specified under `docs/design-system/components/`.

Repository presence alone does not prove a Canvas component is safe to consume. Component acceptance requires an isolated Studio validation gate before an active screen depends on it.

### Power Automate

Option A is approved: Power Automate is a first-class versioned source layer.

Real flow definitions will be captured progressively from the actual Power Automate environment. Missing definitions are recorded as coverage gaps; no flow internals are invented from Power Apps callers.

Initial observed active caller coverage is recorded in:

```text
power-automate/FLOW_COVERAGE.md
```

## Remaining work that is not an architecture decision

The following are ordinary incremental implementation/synchronization tasks and do not reopen repository architecture:

```text
- capture real active flow definitions into power-automate/flows/
- maintain flow contracts as real definitions are synchronized
- migrate remaining LEGACY_SUPPORTED Canvas dependencies when replacement work reaches them
- continue Home_PDS block construction and validation
- keep current compatibility/visual lessons synchronized with the reusable knowledge repository
```

## Current live legacy exceptions

The repository may still contain live legacy-named/source components where current canonical screens depend on them. They remain only until an explicit replacement increment is implemented and validated in Power Apps Studio.

The authoritative register is:

```text
docs/governance/NAMING_EXCEPTIONS.md
```

## Governance authority

Future changes follow:

```text
docs/governance/REPOSITORY_STRUCTURE_STANDARD.md
docs/governance/ACTIVE_SOURCE_POLICY.md
docs/development/PROTOCOLO_IMPLEMENTACION_INCREMENTAL_ASISTIDA.md
docs/development/PROTOCOLO_CONSTRUCCION_MODULAR_PANTALLAS_POWER_APPS.md
```

## Closeout conclusion

The repository architecture is sufficiently stable to resume feature development. Further structural changes should be treated as architecture gates only when they introduce a new runtime/source boundary, change canonical authority, or change the lifecycle policy.
