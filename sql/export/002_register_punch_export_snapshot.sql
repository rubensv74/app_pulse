
/*
    PULSE Excel import - Sprint I01.1

    Registra un snapshot inmutable de una exportación de Punches.

    Identificadores:
    - PunchExportLogId: bigint procedente del proceso de exportación.
    - ExportBatchId: uniqueidentifier técnico del snapshot.

    Este procedimiento no modifica los datos productivos de Punches.
*/

SET NOCOUNT ON;
SET XACT_ABORT ON;
GO

/* ==========================================================================
   1. REGISTRAR SNAPSHOT DE EXPORTACIÓN
   ========================================================================== */

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
        /* ------------------------------------------------------------------
           1. Validación de parámetros
           ------------------------------------------------------------------ */

        IF @PunchExportLogId IS NULL OR @PunchExportLogId <= 0
            THROW 51000, 'PunchExportLogId must be a positive integer.', 1;

        IF @ProjectId IS NULL OR @ProjectId <= 0
            THROW 51001, 'ProjectId must be a positive integer.', 1;

        IF @TemplateId IS NULL OR @TemplateId < 0
            THROW 51002, 'TemplateId cannot be null or negative.', 1;

        SET @ExportType =
            NULLIF(LTRIM(RTRIM(@ExportType)), N'');

        SET @CreatedBy =
            NULLIF(LTRIM(RTRIM(@CreatedBy)), N'');

        SET @FileName =
            NULLIF(LTRIM(RTRIM(@FileName)), N'');

        IF @ExportType IS NULL
            THROW 51003, 'ExportType is required.', 1;

        IF @CreatedBy IS NULL
            THROW 51004, 'CreatedBy is required.', 1;

        IF @FileName IS NULL
            THROW 51005, 'FileName is required.', 1;

        IF ISJSON(@AllowedColumnsJson) <> 1
           OR LEFT(LTRIM(@AllowedColumnsJson), 1) <> N'['
            THROW 51006, 'AllowedColumnsJson must be a JSON array.', 1;

        IF ISJSON(@RowsJson) <> 1
           OR LEFT(LTRIM(@RowsJson), 1) <> N'['
            THROW 51007, 'RowsJson must be a JSON array.', 1;

        /* ------------------------------------------------------------------
           2. Carga inicial permisiva

           WorkItemId se permite NULL temporalmente para poder devolver
           errores funcionales controlados en vez de errores de inserción.
           ------------------------------------------------------------------ */

        DECLARE @RowsStage TABLE
        (
            SourceOrdinal       int             NOT NULL,
            WorkItemId          bigint          NULL,
            SourceProjectId     bigint          NULL,
            SourceExportLogId   bigint          NULL,
            RowChecksum         varchar(64)     NULL,
            OriginalValuesJson  nvarchar(max)   NULL
        );

        INSERT INTO @RowsStage
        (
            SourceOrdinal,
            WorkItemId,
            SourceProjectId,
            SourceExportLogId,
            RowChecksum,
            OriginalValuesJson
        )
        SELECT
            SourceOrdinal =
                TRY_CONVERT(int, src.[key]),

            WorkItemId =
                TRY_CONVERT
                (
                    bigint,
                    JSON_VALUE(src.[value], '$.PunchId')
                ),

            SourceProjectId =
                TRY_CONVERT
                (
                    bigint,
                    JSON_VALUE(src.[value], '$.ProjectId')
                ),

            SourceExportLogId =
                TRY_CONVERT
                (
                    bigint,
                    JSON_VALUE(src.[value], '$.PunchExportLogId')
                ),

            RowChecksum =
                UPPER
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
                                    JSON_VALUE(src.[value], '$.RowHash')
                                )
                            )
                        ),
                        ''
                    )
                ),

            OriginalValuesJson =
                COALESCE
                (
                    JSON_QUERY
                    (
                        src.[value],
                        '$.OriginalValuesJson'
                    ),
                    src.[value]
                )
        FROM OPENJSON(@RowsJson) AS src;

        IF NOT EXISTS
        (
            SELECT 1
            FROM @RowsStage
        )
            THROW 51008, 'The export snapshot does not contain rows.', 1;

        /* ------------------------------------------------------------------
           3. Validación del contenido
           ------------------------------------------------------------------ */

        IF EXISTS
        (
            SELECT 1
            FROM @RowsStage
            WHERE WorkItemId IS NULL
               OR WorkItemId <= 0
               OR RowChecksum IS NULL
               OR LEN(RowChecksum) <> 64
               OR RowChecksum LIKE '%[^0-9A-F]%'
               OR OriginalValuesJson IS NULL
               OR ISJSON(OriginalValuesJson) <> 1
        )
            THROW 51009, 'One or more export rows contain invalid identifiers, checksums or JSON.', 1;

        IF EXISTS
        (
            SELECT
                WorkItemId
            FROM @RowsStage
            GROUP BY
                WorkItemId
            HAVING COUNT(*) > 1
        )
            THROW 51013, 'The export snapshot contains duplicate PunchId values.', 1;

        IF EXISTS
        (
            SELECT 1
            FROM @RowsStage
            WHERE SourceProjectId IS NULL
               OR SourceProjectId <> @ProjectId
               OR SourceExportLogId IS NULL
               OR SourceExportLogId <> @PunchExportLogId
        )
            THROW 51010, 'An export row does not match the batch project or export log.', 1;

        /* ------------------------------------------------------------------
           4. Conjunto validado
           ------------------------------------------------------------------ */

        DECLARE @Rows TABLE
        (
            WorkItemId          bigint          NOT NULL,
            RowChecksum         char(64)        NOT NULL,
            OriginalValuesJson  nvarchar(max)   NOT NULL,

            PRIMARY KEY
            (
                WorkItemId
            )
        );

        INSERT INTO @Rows
        (
            WorkItemId,
            RowChecksum,
            OriginalValuesJson
        )
        SELECT
            WorkItemId,
            CONVERT(char(64), RowChecksum),
            OriginalValuesJson
        FROM @RowsStage;

        DECLARE @RowCount int =
        (
            SELECT COUNT(*)
            FROM @Rows
        );

        DECLARE @EffectiveExpiresAtUtc datetime2(3) =
            COALESCE
            (
                @ExpiresAtUtc,
                DATEADD
                (
                    day,
                    30,
                    CONVERT(datetime2(3), SYSUTCDATETIME())
                )
            );

        DECLARE @ExportBatchId uniqueidentifier;
        DECLARE @ExistingStatus varchar(20);

        /* ------------------------------------------------------------------
           5. Registro transaccional e idempotente
           ------------------------------------------------------------------ */

        BEGIN TRANSACTION;

        SELECT
            @ExportBatchId = ExportBatchId,
            @ExistingStatus = Status
        FROM [warroom].[ExportBatch] WITH (UPDLOCK, HOLDLOCK)
        WHERE PunchExportLogId = @PunchExportLogId;

        /* ------------------------------------------------------------------
           5.1. El snapshot ya existe
           ------------------------------------------------------------------ */

        IF @ExportBatchId IS NOT NULL
        BEGIN
            IF NOT EXISTS
            (
                SELECT 1
                FROM [warroom].[ExportBatch]
                WHERE ExportBatchId = @ExportBatchId
                  AND PunchExportLogId = @PunchExportLogId
                  AND ProjectId = @ProjectId
                  AND TemplateId = @TemplateId
                  AND ExportType = @ExportType
                  AND [RowCount] = @RowCount
                  AND AllowedColumnsJson = @AllowedColumnsJson
                  AND Status IN
                  (
                      'CREATED',
                      'READY'
                  )
            )
                THROW 51011, 'The export batch already exists with different immutable data.', 1;

            IF
            (
                SELECT COUNT(*)
                FROM [warroom].[ExportBatchRow]
                WHERE ExportBatchId = @ExportBatchId
            ) <> @RowCount
                THROW 51012, 'The existing export batch row count is inconsistent.', 1;

            COMMIT TRANSACTION;

            SELECT
                Success =
                    CAST(1 AS bit),

                ExportBatchId =
                    @ExportBatchId,

                PunchExportLogId =
                    @PunchExportLogId,

                Status =
                    @ExistingStatus,

                [RowCount] =
                    @RowCount,

                WasAlreadyRegistered =
                    CAST(1 AS bit);

            RETURN;
        END;

        /* ------------------------------------------------------------------
           5.2. Crear nuevo snapshot
           ------------------------------------------------------------------ */

        SET @ExportBatchId = NEWID();

        INSERT INTO [warroom].[ExportBatch]
        (
            ExportBatchId,
            PunchExportLogId,
            ProjectId,
            TemplateId,
            ExportType,
            CreatedBy,
            CreatedAtUtc,
            ExpiresAtUtc,
            Status,
            FileName,
            [RowCount],
            AllowedColumnsJson
        )
        VALUES
        (
            @ExportBatchId,
            @PunchExportLogId,
            @ProjectId,
            @TemplateId,
            @ExportType,
            @CreatedBy,
            CONVERT(datetime2(3), SYSUTCDATETIME()),
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
            ExportBatchId =
                @ExportBatchId,

            WorkItemId =
                r.WorkItemId,

            RowVersion =
                NULL,

            OriginalValuesJson =
                r.OriginalValuesJson,

            RowChecksum =
                r.RowChecksum
        FROM @Rows AS r;

        COMMIT TRANSACTION;

        SELECT
            Success =
                CAST(1 AS bit),

            ExportBatchId =
                @ExportBatchId,

            PunchExportLogId =
                @PunchExportLogId,

            Status =
                CAST('CREATED' AS varchar(20)),

            [RowCount] =
                @RowCount,

            WasAlreadyRegistered =
                CAST(0 AS bit);
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0
            ROLLBACK TRANSACTION;

        THROW;
    END CATCH;
END;
GO

/* ==========================================================================
   2. COMPLETAR SNAPSHOT DE EXPORTACIÓN
   ========================================================================== */

CREATE OR ALTER PROCEDURE [warroom].[usp_CompletePunchExportBatch]
    @PunchExportLogId bigint,
    @FileName         nvarchar(260),
    @RowCount         int
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRY
        /* ------------------------------------------------------------------
           1. Validación de parámetros
           ------------------------------------------------------------------ */

        IF @PunchExportLogId IS NULL OR @PunchExportLogId <= 0
            THROW 51020, 'PunchExportLogId must be a positive integer.', 1;

        SET @FileName =
            NULLIF(LTRIM(RTRIM(@FileName)), N'');

        IF @FileName IS NULL
            THROW 51021, 'FileName is required.', 1;

        IF @RowCount IS NULL OR @RowCount <= 0
            THROW 51022, 'RowCount must be positive.', 1;

        /* ------------------------------------------------------------------
           2. Recuperar el ExportBatchId técnico
           ------------------------------------------------------------------ */

        BEGIN TRANSACTION;

        DECLARE @ExportBatchId uniqueidentifier;
        DECLARE @StoredRows int;
        DECLARE @Status varchar(20);

        SELECT
            @ExportBatchId = ExportBatchId,
            @StoredRows = [RowCount],
            @Status = Status
        FROM [warroom].[ExportBatch] WITH (UPDLOCK, HOLDLOCK)
        WHERE PunchExportLogId = @PunchExportLogId;

        IF @ExportBatchId IS NULL
            THROW 51023, 'The export batch snapshot does not exist.', 1;

        /* ------------------------------------------------------------------
           3. Validación de consistencia
           ------------------------------------------------------------------ */

        IF @StoredRows <> @RowCount
           OR
           (
               SELECT COUNT(*)
               FROM [warroom].[ExportBatchRow]
               WHERE ExportBatchId = @ExportBatchId
           ) <> @RowCount
            THROW 51024, 'The completed export row count does not match its snapshot.', 1;

        IF @Status NOT IN
        (
            'CREATED',
            'READY'
        )
            THROW 51025, 'The export batch cannot transition to READY.', 1;

        /* ------------------------------------------------------------------
           4. Cambio de estado idempotente
           ------------------------------------------------------------------ */

        UPDATE [warroom].[ExportBatch]
        SET
            FileName = @FileName,
            Status = 'READY'
        WHERE ExportBatchId = @ExportBatchId
          AND Status = 'CREATED';

        COMMIT TRANSACTION;

        SELECT
            Success =
                CAST(1 AS bit),

            ExportBatchId =
                @ExportBatchId,

            PunchExportLogId =
                @PunchExportLogId,

            Status =
                CAST('READY' AS varchar(20)),

            [RowCount] =
                @RowCount,

            WasAlreadyCompleted =
                CAST
                (
                    CASE
                        WHEN @Status = 'READY'
                            THEN 1
                        ELSE 0
                    END
                    AS bit
                );
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0
            ROLLBACK TRANSACTION;

        THROW;
    END CATCH;
END;
GO