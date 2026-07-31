# Canvas App flow-reference inventory — 1.0.0.2

The app contains 73 unique `shared_logicflows` data-source rows.

| Classification | Count | Evidence/action |
|---|---:|---|
| INCLUDED_IN_SOLUTION | 63 | Exact case-insensitive name match to workflow root component |
| HISTORICAL_REFERENCE | 7 | `_1`/`_2` duplicate registry entries with zero source use |
| UNRESOLVED | 3 | Active source use but no matching workflow name or FlowNameId in package |

## Historical references

`WarRoom_Admin_Roles_Get_1`, `WarRoom_Admin_Roles_Get_2`, `WarRoom_Admin_UserProjectRole_Upsert_1`, `WarRoom_AttentionQueue_GetActive_1`, `WarRoom_AttentionQueue_GetHistory_1`, `WarRoom_AttentionQueue_SearchSubsystems_1`, `WarRoom_AttentionQueue_UpdateReason_1`. These have zero formula-source occurrences and coexist with included unsuffixed counterparts; classification is `HISTORICAL_REFERENCE`, with cleanup recommended later.

## Critical unresolved references

| Flow referenced | Included | Classification | Evidence | Action |
|---|---:|---|---|---|
| `Warroom_AddTaskComment` | No | UNRESOLVED | Two source uses; FlowNameId `95c70ac4-2113-4be9-bcba-2b63f482b259` absent from package | Rebind/export exact flow or prove identity mapping to included `Warroom_AddComment` |
| `Warroom_GetTaskCommentsPaged` | No | UNRESOLVED | Ten source uses; FlowNameId `ff899eac-2d44-4afd-b1c3-53b88dc26e19` absent | Rebind/export exact flow or prove mapping to `Warroom_GetCommentsPaged` |
| `PowerAppV2->Executestoredprocedure(V2),RespondtoaPowerApp...` | No | UNRESOLVED | One source use; FlowNameId `a8a892a2-75f4-4461-8127-8af7d60a4fef` absent | Rename/rebind or prove mapping to `Warroom_DeleteComment` |

Similar included names are not accepted as equivalence because their entity GUIDs and the app FlowNameIds do not correlate physically. The 63 exact matches comprise all remaining app references, including `_Codex` and dashboard bundle.
