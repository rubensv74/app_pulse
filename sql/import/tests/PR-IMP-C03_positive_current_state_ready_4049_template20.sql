/*
    PULSE — PR-IMP-C03 positive current-state validation

    Purpose
    -------
    Restage a clean Comments-only v1 workbook from the latest READY export for
    ProjectId 4049 / TemplateId 20, add one New Comment, revalidate against the
    current PULSE state, and prove that no production comment is written.

    PASS expected
    -------------
    - status = READY
    - changedRows = 1
    - conflictRows = 0
    - errorRows = 0
    - canCommit = 1
    - one row READY; remaining rows UNCHANGED
    - CurrentValuesJson populated
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
    THROW 52501, 'PR-IMP-C03 TEST: no READY export snapshot found for ProjectId 4049 / TemplateId 20.', 1;

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
            WHEN sr.rn = 1 THEN N'PR-IMP-C03 validation only — current-state test, do not commit.'
            ELSE N''
        END
    FROM SnapshotRows AS sr
    ORDER BY sr.rn
    FOR JSON PATH
);

EXEC warroom.usp_StageValidatePunchCommentImport
    @ProjectId = @ProjectId,
    @FileName = N'PR-IMP-C03_current_state_ready.xlsx',
    @RequestedBy = N'pr-imp-c03-validation@pulse.local',
    @RowsJson = @RowsJson;

SELECT @ImportBatchId = ib.ImportBatchId
FROM warroom.ImportBatch AS ib
WHERE ib.ExportBatchId = @ExportBatchId;

EXEC warroom.usp_RevalidatePunchCommentImportConflicts
    @ImportBatchId = @ImportBatchId;

SET @PunchCommentCountAfter =
(
    SELECT COUNT_BIG(*)
    FROM warroom.PunchComment
    WHERE ProjectId = @ProjectId
);

SELECT
    PunchCommentCountBefore = @PunchCommentCountBefore,
    PunchCommentCountAfter = @PunchCommentCountAfter,
    ProductionCommentDelta = @PunchCommentCountAfter - @PunchCommentCountBefore,
    ExpectedProductionCommentDelta = 0;

SELECT
    ib.ImportBatchId,
    ib.ExportBatchId,
    ib.ProjectId,
    ib.TemplateId,
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
        THEN 1 ELSE 0 END)
FROM warroom.ImportBatch AS ib
WHERE ib.ImportBatchId = @ImportBatchId;

SELECT
    ibr.ExcelRowNumber,
    ibr.WorkItemId,
    ibr.ValidationStatus,
    ibr.CurrentValuesJson,
    SnapshotChecksum = ebr.RowChecksum,
    CurrentChecksum = CONVERT
    (
        nvarchar(64),
        HASHBYTES('SHA2_256', CONVERT(varbinary(max), ibr.CurrentValuesJson)),
        2
    ),
    ibr.ValidationWarningsJson
FROM warroom.ImportBatchRow AS ibr
INNER JOIN warroom.ImportBatch AS ib
    ON ib.ImportBatchId = ibr.ImportBatchId
LEFT JOIN warroom.ExportBatchRow AS ebr
    ON ebr.ExportBatchId = ib.ExportBatchId
   AND ebr.WorkItemId = ibr.WorkItemId
WHERE ibr.ImportBatchId = @ImportBatchId
ORDER BY ibr.ExcelRowNumber;
