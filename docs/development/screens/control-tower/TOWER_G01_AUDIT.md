# PULSE Control Tower — TOWER-G01 audit

**Date:** 2026-10-26  
**Repository baseline:** `rubensv74/app_pulse`, `main` at `6d3297ca32d60e537a72b2f0cc3a672b02bf9e9e`  
**Screen:** `scr_Home_PDS`  
**Result:** `PASS_STATIC / STUDIO_SCREEN_CONFIRMED_ABSENT`

## Executive result

The user confirmed that `scr_Home_PDS` does not exist in the current Power Apps application. The parallel screen will therefore be created from a blank screen, while `scr_Home` remains the production reference and rollback path. The repository contains prior construction notes and a shell block, but those are not a screen installed in Studio.

No change to `App.StartScreen`, production navigation, `scr_Home`, flows, SQL, or component source is included in this audit.

## Verified repository facts

1. `main` has canonical Power Apps sources for Home, Overview, Punch Review and Punches. It has no canonical Boot or Home PDS screen source.
2. The Home PDS specification defines the parallel Operational Control Tower + Data Explorer architecture and retains `scr_Home` as fallback.
3. The existing `scr_Home` source owns the project-change commit path. The project selector stores `varPendingProjectId`, sets `varGlobalLoadAction = "PROJECT_CHANGE"`, and starts `varGlobalLoadPending`. `tmrGlobalLoader_2` dispatches to `btnHome_ProjectChange_Commit_2`.
4. The commit resolves `varSelectedProject` from `colEnabledProjectsUI`, sets `varProjectId`, `varProjectCode`, `varProjectName`, and `varProjectDescription`, then clears project-dependent state before scheduling the active dashboard load.
5. The existing template call is `Warroom_GetProjectPunchTemplates.Run(Value(varProjectId))`.
6. The bundle call is `warroom_GetPunchDashboardBundle.Run(Value(varProjectId), Value(varPunchDashboardTemplateId), If(varPunchDashboardForceRefreshRequest, 1, 0))`.
7. The cell-detail call has seven arguments in this order: project ID, template ID, subcontractor ID, category code, page, page size, discipline code. Power Apps source is verified; the active flow and SQL runtime still remain the authority for the downstream contract.
8. `cmp_SidebarNav` is `ACTIVE`. KPI, HeatMap, PieChart, ActionToolbar, DataTable, EmptyState and SkeletonLoader are existing PDS candidates whose consuming instances still need validation.
9. `cmp_PageHeaderHeroPro` exists only on open draft PR #22. It is not in `main` and has no confirmed Studio validation. Do not treat it as an installed dependency.
10. PR #21's Boot candidate says Boot does not select a project and navigates to Home. This conflicts with the new brief's decision that Boot is the project-selection point.

## Architecture decision for the rebuild

Use the existing Home project-change commit as the single owner of context mutation and initial data loading. Boot may stage the selected ID in `varPendingProjectId`, but it must hand off to the existing Home commit path. Control Tower must consume that committed project context and loaded presentation data; it must not independently repeat the same project-change or initial bundle request.

The Boot-to-Control-Tower handoff and one-effective-load behavior remain a mandatory runtime gate. Keep `App.StartScreen` unchanged until that gate passes. The current Boot candidate must be reconciled with the new project-selection requirement before being considered for installation.

## Component and Studio boundaries

- Reuse `cmp_SidebarNav`; configure its public inputs on a manually inserted Studio instance if the existing source-created instance hydration issue recurs.
- Use existing PDS candidates only after their actual input/event contracts are checked against the screen host.
- Keep `cmp_PageHeaderHeroPro` out of the screen until its PR candidate passes definition, manual insertion, save/reopen, public event and visual checks in Studio. The reference image may show the desired hero appearance; that does not claim the component is validated.
- Build `scr_Home_PDS` as a parallel screen. Do not alter `scr_Home` or the app start route during construction.

## Gate status

| Check | Status | Evidence |
|---|---|---|
| `scr_Home_PDS` exists in current Studio | `PASS — ABSENT` | User confirmed absence; new screen starts blank |
| `scr_Home` remains functional reference/fallback | `PASS_STATIC` | Canonical Home source and approved specification |
| Project-change source contract recovered | `PASS_STATIC` | Home selector, timer and commit source |
| Boot selection contract aligned | `GATED` | PR #21 candidate conflicts with the new requirement |
| Studio component compatibility | `GATED` | Source and catalog are not Studio proof |
| Boot → Control Tower, one effective load | `NOT_RUN` | Requires Power Apps Studio runtime |

## G02 visual reference scope

The companion reference presents the whole Control Tower at desktop scale: PULSE navigation, industrial object-protagonist header, project/template context, four Punch KPIs, subcontractor-by-category concentration heatmap, discipline pie plus matching comparison bars, active context with actions, and a server-paged Punch explorer. Values and record names are visibly identified as illustrative. PULSE cyan remains brand, blue remains interaction/selection, and discipline colors remain data encoding.

The reference is a visual target for user review, not an assertion that the current components or data are installed. No functional body implementation should begin until this reference is approved.

## Sources

- [Home PDS specification](https://github.com/rubensv74/app_pulse/blob/main/docs/specifications/home-pds/HOME_PDS_SCREEN_SPECIFICATION.md)
- [Home PDS architecture](https://github.com/rubensv74/app_pulse/blob/main/docs/development/screens/home-pds/SCREEN_ARCHITECTURE.md)
- [PULSE Design System](https://github.com/rubensv74/app_pulse/blob/main/docs/design-system/PULSE_DESIGN_SYSTEM.md)
- [Component catalog](https://github.com/rubensv74/app_pulse/blob/main/docs/design-system/COMPONENT_CATALOG.md)
- [Boot PR #21](https://github.com/rubensv74/app_pulse/pull/21)
- [Hero header PR #22](https://github.com/rubensv74/app_pulse/pull/22)
