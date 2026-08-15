# OPDS-C01 — one-pass Studio package

This is the only manual intervention requested for OPDS-C01. It installs the complete
visual candidate and validates all six synthetic states together.

## Before starting

Confirm that the app's component library already contains:

- `cmp_SidebarNav`;
- `cmp_PageHeaderPro`.

Do not edit either component definition. Do not open or modify `scr_Overview`.

## Part 1 — create and paste the screen

1. Open the PULSE app in Power Apps Studio.
2. Add a new **blank** screen.
3. Rename it exactly `scr_Overview_PDS`.
4. Select the complete screen and open **Source code**.
5. Replace the complete source with the contents of:
   `power-apps/screens/OverviewPDS/scr_Overview_PDS.pa.yaml`.
6. Save and wait for Studio to finish checking the source.

The dark Sidebar host and the white header host are intentionally empty at this
point. This is not a missing block: it avoids a component hydration failure already
demonstrated in PULSE.

## Part 2 — insert the Sidebar safely

1. Use **Insert > Custom** and insert `cmp_SidebarNav`.
2. Move the instance inside `conOPDS_SidebarHost`.
3. Rename it `cmpOPDS_Sidebar`.
4. Set these properties through the property selector/formula bar:

| Property | Formula |
|---|---|
| `Width` | `Parent.Width` |
| `Height` | `Parent.Height` |
| `Fill` | `varTheme_NavBg` |
| `ActiveKey` | `"overview"` |
| `AppVersion` | `"PULSE"` |
| `EnvironmentLabel` | `"VISUAL CANDIDATE"` |
| `IsCollapsed` | `true` |
| `Items` | `colSidebarNavItems` |
| `NavItems` | `colSidebarNavItems` |
| `ProjectCode` | `Coalesce(varSelectedProject.ProjectCode, "")` |
| `ProjectName` | `Coalesce(varSelectedProject.ProjectName, "")` |
| `UserRole` | `Coalesce(varUserRole, "reader")` |
| `OnSelectItem` | `Notify("Overview PDS is in visual test mode.", NotificationType.Information)` |

Leave operational navigation untouched. Selecting Sidebar items on this test screen
must only show the information message.

## Part 3 — insert the Page Header safely

1. Use **Insert > Custom** and insert `cmp_PageHeaderPro`.
2. Move the instance inside `conOPDS_PageHeaderHost`.
3. Rename it `cmpOPDS_PageHeader`.
4. Set these properties:

| Property | Formula |
|---|---|
| `Width` | `Parent.Width` |
| `Height` | `Parent.Height` |
| `Title` | `"Overview"` |
| `Subtitle` | `"Project Handover Report · premium visual candidate"` |
| `Context1Label` | `"Project"` |
| `Context1Value` | `If(IsBlank(varProjectId), "No project selected", Coalesce(varSelectedProject.ProjectCode, Text(varProjectId)) & " · " & Coalesce(varSelectedProject.ProjectName, "Project"))` |
| `Context1Visible` | `true` |
| `Context1Interactive` | `false` |
| `Context2Label` | `"Visual state"` |
| `Context2Value` | `Switch(varOPDS_VisualTestState, "LOADING", "Loading", "NO_PROJECT", "No project", "NO_CONFIGURATION", "No configuration", "NO_DATA", "No data", "ERROR", "Error", "READY", "Ready", "Visual test")` |
| `Context2Visible` | `true` |
| `Context2Interactive` | `false` |
| `Context3Label` | `"Evidence"` |
| `Context3Value` | `"Visual only"` |
| `Context3Visible` | `true` |
| `Context3Interactive` | `false` |
| `UtilityText` | `"Preview loading"` |
| `ShowUtility` | `true` |
| `UtilityEnabled` | `true` |
| `OnUtility` | `UpdateContext({varOPDS_VisualTestState: "LOADING"})` |
| `ShowHelp` | `true` |
| `OnHelp` | `Notify("OPDS-C01 validates presentation only. No Overview flow is connected.", NotificationType.Information)` |
| `SurfaceColor` | `varTheme_Surface` |
| `SurfaceAltColor` | `varTheme_SurfaceAlt` |
| `BorderColor` | `varTheme_Border` |
| `TextColor` | `varTheme_Text` |
| `MutedTextColor` | `varTheme_TextMuted` |
| `AccentColor` | `varTheme_PulseBlueDark` |
| `AccentSoftColor` | `varTheme_PulseSoft` |

If either manually inserted component is blank or does not expose these public
properties, stop only that component integration and report the missing properties.
The native visual surfaces can still be inspected; do not rewrite the component or
try equivalent Source Code instances.

## Part 4 — one grouped validation

Save the app, close/reopen the screen if necessary, and use the six buttons in the
`Visual test state` bar.

Record each required criterion with one result: `PASS`, `FAIL`, `NOT_RUN` or `GATED`.

| Check | Expected observation |
|---|---|
| Independent screen | `scr_Overview_PDS` opens and `scr_Overview` remains unchanged. |
| Shell | Sidebar, premium header and content stage render at 1600×900. |
| Loading | Loading copy and skeleton matrix appear alone. |
| No project | Project-selection surface appears alone. Its button only shows an informational message. |
| No configuration | Configuration-guidance surface appears alone and says it is a visual candidate. |
| No data | Empty-success surface appears alone; Preview refresh changes only to Loading. |
| Error | Error surface appears alone; Preview retry changes only to Loading. |
| Ready | Context strip, visual tabs, subsystem action and prepared matrix appear alone. |
| Exclusivity | No two state surfaces overlap during the six-state walkthrough. |
| App Checker | No new blocking error attributable to `scr_Overview_PDS`. |
| Save/reopen | The screen and both manual component instances remain visible and configured. |
| Isolation | No Overview flow runs and operational navigation remains unchanged. |

The no-configuration, no-data and error checks prove presentation only. They must not
be reported as real project outcomes.

## What to return

Return one message containing:

1. `OPDS-C01 STUDIO RESULT`;
2. one result for every row in the validation table;
3. the complete first Studio/App Checker error, if any;
4. one screenshot of the Ready state and screenshots of any visual defect;
5. whether save/reopen preserved both component instances.

Do not run the Overview flows for this validation.

