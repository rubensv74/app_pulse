# EPIC-01 — Executive Home Component Integration

## Implemented in this delivery

- Executive alert replaced by `cmp_ExecutiveAlertBanner`.
- Project pulse KPI strip replaced by four `cmp_ExecutiveKpiCard` instances.
- KPI data bindings: Progress, Open Tasks, Open Punches and Pending Subsystems.
- KPI trends, status colors, tooltips and contextual navigation.
- Unified loading state through `cmp_SkeletonLoader`.
- Unified no-project, no-data, error and no-permission states through `cmp_EmptyState`.
- Existing dispatcher and flow calls preserved.

## Import order

1. Components from `main/components`.
2. `main/screens/Home/scr_Home_1.pa.yaml`.
3. Validate formulas in Power Apps Studio.

## Target-environment checks

- Confirm custom component instance syntax is accepted by the installed Power Apps source-code schema version.
- Test responsive widths at 1280, 1366, 1440 and 1920 px and tablet landscape.
- Exercise KPI navigation, retry, dismiss, refresh, no-project and no-data states.
