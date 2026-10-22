# Home Studio component baseline — 2026-10-22

## Purpose

Record the reusable Canvas Components used by the current `scr_Home` export and make their repository definitions discoverable for future screen audits. This is a source inventory and comparison record; it does not establish that the components compile, are installed in the active app, or pass Studio/runtime validation.

## Component inventory

The supplied `scr_Home` YAML instantiates 9 component types in 12 places.

| Component | Instances | Canonical repository source |
|---|---:|---|
| `cmp_SidebarNav` | 1 | [power-apps/components/cmp_SidebarNav.pa.yaml](../../../power-apps/components/cmp_SidebarNav.pa.yaml) |
| `cmp_ExecutiveAlertBanner` | 1 | [power-apps/components/cmp_ExecutiveAlertBanner.pa.yaml](../../../power-apps/components/cmp_ExecutiveAlertBanner.pa.yaml) |
| `cmp_DashboardSectionHeader` | 1 | [power-apps/components/cmp_DashboardSectionHeader.pa.yaml](../../../power-apps/components/cmp_DashboardSectionHeader.pa.yaml) |
| `cmp_SkeletonLoader` | 1 | [power-apps/components/cmp_SkeletonLoader.pa.yaml](../../../power-apps/components/cmp_SkeletonLoader.pa.yaml) |
| `cmp_KpiCardPro` | 4 | [power-apps/components/cmp_KpiCardPro.pa.yaml](../../../power-apps/components/cmp_KpiCardPro.pa.yaml) |
| `cmp_HeatMapPro` | 1 | [power-apps/components/cmp_HeatMapPro.pa.yaml](../../../power-apps/components/cmp_HeatMapPro.pa.yaml) |
| `cmp_PieChartPro` | 1 | [power-apps/components/cmp_PieChartPro.pa.yaml](../../../power-apps/components/cmp_PieChartPro.pa.yaml) |
| `cmp_ActionToolbarPro` | 1 | [power-apps/components/cmp_ActionToolbarPro.pa.yaml](../../../power-apps/components/cmp_ActionToolbarPro.pa.yaml) |
| `cmp_DataTableProV2` | 1 | [power-apps/components/cmp_DataTableProV2.pa.yaml](../../../power-apps/components/cmp_DataTableProV2.pa.yaml) |

## Screen audit

The initial static review is recorded in [SCR_HOME_STATIC_AUDIT_2026-10-22.md](SCR_HOME_STATIC_AUDIT_2026-10-22.md). It identifies table callback/pagination gaps, visual issues, and the Studio/flow gates without treating unrun behavior as validated.

## Comparison performed

The six separately uploaded component exports were compared against the corresponding `main` sources after normalizing line endings and trailing whitespace:

- Exact match: `cmp_HeatMapPro`, `cmp_KpiCardPro`, `cmp_PieChartPro`, `cmp_ActionToolbarPro`, `cmp_DataTableProV2`.
- Divergent: `cmp_SidebarNav`. The supplied Studio export is 474 lines / 19,832 characters; the repository source is 436 lines / 17,618 characters. The Studio export uses an image control for navigation icons, while the repository source uses classic icons; the public contract and other formula differences still need a focused review.

The definitions pasted in the same message for `cmp_ExecutiveAlertBanner`, `cmp_DashboardSectionHeader`, and `cmp_SkeletonLoader` already have canonical source files in the repository. Their full-text equality was not independently computed as part of this comparison.

## Governance

- Use the canonical files under `power-apps/components/` as the source for repository work.
- Consult this dated Studio snapshot when auditing the supplied Home baseline.
- Do not silently copy the Sidebar Studio export over the canonical source. First resolve why the screen's runtime copy differs, assess effects on shared consumers, and validate the selected source in Power Apps Studio.
- The snapshot is evidence of what was supplied on 2026-10-22; it is not evidence that the current app runtime still matches it.
- Reuse this repository inventory for subsequent screens. Ask Rubén only for a component definition absent from the repository or for a newer Studio export when source/runtime sync is material.
