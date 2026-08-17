/*
    PULSE — PR-IMP-C03 negative conflict validation

    Purpose
    -------
    Prove that a changed workbook row is blocked when the governed current-state
    checksum no longer matches the immutable export snapshot.

    Safety
    ------
    The conflict is simulated by changing one ExportBatchRow checksum INSIDE an
    explicit transaction. The transaction is rolled back at the end. No Punch,
    PunchComment or permanent export metadata change is left behind.

    PASS expected before ROLLBACK
    -----------------------------
    - status = BLOCKED
    - changedRows = 1
    - conflictRows = 1
    - errorRows = 0
    - canCommit = 0
    - changed row ValidationStatus = CONFLICT
    - ValidationWarningsJson contains CURRENT_STATE_CHANGED
    - ProductionCommentDelta = 0
*/

SET NOCOUNT ON;
SET XACT_ABORT ON;

DECLARE @ProjectId bigint = 4049;
DECLARE @TemplateId bigint = 20;
DECLARE @ExportBatchId uniqueidentifier;
DECLARE @PunchExportLogId bigint;
DECLARE @RowsJson nvarchar(max);
DECLARE @ImportBatchId uniqueidentifier;
DECLARE @TargetWorkItemId bigint;
DECLARE @OriginalSnapshotChecksum char(64);
DECLARE @FakeChecksum char(64);
DECLARE @PunchCommentCountBefore bigint;
DECLARE @PunchCommentCountAfter bigint;

SELECT TOP (1)
    @ExportBatchId = eb.ExportBatchId,
    @PunchExportLogId = eb.PunchExportLogId
FROM warroom.ExportBatch AS eb
WHERE eb.ProjectId = @ProjectId
  AND eb.TemplateId = @TemplateId
  AND eb.Status = 'READY'
  AND eb.ExpiresAtUtc > SYSUTCDATETIME()
ORDER BY eb.CreatedAtUtc DESC, eb.PunchExportLogId DESC;

IF @ExportBatchId IS NULL
    THROW 52511, 'PR-IMP-C03 TEST: no READY export snapshot found for ProjectId 4049 / TemplateId 20.', 1;

SET @PunchCommentCountBefore =
(
    SELECT COUNT_BIG(*)
    FROM warroom.PunchComment
    WHERE ProjectId = @ProjectId
);

;WITH SnapshotRows AS
(
    SELECT
        ebr.WorkItemId,
        ebr.RowChecksum,
        rn = ROW_NUMBER() OVER (ORDER BY ebr.WorkItemId)
    FROM warroom.ExportBatchRow AS ebr
    WHERE ebr.ExportBatchId = @ExportBatchId
)
SELECT @RowsJson =
(
    SELECT
        [Export Batch ID] = @PunchExportLogId,
        ProjectId = @ProjectId,
        TemplateId = @TemplateId,
        [Work Item ID] = sr.WorkItemId,
        [Row Checksum] = sr.RowChecksum,
        [New Comment] = CASE
            WHEN sr.rn = 1 THEN N'PR-IMP-C03 validation only — simulated conflict, do not commit.'
            ELSE N''
        END
    FROM SnapshotRows AS sr
    ORDER BY sr.rn
    FOR JSON PATH
);

EXEC warroom.usp_StageValidatePunchCommentImport
    @ProjectId = @ProjectId,
    @FileName = N'PR-IMP-C03_simulated_conflict.xlsx',
    @RequestedBy = N'pr-imp-c03-validation@pulse.local',
    @RowsJson = @RowsJson;

SELECT @ImportBatchId = ib.ImportBatchId
FROM warroom.ImportBatch AS ib
WHERE ib.ExportBatchId = @ExportBatchId;

SELECT TOP (1)
    @TargetWorkItemId = ibr.WorkItemId
FROM warroom.ImportBatchRow AS ibr
WHERE ibr.ImportBatchId = @ImportBatchId
  AND ibr.ChangedColumnsJson <> N'[]'
ORDER BY ibr.ExcelRowNumber;

IF @TargetWorkItemId IS NULL
    THROW 52512, 'PR-IMP-C03 TEST: no changed staging row was created.', 1;

SELECT @OriginalSnapshotChecksum = ebr.RowChecksum
FROM warroom.ExportBatchRow AS ebr
WHERE ebr.ExportBatchId = @ExportBatchId
  AND ebr.WorkItemId = @TargetWorkItemId;

SET @FakeChecksum = CASE
    WHEN @OriginalSnapshotChecksum = REPLICATE('F', 64) THEN REPLICATE('E', 64)
    ELSE REPLICATE('F', 64)
END;

BEGIN TRANSACTION;

UPDATE warroom.ExportBatchRow
SET RowChecksum = @FakeChecksum
WHERE ExportBatchId = @ExportBatchId
  AND WorkItemId = @TargetWorkItemId;

EXEC warroom.usp_RevalidatePunchCommentImportConflicts
    @ImportBatchId = @ImportBatchId;

SET @PunchCommentCountAfter =
(
    SELECT COUNT_BIG(*)
    FROM warroom.PunchComment
    WHERE ProjectId = @ProjectId
);

SELECT
    ib.ImportBatchId,
    ib.Status,
    ib.TotalRows,
    ib.ChangedRows,
    ib.UnchangedRows,
    ib.ValidRows,
    ib.ErrorRows,
    ib.ConflictRows,
    CanCommit = CONVERT(bit, CASE
        WHEN ib.Status = 'READY'
         AND ib.ChangedRows > 0
         AND ib.ErrorRows = 0
         AND ib.ConflictRows = 0
        THEN 1 ELSE 0 END),
    ib.ErrorMessage
FROM warroom.ImportBatch AS ib
WHERE ib.ImportBatchId = @ImportBatchId;

SELECT
    ibr.ExcelRowNumber,
    ibr.WorkItemId,
    ibr.ValidationStatus,
    ibr.ValidationWarningsJson,
    SnapshotChecksumDuringTest = ebr.RowChecksum,
    CurrentChecksum = CONVERT
    (
        nvarchar(64),
        HASHBYTES('SHA2_256', CONVERT(varbinary(max), ibr.CurrentValuesJson)),
        2
    )
FROM warroom.ImportBatchRow AS ibr
INNER JOIN warroom.ImportBatch AS ib
    ON ib.ImportBatchId = ibr.ImportBatchId
LEFT JOIN warroom.ExportBatchRow AS ebr
    ON ebr.ExportBatchId = ib.ExportBatchId
   AND ebr.WorkItemId = ibr.WorkItemId
WHERE ibr.ImportBatchId = @ImportBatchId
  AND ibr.ValidationStatus = 'CONFLICT';

SELECT
    PunchCommentCountBefore = @PunchCommentCountBefore,
    PunchCommentCountAfter = @PunchCommentCountAfter,
    ProductionCommentDelta = @PunchCommentCountAfter - @PunchCommentCountBefore,
    ExpectedProductionCommentDelta = 0;

ROLLBACK TRANSACTION;

SELECT
    SnapshotChecksumRestored = ebr.RowChecksum,
    ExpectedChecksum = @OriginalSnapshotChecksum,
    IsRestored = CONVERT(bit, CASE WHEN ebr.RowChecksum = @OriginalSnapshotChecksum THEN 1 ELSE 0 END)
FROM warroom.ExportBatchRow AS ebr
WHERE ebr.ExportBatchId = @ExportBatchId
  AND ebr.WorkItemId = @TargetWorkItemId;
