# Punch Review Workspace — Incremental Construction

**Status:** active development workspace  
**Canonical runtime screen:** `power-apps/screens/PunchReview/scr_PunchReview.pa.yaml`  
**Construction workspace:** `docs/development/screens/punch-review/`

This workspace contains incremental blocks for building and evolving `scr_PunchReview` in Power Apps Studio without replacing the complete screen blindly.

## Canonical-source rule

`power-apps/screens/PunchReview/scr_PunchReview.pa.yaml` is the canonical complete screen source.

Files under `docs/development/screens/punch-review/blocks/` and the dedicated component workspaces are controlled construction artifacts. They do not replace canonical source until the relevant increment has been validated and consolidated.

## Mandatory compatibility gate

Before drafting, correcting or publishing any `.pa.yaml`, consult:

`docs/development/screens/punch-review/POWER_APPS_SOURCE_CODE_COMPATIBILITY.md`

Do not work from memory. Every confirmed Studio incompatibility must become a preventive rule before dependent blocks continue.

## Current screen block sequence

1. `01_screen_shell.pa.yaml` — validated
2. `02_header_premium.children.pa.yaml` — validated
3. `03_workspace_layout.children.pa.yaml` — validated
4. `04_runtime_state.onvisible.pa.yaml` — validated after typed correction
5. `05_review_queue.replace-control.pa.yaml` — validated
6. `05A_review_queue_test_seed.optional.powerfx` — optional test seed
7. `06_punch_overview.replace-control.pa.yaml` — validated
8. `07_review_actions.replace-control.pa.yaml` — validated
9. `08_session_activity.replace-control.pa.yaml` — validated
10. `08A_help_trigger.add-child.pa.yaml` — validated after removing `Reset(TabList)`
11. `08B_bilingual_help_modal.add-screen-child.pa.yaml` — validated
12. `09_comments.replace-control.pa.yaml` — integrated; real-Punch flow validation required
13. `09A_comments_selection_hook.replace-formula.powerfx` — comments selection hook
14. `09B_comments_test_seed.optional.powerfx` — optional visual test seed
15. `09C_help_comments.incremental-patch.pa.yaml` — comments help
16. `10_custom_fields.replace-control.pa.yaml` — integrated legacy values implementation; VF-04 now replaces its visual responsibility
17. `10A_custom_fields_selection_hook.replace-formula.powerfx` — superseded later by Dirty Guard routing
18. `10B_custom_fields_test_seed.optional.powerfx` — optional field-type seed
19. `10C_yesno_initial_state.incremental-patch.pa.yaml` — Toggle `Checked` binding correction
20. `10D_help_custom_fields.incremental-patch.pa.yaml` — custom-fields help
21. `11_review_progress.replace-control.pa.yaml` — implemented with installed `cmp_DonutPro`; continuation approved
22. `11A_help_review_progress.incremental-patch.pa.yaml` — review-progress help
23. `12_related_queue_context.replace-control.pa.yaml` — integrated path completed; continuation approved
24. `12A_help_related_queue_context.incremental-patch.pa.yaml` — related-context help
25. `13_dirty_guard_modal.add-screen-child.pa.yaml` — integrated path completed; continuation approved
26. `13A_dirty_guard_runtime_state.incremental-patch.powerfx` — typed guard runtime state
27. `13B_dirty_guard_selection_hook.replace-formula.powerfx` — decision-modal queue routing
28. `13C_dirty_guard_back.replace-formula.powerfx` — protects Back navigation
29. `13D_dirty_guard_review_actions.replace-formula.powerfx` — protects Open Punch List
30. `13E_help_dirty_guard.incremental-patch.pa.yaml` — dirty-guard help
31. `14_punches_entry.add-child.pa.yaml` — Punch List entry route
32. `14A_punches_return_to_review.replace-formula.powerfx` — Punch List return route
33. `14B_punchreview_initial_selection.append-onvisible.powerfx` — loads initial Comments + Custom Fields on workspace entry
34. `15_home_entry.replace-formula.powerfx` — validated in Studio / runtime
35. `15A_help_source_integrations.incremental-patch.pa.yaml` — source-integration help

## Pre-Block 16 refactor — Custom Fields responsibility split

Block 16 remains paused.

Authoritative architecture:

`docs/development/custom-fields/CUSTOM_FIELDS_ARCHITECTURE_REFACTOR_PLAN.md`

Two components replace the former mixed-responsibility approach:

### `cmp_CustomFieldValuesPro`

Record-level component for the selected Punch. It occupies the existing Custom Fields area in the right column and provides the compact current-values experience while preserving the real load/save contract and Block 13 Dirty Guard.

Current VF status:

- VF-01 shell — completed as base;
- VF-02 six value renderers — completed as base;
- VF-03 editing + local dirty state — completed as base, with VF-03A mandatory Cancel correction;
- VF-04 Punch Review integration — published and pending real-Punch validation;
- VF-04A empty-queue component rebase — mandatory patch;
- VF-05 visual polish — blocked until VF-04 validates.

VF workspace:

`docs/development/components/custom-field-values-pro/`

VF-04 replaces `conPR_CustomFieldsCard` with `conPR_CustomFieldsHost`, preserving `btnPR_LoadCustomFields` and `btnPR_SaveCustomFields` as hidden host-owned service controls and adding one product instance:

`cmpPR_CustomFieldValues`

The instance receives `colPunchReviewFieldsUI`, synchronizes its `EditedItems` and `DirtyItems` to the existing host collections, and continues to drive `varPunchReviewDirty` / queue `IsDirty`, so Block 13 Dirty Guard remains authoritative.

Authoritative load/save responses call `Reset(cmpPR_CustomFieldValues)` to invoke the component's built-in `OnReset` and rebase its internal working state from the latest host `Items` table. VF-04A applies the same rebase when the review queue becomes empty, preventing stale values from the previous Punch.

`Manage Fields` remains intentionally non-functional during VF-04 except for an informational message. Project-level definition management starts in the DF phase.

### `cmp_CustomFieldsEditorPro`

Project-level definition editor modal. It manages which Custom Fields exist for PUNCH in the project. It is independent of the selected Punch and will first be opened from Punch Review. The same component will later be exposed from Punch List when that screen is modernized.

The legacy `cmp_DetailDrawer_old` remains operational in Punch List temporarily but receives no new Custom Fields features.

Do not begin Block 16 until the values component and the project-definition editor are integrated and validated from Punch Review.

## Confirmed Custom Fields service contracts

### Record values read

`WarRoom_GetCustomBundle(ProjectId, EntityType, RecordId).bundlejson`

### Record values save

`WarRoom_SaveCustomBulk(ProjectId, EntityType, RecordId, JSON(colDirty, JSONFormat.Compact), UserEmail)`

The backend-returned merged state remains authoritative after save.

### Project definitions list

`WarRoom_ListCustomFieldDefs(ProjectId, EntityType, IncludeInactive)`

### Project definition upsert

`WarRoom_UpsertCustomFieldDef(...)`

Current definition schema includes FieldDefId, ProjectId, EntityType, FieldKey, Label, FieldType, HelpText, IsRequired, IsPinned, IsActive, SortOrder, OptionsJson, IsFilterable, ShowInQuickFilters, FilterOrder and FilterMode.

### Project definition enable/disable

`WarRoom_SetCustomFieldActive(ProjectId, EntityType, FieldKey, IsActive, UserEmail)`

Definition mutations must invalidate Punch dynamic-filter configuration so Punch List reloads active/filterable field definitions later.

## Comments contract

Read: `Warroom_GetTaskCommentsPaged(ProjectId, RecordId, Page, PageSize, EntityType)`

Create: `Warroom_AddTaskComment(ProjectId, RecordId, CommentHtml, UserEmail, EntityType, UserName, CommentType)`

## Review Progress contract

Review Progress is session-local and is calculated over `colPunchReviewQueue` using `IsReviewedInSession` to separate Reviewed and Remaining. It does not use SQL or a flow.

`cmp_DonutPro` is confirmed as the installed component used for this session-progress indicator.

## Related Queue Context contract

`Related in Queue` is derived only from the loaded `colPunchReviewQueue`. A row is included when it is not the current Punch and shares `SubsystemCode` or `Discipline` with the current Punch.

The `Review` action routes through `btnPR_SelectCurrent`, so Comments and Custom Field values continue to load through the same selection mechanism.

## Dirty Guard contract

Block 13 provides Save and continue, Discard and continue, and Cancel for queue selection, Related in Queue, Back and Open Punch List.

Pending routing is represented by `varPunchReviewPendingAction` and numeric `varPunchReviewPendingIndex`.

VF-04 preserves the host `colPunchReviewFieldsDirty` and `varPunchReviewDirty` contract instead of replacing the guard with component-private state.

## Punch List integration contract

Block 14 establishes the production entry route into Punch Review from the currently loaded Punch List page. It does not claim to load every row in the filtered SQL result set.

The current Punch List still opens `cmp_DetailDrawer_old` when a row is selected. That behavior remains legacy and is deferred to the later Punch List modernization phase.

## Home integration contract

Block 15 activates the existing Review action in Home and builds a local Punch Review queue from selected or currently loaded Home rows. Real Comments and Custom Field values are loaded after entry through the existing services.

## Manual and compatibility knowledge

User guide: `docs/development/screens/punch-review/user-guide/MANUAL_USUARIO_PUNCH_REVIEW.md`

Compatibility register: `docs/development/screens/punch-review/POWER_APPS_SOURCE_CODE_COMPATIBILITY.md`

## Naming

- Screen: `scr_PunchReview`
- Screen controls: `PR` prefix
- Collections: `colPunchReview` prefix
- Variables: `varPunchReview` prefix
- Service controls: `btnPR_` prefix

## Validation minimum

1. read the compatibility register;
2. work from current repository `main`;
3. integrate only the current increment;
4. save and wait for formula validation;
5. check App Checker;
6. navigate to the screen;
7. confirm no overlap or broken references;
8. stop on any new Source Code error;
9. correct the repository artifact and record the reusable learning before continuing.
