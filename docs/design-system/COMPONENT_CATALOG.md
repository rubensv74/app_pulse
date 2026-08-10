# PULSE Component Catalog

**Status:** active  
**Purpose:** lifecycle and reuse guidance for `main/components/`  
**Last reviewed:** 2026-08-10

This catalog prevents active, legacy and experimental components from being treated as equivalent reuse candidates.

Lifecycle states:

```text
ACTIVE            preferred current reuse candidate
PDS_CANDIDATE     current component being aligned to PDS
LEGACY_SUPPORTED  still may be in use but not preferred for new design
DEPRECATED        do not use for new work
REVIEW_REQUIRED   usage/lifecycle not yet fully verified
```

| Component | Lifecycle | Reuse guidance |
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
| `cmp_DashboardSectionHeader` | LEGACY_SUPPORTED | Older section-header pattern; new PDS work should target `cmp_PanelHeaderPro` |
| `cmp_ExecutiveAlertBanner` | LEGACY_SUPPORTED | Older Executive Home generation; verify usage before removal |
| `cmp_ExecutiveInsightCard` | LEGACY_SUPPORTED | Older Executive Home generation; verify usage before removal |
| `cmp_ExecutiveKpiCard` | LEGACY_SUPPORTED | Older KPI generation; prefer `cmp_KpiCardPro` for new work |
| `cmp_DetailDrawer_old` | DEPRECATED | Explicitly old component; do not reuse in new work |

## Rules

1. New work should prefer `ACTIVE` or `PDS_CANDIDATE` components.
2. `LEGACY_SUPPORTED` does not mean safe to delete; it means “do not select by default for new design”.
3. `DEPRECATED` components must not be used for new work.
4. Before physically moving/deleting legacy components, audit references from canonical screens and components.
5. When a new component is added, update this catalog in the same development cycle.
6. Component specifications belong under `docs/design-system/components/`.

## Planned catalog hardening

A later repository-cleanup phase should add:

- actual canonical-screen usage references;
- PDS compliance status;
- Studio validation date;
- version/replacement relationship;
- owner/workstream.
