# PULSE Power Automate Coverage Register

**Status:** active  
**Canonical:** yes  
**Last reviewed:** 2026-08-10

This register tracks active Power Automate calls observed in the current canonical Power Apps screen sources and whether the real flow definition has been synchronized into `power-automate/flows/`.

The current scan covers:

```text
power-apps/screens/Home/scr_Home.pa.yaml
power-apps/screens/Punches/scr_Punches_1.pa.yaml
power-apps/screens/PunchReview/scr_PunchReview.pa.yaml
```

It is a repository coverage register, not a replacement for the Power Automate environment.

## Status values

```text
CALL_CONFIRMED        runtime caller observed in canonical Power Apps source
DEFINITION_MISSING    real flow definition not yet versioned in power-automate/flows/
DEFINITION_CAPTURED   real exported/deployable definition versioned
VALIDATED             definition + caller contract validated against real environment
```

## Current caller inventory

| Flow | Home | Punches | Punch Review | Repository definition status |
|---|---:|---:|---:|---|
| `Warroom_AddTaskComment` | yes | no confirmed call in current scan | yes | DEFINITION_MISSING |
| `WarRoom_SaveCustomBulk` | yes | no confirmed call in current scan | no confirmed call in current scan | DEFINITION_MISSING |
| `WarRoom_GetCustomBundle` | yes | yes | no confirmed call in current scan | DEFINITION_MISSING |
| `Warroom_GetTaskCommentsPaged` | yes | yes | yes | DEFINITION_MISSING |
| `WarRoom_ListCustomFieldDefs` | yes | yes | no confirmed call in current scan | DEFINITION_MISSING |
| `WarRoom_SetCustomFieldActive` | yes | yes | no confirmed call in current scan | DEFINITION_MISSING |
| `WarRoom_UpsertCustomFieldDef` | yes | yes | no confirmed call in current scan | DEFINITION_MISSING |
| `Warroom_GetProjectPunchTemplates` | yes | no confirmed call in current scan | no confirmed call in current scan | DEFINITION_MISSING |
| `warroom_GetPunchDashboardBundle` | yes | no confirmed call in current scan | no confirmed call in current scan | DEFINITION_MISSING |
| `Warroom_GetPendingSubsystemsByDiscipline` | yes | no confirmed call in current scan | no confirmed call in current scan | DEFINITION_MISSING |
| `warroom_GetPunchDashboardCellDetails` | yes | no confirmed call in current scan | no confirmed call in current scan | DEFINITION_MISSING |
| `Warroom_Punches_GetFilterCatalogs` | no confirmed call in current scan | yes | no confirmed call in current scan | DEFINITION_MISSING |
| `Warroom_Punches_Filtered_Paged` | no confirmed call in current scan | yes | no confirmed call in current scan | DEFINITION_MISSING |
| `Warroom_ExportPunchesToExcel_Codex` | no confirmed call in current scan | yes | no confirmed call in current scan | DEFINITION_MISSING |

`no confirmed call in current scan` means only that the scanned canonical screen did not expose that flow call in the current source review. It must not be interpreted as proof that no other PULSE artifact uses the flow.

## Synchronization order

Prioritize capture according to active feature work and runtime criticality rather than alphabetical order.

For each flow:

```text
1. locate the real active flow in Power Automate
2. confirm display name/environment/current active version
3. export/read real definition
4. store canonical definition under power-automate/flows/
5. confirm input names/order/types against current callers
6. confirm response/error contract
7. link relevant SQL/Office Script dependencies
8. validate in Power Automate
9. change status to VALIDATED
```

Never set `DEFINITION_CAPTURED` or `VALIDATED` based only on inferred caller code.
