# PULSE Component Catalog

**Status:** active  
**Purpose:** lifecycle and reuse guidance for `main/components/`  
**Last reviewed:** 2026-08-10  
**Usage audit:** `docs/analysis/repository/COMPONENT_USAGE_AUDIT_2026-08-10.md`

This catalog prevents active, legacy and experimental components from being treated as equivalent reuse candidates.

## Canonical active-component policy

PULSE uses **Option A** for component lifecycle:

```text
main/components =
current runtime dependencies
+ active planned components
+ components created/evolved for current PDS/product work
```

Inactive historical components do not remain in the active source pool merely for possible future reuse. They are preserved under `docs/archive/components/` when retention is useful.

When a new reusable component is needed, its canonical `.pa.yaml` source must be created in:

```text
main/components/
```

in the same development cycle in which the component is introduced. The same cycle must update this catalog. Reusable PDS components should also receive/update a specification under:

```text
docs/design-system/components/
```

A new component therefore becomes part of the active component source set because there is an explicit current need for it; it must not be left only in a chat, construction block, temporary folder or archive.

## Lifecycle states

```text
ACTIVE            preferred current reuse candidate
PDS_CANDIDATE     current component being aligned to PDS
LEGACY_SUPPORTED  still used by current runtime or intentionally supported; not preferred for new design
DEPRECATED        no new use; physical removal still requires dependency audit
REVIEW_REQUIRED   usage/lifecycle not yet fully verified
ARCHIVED          retained only for history; not an active reuse candidate
```

| Component | Lifecycle | Current canonical usage / reuse guidance |
|---|---|---|
| `cmp_ActionToolbarPro` | PDS_CANDIDATE | Preferred action-toolbar base; screen owns action semantics |
| `cmp_CustomFieldEditor` | ACTIVE | Domain component for custom-field editing |
| `cmp_DataTableProV2` | PDS_CANDIDATE | Preferred Data Explorer/table component |
| `cmp_DonutPro` | ACTIVE | Use for progress/completion/capacity-style circular metrics; not Home_PDS discipline composition |
| `cmp_EmptyState` | PDS_CANDIDATE | Preferred empty/error state base; continue visual hardening |
| `cmp_HeatMapPro` | PDS_CANDIDATE | Preferred heatmap component |
| `cmp_KpiCardPro` | PDS_CANDIDATE | Preferred KPI card for new PDS work |
| `cmp_PageHeaderPro` | PDS_CANDIDATE | Canonical source: `main/components/cmp_PageHeaderPro.pa.yaml`; current Home_PDS header component. PDS spec: `docs/design-system/components/CMP_PAGE_HEADER_PRO.md`. Final 02A visual revalidation remains part of the Home_PDS construction gate |
| `cmp_PieChartPro` | PDS_CANDIDATE | Preferred composition chart for Home_PDS discipline distribution |
| `cmp_SidebarNav` | ACTIVE | Current shared navigation component |
| `cmp_SkeletonLoader` | PDS_CANDIDATE | Preferred loading placeholder base |
| `cmp_SmartFilterBarPro` | REVIEW_REQUIRED | Existing premium filter component; reuse only after screen-specific compatibility check |
| `cmp_DashboardSectionHeader` | LEGACY_SUPPORTED | **Used by current `scr_Home`**. New PDS work should target `cmp_PanelHeaderPro` |
| `cmp_ExecutiveAlertBanner` | LEGACY_SUPPORTED | **Used by current `scr_Home`**. Do not remove while Home remains fallback/runtime reference |
| `cmp_DetailDrawer_old` | LEGACY_SUPPORTED | **Used by current `scr_Punches`** as `comp_DetailDrawer_6`; filename is misleading but component is a live dependency |
| `cmp_ExecutiveInsightCard` | ARCHIVED | No canonical-screen usage found; source retained at `docs/archive/components/cmp_ExecutiveInsightCard.pa.yaml` |
| `cmp_ExecutiveKpiCard` | ARCHIVED | No canonical-screen usage found; source retained at `docs/archive/components/cmp_ExecutiveKpiCard.pa.yaml` |

## Rules

1. New work should prefer `ACTIVE` or `PDS_CANDIDATE` components.
2. `LEGACY_SUPPORTED` means the component cannot be removed merely because a newer pattern exists.
3. Historical inactive components do not remain in `main/components/` under Option A.
4. Before physically moving/deleting any component, audit references from canonical screens and components.
5. When a new component is required, create its canonical source under `main/components/` and update this catalog in the same development cycle.
6. Reusable PDS component specifications belong under `docs/design-system/components/`.
7. A suffix such as `_old` is not authoritative lifecycle metadata; this catalog is.
8. A component file existing in GitHub does not prove it is installed in the active Power Apps app; Studio installation/validation remains a separate requirement.

## Current migration implications

The parallel Home_PDS strategy intentionally preserves `scr_Home` as fallback. Therefore Home legacy dependencies remain in `main/components/` until cutover and stabilization are complete.

Punches currently depends on `cmp_DetailDrawer_old`; that component cannot be moved or renamed until the Punches drawer is replaced and Studio-validated.
