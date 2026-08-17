/*
    PULSE — PR-IMP-C02B
    Preview smoke test using the latest staged import batch for project 4049 / template 20.

    READ ONLY.
*/

SET NOCOUNT ON;

DECLARE @ImportBatchId uniqueidentifier;

SELECT TOP (1)
    @ImportBatchId = ib.ImportBatchId
FROM warroom.ImportBatch ib
WHERE ib.ProjectId = 4049
  AND ib.TemplateId = 20
ORDER BY ib.RequestedAtUtc DESC;

IF @ImportBatchId IS NULL
    THROW 52330, 'PR-IMP-C02B test: no ImportBatch exists for project 4049 / template 20.', 1;

SELECT
    TestImportBatchId = @ImportBatchId,
    BatchStatus = ib.Status,
    ib.TotalRows,
    ib.ChangedRows,
    ib.UnchangedRows,
    ib.ErrorRows,
    ib.ConflictRows
FROM warroom.ImportBatch ib
WHERE ib.ImportBatchId = @ImportBatchId;

-- Result set 2: all preview rows.
EXEC warroom.usp_GetPunchCommentImportPreview
    @ImportBatchId = @ImportBatchId,
    @ValidationStatus = NULL,
    @PageNumber = 1,
    @PageSize = 50;

-- Result set 3: errors only. With the current checksum-negative batch this should return 1 row.
EXEC warroom.usp_GetPunchCommentImportPreview
    @ImportBatchId = @ImportBatchId,
    @ValidationStatus = 'ERROR',
    @PageNumber = 1,
    @PageSize = 50;

/*
Expected with the current negative-checksum batch:
- Result set 1: BatchStatus = BLOCKED, TotalRows = 3, ErrorRows = 1.
- Result set 2: 3 preview rows.
- Result set 3: exactly 1 ERROR row showing CHECKSUM_MISMATCH in ValidationErrorsJson.
- No production data is modified.
*/
