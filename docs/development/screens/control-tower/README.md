# PULSE Control Tower — reference package

**Workstream:** `PULSE-TOWER-01`  
**Current gate:** `TOWER-G02 — awaiting visual approval`  
**Screen target:** `scr_Home_PDS`  
**Status:** reference only; no screen body or production navigation changed.

## Files

- `TOWER_G01_AUDIT.md` — architecture and integration audit.
- `PULSE_Control_Tower_G02_Reference.svg` — full desktop visual target, 1600 × 900 app viewport plus review caption.

## Design intent

The reference follows the approved Control Tower + Data Explorer architecture and PULSE Design System. Its hero uses an industrial valve/piping assembly as the object protagonist. Labels, records, counts and timestamps are illustrative only. The dashboard sections map to existing PULSE component candidates; implementation must validate each actual Studio contract before integration.

The reference deliberately keeps the heatmap and discipline distribution connected to one active context and shows the table as server-paged. It does not imply a new backend, flow, SQL procedure, metric or data dimension.

## Gate rule

Do not begin the functional body implementation until the user approves the visual reference. After approval, start with the blank-screen shell and sidebar, then manually validate the page header path and host context in Studio. Keep `scr_Home`, `App.StartScreen` and production navigation unchanged until the Boot-to-Control-Tower single-load gate passes.
