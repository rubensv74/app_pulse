# PULSE Documentation Index

This file is the canonical entry point for repository documentation.

## Authority order

Use documentation in this order when multiple files appear to cover the same topic:

1. **Governance / normative standards**
2. **Current architecture / Design System**
3. **Active specifications**
4. **Active development workspaces**
5. **Reference**
6. **Analysis / audit**
7. **Archive**

Do not treat a recently modified historical document as authoritative merely because it is newer on disk.

---

## Governance

- `governance/REPOSITORY_STRUCTURE_STANDARD.md` — canonical repository organization and active-component policy.
- `governance/REPOSITORY_REORGANIZATION_TRACKER.md` — controlled cleanup status.

## Design System

- `design-system/PULSE_DESIGN_SYSTEM.md` — canonical PULSE visual/interaction system.
- `design-system/SAAS_INTERFACE_ARCHETYPES.md` — SaaS interface archetype specification.
- `design-system/POWER_APPS_VISUAL_QA_GUARDRAILS.md` — visual QA rules learned from Studio validation.
- `design-system/COMPONENT_CATALOG.md` — lifecycle and reuse guidance for active reusable components.
- `design-system/components/` — reusable PDS component specifications.

## Development method

- `development/PULSE_UI_DELIVERY_FRAMEWORK.md`
- `development/PROTOCOLO_IMPLEMENTACION_INCREMENTAL_ASISTIDA.md`
- `development/PROTOCOLO_CONSTRUCCION_MODULAR_PANTALLAS_POWER_APPS.md`
- `development/PLANTILLA_ENCARGO_NUEVA_INTERFAZ_SAAS_POWER_APPS.md`

## Active screen workspaces

### Home_PDS

- `development/screens/home-pds/README.md`
- `development/screens/home-pds/SCREEN_ARCHITECTURE.md`
- `development/screens/home-pds/POWER_APPS_SOURCE_CODE_COMPATIBILITY.md`
- `development/screens/home-pds/blocks/`

### Punch Review

Current canonical screen source:

- `../main/screens/PunchReview/scr_PunchReview.pa.yaml`

Construction workspace:

- `development/screens/punch-review/README.md`
- `development/screens/punch-review/POWER_APPS_SOURCE_CODE_COMPATIBILITY.md`
- `development/screens/punch-review/blocks/`
- `development/screens/punch-review/user-guide/`

## Specifications

- `specifications/PULSE_EXECUTIVE_DASHBOARD_FDS_v1.0.md`
- `specifications/home-pds/`

## Architecture

- `architecture/integrations/excel-import/EXCEL_IMPORT_ARCHITECTURE.md`

## Analysis

- `analysis/punch-review-workspace/`
- `analysis/repository/REPOSITORY_AUDIT_2026-08-10.md`
- `analysis/repository/COMPONENT_USAGE_AUDIT_2026-08-10.md`

## SQL reference

Canonical SQL technical source and reference are now separated:

```text
../sql/export/
../sql/import/
../sql/schema/warroom/
../sql/tools/warroom-schema/
reference/sql/warroom/
```

## Guides

`guides/` is reserved for genuine reusable step-by-step guidance or explicit compatibility redirects.

`guides/DESIGN_SYSTEM.md` is retained only as a compatibility redirect and is explicitly superseded by `design-system/PULSE_DESIGN_SYSTEM.md`.

## Archive

Archived content is retained for traceability and must not be treated as current implementation authority.

Key areas:

```text
archive/deliveries/
archive/sprints/
archive/remediation/
archive/roadmaps/
archive/superseded-docs/
archive/components/
```

Archived component source under `archive/components/` is not a normal reuse candidate. Current reusable component source belongs under `../main/components/`.

---

## Active component creation rule

When current work requires a new reusable Power Apps component:

1. create its canonical `.pa.yaml` source under `../main/components/`;
2. update `design-system/COMPONENT_CATALOG.md` in the same development cycle;
3. for reusable PDS components, create/update a specification under `design-system/components/`;
4. separately validate that the component is actually installed/accepted by Power Apps Studio.

This prevents required components from existing only in chat, blocks or temporary locations.
