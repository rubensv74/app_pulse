# PULSE Component Catalog

**Status:** active  
**Canonical:** yes  
**Purpose:** lifecycle and reuse guidance for `power-apps/components/`  
**Last reviewed:** 2026-08-11  
**Usage audit:** `docs/analysis/repository/COMPONENT_USAGE_AUDIT_2026-08-10.md`

## Canonical active-component policy

```text
power-apps/components =
current runtime dependencies
+ active approved components
+ components created/evolved for current PDS/product work
```

Historical inactive component source is not retained in the working tree merely for possible future reuse; Git history provides recovery.

When a new reusable component is needed, its canonical `.pa.yaml` source must be created under `power-apps/components/` in the same development cycle. This catalog must be updated immediately. Reusable PDS components also receive/update a specification under `docs/design-system/components/`.

A required component must never exist only in chat, a construction block, temporary download or obsolete path.

## Lifecycle states

```text
ACTIVE            preferred current reuse candidate; instance-safe validation completed
PDS_CANDIDATE     active PDS-aligned component accepted for current PDS integration; target-screen QA remains part of its consuming block
REVIEW_REQUIRED   source exists but compatibility/definition/instance-safety validation is incomplete or has failed
LEGACY_SUPPORTED  live runtime dependency awaiting validated migration; do not select for new work
```

| Component | Lifecycle | Current canonical usage / reuse guidance |
|---|---|---|
| `cmp_ActionToolbarPro` | PDS_CANDIDATE | Preferred action-toolbar base; screen owns action semantics |
| `cmp_CustomFieldEditor` | ACTIVE | Domain component for custom-field editing |
| `cmp_DataTableProV2` | PDS_CANDIDATE | Preferred Data Explorer/table component |
| `cmp_DonutPro` | ACTIVE | Session progress/completion/capacity-style circular metrics; not Home_PDS discipline composition |
| `cmp_EmptyState` | PDS_CANDIDATE | Preferred empty/error state base; continue visual hardening |
| `cmp_HeatMapPro` | PDS_CANDIDATE | Preferred heatmap component |
| `cmp_KpiCardPro` | PDS_CANDIDATE | Preferred KPI card for new PDS work |
| `cmp_OperationalSkylinePro` | REVIEW_REQUIRED | Universal operational timeline/skyline for Punches, Tasks, milestones, readiness and capacity. Canonical source and PDS specification exist; Studio definition, isolated instance, public-contract and visual QA remain mandatory before screen integration. Spec: `docs/design-system/components/CMP_OPERATIONAL_SKYLINE_PRO.md` |
| `cmp_PageHeaderPro` | PDS_CANDIDATE | Corrected complete Source Code passes isolated instantiation and has been accepted for progression into Home_PDS Block 03. Target-screen contract/visual QA remains mandatory during integration. Spec: `docs/design-system/components/CMP_PAGE_HEADER_PRO.md` |
| `cmp_PieChartPro` | PDS_CANDIDATE | Preferred composition chart for Home_PDS discipline distribution |
| `cmp_SidebarNav` | ACTIVE | Current shared navigation component |
| `cmp_SkeletonLoader` | PDS_CANDIDATE | Preferred loading placeholder base |
| `cmp_DashboardSectionHeader` | LEGACY_SUPPORTED | Used by current `scr_Home`; target replacement is the PDS panel/header pattern |
| `cmp_ExecutiveAlertBanner` | LEGACY_SUPPORTED | Used by current `scr_Home`; remove after Home_PDS cutover/stabilization if no other dependency remains |
| `cmp_DetailDrawer_old` | LEGACY_SUPPORTED | Used by current `scr_Punches` as `comp_DetailDrawer_6`; replace through an explicit Punches migration before removal |

## Rules

1. New work should normally prefer `ACTIVE` or a `PDS_CANDIDATE` whose relevant validation gate has passed for the intended use.
2. `REVIEW_REQUIRED` blocks normal screen integration until `docs/development/POWER_APPS_COMPONENT_VALIDATION_GATE.md` is satisfied.
3. `LEGACY_SUPPORTED` means “currently required but scheduled for removal after a validated migration”, not “approved for reuse”.
4. Before removing a component, audit references from canonical screens/components.
5. When a new reusable component is required, create its canonical source under `power-apps/components/` and update this catalog in the same development cycle.
6. Reusable PDS component specifications belong under `docs/design-system/components/`.
7. A suffix such as `_old` is not lifecycle authority; this catalog is.
8. GitHub source existence does not prove the component is installed or safe to instantiate in the active Power Apps application; Studio validation is separate.
9. Target-screen integration remains its own validation surface even after isolated instance safety passes.
10. Once a component has no current dependency or approved active use, remove it from the working tree rather than preserving an inactive copy.

## Current migration implications

The parallel Home_PDS strategy preserves `scr_Home` as fallback during construction, so its two legacy component dependencies remain temporarily.

Punches currently depends on `cmp_DetailDrawer_old`; it remains until a replacement is implemented and Studio-validated.

`cmp_PageHeaderPro` is now approved for controlled Home_PDS integration. Any regression found in Block 03 must be attributed and corrected before Block 04 advances.

`cmp_OperationalSkylinePro` is intentionally blocked at `REVIEW_REQUIRED` until its isolated Power Apps Studio validation gate is completed. No consuming PULSE screen should instantiate it before that result is recorded.
