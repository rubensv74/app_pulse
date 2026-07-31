# ZIP workflow inventory

| Name | GUID | Path | Trigger | Connectors | SHA-256 | Observation |
|---|---|---|---|---|---|---|
| `Warroom_ExportPunchesToExcel_Codex` | `1D37F98F-2D8B-F111-AB10-000D3A21CE45` | `Workflows/Warroom_ExportPunchesToExcel_Codex-1D37F98F-2D8B-F111-AB10-000D3A21CE45.json` | manual / Power Apps | Excel Online Business, SharePoint Online, Azure SQL DW | `9DE0DCB9D47F714863A1644EE0AC2C7999302DA82101FD68AD518531C7A46575` | Present and declared |
| `warroom_GetPunchDashboardBundle` | `4AA15D31-858A-F111-AB10-000D3A21CE45` | `Workflows/warroom_GetPunchDashboardBundle-4AA15D31-858A-F111-AB10-000D3A21CE45.json` | manual / Power Apps | Azure SQL DW | `06C57E380849EFF7CEDA9B86619A613F6AA78EAD6267F540DF44B50268EB3C37` | Present and declared |

Total included: 2. `Warroom_ExportPunchesToExcel` without the `_Codex` suffix is referenced by the app lineage/current repository evidence but absent from the ZIP. The app contains 73 logic-flow data sources; 71 are external to this solution. No child-flow relationship could be proven from the included definitions.
