# Pantalla → flow

Baseline parcial: `baseline_pulse_1_0_0_5.zip`.

## Configuración

| Pantalla | Flow observado |
|---|---|
| `scr_Config` | `WarRoom_ReportConfig_GetTree` |
| `scr_Config` | `WarRoom_ReportConfig_GetAssignments` |
| `scr_Config` | `WarRoom_ReportConfig_GetScope` |
| `scr_Config` | `WarRoom_ReportConfig_AssignGroups` |
| `scr_Config` | `Warroom_ReportConfig_GetAssignmentModalData` |
| `scr_Config` | `Warroom_ReportConfig_UnassignGroups` |
| `scr_Config` | `Warroom_GetProjectPunchTemplates` |
| `scr_Config` | `Warroom_GetPunchReportStatusConfig` |
| `scr_Config` | `Warroom_SetPunchTemplateIncluded` |
| `scr_Config` | `Warroom_SetPunchReportStatusIncluded` |
| `scr_Config` | `warroom_GenerateOverviewSnapshot` |

## Overview actual

| Pantalla | Flow observado |
|---|---|
| `scr_Overview` | `Warroom_GetOverviewSnapshot` |
| `scr_Overview` | `warroom_GenerateOverviewSnapshot` |
| `scr_Overview` | `WarRoom_Operations_RefreshCellCache` |

`scr_Overview_PDS` todavía no invoca flows en el baseline: OPDS-C01 contiene únicamente superficies visuales.
