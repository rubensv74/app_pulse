# EPIC 05 — Executive Grid Data Contract Blocker

Status: **BLOCKED — DATA CONTRACT DECISION REQUIRED**

Date: 2026-07-31  
Branch: `workstream/home-1-punches-1`

## Intended objective

EPIC 05 must implement the Executive Punch Grid with the operational rows corresponding to the current Heatmap context, including sorting, pagination, row selection, Premium Drawer handoff, export, column visibility, and navigation handoff.

## Blocking evidence

The FDS establishes all of the following requirements:

- section 134: consume the dashboard dataset already loaded into Power Apps;
- section 134: do not execute SQL independently and do not invoke Power Automate;
- section 136: display a default executive dataset immediately after a successful refresh;
- section 137: refresh automatically when Heatmap selection changes;
- section 139: expose record-level fields such as Punch Code, Description, Responsible Company/Person, Due Date, and Priority;
- sections 158–159: independent Flow execution is prohibited and absence of any required criterion is a functional defect;
- section 162: all dashboard components must consume one in-memory analytical model retrieved once.

The restored `warroom_GetPunchDashboardBundle` Flow invokes `[warroom].[usp_GetPunchDashboardBundle]` and returns only the first `Table1.result` string. The current Power Apps parser proves that the payload exposes:

- `snapshotInfo`;
- `summary`;
- `matrix`;
- `timeline`;
- `insights`;
- `subsystems`;
- `subcontractors`.

No record-level Punch collection or equivalent Grid array is exposed. In particular, the confirmed bundle contract does not provide Punch Code, Description, Responsible Company/Person, Due Date, or Priority.

`Warroom_Punches_Filtered_Paged` can return record-level Punch rows and is already used by `scr_Punches_1`, but invoking it from Home_1 would introduce a second backend request and an independent Flow execution. That contradicts the mandatory EPIC 05 acceptance criteria and the Single Source of Truth contract.

## Repository checks

| Check | Result |
|---|---|
| Dashboard Bundle workflow response inspected | PASS |
| Home_1 Dashboard Bundle parsing inspected | PASS |
| Required record-level Grid fields present in bundle | FAIL |
| Existing paged Punch service identified | PASS |
| Existing paged service permitted as an independent Home_1 call | FAIL under current FDS |
| Safe repository-only implementation possible without inventing data | NO |

## Required Product Owner / architecture decision

Approve one data-contract path:

1. **Preferred:** extend `usp_GetPunchDashboardBundle` and its JSON payload with a bounded `punches` array containing the required Grid fields, paging metadata, and a documented default ordering. Home_1 then parses that array during the existing single Dashboard Bundle call.
2. Revise the FDS to explicitly authorize `Warroom_Punches_Filtered_Paged` as the Grid's server-side paging service, including when it may be called and how Heatmap synchronization avoids conflicting sources of truth.

The selected contract must also define:

- the Product Owner's default executive dataset when no Heatmap cell is selected;
- canonical field mappings for Responsible Company, Responsible Person, Due Date, and Priority;
- whether export operates over the complete filtered result or only the currently loaded page;
- the paging/sorting contract if rows are bounded in the bundle.

## Work deliberately not performed

- no placeholder or synthetic Punch rows;
- no new SQL procedure;
- no modification of the existing Dashboard Bundle Flow;
- no additional Flow call from Home_1;
- no partial Grid declared complete;
- no official unpack, import, publish, merge, push, or Studio operation.

## Resume point

After an approved contract is available, implement EPIC 05 from `conPunchExecutiveGridWorkspace` and retain the Heatmap as the only analytical-context controller. EPIC 06 remains dependent on the resulting Grid selection/navigation handoff.
