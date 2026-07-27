# EPIC-01 — Executive Component Integration

## Purpose

This package creates the reusable presentation layer for Executive Home without modifying the current Home screen.

## Import order

1. `cmp_DashboardSectionHeader.pa.yaml`
2. `cmp_ExecutiveKpiCard.pa.yaml`
3. `cmp_ExecutiveInsightCard.pa.yaml`
4. `cmp_ExecutiveAlertBanner.pa.yaml`
5. `cmp_SkeletonLoader.pa.yaml`
6. `cmp_EmptyState.pa.yaml`

## Integration constraints

- Keep the existing Home dispatcher and Flow calls.
- Bind component colors to the existing `varTheme_*` tokens.
- Use component Event properties for navigation, refresh and dismiss actions.
- Do not place Canvas Components inside galleries.
- Validate each component in a blank test screen before replacing existing Home controls.
- Use one component instance per KPI or insight card.

## Example bindings

### KPI

- `Title`: `"Open punches"`
- `ValueText`: formatted value from the existing Punch summary.
- `Status`: `"SUCCESS"`, `"WARNING"`, `"CRITICAL"` or `"NEUTRAL"`.
- `OnSelect`: navigate to Punch List with the corresponding filters.

### Alert

- `VisibleState`: dashboard error or warning condition.
- `Severity`: `"ERROR"`, `"WARNING"` or `"INFO"`.
- `OnAction`: `Select(btnHome_RequestDashboardLoad)`.
- `OnDismiss`: set the existing dismiss flag.

### Empty state

Use `State` values:

- `EMPTY`
- `ERROR`
- `NO_PROJECT`
- `NO_PERMISSION`

## Remaining EPIC-01 work

- Replace the duplicated Home KPI controls with component instances.
- Replace the local alert implementation with `cmp_ExecutiveAlertBanner`.
- Map `colPunchDashboardInsights` and future task insights to `cmp_ExecutiveInsightCard`.
- Replace the current Home skeleton with `cmp_SkeletonLoader`.
- Consolidate all Home no-data states through `cmp_EmptyState`.
