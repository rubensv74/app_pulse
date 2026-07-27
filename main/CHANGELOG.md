# Changelog

## EPIC-01 — Executive Home · Increment 01 — Runtime Status

### Objective
- Establish a single, observable runtime status for the Executive Home dashboard so users can distinguish idle, updating, ready, and failed states from the header.

### Changed
- Added the executive dashboard runtime variables `varExecutiveDashboardStatus`, `varExecutiveDashboardError`, `varExecutiveDashboardRequestedAt`, and `varExecutiveDashboardCompletedAt`.
- Centralized the transition to `LOADING` in `btnHome_RequestDashboardLoad` for both Punches and Tasks dashboard requests.
- Added completion transitions to `READY` or `ERROR` in the existing Punch Dashboard and Tasks/Hive loaders without changing their Flow calls or collection contracts.
- Added explicit error-state handling for unsupported dashboard actions in `tmrGlobalLoader_1`.
- Added a live status indicator to the Executive Dashboard refresh card showing `IDLE`, `UPDATING`, `READY`, or `FAILED`.
- Preserved project switching, current load actions, existing collections, navigation, SQL contracts, and Power Automate integrations.

### Files modified
- `screens/Home/scr_Home_1.pa.yaml`
- `CHANGELOG.md`

### Validation
- Parsed the complete Power Apps YAML with PyYAML `BaseLoader`.
- Verified 230 controls with unique names.
- Verified the executive runtime status is initialized, enters `LOADING`, and resolves to `READY` or `ERROR` in both dashboard load paths.
- Verified the unsupported-action branch records a concrete failure status and message.
- Verified the new header status control exists exactly once.
- Verified existing Flow invocation counts remain unchanged.
- Verified the differential ZIP opens successfully and contains only the two modified files.

### Limitations
- Power Apps Studio import/compile is not available in the execution environment; validation is structural and static.

### Open issues
- None identified within this increment.

## Sprint 07I — Punch Template Reload Orchestration

### Objective
- Make Punch Dashboard template changes reload through the centralized Home dashboard dispatcher and prevent redundant reloads when the selected template has not actually changed.

### Changed
- Added an explicit template-change guard comparing the selected template with `varPunchDashboardTemplateId`.
- Reset Punch Dashboard snapshot state and collections before requesting data for a different template, preventing stale analytics from remaining visible during the transition.
- Replaced the template selector's duplicated global-loader orchestration with `Select(btnHome_RequestDashboardLoad)`.
- Preserved the existing `LOAD_PUNCH_DASHBOARD` action, Flow calls, collection schemas, and Punch Dashboard data contract.
- Removed the duplicated Sprint 07G changelog section left in the consolidated repository.

### Files modified
- `screens/Home/scr_Home_1.pa.yaml`
- `CHANGELOG.md`

### Validation
- Parsed the complete Power Apps YAML with PyYAML `BaseLoader`.
- Verified control-name uniqueness across the complete screen source.
- Verified the template selector references the centralized dispatcher exactly once.
- Verified the selector no longer writes `varGlobalLoadAction` or `varGlobalLoadPending` directly.
- Verified all seven Punch Dashboard data collections are cleared before the reload request.
- Verified existing Flow-call counts remain unchanged.
- Verified the differential ZIP opens successfully and contains only the two modified files.

### Limitations
- Power Apps Studio import/compile is not available in the execution environment; validation is structural and static.

### Open issues
- None identified within Sprint 07I scope.

## Sprint 07H — Pending Subsystem Task Navigation

### Objective
- Make the Home pending-subsystem operation open the filtered Tasks screen instead of incorrectly reloading the Home Tasks dashboard.

### Changed
- Reworked `btnHome_OpenNodeOperations_1` to use the same Tasks navigation contract as the visible pending-subsystem row action.
- Added the Home return context, subsystem and discipline filters, automatic Tasks loading, and task collection reset before navigation.
- Added the Tasks page metadata required by the application shell.
- Cleared any stale Home global-loader state before leaving the screen.
- Removed the incorrect `LOAD_TASKS` dispatch from this operation; `LOAD_TASKS` remains reserved for refreshing the Home Tasks dashboard.

### Files modified
- `screens/Home/scr_Home_1.pa.yaml`
- `CHANGELOG.md`

### Validation
- Parsed the complete Power Apps YAML with PyYAML `BaseLoader`.
- Verified control-name uniqueness across the complete screen source.
- Verified `btnHome_OpenNodeOperations_1` now navigates to `scr_Tasks` with `varTasks_AutoLoad = true`.
- Verified the operation no longer assigns `varGlobalLoadAction = "LOAD_TASKS"`.
- Verified the Home dashboard dispatcher and existing Flow references remain unchanged.
- Verified the differential ZIP opens successfully and contains only the two modified files.

### Limitations
- Power Apps Studio import/compile is not available in the execution environment; validation is structural and static.

### Open issues
- None identified within Sprint 07H scope.

## Sprint 07G — Tasks Dashboard Load Orchestration

### Objective
- Complete the centralized Home dashboard dispatcher so the Tasks tab uses an explicit executable load action instead of the generic Home route or the existing no-op placeholder.

### Changed
- Routed Tasks dashboard requests from `btnHome_RequestDashboardLoad` to the explicit `LOAD_TASKS` action.
- Replaced the `LOAD_TASKS` timer placeholder with the existing `btnHome_LoadHive_1` loader that supplies the Tasks discipline and subsystem dashboard.
- Preserved the Tasks-specific loading title and subtitle while the shared Hive loader executes.
- Preserved all Flow calls, collections, project selection behavior, dashboard contracts, and Punch Dashboard routing.

### Files modified
- `screens/Home/scr_Home_1.pa.yaml`
- `CHANGELOG.md`

### Validation
- Parsed the complete Power Apps YAML with PyYAML `BaseLoader`.
- Verified control-name uniqueness across the complete screen source.
- Verified the dispatcher emits `LOAD_TASKS` exactly once and the timer executes `Select(btnHome_LoadHive_1)` for that action.
- Verified the obsolete no-op `LOAD_TASKS` branch is absent.
- Verified Flow-call references and counts are unchanged.
- Verified the differential ZIP opens successfully and contains only the two modified files.

### Limitations
- Power Apps Studio import/compile is not available in the execution environment; validation is structural and static.

### Open issues
- None identified within Sprint 07G scope.

## Sprint 07F — Centralized Dashboard Load Request

### Objective
- Centralize Home dashboard load requests so refresh and tab activation use one consistent runtime entry point without changing existing Flow calls or data contracts.

### Changed
- Added the hidden `btnHome_RequestDashboardLoad` dispatcher as the single request point for Punches and Tasks dashboard loads.
- Reused the dispatcher from the Home refresh button and both dashboard tab selectors.
- Standardized project validation, loading messages, loading scope, action selection, and timer retrigger behavior.
- Preserved the existing `btnHome_LoadPunchDashboard`, `btnHome_LoadHive_1`, timer routing, Flow calls, collections, and SQL contracts.

### Files modified
- `screens/Home/scr_Home_1.pa.yaml`
- `CHANGELOG.md`

### Validation
- Parsed the complete Power Apps YAML with PyYAML `BaseLoader`.
- Verified control-name uniqueness across the complete screen source.
- Verified the new dispatcher exists exactly once and all three intended callers reference it.
- Verified existing Flow-call counts and data collection references are unchanged.
- Compared the differential to confirm changes are limited to load-request orchestration and changelog documentation.
- Verified the differential ZIP opens successfully and contains only the two modified files.

### Limitations
- Power Apps Studio import/compile is not available in the execution environment; validation is structural and static.

### Open issues
- None identified within Sprint 07F scope.

## Sprint 07E — Responsive Dashboard Tab Selector

### Objective
- Keep the Punches/Tasks dashboard selector usable and visually aligned at narrow Home content widths without changing its navigation or loading behavior.

### Changed
- Made both dashboard tab buttons share the available width when the selector becomes narrower than 420 px.
- Linked the Tasks tab position to the Punches tab geometry, removing duplicated hard-coded offsets.
- Linked both active-tab indicators to their corresponding button width and horizontal center.
- Preserved all tab `OnSelect` formulas, Flow calls, collections, filters, navigation, and dashboard contracts.

### Files modified
- `screens/Home/scr_Home_1.pa.yaml`
- `CHANGELOG.md`

### Validation
- Parsed the complete Power Apps YAML with PyYAML `BaseLoader`.
- Verified control-name uniqueness across the complete screen source.
- Verified the four responsive tab geometry formulas are present exactly once.
- Compared every `OnSelect` property between the original and modified YAML; no action formula changed.
- Verified the differential ZIP opens successfully and contains only the two modified files.

### Limitations
- Power Apps Studio import/compile is not available in the execution environment; validation is structural and static.

### Open issues
- None identified within Sprint 07E scope.

## Sprint 07D — Responsive Dashboard Empty States

### Objective
- Keep Punches and Tasks dashboard empty/error messages readable and visually aligned across narrow desktop and tablet widths without changing data-loading behavior.

### Changed
- Made the Punch Dashboard state title and detail text responsive to their parent width.
- Enabled `AutoHeight` on the two compatible Punch Dashboard state text controls to prevent message clipping.
- Consolidated the Tasks no-data state into a bordered dashboard card consistent with the Home visual language.
- Centered and made the Tasks no-data title and description responsive, with dynamic vertical positioning to avoid overlap.
- Preserved all Flow calls, collections, navigation, filters, SQL contracts, and action formulas.

### Files modified
- `screens/Home/scr_Home_1.pa.yaml`
- `CHANGELOG.md`

### Validation
- Parsed the complete Power Apps YAML with PyYAML `BaseLoader`.
- Verified control-name uniqueness across the complete screen source.
- Verified the responsive width and dynamic-position formulas are present exactly once.
- Compared every `OnSelect` property between the original and modified YAML; no action formula changed.
- Verified the differential ZIP opens successfully and contains only the two modified files.

### Limitations
- Power Apps Studio import/compile is not available in the execution environment; validation is structural and static.

### Open issues
- None identified within Sprint 07D scope.

## Sprint 07C — Responsive Executive Header

### Objective
- Prevent the consolidated Home executive header from overflowing or overlapping on narrower desktop and tablet widths while preserving all existing dashboard behavior.

### Changed
- Made the executive header gap and horizontal padding responsive below 1000 px.
- Reduced the title block minimum width so the project and refresh cards can remain visible without clipping.
- Added responsive widths to the project selector and refresh cards.
- Made the refresh timestamp and button share the available width without overlap.
- Preserved all dashboard loading logic, Flow calls, collections, navigation, and SQL contracts.

### Files modified
- `screens/Home/scr_Home_1.pa.yaml`
- `CHANGELOG.md`

### Validation
- Parsed the complete Power Apps YAML with PyYAML `BaseLoader`.
- Verified all eight responsive formulas are present exactly once.
- Verified control-name uniqueness across the complete screen source.
- Confirmed no Flow, collection, navigation, SQL contract, or `OnSelect` formula was changed.
- Verified the differential ZIP opens successfully and contains only the two modified files.

### Limitations
- Power Apps Studio import/compile is not available in the execution environment; validation is structural and static.

### Open issues
- None identified within Sprint 07C scope.

## Sprint 07B — Dashboard Tab State Visibility

### Objective
- Restore the active Punches/Tasks tab indicator after the Sprint 07A selector bar height reduction.

### Changed
- Moved both active-tab indicator rectangles inside the 48 px selector bar so they are no longer clipped.
- Aligned the Tasks tab vertically with the Punches tab.
- Preserved all dashboard loading logic, Flow calls, collections, and SQL contracts.

### Files modified
- `screens/Home/scr_Home_1.pa.yaml`
- `CHANGELOG.md`

### Validation
- Parsed the complete Power Apps source with PyYAML `BaseLoader`.
- Verified both indicators use `Y = 45` with `Height = 3` inside a 48 px parent.
- Verified both tab buttons use `Y = 6` and `Height = 36`.
- Confirmed the differential contains no changes to formulas, Flow references, data collections, or SQL contracts.

### Limitations
- Power Apps Studio import/compile is not available in the execution environment; validation is structural and static.

### Open issues
- None identified within Sprint 07B scope.

## Sprint 07A — Home Visual Consolidation

### Objective
- Consolidate the Home header into one compact executive bar without altering dashboard data loading, Flow calls, or SQL contracts.

### Changed
- Removed the redundant standalone `Home` header container and label.
- Moved `Executive Dashboard` and its contextual subtitle into the existing top bar.
- Added `AutoHeight` only to the two compatible `ModernText` controls in the consolidated header.
- Converted the top bar into a bordered surface aligned with the dashboard cards.
- Reduced the dashboard selector bar height after removing its duplicated title and subtitle.
- Repositioned the Punches and Tasks selectors vertically to preserve alignment in the reduced bar.

### Files modified
- `screens/Home/scr_Home_1.pa.yaml`
- `CHANGELOG.md`

### Validation
- Source YAML structure loaded successfully with PyYAML `BaseLoader`, preserving Power Apps formula tags as scalar content.
- Control-name uniqueness verified across the complete screen source.
- Removed control references checked: `conView_Home_Header_1`, `lblHomeTitle_1`, `lblHomeDashboardTabsTitle`, and `lblHomeDashboardTabsSubtitle` are absent.
- Existing Flow call and SQL contract references remain byte-identical outside the localized visual section.

### Limitations
- Power Apps Studio import/compile was not available in the execution environment; validation is static.

### Open issues
- None identified within Sprint 07A scope.

## Sprint 06 — Consolidated Dashboard v3

### Added
- Nodo JSON `insights` en `warroom.usp_GetPunchDashboardBundle`.
- Generación determinista de señales sobre tendencia Open, tendencia Closed, hotspot, TOP Code y subcontractor.
- Colección Power Apps `colPunchDashboardInsights`.
- Tarjeta `conPunchExecutiveInsightsCard` con prioridad, severidad, métrica y drill-through.
- Contrato de datos 3.0 y guía de integración del Flow.

### Changed
- El procedimiento declara `contractVersion` y `DataVersion` como `3.0`.
- La pantalla limpia timeline e insights al recargar y al cambiar de proyecto.
- La tendencia del timeline usa los tokens existentes `varTheme_Green` y `varTheme_Red`.
