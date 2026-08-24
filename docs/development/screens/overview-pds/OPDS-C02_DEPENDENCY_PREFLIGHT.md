# OPDS-C02 — dependency preflight and corrected contract gate

## Capability

**Capability:** OPDS-C02 — report snapshot workspace  
**Risk:** B  
**Runtime baseline:** `baseline_pulse_1_0_0_5.zip`  
**Baseline date:** 2026-08-15  
**Readiness result:** configuration persistence is confirmed. The remaining gate is the treatment of a published configuration that has no generated Overview snapshot.

## Correction to the first preflight

The first review followed the Overview read flow but did not trace the Configuration publication model far enough. Its conclusion that no stored configuration signal existed was incorrect.

Pulse already persists the authoritative evidence required to decide whether a project has report configuration. No new table or parallel persistence mechanism is needed.

## Authoritative configuration persistence

| Component | Verified behavior |
|---|---|
| `warroom.ReportConfigVersion` | Stores configuration versions per project, including `VersionId`, `ProjectId`, `VersionNo`, `Status`, `PublishedAt` and `PublishedBy` |
| `warroom.usp_ReportConfig_Publish` | Archives the previous published version, creates the new version with `Status = 'Published'`, and snapshots nodes, assignments and completion statuses |
| `warroom.usp_ReportConfig_GetPublishedVersion` | Returns the latest published version for a project |
| `warroom.usp_Home_GetHiveNodesByDiscipline` | Checks the latest published version and rejects the request when none exists |
| `warroom.usp_ReportTasks_FromConfig` | Also uses the published configuration version as its prerequisite |

Therefore the canonical predicate is:

```sql
EXISTS (
    SELECT 1
    FROM warroom.ReportConfigVersion
    WHERE ProjectId = @ProjectId
      AND Status = 'Published'
)
```

The app must not infer this fact from an empty Overview collection or from connector error text.

## Configuration screen and flows

The exported `scr_Config` confirms that configuration is a persisted project concern:

- loads the report tree, assignments and scope;
- assigns and unassigns report groups;
- persists Punch template and report-status inclusion;
- applies the configuration to Overview through `warroom_GenerateOverviewSnapshot`.

The screen evidence agrees with the SQL model: configuration is not a transient Canvas state.

## Current Overview contract

`Warroom_GetOverviewSnapshot` calls `warroom.usp_GetOverviewSnapshot` and currently returns:

```json
{
  "subsystems": [],
  "headers": [],
  "metrics": [],
  "totalCount": 0,
  "generatedOn": ""
}
```

This contract does not expose the configuration state that SQL already knows. This is an exposure gap, not a missing-data or architecture gap.

## Minimal contract extension

Extend `warroom.usp_GetOverviewSnapshot` and pass the following fields unchanged through `Warroom_GetOverviewSnapshot`:

```json
{
  "statusCode": "READY | NO_CONFIGURATION | SNAPSHOT_REQUIRED | NO_DATA",
  "hasPublishedConfig": true,
  "publishedVersionId": 123,
  "hasSnapshot": true,
  "subsystems": [],
  "headers": [],
  "metrics": [],
  "totalCount": 0,
  "generatedOn": ""
}
```

Recommended deterministic classification:

| Condition | `statusCode` |
|---|---|
| No published `ReportConfigVersion` | `NO_CONFIGURATION` |
| Published configuration exists, but no `OverviewSnapshot` exists | `SNAPSHOT_REQUIRED` |
| Snapshot exists, but contains no usable subsystem/report rows | `NO_DATA` |
| Snapshot and usable rows exist | `READY` |
| Flow or connector fails | Power Apps maps `IfError` to `ERROR`; it is not a successful SQL status |

The stored procedure should own the successful business classification. Power Automate should transmit it, and Power Apps should map it directly. Human-readable messages may be displayed but must never drive state selection.

## Existing related signal

`Warroom_GetHiveNodesByDiscipline` already returns a structured `NO_REPORT_CONFIG` code and `scr_Home` uses it to set `varProjectHasReportConfig`. That proves the same concept already exists elsewhere.

It should not be reused as the authoritative Overview contract because:

- it is coupled to Home/Tasks behavior;
- its catch branch currently maps any SQL failure to `NO_REPORT_CONFIG`;
- Overview must be able to classify its own state independently on entry and refresh.

## Validation status

| Criterion | Result | Reason |
|---|---|---|
| Runtime screen baseline available | `PASS` | `scr_Overview_PDS` is present in the export |
| Configuration persistence available | `PASS` | Published versions are stored in `ReportConfigVersion` |
| Authoritative no-configuration predicate available | `PASS` | Latest published version can be queried by project |
| Generate/Get dependencies present | `PASS` | Flow definitions and bindings were inspected |
| Input parameters aligned | `PASS` | Existing screen and workflow definitions agree |
| Configuration state exposed by Get Overview | `PENDING_IMPLEMENTATION` | Source exists but is absent from the response payload |
| No-data independently detectable after extension | `PASS_BY_DESIGN` | Snapshot existence and row existence are separate facts |
| Complete C02 runtime validation | `GATED` | `SNAPSHOT_REQUIRED` needs a product behavior decision |

These are static contract findings. Runtime scenarios still need validation after implementation.

## Current gate: project configured but snapshot absent

There is one material choice before completing the C02 state contract:

1. **Recommended — explicit `SNAPSHOT_REQUIRED` state.** Keep Overview entry read-only and show a clear action to generate/refresh the snapshot.
2. **Generate automatically on entry.** Simpler surface model, but changes current behavior and may execute a comparatively expensive operation whenever the screen opens.
3. **Treat it as `NO_DATA`.** Avoids a new surface but loses an important technical distinction and gives the user a misleading explanation.

The recommended option preserves the current explicit refresh behavior and keeps all outcomes observable without guessing.

## Scope after the gate

Once the behavior is selected:

1. extend `warroom.usp_GetOverviewSnapshot`;
2. extend the Power Automate response payload;
3. map the stable codes in `scr_Overview_PDS`;
4. validate `NO_CONFIGURATION`, `SNAPSHOT_REQUIRED`, `NO_DATA`, `READY` and `ERROR` in Studio/runtime;
5. leave `scr_Overview` unchanged.
