/*
    PULSE Excel import - Sprint I01.1
    Registers an immutable export snapshot in one set-based operation.

    ExportBatchId is the existing PunchExportLogId. This procedure does not
    modify Punch production data.
*/

SET NOCOUNT ON;
SET XACT_ABORT ON;
GO

CREATE OR ALTER PROCEDURE [warroom].[usp_RegisterPunchExportSnapshot]
    @PunchExportLogId    bigint,
    @ProjectId           bigint,
    @TemplateId          bigint,
    @ExportType          nvarchar(30),
    @CreatedBy           nvarchar(320),
    @FileName            nvarchar(260),
    @AllowedColumnsJson  nvarchar(max),
    @RowsJson            nvarchar(max),
    @ExpiresAtUtc        datetime2(3) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRY
        IF @PunchExportLogId IS NULL OR @PunchExportLogId <= 0
            THROW 51000, 'PunchExportLogId must be a positive integer.', 1;

        IF @ProjectId IS NULL OR @ProjectId <= 0
            THROW 51001, 'ProjectId must be a positive integer.', 1;

        IF @TemplateId IS NULL OR @TemplateId < 0
            THROW 51002, 'TemplateId cannot be null or negative.', 1;

        IF NULLIF(LTRIM(RTRIM(@ExportType)), N'') IS NULL
            THROW 51003, 'ExportType is required.', 1;

        IF NULLIF(LTRIM(RTRIM(@CreatedBy)), N'') IS NULL
            THROW 51004, 'CreatedBy is required.', 1;

        IF NULLIF(LTRIM(RTRIM(@FileName)), N'') IS NULL
            THROW 51005, 'FileName is required.', 1;

        IF ISJSON(@AllowedColumnsJson) <> 1
           OR LEFT(LTRIM(@AllowedColumnsJson), 1) <> '['
            THROW 51006, 'AllowedColumnsJson must be a JSON array.', 1;

        IF ISJSON(@RowsJson) <> 1 OR LEFT(LTRIM(@RowsJson), 1) <> '['
            THROW 51007, 'RowsJson must be a JSON array.', 1;

        DECLARE @Rows TABLE
        (
            WorkItemId          bigint NOT NULL PRIMARY KEY,
            RowChecksum         char(64) NOT NULL,
            OriginalValuesJson  nvarchar(max) NOT NULL
        );

        INSERT INTO @Rows
        (
            WorkItemId,
            RowChecksum,
            OriginalValuesJson
        )
        SELECT
            WorkItemId = TRY_CONVERT(bigint, JSON_VALUE(src.[value], '$.PunchId')),
            RowChecksum = UPPER(CONVERT(char(64), JSON_VALUE(src.[value], '$.RowHash'))),
            OriginalValuesJson =
                COALESCE(JSON_QUERY(src.[value], '$.OriginalValuesJson'), src.[value])
        FROM OPENJSON(@RowsJson) src;

        IF NOT EXISTS (SELECT 1 FROM @Rows)
            THROW 51008, 'The export snapshot does not contain rows.', 1;

        IF EXISTS
        (
            SELECT 1
            FROM @Rows
            WHERE WorkItemId IS NULL
               OR WorkItemId <= 0
               OR LEN(RowChecksum) <> 64
               OR RowChecksum LIKE '%[^0-9A-F]%'
               OR ISJSON(OriginalValuesJson) <> 1
        )
            THROW 51009, 'One or more export rows contain invalid identifiers, checksums or JSON.', 1;

        IF EXISTS
        (
            SELECT 1
            FROM OPENJSON(@RowsJson) src
            WHERE TRY_CONVERT(bigint, JSON_VALUE(src.[value], '$.ProjectId')) <> @ProjectId
               OR TRY_CONVERT(bigint, JSON_VALUE(src.[value], '$.PunchExportLogId')) <> @PunchExportLogId
        )
            THROW 51010, 'An export row does not match the batch project or export log.', 1;

        DECLARE @RowCount int = (SELECT COUNT(*) FROM @Rows);
        DECLARE @EffectiveExpiresAtUtc datetime2(3) =
            COALESCE(@ExpiresAtUtc, DATEADD(day, 30, SYSUTCDATETIME()));

        BEGIN TRANSACTION;

        IF EXISTS
        (
            SELECT 1
            FROM [warroom].[ExportBatch] WITH (UPDLOCK, HOLDLOCK)
            WHERE ExportBatchId = @PunchExportLogId
        )
        BEGIN
            IF NOT EXISTS
            (
                SELECT 1
                FROM [warroom].[ExportBatch]
                WHERE ExportBatchId = @PunchExportLogId
                  AND ProjectId = @ProjectId
                  AND TemplateId = @TemplateId
                  AND RowCount = @RowCount
                  AND AllowedColumnsJson = @AllowedColumnsJson
                  AND Status IN ('CREATED', 'READY')
            )
                THROW 51011, 'The export batch already exists with different immutable data.', 1;

            IF
            (
                SELECT COUNT(*)
                FROM [warroom].[ExportBatchRow]
                WHERE ExportBatchId = @PunchExportLogId
            ) <> @RowCount
                THROW 51012, 'The existing export batch row count is inconsistent.', 1;

            COMMIT TRANSACTION;

            SELECT
                Success = CAST(1 AS bit),
                ExportBatchId = @PunchExportLogId,
                Status = CAST('CREATED' AS varchar(20)),
                RowCount = @RowCount,
                WasAlreadyRegistered = CAST(1 AS bit);
            RETURN;
        END;

        INSERT INTO [warroom].[ExportBatch]
        (
            ExportBatchId,
            ProjectId,
            TemplateId,
            ExportType,
            CreatedBy,
            CreatedAtUtc,
            ExpiresAtUtc,
            Status,
            FileName,
            RowCount,
            AllowedColumnsJson
        )
        VALUES
        (
            @PunchExportLogId,
            @ProjectId,
            @TemplateId,
            @ExportType,
            @CreatedBy,
            SYSUTCDATETIME(),
            @EffectiveExpiresAtUtc,
            'CREATED',
            @FileName,
            @RowCount,
            @AllowedColumnsJson
        );

        INSERT INTO [warroom].[ExportBatchRow]
        (
            ExportBatchId,
            WorkItemId,
            RowVersion,
            OriginalValuesJson,
            RowChecksum
        )
        SELECT
            @PunchExportLogId,
            WorkItemId,
            NULL,
            OriginalValuesJson,
            RowChecksum
        FROM @Rows;

        COMMIT TRANSACTION;

        SELECT
            Success = CAST(1 AS bit),
            ExportBatchId = @PunchExportLogId,
            Status = CAST('CREATED' AS varchar(20)),
            RowCount = @RowCount,
            WasAlreadyRegistered = CAST(0 AS bit);
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0
            ROLLBACK TRANSACTION;

        THROW;
    END CATCH;
END;
GO

CREATE OR ALTER PROCEDURE [warroom].[usp_CompletePunchExportBatch]
    @PunchExportLogId bigint,
    @FileName         nvarchar(260),
    @RowCount         int
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRY
        IF @PunchExportLogId IS NULL OR @PunchExportLogId <= 0
            THROW 51020, 'PunchExportLogId must be a positive integer.', 1;

        IF NULLIF(LTRIM(RTRIM(@FileName)), N'') IS NULL
            THROW 51021, 'FileName is required.', 1;

        IF @RowCount IS NULL OR @RowCount <= 0
            THROW 51022, 'RowCount must be positive.', 1;

        BEGIN TRANSACTION;

        DECLARE @StoredRows int;
        DECLARE @Status varchar(20);

        SELECT
            @StoredRows = RowCount,
            @Status = Status
        FROM [warroom].[ExportBatch] WITH (UPDLOCK, HOLDLOCK)
        WHERE ExportBatchId = @PunchExportLogId;

        IF @Status IS NULL
            THROW 51023, 'The export batch snapshot does not exist.', 1;

        IF @StoredRows <> @RowCount
           OR
           (
               SELECT COUNT(*)
               FROM [warroom].[ExportBatchRow]
               WHERE ExportBatchId = @PunchExportLogId
           ) <> @RowCount
            THROW 51024, 'The completed export row count does not match its snapshot.', 1;

        IF @Status NOT IN ('CREATED', 'READY')
            THROW 51025, 'The export batch cannot transition to READY.', 1;

        UPDATE [warroom].[ExportBatch]
        SET
            FileName = @FileName,
            Status = 'READY'
        WHERE ExportBatchId = @PunchExportLogId
          AND Status = 'CREATED';

        COMMIT TRANSACTION;

        SELECT
            Success = CAST(1 AS bit),
            ExportBatchId = @PunchExportLogId,
            Status = CAST('READY' AS varchar(20)),
            RowCount = @RowCount;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0
            ROLLBACK TRANSACTION;

        THROW;
    END CATCH;
END;
GO
