# EPIC 01 Plan — Executive Dashboard Foundation

Status: **PLANNED — NOT STARTED**

## Objective

Prepare `Home_1` for the approved Executive Dashboard without implementing the new layout or interactions. Remove obsolete analytical panels from the active visual hierarchy while preserving object identity, loading, collections, Flow/SQL integration, and navigation.

## Authorized scope

- Canvas source: `power-platform/working-baselines/1.0.0.2/canvas-source/new_pulse_9584c/Src/scr_Home_1.pa.yaml`.
- EPIC 01 implementation notes, validation checklist, changed-control manifest, and rollback instructions.

No `.msapp`, Flow, SQL, component library, other screen, or navigation contract is modified in this EPIC.

## Controls preserved unchanged

| Control/area | Reason |
|---|---|
| `conPunchDashboard` and context header | Foundation owner and template context |
| `cmbHomePunchTemplate` | Approved selector behaviour |
| `conPunchKpiSection` / `galPunchStatusKpis` | Required by EPIC 02 |
| `conPunchMatrixCard` / `galPunchMatrixRows` | Required by EPIC 03 |
| Dashboard loading/state controls | Phase Zero validated behaviour |
| `btnHome_LoadPunchDashboard` | Existing Dashboard Bundle orchestration |
| Project selector, refresh, navigation | Explicit regression boundary |

## Controls removed from the active visual hierarchy

Controls remain in YAML as rollback assets. Only presentation participation changes; internal formulas remain intact.

| Control | Current function | EPIC 01 action |
|---|---|---|
| `conPunchTimelineCard` | Snapshot Timeline | Set inactive in visual hierarchy |
| `conPunchExecutiveInsightsCard` | Executive Insights | Set inactive in visual hierarchy |
| `conPunchOperationalSummaries` | Summary row owner | Set inactive in visual hierarchy |
| `conPunchTopCodeCard` | TOP Summary child | Preserve beneath inactive parent |
| `conPunchSubcontractorCard` | Subcontractor Summary child | Preserve beneath inactive parent |

No control is deleted, renamed, moved, or recreated.

## Formula and data contract

### Changed

- Only `Visible` on the three obsolete top-level containers; target value `false`.

### Explicitly unchanged

- Project/template handlers, refresh, and dashboard load commands.
- `warroom_GetPunchDashboardBundle.Run(...)` and parameter order.
- Bundle parsing and every `colPunchDashboard*` population.
- KPI, matrix, loading, empty, and error formulas.
- Every `Navigate(...)` expression.

All dashboard collections remain populated. Removing deprecated payload sections would be an out-of-scope optimization.

## Implementation sequence

1. Record pre-change hash/blob for `scr_Home_1.pa.yaml`.
2. Confirm Phase Zero remains PASSED and the working tree is clean.
3. Modify the three declared containers in place.
4. Confirm no other control or formula changed.
5. Run static structural/dependency checks.
6. Validate in Power Apps Studio against the existing solution.
7. Document and create one atomic EPIC 01 commit.
8. Stop for Product Owner acceptance; do not start EPIC 02.

## Validation

### Static

- `git diff --check` passes.
- Canvas diff contains only the three declared `Visible` properties.
- Every control remains present exactly once.
- Dashboard Bundle call, collection parsing, navigation, Flow/SQL files, components, and other screens are unchanged.

### Power Apps Studio

- No compilation errors or unresolved references.
- App and `Home_1` open without grey screen.
- Project, template, and refresh work; Dashboard Bundle returns data.
- Timeline, Executive Insights, TOP, and Subcontractor Summary are absent visually.
- KPI and matrix remain visible with unchanged data.
- Loading, empty, and error states remain stable.
- Existing navigation remains operational.

### Regression

- Compare selectors/refresh with Phase Zero evidence.
- Confirm no new Flow execution or SQL change.
- Confirm all legacy screens/components remain present.

## Risks

| Risk | Mitigation |
|---|---|
| Hidden AutoLayout controls retain space | Validate effective collapse at supported desktop resolutions |
| Child controls remain focusable | Validate runtime focus order with inactive parent |
| References to obsolete controls break | Reference scan and Studio compilation |
| Temporary dashboard appears sparse | Preserve KPI and matrix; EPIC 02 supplies approved layout |
| Backend returns temporarily unused data | Preserve contract; treat as documented performance debt |

## Rollback

Revert the single EPIC 01 commit. This restores the original visibility formulas without reconstructing controls. The immutable ZIP and `453cd8e` remain secondary restoration sources.

## Exit criteria

EPIC 01 repository completion is `IMPLEMENTED — PENDING INTEGRATION VALIDATION` after static checks, documentation, and commit. Studio, runtime, and UAT checks are Product Owner integration responsibilities and do not block EPIC 02.
