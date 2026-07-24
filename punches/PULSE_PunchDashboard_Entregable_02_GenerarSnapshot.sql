
/*
    PULSE - Punch Dashboard
    Entregable 02
    Generación optimizada del snapshot analítico

    Contexto obligatorio:
        ProjectId + TemplateId

    Principios:
    - Los estados son dinámicos por proyecto.
    - Solo se incluyen estados configurados como activos e incluidos.
    - Solo se incluyen categorías activas del template seleccionado.
    - La tabla externa dbo.wap_PunchPaged se materializa una sola vez.
    - El Dashboard consume agregados locales.
    - Se evita la regeneración concurrente del mismo proyecto/template.
*/

SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

CREATE OR ALTER PROCEDURE warroom.usp_GeneratePunchDashboardSnapshot
(
    @ProjectId          BIGINT,
    @TemplateId         BIGINT,
    @RequestedBy        NVARCHAR(450) = NULL,
    @KeepCompletedRuns  INT = 3
)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    IF @ProjectId IS NULL OR @ProjectId <= 0
        THROW 50001, 'ProjectId must be greater than zero.', 1;

    IF @TemplateId IS NULL OR @TemplateId <= 0
        THROW 50002, 'TemplateId must be greater than zero.', 1;

    IF @KeepCompletedRuns IS NULL OR @KeepCompletedRuns < 1
        SET @KeepCompletedRuns = 1;

    IF @KeepCompletedRuns > 20
        SET @KeepCompletedRuns = 20;

    DECLARE
        @SnapshotRunId BIGINT,
        @StartedOn     DATETIME2(7) = SYSUTCDATETIME(),
        @CompletedOn   DATETIME2(7),
        @SourceCount   BIGINT = 0,
        @DurationMs    BIGINT = 0,
        @LockResult    INT,
        @LockResource  NVARCHAR(255),
        @ErrorMessage  NVARCHAR(4000);

    SET @LockResource =
        N'PULSE:PunchDashboardSnapshot:' +
        CONVERT(NVARCHAR(30), @ProjectId) +
        N':' +
        CONVERT(NVARCHAR(30), @TemplateId);

    EXEC @LockResult = sys.sp_getapplock
        @Resource = @LockResource,
        @LockMode = 'Exclusive',
        @LockOwner = 'Session',
        @LockTimeout = 0;

    IF @LockResult < 0
    BEGIN
        THROW 50003, 'A snapshot is already being generated for this project and template.', 1;
    END;

    BEGIN TRY
        -----------------------------------------------------------------
        -- Validate project/template relationship and report configuration
        -----------------------------------------------------------------
        IF NOT EXISTS
        (
            SELECT 1
            FROM dbo.wap_TemplateProject tp
            WHERE tp.ProjectId = @ProjectId
              AND tp.TemplateId = @TemplateId
              AND tp.IsActive = 1
        )
        BEGIN
            THROW 50004, 'The selected template is not active for the selected project.', 1;
        END;

        IF NOT EXISTS
        (
            SELECT 1
            FROM warroom.PunchReportTemplateConfig tc
            WHERE tc.ProjectId = @ProjectId
              AND tc.TemplateId = @TemplateId
              AND tc.IsActive = 1
              AND tc.IsIncluded = 1
        )
        BEGIN
            THROW 50005, 'The selected template is not included in the Punch Dashboard configuration.', 1;
        END;

        IF NOT EXISTS
        (
            SELECT 1
            FROM warroom.PunchReportStatusConfig sc
            WHERE sc.ProjectId = @ProjectId
              AND sc.IsActive = 1
              AND sc.IsIncluded = 1
        )
        BEGIN
            THROW 50006, 'No active punch statuses are included for this project.', 1;
        END;

        -----------------------------------------------------------------
        -- Create execution record
        -----------------------------------------------------------------
        INSERT INTO warroom.PunchDashboardSnapshotRun
        (
            ProjectId,
            TemplateId,
            Status,
            RequestedOn,
            StartedOn,
            RequestedBy
        )
        VALUES
        (
            @ProjectId,
            @TemplateId,
            'RUNNING',
            @StartedOn,
            @StartedOn,
            NULLIF(LTRIM(RTRIM(@RequestedBy)), N'')
        );

        SET @SnapshotRunId = SCOPE_IDENTITY();

        -----------------------------------------------------------------
        -- Materialize dynamic status configuration locally
        -----------------------------------------------------------------
        DROP TABLE IF EXISTS #StatusConfig;

        SELECT
            StatusCode =
                UPPER(LTRIM(RTRIM(CONVERT(VARCHAR(20), sc.StatusCode)))),
            StatusName =
                COALESCE(
                    NULLIF(LTRIM(RTRIM(CONVERT(VARCHAR(100), ws.Description))), ''),
                    NULLIF(LTRIM(RTRIM(CONVERT(VARCHAR(100), sc.StatusCode))), '')
                ),
            StatusOrder = sc.DisplayOrder,
            StatusColor =
                NULLIF(LTRIM(RTRIM(CONVERT(VARCHAR(20), ws.Color))), '')
        INTO #StatusConfig
        FROM warroom.PunchReportStatusConfig sc
        LEFT JOIN dbo.wap_Status ws
            ON UPPER(LTRIM(RTRIM(ws.Code)))
             = UPPER(LTRIM(RTRIM(sc.StatusCode)))
           AND ws.IsActive = 1
        WHERE sc.ProjectId = @ProjectId
          AND sc.IsActive = 1
          AND sc.IsIncluded = 1
          AND NULLIF(LTRIM(RTRIM(sc.StatusCode)), '') IS NOT NULL;

        CREATE UNIQUE CLUSTERED INDEX CX_StatusConfig
            ON #StatusConfig(StatusCode);

        -----------------------------------------------------------------
        -- Materialize active categories for the selected template
        -----------------------------------------------------------------
        DROP TABLE IF EXISTS #CategoryConfig;

        SELECT
            CategoryCode =
                UPPER(
                    COALESCE(
                        NULLIF(LTRIM(RTRIM(CONVERT(VARCHAR(20), c.Code))), ''),
                        'NO_CATEGORY'
                    )
                ),
            CategoryName =
                COALESCE(
                    NULLIF(LTRIM(RTRIM(CONVERT(VARCHAR(450), c.Description))), ''),
                    NULLIF(LTRIM(RTRIM(CONVERT(VARCHAR(20), c.Code))), ''),
                    'No category'
                ),
            CategoryOrder = COALESCE(c.[Order], 2147483647)
        INTO #CategoryConfig
        FROM dbo.wap_Category c
        WHERE c.TemplateId = @TemplateId
          AND c.IsActive = 1;

        IF NOT EXISTS (SELECT 1 FROM #CategoryConfig)
        BEGIN
            THROW 50007, 'The selected template does not contain active categories.', 1;
        END;

        CREATE UNIQUE CLUSTERED INDEX CX_CategoryConfig
            ON #CategoryConfig(CategoryCode);

        -----------------------------------------------------------------
        -- Single materialization of the external punch source
        -----------------------------------------------------------------
        DROP TABLE IF EXISTS #PunchBase;

        ;WITH SourcePunch AS
        (
            SELECT
                PunchId = CONVERT(BIGINT, p.Id),

                ProjectId = CONVERT(BIGINT, p.ProjectId),
                TemplateId = CONVERT(BIGINT, p.TemplateID),

                CategoryCode =
                    UPPER(
                        COALESCE(
                            NULLIF(LTRIM(RTRIM(CONVERT(VARCHAR(20), p.CategoryCode))), ''),
                            'NO_CATEGORY'
                        )
                    ),

                StatusCode =
                    UPPER(LTRIM(RTRIM(CONVERT(VARCHAR(20), p.StatusCode)))),

                SubsystemCode =
                    UPPER(
                        COALESCE(
                            NULLIF(LTRIM(RTRIM(CONVERT(VARCHAR(255), p.SubSystemCode))), ''),
                            'NO_SUBSYSTEM'
                        )
                    ),

                SubsystemName =
                    COALESCE(
                        NULLIF(LTRIM(RTRIM(CONVERT(VARCHAR(255), p.SubSystemDesc))), ''),
                        NULLIF(LTRIM(RTRIM(CONVERT(VARCHAR(255), p.SubSystemCode))), ''),
                        'No subsystem'
                    ),

                SubcontractorId =
                    COALESCE(CONVERT(BIGINT, p.SubcontractorId), CONVERT(BIGINT, -1)),

                DisciplineCode =
                    UPPER(
                        COALESCE(
                            NULLIF(LTRIM(RTRIM(CONVERT(VARCHAR(20), p.DisciplineCode))), ''),
                            'NO_DISCIPLINE'
                        )
                    ),

                DisciplineName =
                    COALESCE(
                        NULLIF(LTRIM(RTRIM(CONVERT(VARCHAR(100), p.Discipline))), ''),
                        NULLIF(LTRIM(RTRIM(CONVERT(VARCHAR(20), p.DisciplineCode))), ''),
                        'No discipline'
                    ),

                rn = ROW_NUMBER() OVER
                (
                    PARTITION BY p.Id
                    ORDER BY p.LastModifiedAt DESC, p.Id DESC
                )
            FROM dbo.wap_PunchPaged p
            INNER JOIN #StatusConfig sc
                ON sc.StatusCode =
                    UPPER(LTRIM(RTRIM(CONVERT(VARCHAR(20), p.StatusCode))))
            INNER JOIN #CategoryConfig cc
                ON cc.CategoryCode =
                    UPPER(
                        COALESCE(
                            NULLIF(LTRIM(RTRIM(CONVERT(VARCHAR(20), p.CategoryCode))), ''),
                            'NO_CATEGORY'
                        )
                    )
            WHERE p.ProjectId = @ProjectId
              AND p.TemplateID = @TemplateId
              AND NULLIF(LTRIM(RTRIM(p.StatusCode)), '') IS NOT NULL
        )
        SELECT
            s.PunchId,
            s.ProjectId,
            s.TemplateId,

            s.CategoryCode,
            cc.CategoryName,
            cc.CategoryOrder,

            s.StatusCode,
            sc.StatusName,
            sc.StatusOrder,
            sc.StatusColor,

            s.SubsystemCode,
            s.SubsystemName,

            s.SubcontractorId,
            SubcontractorCode =
                CASE
                    WHEN s.SubcontractorId = -1 THEN N''
                    ELSE CONVERT(NVARCHAR(50), mc.ID_COMPANY)
                END,
            SubcontractorName =
                CASE
                    WHEN s.SubcontractorId = -1 THEN N'No subcontractor'
                    ELSE COALESCE(
                        NULLIF(LTRIM(RTRIM(mc.DS_COMPANY)), N''),
                        CONVERT(NVARCHAR(50), s.SubcontractorId)
                    )
                END,
            SubcontractorShortName =
                CASE
                    WHEN s.SubcontractorId = -1 THEN N'No subcontractor'
                    ELSE COALESCE(
                        NULLIF(LTRIM(RTRIM(mc.DS_SHORT_COMPANY)), N''),
                        NULLIF(LTRIM(RTRIM(mc.DS_COMPANY)), N''),
                        CONVERT(NVARCHAR(50), s.SubcontractorId)
                    )
                END,

            s.DisciplineCode,
            s.DisciplineName
        INTO #PunchBase
        FROM SourcePunch s
        INNER JOIN #StatusConfig sc
            ON sc.StatusCode = s.StatusCode
        INNER JOIN #CategoryConfig cc
            ON cc.CategoryCode = s.CategoryCode
        LEFT JOIN dbo.DIM_MASTER_COMPANIES_LH mc
            ON mc.ID_COMPANY = TRY_CONVERT(INT, s.SubcontractorId)
        WHERE s.rn = 1
        OPTION (RECOMPILE);

        SET @SourceCount = @@ROWCOUNT;

        CREATE UNIQUE CLUSTERED INDEX CX_PunchBase
            ON #PunchBase(PunchId);

        CREATE NONCLUSTERED INDEX IX_PunchBase_CategoryStatus
            ON #PunchBase(CategoryCode, StatusCode)
            INCLUDE
            (
                CategoryName,
                CategoryOrder,
                StatusName,
                StatusOrder,
                StatusColor
            );

        CREATE NONCLUSTERED INDEX IX_PunchBase_Subsystem
            ON #PunchBase(SubsystemCode, CategoryCode, StatusCode)
            INCLUDE
            (
                SubsystemName,
                CategoryName,
                CategoryOrder,
                StatusName,
                StatusOrder,
                StatusColor
            );

        CREATE NONCLUSTERED INDEX IX_PunchBase_Subcontractor
            ON #PunchBase
            (
                SubcontractorId,
                DisciplineCode,
                CategoryCode,
                StatusCode
            )
            INCLUDE
            (
                SubcontractorCode,
                SubcontractorName,
                SubcontractorShortName,
                DisciplineName,
                CategoryName,
                CategoryOrder,
                StatusName,
                StatusOrder,
                StatusColor
            );

        -----------------------------------------------------------------
        -- Persist all aggregates atomically
        -----------------------------------------------------------------
        BEGIN TRANSACTION;

        INSERT INTO warroom.PunchDashboardSnapshotCategoryStatus
        (
            SnapshotRunId,
            ProjectId,
            TemplateId,
            CategoryCode,
            CategoryName,
            CategoryOrder,
            StatusCode,
            StatusName,
            StatusOrder,
            StatusColor,
            PunchCount
        )
        SELECT
            @SnapshotRunId,
            @ProjectId,
            @TemplateId,
            pb.CategoryCode,
            MAX(pb.CategoryName),
            MAX(pb.CategoryOrder),
            pb.StatusCode,
            MAX(pb.StatusName),
            MAX(pb.StatusOrder),
            MAX(pb.StatusColor),
            COUNT_BIG(1)
        FROM #PunchBase pb
        GROUP BY
            pb.CategoryCode,
            pb.StatusCode;

        INSERT INTO warroom.PunchDashboardSnapshotSubsystem
        (
            SnapshotRunId,
            ProjectId,
            TemplateId,
            SubsystemCode,
            SubsystemName,
            CategoryCode,
            CategoryName,
            CategoryOrder,
            StatusCode,
            StatusName,
            StatusOrder,
            StatusColor,
            PunchCount
        )
        SELECT
            @SnapshotRunId,
            @ProjectId,
            @TemplateId,
            pb.SubsystemCode,
            MAX(pb.SubsystemName),
            pb.CategoryCode,
            MAX(pb.CategoryName),
            MAX(pb.CategoryOrder),
            pb.StatusCode,
            MAX(pb.StatusName),
            MAX(pb.StatusOrder),
            MAX(pb.StatusColor),
            COUNT_BIG(1)
        FROM #PunchBase pb
        GROUP BY
            pb.SubsystemCode,
            pb.CategoryCode,
            pb.StatusCode;

        INSERT INTO warroom.PunchDashboardSnapshotSubcontractor
        (
            SnapshotRunId,
            ProjectId,
            TemplateId,
            SubcontractorId,
            SubcontractorCode,
            SubcontractorName,
            SubcontractorShortName,
            DisciplineCode,
            DisciplineName,
            CategoryCode,
            CategoryName,
            CategoryOrder,
            StatusCode,
            StatusName,
            StatusOrder,
            StatusColor,
            PunchCount
        )
        SELECT
            @SnapshotRunId,
            @ProjectId,
            @TemplateId,
            pb.SubcontractorId,
            MAX(pb.SubcontractorCode),
            MAX(pb.SubcontractorName),
            MAX(pb.SubcontractorShortName),
            pb.DisciplineCode,
            MAX(pb.DisciplineName),
            pb.CategoryCode,
            MAX(pb.CategoryName),
            MAX(pb.CategoryOrder),
            pb.StatusCode,
            MAX(pb.StatusName),
            MAX(pb.StatusOrder),
            MAX(pb.StatusColor),
            COUNT_BIG(1)
        FROM #PunchBase pb
        GROUP BY
            pb.SubcontractorId,
            pb.DisciplineCode,
            pb.CategoryCode,
            pb.StatusCode;

        SET @CompletedOn = SYSUTCDATETIME();
        SET @DurationMs = DATEDIFF_BIG(MILLISECOND, @StartedOn, @CompletedOn);

        UPDATE warroom.PunchDashboardSnapshotRun
        SET
            Status = 'COMPLETED',
            CompletedOn = @CompletedOn,
            SourcePunchCount = @SourceCount,
            DurationMs = @DurationMs,
            ErrorMessage = NULL
        WHERE SnapshotRunId = @SnapshotRunId;

        COMMIT TRANSACTION;

        -----------------------------------------------------------------
        -- Retain only the configured number of completed snapshots
        -----------------------------------------------------------------
        DROP TABLE IF EXISTS #RunsToDelete;

        ;WITH RankedRuns AS
        (
            SELECT
                r.SnapshotRunId,
                rn = ROW_NUMBER() OVER
                (
                    PARTITION BY r.ProjectId, r.TemplateId
                    ORDER BY r.SnapshotRunId DESC
                )
            FROM warroom.PunchDashboardSnapshotRun r
            WHERE r.ProjectId = @ProjectId
              AND r.TemplateId = @TemplateId
              AND r.Status = 'COMPLETED'
        )
        SELECT SnapshotRunId
        INTO #RunsToDelete
        FROM RankedRuns
        WHERE rn > @KeepCompletedRuns;

        DELETE r
        FROM warroom.PunchDashboardSnapshotRun r
        INNER JOIN #RunsToDelete d
            ON d.SnapshotRunId = r.SnapshotRunId;

        -----------------------------------------------------------------
        -- Flow / Power Apps response
        -----------------------------------------------------------------
        SELECT
            Success = CONVERT(BIT, 1),
            SnapshotRunId = @SnapshotRunId,
            ProjectId = @ProjectId,
            TemplateId = @TemplateId,
            SnapshotStatus = CONVERT(VARCHAR(20), 'COMPLETED'),
            SourcePunchCount = @SourceCount,
            GeneratedOn = @CompletedOn,
            DurationMs = @DurationMs,
            Message = CONVERT(
                NVARCHAR(4000),
                N'Punch Dashboard snapshot generated successfully.'
            );
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0
            ROLLBACK TRANSACTION;

        SET @CompletedOn = SYSUTCDATETIME();
        SET @DurationMs = DATEDIFF_BIG(MILLISECOND, @StartedOn, @CompletedOn);
        SET @ErrorMessage =
            LEFT(
                CONCAT(
                    N'Error ',
                    ERROR_NUMBER(),
                    N' (line ',
                    ERROR_LINE(),
                    N'): ',
                    ERROR_MESSAGE()
                ),
                4000
            );

        IF @SnapshotRunId IS NOT NULL
        BEGIN
            UPDATE warroom.PunchDashboardSnapshotRun
            SET
                Status = 'FAILED',
                CompletedOn = @CompletedOn,
                SourcePunchCount = @SourceCount,
                DurationMs = @DurationMs,
                ErrorMessage = @ErrorMessage
            WHERE SnapshotRunId = @SnapshotRunId;
        END;

        EXEC sys.sp_releaseapplock
            @Resource = @LockResource,
            @LockOwner = 'Session';

        THROW;
    END CATCH;

    EXEC sys.sp_releaseapplock
        @Resource = @LockResource,
        @LockOwner = 'Session';
END;
GO

/*
    Example:

    EXEC warroom.usp_GeneratePunchDashboardSnapshot
        @ProjectId = 4049,
        @TemplateId = 7,
        @RequestedBy = N'user@company.com',
        @KeepCompletedRuns = 3;
*/
