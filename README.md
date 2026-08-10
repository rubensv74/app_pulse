# PULSE

PULSE is an enterprise operational Power Apps solution supported by Power Automate, SQL Server/Azure SQL and Office Scripts.

This README is the canonical entry point for the repository.

## Repository map

```text
/
├── main/            Canonical active Power Apps source, components, contracts, mappings and tests
├── sql/             Executable SQL, schema snapshots and SQL tooling
├── office-scripts/  Canonical Office Scripts source
└── docs/            Governance, architecture, Design System, specifications, development, reference and archive
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

PULSE uses an **active component pool**: this directory contains current runtime dependencies plus components actively planned/created for current product/PDS work. Historical inactive components are kept out of the active pool.

Lifecycle/reuse guidance:

```text
docs/design-system/COMPONENT_CATALOG.md
```

When current work needs a new reusable component, create its canonical `.pa.yaml` source under `main/components/` in the same development cycle, update the component catalog, and create/update a PDS component specification when applicable.

Historical inactive component source is retained, when useful, under:

```text
docs/archive/components/
```

and must not be selected as a normal reuse candidate.

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
3. `main/components/` is the active reusable component source set.
4. A component existing in GitHub does not by itself prove it is installed in the active Power Apps app; Studio validation is separate.
5. Construction blocks do not replace canonical full screen/component source.
6. Archived or superseded documents/components must not be used as current implementation authority.
7. Repository cleanup must not mix structural migration with unrelated runtime behavior changes.

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
- Punch Review construction workspace moved out of `main/`;
- SQL schema, extraction tooling and SQL reference documentation consolidated;
- sprint/remediation/roadmap material classified and archived/reference-separated;
- component usage audit completed;
- active component policy Option A adopted;
- inactive `cmp_ExecutiveKpiCard` and `cmp_ExecutiveInsightCard` moved to `docs/archive/components/`.

Final cleanup work is limited to safe naming review and stale-link / AI-retrieval QA. Runtime component identities that are still live are not renamed cosmetically.
