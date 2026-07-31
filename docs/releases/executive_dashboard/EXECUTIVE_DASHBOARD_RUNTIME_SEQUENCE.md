# Executive Dashboard Runtime Sequence

## Intended controlled sequence

```text
Power Apps Home_1
  -> Dashboard Bundle Flow(ProjectId, TemplateId)
    -> usp_GetOrRefreshPunchDashboardBundle
      -> read latest COMPLETED run
      -> [missing/stale/forced] usp_GeneratePunchDashboardSnapshot
        -> acquire context application lock
        -> create RUNNING run
        -> materialize unique #PunchBase
        -> transaction: insert all aggregates + mark COMPLETED
        -> retention cleanup
        -> release lock
      -> usp_GetPunchDashboardBundle
        -> select latest/previous COMPLETED runs
        -> build one JSON payload
    <- one `result` string
  <- parse five payload domains into owned collections
  -> render KPI, Heatmap, Distribution, Detail and Executive Grid
```

Transitions through snapshot publication are deterministic subject to the source timestamp tie described in the architecture review. Readers cannot see partially published snapshots.

## Versioned sequence actually evidenced

```text
Home_1
  -> warroom_GetPunchDashboardBundle Flow
    -> usp_GetPunchDashboardBundle                 [direct reader]
    <- contract 3.0 JSON
  <- snapshotInfo, summary, matrix, timeline,
     insights, subsystems, subcontractors
```

Consequences:

- no generation or staleness decision occurs in this call path;
- a missing completed snapshot returns `hasSnapshot=false` rather than being generated;
- the response has no canonical `punches`, `kpis`, `distribution`, or `detail` sections;
- the client does not demonstrate the five-domain v4 materialization required by the FDS.

## Concurrency sequence

For different project/template contexts, generators proceed independently. For the same context, the first generator holds an exclusive session lock. A second generator receives an immediate lock failure because timeout is zero. The orchestrator does not retry or re-read after that failure, so overlapping stale requests are deterministic at the database lock level but not transparent to the user.

## Failure sequence

An error during generation rolls back aggregate publication, records the run as FAILED when possible, releases the application lock and rethrows. The bundle reader ignores failed/running runs. The supplied implementation does not show automated cleanup for orphaned RUNNING runs caused by session termination outside catch handling.

## Release sequence requirement

Controlled integration must verify one coherent path:

`SQL schema/generator → v4 bundle reader → refresh-aware Flow → five-domain Home_1 consumer`.

Mixing the recovered v3 reader with the current v4 documentation or UI expectations is not a supported release sequence.
