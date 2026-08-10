# PULSE

PULSE is an enterprise operational Power Apps solution supported by Power Automate, Azure SQL/SQL Server and Office Scripts.

This README is the canonical entry point for the repository.

## Canonical repository map

```text
/
├── README.md
├── power-apps/      Canonical Canvas app source, reusable components, contracts, mappings and tests
├── sql/             Executable SQL, schema snapshots and SQL tooling
├── office-scripts/  Canonical Office Scripts source
└── docs/            Governance, architecture, Design System, specifications, development and reference
```

The repository deliberately has **no `main/` source folder**. `main` is the Git branch; Power Apps source belongs under `power-apps/`.

Repository authority and lifecycle rules are defined in:

```text
docs/governance/REPOSITORY_STRUCTURE_STANDARD.md
docs/governance/ACTIVE_SOURCE_POLICY.md
```

---

## Power Apps source of truth

### Screens

```text
power-apps/screens/
```

Current canonical screen sources include:

```text
power-apps/screens/Home/scr_Home.pa.yaml
power-apps/screens/PunchReview/scr_PunchReview.pa.yaml
power-apps/screens/Punches/scr_Punches_1.pa.yaml
```

### Components

```text
power-apps/components/
```

This is an **active source pool**, not a historical library. It contains current runtime dependencies plus components required by approved active work.

Lifecycle/reuse guidance:

```text
docs/design-system/COMPONENT_CATALOG.md
```

When a new reusable component is required, its canonical source is created under `power-apps/components/` in the same development cycle, the component catalog is updated, and reusable PDS components receive a specification under `docs/design-system/components/`.

### Contracts, mappings and tests

```text
power-apps/contracts/
power-apps/mappings/
power-apps/tests/
```

---

## SQL

```text
sql/
├── export/
├── import/
├── schema/warroom/
└── tools/warroom-schema/
```

SQL reference documentation lives under:

```text
docs/reference/sql/warroom/
```

---

## Documentation

Start with:

```text
docs/README.md
```

Key normative documents:

```text
docs/governance/REPOSITORY_STRUCTURE_STANDARD.md
docs/governance/ACTIVE_SOURCE_POLICY.md
docs/governance/NAMING_EXCEPTIONS.md
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

Stable runtime reference:

```text
power-apps/screens/Home/scr_Home.pa.yaml
```

Parallel incremental construction workspace:

```text
docs/development/screens/home-pds/
```

Target archetype: **Operational Control Tower** with **Data Explorer** as a secondary pattern.

### Punch Review Workspace

Canonical runtime source:

```text
power-apps/screens/PunchReview/scr_PunchReview.pa.yaml
```

Incremental construction workspace:

```text
docs/development/screens/punch-review/
```

Construction blocks are not canonical full-screen/component source until validated and consolidated.

---

## Legacy policy

Legacy-only files are removed from the working tree once they are no longer required by current runtime, current specifications/contracts or reusable learned knowledge. Git history preserves historical recovery.

A live dependency may remain temporarily as `LEGACY_SUPPORTED`; removing it requires an explicit incremental migration and validation in the target tool.

Current naming/runtime exceptions are documented in:

```text
docs/governance/NAMING_EXCEPTIONS.md
```

---

## Incremental delivery rule

PULSE development follows:

> **Analyse → design → divide → implement one piece → save → validate → correct → document → continue.**

Every project artifact that forms part of the solution must end in its canonical repository location. Chat output or a temporary download is never the final source of truth.
