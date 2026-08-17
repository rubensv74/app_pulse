# Warroom_ExportPunchReviewToExcel — contract v1

**Status:** design-approved for PR-EXP-C03C2A  
**Purpose:** export exactly the Punches currently contained in the Punch Review queue without changing the existing Punch List export Flow.

## Design decision

Create a dedicated Flow:

```text
Warroom_ExportPunchReviewToExcel
```

It is based on `Warroom_ExportPunchesToExcel_Codex` but adds a mandatory Review Queue payload.

The original Flow remains unchanged during this capability.

## Request contract

Input order for the Power Apps V2 trigger:

| # | Input | Type | Meaning |
|---:|---|---|---|
| 1 | `ProjectId` | Number | Internal project ID used by SQL |
| 2 | `SubsystemCode` | Text | Legacy-compatible filter; normally blank for Review Queue |
| 3 | `TemplateId` | Number | Punch template ID |
| 4 | `CategoryCode` | Text | Legacy-compatible filter; normally blank for Review Queue |
| 5 | `StatusCode` | Text | Legacy-compatible filter; normally blank for Review Queue |
| 6 | `PunchDiscipline` | Text | Legacy-compatible filter; normally blank for Review Queue |
| 7 | `Subcontractor` | Text | Legacy-compatible filter; normally blank for Review Queue |
| 8 | `CustomFiltersJson` | Text | Existing custom filter contract; normally `[]` for exact queue export |
| 9 | `RequestedByEmail` | Text | Requesting user email |
| 10 | `RequestedByName` | Text | Requesting user display name |
| 11 | `ExportMode` | Text | `CLIENT` or `INTERNAL` |
| 12 | `SelectedColumnsJson` | Text | Existing selected-column array contract |
| 13 | `WorkItemIdsJson` | Text | Exact Review Queue JSON payload |

## WorkItemIdsJson contract

Canonical shape:

```json
[
  {"WorkItemId":70381},
  {"WorkItemId":653757}
]
```

Rules:

- must be valid JSON;
- must contain at least one item;
- every WorkItemId must be a positive integer;
- duplicates are forbidden;
- SQL must resolve the exact same cardinality;
- partial export is forbidden.

The SQL authority is:

```text
warroom.usp_ExportProjectPunchesExtended_Pivoted
```

with optional backend parameter:

```sql
@WorkItemIdsJson NVARCHAR(MAX) = NULL
```

The dedicated Flow MUST fail closed. It must never convert a missing Review Queue payload into a normal unscoped export.

Recommended SQL binding expression in the dedicated Flow:

```text
if(empty(triggerBody()?['text_10']), '[]', triggerBody()?['text_10'])
```

Assuming the new trigger input is appended after the existing 12 inputs and Power Automate assigns it internal key `text_10`.

If Power Automate assigns a different internal key, use the generated dynamic content token for `WorkItemIdsJson` instead; the functional requirement is the same.

## SelectedColumnsJson contract

Existing shape:

```json
[
  {"ColumnKey":"Code","ColumnLabel":"Punch code","SortOrder":100},
  {"ColumnKey":"Description","ColumnLabel":"Punch description","SortOrder":110}
]
```

The existing Flow parses an array whose items require:

- `ColumnKey` string;
- `ColumnLabel` string;
- `SortOrder` number.

Column selection policy remains a later UI capability. C03C2 only establishes the exact queue transport.

## Response contract

Preserve the existing response:

| Output | Type |
|---|---|
| `success` | Boolean |
| `fileUrl` | Text |
| `fileName` | Text |
| `rowCount` | Number |
| `message` | Text |

## Safety invariant

For Punch Review:

```text
Review Queue count = requested WorkItem count = exported row count
```

If any equality fails, the export must fail; no partial Excel may be presented to the user.
