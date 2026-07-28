# Sprint I01.1 — Real export integration

## Objective

Replace assumptions in I01 with the supplied production-shaped Flow, Office
Script, SQL export procedure and representative XLSX.

## Implemented scope

- Versioned the supplied Power Automate export package and source definition.
- Extracted the real Office Script and export dataset procedure into dedicated
  source files.
- Inspected the representative workbook without versioning its project data.
- Added a repeatable structural workbook inspection.
- Versioned v2 export/mapping contracts using the real physical identifiers.
- Documented exact Flow inputs, actions, SQL calls, output and deployment.

No I02 validation or commit procedures were implemented.

## Findings from real artifacts

- `PunchExportLogId` is the existing export identity and maps logically to
  `ExportBatchId`.
- `PunchId` maps logically to `WorkItemId`.
- `warroom.ExportBatch.ExportBatchId` is a BIGINT extension key aligned with
  `PunchExportLogId`; it does not generate a second export identity.
- The workbook uses `RowHash` and `Original Row Hash` for checksum concurrency;
  the source table's physical `rowversion` was not supplied.
- `ExportedOnUtc` exists in the hidden Export Information sheet, not per row.
- The Office Script already locks technical columns and protects `Punches`.
- `warroom.usp_GetPunchExportColumnMap` and `IsEditableInExcel` are the real
  backend authorities for business-column editability.
- The Flow limit is 50,000 rows, superseding the provisional I01 limit of 5,000.

## Files created

- `main/power-automate/Warroom_ExportPunchesToExcel/Warroom_ExportPunchesToExcel_20260728142303.zip`
- `main/power-automate/Warroom_ExportPunchesToExcel/definition.source.json`
- `main/power-automate/Warroom_ExportPunchesToExcel/definition.corrected.json`
- `main/power-automate/Warroom_ExportPunchesToExcel/README.md`
- `main/office-scripts/BuildPunchExport.ts`
- `main/sql/export/usp_ExportProjectPunchesExtended_Pivoted.sql`
- `main/contracts/excel-import/export-columns.v2.json`
- `main/mappings/excel-import/punch-columns.v2.json`
- `main/tests/excel-export/Inspect-PunchExport.ps1`
- `docs/README_SPRINT_I01_1.md`

## Files modified

- `main/CHANGELOG.md`
- `docs/EXCEL_IMPORT_ARCHITECTURE.md`
- `docs/README_SPRINT_I01.md`
- `main/screens/Punches/scr_Punches_1.pa.yaml`

## Dependencies

- Schema/definition of `warroom.PunchExportLog` and its start/complete SPs.
- Definition of `warroom.usp_GetPunchExportColumnMap`.
- A canonical checksum covering every editable standard and custom field.
- Non-production Power Automate, SharePoint, Office Script and Azure SQL.

## Installation

1. Import the supplied Flow ZIP in non-production.
2. Apply the corrected Compose expressions from `definition.corrected.json`;
   the supplied ZIP contains the original trigger-key defect.
2. Rebind its SQL, SharePoint and Excel connections.
3. Publish `BuildPunchExport.ts` as an Office Script and rebind `Run_script`.
4. Deploy/verify the supplied SQL export procedure.
5. Run `Inspect-PunchExport.ps1` against the fixture and a new export.

## Test instructions

```powershell
.\main\tests\excel-export\Inspect-PunchExport.ps1 -Path C:\path\to\export.xlsx
```

Strict-parse Flow/contract/mapping JSON, TypeScript-check the Office Script in
the Microsoft editor, and execute the export procedure in non-production.

## Results of validation

Results are recorded in the delivery handoff after all local checks complete.

## Known limitations

- The current SQL checksum does not cover all editable standard fields.
- Export rows are not persisted as immutable backend snapshots.
- The Flow lacks a complete failure/cleanup scope.
- The supplied Flow cannot be executed locally.
- The corrected Flow definition has not been deployed.
- Existing export metadata names differ from the original I01 logical names.

## Next step

Complete I01 by extending the existing export log with immutable row snapshots
and a checksum over every allowed editable field. Do not begin I02 until that
export invariant is verified end to end.
