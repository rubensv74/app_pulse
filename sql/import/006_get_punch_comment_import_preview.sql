/*
    PULSE — PR-IMP-C02B
    Read-only preview for Comments-only v1 import batches.

    Purpose
    -------
    Feed the future scr_PunchImport preview grid with staged rows before Commit.

    Safety
    ------
    - READ ONLY.
    - Does not insert/update/delete PunchComment.
    - Does not alter ImportBatch / ImportBatchRow.
*/

SET NOCOUNT ON;
SET XACT_ABORT ON;
GO

CREATE OR ALTER PROCEDURE [warroom].[usp_GetPunchCommentImportPreview]
(
    @ImportBatchId uniqueidentifier,
    @ValidationStatus varchar(20) = NULL,
    @PageNumber int = 1,
    @PageSize int = 50
)
AS
BEGIN
    SET NOCOUNT ON;

    IF @ImportBatchId IS NULL
        THROW 52320, 'PR-IMP-C02B: ImportBatchId is required.', 1;

    IF NOT EXISTS
    (
        SELECT 1
        FROM warroom.ImportBatch
        WHERE ImportBatchId = @ImportBatchId
    )
        THROW 52321, 'PR-IMP-C02B: ImportBatchId does not exist.', 1;

    SET @ValidationStatus = NULLIF(UPPER(LTRIM(RTRIM(@ValidationStatus))), '');

    IF @ValidationStatus IS NOT NULL
       AND @ValidationStatus NOT IN ('PENDING','READY','UNCHANGED','WARNING','ERROR','CONFLICT')
        THROW 52322, 'PR-IMP-C02B: unsupported ValidationStatus filter.', 1;

    IF @PageNumber IS NULL OR @PageNumber < 1 SET @PageNumber = 1;
    IF @PageSize IS NULL OR @PageSize < 1 SET @PageSize = 50;
    IF @PageSize > 200 SET @PageSize = 200;

    DECLARE @Offset int = (@PageNumber - 1) * @PageSize;
    DECLARE @TotalRows int;
    DECLARE @TotalPages int;

    SELECT @TotalRows = COUNT(*)
    FROM warroom.ImportBatchRow ibr
    WHERE ibr.ImportBatchId = @ImportBatchId
      AND (@ValidationStatus IS NULL OR ibr.ValidationStatus = @ValidationStatus);

    SET @TotalRows = COALESCE(@TotalRows, 0);
    SET @TotalPages = CASE WHEN @TotalRows = 0 THEN 0 ELSE CEILING(1.0 * @TotalRows / @PageSize) END;

    SELECT
        ib.ImportBatchId,
        ib.ExportBatchId,
        ib.ProjectId,
        ib.TemplateId,
        ib.Status AS ImportStatus,
        ib.FileName,
        ib.TotalRows AS BatchTotalRows,
        ib.ChangedRows AS BatchChangedRows,
        ib.UnchangedRows AS BatchUnchangedRows,
        ib.ErrorRows AS BatchErrorRows,
        ib.ConflictRows AS BatchConflictRows,

        ibr.ImportBatchRowId,
        ibr.ExcelRowNumber,
        ibr.WorkItemId,
        PunchCode = COALESCE(p.PunchCode, CONVERT(nvarchar(50), ibr.WorkItemId)),
        PunchDescription = COALESCE(p.PunchDescription, N''),
        NewComment = COALESCE
        (
            JSON_VALUE(ibr.IncomingValuesJson, '$."New Comment"'),
            JSON_VALUE(ibr.IncomingValuesJson, '$.NewComment'),
            N''
        ),
        ibr.ValidationStatus,
        ibr.ChangedColumnsJson,
        ibr.ValidationErrorsJson,
        ibr.ValidationWarningsJson,
        ibr.ApplyStatus,
        ibr.ApplyError,

        PageNumber = @PageNumber,
        PageSize = @PageSize,
        TotalRows = @TotalRows,
        TotalPages = @TotalPages
    FROM warroom.ImportBatch ib
    INNER JOIN warroom.ImportBatchRow ibr
        ON ibr.ImportBatchId = ib.ImportBatchId
    OUTER APPLY
    (
        SELECT TOP (1)
            PunchCode = CONVERT(nvarchar(255), wp.Code),
            PunchDescription = CONVERT(nvarchar(2000), wp.Description)
        FROM dbo.wap_PunchPaged wp
        WHERE wp.Id = ibr.WorkItemId
          AND wp.ProjectId = ib.ProjectId
          AND wp.TemplateID = ib.TemplateId
        ORDER BY wp.LastModifiedAt DESC, wp.PunchLogId DESC
    ) p
    WHERE ib.ImportBatchId = @ImportBatchId
      AND (@ValidationStatus IS NULL OR ibr.ValidationStatus = @ValidationStatus)
    ORDER BY ibr.ExcelRowNumber
    OFFSET @Offset ROWS FETCH NEXT @PageSize ROWS ONLY;
END;
GO

SELECT
    ProcedureName = N'warroom.usp_GetPunchCommentImportPreview',
    ExistsAsProcedure = CONVERT(bit, CASE WHEN OBJECT_ID(N'warroom.usp_GetPunchCommentImportPreview', N'P') IS NOT NULL THEN 1 ELSE 0 END),
    WritesPunchComment = CONVERT(bit, CASE
        WHEN OBJECT_DEFINITION(OBJECT_ID(N'warroom.usp_GetPunchCommentImportPreview', N'P')) LIKE '%INSERT%PunchComment%'
          OR OBJECT_DEFINITION(OBJECT_ID(N'warroom.usp_GetPunchCommentImportPreview', N'P')) LIKE '%UPDATE%PunchComment%'
          OR OBJECT_DEFINITION(OBJECT_ID(N'warroom.usp_GetPunchCommentImportPreview', N'P')) LIKE '%DELETE%PunchComment%'
        THEN 1 ELSE 0 END);
GO
