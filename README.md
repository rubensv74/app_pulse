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

Component lifecycle classification is being formalized. Do not automatically select files named `_old` or older `Executive*` components as preferred implementation patterns.

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

## Known cleanup items

The audit has identified these structural issues for migration:

- stale root delivery manifests/reports;
- legacy `docs/guides/DESIGN_SYSTEM.md` overlapping the current PDS;
- Punch Review construction artifacts stored under `main/`;
- SQL assets split across `database/`, `sql/` and `docs/SQL/`;
- active and legacy components mixed in one flat component directory;
- inconsistent naming and document lifecycle metadata.

See the repository audit for the phased migration plan.
