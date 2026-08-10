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
- `governance/REPOSITORY_REORGANIZATION_TRACKER.md` — current structural-cleanup tracker.

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

Canonical runtime source:

- `../main/screens/PunchReview/scr_PunchReview.pa.yaml`

Active construction workspace:

- `development/screens/punch-review/README.md`
- `development/screens/punch-review/POWER_APPS_SOURCE_CODE_COMPATIBILITY.md`
- `development/screens/punch-review/blocks/`
- `development/screens/punch-review/user-guide/`

## Specifications

- `specifications/PULSE_EXECUTIVE_DASHBOARD_FDS_v1.0.md`
- `specifications/home-pds/`

## Analysis

- `analysis/punch-review-workspace/`
- `analysis/repository/REPOSITORY_AUDIT_2026-08-10.md`

## SQL reference

Canonical SQL reference documentation:

```text
reference/sql/warroom/
```

Canonical executable/schema/tooling locations are outside `docs/`:

```text
../sql/export/
../sql/import/
../sql/schema/warroom/
../sql/tools/warroom-schema/
```

## Guides

`guides/` is reserved for genuinely reusable step-by-step guidance. Some historical sprint/remediation/roadmap material still requires classification and is tracked in the reorganization plan.

`guides/DESIGN_SYSTEM.md` is retained only as a compatibility redirect and is explicitly superseded by `design-system/PULSE_DESIGN_SYSTEM.md`.

## Archive

Historical deliveries are stored under:

- `archive/deliveries/`

Archived content is retained for traceability and must not be treated as current implementation authority.

---

## Structural cleanup status

Completed:

- root README and documentation index;
- repository structure standard and audit;
- stale EPIC-01 delivery files removed from root and archived;
- old Design System conflict resolved;
- component lifecycle catalog created;
- Punch Review construction workspace moved to `development/screens/punch-review/`;
- SQL assets consolidated into canonical `sql/` and `reference/sql/` locations.

Pending:

- classify remaining guide/sprint/remediation/roadmap documents;
- component usage audit before physical legacy cleanup;
- safe naming normalization;
- final stale-link search and AI-retrieval QA.
