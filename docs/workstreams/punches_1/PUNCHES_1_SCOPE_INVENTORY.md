# Punches_1 scope inventory

## Primary source

- Screen: `power-platform/working-baselines/1.0.0.2/canvas-source/new_pulse_9584c/Src/scr_Punches_1.pa.yaml`
- Size: 244,135 bytes
- SHA-256: `C81242123AA072C2C3926037C7C6D8685B489A5A432F817B8FBB9767F166C529`

## Direct components

`cmp_DetailDrawer_old`, `cmp_DynamicFilters`, `cmp_MultiValueFilter`, `cmp_SidebarNav`. `cmp_DetailDrawer_old` is active sprint dependency, not a deletion candidate.

## Direct flows

`Warroom_ExportPunchesToExcel_Codex`, `WarRoom_GetCustomBundle`, `Warroom_GetTaskCommentsPaged`, `WarRoom_ListCustomFieldDefs`, `Warroom_Punches_Filtered_Paged`, `Warroom_Punches_GetFilterCatalogs`, `WarRoom_SetCustomFieldActive`, `WarRoom_UpsertCustomFieldDef`.

The screen currently invokes the `_Codex` export flow; no canonical-flow consolidation is authorized in this sprint. `GetTaskCommentsPaged` is a known unresolved binding.

## SQL and contracts

- Paging/filtering: `[warroom].[usp_GetProjectPunchesExtended_FilteredPaged]` and `[warroom].[usp_GetProjectPunchFilterCatalogs]`.
- Export: `[warroom].[usp_CompletePunchExportBatch]`, `[warroom].[usp_ExportProjectPunchesExtended_Pivoted]`, `[warroom].[usp_GetPunchExportColumnMap]`, `[warroom].[usp_PunchExportLog_Start]`, `[warroom].[usp_PunchExportLog_Complete]`, `[warroom].[usp_RegisterPunchExportSnapshot]`.
- Repository SQL: `sql/export/usp_ExportProjectPunchesExtended_Pivoted.sql`, `sql/export/002_register_punch_export_snapshot.sql`, export diagnostics/migration files.
- Documentation/contracts: `docs/sql/PUNCH_EXPORT_SQL_CANONICAL_MODEL.md`, `docs/sql/PUNCH_EXPORT_SQL_MIGRATION_RUNBOOK.md`, `docs/I01_1_E2E_VALIDATION.md`, `docs/upgrades/I01.1-UPG-002/UPGRADE_DEFINITION.md`, `office-scripts/BuildPunchExport.ts`.

## State and navigation

Collections: `colPunches*`, filter catalogs, dynamic-filter collections, `colPunchExportColumns*`, comments and custom-field collections. Global state centers on `varPunches*`, `varPunchExport*`, `varPunchCatalogs*`, drawer/comment state and filters.

Navigation targets: `scr_Briefing`, `scr_Config_NEW`, `scr_Home`, `scr_Overview`, `scr_Punches_1`, `scr_Skyline`, `scr_SuperAdmin`, `scr_Tasks`. Navigation back to legacy `scr_Home` is preserved and should be reconciled only through an explicit sprint story.

## Sprint boundary

Candidate edits are the primary screen, four direct components, eight direct flows and named SQL/contracts when a Punches_1 requirement proves necessity. Flow consolidation and legacy-screen removal are out of scope.
