/*
    PULSE — PR-IMP-C02
    Comments-only v1 contract seed.

    Purpose
    -------
    Register NewComment as the only editable business column for the first
    governed Punch comment-import capability.

    This script does NOT modify PunchComment or any production Punch data.
*/

SET NOCOUNT ON;
SET XACT_ABORT ON;
GO

IF OBJECT_ID(N'[warroom].[ImportColumnDefinition]', N'U') IS NULL
    THROW 52300, 'PR-IMP-C02: warroom.ImportColumnDefinition does not exist.', 1;
GO

DECLARE @ContractVersion smallint = 3;
DECLARE @ExcelColumnName nvarchar(128) = N'NewComment';

UPDATE target
SET
    TargetFieldName = N'NewComment',
    DataType = 'string',
    IsEditable = 1,
    IsRequired = 0,
    MaxLength = NULL,
    ValidationRule = N'Blank means no change. Nonblank text appends one PunchComment. No clear/overwrite semantics in v1.',
    DisplayOrder = 1000,
    DisplayName = N'New Comment',
    IsActive = 1
FROM [warroom].[ImportColumnDefinition] AS target
WHERE target.ContractVersion = @ContractVersion
  AND target.ExcelColumnName = @ExcelColumnName
  AND target.TemplateCode IS NULL
  AND target.ProjectId IS NULL;

IF @@ROWCOUNT = 0
BEGIN
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
    VALUES
    (
        @ContractVersion,
        @ExcelColumnName,
        N'NewComment',
        'string',
        1,
        0,
        NULL,
        N'Blank means no change. Nonblank text appends one PunchComment. No clear/overwrite semantics in v1.',
        NULL,
        NULL,
        1000,
        N'New Comment',
        1
    );
END;
GO

SELECT
    ContractVersion,
    ExcelColumnName,
    TargetFieldName,
    DataType,
    IsEditable,
    IsRequired,
    MaxLength,
    ValidationRule,
    DisplayName,
    IsActive
FROM [warroom].[ImportColumnDefinition]
WHERE ContractVersion = 3
  AND ExcelColumnName = N'NewComment'
  AND TemplateCode IS NULL
  AND ProjectId IS NULL;
GO
