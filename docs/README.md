# PULSE Documentation Index

This file is the canonical entry point for repository documentation.

## Authority order

When several files appear to cover the same topic, use this order:

1. **Canonical runtime/source** — `power-apps/`, `sql/`, `office-scripts/`
2. **Governance / normative standards**
3. **Current architecture / Design System**
4. **Active specifications**
5. **Active development workspaces**
6. **Reference**
7. **Analysis / audit**

Legacy-only material is deleted from the working tree after safe migration; Git history provides historical recovery.

---

## Governance

- `governance/REPOSITORY_STRUCTURE_STANDARD.md` — canonical repository organization.
- `governance/ACTIVE_SOURCE_POLICY.md` — active-source and legacy deletion policy.
- `governance/NAMING_EXCEPTIONS.md` — temporary live naming/runtime exceptions.

## Design System

- `design-system/PULSE_DESIGN_SYSTEM.md` — canonical PULSE visual/interaction system.
- `design-system/SAAS_INTERFACE_ARCHETYPES.md` — SaaS interface archetype specification.
- `design-system/POWER_APPS_VISUAL_QA_GUARDRAILS.md` — visual QA rules learned from Studio validation.
- `design-system/COMPONENT_CATALOG.md` — lifecycle and reuse guidance for reusable components.
- `design-system/components/` — reusable PDS component specifications.

## Development method

- `development/PULSE_UI_DELIVERY_FRAMEWORK.md`
- `development/PROTOCOLO_IMPLEMENTACION_INCREMENTAL_ASISTIDA.md`
- `development/PROTOCOLO_CONSTRUCCION_MODULAR_PANTALLAS_POWER_APPS.md`
- `development/PLANTILLA_ENCARGO_NUEVA_INTERFAZ_SAAS_POWER_APPS.md`

## Active screen workspaces

### Home_PDS

Canonical stable Home source:

```text
../power-apps/screens/Home/scr_Home.pa.yaml
```

Construction workspace:

```text
development/screens/home-pds/
```

### Punch Review

Canonical runtime source:

```text
../power-apps/screens/PunchReview/scr_PunchReview.pa.yaml
```

Construction workspace:

```text
development/screens/punch-review/
```

## Specifications

- `specifications/PULSE_EXECUTIVE_DASHBOARD_FDS_v1.0.md`
- `specifications/home-pds/`

## Architecture

- `architecture/integrations/excel-import/EXCEL_IMPORT_ARCHITECTURE.md`

## Analysis

Analysis documents are point-in-time evidence, not implementation authority.

- `analysis/punch-review-workspace/`
- `analysis/repository/REPOSITORY_AUDIT_2026-08-10.md`
- `analysis/repository/COMPONENT_USAGE_AUDIT_2026-08-10.md`

## SQL reference

```text
../sql/export/
../sql/import/
../sql/schema/warroom/
../sql/tools/warroom-schema/
reference/sql/warroom/
```

## Guides

`guides/` contains only current reusable step-by-step guidance. Superseded compatibility redirects are not retained once references have been migrated.

---

## Active component creation rule

When current work requires a new reusable Power Apps component:

1. create its canonical `.pa.yaml` source under `../power-apps/components/`;
2. update `design-system/COMPONENT_CATALOG.md` in the same development cycle;
3. for reusable PDS components, create/update a specification under `design-system/components/`;
4. separately validate that the component is installed/accepted by Power Apps Studio.

A required component must not exist only in chat, a construction block or a temporary file.
