# EPIC 04 — Right Analytical Column

Status: **IMPLEMENTED — PENDING INTEGRATION VALIDATION**

Date: 2026-07-31  
Branch: `workstream/home-1-punches-1`

## Objective delivered

Implemented the in-memory analytical context to the right of the Executive Heatmap:

- dynamic status Donut;
- ordered semantic legend with counts and percentages;
- overall distribution before selection;
- selected Category × Subsystem context;
- Punch count, percentage of total, and percentage of selected Category;
- Clear Selection action;
- View Punches action presented but intentionally disabled until EPIC 06 navigation.

## Synchronization contract

Heatmap selection remains the only controller. It updates:

- `varPunchDrillSubsystemCode`;
- `varPunchDrillCategoryCode`;
- `colPunchExecutiveSelection`;
- `colPunchExecutiveDistribution`.

The Donut and Detail Panel bind to those collections. Neither component updates the Heatmap or calls a backend.

Clear Selection restores overall Dashboard context and distribution without executing SQL or Power Automate.

## Donut implementation

`htmlPunchExecutiveDonut` renders a CSS `conic-gradient` generated from the ordered status distribution. The centre remains neutral and the numeric total is rendered by a separate Power Apps label. A standard gallery provides the accessible legend and exact values independently of the visual ring.

## Modified controls

- Hid EPIC 02 Donut and Detail placeholder labels.
- Added Donut `HtmlViewer`, total label, legend gallery, and empty state.
- Added selection context/count/percentage labels.
- Added Clear Selection.
- Added disabled View Punches handoff button.
- Extended Heatmap `OnSelect` with in-memory synchronization only.
- Extended bundle initialization and reset paths for distribution/selection collections.

## Repository validation

| Check | Evidence | Result |
|---|---|---|
| YAML hygiene | `git diff --check` | PASS |
| Control identity | 293 named controls, 0 duplicates | PASS |
| Declared right-column controls | Each exactly once | PASS |
| Backend calls in right column | 0 | PASS |
| Navigation calls in right column | 0 | PASS |
| Dashboard Bundle calls globally | 1 before / 1 after | PASS |
| Reset coverage | Template, refresh, project | PASS |
| Post-change SHA-256 | `464C58B64648453B131F1FEE9DEAB1ABE94CB46261A129CB509AD882B4A7C76B` | RECORDED |

## Product Owner integration validation

Include in periodic Studio/UAT validation:

- `HtmlViewer` supports the generated `conic-gradient` markup;
- slices match legend counts, percentages, order, and colours;
- overall distribution appears before a selection;
- selected cell updates Donut and Detail immediately;
- percentages reconcile with Heatmap totals;
- zero selection displays a stable empty state;
- Clear Selection restores overall context and Heatmap border state;
- no layout flicker or backend call occurs;
- disabled View Punches button is visually clear until EPIC 06.

These checks do not block repository progression under the Autonomous EPIC Execution policy.

## Risks

- CSS `conic-gradient` support inside Power Apps `HtmlViewer` requires integration confirmation. The independent legend preserves exact information if rendering differs.
- The current payload defines status colours; those values are reused rather than replaced by hard-coded status mappings.
- View Punches is deliberately disabled until the navigation contract is implemented in EPIC 06.
- The packaged `.msapp` remains unchanged.

## Rollback

Revert the EPIC 04 commit. EPIC 03 Heatmap state remains available, and EPIC 02 right-column placeholders are restored.

## Next EPIC

EPIC 05 — Executive Grid: toolbar, columns, sorting, pagination, selection, Drawer handoff, export handoff, and in-memory/server-compatible dataset contract.
