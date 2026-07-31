# RC1-01 Environment Validation Protocol

Classification: **PENDING ENVIRONMENT VERIFICATION**

Date: 2026-07-31  
Scope: controlled development/integration environment only  
Repository implementation changes: none

## Purpose

Determine whether the snapshot generator and refresh process deployed in the target environment match the repository evidence used by Executive Dashboard RC1.

This protocol does not authorize deployment, procedure replacement, data correction, Power Apps changes, Flow changes or contract changes.

## Reference evidence

- Historical generator commit: `e4d9b8f`.
- Historical generator Git blob: `a04e4857013aef2d9550e2202f556a1273171ab8`.
- Recovered-content SHA-256: `7AFB19CA31A319C34CFC1249CFED06EC6955220629B1898EE3575380E1A963EE`.
- Historical model Git blob: `3218abb3fbdc87a70371d5b20b56358da008941e`.
- Historical contract Git blob: `06e1b45d19746b56c1c1042f5abfed2d5e535815`.
- Read-only diagnostic: `sql/diagnostics/reconcile_punch_dashboard_distribution.sql`.
- Diagnostic SHA-256 at preparation: `71F76A7326786A837B7395D924BAAFE66A33E85ACF078A0EB33F67A3F440AD89`.

The recovered generator constructs one deduplicated `#PunchBase`, uniquely keyed by `PunchId`, and derives both Category×Status and Subsystem×Category×Status aggregates from that same population.

## 1. Preconditions

### Authorization

- Product Owner approves the ProjectId/TemplateId test contexts.
- DBA approves read-only execution in a non-production development or integration database.
- An evidence owner and execution timestamp are assigned.
- No production execution is permitted by this protocol.

### Environment

- The exact server, database and environment identity are recorded outside committed repository files.
- The executing identity has metadata/read access only.
- No deployment or refresh is running concurrently.
- A completed snapshot exists for at least one approved ProjectId/TemplateId.
- Sensitive Punch descriptions or personal information will not be copied into Git evidence.

### Required objects

Confirm existence of:

- `warroom.usp_GeneratePunchDashboardSnapshot`;
- `warroom.usp_GetOrRefreshPunchDashboardBundle`, if deployed;
- `warroom.usp_GetPunchDashboardBundle`;
- `warroom.PunchDashboardSnapshotRun`;
- `warroom.PunchDashboardSnapshotCategoryStatus`;
- `warroom.PunchDashboardSnapshotSubsystem`;
- `warroom.PunchReportStatusConfig`;
- `dbo.wap_PunchPaged`;
- `dbo.wap_Category`.

Confirm `wap_PunchPaged` exposes the diagnostic columns: Id, Code, ProjectId, TemplateID, CategoryCode, StatusCode, SubSystemCode, SubSystemDesc and LastModifiedAt.

### Test contexts

Use at minimum:

1. a normal Project/Template containing multiple statuses, categories and subsystems;
2. a context containing blank or unmapped subsystem source values;
3. latest and previous completed snapshots for one context;
4. a sparse or zero-result context, when available.

Do not commit actual environment identifiers.

## 2. SQL diagnostic execution sequence

### Step 1 — Capture deployed object identity

Using DBA-approved read-only metadata queries, capture:

- `OBJECT_DEFINITION` for the generator, refresh wrapper and Bundle procedure;
- object create/modify dates;
- database engine version;
- procedure text hashes calculated in the controlled evidence workspace;
- snapshot table columns, keys, foreign keys and indexes.

Do not alter or recompile any object.

### Step 2 — Compare generator lineage

Compare the deployed generator with the recovered evidence. Confirm specifically:

- ProjectId and TemplateId validation;
- active/included template and status filters;
- active category filter;
- status/category/subsystem normalization;
- `ROW_NUMBER() PARTITION BY PunchId` deduplication;
- unique PunchBase key;
- CategoryStatus and Subsystem aggregates sourced from the same PunchBase;
- transaction boundary and completed-run update;
- retention strategy.

Textual formatting may differ. Any semantic difference must be recorded.

### Step 3 — Identify the runtime refresh trigger

Determine which environment artifact invokes snapshot generation:

- refresh wrapper;
- Power Automate Flow;
- SQL Agent job;
- Fabric/Data Factory pipeline;
- application/manual action;
- another scheduler.

Record its enabled state, schedule/event, parameters, ownership and last successful execution. Do not trigger a refresh unless separately authorized.

### Step 4 — Prepare the diagnostic

Create a temporary execution copy of:

`sql/diagnostics/reconcile_punch_dashboard_distribution.sql`

Set only:

- `@ProjectId`;
- `@TemplateId`;
- optional `@SnapshotRunId`.

Verify the diagnostic hash before parameter substitution. Do not commit the parameterized copy.

### Step 5 — Execute against the latest completed snapshot

Run the diagnostic once for each approved context. Preserve all 13 result sets without editing or normalizing differences.

### Step 6 — Execute against a previous snapshot

For one representative Project/Template, set an approved previous completed SnapshotRunId and repeat. This detects lineage drift between runs.

### Step 7 — Correlate Bundle output

Run the existing Bundle retrieval through an approved read-only method and confirm:

- returned SnapshotRunId matches the diagnostic context;
- `distribution` equals CategoryStatus status roll-up;
- `subsystems` equals Subsystem snapshot rows;
- ProjectId and TemplateId context is unchanged.

Do not invoke a refresh as part of this comparison.

### Step 8 — Preserve evidence

Store outside source control:

- environment identity;
- object definitions/hashes;
- refresh-trigger evidence;
- parameters and SnapshotRunIds;
- all diagnostic result sets;
- Bundle output;
- executor, timestamp and approval reference.

## 3. Expected result sets

| No. | Result set | Expected evidence |
|---|---|---|
| 01 | Snapshot and configuration | Correct Project/Template, COMPLETED state and non-null source count |
| 02 | Base population | Raw, eligible and deduplicated Punch counts |
| 03 | Aggregate populations | CategoryStatus and Subsystem totals compared with SourcePunchCount |
| 04 | Duplicate Punch IDs | Source duplicates exposed; generator deduplication explains them |
| 05 | Duplicate business codes | Informational business-key collisions |
| 06 | Excluded/unmapped Punches | Separate flags for blank/excluded status, category and subsystem |
| 07 | NULL/blank dimensions | Explicit counts by dataset and dimension |
| 08 | Zero/negative aggregates | Normally empty; any row requires explanation |
| 09 | Counts by status | Base, distribution and subsystem-derived counts with zero deltas |
| 10 | Counts by category | Base and both aggregate roll-ups with zero deltas |
| 11 | Counts by subsystem | Deduplicated base versus snapshot with zero delta |
| 12 | Distribution differences | Empty when counts, percentages and status metadata agree |
| 13 | Duplicate aggregate keys | Empty when target business keys are unique |

Aggregate tables intentionally contain no PunchId. The unavailable aggregate distinct-ID metrics must remain NULL and must not be inferred.

## 4. Acceptance criteria

The deployed environment matches repository lineage only when all mandatory criteria pass.

### Generator and trigger

- Deployed generator exists.
- Its semantics match the recovered generator or every difference is proven non-functional.
- One active refresh owner/trigger is identified.
- Trigger parameters preserve ProjectId and TemplateId.
- Latest completed run can be traced to that trigger.

### Population

- Eligible deduplicated Punch count equals SnapshotRun.SourcePunchCount.
- CategoryStatus total equals SourcePunchCount.
- Subsystem total equals SourcePunchCount.
- CategoryStatus and Subsystem totals are equal.
- Per-status and per-category deltas are zero.
- Base-versus-Subsystem deltas are zero.

### Mapping and integrity

- Blank subsystem Punches are retained under `NO_SUBSYSTEM`.
- Statuses are active/included and normalized consistently.
- Categories are active for the selected Template.
- No unexplained null/blank aggregate keys exist.
- No zero/negative aggregate rows exist unless explicitly designed and documented.
- No duplicate aggregate business keys exist.
- Status name, order and color metadata agree between both aggregates.

### Contract

- Bundle SnapshotRunId matches the diagnostic run.
- Bundle `distribution` matches CategoryStatus roll-up.
- Bundle `subsystems` matches Subsystem rows.
- No additional runtime filter changes either population.

Passing one Project/Template is insufficient. All approved representative contexts must pass.

## 5. Interpretation of discrepancies

| Discrepancy | Likely interpretation | Required response |
|---|---|---|
| Generator missing | Environment cannot reproduce snapshots | Stop; obtain deployment/owner evidence |
| Generator semantics differ | Environment drift from recovered lineage | Classify difference before any integration |
| Trigger not identifiable | Snapshot freshness/governance unknown | Stop; environment owner must identify process |
| SourcePunchCount differs from eligible distinct base | Deduplication/filter/version drift | Preserve rows and investigate generator |
| CategoryStatus total differs from SourcePunchCount | Distribution aggregate defect or stale/mixed run | Stop integration |
| Subsystem total differs from SourcePunchCount | Mapping loss/duplication or generator drift | Stop integration |
| A/B status delta nonzero | Global functional equivalence fails | Return RC1-01 to contract decision |
| NO_SUBSYSTEM missing for blank source | Unmapped Punch loss | Quantify affected Punches |
| Metadata-only mismatch | Labels/order/colors can bias presentation | Resolve configuration lineage |
| Zero/negative aggregate row | Unexpected materialization or corruption | Investigate before integration |
| Bundle differs from snapshot tables | Bundle procedure/version/cache mismatch | Stop integration |
| Latest passes, previous fails | Historical lineage drift | Determine deployment boundary and affected runs |

Never silently trim, coalesce, exclude or correct discrepancies during evidence collection.

## 6. Decision tree

```text
Start
  |
  +-- Generator exists?
  |     |
  |     +-- No --> Environment mismatch; stop and obtain generator deployment evidence.
  |     |
  |     +-- Yes
  |           |
  |           +-- Semantics match recovered lineage?
  |                 |
  |                 +-- No --> Classify deployed-version drift; RC1-01 remains open.
  |                 |
  |                 +-- Yes
  |                       |
  |                       +-- Active refresh trigger identified and traceable?
  |                             |
  |                             +-- No --> Environment governance gap; RC1-01 remains pending.
  |                             |
  |                             +-- Yes
  |                                   |
  |                                   +-- Diagnostic executes read-only for all contexts?
  |                                         |
  |                                         +-- No --> Preserve error; resolve schema/access mismatch.
  |                                         |
  |                                         +-- Yes
  |                                               |
  |                                               +-- Base = SourceRun = A total = B total?
  |                                                     |
  |                                                     +-- No --> Quantify population bias; contract review required.
  |                                                     |
  |                                                     +-- Yes
  |                                                           |
  |                                                           +-- Status/category/subsystem deltas all zero?
  |                                                                 |
  |                                                                 +-- No --> Functional equivalence not proven.
  |                                                                 |
  |                                                                 +-- Yes
  |                                                                       |
  |                                                                       +-- Metadata, null, zero and key checks pass?
  |                                                                             |
  |                                                                             +-- No --> Resolve integrity/configuration drift.
  |                                                                             |
  |                                                                             +-- Yes
  |                                                                                   |
  |                                                                                   +-- Bundle matches same snapshot tables?
  |                                                                                         |
  |                                                                                         +-- No --> Bundle runtime mismatch.
  |                                                                                         |
  |                                                                                         +-- Yes --> Environment matches repository lineage.
```

## Outcome recording

The Product Owner/DBA shall record exactly one environment outcome:

- `ENVIRONMENT MATCHES REPOSITORY SNAPSHOT LINEAGE`;
- `ENVIRONMENT VERSION DRIFT IDENTIFIED`;
- `ENVIRONMENT REFRESH PROCESS NOT TRACEABLE`;
- `RUNTIME RECONCILIATION FAILED`.

Until signed evidence exists, RC1-01 remains:

**PENDING ENVIRONMENT VERIFICATION**
