# Executive Dashboard Data Pipeline

## Scope and authority

This document describes the recovered SQL implementation and contrasts it with the currently versioned integration artifacts. The recovered SQL is authoritative for backend behavior; it emits contract 3.0. The repository v4 contract represents the approved target required by the FDS, not the behavior of the recovered reader.

## Producer lineage

| Stage | Inputs | Transformation | Output/owner |
|---|---|---|---|
| Context validation | ProjectId, TemplateId | Validates active project-template relation and included template/status configuration | `usp_GeneratePunchDashboardSnapshot` |
| Configuration | `PunchReportStatusConfig`, `wap_Status`, `wap_Category` | Normalizes codes, display order, labels and colors | `#StatusConfig`, `#CategoryConfig` |
| Source population | `wap_PunchPaged` | Filters ProjectId/TemplateId, included statuses and active categories; normalizes dimensions; ranks duplicates | `SourcePunch` |
| Canonical population | `SourcePunch`, company lookup | Keeps `rn=1`; applies names; preserves missing subsystem as `NO_SUBSYSTEM` | unique `#PunchBase(PunchId)` |
| Snapshot publication | `#PunchBase` | Aggregates three grains in one transaction | CategoryStatus, Subsystem, Subcontractor snapshots |
| Run publication | current run | Sets count, duration and `COMPLETED` in the same transaction | `PunchDashboardSnapshotRun` |
| Bundle read | latest and previous completed runs | Produces snapshot metadata and analytical JSON | `usp_GetPunchDashboardBundle` |
| Transport | one SQL result row | Returns the `result` JSON string | Dashboard Flow |
| Client materialization | JSON arrays | Parses legacy sections into Power Apps collections | `Home_1` |

## Population rules

- Project filter: exact `p.ProjectId = @ProjectId`.
- Template filter: exact `p.TemplateID = @TemplateId`, with active/included template validation.
- Status population: only nonblank codes present in active, included project status configuration.
- Category population: only codes present in active template categories. A blank source category normalizes to `NO_CATEGORY`, but survives only if that code exists in category configuration.
- Subsystem population: null/blank becomes `NO_SUBSYSTEM` and remains included.
- Subcontractor/discipline population: missing values normalize to sentinel values.
- Deduplication: one row per PunchId, latest `LastModifiedAt`; tied timestamps are not fully ordered.
- Zero values: absent combinations do not produce rows.

## Aggregate ownership

| Dataset | Grain | Authoritative producer | Source |
|---|---|---|---|
| CategoryStatus | Snapshot × Category × Status | snapshot generator | `#PunchBase` |
| Subsystem | Snapshot × Subsystem × Category × Status | snapshot generator | `#PunchBase` |
| Subcontractor | Snapshot × Subcontractor × Discipline × Category × Status | snapshot generator | `#PunchBase` |
| Summary | Status | bundle reader | CategoryStatus |
| Matrix | Category × Status | bundle reader | CategoryStatus |
| Timeline | Snapshot | bundle reader | CategoryStatus over latest runs |
| Insights | ranked insight | bundle reader | snapshot aggregates/current versus previous |

All server aggregates have one producer. The client must not independently recreate a competing aggregate.

## Contract boundary

Recovered SQL contract 3.0 contains:

- `snapshotInfo`
- `summary`
- `matrix`
- `timeline`
- `insights`
- `subsystems`
- `subcontractors`

Approved v4 requires canonical `kpis`, `matrix`, `distribution`, `detail`, and `punches`, retaining legacy aliases only for compatibility. The recovered backend therefore does not supply the approved Executive Grid dataset and does not expose explicit distribution/detail/KPI domains.

## Integration discontinuities

1. The Flow invokes the reader directly, bypassing `usp_GetOrRefreshPunchDashboardBundle`.
2. The client parses legacy 3.0 sections, not all five v4 sections.
3. The FDS prohibits Power Apps from rebuilding server aggregates, yet 3.0 provides no canonical distribution domain.
4. The supplied SQL package omits DDL for two referenced dependencies: the Subcontractor snapshot table and template configuration table.

Until those boundaries agree, the backend lineage is internally sound but the complete application pipeline is not.
