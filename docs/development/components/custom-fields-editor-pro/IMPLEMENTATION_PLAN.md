# cmp_CustomFieldsEditorPro — Incremental Implementation Plan

## Status

- `DF-01` — published; pending Power Apps Studio validation.
- `DF-02` and later — blocked until DF-01 is accepted by Power Apps Studio.

## DF-01 — Definition editor shell

Objective: validate the new `cmp_CustomFieldsEditorPro` component definition and its three-zone premium workspace before adding catalog logic, draft state or backend operations.

Includes:

- new CanvasComponent definition;
- normalized `Definitions` input table using the confirmed backend schema;
- `ProjectId`, `EntityType`, `ProjectLabel`, permission/loading/saving/error inputs;
- outputs `HasDefinitions` and `DefinitionCount`;
- events `OnClose`, `OnRefresh`, `OnAddRequested`;
- premium header;
- catalog/editor/preview regions;
- explicit loading/error/ready status in the shell;
- no flow calls;
- no internal definition draft yet;
- no Punch Review integration yet.

Gate:

- Studio accepts the full component definition with no Source Code errors;
- three zones render without overlap at approximately 1000–1280 px width;
- `DefinitionCount` reacts to `Definitions`;
- close/refresh/add host events can be assigned on a temporary instance;
- no backend or Punch selection is required.

## DF-02 — Catalog / search / select / add

Objective: turn the left zone into the project definition catalog.

Includes:

- internal selected FieldKey;
- active-only / include-inactive view;
- search by Label or FieldKey;
- sort by SortOrder;
- selected-row state;
- Add new definition local action;
- output/event contract needed by the later host integration.

Gate: catalog remains stable with empty, small and large definition sets and selection does not require a flow call.

## DF-03 — Definition form

Objective: edit the selected definition using only properties supported by the current backend.

Includes:

- FieldKey;
- Label;
- FieldType;
- HelpText;
- IsRequired;
- IsPinned;
- IsActive;
- SortOrder;
- IsFilterable;
- ShowInQuickFilters;
- FilterOrder;
- FilterMode;
- validation and draft dirty state.

FieldKey mutability for existing definitions must follow the actual backend/host behavior validated during integration; do not assume it is safely renamable.

Gate: Add/Edit drafts are typed, deterministic and do not invent unsupported metadata.

## DF-04 — Choice / MultiChoice options editor

Objective: maintain `OptionsJson` without making users edit raw JSON.

Includes:

- list of options;
- add/remove option;
- reorder if safely implementable;
- serialization to the existing `OptionsJson` string-array contract using Power Fx `JSON(...)` patterns rather than manual quote escaping.

Gate: generated OptionsJson round-trips through existing data without parser errors.

## DF-05 — Backend host integration

Objective: connect the component to the existing definition flows while preserving service ownership in the host.

Contracts:

- `WarRoom_ListCustomFieldDefs(ProjectId, EntityType, IncludeInactive)`;
- `WarRoom_UpsertCustomFieldDef(...)`;
- `WarRoom_SetCustomFieldActive(ProjectId, EntityType, FieldKey, IsActive, UserEmail)`.

After mutation:

- reload catalog;
- mark Punch dynamic filters for refresh;
- preserve backend response as authoritative.

Gate: list/upsert/toggle work with real project data and error states remain actionable.

## DF-06 — Punch Review modal integration

Objective: make `cmp_CustomFieldValuesPro.OnManageFieldsRequested` open `cmp_CustomFieldsEditorPro` from Punch Review for authorized users.

Includes:

- modal layer;
- ProjectId + EntityType=PUNCH context;
- close/reopen lifecycle;
- definition refresh after save/toggle;
- reload current Punch custom bundle after successful definition change.

Gate: definition changes are visible in the current Punch values panel after closing/refreshing the modal.

## DF-07 — Premium polish, accessibility, help and documentation

Objective: finish the reusable configuration experience.

Includes:

- responsive behavior;
- keyboard/focus behavior;
- empty/loading/error/saving states;
- refined live preview;
- bilingual Punch Review help entry where appropriate;
- Spanish user manual updates;
- reusable component documentation;
- consolidation decision for canonical component source.

Any partial property tuning in this phase must be delivered as `.property-guide.md`, not pseudo-`.pa.yaml`.

## Policy

- Read `POWER_APPS_SOURCE_CODE_COMPATIBILITY.md` immediately before every `.pa.yaml` delivery.
- Studio validation is authoritative.
- Do not introduce unsupported definition properties.
- Do not call flows directly from the reusable component in v1.
- Do not start the next DF increment while the current one has an unresolved Studio error.