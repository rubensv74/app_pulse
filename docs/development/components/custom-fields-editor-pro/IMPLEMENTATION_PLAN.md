# cmp_CustomFieldsEditorPro — Incremental Implementation Plan

## Status

- `DF-01` — published; continuation explicitly authorized by the user, while Studio validation remains authoritative.
- `DF-02` — published; continuation to DF-03 explicitly authorized by the user.
- `DF-03` — published with mandatory DF-03A draft-initialization property guide; continuation to DF-04 explicitly authorized by the user.
- `DF-04` — published with mandatory DF-04A options-state property guide.
- `DF-04B` — published as full replacement of `conCFDEPro_Editor` to refine hierarchy, toggle ownership, Filtering and Options UX after visual validation in Studio.
- `DF-04C` — published as full replacement of `conCFDEPro_Preview` to convert the static preview into a live draft-driven preview.
- `DF-04D-FIX` — component structure consolidated and visually accepted in Studio; current working geometry frozen.
- `DF-05A` — host definition-load service published and continuation to DF-05B explicitly requested by the user.
- `DF-05B` — host upsert/save service published; pending Studio validation. End-to-end write remains pending until DF-06 wires the editor draft to the host service.
- `DF-05C` and later — blocked until DF-05B has no Studio errors.

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
- one line represents one option, so add/remove/reorder are performed by adding/removing/moving lines;
- blank lines are ignored during serialization;
- each option is serialized with `JSON(Trim(Value), JSONFormat.Compact)` and concatenated into the existing JSON string-array contract;
- no raw JSON is displayed or edited;
- no backend flow is called.

## DF-04B — Field configuration visual refinement

Artifact:

`blocks/04B_field_configuration_refined.replace-control.pa.yaml`

Triggered by Studio visual validation after DF-04.

Objective: replace the entire center editor rather than applying a fragile set of isolated property tweaks.

Changes:

- groups Requirement / Pinning / Availability into a single Behavior subpanel so each switch has an unambiguous owner;
- groups Filterable / Quick filter / Filter mode / Filter order into a dedicated Filtering subpanel;
- compresses General fields without removing any supported property;
- increases the Choice/MultiChoice Options editor to 92 px and keeps a visible option count;
- keeps raw JSON hidden;
- preserves all DF-03A / DF-04A draft variables and host ownership of backend operations.

Gate DF-04B:

- Studio accepts the complete `conCFDEPro_Editor` replacement;
- all draft properties still load and edit correctly;
- switch/text ownership is visually clear;
- Filterable=false disables Quick filter and filter controls;
- Choice/MultiChoice options are readable without immediate scrolling for small option sets;
- OptionsJson remains synchronized;
- no flow is called.

## DF-04C — Dynamic live preview

Artifact:

`blocks/04C_live_preview_dynamic.replace-control.pa.yaml`

Objective: replace the static `Sample field` preview with a useful local preview driven by the current draft.

Preview reacts to:

- Label;
- FieldType;
- HelpText;
- Required;
- Pinned;
- Active;
- option count for Choice/MultiChoice;
- FieldKey;
- filterability, FilterMode, FilterOrder and Quick Filter state.

The input representation changes by type for Text, Number, Date, YesNo, Choice and MultiChoice. The preview is intentionally local and does not write record data.

Gate DF-04C:

- Studio accepts the complete `conCFDEPro_Preview` replacement;
- selecting or editing a definition updates the preview immediately;
- Choice/MultiChoice option count follows the local options draft;
- empty selection shows the intentional empty state;
- no backend service is invoked.

## DF-05 — Backend host integration

Objective: connect the component to the existing definition flows while preserving service ownership in the host.

Contracts:

- `WarRoom_ListCustomFieldDefs(ProjectId, EntityType, IncludeInactive)`;
- `WarRoom_UpsertCustomFieldDef(...)`;
- `WarRoom_SetCustomFieldActive(ProjectId, EntityType, FieldKey, IsActive, UserEmail)`.

### DF-05A — Host definition load

Artifacts:

- `blocks/05A_definition_load.add-child.pa.yaml`
- `blocks/05A_manage_load_trigger.property-guide.md`
- `blocks/05A_orden_implementacion.guia.md`

Result:

- `btnPR_LoadCustomFieldDefs` owns the read Flow;
- definitions are normalized into `colPunchReviewFieldDefsAdmin`;
- active and inactive definitions are loaded together;
- component remains flow-free.

### DF-05B — Host definition upsert/save

Artifacts:

- `blocks/05B_host_save_runtime.property-guide.md`
- `blocks/05B_definition_upsert.add-child.pa.yaml`
- `blocks/05B_GUIA_IMPLEMENTACION_Y_VALIDACION.md`

Result:

- typed host staging variables `varPunchReviewDef_*`;
- hidden service `btnPR_SaveCustomFieldDef`;
- validation of project, permission, Label, FieldKey, duplicate key, SortOrder and Choice/MultiChoice options;
- write through `WarRoom_UpsertCustomFieldDef` using the confirmed legacy parameter order;
- authoritative definition reload after success;
- current Punch Custom Field bundle refresh after success when applicable;
- `varPunchDynamicFilters_NeedRefresh=true` after mutation.

Important: the reusable component still does not call the Flow. DF-06 will wire its draft outputs/event into the host staging variables and then call `Select(btnPR_SaveCustomFieldDef)`.

DF-05B gate:

- Studio accepts host runtime and hidden save service without formula or Source Code errors;
- all `varPunchReviewDef_*` names are recognized;
- `WarRoom_UpsertCustomFieldDef` is recognized;
- no screen geometry changes;
- end-to-end write is completed only after DF-06 wiring with a real controlled definition.

### DF-05C — Active/inactive mutation

Blocked until DF-05B has no Studio errors.

### DF-05D — Final backend integration validation

Blocked until DF-05C.

After mutation:

- reload catalog;
- mark Punch dynamic filters for refresh;
- preserve backend response as authoritative.

## DF-06 — Punch Review modal integration

Objective: make `cmp_CustomFieldValuesPro.OnManageFieldsRequested` open `cmp_CustomFieldsEditorPro` from Punch Review for authorized users.

Includes:

- modal layer;
- ProjectId + EntityType=PUNCH context;
- close/reopen lifecycle;
- definition refresh after save/toggle;
- reload current Punch custom bundle after successful definition change;
- copy component draft outputs into `varPunchReviewDef_*` immediately before calling `btnPR_SaveCustomFieldDef`.

Gate: definition changes are visible in the current Punch values panel after closing/refreshing the modal.

## DF-07 — Premium polish, accessibility, help and documentation

Objective: finish the reusable configuration experience.

Includes:

- responsive behavior;
- keyboard/focus behavior;
- empty/loading/error/saving states;
- final visual polish;
- bilingual Punch Review help entry where appropriate;
- Spanish user manual updates;
- reusable component documentation;
- consolidation decision for canonical component source.

Any partial property tuning in this phase must be delivered as `.property-guide.md`, not pseudo-`.pa.yaml`.

## Policy

- Read `POWER_APPS_SOURCE_CODE_COMPATIBILITY.md` immediately before every `.pa.yaml` delivery.
- Read `30-playbooks/power-platform/modular-power-apps-screen-construction.md` before every new YAML block.
- Studio validation is authoritative.
- Do not introduce unsupported definition properties.
- Do not call flows directly from the reusable component in v1.
- Partial property adjustments are delivered as executable `.property-guide.md` files.
- Complete structural replacements are delivered as valid `.pa.yaml` controls.
- Do not start the next DF increment while the current one has an unresolved Studio error.
