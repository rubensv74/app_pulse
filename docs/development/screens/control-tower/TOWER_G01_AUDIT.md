# PULSE Control Tower — TOWER-G01 audit

**Date:** 2026-10-26  
**Repository baseline:** `rubensv74/app_pulse`, canonical sources read from `main` on 2026-10-26  
**Screen:** `scr_Home_PDS`  
**Result:** `PASS_STATIC / STUDIO_SCREEN_CONFIRMED_ABSENT`

## Executive result

The user confirmed that `scr_Home_PDS` is absent from the current Power Apps application. Create it in Studio as a new Blank screen, then apply Block 01 from the canonical block path below. `scr_Home` remains the production reference and rollback path. Repository screen notes and PaYaml are construction artifacts, not proof of an installed screen.

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
9. The current component catalog lists `cmp_PageHeaderPro` as a `PDS_CANDIDATE`; retained Home_PDS records show definition and isolated-instance passes, while target-screen integration still requires manual Studio insertion and validation. The approved industrial hero is drawn as inline SVG in the screen source because the shared header component does not provide this object-protagonist treatment.
10. The older Boot candidate in PR #21 is superseded by today's `scr_Boot_PremiumProjectGallery_V4_1_PA2108_CORREGIDO.pa.yaml` artifact. The V4.1 source selects a project, sets `varPendingProjectId`, dispatches `PROJECT_CHANGE`, and navigates to `scr_Home` so the existing Home timer/commit owns the switch. This is a Library source artifact, not proof of the version currently installed in Studio.
11. V4.1 does not yet hand the user from `scr_Home` to `scr_Home_PDS` after the existing load completes. That post-load landing is a separate integration requirement; it must not trigger another initial bundle load.

## Architecture decision for the rebuild

Keep Boot as the project-selection point, using the V4.1 handoff: stage the selected ID in `varPendingProjectId`, then let the existing Home timer and commit own context mutation and initial data loading. After the existing load succeeds, route to Control Tower using the already committed context and presentation data; do not repeat the project-change or initial bundle request.

The post-load Boot-to-Control-Tower handoff and one-effective-load behavior remain mandatory runtime gates. Keep `App.StartScreen` unchanged until that gate passes. PR #21 is historical candidate evidence; use V4.1 as the latest Boot source candidate, then verify the actual Studio copy before integration.

## Component and Studio boundaries

- Reuse `cmp_SidebarNav`; configure its public inputs on a manually inserted Studio instance if the existing source-created instance hydration issue recurs.
- Use existing PDS candidates only after their actual input/event contracts are checked against the screen host.
- Keep `cmp_PageHeaderHeroPro` out of the screen until its PR candidate passes definition, manual insertion, save/reopen, public event and visual checks in Studio. The reference image may show the desired hero appearance; that does not claim the component is validated.
- Build `scr_Home_PDS` as a parallel screen. Do not alter `scr_Home` or the app start route during construction.

## Gate status

| Check | Status | Evidence |
|---|---|---|
| `scr_Home_PDS` exists in current Studio | `PASS — ABSENT` | User confirmed absence; source defines the new screen; paste it into a new blank screen |
| `scr_Home` remains functional reference/fallback | `PASS_STATIC` | Canonical Home source and approved specification |
| Project-change source contract recovered | `PASS_STATIC` | Home selector, timer and commit source |
| Boot project-selection source | `PASS_STATIC` | V4.1 artifact stages `varPendingProjectId` and reuses Home's `PROJECT_CHANGE` pipeline |
| Boot V4.1 currently installed in Studio | `GATED` | Current runtime version not independently observed |
| Post-load landing on Control Tower | `NOT_IMPLEMENTED` | Current V4.1 navigates to `scr_Home`; no PDS post-load route exists yet |
| Studio component compatibility | `GATED` | Source and catalog are not Studio proof |
| Boot → Control Tower, one effective load | `NOT_RUN` | Requires Power Apps Studio runtime |

## G02 visual reference scope

The companion reference presents the whole Control Tower at desktop scale: PULSE navigation, industrial object-protagonist header, project/template context, four Punch KPIs, subcontractor-by-category concentration heatmap, discipline pie plus matching comparison bars, active context with actions, and a server-paged Punch explorer. Values and record names are visibly identified as illustrative. PULSE cyan remains brand, blue remains interaction/selection, and discipline colors remain data encoding.

**User approved this reference on 2026-10-26.** It is the visual target, not an assertion that the current components or data are installed. Block 01 now contains the complete visual control tree: PULSE sidebar, object-protagonist hero, four KPI surfaces, heatmap and discipline empty states, active-context actions, and a paged-grid shell. Values remain neutral placeholders until the existing data contract is integrated. The source is ready for Studio paste; screen creation and App Checker validation have not yet occurred.

## Sources

- [Home PDS specification](https://github.com/rubensv74/app_pulse/blob/main/docs/specifications/home-pds/HOME_PDS_SCREEN_SPECIFICATION.md)
- [Home PDS architecture](https://github.com/rubensv74/app_pulse/blob/main/docs/development/screens/home-pds/SCREEN_ARCHITECTURE.md)
- [PULSE Design System](https://github.com/rubensv74/app_pulse/blob/main/docs/design-system/PULSE_DESIGN_SYSTEM.md)
- [Component catalog](https://github.com/rubensv74/app_pulse/blob/main/docs/design-system/COMPONENT_CATALOG.md)
- [Boot PR #21](https://github.com/rubensv74/app_pulse/pull/21)
- [Hero header PR #22](https://github.com/rubensv74/app_pulse/pull/22)
