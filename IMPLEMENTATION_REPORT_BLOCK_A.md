# Implementation report - Block A

## Outcome

The repository now models `ExportBatchId` as a technical GUID and `PunchExportLogId` as a unique functional BIGINT. `ExportBatchRow.RowVersion` is nullable and the snapshot INSERT omits it.

## Implemented

- Canonical base DDL for ExportBatch, ExportBatchRow and ImportBatch references.
- Defensive idempotent migration for the confirmed deployed schema.
- Snapshot procedure without a synthetic RowVersion.
- Required export-log identifier validation in the pivot procedure.
- `usp_PunchExportLog_Fail` compensation procedure.
- Read-only classification of open logs.
- Updated v3 contracts and mappings.
- Transactional SQL test, canonical-model documentation and migration runbook.
- Updated static validation and deployment checklist.

## Deliberately not changed

Power Apps, Home/Punches filters, modal, Flow definitions, connection references, `.msapp` and Office Script.

## Environment validation still required

Run the migration and tests in non-production, deploy the procedures, wire the Flow failure path to `usp_PunchExportLog_Fail` in Block D, and retain SQL output. The current Office Script still derives its workbook `ExportBatchId` from `PunchExportLogId`; aligning that runtime workbook contract is outside authorized Block A and remains a dependency for Block D/E.
