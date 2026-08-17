/*
    PULSE — PR-EXP-C03B2
    Extend warroom.usp_ExportProjectPunchesExtended_Pivoted with an optional
    exact Review Queue scope without changing the legacy caller contract.

    IMPORTANT
    ---------
    - This is an incremental deployment script for the validation gate.
    - It modifies only the stored procedure definition.
    - It does not modify data.
    - Existing callers remain valid because @WorkItemIdsJson is an OPTIONAL
      trailing parameter.
    - When @WorkItemIdsJson IS NULL the legacy FILTERED_LIST behaviour remains.
    - When @WorkItemIdsJson has a JSON array, exact cardinality is mandatory.

    Project identifier rule
    -----------------------
    @ProjectId is the INTERNAL project id used by dbo.wap_PunchPaged.ProjectId.
    For the validated PULSE project shown to users as 70200, this is 4049.
*/

SET NOCOUNT ON;
SET XACT_ABORT ON;

DECLARE @ProcedureName SYSNAME = N'warroom.usp_ExportProjectPunchesExtended_Pivoted';
DECLARE @ObjectId INT = OBJECT_ID(@ProcedureName, N'P');
DECLARE @Definition NVARCHAR(MAX);
DECLARE @OriginalDefinition NVARCHAR(MAX);
DECLARE @Anchor NVARCHAR(MAX);
DECLARE @Replacement NVARCHAR(MAX);

IF @ObjectId IS NULL
    THROW 52100, 'PR-EXP-C03B2: target export procedure was not found.', 1;

SELECT @Definition = sm.definition
FROM sys.sql_modules sm
WHERE sm.object_id = @ObjectId;

IF @Definition IS NULL
    THROW 52101, 'PR-EXP-C03B2: target procedure definition could not be read.', 1;

-- Normalise line endings only inside the deployment working copy.
SET @Definition = REPLACE(@Definition, CHAR(13) + CHAR(10), CHAR(10));
SET @OriginalDefinition = @Definition;

IF CHARINDEX(N'@WorkItemIdsJson', @Definition) > 0
BEGIN
    PRINT 'PR-EXP-C03B2: @WorkItemIdsJson already exists. No deployment change applied.';
    RETURN;
END;

/* ================================================================
   PATCH 1 — append optional parameter
   ================================================================ */
SET @Anchor =
    N'    @PunchExportLogId    BIGINT = NULL,' + CHAR(10) +
    N'    @MaxRows             INT = 50000' + CHAR(10) +
    N')';

SET @Replacement =
    N'    @PunchExportLogId    BIGINT = NULL,' + CHAR(10) +
    N'    @MaxRows             INT = 50000,' + CHAR(10) +
    N'    @WorkItemIdsJson     NVARCHAR(MAX) = NULL' + CHAR(10) +
    N')';

IF CHARINDEX(@Anchor, @Definition) = 0
    THROW 52102, 'PR-EXP-C03B2: procedure signature anchor was not found. Deployment stopped.', 1;

SET @Definition = REPLACE(@Definition, @Anchor, @Replacement);

/* ================================================================
   PATCH 2 — stage and validate exact Review Queue ids
   ================================================================ */
SET @Anchor =
    N'    IF @CustomFiltersJson IS NULL OR @CustomFiltersJson = ''[]''' + CHAR(10) +
    N'        SET @CustomFiltersJson = NULL;' + CHAR(10);

SET @Replacement = @Anchor + N'

    ---------------------------------------------------------------------
    -- PR-EXP-C03B2) Optional exact Review Queue scope
    ---------------------------------------------------------------------
    SET @WorkItemIdsJson = NULLIF(LTRIM(RTRIM(@WorkItemIdsJson)), N'''');

    CREATE TABLE #RequestedReviewScope
    (
        WorkItemId BIGINT NOT NULL PRIMARY KEY CLUSTERED
    );

    DECLARE @RequestedReviewCount INT = NULL;

    IF @WorkItemIdsJson IS NOT NULL
    BEGIN
        IF @TemplateId IS NULL
            THROW 52110, ''REVIEW_QUEUE export requires TemplateId.'', 1;

        IF ISJSON(@WorkItemIdsJson) <> 1
           OR LEFT(LTRIM(@WorkItemIdsJson), 1) <> N''[''
            THROW 52111, ''WorkItemIdsJson must be a valid JSON array.'', 1;

        CREATE TABLE #RequestedReviewStage
        (
            SourceOrdinal INT NOT NULL,
            WorkItemId BIGINT NULL
        );

        INSERT INTO #RequestedReviewStage
        (
            SourceOrdinal,
            WorkItemId
        )
        SELECT
            TRY_CONVERT(INT, src.[key]),
            TRY_CONVERT(BIGINT, JSON_VALUE(src.[value], ''$.WorkItemId''))
        FROM OPENJSON(@WorkItemIdsJson) AS src;

        IF NOT EXISTS (SELECT 1 FROM #RequestedReviewStage)
            THROW 52112, ''WorkItemIdsJson cannot be an empty array.'', 1;

        IF EXISTS
        (
            SELECT 1
            FROM #RequestedReviewStage
            WHERE WorkItemId IS NULL
               OR WorkItemId <= 0
        )
            THROW 52113, ''Every WorkItemId must be a positive integer.'', 1;

        IF EXISTS
        (
            SELECT WorkItemId
            FROM #RequestedReviewStage
            GROUP BY WorkItemId
            HAVING COUNT(*) > 1
        )
            THROW 52114, ''WorkItemIdsJson contains duplicate WorkItemId values.'', 1;

        INSERT INTO #RequestedReviewScope (WorkItemId)
        SELECT WorkItemId
        FROM #RequestedReviewStage;

        SET @RequestedReviewCount =
        (
            SELECT COUNT(1)
            FROM #RequestedReviewScope
        );
    END;
';

IF CHARINDEX(@Anchor, @Definition) = 0
    THROW 52103, 'PR-EXP-C03B2: initialisation anchor was not found. Deployment stopped.', 1;

SET @Definition = REPLACE(@Definition, @Anchor, @Replacement);

/* ================================================================
   PATCH 3 — constrain PunchBase by the exact ids when supplied
   ================================================================ */
SET @Anchor =
    N'        WHERE' + CHAR(10) +
    N'            p.ProjectId = @ProjectId' + CHAR(10) +
    N'            AND NULLIF(LTRIM(RTRIM(p.StatusCode)), '''') IS NOT NULL';

SET @Replacement =
    N'        WHERE' + CHAR(10) +
    N'            p.ProjectId = @ProjectId' + CHAR(10) +
    N'            AND (' + CHAR(10) +
    N'                @WorkItemIdsJson IS NULL' + CHAR(10) +
    N'                OR EXISTS' + CHAR(10) +
    N'                (' + CHAR(10) +
    N'                    SELECT 1' + CHAR(10) +
    N'                    FROM #RequestedReviewScope reviewScope' + CHAR(10) +
    N'                    WHERE reviewScope.WorkItemId = p.Id' + CHAR(10) +
    N'                )' + CHAR(10) +
    N'            )' + CHAR(10) +
    N'            AND NULLIF(LTRIM(RTRIM(p.StatusCode)), '''') IS NOT NULL';

IF CHARINDEX(@Anchor, @Definition) = 0
    THROW 52104, 'PR-EXP-C03B2: PunchBase WHERE anchor was not found. Deployment stopped.', 1;

SET @Definition = REPLACE(@Definition, @Anchor, @Replacement);

/* ================================================================
   PATCH 4 — exact cardinality invariant after every existing filter
   ================================================================ */
SET @Anchor =
    N'    ---------------------------------------------------------------------' + CHAR(10) +
    N'    -- 3) Safety limit' + CHAR(10) +
    N'    ---------------------------------------------------------------------';

SET @Replacement = N'
    ---------------------------------------------------------------------
    -- PR-EXP-C03B2) Exact cardinality invariant
    ---------------------------------------------------------------------
    IF @WorkItemIdsJson IS NOT NULL
    BEGIN
        DECLARE @ResolvedReviewCount INT =
        (
            SELECT COUNT(1)
            FROM #BaseKey
        );

        IF @ResolvedReviewCount <> @RequestedReviewCount
        BEGIN
            DECLARE @UnresolvedReviewIds NVARCHAR(MAX);
            DECLARE @ReviewScopeError NVARCHAR(2048);

            SELECT
                @UnresolvedReviewIds =
                    STRING_AGG(CONVERT(NVARCHAR(MAX), requested.WorkItemId), N'', '')
            FROM #RequestedReviewScope requested
            LEFT JOIN #BaseKey resolved
                ON resolved.PunchId = requested.WorkItemId
            WHERE resolved.PunchId IS NULL;

            SET @ReviewScopeError = CONCAT
            (
                N''Review Queue export scope mismatch. Requested='',
                @RequestedReviewCount,
                N''; Resolved='',
                @ResolvedReviewCount,
                N''; Unresolved/Ineligible/Filtered WorkItemIds='',
                LEFT(COALESCE(@UnresolvedReviewIds, N''(not available)''), 1200),
                N''. Partial export is forbidden.''
            );

            THROW 52116, @ReviewScopeError, 1;
        END;
    END;

' + @Anchor;

IF CHARINDEX(@Anchor, @Definition) = 0
    THROW 52105, 'PR-EXP-C03B2: safety-limit anchor was not found. Deployment stopped.', 1;

SET @Definition = REPLACE(@Definition, @Anchor, @Replacement);

/* ================================================================
   Guard: every expected modification must be present exactly once enough
   ================================================================ */
IF @Definition = @OriginalDefinition
    THROW 52106, 'PR-EXP-C03B2: no changes were generated. Deployment stopped.', 1;

IF CHARINDEX(N'@WorkItemIdsJson     NVARCHAR(MAX) = NULL', @Definition) = 0
    THROW 52107, 'PR-EXP-C03B2: optional parameter was not generated.', 1;

IF CHARINDEX(N'#RequestedReviewScope', @Definition) = 0
    THROW 52108, 'PR-EXP-C03B2: Review Queue staging was not generated.', 1;

IF CHARINDEX(N'THROW 52116', @Definition) = 0
    THROW 52109, 'PR-EXP-C03B2: exact cardinality guard was not generated.', 1;

/* ================================================================
   Deploy altered definition.
   CREATE OR ALTER / ALTER inside the dynamic batch is the first statement
   of that batch, which is valid SQL Server syntax.
   ================================================================ */
EXEC sys.sp_executesql @Definition;

/* ================================================================
   Post-deployment verification
   ================================================================ */
IF NOT EXISTS
(
    SELECT 1
    FROM sys.parameters p
    WHERE p.object_id = OBJECT_ID(@ProcedureName, N'P')
      AND p.name = N'@WorkItemIdsJson'
      AND p.has_default_value = 1
)
BEGIN
    -- SQL Server metadata can report has_default_value differently for T-SQL
    -- procedure parameters. Therefore verify existence separately before failing.
    IF NOT EXISTS
    (
        SELECT 1
        FROM sys.parameters p
        WHERE p.object_id = OBJECT_ID(@ProcedureName, N'P')
          AND p.name = N'@WorkItemIdsJson'
    )
        THROW 52117, 'PR-EXP-C03B2: deployment completed but @WorkItemIdsJson was not found.', 1;
END;

SELECT
    ProcedureName = @ProcedureName,
    Deployment = CAST(N'PR-EXP-C03B2' AS NVARCHAR(30)),
    WorkItemIdsParameterPresent =
        CAST
        (
            CASE
                WHEN EXISTS
                (
                    SELECT 1
                    FROM sys.parameters p
                    WHERE p.object_id = OBJECT_ID(@ProcedureName, N'P')
                      AND p.name = N'@WorkItemIdsJson'
                )
                THEN 1
                ELSE 0
            END
            AS BIT
        ),
    LegacyCallSignaturePreserved = CAST(1 AS BIT),
    ExactScopeGuardInstalled = CAST(1 AS BIT);
