/*
    PULSE — PR-IMP-C02A FIX1
    Stage + Validate SQL for Comments-only v1.

    Contract
    --------
    - The Excel technical field named ExportBatchId contains PunchExportLogId
      (PULSE.PunchExcelExportColumns/v3).
    - SQL resolves that numeric value to warroom.ExportBatch.ExportBatchId UUID.
    - NewComment is the only business value interpreted as a change.
    - Blank NewComment means UNCHANGED.
    - This procedure NEVER writes to warroom.PunchComment.

    FIX1 — 2026-08-17
    -----------------
    ValidationErrorsJson is NOT NULL in warroom.ImportBatchRow. The first C02A
    build could propagate NULL from the validation expression into that column.
    This version normalizes every validation JSON payload with COALESCE(...,'[]')
    before classification and INSERT.

    Retry model in C02
    ------------------
    The current database has UQ_ImportBatch_ExportBatchId. Therefore C02 reuses
    the same uncommitted ImportBatch for a given ExportBatch and replaces its
    staging rows. COMMITTED/COMMITTING batches cannot be restaged.
*/

SET NOCOUNT ON;
SET XACT_ABORT ON;
GO

CREATE OR ALTER PROCEDURE [warroom].[usp_StageValidatePunchCommentImport]
(
    @ProjectId     bigint,
    @FileName      nvarchar(260),
    @RequestedBy   nvarchar(320),
    @RowsJson      nvarchar(max)
)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRY
        /* ------------------------------------------------------------------
           1. Input contract
           ------------------------------------------------------------------ */
        IF @ProjectId IS NULL OR @ProjectId <= 0
            THROW 52301, 'PR-IMP-C02: ProjectId must be a positive integer.', 1;

        SET @FileName = NULLIF(LTRIM(RTRIM(@FileName)), N'');
        SET @RequestedBy = NULLIF(LTRIM(RTRIM(@RequestedBy)), N'');

        IF @FileName IS NULL
            THROW 52302, 'PR-IMP-C02: FileName is required.', 1;

        IF @RequestedBy IS NULL
            THROW 52303, 'PR-IMP-C02: RequestedBy is required.', 1;

        IF ISJSON(@RowsJson) <> 1 OR LEFT(LTRIM(@RowsJson), 1) <> N'['
            THROW 52304, 'PR-IMP-C02: RowsJson must be a JSON array.', 1;

        DROP TABLE IF EXISTS #Stage;

        CREATE TABLE #Stage
        (
            ExcelRowNumber      int             NOT NULL,
            RawJson             nvarchar(max)   NOT NULL,
            PunchExportLogId    bigint          NULL,
            RowProjectId        bigint          NULL,
            RowTemplateId       bigint          NULL,
            WorkItemId          bigint          NULL,
            RowChecksum         varchar(64)     NULL,
            NewComment          nvarchar(max)   NULL,
            DuplicateCount      int             NOT NULL DEFAULT (1)
        );

        INSERT INTO #Stage
        (
            ExcelRowNumber,
            RawJson,
            PunchExportLogId,
            RowProjectId,
            RowTemplateId,
            WorkItemId,
            RowChecksum,
            NewComment
        )
        SELECT
            ExcelRowNumber = TRY_CONVERT(int, src.[key]) + 2,
            RawJson = src.[value],
            PunchExportLogId = TRY_CONVERT
            (
                bigint,
                COALESCE
                (
                    JSON_VALUE(src.[value], '$."Export Batch ID"'),
                    JSON_VALUE(src.[value], '$.ExportBatchId'),
                    JSON_VALUE(src.[value], '$.PunchExportLogId')
                )
            ),
            RowProjectId = TRY_CONVERT
            (
                bigint,
                COALESCE
                (
                    JSON_VALUE(src.[value], '$.ProjectId'),
                    JSON_VALUE(src.[value], '$."Project ID"')
                )
            ),
            RowTemplateId = TRY_CONVERT
            (
                bigint,
                COALESCE
                (
                    JSON_VALUE(src.[value], '$.TemplateId'),
                    JSON_VALUE(src.[value], '$."Template ID"')
                )
            ),
            WorkItemId = TRY_CONVERT
            (
                bigint,
                COALESCE
                (
                    JSON_VALUE(src.[value], '$."Work Item ID"'),
                    JSON_VALUE(src.[value], '$.WorkItemId'),
                    JSON_VALUE(src.[value], '$.PunchId')
                )
            ),
            RowChecksum = UPPER
            (
                NULLIF
                (
                    LTRIM
                    (
                        RTRIM
                        (
                            CONVERT
                            (
                                varchar(64),
                                COALESCE
                                (
                                    JSON_VALUE(src.[value], '$."Row Checksum"'),
                                    JSON_VALUE(src.[value], '$.RowChecksum'),
                                    JSON_VALUE(src.[value], '$.RowHash')
                                )
                            )
                        )
                    ),
                    ''
                )
            ),
            NewComment = NULLIF
            (
                LTRIM
                (
                    RTRIM
                    (
                        COALESCE
                        (
                            JSON_VALUE(src.[value], '$."New Comment"'),
                            JSON_VALUE(src.[value], '$.NewComment')
                        )
                    )
                ),
                N''
            )
        FROM OPENJSON(@RowsJson) AS src
        WHERE src.[type] = 5;

        IF NOT EXISTS (SELECT 1 FROM #Stage)
            THROW 52305, 'PR-IMP-C02: the workbook does not contain Punch rows.', 1;

        UPDATE s
        SET DuplicateCount = d.DuplicateCount
        FROM #Stage AS s
        INNER JOIN
        (
            SELECT
                WorkItemId,
                DuplicateCount = COUNT(*)
            FROM #Stage
            WHERE WorkItemId IS NOT NULL
            GROUP BY WorkItemId
        ) AS d
            ON d.WorkItemId = s.WorkItemId;

        /* ------------------------------------------------------------------
           2. Resolve the immutable export snapshot
           ------------------------------------------------------------------ */
        DECLARE @PunchExportLogId bigint;
        DECLARE @ExportBatchId uniqueidentifier;
        DECLARE @ExportProjectId bigint;
        DECLARE @TemplateId bigint;
        DECLARE @ExportStatus varchar(20);
        DECLARE @ExpiresAtUtc datetime2(3);
        DECLARE @ExportRowCount int;

        SELECT @PunchExportLogId = MIN(PunchExportLogId)
        FROM #Stage
        WHERE PunchExportLogId IS NOT NULL
          AND PunchExportLogId > 0;

        IF @PunchExportLogId IS NULL
            THROW 52306, 'PR-IMP-C02: no valid Export Batch ID / PunchExportLogId was found.', 1;

        SELECT
            @ExportBatchId = eb.ExportBatchId,
            @ExportProjectId = eb.ProjectId,
            @TemplateId = eb.TemplateId,
            @ExportStatus = eb.Status,
            @ExpiresAtUtc = eb.ExpiresAtUtc,
            @ExportRowCount = eb.[RowCount]
        FROM [warroom].[ExportBatch] AS eb
        WHERE eb.PunchExportLogId = @PunchExportLogId;

        IF @ExportBatchId IS NULL
            THROW 52307, 'PR-IMP-C02: the export snapshot does not exist.', 1;

        IF @ExportProjectId <> @ProjectId
            THROW 52308, 'PR-IMP-C02: the workbook belongs to a different project.', 1;

        IF @ExportStatus <> 'READY'
            THROW 52309, 'PR-IMP-C02: the export snapshot is not READY for import.', 1;

        IF @ExpiresAtUtc <= CONVERT(datetime2(3), SYSUTCDATETIME())
            THROW 52310, 'PR-IMP-C02: the export snapshot has expired.', 1;

        /* ------------------------------------------------------------------
           3. Create or reuse the staging batch.
              No PunchComment write exists anywhere in this transaction.
           ------------------------------------------------------------------ */
        DECLARE @ImportBatchId uniqueidentifier;
        DECLARE @ExistingImportStatus varchar(20);

        BEGIN TRANSACTION;

        SELECT
            @ImportBatchId = ib.ImportBatchId,
            @ExistingImportStatus = ib.Status
        FROM [warroom].[ImportBatch] AS ib WITH (UPDLOCK, HOLDLOCK)
        WHERE ib.ExportBatchId = @ExportBatchId;

        IF @ImportBatchId IS NOT NULL
           AND @ExistingImportStatus IN ('COMMITTING', 'COMMITTED')
            THROW 52311, 'PR-IMP-C02: a committed import batch cannot be restaged.', 1;

        IF @ImportBatchId IS NULL
        BEGIN
            SET @ImportBatchId = NEWID();

            INSERT INTO [warroom].[ImportBatch]
            (
                ImportBatchId,
                ExportBatchId,
                ProjectId,
                TemplateId,
                FileName,
                RequestedBy,
                RequestedAtUtc,
                ValidatedAtUtc,
                CommittedAtUtc,
                Status,
                TotalRows,
                ChangedRows,
                UnchangedRows,
                ValidRows,
                WarningRows,
                ErrorRows,
                ConflictRows,
                AppliedRows,
                FailedRows,
                ErrorMessage
            )
            VALUES
            (
                @ImportBatchId,
                @ExportBatchId,
                @ProjectId,
                @TemplateId,
                @FileName,
                @RequestedBy,
                CONVERT(datetime2(3), SYSUTCDATETIME()),
                NULL,
                NULL,
                'VALIDATING',
                0,0,0,0,0,0,0,0,0,
                NULL
            );
        END
        ELSE
        BEGIN
            DELETE FROM [warroom].[ImportBatchRow]
            WHERE ImportBatchId = @ImportBatchId;

            UPDATE [warroom].[ImportBatch]
            SET
                FileName = @FileName,
                RequestedBy = @RequestedBy,
                RequestedAtUtc = CONVERT(datetime2(3), SYSUTCDATETIME()),
                ValidatedAtUtc = NULL,
                CommittedAtUtc = NULL,
                Status = 'VALIDATING',
                TotalRows = 0,
                ChangedRows = 0,
                UnchangedRows = 0,
                ValidRows = 0,
                WarningRows = 0,
                ErrorRows = 0,
                ConflictRows = 0,
                AppliedRows = 0,
                FailedRows = 0,
                ErrorMessage = NULL
            WHERE ImportBatchId = @ImportBatchId;
        END;

        /* ------------------------------------------------------------------
           4. Row validation
           ------------------------------------------------------------------ */
        INSERT INTO [warroom].[ImportBatchRow]
        (
            ImportBatchId,
            ExcelRowNumber,
            WorkItemId,
            IncomingValuesJson,
            OriginalValuesJson,
            CurrentValuesJson,
            ChangedColumnsJson,
            ValidationStatus,
            ValidationErrorsJson,
            ValidationWarningsJson,
            ApplyStatus,
            ApplyError
        )
        SELECT
            @ImportBatchId,
            s.ExcelRowNumber,
            s.WorkItemId,
            s.RawJson,
            ebr.OriginalValuesJson,
            NULL,
            CASE
                WHEN s.NewComment IS NULL THEN N'[]'
                ELSE COALESCE
                (
                    (
                        SELECT
                            ColumnName = N'NewComment',
                            OldValue = CONVERT(nvarchar(max), NULL),
                            NewValue = s.NewComment
                        FOR JSON PATH
                    ),
                    N'[]'
                )
            END,
            CASE
                WHEN COALESCE(validation.ValidationErrorsJson, N'[]') <> N'[]' THEN 'ERROR'
                WHEN s.NewComment IS NULL THEN 'UNCHANGED'
                ELSE 'READY'
            END,
            COALESCE(validation.ValidationErrorsJson, N'[]'),
            N'[]',
            'NOT_APPLIED',
            NULL
        FROM #Stage AS s
        LEFT JOIN [warroom].[ExportBatchRow] AS ebr
            ON ebr.ExportBatchId = @ExportBatchId
           AND ebr.WorkItemId = s.WorkItemId
        CROSS APPLY
        (
            SELECT ValidationErrorsJson = COALESCE
            (
                (
                    SELECT
                        ErrorCode = errors.ErrorCode,
                        [Message] = errors.[Message]
                    FROM
                    (
                        SELECT
                            ErrorCode = N'INVALID_EXPORT_BATCH_ID',
                            [Message] = N'The row does not contain the expected Export Batch ID.'
                        WHERE s.PunchExportLogId IS NULL
                           OR s.PunchExportLogId <= 0
                           OR s.PunchExportLogId <> @PunchExportLogId

                        UNION ALL

                        SELECT
                            N'PROJECT_MISMATCH',
                            N'The row ProjectId does not match the export snapshot.'
                        WHERE s.RowProjectId IS NULL
                           OR s.RowProjectId <> @ProjectId

                        UNION ALL

                        SELECT
                            N'TEMPLATE_MISMATCH',
                            N'The row TemplateId does not match the export snapshot.'
                        WHERE s.RowTemplateId IS NULL
                           OR s.RowTemplateId <> @TemplateId

                        UNION ALL

                        SELECT
                            N'INVALID_WORKITEM',
                            N'The Work Item ID is missing or invalid.'
                        WHERE s.WorkItemId IS NULL
                           OR s.WorkItemId <= 0

                        UNION ALL

                        SELECT
                            N'DUPLICATE_WORKITEM',
                            N'The Work Item ID appears more than once in the workbook.'
                        WHERE s.DuplicateCount > 1

                        UNION ALL

                        SELECT
                            N'WORKITEM_NOT_IN_EXPORT',
                            N'The Work Item ID is not part of the immutable export snapshot.'
                        WHERE s.WorkItemId IS NOT NULL
                          AND ebr.WorkItemId IS NULL

                        UNION ALL

                        SELECT
                            N'INVALID_CHECKSUM',
                            N'The Row Checksum is missing or malformed.'
                        WHERE s.RowChecksum IS NULL
                           OR LEN(s.RowChecksum) <> 64
                           OR s.RowChecksum LIKE '%[^0-9A-F]%'

                        UNION ALL

                        SELECT
                            N'CHECKSUM_MISMATCH',
                            N'The Row Checksum does not match the immutable export snapshot.'
                        WHERE ebr.WorkItemId IS NOT NULL
                          AND
                          (
                              s.RowChecksum IS NULL
                              OR UPPER(CONVERT(varchar(64), ebr.RowChecksum)) <> s.RowChecksum
                          )
                    ) AS errors
                    FOR JSON PATH
                ),
                N'[]'
            )
        ) AS validation;

        /* ------------------------------------------------------------------
           5. Batch summary
           ------------------------------------------------------------------ */
        DECLARE @TotalRows int;
        DECLARE @ChangedRows int;
        DECLARE @UnchangedRows int;
        DECLARE @ValidRows int;
        DECLARE @ErrorRows int;
        DECLARE @GlobalError nvarchar(2000) = NULL;
        DECLARE @FinalStatus varchar(20);

        SELECT
            @TotalRows = COUNT(*),
            @ChangedRows = SUM(CASE WHEN ValidationStatus = 'READY' THEN 1 ELSE 0 END),
            @UnchangedRows = SUM(CASE WHEN ValidationStatus = 'UNCHANGED' THEN 1 ELSE 0 END),
            @ValidRows = SUM(CASE WHEN ValidationStatus IN ('READY','UNCHANGED') THEN 1 ELSE 0 END),
            @ErrorRows = SUM(CASE WHEN ValidationStatus = 'ERROR' THEN 1 ELSE 0 END)
        FROM [warroom].[ImportBatchRow]
        WHERE ImportBatchId = @ImportBatchId;

        SET @TotalRows = COALESCE(@TotalRows, 0);
        SET @ChangedRows = COALESCE(@ChangedRows, 0);
        SET @UnchangedRows = COALESCE(@UnchangedRows, 0);
        SET @ValidRows = COALESCE(@ValidRows, 0);
        SET @ErrorRows = COALESCE(@ErrorRows, 0);

        IF @TotalRows <> @ExportRowCount
            SET @GlobalError = CONCAT
            (
                N'FILE_ROW_COUNT_MISMATCH: expected ',
                @ExportRowCount,
                N' rows from the export snapshot but received ',
                @TotalRows,
                N'.'
            );

        SET @FinalStatus =
            CASE
                WHEN @ErrorRows > 0 OR @GlobalError IS NOT NULL THEN 'BLOCKED'
                ELSE 'READY'
            END;

        UPDATE [warroom].[ImportBatch]
        SET
            ValidatedAtUtc = CONVERT(datetime2(3), SYSUTCDATETIME()),
            Status = @FinalStatus,
            TotalRows = @TotalRows,
            ChangedRows = @ChangedRows,
            UnchangedRows = @UnchangedRows,
            ValidRows = @ValidRows,
            WarningRows = 0,
            ErrorRows = @ErrorRows,
            ConflictRows = 0,
            AppliedRows = 0,
            FailedRows = 0,
            ErrorMessage = @GlobalError
        WHERE ImportBatchId = @ImportBatchId;

        COMMIT TRANSACTION;

        /* ------------------------------------------------------------------
           6. Contract response
           ------------------------------------------------------------------ */
        DECLARE @ErrorsJson nvarchar(max) = COALESCE
        (
            (
                SELECT
                    ExcelRowNumber,
                    WorkItemId,
                    errors = JSON_QUERY(COALESCE(ValidationErrorsJson, N'[]'))
                FROM [warroom].[ImportBatchRow]
                WHERE ImportBatchId = @ImportBatchId
                  AND ValidationStatus = 'ERROR'
                ORDER BY ExcelRowNumber
                FOR JSON PATH
            ),
            N'[]'
        );

        IF @GlobalError IS NOT NULL
        BEGIN
            SET @ErrorsJson =
            (
                SELECT
                    globalError = @GlobalError,
                    rowErrors = JSON_QUERY(COALESCE(@ErrorsJson, N'[]'))
                FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
            );
        END;

        SELECT
            success = CAST(1 AS bit),
            importBatchId = CONVERT(nvarchar(36), @ImportBatchId),
            status = @FinalStatus,
            fileName = @FileName,
            totalRows = @TotalRows,
            changedRows = @ChangedRows,
            unchangedRows = @UnchangedRows,
            validRows = @ValidRows,
            warningRows = CAST(0 AS int),
            errorRows = @ErrorRows,
            conflictRows = CAST(0 AS int),
            appliedRows = CAST(0 AS int),
            failedRows = CAST(0 AS int),
            canCommit = CAST
            (
                CASE
                    WHEN @FinalStatus = 'READY'
                     AND @ErrorRows = 0
                     AND @GlobalError IS NULL
                     AND @ChangedRows > 0
                    THEN 1 ELSE 0
                END
                AS bit
            ),
            [message] =
                CASE
                    WHEN @FinalStatus = 'BLOCKED'
                        THEN COALESCE(@GlobalError, N'The file was validated with blocking errors.')
                    WHEN @ChangedRows = 0
                        THEN N'The workbook is valid but contains no new comments to apply.'
                    ELSE N'The workbook is valid and ready for preview.'
                END,
            errorsJson = COALESCE(@ErrorsJson, N'[]'),
            exportBatchId = CONVERT(nvarchar(36), @ExportBatchId),
            punchExportLogId = @PunchExportLogId,
            projectId = @ProjectId,
            templateId = @TemplateId;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0
            ROLLBACK TRANSACTION;

        THROW;
    END CATCH;
END;
GO

/* Deployment verification only. */
SELECT
    ProcedureName = N'warroom.usp_StageValidatePunchCommentImport',
    ExistsAsProcedure = CAST
    (
        CASE
            WHEN OBJECT_ID(N'warroom.usp_StageValidatePunchCommentImport', N'P') IS NOT NULL
            THEN 1 ELSE 0
        END
        AS bit
    ),
    WritesPunchComment = CAST
    (
        CASE
            WHEN OBJECT_DEFINITION(OBJECT_ID(N'warroom.usp_StageValidatePunchCommentImport', N'P'))
                 LIKE '%INSERT%warroom.PunchComment%'
              OR OBJECT_DEFINITION(OBJECT_ID(N'warroom.usp_StageValidatePunchCommentImport', N'P'))
                 LIKE '%UPDATE%warroom.PunchComment%'
              OR OBJECT_DEFINITION(OBJECT_ID(N'warroom.usp_StageValidatePunchCommentImport', N'P'))
                 LIKE '%DELETE%warroom.PunchComment%'
            THEN 1 ELSE 0
        END
        AS bit
    );
GO
