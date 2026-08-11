# Custom Fields — Architecture Refactor Plan

**Status:** approved direction — planning baseline  
**Primary screen:** Punch Review Workspace  
**Deferred consumer:** Punch List  
**Date:** 2026-08-11

## 1. Decision

Custom Fields are split into two independent responsibilities:

1. **Record values** — current values of the Custom Fields for one selected Punch.
2. **Project definitions** — configuration of which Custom Fields exist for PUNCH records in the current project.

These responsibilities must not share one drawer or one editor component.

## 2. Target components

### 2.1 `cmp_CustomFieldValuesPro`

Purpose: compact premium panel for the current Punch.

Responsibilities:

- receive the merged field/value rows for the selected Punch;
- show field label + current value in a compact two-column/list presentation;
- support the existing field types: Text, Number, Date, YesNo, Choice, MultiChoice;
- allow value editing for authorized users;
- expose dirty state and dirty payload;
- expose Save / Cancel or Reset events to the host;
- expose optional Manage Fields request event, without implementing definition management itself;
- represent Loading / Empty / Ready / Unsaved / Saving / Error.

It does **not** load definitions, create fields, activate fields or edit filter behavior.

### 2.2 `cmp_CustomFieldsEditorPro`

Purpose: project-level modal for defining the Custom Fields used by PUNCH records.

Responsibilities:

- display the project Custom Field definition catalog;
- search fields;
- show active/inactive definitions;
- add a definition;
- edit a definition;
- enable/disable a definition;
- edit only properties supported by the current backend contract;
- provide a live visual preview where feasible;
- expose host events for load/save/toggle operations, unless a later validated implementation deliberately centralizes the services inside the component.

This editor is **project-level**, not Punch-level. Opening it must require project context, not a selected Punch.

## 3. Existing backend contracts retained

### Record values

Load:

`WarRoom_GetCustomBundle(ProjectId, EntityType, RecordId)`

Save:

`WarRoom_SaveCustomBulk(ProjectId, EntityType, RecordId, DirtyJson, UserEmail)`

The merged server response remains authoritative after save.

### Definitions

List:

`WarRoom_ListCustomFieldDefs(ProjectId, EntityType, IncludeInactive)`

Upsert:

`WarRoom_UpsertCustomFieldDef(...)`

Current supported definition properties:

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

Enable/disable:

`WarRoom_SetCustomFieldActive(ProjectId, EntityType, FieldKey, IsActive, UserEmail)`

Definition changes must mark Punch dynamic filters for refresh because Punch List derives dynamic filters from active/filterable definitions.

## 4. Punch Review target layout

The right column remains structurally simple:

- Comments
- Custom Field Values
- Review Progress

The current `conPR_CustomFieldsCard` is refactored into an instance of `cmp_CustomFieldValuesPro`.

The screen retains its existing host service controls and authoritative collections during the migration:

- `btnPR_LoadCustomFields`
- `btnPR_SaveCustomFields`
- `colPunchReviewFieldsUI`
- `colPunchReviewFieldsBase`
- `colPunchReviewFieldsDirty`
- `varPunchReviewDirty`
- `varPunchReviewFieldsLoading`
- `varPunchReviewFieldsSaving`
- `varPunchReviewFieldsError`

Block 13 Dirty Guard remains authoritative and must not regress.

For managers, Punch Review will expose a `Manage fields` action that opens `cmp_CustomFieldsEditorPro`. That action only opens the project definition editor; it does not mix definition controls into the values panel.

After a successful definition change, Punch Review reloads the current Punch custom bundle so newly added/changed definitions are reflected immediately.

## 5. Punch List target direction — deferred

Punch List is intentionally not redesigned during this refactor.

Current behavior is preserved temporarily:

- selecting a grid row opens `cmp_DetailDrawer_old`;
- the drawer contains Overview, Comments, Custom values and Manage Fields responsibilities.

Later Punch List work will separate these concerns:

- row selection should select the Punch without automatically opening a large legacy drawer;
- project-level `Manage custom fields` will open the same `cmp_CustomFieldsEditorPro` used by Punch Review;
- a future Punch List detail experience can replace the remaining drawer responsibilities;
- `cmp_DetailDrawer_old` is retired only after all required behaviors have explicit replacements.

The project-definition modal does not require a selected Punch and therefore can be opened from Punch List toolbar/header context.

## 6. Visual direction

### Values panel

Reference: compact card/list pattern.

- dense but readable rows;
- field label on the left;
- current value/editor on the right;
- subtle dividers;
- minimal metadata;
- Save / Cancel or Reset grouped in a compact footer;
- no technical definition controls in this card.

### Definition editor modal

Reference: three-zone project configuration workspace.

- left: field catalog, search, active state, add field;
- center: selected field definition editor;
- right: live preview;
- top actions: Save/Publish only where supported by the actual contract.

The visual reference includes capabilities such as groups, regex validation, min/max, default values and automation rules. These are **not** part of the current backend contract and are therefore excluded from v1 unless backend support is added explicitly later.

## 7. Components and artifacts to retire or freeze

### `cmp_CustomFieldEditor`

Legacy/simple value editor. It renders a generic text input and does not cover the full multitype contract. Do not extend it.

### `cmp_CustomFieldEditorPro`

The CF-01/CF-02/CF-03 prototype was built under the incorrect assumption that this name represented the Punch Review values editor. Freeze it as an abandoned prototype and do not continue CF-04.

### `cmp_DetailDrawer_old`

Legacy aggregate drawer. Freeze feature development. Keep it operational in Punch List until replacement work reaches that screen.

## 8. Incremental roadmap

### VF-01 — Values component shell

Create `cmp_CustomFieldValuesPro` with compact header/body/footer and input/output contract only.

### VF-02 — Value renderers

Implement Text, Number, Date, YesNo, Choice and MultiChoice presentation/editors.

### VF-03 — Dirty state and host events

Implement local dirty tracking and Save/Cancel/Reset/Refresh/ManageFields requested events.

### VF-04 — Punch Review integration

Replace the current Custom Fields visual implementation while retaining existing load/save services and Dirty Guard.

### VF-05 — Punch Review visual polish

Validate the complete right column with Comments + Values + Review Progress at target desktop sizes.

### DF-01 — Definition editor shell

Create `cmp_CustomFieldsEditorPro` modal shell with catalog / editor / preview regions.

### DF-02 — Definition catalog

Load/search active and inactive definitions; select, add and toggle definitions.

### DF-03 — Definition form

Edit the currently supported definition properties only.

### DF-04 — Choice/MultiChoice options

Provide a maintainable options editor that produces the existing `OptionsJson` contract without requiring users to edit raw JSON.

### DF-05 — Save/toggle integration

Connect existing list/upsert/set-active contracts and refresh the definition catalog after mutations.

### DF-06 — Punch Review modal integration

Open the editor from Punch Review for authorized users, then refresh current values after definition changes.

### DF-07 — Premium polish + documentation

Responsive layout, preview, empty/loading/error states, user help and component documentation.

### PL-01 and later — Punch List modernization

Deferred until Punch Review and both components are stable. Add the shared definition editor entry point first; redesign row selection/drawer separately.

## 9. Gates

- Block 16 remains paused until the Punch Review Custom Fields refactor is stable.
- No more work is performed on the abandoned CF-04 path.
- Before every future `.pa.yaml`, read `docs/development/screens/punch-review/POWER_APPS_SOURCE_CODE_COMPATIBILITY.md`.
- Each component increment is validated in Studio before the next increment.
- Do not modify Punch List architecture until the values component and definition editor are validated from Punch Review.
