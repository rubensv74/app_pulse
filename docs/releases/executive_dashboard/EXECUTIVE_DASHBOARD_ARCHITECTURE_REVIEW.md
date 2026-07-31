# Executive Dashboard Architecture Review

Date: 2026-07-31  
Review type: static architecture certification  
SQL evidence: `RC01-01.txt`, SHA-256 `4903C66F3678BBA171931636018E700B97E54F13E68C1A6EA69FCC4B4FA00B06`

## Executive assessment

The recovered snapshot implementation has a sound core: one project/template-scoped, deduplicated `#PunchBase` produces the CategoryStatus, Subsystem and Subcontractor aggregates; completed runs are transactionally published; per-context generation is serialized with an application lock; and readers select completed snapshots only.

The end-to-end release architecture is not certifiable, however. The recovered authoritative bundle emits contract `3.0`, while the repository contract and FDS require the five-domain v4 payload. The versioned Flow calls the reader directly instead of the refresh orchestrator, and the versioned `Home_1` source consumes legacy sections without consuming `punches`. These are contract and runtime discontinuities, not cosmetic observations.

## Certification findings

| ID | Severity | Finding | Evidence | Release effect |
|---|---|---|---|---|
| AR-01 | Blocking | Authoritative SQL returns `snapshotInfo`, `summary`, `matrix`, `timeline`, `insights`, `subsystems`, `subcontractors`, `contractVersion=3.0`; it does not return v4 `kpis`, `distribution`, `detail`, or `punches`. | Recovered `usp_GetPunchDashboardBundle`; repository `PUNCH_DASHBOARD_BUNDLE_V4.md` | Producer and approved consumer contract differ. |
| AR-02 | Blocking | The versioned Dashboard Flow executes `usp_GetPunchDashboardBundle`, not `usp_GetOrRefreshPunchDashboardBundle`. | Flow action `SP` | The documented optional refresh path is unreachable from the application pipeline. |
| AR-03 | Blocking | Versioned `Home_1` parses only legacy payload sections and contains no `_bundle.punches` consumption. | `scr_Home_1.fx.yaml` refresh formula | The FDS Executive Grid cannot be supplied by the authoritative SQL payload. |
| AR-04 | Blocking package gap | The supplied artifact set references `PunchDashboardSnapshotSubcontractor` and `PunchReportTemplateConfig`, but their definitions are absent from the stated baseline package. | Generator and bundle dependencies | The supplied SQL set is not independently deployable or schema-certifiable. |
| AR-05 | Major | `ROW_NUMBER()` deduplicates by `PunchId` using `LastModifiedAt DESC, Id DESC`; because `Id` is constant inside a partition, equal timestamps have no final tie-breaker. | `SourcePunch` CTE | Selection is not provably deterministic for tied duplicate source rows. |
| AR-06 | Major | Concurrent stale-cache callers can both decide to generate; the second generator uses `LockTimeout=0` and fails instead of waiting and re-reading the newly completed snapshot. | Orchestrator plus generator | Valid concurrent requests can produce an avoidable application error. |
| AR-07 | Major | Snapshot aggregates are sparse: zero-valued category/status/subsystem combinations are not generated. | `GROUP BY` inserts from `#PunchBase` | Any complete heatmap axis/zero-cell behavior must be explicitly owned elsewhere; the FDS forbids the Heatmap rebuilding totals. |
| AR-08 | Observation | `PunchDashboardSnapshotRun` has only its identity PK in the supplied DDL; latest-snapshot reads filter by project/template/status and order by run ID. | Table DDL and all readers | Lookup cost will grow with retained contexts/runs; validate the deployed supporting index before scale approval. |
| AR-09 | Observation | Aggregate rows repeat ProjectId/TemplateId but the FK validates only SnapshotRunId. | Snapshot table DDL | Incorrect metadata could be inserted by another producer; current producer is consistent, but the schema does not enforce it. |

## Data lineage certification

The lineage inside the recovered SQL is unambiguous:

`wap_PunchPaged` + status/category/template configuration + company lookup

→ normalized and deduplicated `#PunchBase` (`PunchId` unique)

→ atomic inserts into snapshot aggregate tables

→ completed `PunchDashboardSnapshotRun`

→ `usp_GetPunchDashboardBundle`

→ JSON contract 3.0.

CategoryStatus, Subsystem and Subcontractor each have exactly one authoritative SQL producer: `usp_GeneratePunchDashboardSnapshot`. Summary, Matrix, Timeline and Insights each have exactly one SQL producer: `usp_GetPunchDashboardBundle`. `NO_SUBSYSTEM` is preserved. Blank/unmapped status and category values are excluded through configured inner joins; this exclusion is deterministic but must be treated as an explicit population rule.

The lineage ceases to be consistent after the SQL reader because the Flow and Power Apps artifacts do not implement the approved refresh and v4 consumer path.

## Snapshot architecture

- Lifecycle: `RUNNING` is inserted before extraction; aggregate inserts and transition to `COMPLETED` share one transaction; errors mark the run `FAILED`.
- Locking: a session-owned, project/template-specific exclusive application lock prevents simultaneous generators for the same context without blocking unrelated contexts.
- Consistency: `XACT_ABORT`, rollback in `CATCH`, and completed-only reads prevent partial aggregates from becoming visible.
- Immutability: completed aggregate rows are not updated; retention removes old runs by cascade delete. Immutability therefore applies only within the retention window.
- Retention: bounded to 1–20 completed runs, default 3 in the generator and 7 through the orchestrator.
- Idempotency: repeated generation deliberately creates a new immutable snapshot; it is operationally repeatable, not identifier-idempotent.
- Failure handling: failed runs remain auditable. Lock release is attempted on success and error.
- Cleanup: completed retention is implemented; failed/running orphan cleanup is not shown.

## SQL quality assessment

The temporary indexes align with the three aggregation grains, `COUNT_BIG` matches persisted `BIGINT`, and `OPTION (RECOMPILE)` is reasonable for highly variable project/template cardinalities. Transaction scope excludes source materialization, limiting write-lock duration. JSON is assembled after snapshot selection, so readers do not mutate state.

Material risks are limited to the nondeterministic timestamp tie, sparse zero rows, latest-run index evidence, immediate lock rejection, and potential memory/tempdb pressure from fully materializing a large project/template. `FORMAT` is used only for a maximum of five insight rows and is not a meaningful scalability concern.

## Future evolution

The snapshot-run/aggregate-table pattern supports additional widgets, dimensions, consumers and historical comparisons without redesign. New dimensions require a new aggregate table or a versioned grain; new consumers can read immutable completed runs. Long-term analytics will require a retention policy distinct from the current operational cache. Contract evolution must be explicitly versioned and deployed atomically across SQL, Flow and Power Apps.

## Required release conditions

1. Select and consistently deploy one contract version; for the approved FDS this is v4 with `kpis`, `matrix`, `distribution`, `detail`, and `punches`.
2. Route the Dashboard Flow through the approved refresh policy or formally document an external refresh owner.
3. Demonstrate `Home_1` consumption of all five domains without client-side reconstruction of server aggregates.
4. Supply and validate all referenced DDL dependencies.
5. Resolve or explicitly accept AR-05 through AR-09 with evidence.

## Conclusion

ARCHITECTURE NOT READY FOR PRODUCTION
