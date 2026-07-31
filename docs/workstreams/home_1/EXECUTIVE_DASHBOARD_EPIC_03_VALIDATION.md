# EPIC 03 — Executive Heatmap

Status: **IMPLEMENTED — PENDING INTEGRATION VALIDATION**

Date: 2026-07-31  
Branch: `workstream/home-1-punches-1`

## Objective delivered

Implemented the canonical Executive Heatmap inside the EPIC 02 layout using the existing Dashboard Bundle payload only.

- X axis: Subsystem, matching the canonical reference columns.
- Y axis: Category, matching the canonical reference rows.
- Cell: aggregated Punch count for one Category × Subsystem intersection.
- Row totals, column totals, and grand total included.
- Zero intersections materialized to preserve matrix geometry.
- Dataset-relative five-band intensity scale.
- Hover and persistent single-cell selection.
- Selection reset on template change, dashboard refresh, and project reset.
- Loading, empty, and error message state.
- No navigation, SQL, or Flow execution from the Heatmap.

## Data architecture

The existing `colPunchDashboardSubsystems` payload is transformed once after bundle parsing into:

- `colPunchExecutiveHeatmapColumns`: Subsystem headers and totals;
- `colPunchExecutiveHeatmapRows`: Category headers and totals;
- `colPunchExecutiveHeatmapCells`: Cartesian Category × Subsystem cells.

Selection reuses existing application state:

- `varPunchDrillSubsystemCode`;
- `varPunchDrillCategoryCode`.

Selecting a cell clears stale status, subcontractor, and discipline drill context. It performs no backend or navigation action.

## Modified controls

- Hid the EPIC 02 Heatmap placeholder state label.
- Added column header, row, nested-cell, column-total galleries.
- Added row/column/grand totals, legend, and state labels.
- Added transparent cell interaction button with state-only `OnSelect`.
- Extended existing bundle parsing and reset commands for the three Heatmap collections.

## Repository validation

| Check | Evidence | Result |
|---|---|---|
| YAML hygiene | `git diff --check` | PASS |
| Control identity | 279 named controls, 0 duplicates | PASS |
| Heatmap galleries/buttons | Each declared control exactly once | PASS |
| Backend calls from Heatmap | 0 | PASS |
| Navigation from Heatmap | 0 | PASS |
| Dashboard Bundle calls globally | 1 before / 1 after | PASS |
| Navigation calls globally | 22 before / 22 after | PASS |
| Reset coverage | Template, refresh, project | PASS |
| Source change | 248 insertions, 0 deletions | PASS |
| Post-change SHA-256 | `AA3AD8E480B8403B16425907D8BF369E7D75EEE37537870FB57C277B02A18423` | RECORDED |

## Product Owner integration validation

Include in periodic Studio/UAT validation:

- supported Power Fx syntax for aliases and nested `ForAll`/`Collect`;
- matrix displays X=Subsystem and Y=Category;
- totals reconcile with cells and Dashboard Bundle source;
- zero cells remain visible;
- cell colours scale with the visible maximum;
- hover and selected border render correctly;
- only one selection persists;
- template/project/refresh clear the selection;
- loading/empty/error states preserve layout;
- no horizontal scrolling at supported resolutions;
- cell interaction feels immediate and triggers no Flow.

These checks do not block repository progression under the Autonomous EPIC Execution policy.

## Risks and assumptions

- The backend omits absent intersections; EPIC 03 interprets them as zero. The current contract has no explicit “unknown/missing” flag, so a distinct missing-data state cannot be derived safely.
- Row gallery scrolling may be required for projects with many categories; horizontal scrolling remains disabled.
- Runtime formula compilation is Product Owner integration scope.
- The packaged `.msapp` remains unchanged.

## Rollback

Revert the EPIC 03 commit. EPIC 02 placeholder layout and the original matrix controls remain preserved.

## Next EPIC

EPIC 04 — Right Analytical Column: bind Donut and Selected Cell Details to the in-memory analytical model and current Heatmap selection, without backend calls.
