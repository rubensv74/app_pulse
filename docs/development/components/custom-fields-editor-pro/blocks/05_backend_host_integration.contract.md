# DF-05 — Backend host integration

**Type:** `I — Integration`  
**Status:** READY AFTER C16 VALIDATION — implementation not yet released.

## Gate

DF-05 is intentionally not emitted as Power Apps YAML until the immediately preceding Punch Review C16 Review Progress block is validated in Power Apps Studio.

This preserves the active rule:

`deliver -> Studio validate -> freeze -> next block`.

## Purpose

Connect `cmp_CustomFieldsEditorPro` to the existing Custom Field definition backend while keeping all Power Automate calls owned by the host screen, not by the reusable component.

## Existing backend contracts

### List definitions

`WarRoom_ListCustomFieldDefs(ProjectId, EntityType, IncludeInactive)`

Expected normalized rows:

- FieldDefId
- ProjectId
- EntityType
- FieldKey
- Label
- FieldType
- HelpText
- IsRequired
- IsPinned
- IsActive
- SortOrder
- OptionsJson
- IsFilterable
- ShowInQuickFilters
- FilterOrder
- FilterMode

### Upsert definition

`WarRoom_UpsertCustomFieldDef(...)`

DF-05 will pass only properties already supported by the current definition contract. It will not invent groups, regex rules, min/max lengths, defaults or automation metadata.

### Activate / deactivate definition

`WarRoom_SetCustomFieldActive(ProjectId, EntityType, FieldKey, IsActive, UserEmail)`

## Host responsibilities

The host must own:

- loading definitions;
- saving/upserting the current draft;
- active/inactive mutation;
- loading/saving/error state;
- server-authoritative refresh after mutation;
- setting `varPunchDynamicFilters_NeedRefresh=true` after a definition mutation;
- user notifications;
- permission enforcement.

The reusable component remains responsible only for definition presentation, local draft editing, validation state and host events/contracts.

## Frozen during DF-05

DF-05 must not redesign:

- `cmp_CustomFieldsEditorPro` three-column geometry;
- Field Catalog layout;
- Field Configuration layout;
- Live Preview layout;
- Choice/MultiChoice visual options editor;
- component color layer;
- Punch Review Comments;
- Punch Review Review Progress.

## Expected implementation split

To preserve one dominant purpose per block, DF-05 should be delivered as small integration increments if necessary:

- `DF-05A` — host definition load;
- `DF-05B` — host upsert/save;
- `DF-05C` — host active/inactive mutation + authoritative reload;
- `DF-05D` — dynamic-filter invalidation and final integration validation.

If one coherent block remains small and independently verifiable, these may be consolidated, but no visual redesign is allowed inside the integration increment.

## Validation

With a real project and `EntityType="PUNCH"`:

1. host load returns current definitions into the component;
2. Add creates a real definition and authoritative reload shows it;
3. Edit updates an existing supported definition;
4. Choice/MultiChoice `OptionsJson` round-trips correctly;
5. Active/inactive changes persist and reload correctly;
6. backend errors are shown without destroying the local component;
7. dynamic Punch filters are marked for refresh after successful definition mutation;
8. no definition Flow is called directly from inside the component.

## Expected status after successful DF-05

```text
COMPONENT STRUCTURE   FUNCTIONAL_FROZEN
LOCAL BEHAVIOR        FUNCTIONAL_FROZEN
BACKEND INTEGRATION   FUNCTIONAL_FROZEN
COLOR                  PENDING
```
