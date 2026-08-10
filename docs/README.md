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

- `governance/REPOSITORY_STRUCTURE_STANDARD.md` — canonical repository organization rules.

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

- `development/screens/home-pds/README.md`
- `development/screens/home-pds/SCREEN_ARCHITECTURE.md`
- `development/screens/home-pds/POWER_APPS_SOURCE_CODE_COMPATIBILITY.md`
- `development/screens/home-pds/blocks/`

### Punch Review

Current canonical screen source:

- `../main/screens/PunchReview/scr_PunchReview.pa.yaml`

Construction workspace currently remains under `../main/punch-review/` and is scheduled for migration to `development/screens/punch-review/` by the repository cleanup plan.

## Specifications

- `specifications/PULSE_EXECUTIVE_DASHBOARD_FDS_v1.0.md`
- `specifications/home-pds/`

## Analysis

- `analysis/punch-review-workspace/`
- `analysis/repository/REPOSITORY_AUDIT_2026-08-10.md`

## SQL reference

Current documentation is temporarily split between:

- `SQL/`
- `../sql/schema_warroom/`
- `../database/warroom/tools/`

This is a known repository issue. The canonical target is documented in `governance/REPOSITORY_STRUCTURE_STANDARD.md` and the repository audit.

## Guides

`guides/` currently contains both genuine guides and historical material. Until migration is completed, prefer current normative/specification documents when overlap exists.

`guides/DESIGN_SYSTEM.md` is retained only as a compatibility redirect and is explicitly superseded by `design-system/PULSE_DESIGN_SYSTEM.md`.

## Archive

Historical deliveries are now stored under:

- `archive/deliveries/`

Archived content is retained for traceability and must not be treated as current implementation authority.

---

## Structural cleanup status

Repository cleanup is being executed incrementally to avoid breaking Power Apps, SQL and documentation references.

Completed in Phase 0 / initial cleanup:

- root README created;
- documentation index created;
- repository structure standard published;
- repository audit published;
- stale EPIC-01 delivery files removed from root and archived;
- old `guides/DESIGN_SYSTEM.md` converted to a superseded compatibility stub;
- component lifecycle catalog created.

Pending controlled migrations:

- Punch Review construction workspace → `development/screens/punch-review/`;
- SQL consolidation;
- remaining guide/sprint/archive cleanup;
- component usage audit before physical legacy moves;
- final stale-link search and retrieval QA.
