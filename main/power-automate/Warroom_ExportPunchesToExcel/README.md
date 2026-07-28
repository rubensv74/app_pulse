# Warroom_ExportPunchesToExcel

## Versioned source

- Display name: `Warroom_ExportPunchesToExcel`
- Source export: `Warroom_ExportPunchesToExcel_20260728142303.zip`
- Flow definition: `definition.source.json`
- Corrected deployable definition: `definition.corrected.json`
  (connection references still require environment rebinding)
- Trigger: Power Apps V2
- Office Script source: `../../office-scripts/BuildPunchExport.ts`
- SQL dataset source:
  `../../sql/export/usp_ExportProjectPunchesExtended_Pivoted.sql`

The ZIP and JSON are the supplied environment export. Connection identifiers,
SharePoint site/drive identifiers and the Office Script identifier are
environment-bound references, not reusable credentials. Deployment must rebind
all connection references and select the target Office Script.

## Power Apps input contract

Inputs are positional and all required:

| Position | Trigger key | Title | Type |
|---:|---|---|---|
| 1 | `number` | `ProjectId` | number |
| 2 | `text` | `SubsystemCode` | string |
| 3 | `number_1` | `TemplateId` | number |
| 4 | `text_1` | `CategoryCode` | string |
| 5 | `text_2` | `StatusCode` | string |
| 6 | `text_3` | `PunchDiscipline` | string |
| 7 | `text_4` | `Subcontractor` | string |
| 8 | `text_5` | `CustomFiltersJson` | string |
| 9 | `text_6` | `RequestedByEmail` | string |
| 10 | `text_7` | `RequestedByName` | string |
| 11 | `text_8` | `ExportMode` | string |
| 12 | `text_9` | `SelectedColumnsJson` | string |

`SelectedColumnsJson` is an array of `{ColumnKey, ColumnLabel, SortOrder}`.
Technical columns are owned by the Office Script and must not be appended by
Power Apps.

The supplied definition incorrectly reads `text_SelectedColumnsJson` and named
trigger fields such as `ProjectId`. The trigger actually exposes internal keys
`number`, `text` ... `text_9`. `definition.corrected.json` fixes
`Compose_SelectedColumns_Safe` and `Compose_FilterJson`; the original remains
unchanged for traceability.

## Action sequence

1. Initialize project, requester and filename variables.
2. Normalize export mode and selected-column JSON.
3. Parse selected columns.
4. Execute `warroom.usp_PunchExportLog_Start`.
5. Read the returned `PunchExportLogId`.
6. Execute `warroom.usp_ExportProjectPunchesExtended_Pivoted` with a current
   limit of 50,000 rows.
7. Execute `warroom.usp_GetPunchExportColumnMap`.
8. Compose row data, column map, row count and export information.
9. Read the Excel template from SharePoint.
10. Create the export file in SharePoint and wait for availability.
11. Run `BuildPunchExport` against the created workbook.
12. Create the sharing link.
13. Execute `warroom.usp_PunchExportLog_Complete`.
14. Return `{success, fileurl, filename, rowcount, message}` to Power Apps.

The supplied Flow has a success path only. It has no top-level failure scope,
cleanup path or call that snapshots every exported row in
`warroom.ExportBatchRow`.

## Exact SQL calls

- `warroom.usp_PunchExportLog_Start`
- `warroom.usp_ExportProjectPunchesExtended_Pivoted`
- `warroom.usp_GetPunchExportColumnMap`
- `warroom.usp_PunchExportLog_Complete`

## Office Script parameters

- `rowsJson`
- `columnMapJson`
- `exportInfoJson`
- `exportMode`
- `selectedColumnsJson`

## Output contract

```json
{
  "success": true,
  "fileurl": "https://environment-specific-link",
  "filename": "PULSE_Punches_Project_4049_20260723_100658.xlsx",
  "rowcount": 4,
  "message": "Export generated successfully."
}
```

## Rebuild and deployment

1. Import the supplied ZIP into a non-production Power Automate environment.
2. Apply the two corrected Compose definitions from
   `definition.corrected.json`.
3. Rebind all SQL, SharePoint and Excel Online connection references.
4. Create/update the Office Script from `BuildPunchExport.ts` and bind it in
   `Run_script`.
5. Confirm the four stored procedures exist in the target database.
6. Replace the SharePoint template/site/folder references for that environment.
7. Run the workbook inspection and a real export before enabling the Flow.

No production deployment or connection rebinding was performed by I01.1.
