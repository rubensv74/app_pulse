# Warroom_StagePunchCommentImport — contract v1

**Status:** prepared for PR-IMP-C05  
**Purpose:** receive one governed INTERNAL workbook, extract only the comment-import contract, stage/validate it in SQL and return the batch summary to Power Apps.  
**Safety:** this Flow never applies comments to production.

## 1. Power Apps trigger contract

Use `Power Apps (V2)` with these inputs:

| # | Input | Type | Meaning |
|---:|---|---|---|
| 1 | `StagingItemId` | Number | SharePoint `PULSE_ImportStaging` item containing exactly one attachment |
| 2 | `ProjectId` | Number | Internal project ID already used by the PULSE SQL contract |
| 3 | `RequestedBy` | Text | Requesting user email |

Power Apps users do not type or see the internal project ID. The app supplies its existing project context.

## 2. File-ingestion boundary

Canvas Apps do not have a generic standalone binary file picker suitable for this workflow. The supported `Attachments` control uploads only when hosted inside a form bound to Microsoft Lists or Dataverse.

For v1 the transport is therefore:

```text
scr_PunchImport
  -> EditForm bound to PULSE_ImportStaging
  -> one .xlsx attachment
  -> SubmitForm
  -> Form.OnSuccess calls Warroom_StagePunchCommentImport with LastSubmit.ID
```

The SharePoint item is transport only; SQL remains the authority for import state.

## 3. Flow sequence

```text
Power Apps (V2)
  1. Get attachments — PULSE_ImportStaging / StagingItemId
  2. Require exactly one attachment
  3. Require .xlsx filename
  4. Get attachment content
  5. Create temporary .xlsx in the same governed SharePoint area used by PULSE exports
  6. Excel Online (Business) — Run script: ReadPunchCommentImport
  7. SQL — Execute stored procedure (V2): warroom.usp_StageValidatePunchCommentImport
  8. Normalize first SQL result row
  9. Delete temporary workbook
 10. Delete staging-list item
 11. Respond to Power Apps
```

Use try/catch/finally scopes so temporary SharePoint artifacts are cleaned on both success and failure whenever they were created.

## 4. Office Script contract

Repository source:

```text
office-scripts/ReadPunchCommentImport.ts
```

The script reads table:

```text
tblPunches
```

and returns one JSON array containing only:

```json
[
  {
    "Export Batch ID": 12345,
    "ProjectId": 4049,
    "TemplateId": 20,
    "Work Item ID": 1292427,
    "Row Checksum": "ABCDEF...",
    "New Comment": "New meeting comment"
  }
]
```

Required governed columns:

- `Export Batch ID`
- `ProjectId`
- `TemplateId`
- `Work Item ID`
- `Row Checksum`
- `New Comment`

Missing technical columns fail closed. This prevents a CLIENT workbook from being treated as import-ready.

## 5. SQL binding

Procedure:

```text
warroom.usp_StageValidatePunchCommentImport
```

Inputs:

| SQL input | Flow value |
|---|---|
| `ProjectId` | trigger `ProjectId` |
| `FileName` | SharePoint attachment filename |
| `RequestedBy` | trigger `RequestedBy` |
| `RowsJson` | result from `ReadPunchCommentImport` |

The procedure is already validated to stage only. It does not insert/update/delete `warroom.PunchComment`.

## 6. Power Apps response contract

Both success and handled-failure responses must expose the same typed outputs:

| Output | Type |
|---|---|
| `success` | Boolean |
| `importBatchId` | Text |
| `status` | Text |
| `fileName` | Text |
| `totalRows` | Number |
| `changedRows` | Number |
| `unchangedRows` | Number |
| `validRows` | Number |
| `warningRows` | Number |
| `errorRows` | Number |
| `conflictRows` | Number |
| `appliedRows` | Number |
| `failedRows` | Number |
| `canCommit` | Boolean |
| `message` | Text |
| `errorsJson` | Text |
| `projectId` | Number |
| `templateId` | Number |

### Type rule

Do not return numeric values as strings. In Power Automate response fields use `int(...)` where necessary. Do not return Boolean values as text; use `bool(...)` or literal Boolean tokens.

This rule is mandatory because the export implementation already demonstrated that a Number output returned as Text causes a Power Apps `JSON parsing error, expected number but got string`.

## 7. State mapping

```text
SQL READY
  -> success=true
  -> status=READY
  -> Power Apps step=PREVIEW

SQL BLOCKED
  -> success=true
  -> status=BLOCKED
  -> Power Apps step=PREVIEW
  -> commit disabled

Technical/transport failure
  -> success=false
  -> status=FAILED
  -> Power Apps remains UPLOAD
```

A validation failure is not a technical Flow failure. `BLOCKED` is a governed business result and must be returned normally so the user can inspect it.

## 8. Acceptance gate for PR-IMP-C05

PR-IMP-C05 is not accepted until a real INTERNAL workbook passes through:

```text
Power Apps attachment
-> SharePoint staging
-> Office Script
-> SQL Stage/Validate
-> typed Flow response
-> Power Apps Preview state
```

At this gate:

```text
Production PunchComment delta = 0
```

Commit remains out of scope.
