# Punch Dashboard Bundle Contract v4.0

The Dashboard Bundle remains the only business-data request initiated by `Home_1`. EPIC 05 extends its JSON response with `punches`; `Home_1` does not invoke `Warroom_Punches_Filtered_Paged`.

## Canonical dashboard domains

| Domain | Current JSON property | Consumer |
|---|---|---|
| KPIs | `kpis` | KPI strip and status totals |
| Matrix | `matrix` | Category/status compatibility matrix |
| Distribution | `distribution` | Status distribution |
| Detail | `detail` | Snapshot and active-context seed |
| Punches | `punches` | Executive Grid only |

The canonical payload domains are `kpis`, `matrix`, `distribution`, `detail`, and `punches`. Legacy analytical properties remain for compatibility, including `summary`, `snapshotInfo`, `subsystems`, `timeline`, `insights`, and `subcontractors`. `subsystems` continues to provide the richer Subsystem × Category × Status heatmap source without creating another request.

## `punches` schema

`punches` is a bounded array of at most 100 rows filtered by Bundle `ProjectId` and `TemplateId`. It is an executive initial-view subset, not the complete operational Punch List.

| Field | Meaning |
|---|---|
| `PunchId` | Canonical identifier |
| `PunchCode`, `PunchDescription` | Display code and description |
| `StatusCode`, `PunchStatus` | Status identity and label |
| `CategoryCode`, `CategoryName` | Category identity and label |
| `SubsystemCode`, `DisciplineCode` | Analytical context keys |
| `ResponsibleCompany` | Existing subcontractor short/full name |
| `ResponsiblePerson` | Existing Punch coordinator |
| `DueDate` | Existing `ClosingDate` value |
| `PriorityCode`, `PriorityColor` | Existing `EntryType` classification and colour |
| `SourceOrder` | Stable initial ordering |

Rows exclude `HOLD` and `VOID` and are deduplicated by `PunchId` where hierarchy joins expose multiple element rows.

## Flow request contract

The single Dashboard Flow invokes `warroom.usp_GetOrRefreshPunchDashboardBundle` with `ProjectId`, `TemplateId`, `RequestedBy`, `ForceRefresh`, `MaxSnapshotAgeMinutes`, and `KeepCompletedRuns`. The orchestrator captures snapshot-generation output internally and exposes only the final Bundle JSON to Power Apps.
## Ownership and compatibility

- `Home_1` filters, sorts, paginates, selects and exports this in-memory subset.
- `Punches_1` owns the complete operational dataset and retains `Warroom_Punches_Filtered_Paged`.
- Dashboard refresh reloads all domains in one Bundle response.
- Missing or empty `punches` becomes an empty collection without invalidating other widgets.
