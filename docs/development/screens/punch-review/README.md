# Punch Review Workspace — Incremental Construction

**Status:** active development workspace  
**Canonical runtime screen:** `power-apps/screens/PunchReview/scr_PunchReview.pa.yaml`  
**Construction workspace:** `docs/development/screens/punch-review/`

This workspace contains incremental blocks for building and evolving `scr_PunchReview` in Power Apps Studio without replacing the complete screen blindly.

## Canonical-source rule

```text
power-apps/screens/PunchReview/scr_PunchReview.pa.yaml
```

is the canonical complete screen source.

Files under:

```text
docs/development/screens/punch-review/blocks/
```

are controlled construction artifacts. They do not replace the canonical screen source until the relevant increment has been validated and consolidated.

## Mandatory compatibility gate

Before drafting, correcting or publishing any `.pa.yaml`, consult:

```text
docs/development/screens/punch-review/POWER_APPS_SOURCE_CODE_COMPATIBILITY.md
```

Do not work from memory. Every confirmed Studio incompatibility must become a preventive rule before dependent blocks continue.

## Current block sequence

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
16. `10_custom_fields.replace-control.pa.yaml` — integrated
17. `10A_custom_fields_selection_hook.replace-formula.powerfx` — comments + custom-fields selection hook
18. `10B_custom_fields_test_seed.optional.powerfx` — optional field-type seed
19. `10C_yesno_initial_state.incremental-patch.pa.yaml` — Toggle `Checked` binding correction
20. `10D_help_custom_fields.incremental-patch.pa.yaml` — custom-fields help
21. `11_review_progress.replace-control.pa.yaml` — implemented with installed `cmp_DonutPro`; continuation approved
22. `11A_help_review_progress.incremental-patch.pa.yaml` — review-progress help
23. `12_related_queue_context.replace-control.pa.yaml` — integrated path completed; continuation to Block 13 approved
24. `12A_help_related_queue_context.incremental-patch.pa.yaml` — related-context help
25. `13_dirty_guard_modal.add-screen-child.pa.yaml` — integrated path completed; continuation to Block 14 approved
26. `13A_dirty_guard_runtime_state.incremental-patch.powerfx` — typed guard runtime state
27. `13B_dirty_guard_selection_hook.replace-formula.powerfx` — decision-modal queue routing
28. `13C_dirty_guard_back.replace-formula.powerfx` — protects Back navigation
29. `13D_dirty_guard_review_actions.replace-formula.powerfx` — protects Open Punch List
30. `13E_help_dirty_guard.incremental-patch.pa.yaml` — dirty-guard help
31. `14_punches_entry.add-child.pa.yaml` — published; pending Studio validation
32. `14A_punches_return_to_review.replace-formula.powerfx` — Punch List return route
33. `14B_punchreview_initial_selection.append-onvisible.powerfx` — loads initial Comments + Custom Fields on workspace entry

Do not begin Block 15 until Block 14 is validated end-to-end from a real loaded Punch List page and the return path back to Punch Review preserves the review session.

## Confirmed service contracts

### Comments read

```text
Warroom_GetTaskCommentsPaged.Run(
    ProjectId,
    RecordId,
    Page,
    PageSize,
    EntityType
)
```

### Comment create

```text
Warroom_AddTaskComment.Run(
    ProjectId,
    RecordId,
    CommentHtml,
    UserEmail,
    EntityType,
    UserName,
    CommentType
)
```

### Custom fields read

```text
WarRoom_GetCustomBundle.Run(
    ProjectId,
    EntityType,
    RecordId
).bundlejson
```

### Custom fields save

```text
WarRoom_SaveCustomBulk.Run(
    ProjectId,
    EntityType,
    RecordId,
    JSON(colDirty, JSONFormat.Compact),
    UserEmail
)
```

The backend-returned merged state remains authoritative after save.

## Review Progress contract

Review Progress is session-local and is calculated over `colPunchReviewQueue` using `IsReviewedInSession` to separate Reviewed and Remaining. It does not use SQL or a flow.

`cmp_DonutPro` is confirmed as the installed component used for this session-progress indicator.

## Related Queue Context contract

Block 12 deliberately does **not** invent a backend Punch-to-Punch relationship.

`Related in Queue` is derived only from the loaded `colPunchReviewQueue`. A row is included when it is not the current Punch and shares `SubsystemCode` or `Discipline` with the current Punch.

The `Review` action routes through `btnPR_SelectCurrent`, so Comments and Custom Fields continue to load through the same selection mechanism.

## Dirty Guard contract

Block 13 replaces the temporary hard navigation lock with an explicit decision flow for queue selection, Related in Queue, Back and Open Punch List.

The modal offers Save and continue, Discard and continue, and Cancel. Pending routing is represented by `varPunchReviewPendingAction` and numeric `varPunchReviewPendingIndex`.

## Punch List integration contract

Block 14 establishes the first production entry route into Punch Review.

Source screen:

```text
scr_Punches
```

Source collection:

```text
colPunches
```

The `Review page` action builds a fresh session queue from the **currently loaded Punch List page only**. It does not claim to load every row in the filtered SQL result set.

Each `colPunches` row is normalized into the Punch Review queue contract using already available fields such as PunchId, PunchCode, PunchDescription, WBS codes, PunchDiscipline, CategoryCode, StatusCode/PunchStatus, SubcontractorName, InspectionName, Originator, CommentCount and LastCommentOn.

If `varSelectedTaskId` belongs to the loaded page, that Punch becomes the initial active review record; otherwise the review starts at row 1.

`14B_punchreview_initial_selection.append-onvisible.powerfx` routes the initial active record through `btnPR_SelectCurrent`, ensuring Comments and Custom Fields use the same loading pipeline as later queue navigation.

When Punch Review uses `Open Punch List`, the existing action sets:

```text
varPunches_ReturnView = "PunchReview"
```

`14A_punches_return_to_review.replace-formula.powerfx` makes that route functional without rebuilding the queue, so Reviewed state and Session Activity remain part of the current review session.

## Manual and compatibility knowledge

User guide:

```text
docs/development/screens/punch-review/user-guide/MANUAL_USUARIO_PUNCH_REVIEW.md
```

Compatibility register:

```text
docs/development/screens/punch-review/POWER_APPS_SOURCE_CODE_COMPATIBILITY.md
```

Confirmed reusable rules include:

- `Label@2.5.1` does not support corner-radius properties used on containers;
- `Classic/Button@2.2.0` does not support the previously attempted `AccessibleLabel` Source Code pattern;
- `TabList@2.2.30` is not reset with `Reset()`;
- new numeric variables require an unequivocal numeric initialization;
- modern Toggle uses `Checked` for the initial Boolean state;
- a Canvas component must exist in the active app; a GitHub file alone is insufficient;
- do not use inline SVG as a substitute for an installed/maintainable visual component when the PULSE component pattern is available.

## Naming

```text
Screen       scr_PunchReview
Controls     PR prefix
Collections  colPunchReview prefix
Variables    varPunchReview prefix
Service      btnPR_ prefix
```

## Validation minimum

1. review the compatibility register;
2. work from current repository `main` branch state;
3. save the block in Studio;
4. wait for formula validation;
5. check App Checker;
6. navigate to the screen;
7. confirm no overlaps, visible defects or broken references;
8. stop on new PA1001, PA2108, PA2301, unsupported property or type error;
9. correct the repository artifact and record reusable learning before continuing.

## Current source references

```text
power-apps/screens/PunchReview/scr_PunchReview.pa.yaml
power-apps/screens/Home/scr_Home.pa.yaml
power-apps/screens/Punches/scr_Punches_1.pa.yaml
power-apps/components/cmp_SidebarNav.pa.yaml
power-apps/components/cmp_DonutPro.pa.yaml
power-apps/components/
```

The repository structure and legacy policy are governed by:

```text
docs/governance/REPOSITORY_STRUCTURE_STANDARD.md
docs/governance/ACTIVE_SOURCE_POLICY.md
```
