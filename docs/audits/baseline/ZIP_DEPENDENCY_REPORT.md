# ZIP dependency report

| Dependency | Classification | Evidence/impact |
|---|---|---|
| Power Apps / Power Automate logic flows | REQUIRED | Canvas App has 73 logic-flow data sources; only 2 flows are included |
| Azure SQL Data Warehouse | REQUIRED | Four logical connection references and both included workflows |
| Excel Online (Business) | REQUIRED | Export workflow |
| SharePoint Online | REQUIRED | Export workflow |
| Office 365 Users | REQUIRED | Canvas data source |
| Office 365 Outlook (`shared_office365`) | REQUIRED | Canvas data source |
| 71 externally referenced flows | UNKNOWN | Not packaged; availability, ownership and version cannot be verified |
| Environment variables | UNKNOWN | None packaged; configuration strategy cannot be verified |

Representative external flow references include `Warroom_GetTaskSummaryById`, `Warroom_FilterOptions_Subcontractors`, `Warroom_FilterOptions_Subsystems`, `WarRoom_GetCustomBundle`, `WarRoom_Home_GetKPIs`, `WarRoom_Operations_GetCells`, `WarRoom_Security_IsSuperAdmin`, `Warroom_Punches_Filtered_Paged`, `Warroom_Tasks_Filtered_Paged`, and many ReportConfig/Admin/AttentionQueue flows. The full physical set is the 73 `shared_logicflows` entries in `References/DataSources.json`; only `Warroom_ExportPunchesToExcel_Codex` and `warroom_GetPunchDashboardBundle` are packaged.

Unknown dependencies are not converted to PASS. No forbidden dependency was positively identified, but absence of evidence is not approval.
