# Executive Dashboard SQL Architecture

## Stored procedures

### `warroom.usp_GeneratePunchDashboardSnapshot`

The sole snapshot producer. It validates context/configuration, obtains an exclusive session application lock scoped by ProjectId and TemplateId, creates a run, materializes/deduplicates `#PunchBase`, writes all aggregate tables atomically, marks the run completed, and applies retention.

Important semantics:

- unique business key: PunchId;
- normalization: upper/trim codes;
- missing subsystem: `NO_SUBSYSTEM`;
- source exclusion: blank/unconfigured statuses and inactive/unconfigured categories;
- concurrency: immediate rejection when the same context is locked;
- failure: rollback plus persistent `FAILED` run where a run ID exists.

### `warroom.usp_GetOrRefreshPunchDashboardBundle`

Cache-policy orchestrator. It generates when no completed snapshot exists, the latest snapshot is at least the configured age, or force refresh is set. Generation output is captured so callers receive only the final JSON result set. This procedure is not invoked by the versioned Flow.

### `warroom.usp_GetPunchDashboardBundle`

Read-only bundle producer over the latest completed snapshot and, where needed, the previous completed snapshot. It emits contract 3.0. Summary, Matrix, Timeline and Insights are derived from snapshot tables; no live Punch source is queried.

### `warroom.usp_GetLatestPunchDashboardSnapshot`

Diagnostic/legacy reader returning four relational result sets: run metadata, CategoryStatus, Subsystem and Subcontractor. It returns empty sets when no completed snapshot exists.

## Tables

### `PunchDashboardSnapshotRun`

Run header and publication boundary. States are constrained to PENDING, RUNNING, COMPLETED and FAILED. The identity key establishes snapshot order. A covering/indexed access path for `(ProjectId, TemplateId, Status, SnapshotRunId)` was not present in supplied DDL.

### `PunchDashboardSnapshotCategoryStatus`

Primary key `(SnapshotRunId, CategoryCode, StatusCode)`. Authoritative CategoryStatus grain and source for Summary, Matrix, Timeline and parts of Insights. Cascade deletion follows run retention.

### `PunchDashboardSnapshotSubsystem`

Primary key `(SnapshotRunId, SubsystemCode, CategoryCode, StatusCode)`. Source for subsystem analysis and subsystem insight. `NO_SUBSYSTEM` prevents loss of unassigned punches.

### `PunchReportStatusConfig`

Project-scoped included/active status configuration with display order. Status labels/colors are resolved from `wap_Status` at generation time and frozen into the snapshot.

## Referenced but not supplied

- `PunchDashboardSnapshotSubcontractor`: required by generator, latest-snapshot reader, bundle and retention cascade behavior.
- `PunchReportTemplateConfig`: required to authorize a template for dashboard generation.
- Source/reference objects: `wap_TemplateProject`, `wap_Status`, `wap_Category`, `wap_PunchPaged`, and `DIM_MASTER_COMPANIES_LH`.

Their absence does not invalidate the visible algorithms, but prevents complete DDL, constraint, index and deployment certification.

## Consistency and indexing

Temporary indexes match all three grouping paths. Persisted aggregate primary keys support reads by SnapshotRunId and enforce unique grains. `COUNT_BIG` is consistent with `BIGINT PunchCount`. Source materialization occurs before the write transaction, reducing transaction duration. `OPTION (RECOMPILE)` trades compilation for context-sensitive cardinality.

The run lookup index, source-table indexes, statistics health and actual execution plans require environment evidence. The schema repeats ProjectId/TemplateId in aggregate rows without an FK enforcing their equality to the run header.

## Determinism limits

Snapshot selection is deterministic by descending identity among completed runs. JSON arrays have explicit ordering. Insight ties include secondary keys in the visible queries. Source deduplication is not fully deterministic when duplicate PunchId rows share the same `LastModifiedAt`; `Id DESC` cannot break a tie inside an Id partition.

## Scalability boundary

The design scales by project/template isolation and bounded retained runs. Large contexts require tempdb memory for `#PunchBase` and its indexes. Historical analytics beyond the retention window and multiple long-lived consumers require a separate retention/archive strategy, not a redesign of the publication pattern.
