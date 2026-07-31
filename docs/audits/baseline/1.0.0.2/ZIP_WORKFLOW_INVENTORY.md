# Workflow inventory — 1.0.0.2

There are 69 physical workflow JSON files and 69 matching workflow root components. All use manual/Power Apps or connector-driven definitions; most depend on Azure SQL DW. Full GUIDs are encoded in filenames and `customizations.xml`.

## Specifically required flows

| Flow | GUID | Included | Referenced by app | Connectors | SHA-256 / assessment |
|---|---|---:|---:|---|---|
| `Warroom_ExportPunchesToExcel` | `776AED9C-298B-F111-AB10-000D3A25AA91` | Yes | No exact app reference | SQL DW, Excel Online Business, SharePoint | `424FC300…`; included but not app-canonical |
| `Warroom_ExportPunchesToExcel_Codex` | `1D37F98F-2D8B-F111-AB10-000D3A21CE45` | Yes | Yes; one source use | SQL DW, Excel Online Business, SharePoint | `9DE0DCB9D47F714863A1644EE0AC2C7999302DA82101FD68AD518531C7A46575`; app-canonical by current binding |
| `warroom_GetPunchDashboardBundle` | `4AA15D31-858A-F111-AB10-000D3A21CE45` | Yes | Yes; one source use | SQL DW | `06C57E380849EFF7CEDA9B86619A613F6AA78EAD6267F540DF44B50268EB3C37` |

The only defensible canonical conclusion is scoped: `_Codex` is the export flow currently bound and invoked by this Canvas App. The unsuffixed flow is newly included but not bound by exact name; whether it is intended to replace `_Codex` is unresolved.

## Complete included-name inventory (69)

`DIM_MASTER_COMPANIES_LH`, `Warroom_AddComment`, `Warroom_DeleteComment`, `Warroom_ExportPunchesToExcel`, `Warroom_ExportPunchesToExcel_Codex`, `Warroom_FilterOptions_Disciplines`, `Warroom_FilterOptions_Subcontractors`, `Warroom_FilterOptions_Subsystems`, `warroom_GenerateOverviewSnapshot`, `Warroom_GetCommentsPaged`, `Warroom_GetCustom`, `WarRoom_GetCustomBundle`, `Warroom_GetHiveNodesByDiscipline`, `Warroom_GetOverviewSnapshot`, `Warroom_GetPendingSubsystemsByDiscipline`, `Warroom_GetProjectPunchTemplates`, `warroom_GetPunchDashboardBundle`, `Warroom_GetPunchReportStatusConfig`, `Warroom_GetTaskSummaryById`, `Warrrom_SaveCustom`,

`WarRoom_Admin_Roles_Get`, `WarRoom_Admin_UserProjectRole_Upsert`, `WarRoom_Admin_Users_Get`, `WarRoom_Admin_User_Upsert`, `WarRoom_AttentionQueue_Add`, `WarRoom_AttentionQueue_GetActive`, `WarRoom_AttentionQueue_GetHistory`, `WarRoom_AttentionQueue_Move`, `WarRoom_AttentionQueue_Remove`, `WarRoom_AttentionQueue_SearchSubsystems`, `WarRoom_AttentionQueue_UpdateReason`, `WarRoom_DailyBriefing_CreateDraft`, `WarRoom_DailyBriefing_GetData`, `WarRoom_EnabledProjects_Enable`, `WarRoom_EnabledProjects_GetActive`, `WarRoom_Home_GetExecutiveDashboard`, `WarRoom_Home_GetKPIs`, `WarRoom_Home_GetProgressByDiscipline`, `WarRoom_Home_GetStatusSummary`, `WarRoom_Home_GetTopSubsystemsPending`,

`WarRoom_ListCustomFieldDefs`, `WarRoom_Operations_GetCells`, `WarRoom_Operations_RefreshCellCache`, `WarRoom_Operations_UpsertCell`, `Warroom_PHR_GetPage`, `WarRoom_Projects_Search`, `Warroom_Pulse_GetSubsystemSkyline`, `Warroom_Punches_Filtered_Paged`, `Warroom_Punches_GetFilterCatalogs`, `Warroom_Punches_GetSubcontractors`, `Warroom_Punches_GetSubsystems`, `WarRoom_ReportConfig_AssignGroups`, `WarRoom_ReportConfig_DeactivateNode`, `Warroom_ReportConfig_GetAssignmentModalData`, `WarRoom_ReportConfig_GetAssignments`, `WarRoom_ReportConfig_GetScope`, `WarRoom_ReportConfig_GetTree`, `Warroom_ReportConfig_UnassignGroups`, `WarRoom_ReportConfig_UpsertNode`, `WarRoom_ReportDictionary_Get`, `WarRoom_ReportDictionary_MapDebug`, `WarRoom_SaveCustomBulk`, `WarRoom_Security_IsSuperAdmin`, `WarRoom_SetCustomFieldActive`, `Warroom_SetPunchReportStatusIncluded`, `Warroom_SetPunchTemplateIncluded`, `Warroom_Tasks_Filtered_Paged`, `Warroom_Tasks_GetFilterCatalogs`, `WarRoom_UpsertCustomFieldDef`.

No child-flow relationship was conclusively evidenced. Connection bindings are embedded in workflow client data; connection-reference root components are absent.
