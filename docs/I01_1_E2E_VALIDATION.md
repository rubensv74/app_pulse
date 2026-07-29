# I01.1 - Single E2E deployment and validation round

Execute this checklist only after all repository changes are available in the
target branch. Use a non-production environment.

## 1. Azure SQL

- [ ] Execute `main/sql/import/001_import_foundations.sql`.
- [ ] Execute `main/sql/export/usp_ExportProjectPunchesExtended_Pivoted.sql`.
- [ ] Execute `main/sql/export/002_register_punch_export_snapshot.sql`.
- [ ] Execute `main/sql/import/003_seed_import_columns_v3.sql`.
- [ ] Execute the four scripts again; confirm that the second execution
      completes without duplicate-object or duplicate-mapping errors.
- [ ] Confirm `warroom.ExportBatch.ExportBatchId` is `bigint`.
- [ ] Confirm `warroom.ExportBatchRow.RowVersion` is nullable.
- [ ] Confirm `warroom.usp_RegisterPunchExportSnapshot` returns `Success=1`, `Status=CREATED` and the expected `RowCount` when called by the Flow.
- [ ] Confirm `warroom.usp_CompletePunchExportBatch` changes the same batch to `READY` only after file creation and export-log completion.

## 2. Office Scripts

- [ ] Publish `main/office-scripts/BuildPunchExport.ts`.
- [ ] Confirm the Office Scripts editor reports no TypeScript errors, including
      no TS2352 error.
- [ ] Record/select the published script in the Flow action `Run_script`.

## 3. Power Automate

- [ ] Import
      `main/power-automate/Warroom_ExportPunchesToExcel_Codex/Warroom_ExportPunchesToExcel_Codex.zip`.
- [ ] Confirm the imported display name is
      `Warroom_ExportPunchesToExcel_Codex`.
- [ ] Rebind all Azure SQL, SharePoint and Excel Online connections.
- [ ] Rebind the template path, export folder and published Office Script.
- [ ] Confirm `Compose_ExportMode_Safe` reads trigger key `text_8`.
- [ ] Confirm `Compose_SelectedColumns_Safe` reads trigger key `text_9`.
- [ ] Confirm `Compose_FilterJson` reads `number`, `text`, `number_1` and
      `text_1` through `text_5`.
- [ ] Confirm `SQL_RegisterExportSnapshot` executes
      `warroom.usp_RegisterPunchExportSnapshot`.
- [ ] Confirm `SP_GetTemplateFileContent` runs only after
      `SQL_RegisterExportSnapshot` succeeds.
- [ ] Confirm `SQL_CompleteExportBatch` runs after `usp_PunchExportLog_Complete` and before the success response.
- [ ] Run Flow Checker and confirm there are no errors.

## 4. Power Apps Studio

- [ ] Import/update
      `main/screens/Punches/scr_Punches_1.pa.yaml`.
- [ ] Add or refresh the Flow connection named
      `Warroom_ExportPunchesToExcel_Codex`.
- [ ] Confirm the `.Run(...)` call has the existing twelve arguments in the
      documented order.
- [ ] Check the app and confirm there are no new formula or control errors.
- [ ] Publish only to the non-production test app.

## 5. End-to-end export

- [ ] Select one project and one Punch template.
- [ ] Generate an `INTERNAL` export with at least one editable standard field
      and one editable custom field, when available.
- [ ] Confirm the Flow succeeds and returns `success`, `fileurl`, `filename`,
      `rowcount` and `message`.
- [ ] Confirm one `warroom.ExportBatch` exists with `Status=READY`.
- [ ] Confirm `warroom.ExportBatchRow` contains exactly one row per exported
      Punch and no duplicates.
- [ ] Confirm every stored checksum has 64 uppercase hexadecimal characters.
- [ ] Run:

```powershell
.\main\tests\excel-export\Inspect-PunchExport.ps1 -Path "C:\path\to\generated.xlsx"
```

- [ ] Confirm the inspector reports contract version 3, `tblPunches`, worksheet
      protection and all seven canonical metadata columns.
- [ ] Confirm technical columns are hidden and locked.
- [ ] Confirm only backend-authorized business columns are unlocked.
- [ ] Confirm `OriginalValuesJson` is not present in the workbook.
- [ ] Confirm the exported row count matches the Flow response and both SQL
      snapshot tables.

## Evidence to retain

- SQL execution output for both runs.
- Flow Checker result and one successful run history.
- Office Scripts compilation result.
- Power Apps checker result.
- Inspector output for the generated workbook.
- Export batch ID and row-count comparison.

I01.1 passes only when every checkbox above succeeds. Any failure blocks I02.


