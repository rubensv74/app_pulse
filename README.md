# PULSE

PULSE is an enterprise operational Power Apps solution supported by Power Automate, SQL Server/Azure SQL and Office Scripts.

This README is the canonical entry point for the repository.

## Repository map

```text
/
├── main/            Power Apps source, reusable components, contracts and mappings
├── sql/             Executable SQL, import/export SQL and schema snapshots
├── office-scripts/  Office Scripts source
└── docs/            Architecture, Design System, specifications, development workspaces and analysis
```

The repository is currently being reorganized incrementally. Do not infer authority from folder age or file modification date; use the rules below.

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
```

The current repository still contains related tooling under `database/warroom/tools/`; this is scheduled for consolidation into `sql/tools/`.

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

PULSE is building a parallel replacement of the current Home screen rather than modifying the stable screen destructively.

```text
Stable screen:
main/screens/Home/scr_Home.pa.yaml

Construction workspace:
docs/development/screens/home-pds/
```

Target archetype: **Operational Control Tower** with **Data Explorer** as the secondary pattern.

### Punch Review Workspace

Canonical runtime source:

```text
main/screens/PunchReview/scr_PunchReview.pa.yaml
```

Historical/incremental construction blocks currently remain under `main/punch-review/` and are scheduled to move into the documentation development workspace during repository cleanup.

---

## Repository organization rules

Canonical structure standard:

```text
docs/governance/REPOSITORY_STRUCTURE_STANDARD.md
```

Current audit:

```text
docs/analysis/repository/REPOSITORY_AUDIT_2026-08-10.md
```

Important authority rules:

1. Runtime source beats historical delivery documentation.
2. `docs/design-system/PULSE_DESIGN_SYSTEM.md` is the canonical PDS source.
3. Construction blocks do not replace canonical full screen/component source.
4. Archived or superseded documents must not be used as current implementation authority.
5. Repository cleanup is performed in controlled batches without mixing structural migration and runtime behavior changes.

---

## Cleanup status

Completed:

- canonical root README;
- canonical docs index;
- repository structure standard;
- repository audit;
- stale EPIC-01 delivery report/manifests removed from root and archived under `docs/archive/deliveries/`;
- legacy `docs/guides/DESIGN_SYSTEM.md` converted to a superseded compatibility stub;
- component lifecycle catalog created.

Pending controlled migrations:

- Punch Review construction artifacts currently stored under `main/`;
- SQL assets split across `database/`, `sql/` and `docs/SQL/`;
- remaining sprint/remediation/roadmap documents mixed under `docs/guides/`;
- physical separation of confirmed legacy components after usage audit;
- stale-link and retrieval QA after moves.

See the repository audit for the phased migration plan.
