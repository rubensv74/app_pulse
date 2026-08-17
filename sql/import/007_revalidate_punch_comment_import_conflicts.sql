/*
    PULSE — PR-IMP-C03
    Current-state + conflict revalidation for Comments-only v1.

    Purpose
    -------
    Rebuild the governed current-state snapshot for every staged WorkItem and
    compare its SHA-256 checksum with the immutable ExportBatchRow checksum.

    Safety
    ------
    - Never writes to warroom.PunchComment.
    - Only updates ImportBatch / ImportBatchRow staging state.
    - Blank New Comment rows remain UNCHANGED even if the current Punch changed.
    - Rows with an incoming New Comment become CONFLICT when current state no
      longer matches the immutable export snapshot.
    - No force-overwrite path exists.

    Conservative v1 rule
    --------------------
    Any governed snapshot change blocks a row with an incoming comment. This
    includes changes to the current Punch fields, hierarchy, subcontractor,
    comment summary or exportable Custom Fields because all of those values are
    part of the row checksum produced by the governed INTERNAL export.
*/

SET NOCOUNT ON;
SET XACT_ABORT ON;
GO

CREATE OR ALTER PROCEDURE [warroom].[usp_RevalidatePunchCommentImportConflicts]
(
    @ImportBatchId uniqueidentifier
)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRY
        IF @ImportBatchId IS NULL
            THROW 52330, 'PR-IMP-C03: ImportBatchId is required.', 1;

        DECLARE @ProjectId bigint;
        DECLARE @TemplateId bigint;
        DECLARE @ExportBatchId uniqueidentifier;
        DECLARE @ImportStatus varchar(20);
        DECLARE @ExportStatus varchar(20);
        DECLARE @ExpiresAtUtc datetime2(3);

        SELECT
            @ProjectId = ib.ProjectId,
            @TemplateId = ib.TemplateId,
            @ExportBatchId = ib.ExportBatchId,
            @ImportStatus = ib.Status
        FROM warroom.ImportBatch AS ib
        WHERE ib.ImportBatchId = @ImportBatchId;

        IF @ExportBatchId IS NULL
            THROW 52331, 'PR-IMP-C03: ImportBatchId does not exist.', 1;

        IF @ImportStatus IN ('COMMITTING', 'COMMITTED', 'CANCELLED', 'FAILED', 'EXPIRED')
            THROW 52332, 'PR-IMP-C03: this ImportBatch state cannot be revalidated.', 1;

        SELECT
            @ExportStatus = eb.Status,
            @ExpiresAtUtc = eb.ExpiresAtUtc
        FROM warroom.ExportBatch AS eb
        WHERE eb.ExportBatchId = @ExportBatchId;

        IF @ExportStatus IS NULL
            THROW 52333, 'PR-IMP-C03: the export snapshot does not exist.', 1;

        IF @ExportStatus <> 'READY'
            THROW 52334, 'PR-IMP-C03: the export snapshot is not READY.', 1;

        IF @ExpiresAtUtc <= CONVERT(datetime2(3), SYSUTCDATETIME())
        BEGIN
            UPDATE warroom.ImportBatch
            SET
                Status = 'EXPIRED',
                ConflictRows = 0,
                ErrorMessage = N'The governed export snapshot has expired.'
            WHERE ImportBatchId = @ImportBatchId;

            SELECT
                success = CAST(1 AS bit),
                importBatchId = CONVERT(nvarchar(36), @ImportBatchId),
                status = CAST('EXPIRED' AS varchar(20)),
                totalRows = ib.TotalRows,
                changedRows = ib.ChangedRows,
                unchangedRows = ib.UnchangedRows,
                validRows = ib.ValidRows,
                warningRows = ib.WarningRows,
                errorRows = ib.ErrorRows,
                conflictRows = ib.ConflictRows,
                canCommit = CAST(0 AS bit),
                [message] = N'The governed export snapshot has expired.'
            FROM warroom.ImportBatch ib
            WHERE ib.ImportBatchId = @ImportBatchId;

            RETURN;
        END;

        DROP TABLE IF EXISTS #BatchItems;
        CREATE TABLE #BatchItems
        (
            WorkItemId bigint NOT NULL PRIMARY KEY,
            HasIncomingChange bit NOT NULL
        );

        INSERT INTO #BatchItems (WorkItemId, HasIncomingChange)
        SELECT
            ibr.WorkItemId,
            HasIncomingChange = CONVERT
            (
                bit,
                CASE
                    WHEN ibr.ChangedColumnsJson IS NOT NULL
                     AND ISJSON(ibr.ChangedColumnsJson) = 1
                     AND ibr.ChangedColumnsJson <> N'[]'
                    THEN 1 ELSE 0
                END
            )
        FROM warroom.ImportBatchRow AS ibr
        WHERE ibr.ImportBatchId = @ImportBatchId
          AND ibr.WorkItemId IS NOT NULL;

        IF NOT EXISTS (SELECT 1 FROM #BatchItems)
            THROW 52335, 'PR-IMP-C03: the ImportBatch contains no valid WorkItems.', 1;

        DROP TABLE IF EXISTS #CurrentBase;

        ;WITH PunchBase AS
        (
            SELECT
                h.AreaCode,
                h.UnitCode,
                h.SystemCode,
                SubsystemCode = COALESCE(NULLIF(LTRIM(RTRIM(h.SubsystemCode)), ''), 'NO SUBSYSTEM'),
                h.ItemCode AS ElementCode,
                p.ProjectId,
                CONVERT(bigint, p.Id) AS PunchId,
                p.TemplateID AS TemplateId,
                p.Code,
                p.[Description],
                p.PunchCoordinator,
                p.Originator,
                p.CategoryCode,
                p.Category,
                p.Discipline AS PunchDiscipline,
                p.StatusCode,
                p.[Status] AS PunchStatus,
                p.InspectionCode,
                p.InspectionName,
                p.InspectionType,
                p.EntryType,
                p.EntryTypeColor,
                p.Topic,
                p.RejectCount,
                p.Items AS ItemsRaw,
                p.SubcontractorId,
                SubcontractorCode = CONVERT(nvarchar(50), mc.ID_COMPANY),
                SubcontractorName = mc.DS_COMPANY,
                SubcontractorShortName = mc.DS_SHORT_COMPANY,
                p.DepartmentAction,
                rn = ROW_NUMBER() OVER
                (
                    PARTITION BY p.Id
                    ORDER BY
                        CASE WHEN h.SubsystemCode IS NULL THEN 1 ELSE 0 END,
                        h.SubsystemCode,
                        h.ItemCode,
                        h.AreaCode,
                        h.UnitCode,
                        h.SystemCode
                )
            FROM dbo.wap_PunchPaged AS p
            INNER JOIN #BatchItems AS bi
                ON bi.WorkItemId = p.Id
            INNER JOIN dbo.wap_ElementHierarchyPunchView AS h
                ON h.ProjectId = p.ProjectId
               AND h.PunchId = p.Id
            LEFT JOIN dbo.DIM_MASTER_COMPANIES_LH AS mc
                ON mc.ID_COMPANY = TRY_CONVERT(int, p.SubcontractorId)
            WHERE p.ProjectId = @ProjectId
              AND p.TemplateID = @TemplateId
        ),
        LatestComment AS
        (
            SELECT
                c.PunchId,
                c.CreatedOn,
                c.CommentText,
                c.CreatedByEmail,
                rn = ROW_NUMBER() OVER
                (
                    PARTITION BY c.PunchId
                    ORDER BY c.CreatedOn DESC
                ),
                CommentCount = COUNT(*) OVER (PARTITION BY c.PunchId)
            FROM warroom.PunchComment AS c
            INNER JOIN #BatchItems AS bi
                ON bi.WorkItemId = c.PunchId
            WHERE c.ProjectId = @ProjectId
              AND c.IsDeleted = 0
        )
        SELECT
            pb.ProjectId,
            pb.PunchId,
            pb.TemplateId,
            pb.AreaCode,
            pb.UnitCode,
            pb.SystemCode,
            pb.SubsystemCode,
            pb.ElementCode,
            pb.PunchDiscipline AS ElementDiscipline,
            pb.Code,
            pb.[Description],
            pb.PunchCoordinator,
            pb.Originator,
            pb.CategoryCode,
            pb.Category,
            pb.PunchDiscipline AS Discipline,
            pb.StatusCode,
            pb.PunchStatus AS [Status],
            pb.InspectionCode,
            pb.InspectionName,
            pb.InspectionType,
            pb.EntryType,
            pb.EntryTypeColor,
            pb.Topic,
            pb.RejectCount,
            pb.ItemsRaw,
            pb.SubcontractorId,
            pb.SubcontractorCode,
            pb.SubcontractorName,
            pb.SubcontractorShortName,
            pb.DepartmentAction,
            LastCommentOn = lc.CreatedOn,
            LastCommentText = lc.CommentText,
            LastCommentByEmail = lc.CreatedByEmail,
            CommentCount = COALESCE(lc.CommentCount, 0),
            StandardValuesJson = CONVERT(nvarchar(max), NULL)
        INTO #CurrentBase
        FROM PunchBase AS pb
        LEFT JOIN LatestComment AS lc
            ON lc.PunchId = pb.PunchId
           AND lc.rn = 1
        WHERE pb.rn = 1;

        UPDATE cb
        SET StandardValuesJson = snapshot.StandardValuesJson
        FROM #CurrentBase AS cb
        CROSS APPLY
        (
            SELECT
                cb.ProjectId,
                cb.PunchId,
                cb.TemplateId,
                cb.AreaCode,
                cb.UnitCode,
                cb.SystemCode,
                cb.SubsystemCode,
                cb.ElementCode,
                cb.ElementDiscipline,
                cb.Code,
                cb.[Description],
                cb.PunchCoordinator,
                cb.Originator,
                cb.CategoryCode,
                cb.Category,
                cb.Discipline,
                cb.StatusCode,
                cb.[Status],
                cb.InspectionCode,
                cb.InspectionName,
                cb.InspectionType,
                cb.EntryType,
                cb.EntryTypeColor,
                cb.Topic,
                cb.RejectCount,
                cb.ItemsRaw,
                cb.SubcontractorId,
                cb.SubcontractorCode,
                cb.SubcontractorName,
                cb.SubcontractorShortName,
                cb.DepartmentAction,
                cb.LastCommentOn,
                cb.LastCommentText,
                cb.LastCommentByEmail,
                cb.CommentCount
            FOR JSON PATH, WITHOUT_ARRAY_WRAPPER, INCLUDE_NULL_VALUES
        ) AS snapshot(StandardValuesJson);

        DROP TABLE IF EXISTS #CustomFlat;
        CREATE TABLE #CustomFlat
        (
            PunchId bigint NOT NULL,
            ColumnName nvarchar(128) NOT NULL,
            FieldValue nvarchar(max) NULL
        );

        INSERT INTO #CustomFlat (PunchId, ColumnName, FieldValue)
        SELECT
            cb.PunchId,
            ColumnName = CONCAT
            (
                N'CF__',
                REPLACE(REPLACE(REPLACE(REPLACE(d.FieldKey, ' ', '_'), '-', '_'), '.', '_'), ']', '_')
            ),
            FieldValue =
                CASE d.FieldType
                    WHEN 'Text' THEN v.ValueText
                    WHEN 'Number' THEN CONVERT(nvarchar(100), v.ValueNumber)
                    WHEN 'Date' THEN CONVERT(nvarchar(30), v.ValueDate, 126)
                    WHEN 'YesNo' THEN CASE WHEN v.ValueBool = 1 THEN 'true' WHEN v.ValueBool = 0 THEN 'false' ELSE NULL END
                    WHEN 'Choice' THEN v.ValueText
                    WHEN 'MultiChoice' THEN v.ValueJson
                    WHEN 'Json' THEN v.ValueJson
                    ELSE v.ValueText
                END
        FROM #CurrentBase AS cb
        INNER JOIN warroom.CustomFieldDef AS d
            ON d.ProjectId = @ProjectId
           AND d.EntityType = 'PUNCH'
           AND d.IsActive = 1
           AND d.IsExportable = 1
        LEFT JOIN warroom.CustomFieldValue AS v
            ON v.ProjectId = @ProjectId
           AND v.EntityType = 'PUNCH'
           AND v.RecordId = cb.PunchId
           AND v.FieldKey = d.FieldKey;

        DECLARE @HasCustomFields bit = CONVERT(bit, CASE WHEN EXISTS (SELECT 1 FROM #CustomFlat) THEN 1 ELSE 0 END);

        DROP TABLE IF EXISTS #CurrentCanonical;
        CREATE TABLE #CurrentCanonical
        (
            WorkItemId bigint NOT NULL PRIMARY KEY,
            CurrentValuesJson nvarchar(max) NOT NULL,
            CurrentRowChecksum char(64) NOT NULL
        );

        IF @HasCustomFields = 1
        BEGIN
            INSERT INTO #CurrentCanonical (WorkItemId, CurrentValuesJson, CurrentRowChecksum)
            SELECT
                cb.PunchId,
                canonical.CurrentValuesJson,
                CONVERT(char(64), CONVERT(nvarchar(64), HASHBYTES('SHA2_256', CONVERT(varbinary(max), canonical.CurrentValuesJson)), 2))
            FROM #CurrentBase AS cb
            CROSS APPLY
            (
                SELECT CustomHashSource =
                (
                    SELECT cf.ColumnName, cf.FieldValue
                    FROM #CustomFlat AS cf
                    WHERE cf.PunchId = cb.PunchId
                    ORDER BY cf.ColumnName
                    FOR JSON PATH, INCLUDE_NULL_VALUES
                )
            ) AS hs
            CROSS APPLY
            (
                SELECT CurrentValuesJson = JSON_MODIFY(cb.StandardValuesJson, '$.CustomValuesCanonical', ISNULL(hs.CustomHashSource, ''))
            ) AS canonical;
        END
        ELSE
        BEGIN
            INSERT INTO #CurrentCanonical (WorkItemId, CurrentValuesJson, CurrentRowChecksum)
            SELECT
                cb.PunchId,
                cb.StandardValuesJson,
                CONVERT(char(64), CONVERT(nvarchar(64), HASHBYTES('SHA2_256', CONVERT(varbinary(max), cb.StandardValuesJson)), 2))
            FROM #CurrentBase AS cb;
        END;

        UPDATE ibr
        SET
            CurrentValuesJson = COALESCE
            (
                cc.CurrentValuesJson,
                (SELECT WorkItemId = ibr.WorkItemId, CurrentRecordMissing = CAST(1 AS bit) FOR JSON PATH, WITHOUT_ARRAY_WRAPPER)
            ),
            ValidationStatus = CASE
                WHEN ibr.ValidationStatus = 'ERROR' THEN 'ERROR'
                WHEN bi.HasIncomingChange = 0 THEN 'UNCHANGED'
                WHEN cc.WorkItemId IS NULL THEN 'CONFLICT'
                WHEN UPPER(CONVERT(varchar(64), cc.CurrentRowChecksum)) <> UPPER(CONVERT(varchar(64), ebr.RowChecksum)) THEN 'CONFLICT'
                ELSE 'READY'
            END,
            ValidationWarningsJson = CASE
                WHEN ibr.ValidationStatus = 'ERROR' THEN ibr.ValidationWarningsJson
                WHEN bi.HasIncomingChange = 0 THEN N'[]'
                WHEN cc.WorkItemId IS NULL THEN
                    (SELECT ConflictCode = N'CURRENT_RECORD_MISSING', [Message] = N'The Punch can no longer be reconstructed from the current governed data sources.' FOR JSON PATH)
                WHEN UPPER(CONVERT(varchar(64), cc.CurrentRowChecksum)) <> UPPER(CONVERT(varchar(64), ebr.RowChecksum)) THEN
                    (SELECT ConflictCode = N'CURRENT_STATE_CHANGED', [Message] = N'The Punch changed in PULSE after this workbook was exported. Re-export before applying the comment.' FOR JSON PATH)
                ELSE N'[]'
            END
        FROM warroom.ImportBatchRow AS ibr
        INNER JOIN #BatchItems AS bi ON bi.WorkItemId = ibr.WorkItemId
        LEFT JOIN #CurrentCanonical AS cc ON cc.WorkItemId = ibr.WorkItemId
        LEFT JOIN warroom.ExportBatchRow AS ebr
            ON ebr.ExportBatchId = @ExportBatchId
           AND ebr.WorkItemId = ibr.WorkItemId
        WHERE ibr.ImportBatchId = @ImportBatchId;

        DECLARE @TotalRows int;
        DECLARE @ChangedRows int;
        DECLARE @UnchangedRows int;
        DECLARE @ValidRows int;
        DECLARE @WarningRows int;
        DECLARE @ErrorRows int;
        DECLARE @ConflictRows int;
        DECLARE @FinalStatus varchar(20);

        SELECT
            @TotalRows = COUNT(*),
            @ChangedRows = SUM(CASE WHEN ValidationStatus IN ('READY','CONFLICT') THEN 1 ELSE 0 END),
            @UnchangedRows = SUM(CASE WHEN ValidationStatus = 'UNCHANGED' THEN 1 ELSE 0 END),
            @ValidRows = SUM(CASE WHEN ValidationStatus IN ('READY','UNCHANGED','WARNING') THEN 1 ELSE 0 END),
            @WarningRows = SUM(CASE WHEN ValidationStatus = 'WARNING' THEN 1 ELSE 0 END),
            @ErrorRows = SUM(CASE WHEN ValidationStatus = 'ERROR' THEN 1 ELSE 0 END),
            @ConflictRows = SUM(CASE WHEN ValidationStatus = 'CONFLICT' THEN 1 ELSE 0 END)
        FROM warroom.ImportBatchRow
        WHERE ImportBatchId = @ImportBatchId;

        SET @TotalRows = COALESCE(@TotalRows, 0);
        SET @ChangedRows = COALESCE(@ChangedRows, 0);
        SET @UnchangedRows = COALESCE(@UnchangedRows, 0);
        SET @ValidRows = COALESCE(@ValidRows, 0);
        SET @WarningRows = COALESCE(@WarningRows, 0);
        SET @ErrorRows = COALESCE(@ErrorRows, 0);
        SET @ConflictRows = COALESCE(@ConflictRows, 0);

        SET @FinalStatus = CASE WHEN @ErrorRows > 0 OR @ConflictRows > 0 THEN 'BLOCKED' ELSE 'READY' END;

        UPDATE warroom.ImportBatch
        SET
            ValidatedAtUtc = CONVERT(datetime2(3), SYSUTCDATETIME()),
            Status = @FinalStatus,
            TotalRows = @TotalRows,
            ChangedRows = @ChangedRows,
            UnchangedRows = @UnchangedRows,
            ValidRows = @ValidRows,
            WarningRows = @WarningRows,
            ErrorRows = @ErrorRows,
            ConflictRows = @ConflictRows,
            ErrorMessage = CASE
                WHEN @ConflictRows > 0 THEN N'One or more changed rows conflict with the current PULSE state.'
                WHEN @ErrorRows = 0 THEN NULL
                ELSE ErrorMessage
            END
        WHERE ImportBatchId = @ImportBatchId;

        SELECT
            success = CAST(1 AS bit),
            importBatchId = CONVERT(nvarchar(36), @ImportBatchId),
            status = @FinalStatus,
            totalRows = @TotalRows,
            changedRows = @ChangedRows,
            unchangedRows = @UnchangedRows,
            validRows = @ValidRows,
            warningRows = @WarningRows,
            errorRows = @ErrorRows,
            conflictRows = @ConflictRows,
            canCommit = CONVERT(bit, CASE WHEN @FinalStatus = 'READY' AND @ChangedRows > 0 AND @ErrorRows = 0 AND @ConflictRows = 0 THEN 1 ELSE 0 END),
            [message] = CASE
                WHEN @ConflictRows > 0 THEN N'The workbook contains conflicts with the current PULSE state.'
                WHEN @ErrorRows > 0 THEN N'The workbook contains blocking validation errors.'
                WHEN @ChangedRows = 0 THEN N'The workbook is valid but contains no new comments to apply.'
                ELSE N'The workbook is current and ready for preview.'
            END;
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH;
END;
GO

/* Deployment verification only. */
DECLARE @Definition nvarchar(max) = OBJECT_DEFINITION(OBJECT_ID(N'warroom.usp_RevalidatePunchCommentImportConflicts', N'P'));

SELECT
    ProcedureName = N'warroom.usp_RevalidatePunchCommentImportConflicts',
    ExistsAsProcedure = CONVERT(bit, CASE WHEN OBJECT_ID(N'warroom.usp_RevalidatePunchCommentImportConflicts', N'P') IS NOT NULL THEN 1 ELSE 0 END),
    WritesPunchComment = CONVERT(bit, CASE
        WHEN @Definition LIKE '%INSERT INTO [warroom].[PunchComment]%'
          OR @Definition LIKE '%INSERT INTO warroom.PunchComment%'
          OR @Definition LIKE '%UPDATE [warroom].[PunchComment]%'
          OR @Definition LIKE '%UPDATE warroom.PunchComment%'
          OR @Definition LIKE '%DELETE FROM [warroom].[PunchComment]%'
          OR @Definition LIKE '%DELETE FROM warroom.PunchComment%'
        THEN 1 ELSE 0 END);
GO
