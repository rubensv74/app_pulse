# PULSE

PULSE is an enterprise operational Power Apps solution supported by Power Automate, SQL Server/Azure SQL and Office Scripts.

This README is the canonical entry point for the repository.

## Repository map

```text
/
├── main/            Canonical Power Apps source, components, contracts, mappings and tests
├── sql/             Executable SQL, schema snapshots and SQL tooling
├── office-scripts/  Canonical Office Scripts source
└── docs/            Governance, architecture, Design System, specifications, development and reference
```

Repository authority is defined in `docs/governance/REPOSITORY_STRUCTURE_STANDARD.md`.

---

## Current source of truth

### Power Apps screens

```text
main/screens/
```

Current tracked screen sources include:

- `main/screens/Home/scr_Home.pa.yaml`
- `main/screens/PunchReview/scr_PunchReview.pa.yaml`
- `main/screens/Punches/scr_Punches_1.pa.yaml`

### Reusable components

```text
main/components/
```

Lifecycle/reuse guidance:

```text
docs/design-system/COMPONENT_CATALOG.md
```

Do not automatically select files named `_old` or older `Executive*` components as preferred implementation patterns.

### SQL

```text
sql/
├── export/
├── import/
├── schema/warroom/
└── tools/warroom-schema/
```

Stored-procedure reference documentation is under:

```text
docs/reference/sql/warroom/
```

### Office Scripts

```text
office-scripts/
```

---

## Documentation

Start here:

```text
docs/README.md
```

Key normative documents:

```text
docs/governance/REPOSITORY_STRUCTURE_STANDARD.md
docs/design-system/PULSE_DESIGN_SYSTEM.md
docs/design-system/SAAS_INTERFACE_ARCHETYPES.md
docs/design-system/POWER_APPS_VISUAL_QA_GUARDRAILS.md
docs/design-system/COMPONENT_CATALOG.md
docs/development/PULSE_UI_DELIVERY_FRAMEWORK.md
docs/development/PROTOCOLO_IMPLEMENTACION_INCREMENTAL_ASISTIDA.md
docs/development/PROTOCOLO_CONSTRUCCION_MODULAR_PANTALLAS_POWER_APPS.md
```

---

## Active UI modernization

### Home_PDS

Stable runtime screen:

```text
main/screens/Home/scr_Home.pa.yaml
```

Parallel construction workspace:

```text
docs/development/screens/home-pds/
```

Target archetype: **Operational Control Tower** with **Data Explorer** as the secondary pattern.

### Punch Review Workspace

Canonical runtime source:

```text
main/screens/PunchReview/scr_PunchReview.pa.yaml
```

Incremental construction workspace:

```text
docs/development/screens/punch-review/
```

Construction blocks are not canonical full-screen source.

---

## Repository organization rules

Important authority rules:

1. Runtime source beats historical delivery documentation.
2. `docs/design-system/PULSE_DESIGN_SYSTEM.md` is the canonical PDS source.
3. Construction blocks do not replace canonical full screen/component source.
4. Archived or superseded documents must not be used as current implementation authority.
5. Repository cleanup is performed in controlled batches without mixing structural migration and runtime behavior changes.

Current audit:

```text
docs/analysis/repository/REPOSITORY_AUDIT_2026-08-10.md
```

Current cleanup tracker:

```text
docs/governance/REPOSITORY_REORGANIZATION_TRACKER.md
```

---

## Cleanup status

Completed:

- canonical root README and documentation index;
- repository structure standard and audit;
- stale EPIC-01 delivery artifacts archived;
- legacy Design System conflict resolved;
- component lifecycle catalog created;
- Punch Review construction workspace moved out of `main/`;
- SQL schema, extraction tooling and SQL reference documentation consolidated under canonical locations.

Pending controlled cleanup:

- classify remaining sprint/remediation/roadmap material under `docs/guides/`;
- complete component usage audit before any physical legacy-component move;
- normalize safe filenames/folders where useful;
- final stale-link and AI-retrieval QA.
