# P4-SKY-01 — Skyline first-touch and component validation package

**Purpose:** obtain the missing baseline and the minimum executed evidence in one Power Apps Studio round-trip.  
**Package type:** runtime capture and validation gate; no redesign.  
**Expected user intervention:** one coherent session.

## Before opening Studio

Use the current PULSE application and a project that already exposes Skyline in navigation. Do not replace formulas or connect new data sources during this package.

Repository artifacts to have available:

- `power-apps/components/cmp_OperationalSkylinePro.pa.yaml`
- `docs/development/components/operational-skyline-pro/VALIDATION.md`

## A. Capture the actual installed source

Export/copy and preserve without editing:

1. complete Source Code for `scr_Skyline`;
2. current `App.OnStart`;
3. `App.StartScreen`, if configured;
4. complete source of any component instantiated directly by `scr_Skyline` that is not already represented by a current Studio-validated snapshot.

Name the captures exactly:

```text
scr_Skyline.runtime.pa.yaml
App.OnStart.runtime.powerfx
App.StartScreen.runtime.powerfx
```

If Source Code exposes an error, preserve the exact message, first failing line and Session ID; do not patch it in this session.

## B. Observe the existing Skyline once

With a project selected:

1. enter Skyline through the normal Sidebar route;
2. record whether the screen opens, loads, becomes empty or fails;
3. record the visible week horizon, subsystem selection/filtering, mode and risk/workload outputs;
4. select one week or bar if the current screen permits it and record the observable result;
5. return to Home and re-enter Skyline; record whether Skyline state is preserved or reset;
6. run App Checker and export/copy only Skyline-attributable errors and warnings.

Capture one screenshot of the loaded/failed Skyline and one screenshot after the interaction/re-entry. These are evidence, not design approval.

## C. Validate the repository component in isolation

Do this only in a blank diagnostic screen; do not integrate it into `scr_Skyline`.

1. Add/import the complete `cmp_OperationalSkylinePro.pa.yaml` using supported Source Code.
2. Save and run App Checker.
3. Insert one instance using default sample data; save, close and reopen.
4. Insert a second instance with different sample `Slots`; select a different slot in each.
5. Check widths 560, 760, 1000 and 1280, including last-slot clipping, horizontal scroll, summary visibility and labels.
6. Record the result using the evidence record below.

Stop on a definition rejection or Studio close. Preserve the exact error and Session ID. Do not start a chain of speculative property edits.

## Evidence record

Return the captures and this completed record together:

```text
P4-SKY-01 EVIDENCE
Date/time:
Environment/app:
Project used:

SCR_SKYLINE_CAPTURED: YES | NO
APP_ONSTART_CAPTURED: YES | NO
APP_STARTSCREEN_CAPTURED: YES | N/A | NO

EXISTING_SKYLINE_OPEN: PASS | FAIL
LOAD_RESULT: READY | EMPTY | ERROR | UNKNOWN
WEEK_INTERACTION: PASS | FAIL | NOT_AVAILABLE
HOME_REENTRY_STATE: PRESERVED | RESET | UNKNOWN
SKYLINE_APP_CHECKER:

COMPONENT_DEFINITION_ACCEPTED: PASS | FAIL
INSTANCE_SAFE: PASS | FAIL | NOT_RUN
PUBLIC_CONTRACT: PASS | FAIL | NOT_RUN
TWO_INSTANCE_ISOLATION: PASS | FAIL | NOT_RUN
VISUAL_QA: PASS | FAIL | NOT_RUN
COMPONENT_APP_CHECKER:
SESSION_ID:

FILES/SCREENSHOTS ATTACHED:
NOTES:
```

## Pass outcomes

- If capture succeeds and the existing screen runs, the agent can reconstruct the installed producer/host contract before selecting the next functional capability.
- If capture succeeds and runtime fails, the agent prepares one consolidated P4-SKY-01-FIX from the actual first failing contract.
- If the component passes, it may progress from repo-only candidate toward `STUDIO_VALIDATED`; it is not `RUNTIME_VALIDATED` until used in the real Skyline capability.
- If the component fails, integration remains blocked and diagnosis compares the complete candidate with `cmp_HeatMapPro` / `cmp_SidebarNav` before any reduction.

## Exclusions

This package does not authorize a redesign, SQL mutation, Flow replacement, component integration into the production screen or promotion to `SYNCED` without matching evidence.
