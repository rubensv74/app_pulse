/*
    PULSE Excel import - Sprint I01 foundations
    Target: Azure SQL Database

    This script creates only import/export foundation objects. It does not update
    production punch data and may be rerun safely.
*/

SET NOCOUNT ON;
SET XACT_ABORT ON;
GO

IF SCHEMA_ID(N'warroom') IS NULL
    EXEC(N'CREATE SCHEMA [warroom] AUTHORIZATION [dbo];');
GO

IF OBJECT_ID(N'[warroom].[ExportBatch]', N'U') IS NULL
BEGIN
    CREATE TABLE [warroom].[ExportBatch]
    (
        [ExportBatchId]        bigint NOT NULL,
        [ProjectId]            bigint NOT NULL,
        [TemplateId]           bigint NOT NULL,
        [ExportType]           nvarchar(30) NOT NULL,
        [CreatedBy]            nvarchar(320) NOT NULL,
        [CreatedAtUtc]         datetime2(3) NOT NULL
            CONSTRAINT [DF_ExportBatch_CreatedAtUtc] DEFAULT SYSUTCDATETIME(),
        [ExpiresAtUtc]         datetime2(3) NOT NULL,
        [Status]               varchar(20) NOT NULL
            CONSTRAINT [DF_ExportBatch_Status] DEFAULT 'CREATED',
        [FileName]             nvarchar(260) NOT NULL,
        [RowCount]             int NOT NULL,
        [AllowedColumnsJson]   nvarchar(max) NOT NULL,
        CONSTRAINT [PK_ExportBatch] PRIMARY KEY CLUSTERED ([ExportBatchId]),
        CONSTRAINT [CK_ExportBatch_RowCount] CHECK ([RowCount] >= 0),
        CONSTRAINT [CK_ExportBatch_Dates] CHECK ([ExpiresAtUtc] > [CreatedAtUtc]),
        CONSTRAINT [CK_ExportBatch_AllowedColumnsJson]
            CHECK (ISJSON([AllowedColumnsJson]) = 1),
        CONSTRAINT [CK_ExportBatch_Status]
            CHECK ([Status] IN ('CREATED', 'READY', 'EXPIRED', 'REVOKED'))
    );
END;
GO

IF OBJECT_ID(N'[warroom].[ExportBatchRow]', N'U') IS NULL
BEGIN
    CREATE TABLE [warroom].[ExportBatchRow]
    (
        [ExportBatchId]        bigint NOT NULL,
        [WorkItemId]           bigint NOT NULL,
        [RowVersion]           binary(8) NOT NULL,
        [OriginalValuesJson]   nvarchar(max) NOT NULL,
        [RowChecksum]          char(64) NOT NULL,
        CONSTRAINT [PK_ExportBatchRow]
            PRIMARY KEY CLUSTERED ([ExportBatchId], [WorkItemId]),
        CONSTRAINT [FK_ExportBatchRow_ExportBatch]
            FOREIGN KEY ([ExportBatchId])
            REFERENCES [warroom].[ExportBatch] ([ExportBatchId]),
        CONSTRAINT [CK_ExportBatchRow_OriginalValuesJson]
            CHECK (ISJSON([OriginalValuesJson]) = 1),
        CONSTRAINT [CK_ExportBatchRow_RowChecksum]
            CHECK ([RowChecksum] NOT LIKE '%[^0-9A-Fa-f]%')
    );
END;
GO

IF OBJECT_ID(N'[warroom].[ImportBatch]', N'U') IS NULL
BEGIN
    CREATE TABLE [warroom].[ImportBatch]
    (
        [ImportBatchId]        uniqueidentifier NOT NULL
            CONSTRAINT [DF_ImportBatch_ImportBatchId] DEFAULT NEWSEQUENTIALID(),
        [ExportBatchId]        bigint NOT NULL,
        [ProjectId]            bigint NOT NULL,
        [TemplateId]           bigint NOT NULL,
        [FileName]             nvarchar(260) NOT NULL,
        [RequestedBy]          nvarchar(320) NOT NULL,
        [RequestedAtUtc]       datetime2(3) NOT NULL
            CONSTRAINT [DF_ImportBatch_RequestedAtUtc] DEFAULT SYSUTCDATETIME(),
        [ValidatedAtUtc]       datetime2(3) NULL,
        [CommittedAtUtc]       datetime2(3) NULL,
        [Status]               varchar(20) NOT NULL
            CONSTRAINT [DF_ImportBatch_Status] DEFAULT 'CREATED',
        [TotalRows]            int NOT NULL CONSTRAINT [DF_ImportBatch_TotalRows] DEFAULT 0,
        [ChangedRows]          int NOT NULL CONSTRAINT [DF_ImportBatch_ChangedRows] DEFAULT 0,
        [UnchangedRows]        int NOT NULL CONSTRAINT [DF_ImportBatch_UnchangedRows] DEFAULT 0,
        [ValidRows]            int NOT NULL CONSTRAINT [DF_ImportBatch_ValidRows] DEFAULT 0,
        [WarningRows]          int NOT NULL CONSTRAINT [DF_ImportBatch_WarningRows] DEFAULT 0,
        [ErrorRows]            int NOT NULL CONSTRAINT [DF_ImportBatch_ErrorRows] DEFAULT 0,
        [ConflictRows]         int NOT NULL CONSTRAINT [DF_ImportBatch_ConflictRows] DEFAULT 0,
        [AppliedRows]          int NOT NULL CONSTRAINT [DF_ImportBatch_AppliedRows] DEFAULT 0,
        [FailedRows]           int NOT NULL CONSTRAINT [DF_ImportBatch_FailedRows] DEFAULT 0,
        [ErrorMessage]         nvarchar(2000) NULL,
        CONSTRAINT [PK_ImportBatch] PRIMARY KEY CLUSTERED ([ImportBatchId]),
        CONSTRAINT [FK_ImportBatch_ExportBatch]
            FOREIGN KEY ([ExportBatchId])
            REFERENCES [warroom].[ExportBatch] ([ExportBatchId]),
        CONSTRAINT [UQ_ImportBatch_ExportBatchId] UNIQUE ([ExportBatchId]),
        CONSTRAINT [CK_ImportBatch_Status]
            CHECK ([Status] IN
                ('CREATED', 'STAGED', 'VALIDATING', 'READY', 'BLOCKED',
                 'COMMITTING', 'COMMITTED', 'CANCELLED', 'FAILED', 'EXPIRED')),
        CONSTRAINT [CK_ImportBatch_Counts]
            CHECK
            (
                [TotalRows] >= 0 AND [ChangedRows] >= 0 AND [UnchangedRows] >= 0
                AND [ValidRows] >= 0 AND [WarningRows] >= 0 AND [ErrorRows] >= 0
                AND [ConflictRows] >= 0 AND [AppliedRows] >= 0 AND [FailedRows] >= 0
            )
    );
END;
GO

IF OBJECT_ID(N'[warroom].[ImportBatchRow]', N'U') IS NULL
BEGIN
    CREATE TABLE [warroom].[ImportBatchRow]
    (
        [ImportBatchRowId]     bigint IDENTITY(1,1) NOT NULL,
        [ImportBatchId]        uniqueidentifier NOT NULL,
        [ExcelRowNumber]       int NOT NULL,
        [WorkItemId]           bigint NULL,
        [IncomingValuesJson]   nvarchar(max) NOT NULL,
        [OriginalValuesJson]   nvarchar(max) NULL,
        [CurrentValuesJson]    nvarchar(max) NULL,
        [ChangedColumnsJson]   nvarchar(max) NULL,
        [ValidationStatus]     varchar(20) NOT NULL
            CONSTRAINT [DF_ImportBatchRow_ValidationStatus] DEFAULT 'PENDING',
        [ValidationErrorsJson] nvarchar(max) NOT NULL
            CONSTRAINT [DF_ImportBatchRow_ValidationErrorsJson] DEFAULT N'[]',
        [ValidationWarningsJson] nvarchar(max) NOT NULL
            CONSTRAINT [DF_ImportBatchRow_ValidationWarningsJson] DEFAULT N'[]',
        [ApplyStatus]          varchar(20) NOT NULL
            CONSTRAINT [DF_ImportBatchRow_ApplyStatus] DEFAULT 'NOT_APPLIED',
        [ApplyError]           nvarchar(2000) NULL,
        CONSTRAINT [PK_ImportBatchRow] PRIMARY KEY CLUSTERED ([ImportBatchRowId]),
        CONSTRAINT [FK_ImportBatchRow_ImportBatch]
            FOREIGN KEY ([ImportBatchId])
            REFERENCES [warroom].[ImportBatch] ([ImportBatchId]),
        CONSTRAINT [UQ_ImportBatchRow_ExcelRow]
            UNIQUE ([ImportBatchId], [ExcelRowNumber]),
        CONSTRAINT [CK_ImportBatchRow_ExcelRowNumber] CHECK ([ExcelRowNumber] >= 2),
        CONSTRAINT [CK_ImportBatchRow_Json]
            CHECK
            (
                ISJSON([IncomingValuesJson]) = 1
                AND ([OriginalValuesJson] IS NULL OR ISJSON([OriginalValuesJson]) = 1)
                AND ([CurrentValuesJson] IS NULL OR ISJSON([CurrentValuesJson]) = 1)
                AND ([ChangedColumnsJson] IS NULL OR ISJSON([ChangedColumnsJson]) = 1)
                AND ISJSON([ValidationErrorsJson]) = 1
                AND ISJSON([ValidationWarningsJson]) = 1
            ),
        CONSTRAINT [CK_ImportBatchRow_ValidationStatus]
            CHECK ([ValidationStatus] IN
                ('PENDING', 'READY', 'UNCHANGED', 'WARNING', 'ERROR', 'CONFLICT')),
        CONSTRAINT [CK_ImportBatchRow_ApplyStatus]
            CHECK ([ApplyStatus] IN ('NOT_APPLIED', 'APPLIED', 'FAILED', 'SKIPPED'))
    );
END;
GO

IF OBJECT_ID(N'[warroom].[ImportAudit]', N'U') IS NULL
BEGIN
    CREATE TABLE [warroom].[ImportAudit]
    (
        [ImportAuditId]        bigint IDENTITY(1,1) NOT NULL,
        [ImportBatchId]        uniqueidentifier NOT NULL,
        [WorkItemId]           bigint NOT NULL,
        [ColumnName]           sysname NOT NULL,
        [OldValue]             nvarchar(max) NULL,
        [NewValue]             nvarchar(max) NULL,
        [ChangedBy]            nvarchar(320) NOT NULL,
        [ChangedAtUtc]         datetime2(3) NOT NULL
            CONSTRAINT [DF_ImportAudit_ChangedAtUtc] DEFAULT SYSUTCDATETIME(),
        CONSTRAINT [PK_ImportAudit] PRIMARY KEY CLUSTERED ([ImportAuditId]),
        CONSTRAINT [FK_ImportAudit_ImportBatch]
            FOREIGN KEY ([ImportBatchId])
            REFERENCES [warroom].[ImportBatch] ([ImportBatchId])
    );
END;
GO

IF OBJECT_ID(N'[warroom].[ImportColumnDefinition]', N'U') IS NULL
BEGIN
    CREATE TABLE [warroom].[ImportColumnDefinition]
    (
        [ImportColumnDefinitionId] int IDENTITY(1,1) NOT NULL,
        [ContractVersion]       smallint NOT NULL,
        [ExcelColumnName]       nvarchar(128) NOT NULL,
        [TargetFieldName]       sysname NOT NULL,
        [DataType]              varchar(20) NOT NULL,
        [IsEditable]            bit NOT NULL,
        [IsRequired]            bit NOT NULL,
        [MaxLength]             int NULL,
        [ValidationRule]        nvarchar(1000) NULL,
        [TemplateCode]          nvarchar(50) NULL,
        [ProjectId]             bigint NULL,
        [DisplayOrder]          int NOT NULL,
        [DisplayName]           nvarchar(128) NOT NULL,
        [IsActive]              bit NOT NULL
            CONSTRAINT [DF_ImportColumnDefinition_IsActive] DEFAULT 1,
        CONSTRAINT [PK_ImportColumnDefinition]
            PRIMARY KEY CLUSTERED ([ImportColumnDefinitionId]),
        CONSTRAINT [UQ_ImportColumnDefinition_Scope]
            UNIQUE
            (
                [ContractVersion], [ExcelColumnName],
                [TemplateCode], [ProjectId]
            ),
        CONSTRAINT [CK_ImportColumnDefinition_DataType]
            CHECK ([DataType] IN ('string', 'integer', 'decimal', 'boolean', 'date', 'datetime')),
        CONSTRAINT [CK_ImportColumnDefinition_MaxLength]
            CHECK ([MaxLength] IS NULL OR [MaxLength] > 0)
    );
END;
GO

IF NOT EXISTS
(
    SELECT 1
    FROM sys.indexes
    WHERE [object_id] = OBJECT_ID(N'[warroom].[ImportBatchRow]')
      AND [name] = N'IX_ImportBatchRow_BatchStatus'
)
    CREATE INDEX [IX_ImportBatchRow_BatchStatus]
        ON [warroom].[ImportBatchRow] ([ImportBatchId], [ValidationStatus])
        INCLUDE ([ExcelRowNumber], [WorkItemId], [ApplyStatus]);
GO

IF NOT EXISTS
(
    SELECT 1
    FROM sys.indexes
    WHERE [object_id] = OBJECT_ID(N'[warroom].[ImportAudit]')
      AND [name] = N'IX_ImportAudit_BatchWorkItem'
)
    CREATE INDEX [IX_ImportAudit_BatchWorkItem]
        ON [warroom].[ImportAudit] ([ImportBatchId], [WorkItemId]);
GO
