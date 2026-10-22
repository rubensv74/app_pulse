# Static audit — `scr_Home` — 2026-10-22

## Scope and evidence

Reviewed the Studio-exported YAML supplied for `scr_Home`, the associated current-screen screenshot, and the canonical component sources in `power-apps/components/`. This report is static analysis only. It does not claim that the formulas compile, that buttons were exercised in the running app, or that the Studio export is the same revision as the repository.

The screen export contains 256 controls and 12 Canvas Component instances across 9 component types. Five of six separately attached component definitions matched their repository source exactly after normalizing line endings and trailing whitespace. `cmp_SidebarNav` differs; its supplied Studio copy is preserved in the dated snapshot directory. The three component definitions pasted separately have existing canonical files, but full-text comparison was not run.

## Findings

### Confirmed from the supplied screen/component source

| Priority | Finding | Evidence / impact |
|---|---|---|
| High | Data-table row actions and bulk actions are exposed without host handlers. | The instance enables `ShowRowActions` and `ShowBulkActions`, supplies five `ContextActions`, but leaves `OnContextAction` and `OnBulkAction` blank. The component calls these events when the user selects an action. The visible affordances therefore have no screen behavior. |
| High | The visible rows-per-page control has no callback. | The instance leaves `OnRowsPerPage` blank. The component invokes it from its rows-per-page selector. A separate page-size helper exists in an inactive/hidden legacy grid, but it is not wired to this component. |
| High | Result range is hard-coded. | `VisibleStart=1` and `VisibleEnd=25` are constant inputs, while the table supports multiple server pages. Its footer will keep showing the first page range after navigation. |
| Medium | Sort behavior is local to the fetched page. | The table's `OnSort` updates local sort variables and rebuilds `colHomePunchGridView`. The rebuild sorts `colPunchExecutiveGridFiltered`, which is the current page returned by `warroom_GetPunchDashboardCellDetails`; the flow call does not send sort key/direction. The UI suggests a result-wide sort but the source only sorts the loaded page. |
| Medium | Several toolbar choices are placeholders or do not perform their label's action. | `MORE` displays “Additional actions will be added here.” `COMMENTS` only notifies that the punch will open in the review workspace. `COLUMNS` only tells the user to use the grid gear. These controls add dead-end steps and duplicate the table's own affordances. |
| Medium | Four KPI instances pass an empty `AccessibleLabel`. | The cards are clickable for Total/Open/Closed and visual-only for Completion, but the instance labels are blank. Screen-level scan found 51 controls with an `OnSelect`/`OnChange` and no `AccessibleLabel` or `Tooltip`; this is a candidate count because some are internal or sortable labels, not necessarily standalone keyboard targets. |
| Medium | Studio screenshot and formula disagree on the Open KPI trend tone. | The screenshot shows the positive Open delta in green. The current Home instance sets `TrendTone` to `danger` when the Open delta is positive. Confirm that both artifacts are the same revision and decide the intended meaning of an increase in open punches. |
| Medium | The shown KPI totals leave a count unexplained. | Screenshot: Total 13,719; Open 6,766; Closed 6,904. Open + Closed = 13,670, leaving 49 punches outside those two labels. This may be valid if other statuses exist; the dashboard does not explain them in the visible KPI summary. |
| Low | Home retains a Tasks dashboard branch while its tabs are hidden. | The screen contains separate `TASKS` and `PUNCHES` surfaces, but the selector container has `Visible=false`. Confirm whether the Tasks branch is intentionally retired or has lost its entry point. |

### Visual risks from the screenshot

- The screen is very dense: filters, four KPI cards, two analytics panels, an action toolbar and a data table share one view.
- Heatmap, discipline panel and table each have their own scrolling region. This divides attention and makes the relationship between the selected cell, chart and rows harder to follow.
- Text and controls in the analytics/table regions are small at the supplied desktop size.
- The generic skeleton is a 280 px block with three placeholder cards and two rows; it does not mirror Home's four KPIs, two analytics panels, action bar and table. Loading composition should be checked in Studio.
- The visible sample has a high-density heatmap and a long discipline list. The current screenshot shows content, but no evidence was supplied for tablet/narrow-window behavior.

## Integration and contract gaps

Home invokes `Warroom_GetProjectPunchTemplates`, `warroom_GetPunchDashboardBundle`, and `warroom_GetPunchDashboardCellDetails` (plus Hive and drawer flows in the same screen). The repository's flow README says missing real definitions are coverage gaps and must not be inferred from Power Apps call signatures. Therefore this review cannot certify those flows' parameter/output contracts, server sort/paging behavior, timeout behavior, or idempotency.

The repository source for `cmp_SidebarNav` is not byte-equivalent to the supplied Studio export. Do not overwrite the canonical component solely from the snapshot. Reconcile the lifecycle and effects on shared consumers first.

## Recommended order

1. Wire the visible table's row, bulk and page-size callbacks, or remove/hide the unsupported affordances.
2. Make server pagination internally consistent: current result range, page size and sort need one explicit contract between the grid, Home and the detail flow.
3. Resolve the Open KPI trend semantic mismatch and explain any valid non-Open/non-Closed punch statuses.
4. Match loading/error/empty states to the real Home composition; check no-project and no-template states.
5. Improve keyboard/accessibility labels, then address density, nested scrolling and responsive widths.
6. Validate the complete Home capability in Power Apps Studio with the checklist below.

## Studio validation checklist — not yet run

- Load Home with a project and template; inspect loading, ready and refresh states.
- Switch project and template; confirm old data is not presented as new project data and errors release all loading indicators.
- Select/clear heatmap cells and a discipline; verify KPI/chart/grid context remains aligned.
- Navigate to another page, change page size, sort, and verify the footer range and data order against server results.
- Exercise every table bulk and row menu action, plus every top toolbar action.
- Test no project, no template, empty data and flow error states.
- Check at the supported narrowest viewport and use keyboard/screen reader navigation for filters, cards, sortable headers and row actions.

## Status

- Static source inspection: completed for this first Home pass.
- Studio/App Checker and interaction validation: `NOT_RUN` (manual runtime gate).
- Flow-contract validation: `GATED` on real exported flow definitions/response contracts.
- Redesign/reference-image work: deferred until the findings and functional contract are settled.
