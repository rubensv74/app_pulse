# Static audit — `scr_Home` — 2026-10-22

## Scope and evidence

Reviewed the Studio-exported YAML supplied for `scr_Home`, the associated current-screen screenshot, and the canonical component sources in `power-apps/components/`. This report is static analysis only. It does not claim that the formulas compile, that buttons were exercised in the running app, or that the Studio export is the same revision as the repository.

The screen export contains 256 controls and 12 Canvas Component instances across 9 component types. Five of six separately attached component definitions matched their repository source exactly after normalizing line endings and trailing whitespace. `cmp_SidebarNav` differs; its supplied Studio copy is preserved in the dated snapshot directory. The three component definitions pasted separately have existing canonical files, but full-text comparison was not run.

## Findings

### Confirmed from the supplied screen/component source

| Priority | Finding | Evidence / impact |
|---|---|---|
| High | Data-table row actions and bulk actions are exposed without host handlers. | The instance enables `ShowRowActions` and `ShowBulkActions`, supplies five `ContextActions`, but leaves `OnContextAction` and `OnBulkAction` blank. The component calls these events when the user selects an action. The visible affordances therefore have no screen behavior. |
| High | A guard can close the whole app. | Five active `Exit()` calls appear in the Punch dashboard, pending-subsystems, and Hive loaders. Microsoft documents that `Exit()` exits the running app; it is used here for “no project/selection” or “request already running” guards. Users can be returned to the app list during normal interaction. Replace these early exits with mutually exclusive `If` branches so only the load branch runs when its prerequisites are met. See [Microsoft Power Fx Exit](https://learn.microsoft.com/en-us/power-platform/power-fx/reference/function-exit). |
| High | The Hive/Tasks loader continues after its missing-project guard. | `btnHome_LoadHive_2` shows a warning and clears loading state when `varProjectId` is blank, but its `Exit()` is commented out. The formula then continues, sets loading back to true, and reaches the Hive flow call. Guard the entire load body with `!IsBlank(varProjectId) && !varHomeLoading`; the invalid-context branch should end after cleanup. |
| Medium | Refresh discards the visible snapshot before the replacement is ready. | `btnHome_LoadPunchDashboard_1` sets `varPunchDashboardHasSnapshot` to false and clears the dashboard collections before requesting the bundle. A refresh therefore removes the existing view and shows the generic 280 px skeleton while the request runs; on failure the user loses the last good snapshot. Preserve the current data during same-project refreshes and replace it only after a successful response; clear it on project/template changes. |
| High | The visible rows-per-page control has no callback. | The instance leaves `OnRowsPerPage` blank. The component invokes it from its rows-per-page selector. A separate page-size helper exists in an inactive/hidden legacy grid, but it is not wired to this component. |
| High | Result range is hard-coded. | `VisibleStart=1` and `VisibleEnd=25` are constant inputs, while the table supports multiple server pages. Its footer will keep showing the first page range after navigation. |
| Medium | Sort behavior is local to the fetched page. | The table's `OnSort` updates local sort variables and rebuilds `colHomePunchGridView`. The rebuild sorts `colPunchExecutiveGridFiltered`, which is the current page returned by `warroom_GetPunchDashboardCellDetails`; the flow call does not send sort key/direction. The UI suggests a result-wide sort but the source only sorts the loaded page. |
| Medium | Several toolbar choices are placeholders or do not perform their label's action. | `MORE` displays “Additional actions will be added here.” `COMMENTS` only notifies that the punch will open in the review workspace. `COLUMNS` only tells the user to use the grid gear. These controls add dead-end steps and duplicate the table's own affordances. |
| Medium | Four KPI instances pass an empty `AccessibleLabel`. | The cards are clickable for Total/Open/Closed and visual-only for Completion, but the instance labels are blank. Screen-level scan found 51 controls with an `OnSelect`/`OnChange` and no `AccessibleLabel` or `Tooltip`; this is a candidate count because some are internal or sortable labels, not necessarily standalone keyboard targets. |
| Medium | Studio screenshot and formula disagree on the Open KPI trend tone. | The screenshot shows the positive Open delta in green. The current Home instance sets `TrendTone` to `danger` when the Open delta is positive. Confirm that both artifacts are the same revision and decide the intended meaning of an increase in open punches. |
| Medium | The visible KPI summary omits the `CLEARED` status. | The recorded bundle returns OPEN 6,785; CLEARED 63; CLOSED 6,975; total 13,823. The three statuses reconcile exactly. The KPI strip shows Total/Open/Closed only, leaving users unable to reconcile the 63 CLEARED punches. Decide whether to add a CLEARED KPI or clarify the Total card's composition. |
| Medium | The supplied YAML copy contains a raw control character in a status string. | A raw U+008F occurs in the `In Progress` text formula (source line 1566), and a standard YAML parser rejects the supplied file. This may be copy/encoding corruption rather than the actual Studio source; inspect the source in Studio before importing or editing this text. |
| Low | Home retains a Tasks dashboard branch while its tabs are hidden. | The screen contains separate `TASKS` and `PUNCHES` surfaces, but the selector container has `Visible=false`. Confirm whether the Tasks branch is intentionally retired or has lost its entry point. |

### Candidate code correction — loader guards

The screen YAML is an exported baseline, not the tracked app source, so these are exact repair rules for the corresponding Studio formulas; they are not presented as applied or runtime-validated code.

- `btnHome_LoadPunchDashboard_1`: keep the existing missing-project cleanup in the first `If` result and move the complete load body (starting at `Set(varPunchDashboardLoading, true)`) into the else result. Within that else branch, guard duplicate requests with `If(!varPunchDashboardLoading, <existing load body>)` instead of `Exit()`.
- `btnHome_LoadPendingSubsystems_2`: return from the work by making the request body the else branch of `If(IsBlank(varProjectId) || IsBlank(varSelectedHiveNode.Discipline), <cleanup>, <existing guarded load>)`; duplicate requests should be an empty/no-op branch.
- `btnHome_LoadHive_2`: keep the missing-project warning and cleanup, then place the full Hive request under the valid-project/idle branch. Do not restore loading flags or call the flow after that validation fails.

This avoids app exit and guarantees the request prerequisites before running the flow. The screenshot/video and flow response support the other listed findings; no Monitor trace was used for this pass.

## Runtime evidence — 2026-10-22

A captured execution of `warroom_GetPunchDashboardBundle` returned `success=true`, `hasSnapshot=true`, and DataVersion `3.0`. It generated snapshot 54 from previous snapshot 53 in 5.384 seconds. The response reports a source count of 13,823 and status counts OPEN 6,785, CLEARED 63, CLOSED 6,975; these sum exactly to the source count.

This successful run does not reproduce the Studio “division by zero” notification seen in the recording. It rules out this specific bundle execution as the source of that notification, but does not rule out another execution, a separate flow, or a Canvas formula error. Static inspection of Home and its used component formulas found no unguarded dynamic divisor; the division-by-zero notification remains unresolved in this audit and is deferred; this does not block the static findings or next screen-design work.

### Studio recording — 2026-10-22 18:10

- **Observed normal-load result:** Home remained open and rendered the Punch dashboard. The blocking “Loading Punch Dashboard…” overlay was visible through approximately 24 seconds and gone by approximately 27 seconds. This is a successful normal path, not a latency benchmark; the delay is nevertheless a visible UX concern.
- **Guard branches not exercised in the recording:** a missing project and a second request while one is active are not shown. Therefore the video does not validate the specific `Exit()` replacement paths.
- **Dashboard state:** the visible cards show Total 13,874, Open 6,803, Closed 6,975 and Completion 50.3%. Total minus Open minus Closed is 96. The recording does not identify the status of those 96 records, so they must not be labeled `CLEARED` without the matching response payload.
- The heatmap is initially unselected and the punch list is empty; a later heatmap selection populates the discipline distribution and rows. This supports the selection/drill-through path, but not pagination, row/bulk actions, or all toolbar actions.
- The recording also opens the Custom Fields dialog in Punch Review and displays its field catalog. This is outside the Home loader patch and does not validate save/cancel behavior.
- No division-by-zero banner is visible in this recording. Its cause remains unresolved; this clip does not identify or disprove the source.

## Visual risks from the screenshot

- The screen is very dense: filters, four KPI cards, two analytics panels, an action toolbar and a data table share one view.
- Heatmap, discipline panel and table each have their own scrolling region. This divides attention and makes the relationship between the selected cell, chart and rows harder to follow.
- Text and controls in the analytics/table regions are small at the supplied desktop size.
- The generic skeleton is a 280 px block with three placeholder cards and two rows; it does not mirror Home's four KPIs, two analytics panels, action bar and table. Loading composition should be checked in Studio.
- The visible sample has a high-density heatmap and a long discipline list. The current screenshot shows content, but no evidence was supplied for tablet/narrow-window behavior.

## Integration and contract gaps

Home invokes `Warroom_GetProjectPunchTemplates`, `warroom_GetPunchDashboardBundle`, and `warroom_GetPunchDashboardCellDetails` (plus Hive and drawer flows in the same screen). The repository's flow README says missing real definitions are coverage gaps and must not be inferred from Power Apps call signatures. Therefore this review cannot certify those flows' parameter/output contracts, server sort/paging behavior, timeout behavior, or idempotency.

The repository source for `cmp_SidebarNav` is not byte-equivalent to the supplied Studio export. Do not overwrite the canonical component solely from the snapshot. Reconcile the lifecycle and effects on shared consumers first.

## Recommended order

1. Replace all active `Exit()` guard calls with guarded branches; specifically fix the missing-project path in `btnHome_LoadHive_2` so it cannot execute the flow.
2. Wire the visible table's row, bulk and page-size callbacks, or remove/hide the unsupported affordances.
3. Make server pagination internally consistent: current result range, page size and sort need one explicit contract between the grid, Home and the detail flow.
4. Resolve the Open KPI trend semantic mismatch and explain any valid non-Open/non-Closed punch statuses.
5. Match loading/error/empty states to the real Home composition; check no-project and no-template states.
6. Improve keyboard/accessibility labels, then address density, nested scrolling and responsive widths.
7. Validate the complete Home capability in Power Apps Studio with the checklist below.

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
- Home normal-load and heatmap selection in supplied recording: observed; missing-project/duplicate-load guard paths, App Checker, pagination, row/bulk actions and full toolbar validation: `NOT_RUN`.
- Flow-contract validation: one successful bundle response captured; full contract remains `GATED` on active Flow and SQL definitions.
- Redesign/reference-image work: deferred until the findings and functional contract are settled.
