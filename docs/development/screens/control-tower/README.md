# PULSE Control Tower — implementation workspace

**Workstream:** `PULSE-TOWER-01`  
**Screen:** `scr_Home_PDS`  
**Visual gate:** `TOWER-G02 — APPROVED 2026-10-26`  
**Implementation source:** `BLOCK 01 — COMPLETE VISUAL SCREEN DEFINITION`

## Artifacts

- `TOWER_G01_AUDIT.md` — architecture, data contracts and runtime gates.
- `PULSE_Control_Tower_G02_Reference.svg` — user-approved desktop visual target.
- `../home-pds/blocks/01_screen_shell.pa.yaml` — complete `Screens.scr_Home_PDS` PaYaml definition for Studio paste.

## What the complete source defines

- Shared `cmp_SidebarNav` with Home active and current project context.
- Dark industrial hero with inline valve SVG, page identity and utility actions.
- Four PDS KPI cards.
- Subcontractor × category concentration panel.
- Discipline distribution panel with a shared-selection contract.
- Active context and Review / Punch List actions.
- Punch explorer with column headers and paging controls.

The source uses neutral empty states and disabled actions. It does not display invented counts or records, call a flow, reset the selected project, or fetch data. The bundle and SQL-authoritative paging must be connected in later blocks after their current Studio contracts are confirmed.

## Paste into Power Apps Studio

1. Add a **Blank screen** and name it exactly `scr_Home_PDS`.
2. Open the screen's **Source Code** and replace the complete screen source with `docs/development/screens/home-pds/blocks/01_screen_shell.pa.yaml`.
3. Save and resolve any formula or component hydration issue in Studio.
4. Confirm the sidebar and complete visual tree render; confirm the values remain neutral rather than fabricated.
5. Run App Checker and confirm `scr_Home` is unchanged.

The artifact is prepared, but this workspace has not edited Power Apps Studio; runtime acceptance is still open. Keep `App.StartScreen`, production navigation, flows and SQL unchanged during this paste.

## Remaining implementation gates

| Gate | Scope | Status |
|---|---|---|
| G01 | Source and contract audit | Complete |
| G02 | Visual reference | Approved |
| Block 01 | Complete visual screen definition | Source ready; Studio paste and acceptance required |
| Data integration | Existing bundle, heatmap, discipline and paged results | Pending |
| Interaction | Shared context, actions and drill-through | Pending |
| Final | Boot → Tower, one effective load, cutover decision | Runtime gated |

