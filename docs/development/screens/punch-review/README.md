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
21. `11_review_progress.replace-control.pa.yaml` — corrected to use installed `cmp_DonutPro`; pending Studio revalidation
22. `11A_help_review_progress.incremental-patch.pa.yaml` — dependent on Block 11 validation

Do not begin Block 12 until Review Progress imports without errors and responds correctly to Mark Reviewed / Undo Review.

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

Review Progress is session-local and is calculated over:

```text
colPunchReviewQueue
```

using `IsReviewedInSession` to separate Reviewed and Remaining. It does not use SQL or a flow.

`cmp_DonutPro` is confirmed as the installed component used for this session-progress indicator. It is not a substitute for the Home_PDS discipline-composition pie chart.

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
