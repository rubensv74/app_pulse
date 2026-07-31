# RC1-01 Runtime Reconciliation Plan

Status: **READY FOR CONTROLLED DEVELOPMENT-ENVIRONMENT EXECUTION**

No query has been executed.

## Objective

Verify whether the deployed snapshot generator and stored aggregates conform to the recovered historical lineage and whether global `distribution` equals the global distribution derived from `subsystems`.

This plan does not determine which source is authoritative.

## Artifact

`sql/diagnostics/reconcile_punch_dashboard_distribution.sql`

The script:

- requires explicit ProjectId and TemplateId;
- optionally accepts a completed SnapshotRunId;
- uses SELECT-only diagnostics;
- changes no data or schema;
- returns differences without normalizing them.

## Environment and authorization

Run only in a controlled development environment after:

- Product Owner identifies representative ProjectId/TemplateId contexts;
- database read access is approved;
- deployed generator definition is captured;
- execution output can be retained as release evidence;
- sensitive Punch descriptions are excluded from shared evidence.

## Preflight

1. Confirm the database is non-production.
2. Capture server/database/environment identity separately from repository files.
3. Confirm required objects exist.
4. Confirm `wap_PunchPaged` has Id, Code, ProjectId, TemplateID, CategoryCode, StatusCode, SubSystemCode, SubSystemDesc and LastModifiedAt.
5. Set ProjectId and TemplateId in a temporary execution copy; do not commit environment values.
6. Leave SnapshotRunId null for latest completed run or set an explicitly approved run.

## Diagnostic result sets

| Result | Evidence |
|---|---|
| 01 | Snapshot identity, source count and config coverage |
| 02 | Raw, eligible and distinct base Punch population |
| 03 | Aggregate row counts and total Punch counts |
| 04 | Duplicate source Punch identifiers |
| 05 | Duplicate nonblank Punch business codes |
| 06 | Excluded and unmapped Punches with separate reason flags |
| 07 | NULL and blank dimensions |
| 08 | Zero or negative aggregate rows |
| 09 | Base/A/B counts by status and deltas |
| 10 | A/B counts by category |
| 11 | Base/B counts by subsystem |
| 12 | Distribution versus subsystem-derived count, percentage and metadata differences |
| 13 | Duplicate aggregate business keys |

Aggregate tables do not contain PunchId. The script reports their distinct-id metric as unavailable rather than fabricating it.

## Minimum sample

Run against at least:

- one normal Project/Template with multiple statuses/categories/subsystems;
- one context containing blank/unmapped subsystem source values;
- one context with duplicate source rows by PunchId, if available;
- latest and previous completed snapshots for one context;
- one zero-result or sparse context.

## Acceptance evidence for global equivalence

For every tested SnapshotRunId:

- SourcePunchCount equals eligible distinct PunchId count;
- SourcePunchCount equals both aggregate grand totals;
- every status count delta is zero;
- every category roll-up delta is zero;
- no metadata mismatch exists for StatusName/Order/Color;
- unmapped subsystems appear as NO_SUBSYSTEM;
- aggregate business keys are unique;
- no unexplained zero/negative rows exist;
- deployed generator definition matches the recovered grouping/filter rules.

Any difference must be retained verbatim and investigated. Do not correct data as part of reconciliation.

## Selected-cell validation

Even if global equivalence passes, selected-cell behavior remains subsystem-derived:

1. choose representative Category×Subsystem Heatmap cells;
2. sum snapshot subsystem rows by StatusCode for each cell;
3. compare with Home_1 Donut values;
4. compare against authoritative distinct Punch rows using the same Project, Template, Category and Subsystem;
5. record bounded Executive Grid limitations separately.

`_bundle.distribution` cannot validate selected-cell behavior because it has no Category or Subsystem keys.

## Decision gate after execution

- Global equality plus matching deployed generator lineage permits consideration of A for initial/clear state only.
- Selected-cell distribution continues to require B unless the contract is extended.
- Any nonzero unexplained delta returns RC1-01 to contract-owner review.
- No source becomes authoritative without Product Owner approval.

## Evidence package

Retain:

- parameter context without credentials;
- SnapshotRunId and timestamps;
- deployed generator definition/hash;
- all 13 result sets;
- Bundle JSON for the same context;
- Home_1 screenshots/Monitor trace;
- signed reconciliation decision.

Do not store production credentials or sensitive row content in Git.
