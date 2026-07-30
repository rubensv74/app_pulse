# Punch export SQL canonical model

## Identity

- `ExportBatchId uniqueidentifier NOT NULL`: technical snapshot identifier.
- `PunchExportLogId bigint NOT NULL`: functional export-attempt identifier, unique in `ExportBatch`.
- `ExportBatchRow.ExportBatchId uniqueidentifier NOT NULL`: foreign key to `ExportBatch`.
- `WorkItemId bigint NOT NULL`: Punch identifier.

## Concurrency

`RowVersion` is `binary(8) NULL`. It is reserved until the Punch source exposes a real version. No zero value, date, GUID or SQL `rowversion` is synthesized. Concurrency currently relies on the immutable uppercase SHA-256 `RowChecksum` over `OriginalValuesJson`.

## Lifecycle

`usp_PunchExportLog_Start` creates the attempt. `usp_RegisterPunchExportSnapshot` atomically creates one batch and N rows, keyed idempotently by `PunchExportLogId`. `usp_CompletePunchExportBatch` changes `CREATED` to `READY`. `usp_PunchExportLog_Fail` marks an unfinished log `Failed` without deleting evidence.

## Invariants

- One `ExportBatch` per `PunchExportLogId`.
- Header and rows commit or roll back together.
- Snapshot retries with identical immutable data succeed without duplicates.
- Retries with different immutable data fail.
- `RowVersion` remains NULL until a real source value exists.
