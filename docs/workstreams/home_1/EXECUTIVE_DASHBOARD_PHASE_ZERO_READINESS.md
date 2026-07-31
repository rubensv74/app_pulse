# Executive Dashboard — Phase Zero Readiness

Status: **NOT READY FOR EPIC 01 IMPLEMENTATION**

Date: 2026-07-31  
Branch: `workstream/home-1-punches-1`

## Normative inputs

- FDS: `docs/specifications/PULSE_EXECUTIVE_DASHBOARD_FDS_v1.md`
  - SHA-256: `57FA88527E787A810B9DD11B437F8B2AD982B7767ADEA11B1D8A110ABD9F2887`
- Canonical image: `docs/specifications/assets/PULSE_EXECUTIVE_DASHBOARD_REFERENCE_v1.png`
  - 1536 × 1024
  - SHA-256: `F73E783BFDDA0D99191F68A3D9E829BE2540A2821C23B0092F58AFB08B62E9EC`

The reference requires: header, exactly five KPIs, dominant Subsystem × Category heatmap with totals, status donut, selected-cell details, and a full-width operational Punch grid.

## Phase Zero checks

| Check | Evidence | Result |
|---|---|---|
| Repository baseline | Baseline commit `453cd8e` present | PASS |
| Dashboard Flow | `warroom_GetPunchDashboardBundle-4AA15D31-858A-F111-AB10-000D3A21CE45.json` parses | PASS |
| SQL reference | Flow targets `[warroom].[usp_GetPunchDashboardBundle]`; SQL contract docs exist | PASS |
| Solution metadata | `Other/Solution.xml` and `Other/Customizations.xml` parse | PASS |
| Home_1 static structure | 245 controls, no duplicate names, `git diff --check` passes | PASS (static) |
| Home_1 compilation/import | No local Canvas compiler or Power Apps Studio | NOT VERIFIED |
| Dashboard opens | Requires connected Power Apps runtime | NOT VERIFIED |
| Power Fx references | Requires Canvas compilation | NOT VERIFIED |

The FDS requires every Phase Zero check to pass before controls are modified. EPIC 01 Foundation must not start.

## Current-to-target migration map

| Current area | FDS disposition | Phase |
|---|---|---|
| Project/template selectors and refresh | Reuse without behavioural change | EPIC 01/02 |
| `conPunchKpiSection` / `galPunchStatusKpis` | Reuse data; exactly five equal cards | EPIC 02 |
| `conPunchMatrixCard` / `galPunchMatrixRows` | Preserve identity/data; rebuild as dominant heatmap | EPIC 03 |
| Timeline and Executive Insights | Remove from active visual hierarchy | EPIC 01 |
| TOP and subcontractor summaries | Remove from active visual hierarchy | EPIC 01 |
| Right analytical column | Donut + Selected Cell Details from in-memory model | EPIC 04 |
| Current drilldown card | Supersede with FDS detail panel/grid | EPIC 04/05 |
| Navigation | Preserve until navigation EPIC | EPIC 06 |

## Major incompatibility in `bfc38f2`

The earlier incremental drilldown conflicts with the approved FDS:

- Heatmap selection calls hidden `btnHome_LoadPunchDrilldown`.
- That control invokes `Warroom_Punches_Filtered_Paged` on each selection.
- FDS §§89–91 and §§162–165 require selection to update application state only and prohibit Flow calls from the heatmap.
- The source was not rebuilt into the packaged `.msapp`, so the commit is not independently deployable.
- Its layout does not implement the canonical Donut / Detail / Grid structure.

This commit remains recoverable evidence and was not pushed or merged. It should be reverted or explicitly superseded before EPIC 01; history must not be rewritten silently.

## Phase Zero modifications

No Canvas, Flow, or SQL control was modified. This report is documentation only.

## Gate clearance required

1. Open the baseline app at commit `453cd8e` in Power Apps Studio.
2. Confirm import/formula compilation with no unresolved references.
3. Confirm Home_1 opens and project, template, and refresh work.
4. Confirm the dashboard bundle Flow completes in development.
5. Record Product Owner acceptance of Phase Zero.
6. Authorize either `git revert bfc38f2` or a superseding EPIC 01 change.

## Rollback

Revert the documentation commit. The immutable ZIP and commit `453cd8e` remain restoration sources.
