/****** Object:  StoredProcedure [warroom].[usp_ExportProjectPunchesExtended_Pivoted]    Script Date: 7/28/2026 4:12:48 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER PROCEDURE [warroom].[usp_ExportProjectPunchesExtended_Pivoted]
(
    @ProjectId           BIGINT,
    @SubsystemCode       NVARCHAR(255) = NULL,
    @TemplateId          BIGINT = NULL,
    @CategoryCode        NVARCHAR(50) = NULL,
    @StatusCode          NVARCHAR(50) = NULL,
    @PunchDiscipline     NVARCHAR(100) = NULL,
    @Subcontractor       NVARCHAR(255) = NULL,
    @CustomFiltersJson   NVARCHAR(MAX) = NULL,
    @PunchExportLogId    BIGINT = NULL,
    @MaxRows             INT = 50000
)
AS
BEGIN
    SET NOCOUNT ON;

    IF @TemplateId = 0 SET @TemplateId = NULL;

    SET @SubsystemCode = NULLIF(LTRIM(RTRIM(@SubsystemCode)), '');
    SET @CategoryCode = NULLIF(LTRIM(RTRIM(@CategoryCode)), '');
    SET @StatusCode = NULLIF(LTRIM(RTRIM(@StatusCode)), '');
    SET @PunchDiscipline = NULLIF(LTRIM(RTRIM(@PunchDiscipline)), '');
    SET @Subcontractor = NULLIF(LTRIM(RTRIM(@Subcontractor)), '');
    SET @CustomFiltersJson = NULLIF(LTRIM(RTRIM(@CustomFiltersJson)), '');

    IF @CustomFiltersJson IS NULL OR @CustomFiltersJson = '[]'
        SET @CustomFiltersJson = NULL;

    ---------------------------------------------------------------------
    -- 1) Base punch dataset
    ---------------------------------------------------------------------
    ;WITH PunchBase AS
    (
        SELECT
            h.AreaCode,
            h.UnitCode,
            h.SystemCode,
            SubsystemCode = COALESCE(NULLIF(LTRIM(RTRIM(h.SubsystemCode)), ''), 'NO SUBSYSTEM'),
            h.ItemCode AS ElementCode,
            h.GroupCode,
            h.ModuleCode,

            p.ProjectId,
            CAST(p.Id AS INT) AS PunchId,
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

            SubcontractorCode = CAST(mc.ID_COMPANY AS NVARCHAR(50)),
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
        FROM dbo.wap_PunchPaged p
        INNER JOIN dbo.wap_ElementHierarchyPunchView h
            ON h.ProjectId = p.ProjectId
           AND h.PunchId = p.Id
        LEFT JOIN dbo.DIM_MASTER_COMPANIES_LH mc
            ON mc.ID_COMPANY = TRY_CONVERT(INT, p.SubcontractorId)
        WHERE
            p.ProjectId = @ProjectId
            AND NULLIF(LTRIM(RTRIM(p.StatusCode)), '') IS NOT NULL
            AND UPPER(LTRIM(RTRIM(p.StatusCode))) NOT IN ('HOLD', 'VOID')

            AND (
                @SubsystemCode IS NULL
                OR COALESCE(NULLIF(LTRIM(RTRIM(h.SubsystemCode)), ''), 'NO SUBSYSTEM') = @SubsystemCode
            )

            AND (@TemplateId IS NULL OR p.TemplateID = @TemplateId)
            AND (@CategoryCode IS NULL OR p.CategoryCode = @CategoryCode)
            AND (@StatusCode IS NULL OR UPPER(LTRIM(RTRIM(p.StatusCode))) = UPPER(@StatusCode))
            AND (@PunchDiscipline IS NULL OR p.Discipline = @PunchDiscipline)

            AND (
                @Subcontractor IS NULL
                OR CAST(p.SubcontractorId AS NVARCHAR(255)) = @Subcontractor
                OR CAST(mc.ID_COMPANY AS NVARCHAR(255)) = @Subcontractor
                OR mc.DS_COMPANY = @Subcontractor
                OR mc.DS_SHORT_COMPANY = @Subcontractor
            )
    )
    SELECT
        AreaCode,
        UnitCode,
        SystemCode,
        SubsystemCode,
        ElementCode,
        GroupCode,
        ModuleCode,

        ProjectId,
        PunchId,
        TemplateId,
        Code,
        [Description],
        PunchCoordinator,
        Originator,
        CategoryCode,
        Category,
        PunchDiscipline,
        StatusCode,
        PunchStatus,
        InspectionCode,
        InspectionName,
        InspectionType,
        EntryType,
        EntryTypeColor,
        Topic,
        RejectCount,
        ItemsRaw,
        SubcontractorId,
        SubcontractorCode,
        SubcontractorName,
        SubcontractorShortName,
        DepartmentAction
    INTO #BaseKey
    FROM PunchBase
    WHERE rn = 1
    OPTION (RECOMPILE);

    CREATE UNIQUE CLUSTERED INDEX CX_BaseKey
    ON #BaseKey(PunchId);

    CREATE NONCLUSTERED INDEX IX_BaseKey_Order
    ON #BaseKey(SubsystemCode, PunchDiscipline, ElementCode, PunchId);

    CREATE NONCLUSTERED INDEX IX_BaseKey_Filters
    ON #BaseKey
    (
        TemplateId,
        CategoryCode,
        StatusCode,
        PunchDiscipline,
        SubsystemCode,
        SubcontractorId
    );

    ---------------------------------------------------------------------
    -- 2) Dynamic custom filters
    ---------------------------------------------------------------------
    IF @CustomFiltersJson IS NOT NULL
    BEGIN
        CREATE TABLE #CustomFilters
        (
            FieldKey NVARCHAR(100) NOT NULL,
            FieldType NVARCHAR(30) NULL,
            FilterMode NVARCHAR(30) NULL,
            ValueText NVARCHAR(4000) NULL,
            ValueJson NVARCHAR(MAX) NULL,
            ValueNumberFrom DECIMAL(18,4) NULL,
            ValueNumberTo DECIMAL(18,4) NULL,
            ValueDateFrom DATE NULL,
            ValueDateTo DATE NULL,
            ValueBool BIT NULL
        );

        INSERT INTO #CustomFilters
        (
            FieldKey,
            FieldType,
            FilterMode,
            ValueText,
            ValueJson,
            ValueNumberFrom,
            ValueNumberTo,
            ValueDateFrom,
            ValueDateTo,
            ValueBool
        )
        SELECT
            FieldKey,
            FieldType,
            FilterMode,
            NULLIF(LTRIM(RTRIM(ValueText)), ''),
            NULLIF(LTRIM(RTRIM(ValueJson)), ''),
            NULLIF(ValueNumberFrom, 0),
            NULLIF(ValueNumberTo, 0),
            NULLIF(TRY_CONVERT(DATE, ValueDateFrom), '19000101'),
            NULLIF(TRY_CONVERT(DATE, ValueDateTo), '19000101'),
            ValueBool
        FROM OPENJSON(@CustomFiltersJson)
        WITH
        (
            FieldKey NVARCHAR(100) '$.FieldKey',
            FieldType NVARCHAR(30) '$.FieldType',
            FilterMode NVARCHAR(30) '$.FilterMode',
            ValueText NVARCHAR(4000) '$.ValueText',
            ValueJson NVARCHAR(MAX) '$.ValueJson',
            ValueNumberFrom DECIMAL(18,4) '$.ValueNumberFrom',
            ValueNumberTo DECIMAL(18,4) '$.ValueNumberTo',
            ValueDateFrom NVARCHAR(50) '$.ValueDateFrom',
            ValueDateTo NVARCHAR(50) '$.ValueDateTo',
            ValueBool BIT '$.ValueBool'
        )
        WHERE NULLIF(LTRIM(RTRIM(FieldKey)), '') IS NOT NULL;

        DELETE cf
        FROM #CustomFilters cf
        WHERE
            cf.ValueText IS NULL
            AND (cf.ValueJson IS NULL OR cf.ValueJson = '[]')
            AND cf.ValueNumberFrom IS NULL
            AND cf.ValueNumberTo IS NULL
            AND cf.ValueDateFrom IS NULL
            AND cf.ValueDateTo IS NULL
            AND ISNULL(cf.ValueBool, 0) = 0;

        IF EXISTS (SELECT 1 FROM #CustomFilters)
        BEGIN
            DELETE bk
            FROM #BaseKey bk
            WHERE EXISTS
            (
                SELECT 1
                FROM #CustomFilters cf
                LEFT JOIN warroom.CustomFieldValue v
                    ON v.ProjectId = @ProjectId
                   AND v.EntityType = 'PUNCH'
                   AND v.RecordId = bk.PunchId
                   AND v.FieldKey = cf.FieldKey
                WHERE
                    (
                        cf.ValueText IS NOT NULL
                        AND ISNULL(v.ValueText, '') NOT LIKE '%' + cf.ValueText + '%'
                    )
                    OR
                    (
                        cf.ValueNumberFrom IS NOT NULL
                        AND (v.ValueNumber IS NULL OR v.ValueNumber < cf.ValueNumberFrom)
                    )
                    OR
                    (
                        cf.ValueNumberTo IS NOT NULL
                        AND (v.ValueNumber IS NULL OR v.ValueNumber > cf.ValueNumberTo)
                    )
                    OR
                    (
                        cf.ValueDateFrom IS NOT NULL
                        AND (v.ValueDate IS NULL OR v.ValueDate < cf.ValueDateFrom)
                    )
                    OR
                    (
                        cf.ValueDateTo IS NOT NULL
                        AND (v.ValueDate IS NULL OR v.ValueDate > cf.ValueDateTo)
                    )
                    OR
                    (
                        cf.ValueBool = 1
                        AND ISNULL(v.ValueBool, 0) <> 1
                    )
                    OR
                    (
                        cf.ValueJson IS NOT NULL
                        AND cf.ValueJson <> '[]'
                        AND LOWER(LTRIM(RTRIM(cf.FieldType))) = 'multichoice'
                        AND NOT EXISTS
                        (
                            SELECT 1
                            FROM OPENJSON(
                                CASE
                                    WHEN ISJSON(v.ValueJson) = 1 THEN v.ValueJson
                                    ELSE N'[]'
                                END
                            ) stored
                            INNER JOIN OPENJSON(
                                CASE
                                    WHEN ISJSON(cf.ValueJson) = 1 THEN cf.ValueJson
                                    ELSE N'[]'
                                END
                            ) selected
                                ON LTRIM(RTRIM(CONVERT(NVARCHAR(4000), stored.[value])))
                                 = LTRIM(RTRIM(CONVERT(NVARCHAR(4000), selected.[value])))
                        )
                    )
                    OR
                    (
                        cf.ValueJson IS NOT NULL
                        AND cf.ValueJson <> '[]'
                        AND LOWER(LTRIM(RTRIM(cf.FieldType))) <> 'multichoice'
                        AND ISNULL(v.ValueJson, '') NOT LIKE '%' + cf.ValueJson + '%'
                    )
            );
        END
    END;

    ---------------------------------------------------------------------
    -- 3) Safety limit
    ---------------------------------------------------------------------
    DECLARE @TotalRows INT = (SELECT COUNT(1) FROM #BaseKey);

    IF @MaxRows IS NOT NULL
       AND @MaxRows > 0
       AND @TotalRows > @MaxRows
    BEGIN
        THROW 50010, 'Export exceeds maximum allowed rows. Please apply more filters.', 1;
    END;

    ---------------------------------------------------------------------
    -- 4) Comments summary
    ---------------------------------------------------------------------
    ;WITH C AS
    (
        SELECT
            c.PunchId,
            c.CreatedOn,
            c.CommentText,
            c.CreatedByEmail,
            ROW_NUMBER() OVER
            (
                PARTITION BY c.PunchId
                ORDER BY c.CreatedOn DESC
            ) AS rn
        FROM warroom.PunchComment c
        INNER JOIN #BaseKey bk
            ON bk.PunchId = c.PunchId
        WHERE c.ProjectId = @ProjectId
          AND c.IsDeleted = 0
    ),
    Agg AS
    (
        SELECT PunchId, COUNT(1) AS CommentCount
        FROM C
        GROUP BY PunchId
    )
    SELECT
        bk.PunchId,
        MAX(CASE WHEN c.rn = 1 THEN c.CreatedOn END) AS LastCommentOn,
        MAX(CASE WHEN c.rn = 1 THEN c.CommentText END) AS LastCommentText,
        MAX(CASE WHEN c.rn = 1 THEN c.CreatedByEmail END) AS LastCommentByEmail,
        COALESCE(a.CommentCount, 0) AS CommentCount
    INTO #Comments
    FROM #BaseKey bk
    LEFT JOIN C c
        ON c.PunchId = bk.PunchId
    LEFT JOIN Agg a
        ON a.PunchId = bk.PunchId
    GROUP BY bk.PunchId, a.CommentCount;

    CREATE UNIQUE CLUSTERED INDEX IX_Comments
    ON #Comments(PunchId);

    ---------------------------------------------------------------------
    -- 5) Flat base export table
    ---------------------------------------------------------------------
    SELECT
        bk.ProjectId,
        bk.PunchId,
        @PunchExportLogId AS PunchExportLogId,

        bk.AreaCode,
        bk.UnitCode,
        bk.SystemCode,
        bk.SubsystemCode,
        bk.ElementCode,
        bk.PunchDiscipline AS ElementDiscipline,
        CAST(NULL AS NVARCHAR(100)) AS TypeCode,

        bk.TemplateId,
        bk.Code,
        bk.[Description],
        bk.PunchCoordinator,
        bk.Originator,
        bk.CategoryCode,
        bk.Category,
        bk.PunchDiscipline AS Discipline,
        bk.StatusCode,
        bk.PunchStatus AS [Status],
        bk.InspectionCode,
        bk.InspectionName,
        bk.InspectionType,
        bk.EntryType,
        bk.EntryTypeColor,
        bk.Topic,
        bk.RejectCount,
        bk.ElementCode AS ElementCodeMapped,
        bk.ItemsRaw,
        bk.SubcontractorId,
        bk.SubcontractorCode,
        bk.SubcontractorName,
        bk.SubcontractorShortName,
        bk.DepartmentAction,

        cp.LastCommentOn,
        cp.LastCommentText,
        cp.LastCommentByEmail,
        cp.CommentCount,

        CAST(NULL AS NVARCHAR(MAX)) AS NewComment
    INTO #ExportBase
    FROM #BaseKey bk
    LEFT JOIN #Comments cp
        ON cp.PunchId = bk.PunchId;

    CREATE UNIQUE CLUSTERED INDEX CX_ExportBase
    ON #ExportBase(PunchId);

    ---------------------------------------------------------------------
    -- 6) Custom values normalized
    ---------------------------------------------------------------------
    CREATE TABLE #CustomFlat
    (
        PunchId INT NOT NULL,
        FieldKey VARCHAR(64) NOT NULL,
        ColumnName NVARCHAR(128) NOT NULL,
        FieldValue NVARCHAR(MAX) NULL
    );

    INSERT INTO #CustomFlat
    (
        PunchId,
        FieldKey,
        ColumnName,
        FieldValue
    )
    SELECT
        eb.PunchId,
        d.FieldKey,
        ColumnName =
            CONCAT(
                N'CF__',
                REPLACE(
                    REPLACE(
                        REPLACE(
                            REPLACE(d.FieldKey, ' ', '_'),
                        '-', '_'),
                    '.', '_'),
                ']', '_')
            ),
        FieldValue =
            CASE d.FieldType
                WHEN 'Text' THEN v.ValueText
                WHEN 'Number' THEN CONVERT(NVARCHAR(100), v.ValueNumber)
                WHEN 'Date' THEN CONVERT(NVARCHAR(30), v.ValueDate, 126)
                WHEN 'YesNo' THEN
                    CASE
                        WHEN v.ValueBool = 1 THEN 'true'
                        WHEN v.ValueBool = 0 THEN 'false'
                        ELSE NULL
                    END
                WHEN 'Choice' THEN v.ValueText
                WHEN 'MultiChoice' THEN v.ValueJson
                WHEN 'Json' THEN v.ValueJson
                ELSE v.ValueText
            END
    FROM #ExportBase eb
    INNER JOIN warroom.CustomFieldDef d
        ON d.ProjectId = @ProjectId
       AND d.EntityType = 'PUNCH'
       AND d.IsActive = 1
       AND d.IsExportable = 1
    LEFT JOIN warroom.CustomFieldValue v
        ON v.ProjectId = @ProjectId
       AND v.EntityType = 'PUNCH'
       AND v.RecordId = eb.PunchId
       AND v.FieldKey = d.FieldKey;

    CREATE NONCLUSTERED INDEX IX_CustomFlat_Pivot
    ON #CustomFlat(PunchId, ColumnName);

    ---------------------------------------------------------------------
    -- 7) Dynamic pivot columns
    ---------------------------------------------------------------------
    DECLARE @PivotColumns NVARCHAR(MAX);
    DECLARE @SelectPivotColumns NVARCHAR(MAX);
    DECLARE @Sql NVARCHAR(MAX);

    SELECT
        @PivotColumns = STRING_AGG(QUOTENAME(ColumnName), ',')
    FROM
    (
        SELECT DISTINCT ColumnName
        FROM #CustomFlat
    ) x;

    SELECT
        @SelectPivotColumns = STRING_AGG('p.' + QUOTENAME(ColumnName), ',' + CHAR(13) + CHAR(10) + '        ')
    FROM
    (
        SELECT DISTINCT ColumnName
        FROM #CustomFlat
    ) x;

    ---------------------------------------------------------------------
    -- 8) Return final flat dataset
    ---------------------------------------------------------------------
    IF @PivotColumns IS NULL OR LTRIM(RTRIM(@PivotColumns)) = ''
    BEGIN
        SELECT
            eb.ProjectId,
            eb.PunchId,
            eb.PunchExportLogId,

            CONVERT(
                NVARCHAR(64),
                HASHBYTES(
                    'SHA2_256',
                    CONCAT(
                        eb.ProjectId,
                        '|',
                        eb.PunchId,
                        '|'
                    )
                ),
                2
            ) AS RowHash,

            eb.AreaCode,
            eb.UnitCode,
            eb.SystemCode,
            eb.SubsystemCode,
            eb.ElementCode,
            eb.ElementDiscipline,
            eb.TypeCode,

            eb.TemplateId,
            eb.Code,
            eb.[Description],
            eb.PunchCoordinator,
            eb.Originator,
            eb.CategoryCode,
            eb.Category,
            eb.Discipline,
            eb.StatusCode,
            eb.[Status],
            eb.InspectionCode,
            eb.InspectionName,
            eb.InspectionType,
            eb.EntryType,
            eb.EntryTypeColor,
            eb.Topic,
            eb.RejectCount,
            eb.ElementCodeMapped,
            eb.ItemsRaw,
            eb.SubcontractorId,
            eb.SubcontractorCode,
            eb.SubcontractorName,
            eb.SubcontractorShortName,
            eb.DepartmentAction,

            eb.LastCommentOn,
            eb.LastCommentText,
            eb.LastCommentByEmail,
            eb.CommentCount,

            eb.NewComment,

            @TotalRows AS TotalRows
        FROM #ExportBase eb
        ORDER BY
            CASE WHEN eb.SubsystemCode = 'NO SUBSYSTEM' THEN 1 ELSE 0 END,
            eb.SubsystemCode,
            eb.Discipline,
            eb.ElementCode,
            eb.PunchId;

        RETURN;
    END;

    SET @Sql = N'
        ;WITH Pivoted AS
        (
            SELECT
                PunchId,
                ' + @PivotColumns + N'
            FROM
            (
                SELECT
                    PunchId,
                    ColumnName,
                    FieldValue
                FROM #CustomFlat
            ) src
            PIVOT
            (
                MAX(FieldValue)
                FOR ColumnName IN (' + @PivotColumns + N')
            ) pvt
        ),
        HashSource AS
        (
            SELECT
                PunchId,
                STRING_AGG(CONCAT(ColumnName, ''='', ISNULL(FieldValue, '''')), ''|'')
                    WITHIN GROUP (ORDER BY ColumnName) AS CustomHashSource
            FROM #CustomFlat
            GROUP BY PunchId
        )
        SELECT
            eb.ProjectId,
            eb.PunchId,
            eb.PunchExportLogId,

            CONVERT(
                NVARCHAR(64),
                HASHBYTES(
                    ''SHA2_256'',
                    CONCAT(
                        eb.ProjectId,
                        ''|'',
                        eb.PunchId,
                        ''|'',
                        ISNULL(hs.CustomHashSource, '''')
                    )
                ),
                2
            ) AS RowHash,

            eb.AreaCode,
            eb.UnitCode,
            eb.SystemCode,
            eb.SubsystemCode,
            eb.ElementCode,
            eb.ElementDiscipline,
            eb.TypeCode,

            eb.TemplateId,
            eb.Code,
            eb.[Description],
            eb.PunchCoordinator,
            eb.Originator,
            eb.CategoryCode,
            eb.Category,
            eb.Discipline,
            eb.StatusCode,
            eb.[Status],
            eb.InspectionCode,
            eb.InspectionName,
            eb.InspectionType,
            eb.EntryType,
            eb.EntryTypeColor,
            eb.Topic,
            eb.RejectCount,
            eb.ElementCodeMapped,
            eb.ItemsRaw,
            eb.SubcontractorId,
            eb.SubcontractorCode,
            eb.SubcontractorName,
            eb.SubcontractorShortName,
            eb.DepartmentAction,

            eb.LastCommentOn,
            eb.LastCommentText,
            eb.LastCommentByEmail,
            eb.CommentCount,

            ' + @SelectPivotColumns + N',

            eb.NewComment,

            ' + CAST(@TotalRows AS NVARCHAR(20)) + N' AS TotalRows
        FROM #ExportBase eb
        LEFT JOIN Pivoted p
            ON p.PunchId = eb.PunchId
        LEFT JOIN HashSource hs
            ON hs.PunchId = eb.PunchId
        ORDER BY
            CASE WHEN eb.SubsystemCode = ''NO SUBSYSTEM'' THEN 1 ELSE 0 END,
            eb.SubsystemCode,
            eb.Discipline,
            eb.ElementCode,
            eb.PunchId;
    ';

    EXEC sys.sp_executesql @Sql;
END;


