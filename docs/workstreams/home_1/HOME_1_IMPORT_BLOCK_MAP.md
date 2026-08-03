# Home_1 import block map

## Purpose

This block map translates the Home_1 YAML hierarchy into pasteable units that preserve parent/child structure and keep the largest galleries and formulas isolated from one another.

## Block map

| Block | Anchor control | Paste scope | Suggested size | Notes |
|---|---|---|---|---|
| B1 | conHomeScreenRoot_1 | conHomeScreenRoot_1, cmp_NavApp_1, conHomeContent_1 | Small | Establishes the overall shell, sidebar width and content region. |
| B2 | con_Home_1 | con_Home_1, conExecutiveHeader_1, cmpHomeExecutiveAlert, conExecutiveKpiStrip_1, cmpHomeDashboardSkeleton, cmpHomeDashboardEmptyState, conHomeDashboardTabs | Medium | Creates the executive dashboard chrome and the Tasks/Punches toggles. |
| B3 | conHomeShell_1 | conHomeShell_1, conHomeMain_1, cntHome_HiveGridArea_1, galHomeHiveNodes_1, conNodeCard_1 | Large | Main Tasks experience and the Hive card gallery. High-risk because of the gallery template and embedded SVG. |
| B4 | conHomeSidebar_1 | conHomeSidebar_1, cntHome_SelectedNode_1, cntHome_PendingSubsystems_1, galHomePendingSubsystems_1, conPendingSubsystemsLoading_1 | Medium | Right-side detail panel and pending-subsystem list. Easier to validate after the main task shell is present. |
| B5 | conPunchDashboard | conPunchDashboard, conPunchDashboardContext, conPunchDashboardBody, conPunchKpiSection, conPunchExecutiveKpiStrip, conPunchExecutiveAnalyticsWorkspace, conPunchExecutiveGridWorkspace, conPunchTimelineCard, conPunchExecutiveInsightsCard, conPunchMatrixCard, conPunchOperationalSummaries | Very large | Punch dashboard shell that holds the next layer of analytics cards and nested galleries. |
| B6 | conPunchExecutiveAnalyticsWorkspace | conPunchExecutiveAnalyticsWorkspace, conPunchExecutiveHeatmapSlot, galPunchExecutiveHeatmapRows, galPunchExecutiveHeatmapCells, conPunchExecutiveRightColumn, htmlPunchExecutiveDonut, conPunchExecutiveDonutSlot, conPunchExecutiveDetailSlot | Large | Contains nested galleries, HtmlViewer rendering and selection logic. |
| B7 | conPunchExecutiveGridWorkspace | conPunchExecutiveGridWorkspace, conPunchExecutiveGridHeader, galPunchExecutiveGridRows, lblPunchExecutiveGridEmpty, btnPunchExecutiveGridPrevious, btnPunchExecutiveGridNext, btnPunchExecutiveGridPageSize | Medium | Executive grid, sorting, paging and export logic. |
| B8 | conGlobalOverlay_Home_1 | conGlobalOverlay_Home_1, btnHome_LoadPunchDashboard, btnHome_LoadHive_1, btnHome_ProjectChange_Commit_1, btnHome_OpenNodeOperations_1, btnHome_LoadPendingSubsystems_1, btnHome_RequestDashboardLoad | Medium | Hidden actions and loading overlay. Paste last so they can attach to the already-rendered shell. |

## Recommended handling for the largest blocks

- B3: paste the outer container first, then the gallery template subtree. If Studio becomes slow, paste the gallery subtree in a second pass after the surrounding container is already in place.
- B5: paste the outer shell first, then the analytics workspace and grid workspace separately. This prevents one massive block from carrying too much nested logic at once.
- B6: keep the HtmlViewer and the nested galleries together in one paste block to preserve their parent/child relationship.
- B8: import the buttons after the visible shell; they are action handlers rather than layout containers.

## Dependencies to preserve

- The Home chrome block depends on the root frame and the sidebar width from B1.
- The Tasks and Punches view blocks both depend on the shared Home container and the dashboard-tab container from B2.
- The pending-subsystem detail panel depends on the selected-node state and the Tasks shell from B3.
- The Punch analytics block depends on the shared Punch dashboard container from B5 and the same shared variables and collections used by the Home dashboard.

## Safe import strategy if Studio still struggles

1. Paste B1 and B2 first.
2. Paste B3.
3. Paste B4.
4. Paste B5.
5. Paste B6.
6. Paste B7.
7. Paste B8.

This order prioritizes the stable shell first and leaves the most formula-heavy blocks for later once the surrounding layout is already present.
