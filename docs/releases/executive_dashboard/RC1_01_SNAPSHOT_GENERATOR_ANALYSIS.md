# RC1-01 Snapshot Generator Analysis

Status: **HISTORICAL GENERATOR RECOVERED — RUNTIME VERSION MUST BE VERIFIED**

Date: 2026-07-31  
Implementation changes: none.

## Search scope

The search covered:

- tracked and normally ignored working-tree files;
- SQL, Markdown, Canvas and Workflow content;
- unpacked audit evidence already present locally;
- all Git branches and commit history;
- historical path names and content searches for the generator and snapshot tables.

No scheduled-job definition, SQL Agent job, Fabric pipeline or current Power Automate refresh Flow was found.

## Generator location and lifecycle

`warroom.usp_GeneratePunchDashboardSnapshot` is absent from the current tree but is versioned in Git history:

- canonical historical blob: commit `e4d9b8f`;
- path: `main/screens/Home/PULSE_PunchDashboard_Entregable_02_GenerarSnapshot.sql`;
- generator Git blob: `a04e4857013aef2d9550e2202f556a1273171ab8`;
- recovered-content SHA-256: `7AFB19CA31A319C34CFC1249CFED06EC6955220629B1898EE3575380E1A963EE`;
- model: `main/screens/Home/PULSE_PunchDashboard_Entregable_01_ModeloDatos.sql`;
- model Git blob: `3218abb3fbdc87a70371d5b20b56358da008941e`;
- contract: `main/screens/Home/PULSE_PunchDashboard_Entregable_03_ContratoDatos.md`;
- contract Git blob: `06e1b45d19746b56c1c1042f5abfed2d5e535815`;
- the three files were removed in commit `8b7e08f` five minutes after their move/addition.

The generator is therefore historically versioned, but not present as a deployable current-tree artifact. The deployed environment version cannot be inferred from Git alone.

## Execution lineage

Historical intended path:

```text
usp_GetOrRefreshPunchDashboardBundle
  ├─ evaluates latest completed snapshot age / force flag
  ├─ calls usp_GeneratePunchDashboardSnapshot when required
  └─ calls usp_GetPunchDashboardBundle
```

The current packaged Dashboard Flow does not call the refresh wrapper. It calls `warroom.usp_GetPunchDashboardBundle` directly with ProjectId and TemplateId. No repository trigger that currently generates snapshots was found.

Refresh wrapper behavior documented in the current tree:

- generate when no completed snapshot exists;
- generate when `ForceRefresh = 1`;
- generate when snapshot age reaches `MaxSnapshotAgeMinutes` (default 30);
- retain 1–20 completed runs (default 7 in wrapper);
- return the Bundle only after generation completes.

Whether another external scheduler or operational process invokes the generator is external evidence.

## Recovered generator contract

| Property | Historical implementation |
|---|---|
| Source table | `dbo.wap_PunchPaged` |
| Configuration sources | `PunchReportStatusConfig`, `wap_Status`, `wap_Category`, `wap_TemplateProject`, `PunchReportTemplateConfig` |
| Targets | SnapshotRun, SnapshotCategoryStatus, SnapshotSubsystem, SnapshotSubcontractor |
| Required context | Positive ProjectId and TemplateId |
| Concurrency | Exclusive application lock per ProjectId:TemplateId |
| Source materialization | One `#PunchBase` per run |
| Unique source key | Unique clustered index on `#PunchBase(PunchId)` |
| Deduplication | `ROW_NUMBER() PARTITION BY p.Id ORDER BY LastModifiedAt DESC, Id DESC`; retain rn=1 |
| Atomicity | All aggregate targets written in one transaction; run marked COMPLETED afterward |
| Retention | Deletes completed runs beyond KeepCompletedRuns; FK cascade removes aggregates |

## Filters and mappings

### Project and Template

- verifies active `wap_TemplateProject` relationship;
- verifies included/active `PunchReportTemplateConfig`;
- source predicate is exactly `p.ProjectId = @ProjectId AND p.TemplateID = @TemplateId`.

### Status

- only active and included project status configuration;
- blank configured StatusCode excluded;
- source StatusCode must be nonblank;
- normalization: trim and uppercase;
- Punch rows inner-join the configured status set;
- name/color come from active `wap_Status`;
- display order comes from status configuration.

### Category

- only active categories for the selected TemplateId;
- trim and uppercase;
- null/blank maps to `NO_CATEGORY`;
- display name falls back to description, code, then “No category”;
- Punch rows inner-join the active category set.

### Subsystem

- trim and uppercase;
- null/blank maps to `NO_SUBSYSTEM`;
- name falls back to description, code, then “No subsystem”;
- unmapped Punches are retained rather than discarded.

### Other dimensions

- null subcontractor maps to id -1 and “No subcontractor”;
- null/blank discipline maps to `NO_DISCIPLINE` and “No discipline”.

## Aggregation grains and keys

| Target | Grain / primary key after SnapshotRunId | Count |
|---|---|---|
| CategoryStatus | CategoryCode × StatusCode | `COUNT_BIG(1)` from PunchBase |
| Subsystem | SubsystemCode × CategoryCode × StatusCode | `COUNT_BIG(1)` from the same PunchBase |
| Subcontractor | SubcontractorId × DisciplineCode × CategoryCode × StatusCode | `COUNT_BIG(1)` from the same PunchBase |

No zero rows are synthesized. Only combinations present in PunchBase are persisted.

## Static equivalence implication

Under the recovered generator, global `SUM(PunchCount)` from CategoryStatus and global `SUM(PunchCount)` from Subsystem are mathematically equal because:

1. both aggregate the same materialized PunchBase;
2. PunchBase contains exactly one row per PunchId;
3. every PunchBase row has a normalized non-null SubsystemCode;
4. neither aggregation filters PunchBase further.

Per-status totals should also be equal because StatusCode is carried unchanged into both groupings.

This is strong historical evidence, not proof of the currently deployed procedure version.

## Remaining external evidence

Obtain from the controlled development environment:

- `OBJECT_DEFINITION(OBJECT_ID('warroom.usp_GeneratePunchDashboardSnapshot'))`;
- object create/modify dates and procedure hash;
- definitions of the three snapshot tables and constraints;
- the actual scheduler/Flow/job invoking the generator;
- a controlled execution of the read-only reconciliation script;
- confirmation that `wap_PunchPaged` still exposes the historical source columns.

## Phase A conclusion

The snapshot generator is historically versioned and its lineage is recoverable, but its deployed identity and active trigger remain external evidence.

## Decision-gate status

**READY FOR CONTROLLED RUNTIME RECONCILIATION**
