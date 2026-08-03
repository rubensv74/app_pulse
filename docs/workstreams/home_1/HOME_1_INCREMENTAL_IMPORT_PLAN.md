# Home_1 incremental import plan

## Objective

Produce a deterministic, low-risk import sequence for the Home screen in Power Apps Studio by pasting the existing YAML in parent-contained blocks. The goal is to preserve the current control identities, layout hierarchy and formulas while avoiding a single large paste that is likely to overwhelm Studio.

## Source of truth

- Screen: power-platform/working-baselines/1.0.0.2/canvas-source/new_pulse_9584c/Src/scr_Home_1.pa.yaml
- Scope: current canonical Home_1 source only; no YAML edits, no Canvas pack attempt, no solution packaging in this phase.

## Import rules

1. Paste by container subtree, not by arbitrary visual section.
2. Always import the parent container first and then its descendants.
3. Keep existing control names unchanged.
4. Import the high-risk galleries and HtmlViewer blocks after the surrounding shell is already present.
5. Import the hidden action buttons and the global overlay last so they can attach to the already-formed visible layout.

## Recommended paste order

### Block 1 — Root frame and navigation shell

Anchor: conHomeScreenRoot_1

Paste scope:
- conHomeScreenRoot_1
- cmp_NavApp_1
- conHomeContent_1

Why first:
- This establishes the full screen shell, app width/height, sidebar width and the content region used by every other block.
- It also defines the base container that hosts the Home Tasks/Punches switch.

### Block 2 — Home chrome and dashboard tabs

Anchor: con_Home_1

Paste scope:
- con_Home_1
- conExecutiveHeader_1
- cmpHomeExecutiveAlert
- conExecutiveKpiStrip_1
- cmpHomeDashboardSkeleton
- cmpHomeDashboardEmptyState
- conHomeDashboardTabs

Why second:
- This block creates the visible executive dashboard chrome and the top-level switch between Tasks and Punches.
- It is mostly structural and should load before the larger content areas.

### Block 3 — Tasks dashboard shell

Anchor: conHomeShell_1

Paste scope:
- conHomeShell_1
- conHomeMain_1
- cntHome_HiveGridArea_1
- galHomeHiveNodes_1 and its card template subtree
- conHomeSidebar_1
- cntHome_SelectedNode_1
- cntHome_PendingSubsystems_1
- conPendingSubsystemsLoading_1

Why third:
- This is the main Tasks experience and contains the large Hive gallery, the node card template and the right-side pending-subsystem detail panel.
- The card template is the highest-risk area for the Tasks view because it includes an embedded SVG image and long selection formulas.

### Block 4 — Tasks detail and loading state

Anchor: conHomeShell_1 (second pass) or the right-panel subtree

Paste scope:
- conHomeSidebar_1 contents as a separate pass if Studio struggles with the larger Tasks block
- cntHome_SelectedNode_1
- cntHome_PendingSubsystems_1
- galHomePendingSubsystems_1 and its row controls
- the loading overlay inside conPendingSubsystemsLoading_1

Why this split helps:
- The right-hand panel contains many small controls and inline formulas, so it is often easier to paste after the larger left-side dashboard shell is already present.

### Block 5 — Punch dashboard shell

Anchor: conPunchDashboard

Paste scope:
- conPunchDashboard
- conPunchDashboardContext
- conPunchDashboardBody
- conPunchKpiSection
- conPunchExecutiveKpiStrip
- conPunchExecutiveAnalyticsWorkspace
- conPunchExecutiveGridWorkspace
- conPunchTimelineCard
- conPunchExecutiveInsightsCard
- conPunchMatrixCard
- conPunchOperationalSummaries

Why fifth:
- This is the largest visible section and contains several nested galleries and the most complex formulas in the screen.
- Importing the shell after the task dashboard is in place reduces the chance of Studio failing on the nested gallery tree from the start.

### Block 6 — Punch analytics and heatmap subtree

Anchor: conPunchExecutiveAnalyticsWorkspace

Paste scope:
- conPunchExecutiveAnalyticsWorkspace
- conPunchExecutiveHeatmapSlot
- galPunchExecutiveHeatmapRows
- galPunchExecutiveHeatmapCells
- conPunchExecutiveRightColumn
- htmlPunchExecutiveDonut
- conPunchExecutiveDonutSlot
- conPunchExecutiveDetailSlot

Why this is separate:
- This subtree is full of nested galleries, a HtmlViewer donut, and selection-based state updates.
- It should follow the broader Punch shell once sizing and parent containers are already present.

### Block 7 — Punch grid and pager subtree

Anchor: conPunchExecutiveGridWorkspace

Paste scope:
- conPunchExecutiveGridWorkspace
- conPunchExecutiveGridHeader
- galPunchExecutiveGridRows
- lblPunchExecutiveGridEmpty
- btnPunchExecutiveGridPrevious/Next/PageSize

Why this is separate:
- The executive grid contains the main punch-list experience and the export/sorting/paging logic.
- It is easier to validate once the surrounding analytic shell exists.

### Block 8 — Overlay and hidden actions

Anchor: conGlobalOverlay_Home_1

Paste scope:
- conGlobalOverlay_Home_1
- btnHome_LoadPunchDashboard
- btnHome_LoadHive_1
- btnHome_ProjectChange_Commit_1
- btnHome_OpenNodeOperations_1
- btnHome_LoadPendingSubsystems_1
- btnHome_RequestDashboardLoad

Why last:
- These controls are mostly action handlers and loading-state surfaces. They are important, but they should be brought in after the visible shell is already present so their references resolve cleanly in Studio.

## High-risk controls to keep together

- galHomeHiveNodes_1 plus conNodeCard_1: the task card gallery and its SVG-based image formula are the most likely to cause local paste pressure.
- galPunchExecutiveHeatmapRows and its nested galPunchExecutiveHeatmapCells: nested galleries with dynamic selection formulas.
- htmlPunchExecutiveDonut: HtmlViewer-based rendering should be imported as part of the surrounding analytics block.
- galPunchExecutiveGridRows: large dynamic grid plus sorting and paging formulas.
- btnHome_LoadPunchDashboard and btnHome_LoadHive_1: these contain the longest formulas and should be imported after the visible shell is present.

## Validation checklist after each paste block

- The screen remains visible and does not fall into a blank or grey state.
- The parent container and its child controls appear in Studio with intact names.
- The visible region for the imported block matches the expected layout.
- The most important formulas still resolve without immediate syntax issues.

## Recommended import sequencing summary

1. Root frame and navigation shell.
2. Home chrome and dashboard tabs.
3. Tasks dashboard shell.
4. Tasks right-panel detail / pending subsystem shell.
5. Punch dashboard shell.
6. Punch analytics and heatmap subtree.
7. Punch grid and paging subtree.
8. Overlay and hidden action buttons.
