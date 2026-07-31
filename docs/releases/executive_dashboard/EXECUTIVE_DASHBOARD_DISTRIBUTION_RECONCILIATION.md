# Executive Dashboard Distribution Reconciliation

Status: **DATA CONTRACT AMBIGUITY — FUNCTIONAL EQUIVALENCE NOT PROVEN**

No runtime data was queried and no implementation was changed.

## Reconciliation matrix

| Dimension | `_bundle.distribution` | Derived from `subsystems` | Equivalent |
|---|---|---|---|
| Source population | Category×Status snapshot aggregate | Subsystem×Category×Status snapshot aggregate | Unproven |
| Project filter | Latest completed run for ProjectId+TemplateId | Same SnapshotRunId | Yes at run selection |
| Template filter | Latest completed run for ProjectId+TemplateId | Same SnapshotRunId | Yes at run selection |
| Status filter | All rows present in CategoryStatus; generator rules unknown | All rows present in Subsystem; generator rules unknown | Unproven |
| Aggregation grain | Status | Status after summing Subsystem×Category×Status | Algebraically compatible only if populations are lossless and nonduplicated |
| Total count | SUM CategoryStatus PunchCount | SUM Subsystem PunchCount | Unproven |
| Percentage base | Sum of A counts | Sum of current B counts; selected cell uses cell total | Different after selection |
| Null handling | SQL NULL group; metadata via MAX | Text null→blank; grouping by blank; metadata via First | Not guaranteed |
| Zero handling | Stored zero rows retained; absent statuses omitted | Stored zero rows retained; absent statuses omitted | Unproven materialization parity |
| Heatmap compatibility | No Subsystem/Category keys | Same source and keys as Heatmap | B compatible; A global only |
| Grid compatibility | Global full-snapshot aggregate versus bounded Grid | Filter keys align; still full-snapshot counts versus bounded Grid | Neither count-equivalent to bounded Grid |

## Detailed relationship comparison

### KPI totals

A is the same `@Summary` JSON used for `kpis`; therefore A and KPI status totals are structurally identical. B is from another snapshot table and needs reconciliation before claiming equality.

### Heatmap

B is the Heatmap lineage. Home builds Heatmap dimensions and cells from subsystem rows. A cannot identify a selected cell and therefore cannot replace B for post-selection behavior.

### Executive Grid

The Grid contains at most 100 Punches. Both A and B can represent a larger snapshot population. Grid row counts must not be used as the denominator for either global distribution. For a selected cell, Grid emptiness can reflect subset truncation even when B reports Punches.

### Expected state transitions

| State | A behavior | Current B behavior |
|---|---|---|
| Initial load | Overall status distribution | Overall status distribution reconstructed from all subsystem rows |
| Cell selected | Remains overall; lacks cell dimensions | Filters exact Category×Subsystem, then groups by status |
| Clear selection | Overall status distribution | Reconstructs overall subsystem-derived distribution |
| Project/Template refresh | New SnapshotRun | New rows from the same new SnapshotRun |

Only the initial and clear-selection states are candidates for A/B equivalence testing. Selected state is intentionally B-specific.

## Read-only SQL validation design

Execute only after explicit environment authorization:

```sql
DECLARE @SnapshotRunId BIGINT = /* controlled completed run */;

WITH A AS
(
    SELECT
        StatusCode,
        PunchCount = SUM(PunchCount),
        StatusNameMin = MIN(StatusName),
        StatusNameMax = MAX(StatusName),
        StatusOrderMin = MIN(StatusOrder),
        StatusOrderMax = MAX(StatusOrder),
        StatusColorMin = MIN(StatusColor),
        StatusColorMax = MAX(StatusColor)
    FROM warroom.PunchDashboardSnapshotCategoryStatus
    WHERE SnapshotRunId = @SnapshotRunId
    GROUP BY StatusCode
),
B AS
(
    SELECT
        StatusCode,
        PunchCount = SUM(PunchCount),
        StatusNameMin = MIN(StatusName),
        StatusNameMax = MAX(StatusName),
        StatusOrderMin = MIN(StatusOrder),
        StatusOrderMax = MAX(StatusOrder),
        StatusColorMin = MIN(StatusColor),
        StatusColorMax = MAX(StatusColor)
    FROM warroom.PunchDashboardSnapshotSubsystem
    WHERE SnapshotRunId = @SnapshotRunId
    GROUP BY StatusCode
)
SELECT
    StatusCode = COALESCE(A.StatusCode, B.StatusCode),
    CategoryStatusCount = A.PunchCount,
    SubsystemCount = B.PunchCount,
    Delta = COALESCE(B.PunchCount, 0) - COALESCE(A.PunchCount, 0),
    A.StatusNameMin, A.StatusNameMax,
    B.StatusNameMin, B.StatusNameMax,
    A.StatusOrderMin, A.StatusOrderMax,
    B.StatusOrderMin, B.StatusOrderMax,
    A.StatusColorMin, A.StatusColorMax,
    B.StatusColorMin, B.StatusColorMax
FROM A
FULL OUTER JOIN B
    ON A.StatusCode = B.StatusCode
    OR (A.StatusCode IS NULL AND B.StatusCode IS NULL);
```

Additional controlled queries must compare both grand totals with SourcePunchCount and enumerate:

- NULL/blank StatusCode;
- NULL/blank CategoryCode;
- NULL/blank SubsystemCode;
- negative/zero PunchCount;
- duplicate or conflicting status metadata;
- selected Category×Subsystem status totals.

The generator procedure definition is also required to prove unique Punch membership and filter parity; aggregate tables alone cannot do so.

## Decision rule

- Exact equality across statuses, metadata and grand totals is necessary but not sufficient.
- Generator lineage must also prove no multi-subsystem duplication and no loss of unmapped Punches.
- Even if global equivalence is proven, B remains necessary for selected-cell distribution unless the Bundle contract gains contextual distributions.

## Conclusion

**INSUFFICIENT EVIDENCE**
