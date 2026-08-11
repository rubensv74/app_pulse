# DF-05 — Backend host integration

**Type:** `I — Integration`  
**Status:** IN PROGRESS — DF-05A published, pending Studio validation.

## Gate

The preceding Punch Review C16 Review Progress block has been visually accepted in Power Apps Studio. DF-05 may therefore proceed incrementally under the active rule:

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

## Increment plan

- `DF-05A` — host definition load — **PUBLISHED / PENDING STUDIO VALIDATION**;
- `DF-05B` — host upsert/save — blocked until DF-05A validation;
- `DF-05C` — host active/inactive mutation + authoritative reload — blocked;
- `DF-05D` — dynamic-filter invalidation and final integration validation — blocked.

## DF-05A artifacts

- `05A_definition_load.add-child.pa.yaml`
- `05A_manage_load_trigger.property-guide.md`

DF-05A deliberately loads **active and inactive** PUNCH definitions (`IncludeInactive = 1`) because the component owns the local Active only / Show inactive view.

The established backend response shape is preserved:

`resp.result -> outer array -> First(...).Value.result -> bundle.defs`.

The normalized collection is:

`colPunchReviewFieldDefsAdmin`.

The host state variables are:

- `varPunchReviewFieldDefsLoading`;
- `varPunchReviewFieldDefsError`.

No modal is introduced in DF-05A. The current Manage event is temporarily used as a validation trigger; DF-06 will replace that temporary notification lifecycle with the real `cmp_CustomFieldsEditorPro` modal.

## Validation

With a real project and `EntityType="PUNCH"`:

1. DF-05A host load returns current definitions into `colPunchReviewFieldDefsAdmin`;
2. active and inactive definitions are both available;
3. backend errors are exposed through `varPunchReviewFieldDefsError` without changing screen geometry;
4. no definition Flow is called directly from inside a reusable component;
5. after DF-05B, Add/Edit must persist and authoritative reload must show the result;
6. after DF-05C, Active/inactive changes must persist and reload correctly;
7. Choice/MultiChoice `OptionsJson` must round-trip correctly;
8. after successful definition mutation, dynamic Punch filters must be marked for refresh.

## Expected status after successful DF-05

```text
COMPONENT STRUCTURE   FUNCTIONAL_FROZEN
LOCAL BEHAVIOR        FUNCTIONAL_FROZEN
BACKEND INTEGRATION   FUNCTIONAL_FROZEN
COLOR                  PENDING
```
