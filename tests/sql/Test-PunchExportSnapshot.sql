/*
    Punch export snapshot integration tests.
    Run only in a non-production database after deploying Block A scripts.
    Test records are removed at the end; identity gaps in PunchExportLog are expected.
*/
SET NOCOUNT ON;
SET XACT_ABORT ON;
GO

IF NOT EXISTS (SELECT 1 FROM sys.columns c JOIN sys.types t ON t.user_type_id=c.user_type_id WHERE c.object_id=OBJECT_ID(N'[warroom].[ExportBatch]') AND c.name=N'ExportBatchId' AND t.name=N'uniqueidentifier' AND c.is_nullable=0)
    THROW 51200, 'ExportBatchId schema assertion failed.', 1;
IF NOT EXISTS (SELECT 1 FROM sys.columns c JOIN sys.types t ON t.user_type_id=c.user_type_id WHERE c.object_id=OBJECT_ID(N'[warroom].[ExportBatch]') AND c.name=N'PunchExportLogId' AND t.name=N'bigint' AND c.is_nullable=0)
    THROW 51201, 'PunchExportLogId schema assertion failed.', 1;
IF NOT EXISTS (SELECT 1 FROM sys.columns c JOIN sys.types t ON t.user_type_id=c.user_type_id WHERE c.object_id=OBJECT_ID(N'[warroom].[ExportBatchRow]') AND c.name=N'RowVersion' AND t.name=N'binary' AND c.max_length=8 AND c.is_nullable=1)
    THROW 51202, 'RowVersion must be binary(8) NULL.', 1;
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id=OBJECT_ID(N'[warroom].[ExportBatch]') AND name IN(N'UX_ExportBatch_PunchExportLogId',N'UQ_ExportBatch_PunchExportLogId') AND is_unique=1)
    THROW 51203, 'Unique PunchExportLogId index is missing.', 1;
GO

DECLARE @Log TABLE ([PunchExportLogId] bigint);
DECLARE @Register TABLE
(
    [Success] bit,
    [ExportBatchId] uniqueidentifier,
    [PunchExportLogId] bigint,
    [Status] varchar(20),
    [RowCount] int,
    [WasAlreadyRegistered] bit
);
DECLARE @Complete TABLE
(
    [Success] bit,
    [ExportBatchId] uniqueidentifier,
    [PunchExportLogId] bigint,
    [Status] varchar(20),
    [RowCount] int,
    [WasAlreadyCompleted] bit
);
DECLARE @Fail TABLE
(
    [Success] bit,
    [PunchExportLogId] bigint,
    [ExportStatus] nvarchar(50),
    [ErrorMessage] nvarchar(max)
);

DECLARE @LogId bigint;
DECLARE @FailLogId bigint;
DECLARE @InvalidLogId bigint;
DECLARE @BatchId uniqueidentifier;
DECLARE @Rows nvarchar(max);
DECLARE @InvalidRows nvarchar(max);

BEGIN TRY
    /* Main lifecycle. Do not wrap procedure calls in an outer transaction:
       the procedures own their transactions and rollback behavior. */
    INSERT INTO @Log
    EXEC [warroom].[usp_PunchExportLog_Start]
        @ProjectId=900000001,
        @TemplateSelector=N'77',
        @FilterJson=N'[]',
        @CreatedByEmail=N'codex-test@example.invalid',
        @CreatedByName=N'Codex test';

    SELECT @LogId=MAX(PunchExportLogId) FROM @Log;
    SET @Rows=N'[{"ProjectId":900000001,"PunchId":1001,"PunchExportLogId":'+CONVERT(nvarchar(20),@LogId)+N',"RowHash":"AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA","OriginalValuesJson":{"Code":"P-1001"}},{"ProjectId":900000001,"PunchId":1002,"PunchExportLogId":'+CONVERT(nvarchar(20),@LogId)+N',"RowHash":"BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB","OriginalValuesJson":{"Code":"P-1002"}}]';

    INSERT INTO @Register
    EXEC [warroom].[usp_RegisterPunchExportSnapshot]
        @PunchExportLogId=@LogId,@ProjectId=900000001,@TemplateId=77,
        @ExportType=N'Punches',@CreatedBy=N'codex-test@example.invalid',
        @FileName=N'block-a-test.xlsx',@AllowedColumnsJson=N'[]',@RowsJson=@Rows;

    SELECT @BatchId=ExportBatchId FROM @Register;
    IF (SELECT COUNT(*) FROM [warroom].[ExportBatchRow] WHERE ExportBatchId=@BatchId)<>2
        THROW 51210, 'Snapshot row count failed.', 1;
    IF EXISTS (SELECT 1 FROM [warroom].[ExportBatchRow] WHERE ExportBatchId=@BatchId AND RowVersion IS NOT NULL)
        THROW 51211, 'RowVersion was not NULL.', 1;

    DELETE FROM @Register;
    INSERT INTO @Register
    EXEC [warroom].[usp_RegisterPunchExportSnapshot]
        @PunchExportLogId=@LogId,@ProjectId=900000001,@TemplateId=77,
        @ExportType=N'Punches',@CreatedBy=N'codex-test@example.invalid',
        @FileName=N'block-a-test.xlsx',@AllowedColumnsJson=N'[]',@RowsJson=@Rows;
    IF NOT EXISTS (SELECT 1 FROM @Register WHERE WasAlreadyRegistered=1)
        THROW 51212, 'Identical retry was not idempotent.', 1;

    BEGIN TRY
        EXEC [warroom].[usp_RegisterPunchExportSnapshot]
            @PunchExportLogId=@LogId,@ProjectId=900000001,@TemplateId=78,
            @ExportType=N'Punches',@CreatedBy=N'codex-test@example.invalid',
            @FileName=N'block-a-test.xlsx',@AllowedColumnsJson=N'[]',@RowsJson=@Rows;
        THROW 51213, 'Different retry unexpectedly succeeded.', 1;
    END TRY
    BEGIN CATCH
        IF ERROR_NUMBER()=51213 THROW;
        IF ERROR_NUMBER()<>51011 THROW;
    END CATCH;

    INSERT INTO @Complete
    EXEC [warroom].[usp_CompletePunchExportBatch]
        @PunchExportLogId=@LogId,@FileName=N'block-a-test.xlsx',@RowCount=2;
    DELETE FROM @Complete;
    INSERT INTO @Complete
    EXEC [warroom].[usp_CompletePunchExportBatch]
        @PunchExportLogId=@LogId,@FileName=N'block-a-test.xlsx',@RowCount=2;
    IF NOT EXISTS (SELECT 1 FROM @Complete WHERE WasAlreadyCompleted=1)
        THROW 51214, 'Repeated completion was not idempotent.', 1;

    /* Failure compensation. */
    DELETE FROM @Log;
    INSERT INTO @Log
    EXEC [warroom].[usp_PunchExportLog_Start]
        @ProjectId=900000001,@TemplateSelector=N'77',@FilterJson=N'[]',
        @CreatedByEmail=N'codex-test@example.invalid',@CreatedByName=N'Codex fail test';
    SELECT @FailLogId=MAX(PunchExportLogId) FROM @Log;
    INSERT INTO @Fail
    EXEC [warroom].[usp_PunchExportLog_Fail]
        @PunchExportLogId=@FailLogId,@ErrorMessage=N'Controlled test failure';
    IF NOT EXISTS (SELECT 1 FROM @Fail WHERE ExportStatus=N'Failed' AND ErrorMessage=N'Controlled test failure')
        THROW 51215, 'Failure compensation assertion failed.', 1;

    /* Invalid payload must not create a partial batch. */
    DELETE FROM @Log;
    INSERT INTO @Log
    EXEC [warroom].[usp_PunchExportLog_Start]
        @ProjectId=900000001,@TemplateSelector=N'77',@FilterJson=N'[]',
        @CreatedByEmail=N'codex-test@example.invalid',@CreatedByName=N'Codex rollback test';
    SELECT @InvalidLogId=MAX(PunchExportLogId) FROM @Log;
    SET @InvalidRows=N'[{"ProjectId":900000001,"PunchId":1003,"PunchExportLogId":'+CONVERT(nvarchar(20),@InvalidLogId)+N',"RowHash":"INVALID","OriginalValuesJson":{"Code":"P-1003"}}]';
    BEGIN TRY
        EXEC [warroom].[usp_RegisterPunchExportSnapshot]
            @PunchExportLogId=@InvalidLogId,@ProjectId=900000001,@TemplateId=77,
            @ExportType=N'Punches',@CreatedBy=N'codex-test@example.invalid',
            @FileName=N'block-a-invalid.xlsx',@AllowedColumnsJson=N'[]',@RowsJson=@InvalidRows;
        THROW 51216, 'Invalid payload unexpectedly succeeded.', 1;
    END TRY
    BEGIN CATCH
        IF ERROR_NUMBER()=51216 THROW;
        IF ERROR_NUMBER()<>51009 THROW;
    END CATCH;
    IF EXISTS (SELECT 1 FROM [warroom].[ExportBatch] WHERE PunchExportLogId=@InvalidLogId)
        THROW 51217, 'Invalid payload left a partial ExportBatch.', 1;

    /* Cleanup in FK order; logs are retained on failure by the CATCH block. */
    DELETE FROM [warroom].[ExportBatchRow] WHERE ExportBatchId=@BatchId;
    DELETE FROM [warroom].[ExportBatch] WHERE ExportBatchId=@BatchId;
    DELETE FROM [warroom].[PunchExportLog] WHERE PunchExportLogId IN (@LogId,@FailLogId,@InvalidLogId);

    SELECT TestResult=N'PASS - schema, snapshot, retries, completion, failure compensation and rollback assertions';
END TRY
BEGIN CATCH
    DECLARE @TestError nvarchar(2048)=CONCAT(N'Punch export snapshot test failed. Error ',ERROR_NUMBER(),N': ',ERROR_MESSAGE(),N'. Test log IDs: ',COALESCE(CONVERT(nvarchar(20),@LogId),N'NULL'),N', ',COALESCE(CONVERT(nvarchar(20),@FailLogId),N'NULL'),N', ',COALESCE(CONVERT(nvarchar(20),@InvalidLogId),N'NULL'),N'.');
    THROW 51299,@TestError,1;
END CATCH;
GO
