/*
    PULSE — PR-EXP-C03B1
    Validación backend del scope exacto de Punch Review.

    Objetivo:
    - recibir el payload WorkItemIdsJson construido por scr_PunchReview;
    - comprobar formato, duplicados, pertenencia a proyecto/template y elegibilidad;
    - garantizar que requestedCount = resolvedCount;
    - NO modificar datos productivos;
    - NO generar todavía el Excel.

    Este procedimiento es deliberadamente independiente del export productivo actual.
    Permite validar el contrato de scope antes de modificar
    warroom.usp_ExportProjectPunchesExtended_Pivoted o Power Automate.
*/

SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO

CREATE OR ALTER PROCEDURE [warroom].[usp_ValidatePunchReviewExportScope]
(
    @ProjectId        BIGINT,
    @TemplateId       BIGINT,
    @WorkItemIdsJson  NVARCHAR(MAX)
)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    ---------------------------------------------------------------------
    -- 1. Parameter validation
    ---------------------------------------------------------------------
    IF @ProjectId IS NULL OR @ProjectId <= 0
        THROW 52000, 'ProjectId must be a positive integer.', 1;

    IF @TemplateId IS NULL OR @TemplateId <= 0
        THROW 52001, 'TemplateId must be a positive integer for REVIEW_QUEUE export.', 1;

    SET @WorkItemIdsJson = NULLIF(LTRIM(RTRIM(@WorkItemIdsJson)), N'');

    IF @WorkItemIdsJson IS NULL
        THROW 52002, 'WorkItemIdsJson is required for REVIEW_QUEUE export.', 1;

    IF ISJSON(@WorkItemIdsJson) <> 1
       OR LEFT(LTRIM(@WorkItemIdsJson), 1) <> N'['
        THROW 52003, 'WorkItemIdsJson must be a valid JSON array.', 1;

    ---------------------------------------------------------------------
    -- 2. Permissive staging so functional errors can be reported cleanly
    ---------------------------------------------------------------------
    CREATE TABLE #RequestedStage
    (
        SourceOrdinal  INT          NOT NULL,
        WorkItemId     BIGINT       NULL
    );

    INSERT INTO #RequestedStage
    (
        SourceOrdinal,
        WorkItemId
    )
    SELECT
        SourceOrdinal = TRY_CONVERT(INT, src.[key]),
        WorkItemId = TRY_CONVERT
        (
            BIGINT,
            JSON_VALUE(src.[value], '$.WorkItemId')
        )
    FROM OPENJSON(@WorkItemIdsJson) AS src;

    IF NOT EXISTS (SELECT 1 FROM #RequestedStage)
        THROW 52004, 'WorkItemIdsJson cannot be an empty array.', 1;

    IF EXISTS
    (
        SELECT 1
        FROM #RequestedStage
        WHERE WorkItemId IS NULL
           OR WorkItemId <= 0
    )
        THROW 52005, 'Every WorkItemId must be a positive integer.', 1;

    IF EXISTS
    (
        SELECT WorkItemId
        FROM #RequestedStage
        GROUP BY WorkItemId
        HAVING COUNT(*) > 1
    )
        THROW 52006, 'WorkItemIdsJson contains duplicate WorkItemId values.', 1;

    CREATE TABLE #Requested
    (
        WorkItemId  BIGINT NOT NULL PRIMARY KEY CLUSTERED
    );

    INSERT INTO #Requested (WorkItemId)
    SELECT WorkItemId
    FROM #RequestedStage;

    DECLARE @RequestedCount INT =
    (
        SELECT COUNT(1)
        FROM #Requested
    );

    ---------------------------------------------------------------------
    -- 3. Resolve exactly against the same principal eligibility rules
    --    already used by usp_ExportProjectPunchesExtended_Pivoted.
    ---------------------------------------------------------------------
    CREATE TABLE #Resolved
    (
        WorkItemId      BIGINT          NOT NULL PRIMARY KEY CLUSTERED,
        PunchCode       NVARCHAR(500)   NULL,
        StatusCode      NVARCHAR(50)    NULL,
        PunchDiscipline NVARCHAR(100)   NULL,
        TemplateId      BIGINT          NULL
    );

    INSERT INTO #Resolved
    (
        WorkItemId,
        PunchCode,
        StatusCode,
        PunchDiscipline,
        TemplateId
    )
    SELECT
        r.WorkItemId,
        p.Code,
        p.StatusCode,
        p.Discipline,
        p.TemplateID
    FROM #Requested r
    INNER JOIN dbo.wap_PunchPaged p
        ON p.Id = r.WorkItemId
       AND p.ProjectId = @ProjectId
    WHERE
        p.TemplateID = @TemplateId
        AND NULLIF(LTRIM(RTRIM(p.StatusCode)), '') IS NOT NULL
        AND UPPER(LTRIM(RTRIM(p.StatusCode))) NOT IN ('HOLD', 'VOID')
        AND EXISTS
        (
            SELECT 1
            FROM dbo.wap_ElementHierarchyPunchView h
            WHERE h.ProjectId = p.ProjectId
              AND h.PunchId = p.Id
        );

    DECLARE @ResolvedCount INT =
    (
        SELECT COUNT(1)
        FROM #Resolved
    );

    ---------------------------------------------------------------------
    -- 4. Exact cardinality invariant
    ---------------------------------------------------------------------
    IF @ResolvedCount <> @RequestedCount
    BEGIN
        DECLARE @UnresolvedIds NVARCHAR(MAX);
        DECLARE @ErrorMessage NVARCHAR(2048);

        SELECT
            @UnresolvedIds = STRING_AGG(CONVERT(NVARCHAR(MAX), r.WorkItemId), N', ')
        FROM #Requested r
        LEFT JOIN #Resolved x
            ON x.WorkItemId = r.WorkItemId
        WHERE x.WorkItemId IS NULL;

        SET @ErrorMessage = CONCAT
        (
            N'Review Queue export scope mismatch. Requested=',
            @RequestedCount,
            N'; Resolved=',
            @ResolvedCount,
            N'; Unresolved/Ineligible WorkItemIds=',
            LEFT(COALESCE(@UnresolvedIds, N'(not available)'), 1200),
            N'. Partial export is forbidden.'
        );

        THROW 52007, @ErrorMessage, 1;
    END;

    ---------------------------------------------------------------------
    -- 5. Success result
    ---------------------------------------------------------------------
    SELECT
        ProjectId = @ProjectId,
        TemplateId = @TemplateId,
        ExportScope = CAST(N'REVIEW_QUEUE' AS NVARCHAR(30)),
        RequestedCount = @RequestedCount,
        ResolvedCount = @ResolvedCount,
        IsExactMatch = CAST(1 AS BIT);

    SELECT
        RequestedOrdinal = s.SourceOrdinal + 1,
        s.WorkItemId,
        x.PunchCode,
        x.TemplateId,
        x.StatusCode,
        x.PunchDiscipline,
        ResolutionStatus = CAST(N'READY' AS NVARCHAR(20))
    FROM #RequestedStage s
    INNER JOIN #Resolved x
        ON x.WorkItemId = s.WorkItemId
    ORDER BY s.SourceOrdinal;
END;
GO
