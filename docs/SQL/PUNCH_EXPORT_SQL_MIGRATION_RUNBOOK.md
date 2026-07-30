# Punch export SQL migration runbook

## Scope

Non-production first. This runbook aligns the existing GUID/BIGINT schema and makes `ExportBatchRow.RowVersion` nullable. It does not modify Punch production data.

## Pre-deployment

1. Back up definitions of `ExportBatch`, `ExportBatchRow`, `PunchExportLog` and the three export procedures.
2. Run `sql/diagnostics/find_open_punch_export_logs.sql` and retain results.
3. Confirm no duplicate `ExportBatch.PunchExportLogId` values.
4. Confirm the target is not production.

## Deployment order

1. `sql/migrations/20260730_align_punch_export_snapshot_model.sql`
2. `sql/export/usp_ExportProjectPunchesExtended_Pivoted.sql`
3. `sql/export/002_register_punch_export_snapshot.sql`
4. `tests/sql/Test-PunchExportSnapshot.sql`
5. Run the migration a second time to prove idempotence.

## Expected result

`RowVersion` is `binary(8) NULL`; the unique log index exists; the test reports PASS. Existing values and batches remain unchanged.

## Rollback

Do not restore `NOT NULL` while any NULL rows exist. If procedure deployment fails, redeploy the backed-up procedures. If the migration transaction fails, SQL rolls it back automatically. Restoring `RowVersion NOT NULL` requires an approved data policy for existing NULLs and is therefore not an automatic rollback step.

## Open logs

Review diagnostic classifications manually. Use `usp_PunchExportLog_Fail` only after confirming the attempt cannot resume. Never delete logs or batches as part of this runbook.
