# cmp_CustomFieldsEditorPro — Incremental Implementation Plan

## Status

- `DF-01` — published; continuation explicitly authorized by the user, while Studio validation remains authoritative.
- `DF-02` — published; continuation to DF-03 explicitly authorized by the user.
- `DF-03` — published with mandatory DF-03A draft-initialization property guide; continuation to DF-04 explicitly authorized by the user.
- `DF-04` — published with mandatory DF-04A options-state property guide; pending Power Apps Studio validation.
- `DF-05` and later — blocked until DF-04 + DF-04A are accepted in Studio or any reported issue is corrected.

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

Artifact:

`blocks/02_definition_catalog.replace-control.pa.yaml`

Objective: turn the left zone into the project definition catalog without calling backend services.

Includes:

- local selected `FieldKey` through component-scoped `Set()` state;
- local edit mode `EDIT` / `ADD` prepared for DF-03;
- active-only / include-inactive view;
- search by Label or FieldKey;
- sort by SortOrder;
- selected-row visual state;
- Add new definition local action plus existing `OnAddRequested` host event;
- loading, empty and error catalog states;
- compact metadata for type / required / pinned / active state.

No new output property is required in DF-02 because DF-03 is inside the same component and can consume the component-scoped selection state directly. Host-facing save/toggle contracts are introduced only when their behavior is required.

Gate DF-02:

- Studio accepts the replacement control without Source Code or formula errors;
- with DF-01A seed, six definitions appear when inactive definitions are included;
- active-only hides the inactive Target Date definition;
- search works by Label and FieldKey;
- rows remain sorted by SortOrder;
- clicking a row highlights one definition and establishes `EDIT` mode;
- + Add establishes `ADD` mode and raises `OnAddRequested`;
- empty/loading/error states render intentionally;
- no flow is called.

## DF-03 — Definition form

Artifacts:

- `blocks/03_field_configuration.replace-control.pa.yaml`
- `blocks/03A_definition_draft_initialization.property-guide.md`

Objective: replace the center placeholder with a typed local definition form using only properties supported by the current backend contract.

Includes:

- local draft initialization for Add and Edit;
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
- local `Modified / Loaded / New draft` state;
- deterministic typed variables for draft fields;
- filter dependency: disabling Filterable clears/disables Quick filter;
- explicit empty state when no catalog row is selected;
- no flow calls;
- no raw OptionsJson editing.

Conservative rules:

- existing `FieldKey` is read-only;
- existing `FieldType` is read-only;
- new definitions may set FieldKey and FieldType;
- FilterMode is limited to the currently confirmed values `Equals` and `Contains`;
- Choice/MultiChoice options remain deferred to DF-04.

Gate DF-03:

- apply DF-03A first so catalog selection initializes the draft;
- Studio accepts `conCFDEPro_Editor` replacement without Source Code/formula errors;
- selecting a seeded field populates the form and shows `Loaded`;
- changing any supported property changes state to `Modified`;
- selecting another field replaces the draft deterministically;
- + Add creates blank/default local state and shows `New draft`;
- FieldKey/FieldType are editable only in ADD mode;
- Filterable=false clears/disables Quick filter;
- Choice/MultiChoice display the DF-04 options notice rather than exposing JSON;
- no backend service is invoked.

## DF-04 — Choice / MultiChoice options editor

Artifacts:

- `blocks/04_choice_options_editor.replace-control.pa.yaml`
- `blocks/04A_choice_options_state.property-guide.md`

Objective: maintain the existing `OptionsJson` contract without exposing raw JSON to the user.

Implementation:

- DF-04A converts the stored JSON string array into a human-readable one-option-per-line local state when a definition is selected;
- new Choice/MultiChoice definitions start with an empty options list;
- switching a new definition between Choice and MultiChoice preserves its option lines;
- switching a new definition to a non-choice type clears options and normalizes `OptionsJson` to `[]`;
- DF-04 replaces the informational DF-03 notice with a compact multiline options editor;
- one line represents one option, so add/remove/reorder are performed by adding/removing/moving lines;
- blank lines are ignored during serialization;
- each option is serialized with `JSON(Trim(Value), JSONFormat.Compact)` and concatenated into the existing JSON string-array contract;
- no raw JSON is displayed or edited;
- no backend flow is called.

Why the line-based editor is used in v1:

- it supports add/remove/reorder with control types already validated in PULSE;
- it avoids introducing an unvalidated horizontal-gallery pattern or secondary modal;
- it directly eliminates the manual JSON-editing UX from the legacy drawer;
- it preserves option order explicitly through line order.

Gate DF-04:

- apply DF-04A before the control replacement;
- Studio accepts `conCFDEPro_OptionsNotice` -> `conCFDEPro_OptionsEditor` without Source Code/formula errors;
- seeded Choice/MultiChoice definitions round-trip from OptionsJson into visible lines;
- non-choice fields hide the editor;
- add/remove/reorder lines changes local draft state and serialized order;
- blank lines do not generate empty JSON entries;
- quotes/special characters do not break serialization because `JSON()` performs escaping;
- no backend service is invoked.

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
- Partial property adjustments are delivered as executable `.property-guide.md` files.
- Do not start the next DF increment while the current one has an unresolved Studio error.
