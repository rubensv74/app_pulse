/*
    PULSE — PR-IMP-C02 positive validation

    Purpose
    -------
    Use the most recent READY export snapshot for ProjectId 4049 / TemplateId 20,
    synthesize the Excel technical contract directly from the immutable snapshot,
    add ONE New Comment in staging, and prove that:

      - the ImportBatch becomes READY;
      - exactly one row is CHANGED/READY;
      - the remaining rows are UNCHANGED;
      - canCommit = 1;
      - warroom.PunchComment is NOT modified.

    This test writes only to ImportBatch / ImportBatchRow.
    It does not commit any comment.
*/

SET NOCOUNT ON;
SET XACT_ABORT ON;

DECLARE @ProjectId bigint = 4049;
DECLARE @TemplateId bigint = 20;
DECLARE @ExportBatchId uniqueidentifier;
DECLARE @PunchExportLogId bigint;
DECLARE @RowsJson nvarchar(max);
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
    THROW 52401, 'PR-IMP-C02 TEST: no READY export snapshot found for ProjectId 4049 / TemplateId 20.', 1;

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
        [New Comment] =
            CASE
                WHEN sr.rn = 1
                    THEN N'PR-IMP-C02 validation only — staged comment, do not commit.'
                ELSE N''
            END
    FROM SnapshotRows AS sr
    ORDER BY sr.rn
    FOR JSON PATH
);

EXEC warroom.usp_StageValidatePunchCommentImport
    @ProjectId = @ProjectId,
    @FileName = N'PR-IMP-C02_validation_internal.xlsx',
    @RequestedBy = N'pr-imp-c02-validation@pulse.local',
    @RowsJson = @RowsJson;

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
    ib.ErrorMessage
FROM warroom.ImportBatch AS ib
WHERE ib.ExportBatchId = @ExportBatchId;

SELECT
    ibr.ExcelRowNumber,
    ibr.WorkItemId,
    ibr.ValidationStatus,
    ibr.ChangedColumnsJson,
    ibr.ValidationErrorsJson
FROM warroom.ImportBatchRow AS ibr
INNER JOIN warroom.ImportBatch AS ib
    ON ib.ImportBatchId = ibr.ImportBatchId
WHERE ib.ExportBatchId = @ExportBatchId
ORDER BY ibr.ExcelRowNumber;

/*
    PASS expected
    -------------
    - status = READY
    - ChangedRows = 1
    - ErrorRows = 0
    - one ImportBatchRow = READY
    - remaining ImportBatchRow = UNCHANGED
    - ProductionCommentDelta = 0
*/
