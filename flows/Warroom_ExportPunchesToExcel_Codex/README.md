# Warroom_ExportPunchesToExcel_Codex

## Versioned artifacts

- Deployable package: `Warroom_ExportPunchesToExcel_Codex.zip`
- Deployable definition: `definition.deploy.json`
- Original source package:
  `Warroom_ExportPunchesToExcel_source_20260728142303.zip`
- Original definition: `definition.source.json`
- Trigger-key correction history: `definition.corrected.json`
- Office Script: `../../office-scripts/BuildPunchExport.ts`
- Export dataset:
  `../../sql/export/usp_ExportProjectPunchesExtended_Pivoted.sql`
- Snapshot registration:
  `../../sql/export/002_register_punch_export_snapshot.sql`

Connection identifiers and SharePoint/Office Script references are
environment-bound. Deployment must rebind them; no credentials are stored.

## Power Apps input contract

Inputs are positional and required:

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

`SelectedColumnsJson` contains `{ColumnKey, ColumnLabel, SortOrder}` business
columns. Power Apps never appends technical fields; the Office Script owns
them.

## Implemented action sequence

1. Initialize project, requester and filename.
2. Normalize export mode and selected columns.
3. Parse selected columns using trigger key `text_9`.
4. Compose filter JSON from the trigger's real internal keys.
5. Execute `warroom.usp_PunchExportLog_Start`.
6. Execute `warroom.usp_ExportProjectPunchesExtended_Pivoted`.
7. Execute `warroom.usp_GetPunchExportColumnMap`.
8. Compose rows, map, row count and export information.
9. Execute `warroom.usp_RegisterPunchExportSnapshot` once for the complete
   dataset. It atomically persists `ExportBatch` and `ExportBatchRow`.
10. Read the SharePoint template and create the export file.
11. Run `BuildPunchExport`.
12. Create the sharing link.
13. Execute `warroom.usp_PunchExportLog_Complete`.
14. Execute `warroom.usp_CompletePunchExportBatch` and transition the snapshot from `CREATED` to `READY`.
15. Return `{success, fileurl, filename, rowcount, message}`.

The template/file actions cannot run unless snapshot registration succeeds.
A structured failure response handles a failed, timed-out or skipped success
response.

## SQL dependencies

- `warroom.usp_PunchExportLog_Start`
- `warroom.usp_ExportProjectPunchesExtended_Pivoted`
- `warroom.usp_GetPunchExportColumnMap`
- `warroom.usp_RegisterPunchExportSnapshot`
- `warroom.usp_PunchExportLog_Complete`
- `warroom.usp_CompletePunchExportBatch`

## Office Script parameters

- `rowsJson`
- `columnMapJson`
- `exportInfoJson`
- `exportMode`
- `selectedColumnsJson`

The script emits and protects contract-v3 metadata. `OriginalValuesJson` is
used only by SQL snapshot persistence and is excluded from the workbook.

## Output contract

```json
{
  "success": true,
  "fileurl": "https://environment-specific-link",
  "filename": "PULSE_Punches_Project_4049_20260729_083000.xlsx",
  "rowcount": 245,
  "message": "Export generated successfully."
}
```

## Deployment

Use only the single checklist at `docs/I01_1_E2E_VALIDATION.md`. The deployable
ZIP already includes the corrected trigger expressions and snapshot action; no
manual intermediate code edits are required.



