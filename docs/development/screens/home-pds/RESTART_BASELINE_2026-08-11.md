# HOME_PDS — Restart Baseline — 2026-08-11

**Screen:** `scr_Home_PDS`  
**Current Studio state:** empty screen  
**Restart scope:** implementation of `scr_Home_PDS` only  
**Stable fallback:** `scr_Home`  
**StartScreen:** unchanged during construction

## 1. Why this restart exists

The user has intentionally reset `scr_Home_PDS` to an empty screen and wants the implementation rebuilt from a known baseline.

This restart does **not** discard the architectural, design-system, component, compatibility or diagnostic knowledge already validated in the repository. It resets only the current screen implementation state.

## 2. Preserved decisions

The following remain authoritative:

- `scr_Home` remains the stable reference and rollback screen.
- `scr_Home_PDS` is a parallel PDS implementation.
- Primary archetype: **Operational Control Tower**.
- Secondary pattern: **Data Explorer**.
- Frozen target architecture remains unchanged.
- PULSE Design System remains the visual authority.
- Existing validated reusable components remain reusable assets; they are not recreated merely because the screen is empty.
- Power Apps Studio + App Checker remain the runtime acceptance authority.

## 3. What had been reached before the reset

Historical implementation had reached **Block 03 — Page Header integration**.

Validated/relevant evidence retained:

```text
Block 00 — foundation / reuse / architecture          VALIDATED
Block 01 — shell                                      previously validated
Block 02 — cmp_PageHeaderPro corrected                DEFINITION_ACCEPTED = PASS
                                                       INSTANCE_SAFE = PASS
Block 03 — host integration                           NOT CLOSED
```

Block 03 revealed an important compatibility boundary:

- a `cmp_PageHeaderPro` instance created from screen Source Code could be accepted as a generic `CanvasComponent`;
- host-side assignments to its custom properties returned `PA2108`;
- a Source Code-created instance later rendered blank and did not expose the expected public contract;
- the proven corrective route is **manual Studio insertion of `cmp_PageHeaderPro`**, not more equivalent screen-YAML variants.

The detailed evidence remains in:

- `CMP_PAGE_HEADER_PRO_VALIDATION_REPORT_2026-08-10.md`
- `POWER_APPS_SOURCE_CODE_COMPATIBILITY.md`
- `blocks/03C_header_integration_manual_instance.md`

## 4. Current implementation reset

Because `scr_Home_PDS` is empty, the **current screen gate** is reset to:

```text
Block 00  RETAINED / no rework
Block 01  NEXT — rebuild shell
Block 02  RETAINED COMPONENT EVIDENCE — do not recreate unless asset is missing
Block 03  PENDING AFTER BLOCK 01 — use the proven manual-instance path
Block 04+ BLOCKED until Block 03 closes
```

Historical validation is retained as evidence, but it does not mean the empty screen currently contains those blocks.

## 5. Immediate next action — Block 01

Use the existing executable artifact:

`docs/development/screens/home-pds/blocks/01_screen_shell.pa.yaml`

Operation:

1. Select the complete `scr_Home_PDS` screen.
2. Open its Source Code.
3. Replace the complete screen source with Block 01.
4. Save and wait for validation.
5. Open `scr_Home_PDS`.
6. Confirm the shared PULSE sidebar renders at the left and the remaining content surface is empty.
7. Confirm `scr_Home` remains unchanged.
8. Confirm App Checker has no new Block-01-attributable error.

Do not add the Page Header in the same operation.

## 6. Block 01 acceptance

```text
[ ] scr_Home_PDS opens normally
[ ] cmpHPDS_Sidebar renders
[ ] Home is the active navigation key
[ ] current project is not reset
[ ] conHPDS_ContentShell occupies the remaining screen
[ ] content shell is intentionally empty
[ ] scr_Home remains intact
[ ] no new PA1001 / PA2108 attributable to Block 01
```

Result to report:

```text
BLOCK 01 OK
```

or provide the complete Studio error details.

## 7. What happens after Block 01

Do **not** rebuild `cmp_PageHeaderPro` from scratch if it still exists in the component library.

The next stage will be a refreshed Block 03 integration using the evidence already learned:

```text
shell validated
→ create PageHeader host
→ insert cmp_PageHeaderPro manually from Studio Custom components
→ configure its public contract in Studio
→ one integration smoke test
→ close Block 03
```

Only after that will Block 04 create the workspace/body structure.

## 8. Frozen roadmap after restart

```text
00  Foundation audit and reuse matrix                    retained
01  Blank screen shell + shared sidebar + content shell  NEXT
02  PDS Page Header component                            retained asset/evidence
03  Home_PDS Page Header integration                     pending
04  Workspace/body structural layout                     blocked
05  Minimum typed runtime state
06  KPI strip with local presentation model
07  Punch-template context selector
08  Dashboard bundle remote read
09  Bundle parser / presentation model
10  KPI real-data integration
11  Heatmap integration
12  Heatmap selection + active context
13  Discipline pie integration
14  Discipline bars + shared selection
15  Action toolbar
16  Cell-details remote read
17  DataTableProV2 + SQL-authoritative paging
18  Search/sort/columns/density/selection
19  Home → Punch Review contextual navigation
20  Loading/empty/error hardening
21  Help/accessibility/responsive
22  Remove scaffolding + visual QA
23  Consolidation + user guide + cutover decision
```

## 9. Working rule from this restart

For each block:

```text
repository artifact
→ implement in Studio
→ one meaningful validation
→ record result
→ advance only if the dependency gate passes
```

Do not repeat historical diagnosis unless the same failure is reproduced in the restarted screen.
