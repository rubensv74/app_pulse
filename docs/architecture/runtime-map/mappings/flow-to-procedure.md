# Flow → procedimiento almacenado

Baseline parcial: `baseline_pulse_1_0_0_5.zip`.

| Flow | Procedimiento observado |
|---|---|
| `WarRoom_ReportConfig_GetTree` | `warroom.usp_ReportNode_GetTree` |
| `WarRoom_ReportConfig_GetAssignments` | `warroom.usp_ReportAssignment_Get` |
| `WarRoom_ReportConfig_GetScope` | `warroom.usp_InspectionScope_GroupedTotals` |
| `WarRoom_ReportConfig_AssignGroups` | `warroom.usp_ReportAssignment_BulkUpsert` |
| `Warroom_ReportConfig_GetAssignmentModalData` | `warroom.usp_ReportConfig_GetAssignmentModalData` |
| `Warroom_ReportConfig_UnassignGroups` | `warroom.usp_ReportConfig_UnassignGroups` |
| `Warroom_SetPunchTemplateIncluded` | `warroom.usp_SetPunchTemplateIncluded` |
| `Warroom_SetPunchReportStatusIncluded` | `warroom.usp_SetPunchReportStatusIncluded` |
| `Warroom_GetOverviewSnapshot` | `warroom.usp_GetOverviewSnapshot` |
| `warroom_GenerateOverviewSnapshot` | `warroom.usp_GenerateOverviewSnapshot` |

Las filas proceden directamente de las definiciones de los workflows exportados.
