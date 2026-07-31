# Home_1 scope inventory

## Primary source

- Screen: `power-platform/working-baselines/1.0.0.2/canvas-source/new_pulse_9584c/Src/scr_Home_1.pa.yaml`
- Size: 348,898 bytes
- SHA-256: `98B2B45255DD8F4D6E4C844243A2DFEB86CE4A580311418F42663CD0D6D0F203`

## Direct components

`cmp_DashboardSectionHeader`, `cmp_DetailDrawer_Premium`, `cmp_EmptyState`, `cmp_ExecutiveAlertBanner`, `cmp_ExecutiveInsightCard`, `cmp_ExecutiveKpiCard`, `cmp_SidebarNav`, `cmp_SkeletonLoader`. Their sources are under `canvas-source/new_pulse_9584c/Src/Components/`.

## Direct flows

`Warroom_AddTaskComment`, `WarRoom_GetCustomBundle`, `Warroom_GetHiveNodesByDiscipline`, `Warroom_GetPendingSubsystemsByDiscipline`, `Warroom_GetProjectPunchTemplates`, `warroom_GetPunchDashboardBundle`, `Warroom_GetTaskCommentsPaged`, `WarRoom_ListCustomFieldDefs`, `WarRoom_SaveCustomBulk`, `WarRoom_SetCustomFieldActive`, `WarRoom_UpsertCustomFieldDef`.

The exact `AddTaskComment` and `GetTaskCommentsPaged` bindings are known debt; similarly named solution flows exist, but identity equivalence is not proven.

## SQL and data contracts

- Dashboard: `[warroom].[usp_GetPunchDashboardBundle]` via `warroom_GetPunchDashboardBundle`.
- Hive/pending: `[warroom].[usp_Home_GetHiveNodesByDiscipline]`, `[warroom].[usp_Home_GetPendingSubsystemsByDiscipline]`.
- Templates/custom fields: `[warroom].[usp_GetProjectPunchTemplates]`, `[warroom].[usp_CustomBundle_GetJson]` plus custom-field flows.
- Repository docs: `docs/sql/warroom.usp_GetPunchDashboardBundle.md`, `docs/sql/warroom.usp_GetOrRefreshPunchDashboardBundle.md`.

## State and navigation

Primary collections include `colHomeHiveNodes*`, `colHomeLowestProgress*`, `colHomePendingSubsystems*`, `colPunchDashboard*`, filter catalogs, comments and custom-field collections. Global state centers on `varHome*`, `varExecutiveDashboard*`, `varPunchDashboard*`, project identity, loading state and drill-through filters.

Navigation targets: `scr_Briefing`, `scr_Config_NEW`, `scr_Home_1`, `scr_Overview`, `scr_Punches`, `scr_Skyline`, `scr_SuperAdmin`, `scr_Tasks`. Navigation to legacy `scr_Punches` is preserved and must be reviewed before changing Home_1 drill-through behavior.

## Sprint boundary

Candidate edits are the primary screen plus the eight direct components and directly invoked flows only when a Home_1 requirement proves the need. Legacy screens, global cleanup and unrelated flows are out of scope.
