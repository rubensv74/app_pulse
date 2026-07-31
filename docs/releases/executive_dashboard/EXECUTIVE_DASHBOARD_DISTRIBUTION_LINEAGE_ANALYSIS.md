# Executive Dashboard Distribution Lineage Analysis

Status: **DATA CONTRACT AMBIGUITY — FUNCTIONAL EQUIVALENCE NOT PROVEN**

Date: 2026-07-31  
Audited endpoint: `84d56de`  
Analysis only: no Power Apps, SQL or Flow implementation was modified.

## Question

Compare:

- A: canonical `_bundle.distribution`;
- B: the distribution reconstructed by Home_1 from `_bundle.subsystems`.

The comparison distinguishes the overall dashboard state from the selected Heatmap-cell state. They are not the same analytical question.

## Shared upstream lineage

`usp_GetPunchDashboardBundle` selects the latest completed `PunchDashboardSnapshotRun` filtered by both `ProjectId` and `TemplateId`. Both A and B are then filtered by that same `SnapshotRunId`.

The repository does not contain `warroom.usp_GeneratePunchDashboardSnapshot`, which populates the two aggregate tables. Consequently, equal source membership, unique subsystem allocation and identical status inclusion cannot be proven from repository evidence.

## A. Bundle distribution

### Source SQL result set

`distribution` is an alias of `@Summary`. `@Summary` reads `warroom.PunchDashboardSnapshotCategoryStatus`.

Current snapshot query:

- group by `StatusCode`;
- `PunchCount = SUM(PunchCount)`;
- `StatusName`, `StatusOrder` and `StatusColor` use `MAX`;
- previous-snapshot values are joined only for trend fields.

### Contract characteristics

| Attribute | Observed behavior |
|---|---|
| Grain | One row per StatusCode for the current snapshot |
| Project filter | Indirect through SnapshotRun selected by ProjectId |
| Template filter | Indirect through the same SnapshotRun selected by TemplateId |
| Status inclusion | Every status physically present in CategoryStatus; generator policy unavailable |
| Explicit exclusions | None in Bundle read query |
| Category mapping | Categories are summed away; no category field remains |
| Null StatusCode | SQL creates a NULL status group if present |
| Blank StatusCode | Blank is a separate group unless generator normalizes it |
| Null metadata | MAX ignores NULL where another value exists; can remain NULL |
| Zero values | Stored zero rows remain; missing statuses are not synthesized |
| Total population | Sum of CategoryStatus PunchCount; equality to SourcePunchCount is unproven |
| Percentage denominator | Home would use sum of distribution counts; currently it does not parse A |
| Sorting | StatusOrder then StatusCode in SQL |
| Heatmap relationship | Same snapshot, but no Subsystem/Category dimensions |
| KPI relationship | Identical JSON source as kpis/summary, so count totals are structurally identical to KPI status totals |
| Grid relationship | Full snapshot aggregate versus a bounded 100-row Grid subset; not expected to reconcile row-for-row |

### Selection behavior

A is global. It cannot produce the status distribution for a selected Category×Subsystem cell because those dimensions are absent. Direct use after Heatmap selection would incorrectly continue showing the overall distribution unless another contextual dataset were added.

## B. Subsystem-derived distribution

### Source SQL result set

`subsystems` reads every row from `warroom.PunchDashboardSnapshotSubsystem` for the selected SnapshotRunId. Its declared grain contains:

- SubsystemCode/Name;
- CategoryCode/Name;
- StatusCode/Name/Order/Color;
- PunchCount.

Home_1 groups these rows by StatusCode and sums PunchCount. Status metadata comes from `First(StatusRows)`.

### Contract characteristics

| Attribute | Observed behavior |
|---|---|
| Grain before Home aggregation | Subsystem×Category×Status rows |
| Grain after Home aggregation | One row per StatusCode |
| Project filter | Indirect through the same SnapshotRun |
| Template filter | Indirect through the same SnapshotRun |
| Status inclusion | Every status physically present in Subsystem snapshot rows; generator policy unavailable |
| Explicit exclusions | None in Bundle read or Home aggregation |
| Category mapping | Category preserved before aggregation and available for Heatmap selection |
| Null Subsystem | Retained by SQL; Power Apps converts null text to blank |
| Null/blank StatusCode | Power Apps Text produces blank and GroupBy combines blank keys |
| Null metadata | `First` is order-dependent if metadata conflicts |
| Zero values | Stored zero rows remain; missing status rows are not synthesized |
| Total population | Sum across subsystem rows; equality to unique Punches is unproven |
| Percentage denominator | Donut uses sum of the currently derived distribution |
| Sorting | SQL orders SubsystemCode, CategoryOrder, StatusOrder; Home re-sorts by StatusOrder |
| Heatmap relationship | Exact source used to construct Heatmap rows, columns, cells and totals |
| KPI relationship | Same SnapshotRun, but equality to CategoryStatus totals is unproven |
| Grid relationship | Filter keys align with Grid CategoryCode/SubsystemCode; counts represent full snapshot while Grid is bounded |

### Selection behavior

On cell selection Home filters subsystem rows by the selected SubsystemCode and CategoryCode, then groups by StatusCode. This produces the cell-specific Donut and is analytically aligned with the Heatmap cell. Clear Selection reconstructs the overall B distribution.

## Potential non-equivalence mechanisms

1. A Punch may map to more than one subsystem, causing B to exceed A.
2. A Punch without subsystem mapping may exist in A but be absent from B, causing B to be lower.
3. Snapshot generation may apply different status/category eligibility rules to the two tables.
4. Null/blank subsystem or status normalization may differ.
5. Conflicting status metadata uses SQL MAX in A and Power Apps First in B.
6. Zero rows may be materialized in one snapshot table but omitted from the other.

None can be quantified without the generator definition or runtime rows.

## Required runtime/data validation

For representative ProjectId/TemplateId pairs and the exact latest completed SnapshotRunId:

1. full outer join status totals from CategoryStatus and Subsystem;
2. compare grand totals with `PunchDashboardSnapshotRun.SourcePunchCount`;
3. enumerate null/blank status, category and subsystem rows;
4. compare status names/orders/colors for consistency;
5. identify statuses present in only one table;
6. execute the Bundle and compare JSON arrays to table results;
7. select representative Heatmap cells, including null/blank and zero-volume cases;
8. reconcile cell-specific B counts with authoritative unique Punch-level data;
9. verify whether a Punch can contribute to multiple subsystem rows;
10. repeat for at least one previous snapshot to detect lineage drift.

Suggested read-only reconciliation is defined in the companion reconciliation document. No query was executed during this analysis.

## Recommendation

Preserve the current implementation pending evidence. Do not replace selected-cell derivation with the global Bundle distribution. After runtime reconciliation:

- if global A and global B match for all tested snapshots and generator rules prove invariant equality, A may seed overall/clear state while B remains authoritative after selection;
- if they differ, the Product Owner must define whether KPI-global population or Heatmap-drill population governs the overall Donut.

## Conclusion

**INSUFFICIENT EVIDENCE**
