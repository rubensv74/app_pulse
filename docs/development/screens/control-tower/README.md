# PULSE Control Tower — implementation workspace

**Workstream:** `PULSE-TOWER-01`  
**Screen:** `scr_Home_PDS`  
**Visual gate:** `TOWER-G02 — APPROVED 2026-10-26`  
**Implementation gate:** `BLOCK 01 — SOURCE READY / STUDIO APPLY REQUIRED`

## Artifacts

- `TOWER_G01_AUDIT.md` — architecture, data contracts and runtime gates.
- `PULSE_Control_Tower_G02_Reference.svg` — user-approved desktop visual target.
- `../home-pds/blocks/01_screen_shell.pa.yaml` — executable source for the initial screen shell.

## What Block 01 creates

A new parallel `scr_Home_PDS` screen with the shared `cmp_SidebarNav` and an empty PDS content surface. It establishes screen identity and safe theme fallbacks only. It contains no flow calls, business collections, project reset or production navigation change.

The approved reference shows the complete target: industrial object-protagonist header, project/template context, four Punch KPIs, subcontractor/category heatmap, discipline pie with matching comparison bars, active context/actions and server-paged Punch explorer. Those modules follow after the shell and header pass Studio validation.

The existing shared sidebar has a narrower, different footer/navigation composition from the reference. Keep its canonical navigation and surface the project/template context in the header. Do not add a second project-selection path to the sidebar.

## Apply Block 01 in Power Apps Studio

1. Add a new **Blank screen** and name it exactly `scr_Home_PDS`.
2. Open that screen's **Source Code** and replace the complete screen source with `docs/development/screens/home-pds/blocks/01_screen_shell.pa.yaml`.
3. Save, wait for formula validation, and open `scr_Home_PDS`.
4. If the source-created sidebar does not hydrate its public inputs, insert `cmp_SidebarNav` manually in Studio and set the inputs specified in `blocks/01A_sidebar_manual_instance.md`.
5. Confirm Home is active, the selected project is not reset, the PDS surface fills the remaining area, and no new App Checker errors appear. Confirm `scr_Home` still opens unchanged.

The repository source is ready; Studio is the remaining creation and acceptance surface. Do not change `App.StartScreen`, `scr_Home`, production navigation, flows or SQL during this block.

## Next gates

| Gate | Scope | Status |
|---|---|---|
| G01 | Source and contract audit | Complete |
| G02 | Visual reference | Approved |
| Block 01 | New screen shell + shared sidebar | Source ready; Studio apply required |
| Block 03 | Page header / approved hero direction | Pending after Block 01 |
| Block 04+ | Dashboard structure, local state, data and interaction blocks | Pending |
| Final | Boot → Tower, one effective load, cutover decision | Runtime gated |

Every block advances only after a meaningful Power Apps Studio validation. `scr_Home` remains the fallback until final acceptance.
