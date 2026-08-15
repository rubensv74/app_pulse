# OVR-01 — Overview operational states

## Functional purpose recovered from repository evidence

Overview is the Project Handover Report matrix. It presents the published report
configuration by subsystem and report hierarchy, combines task and Punch metrics,
supports snapshot refresh/load, and opens Tasks or Punch List with the selected
subsystem context.

It is not a generic executive dashboard.

## Evidence classification

### Present in `main`

- Complete `scr_Overview` Source Code snapshot.
- Home and Sidebar navigation to `scr_Overview`.
- Return navigation from Punch List to Overview.
- Calls to `warroom_GenerateOverviewSnapshot` and
  `Warroom_GetOverviewSnapshot`.
- Overview snapshot tables and stored procedures in the `warroom` schema
  snapshot.
- Drill-through formulas from Overview to Tasks and Punch List.

### Demonstrated in Power Apps

The screen was supplied from the current Power Apps authoring environment. This
demonstrates that the captured source existed there when copied. No App Checker,
Studio formula validation, save/publish evidence, or end-to-end runtime result is
stored for OVR-01.

### Installed but not synchronized

The two Power Automate flows consumed by the screen are referenced by name, but
their full definitions are not stored under `power-automate/flows`. Their installed
configuration and connection bindings therefore remain runtime-only evidence.

### Historical or proposal-only

Older generic Overview/dashboard references do not define this screen's purpose.
The published report configuration, snapshot schema, current formulas, and
navigation contracts take precedence.

### Still unknown

- Current App Checker result for `scr_Overview`.
- Whether both Overview flows are connected and enabled in the target app.
- Whether a selected test project has a published report configuration and a
  generated snapshot.
- Whether Tasks and Punch List consume every drill-through variable correctly at
  runtime.

## Capability card

**CAPABILITY:** OVR-01 — truthful Overview entry and operational states

**Objective:** A user entering Overview can distinguish a load error, a missing
published configuration, an empty report, and a ready-to-refresh state, while
retaining the existing automatic load and Refresh behavior.

**Risk:** B — reversible Power Apps behavior over existing data and flow contracts.

**Scope:** Empty/error state presentation and classification in `scr_Overview`.

**Dependencies:** Existing project context, existing Overview snapshot flows,
existing state variables, and existing Refresh trigger.

**Acceptance:**

1. Loading overlays suppress empty-state text.
2. Missing configuration has a specific message and does not claim generic no-data.
3. Successful empty results have a no-data message.
4. Other load failures show the actual error and offer Refresh as retry.
5. A successful populated result continues to show the matrix.

**Validation:** Static source checks plus one grouped Studio/runtime validation.

**Gate:** Studio/runtime execution is required before claiming the capability works.

## Single Studio/runtime validation

1. Open PULSE in Power Apps Studio and open `scr_Overview`.
2. Replace the screen Source Code with the complete candidate file from this PR.
3. Save and run App Checker. Record every error that names `scr_Overview`.
4. Play the app and select a project with a published report configuration and
   report data. Open Overview and confirm that the matrix loads.
5. Press **Refresh** once and confirm that loading completes and **Last Refresh** is
   updated.
6. Open the task icon and Punch icon on one subsystem row. Confirm each target list
   opens filtered to that subsystem, then use its back action to return to Overview.
7. If available, select one project without a published report configuration and
   confirm the dedicated configuration message. If no such project exists, report
   that this case could not be executed; do not manufacture one.
8. Return one result only: App Checker output, the projects/cases exercised, whether
   load/refresh/drill-through/return passed, and one screenshot of the final state.

Do not publish the app merely to validate this candidate unless publishing is already
part of the normal controlled PULSE release process.
