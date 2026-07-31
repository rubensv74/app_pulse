# Executive Dashboard Changelog RC1

Status: **AUDITED ENDPOINT — RELEASE BLOCKED**

Range: `453cd8e..84d56de`

## Ordered implementation commits

1. `ed7ec67` — EPIC 01 visibility.
2. `bbbf309` — EPIC 01 documentation.
3. `285fecc` — EPIC 02 layout.
4. `7ed8984` — EPIC 03 heatmap.
5. `0f2633e` — EPIC 04 analytical context.
6. `56c70be` — EPIC 05 blocker evidence.
7. `5aa6deb` — EPIC 05 Bundle/Grid.
8. `4c291e9` — EPIC 06 navigation.
9. `84d56de` — EPIC 07 validation.

## Modified files

- `docs/SQL/warroom.usp_GetPunchDashboardBundle.md`
- `power-platform/working-baselines/1.0.0.2/canvas-source/new_pulse_9584c/Src/scr_Home_1.pa.yaml`

## Created files

- `docs/contracts/PUNCH_DASHBOARD_BUNDLE_V4.md`
- `docs/specifications/PULSE_EXECUTIVE_DASHBOARD_FDS_v1.md`
- `docs/specifications/assets/PULSE_EXECUTIVE_DASHBOARD_REFERENCE_v1.png`
- `docs/workstreams/home_1/EXECUTIVE_DASHBOARD_EPIC_01_PLAN.md`
- `docs/workstreams/home_1/EXECUTIVE_DASHBOARD_EPIC_01_VALIDATION.md`
- `docs/workstreams/home_1/EXECUTIVE_DASHBOARD_EPIC_02_VALIDATION.md`
- `docs/workstreams/home_1/EXECUTIVE_DASHBOARD_EPIC_03_VALIDATION.md`
- `docs/workstreams/home_1/EXECUTIVE_DASHBOARD_EPIC_04_VALIDATION.md`
- `docs/workstreams/home_1/EXECUTIVE_DASHBOARD_EPIC_05_BLOCKER.md`
- `docs/workstreams/home_1/EXECUTIVE_DASHBOARD_EPIC_05_VALIDATION.md`
- `docs/workstreams/home_1/EXECUTIVE_DASHBOARD_EPIC_06_VALIDATION.md`
- `docs/workstreams/home_1/EXECUTIVE_DASHBOARD_EPIC_07_VALIDATION.md`
- `docs/workstreams/home_1/EXECUTIVE_DASHBOARD_PHASE_ZERO_READINESS.md`
- `sql/dashboard/usp_GetPunchDashboardBundle_v4.sql`

Removed files: none.

## Power Apps controls

85 controls were added and none removed:

- containers: `conPunchExecutiveAnalyticsWorkspace`, `conPunchExecutiveDetailSlot`, `conPunchExecutiveDonutSlot`, `conPunchExecutiveGridHeader`, `conPunchExecutiveGridWorkspace`, `conPunchExecutiveHeatmapSlot`, five KPI containers, `conPunchExecutiveKpiStrip`, `conPunchExecutiveRightColumn`;
- galleries: Donut legend, Grid rows, Heatmap rows/cells/columns/totals;
- actions: Clear Selection, View Punches, Grid Refresh/Export/Columns/Go/Previous/Next/Page Size/Row, Heatmap Cell and Grid Code Sort;
- visual/data controls: Donut HtmlViewer, selected-row rectangle, Donut legend colour, KPI labels, Heatmap labels, Detail labels and Grid labels/empty/page state.

41 existing control blocks were impacted directly or structurally:

`btnHome_LoadPunchDashboard`, `btnHome_ProjectChange_Commit_1`, `cmbHomePunchTemplate`, `cmpHomeKpiProgress`, `cmpPunchInsightPrimary`, `cmpPunchInsightSecondary`, `cntHome_HiveGridArea_1`, `cntHome_PendingSubsystems_1`, `cntHome_RightPanelArea_1`, `con_Home_1`, `conExecutiveKpiStrip_1`, `conHomeContent_1`, `conHomeMain_1`, `conHomeScreenRoot_1`, `conHomeShell_1`, `conHomeSidebar_1`, `conNodeCard_1`, `conPunchDashboard`, `conPunchDashboardBody`, `conPunchDashboardContext`, `conPunchExecutiveInsightsCard`, `conPunchKpiSection`, `conPunchMatrixCard`, `conPunchOperationalSummaries`, `conPunchStatusKpiCard`, `conPunchSubcontractorCard`, `conPunchTimelineCard`, `conPunchTopCodeCard`, `galHomeHiveNodes_1`, `galHomePendingSubsystems_1`, `galPunchStatusKpis`, `galPunchSubcontractors`, `galPunchTopCodes`, `lbl_Dt_1`, `lblPunchKpiTrend`, `lblPunchSnapshotInfo`, `lblPunchSubcontractorDetail`, `lblPunchTimelineCurrentTrend`, `lblPunchTopCodeCategory`, `Text19_1`, and `Text21_1`.

## Collections

Created:

- `colPunchDashboardPunches`
- `colPunchExecutiveDistribution`
- `colPunchExecutiveHeatmapCells`
- `colPunchExecutiveHeatmapColumns`
- `colPunchExecutiveHeatmapRows`
- `colPunchExecutiveSelection`

Existing collections reused/modified include `colPunchDashboardSummary`, `colPunchDashboardMatrix`, `colPunchDashboardSubsystems`, `colPunchDashboardSnapshotInfo`, `colPunchDashboardTimeline`, `colPunchDashboardInsights`, and `colPunchDashboardSubcontractors`.

## Variables

New to Home_1:

- `varPunchExecutiveGridCompact`
- `varPunchExecutiveGridLastClick`
- `varPunchExecutiveGridPage`
- `varPunchExecutiveGridPageSize`
- `varPunchExecutiveGridSelectedId`
- `varPunchExecutiveGridSortColumn`
- `varPunchExecutiveGridSortDirection`

`varPunches_PageSize` is newly referenced in Home_1 but already belongs to the Punches_1 contract.

Existing state reused/modified includes dashboard loading/template/error state; Heatmap drill Category/Subsystem/Status/Discipline/Subcontractor state; Punches_1 filter/navigation state; Drawer state; and existing theme variables.

## SQL and Flow

SQL:

- `warroom.usp_GetPunchDashboardBundle` contract version raised from 3.0 to 4.0;
- canonical sections added: `kpis`, `distribution`, `detail`, `punches`;
- existing `matrix` retained;
- backward-compatible properties retained;
- executive Punch subset limited to 100 and filtered by Project/Template.

Flow:

- no Flow source file changed;
- existing ProjectId/TemplateId inputs and string `result` response remain byte-identical;
- no direct Home_1 call to `Warroom_Punches_Filtered_Paged`.

## Open release issue

RC1-01: **DATA CONTRACT AMBIGUITY — FUNCTIONAL EQUIVALENCE NOT PROVEN**. Direct replacement is not approved. See the distribution lineage and reconciliation analyses.
