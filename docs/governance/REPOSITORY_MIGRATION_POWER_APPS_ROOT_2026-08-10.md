# PULSE Repository Migration — `main/` → `power-apps/`

**Status:** approved / in execution  
**Date:** 2026-08-10  
**Architecture decision:** replace the ambiguous repository folder `main/` with `power-apps/`.

## Decision

The branch may be named `main`, but the repository source folder must describe its technology/domain rather than repeat the branch name.

Target structure:

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
├── sql/
├── office-scripts/
└── docs/
```

## Incremental-architecture rules applied

This migration follows `docs/development/PROTOCOLO_IMPLEMENTACION_INCREMENTAL_ASISTIDA.md`:

- repository is the source of truth;
- structural migration is isolated from runtime behavior changes;
- canonical runtime content is moved without modifying its contents;
- references are repaired after the move;
- obsolete/legacy material is deleted when Git history already provides traceability;
- live legacy dependencies are not deleted until a validated migration removes the dependency;
- new reusable Power Apps components are created directly under `power-apps/components/` and catalogued in the same development cycle.

## Legacy deletion policy

Delete from the working tree when all are true:

1. it is not a current runtime dependency;
2. it is not a current normative specification/contract;
3. it is superseded or historical only;
4. its historical content remains recoverable from Git history;
5. deletion does not remove a reusable learned rule that belongs in current knowledge/compatibility documentation.

Live legacy dependencies remain temporarily in `power-apps/components/` with explicit `LEGACY_SUPPORTED` status until migrated.

## Protected current source

The following source families must be preserved through the move:

```text
screens/
components/ used by current runtime or active PDS work
contracts/
mappings/
tests/
CHANGELOG.md
```

## Post-migration checks

- `main/` folder no longer exists;
- `power-apps/` exists with the complete former source tree;
- repository docs reference `power-apps/...` rather than `main/...`;
- obsolete compatibility redirects and archived legacy component copies are removed where safe;
- canonical Home, Punches and Punch Review source remain byte-equivalent apart from path relocation;
- Home_PDS incremental workspace remains under `docs/development/screens/home-pds/`;
- Punch Review incremental workspace remains under `docs/development/screens/punch-review/`.
