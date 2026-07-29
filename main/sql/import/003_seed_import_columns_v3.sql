/*
    PULSE Excel import - Sprint I01.1
    Seeds the physical technical-column mappings. Business-column mappings
    Contract v3. Business columns remain governed by usp_GetPunchExportColumnMap / IsEditableInExcel.
*/

SET NOCOUNT ON;
SET XACT_ABORT ON;
GO

DECLARE @Definitions TABLE
(
    ContractVersion smallint NOT NULL,
    ExcelColumnName nvarchar(128) NOT NULL,
    TargetFieldName sysname NOT NULL,
    DataType varchar(20) NOT NULL,
    IsEditable bit NOT NULL,
    IsRequired bit NOT NULL,
    MaxLength int NULL,
    ValidationRule nvarchar(1000) NULL,
    DisplayOrder int NOT NULL,
    DisplayName nvarchar(128) NOT NULL
);

INSERT INTO @Definitions
(
    ContractVersion,
    ExcelColumnName,
    TargetFieldName,
    DataType,
    IsEditable,
    IsRequired,
    MaxLength,
    ValidationRule,
    DisplayOrder,
    DisplayName
)
VALUES
    (3, N'ExportBatchId',  N'ExportBatchId',  'integer', 0, 1, NULL, N'Must equal PunchExportLogId and the stored export batch.', -700, N'Export batch'),
    (3, N'ProjectId',      N'ProjectId',      'integer', 0, 1, NULL, N'One value per file; must match the stored export batch.', -600, N'Project'),
    (3, N'TemplateId',     N'TemplateId',     'integer', 0, 1, NULL, N'One value per import file; must match the stored export row.', -500, N'Template'),
    (3, N'WorkItemId',     N'WorkItemId',     'integer', 0, 1, NULL, N'Unique in file; must exist in ExportBatchRow.', -400, N'Work item'),
    (3, N'RowVersion',     N'RowVersion',     'string',  0, 0, 16,   N'Optional until the Punch source exposes binary rowversion.', -300, N'Row version'),
    (3, N'ExportedAtUtc',  N'ExportedAtUtc',  'datetime',0, 1, NULL, N'ISO 8601 UTC; must match export metadata.', -200, N'Exported at UTC'),
    (3, N'RowChecksum',    N'RowChecksum',    'string',  0, 1, 64,   N'Uppercase SHA-256; must match ExportBatchRow.', -100, N'Row checksum');

UPDATE target
SET
    TargetFieldName = source.TargetFieldName,
    DataType = source.DataType,
    IsEditable = source.IsEditable,
    IsRequired = source.IsRequired,
    MaxLength = source.MaxLength,
    ValidationRule = source.ValidationRule,
    DisplayOrder = source.DisplayOrder,
    DisplayName = source.DisplayName,
    IsActive = 1
FROM [warroom].[ImportColumnDefinition] target
INNER JOIN @Definitions source
    ON source.ContractVersion = target.ContractVersion
   AND source.ExcelColumnName = target.ExcelColumnName
WHERE target.TemplateCode IS NULL
  AND target.ProjectId IS NULL;

INSERT INTO [warroom].[ImportColumnDefinition]
(
    ContractVersion,
    ExcelColumnName,
    TargetFieldName,
    DataType,
    IsEditable,
    IsRequired,
    MaxLength,
    ValidationRule,
    TemplateCode,
    ProjectId,
    DisplayOrder,
    DisplayName,
    IsActive
)
SELECT
    source.ContractVersion,
    source.ExcelColumnName,
    source.TargetFieldName,
    source.DataType,
    source.IsEditable,
    source.IsRequired,
    source.MaxLength,
    source.ValidationRule,
    NULL,
    NULL,
    source.DisplayOrder,
    source.DisplayName,
    1
FROM @Definitions source
WHERE NOT EXISTS
(
    SELECT 1
    FROM [warroom].[ImportColumnDefinition] target
    WHERE target.ContractVersion = source.ContractVersion
      AND target.ExcelColumnName = source.ExcelColumnName
      AND target.TemplateCode IS NULL
      AND target.ProjectId IS NULL
);
GO
