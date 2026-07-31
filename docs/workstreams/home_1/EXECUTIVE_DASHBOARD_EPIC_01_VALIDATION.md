# EPIC 01 Validation — Executive Dashboard Foundation

Status: **IMPLEMENTED — PENDING INTEGRATION VALIDATION**

Date: 2026-07-31  
Branch: `workstream/home-1-punches-1`

## Work completed

The obsolete analytical panels were removed from the active `Home_1` visual hierarchy while their controls and formulas remain preserved for rollback:

- `conPunchTimelineCard`: added `Visible: =false`.
- `conPunchExecutiveInsightsCard`: added `Visible: =false`.
- `conPunchOperationalSummaries`: added `Visible: =false`.
- `conPunchTopCodeCard` and `conPunchSubcontractorCard` remain unchanged beneath their inactive parent.

No control was deleted, renamed, moved, or recreated.

## Modified files

- `power-platform/working-baselines/1.0.0.2/canvas-source/new_pulse_9584c/Src/scr_Home_1.pa.yaml`
- `docs/workstreams/home_1/EXECUTIVE_DASHBOARD_EPIC_01_VALIDATION.md`

## Unchanged compatibility assets

- Every screen and component.
- Dashboard Bundle Flow and all other workflows.
- SQL and connection references.
- Project/template selectors and refresh.
- KPI and matrix controls.
- Dashboard collections, variables, parsing, loading, empty, and error logic.
- All navigation formulas.
- Packaged `.msapp` (packaging is not authorized in EPIC 01).

## Static validation

| Check | Evidence | Result |
|---|---|---|
| Declared Canvas surface | 3 insertions, 0 deletions | PASS |
| Whitespace/errors | `git diff --check` | PASS |
| Control identity | 233 named controls; 0 duplicate names | PASS |
| Dashboard Bundle call | 1 before / 1 after | PASS |
| Navigation calls | 22 before / 22 after | PASS |
| Changed Canvas files | Only `scr_Home_1.pa.yaml` | PASS |
| Pre-change SHA-256 | `67745D475ECC25CDE28E89432BA12C9B64F234A917E33473225A478BC9A23982` | RECORDED |
| Post-change SHA-256 | `D8CE52CF2DBFF43846F983A3BB05EDED826572F5E84E0339AF83A29AE8219163` | RECORDED |

## Product Owner integration validation

Validate against the existing development solution without a new Phase Zero import:

1. No compilation errors or unresolved references.
2. Application and `Home_1` open without grey screen.
3. Project and template selectors work.
4. Refresh executes and Dashboard Bundle returns data.
5. Timeline, Executive Insights, TOP Summary, and Subcontractor Summary are not visible.
6. Hidden AutoLayout containers consume no space and their children are not focusable.
7. KPI and matrix remain visible and show unchanged data.
8. Loading, empty, and error states remain stable.
9. Existing navigation remains operational.

These runtime checks are owned by the Product Owner and do not block repository completion or the next EPIC.

## Defects and risks

- No static defect detected.
- Runtime AutoLayout collapse and focus order remain unverified.
- The temporary visual result intentionally retains KPI and matrix only; approved layout construction belongs to EPIC 02.
- Deprecated payload collections remain populated to preserve the existing backend contract.

## Rollback

Revert the EPIC 01 commit. This removes only the three `Visible: =false` properties and restores the previous hierarchy. No object reconstruction is required. The immutable baseline ZIP and commit `453cd8e` remain secondary restoration sources.

## Recommendation

Include this EPIC in the next periodic Product Owner integration validation. Repository implementation is complete and EPIC 02 may begin.
