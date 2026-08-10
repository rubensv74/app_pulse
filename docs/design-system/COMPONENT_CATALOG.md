# PULSE Component Catalog

**Status:** active  
**Purpose:** lifecycle and reuse guidance for `main/components/`  
**Last reviewed:** 2026-08-10  
**Usage audit:** `docs/analysis/repository/COMPONENT_USAGE_AUDIT_2026-08-10.md`

This catalog prevents active, legacy and experimental components from being treated as equivalent reuse candidates.

Lifecycle states:

```text
ACTIVE            preferred current reuse candidate
PDS_CANDIDATE     current component being aligned to PDS
LEGACY_SUPPORTED  still used by current runtime or intentionally supported; not preferred for new design
DEPRECATED        no new use; physical removal still requires dependency audit
REVIEW_REQUIRED   usage/lifecycle not yet fully verified
ARCHIVE_CANDIDATE no canonical-screen usage found; lifecycle policy decision required before physical move
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
| `cmp_PieChartPro` | PDS_CANDIDATE | Preferred composition chart for Home_PDS discipline distribution |
| `cmp_SidebarNav` | ACTIVE | Current shared navigation component |
| `cmp_SkeletonLoader` | PDS_CANDIDATE | Preferred loading placeholder base |
| `cmp_SmartFilterBarPro` | REVIEW_REQUIRED | Existing premium filter component; reuse only after screen-specific compatibility check |
| `cmp_DashboardSectionHeader` | LEGACY_SUPPORTED | **Used by current `scr_Home`**. New PDS work should target `cmp_PanelHeaderPro` |
| `cmp_ExecutiveAlertBanner` | LEGACY_SUPPORTED | **Used by current `scr_Home`**. Do not remove while Home remains fallback/runtime reference |
| `cmp_ExecutiveInsightCard` | ARCHIVE_CANDIDATE | No canonical-screen usage found in 2026-08-10 audit |
| `cmp_ExecutiveKpiCard` | ARCHIVE_CANDIDATE | No canonical-screen usage found; prefer `cmp_KpiCardPro` |
| `cmp_DetailDrawer_old` | LEGACY_SUPPORTED | **Used by current `scr_Punches`** as `comp_DetailDrawer_6`; filename is misleading but component is a live dependency |

## Rules

1. New work should prefer `ACTIVE` or `PDS_CANDIDATE` components.
2. `LEGACY_SUPPORTED` means the component cannot be removed merely because a newer pattern exists.
3. `ARCHIVE_CANDIDATE` means current canonical-screen usage was not found; it does not authorize deletion by itself.
4. Before physically moving/deleting any component, audit references from canonical screens and components and apply the repository lifecycle policy.
5. When a new component is added, update this catalog in the same development cycle.
6. Component specifications belong under `docs/design-system/components/`.
7. A suffix such as `_old` is not authoritative lifecycle metadata; this catalog is.

## Current migration implications

The parallel Home_PDS strategy intentionally preserves `scr_Home` as fallback. Therefore Home legacy dependencies remain in `main/components/` until cutover and stabilization are complete.

Punches currently depends on `cmp_DetailDrawer_old`; that component cannot be moved or renamed until the Punches drawer is replaced and Studio-validated.

## Pending lifecycle decision

`cmp_ExecutiveKpiCard` and `cmp_ExecutiveInsightCard` have no canonical-screen usage in the current audit. Before moving them out of `main/components/`, decide whether the active component directory is:

```text
A. runtime + active planned component source only
```

or

```text
B. runtime + inactive reusable library
```

No physical move is authorized until that policy is explicit.
