# cmp_CustomFieldsEditorPro

## Purpose

`cmp_CustomFieldsEditorPro` is the project-level premium editor for defining which Custom Fields exist for `PUNCH` records in the active PULSE project.

It is deliberately separate from `cmp_CustomFieldValuesPro`:

- `cmp_CustomFieldValuesPro` edits values for one selected Punch.
- `cmp_CustomFieldsEditorPro` edits the project definition model.

The editor does not require a selected Punch. Its required context is `ProjectId + EntityType`.

## Current backend definition contract

The component must work only with properties already supported by the backend:

- `FieldDefId`
- `ProjectId`
- `EntityType`
- `FieldKey`
- `Label`
- `FieldType`
- `HelpText`
- `IsRequired`
- `IsPinned`
- `IsActive`
- `SortOrder`
- `OptionsJson`
- `IsFilterable`
- `ShowInQuickFilters`
- `FilterOrder`
- `FilterMode`

Supported field types remain:

- Text
- Number
- Date
- YesNo
- Choice
- MultiChoice

The current contract does not include groups, regex validation, min/max constraints, default values, conditional rules or automations. Those capabilities must not be simulated in v1.

## Target UX

The component follows a three-zone configuration workspace:

1. **Catalog** — definitions, search, active/inactive, add/select.
2. **Definition editor** — supported properties for the selected field.
3. **Live preview** — visual representation of the resulting field.

Top-level actions provide close/refresh and later save/toggle operations. There is no Publish action in v1 because the backend does not expose a publish lifecycle.

## Service ownership

The host remains responsible for Power Automate calls:

- list: `WarRoom_ListCustomFieldDefs`
- upsert: `WarRoom_UpsertCustomFieldDef`
- activate/deactivate: `WarRoom_SetCustomFieldActive`

The component receives normalized definitions and emits events/outputs for the host. This keeps the reusable component independent from app-specific flow bindings.

After a successful definition mutation, the host must:

1. refresh the definition catalog;
2. invalidate Punch dynamic-filter configuration;
3. when opened from Punch Review, reload the current Punch custom bundle so the values panel reflects the new definition model.

## First consumer

Punch Review Workspace.

The `Manage` action of `cmp_CustomFieldValuesPro` will eventually open this editor as a modal layer. Punch List integration is deferred until the later modernization of that screen.

## Incremental construction

See `IMPLEMENTATION_PLAN.md`.

The current DF sequence is:

- DF-01 shell
- DF-02 catalog/search/select/add
- DF-03 definition form
- DF-04 Choice/MultiChoice options editor
- DF-05 backend host integration
- DF-06 Punch Review modal integration
- DF-07 premium polish/help/documentation

## Compatibility gate

Before creating or modifying `.pa.yaml`, always read:

`docs/development/screens/punch-review/POWER_APPS_SOURCE_CODE_COMPATIBILITY.md`

Partial property adjustments must be delivered as executable `.property-guide.md` documents rather than pseudo-`.pa.yaml` patches.