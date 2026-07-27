/*
    PULSE - Punch Dashboard
    Sprint 05.1 - Executive KPI vertical for Power Automate / Power Apps

    Prerequisites:
      - PULSE_PunchDashboard_Entregable_01_ModeloDatos.sql
      - PULSE_PunchDashboard_Entregable_02_GenerarSnapshot.sql

    Output contract:
      One row / one column named [result], containing one JSON object.
*/
SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

CREATE OR ALTER PROCEDURE warroom.usp_GetPunchDashboardBundle
(
    @ProjectId  BIGINT,
    @TemplateId BIGINT
)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    IF @ProjectId IS NULL OR @ProjectId <= 0
        THROW 50100, 'ProjectId is required.', 1;

    IF @TemplateId IS NULL OR @TemplateId <= 0
        THROW 50101, 'TemplateId is required.', 1;

    DECLARE @SnapshotRunId BIGINT;
    DECLARE @PreviousSnapshotRunId BIGINT;
    DECLARE @SnapshotInfo NVARCHAR(MAX) = N'[]';
    DECLARE @Summary NVARCHAR(MAX) = N'[]';
    DECLARE @Matrix NVARCHAR(MAX) = N'[]';
    DECLARE @Subsystems NVARCHAR(MAX) = N'[]';
    DECLARE @Subcontractors NVARCHAR(MAX) = N'[]';
    DECLARE @Result NVARCHAR(MAX);

    SELECT TOP (1)
        @SnapshotRunId = r.SnapshotRunId
    FROM warroom.PunchDashboardSnapshotRun r
    WHERE r.ProjectId = @ProjectId
      AND r.TemplateId = @TemplateId
      AND r.Status = 'COMPLETED'
    ORDER BY r.SnapshotRunId DESC;

    IF @SnapshotRunId IS NOT NULL
    BEGIN
        SELECT TOP (1)
            @PreviousSnapshotRunId = r.SnapshotRunId
        FROM warroom.PunchDashboardSnapshotRun r
        WHERE r.ProjectId = @ProjectId
          AND r.TemplateId = @TemplateId
          AND r.Status = 'COMPLETED'
          AND r.SnapshotRunId < @SnapshotRunId
        ORDER BY r.SnapshotRunId DESC;
        SELECT @SnapshotInfo =
        (
            SELECT
                r.SnapshotRunId,
                PreviousSnapshotRunId = @PreviousSnapshotRunId,
                GeneratedOn = r.CompletedOn,
                r.SourcePunchCount,
                r.DurationMs,
                DataVersion = N'2.1'
            FROM warroom.PunchDashboardSnapshotRun r
            WHERE r.SnapshotRunId = @SnapshotRunId
            FOR JSON PATH
        );

        ;WITH CurrentSummary AS
        (
            SELECT
                cs.StatusCode,
                StatusName = MAX(cs.StatusName),
                StatusOrder = MAX(cs.StatusOrder),
                StatusColor = MAX(cs.StatusColor),
                PunchCount = SUM(cs.PunchCount)
            FROM warroom.PunchDashboardSnapshotCategoryStatus cs
            WHERE cs.SnapshotRunId = @SnapshotRunId
            GROUP BY cs.StatusCode
        ),
        PreviousSummary AS
        (
            SELECT
                cs.StatusCode,
                PreviousPunchCount = SUM(cs.PunchCount)
            FROM warroom.PunchDashboardSnapshotCategoryStatus cs
            WHERE cs.SnapshotRunId = @PreviousSnapshotRunId
            GROUP BY cs.StatusCode
        )
        SELECT @Summary =
        (
            SELECT
                c.StatusCode,
                c.StatusName,
                c.StatusOrder,
                c.StatusColor,
                c.PunchCount,
                PreviousPunchCount = COALESCE(p.PreviousPunchCount, c.PunchCount),
                Delta = c.PunchCount - COALESCE(p.PreviousPunchCount, c.PunchCount),
                DeltaPercent =
                    CONVERT(
                        DECIMAL(10,2),
                        CASE
                            WHEN COALESCE(p.PreviousPunchCount, 0) = 0 THEN 0
                            ELSE
                                ((c.PunchCount - p.PreviousPunchCount) * 100.0)
                                / NULLIF(p.PreviousPunchCount, 0)
                        END
                    ),
                Trend =
                    CASE
                        WHEN @PreviousSnapshotRunId IS NULL THEN N'Neutral'
                        WHEN c.PunchCount > COALESCE(p.PreviousPunchCount, 0) THEN N'Up'
                        WHEN c.PunchCount < COALESCE(p.PreviousPunchCount, 0) THEN N'Down'
                        ELSE N'Neutral'
                    END
            FROM CurrentSummary c
            LEFT JOIN PreviousSummary p
                ON p.StatusCode = c.StatusCode
            ORDER BY c.StatusOrder, c.StatusCode
            FOR JSON PATH
        );

        SELECT @Matrix =
        (
            SELECT
                cs.CategoryCode,
                cs.CategoryName,
                cs.CategoryOrder,
                cs.StatusCode,
                cs.StatusName,
                cs.StatusOrder,
                cs.StatusColor,
                cs.PunchCount
            FROM warroom.PunchDashboardSnapshotCategoryStatus cs
            WHERE cs.SnapshotRunId = @SnapshotRunId
            ORDER BY cs.CategoryOrder, cs.CategoryCode, cs.StatusOrder, cs.StatusCode
            FOR JSON PATH
        );

        SELECT @Subsystems =
        (
            SELECT
                s.SubsystemCode,
                s.SubsystemName,
                s.CategoryCode,
                s.CategoryName,
                s.StatusCode,
                s.StatusName,
                s.StatusOrder,
                s.StatusColor,
                s.PunchCount
            FROM warroom.PunchDashboardSnapshotSubsystem s
            WHERE s.SnapshotRunId = @SnapshotRunId
            ORDER BY s.SubsystemCode, s.CategoryOrder, s.StatusOrder
            FOR JSON PATH
        );

        SELECT @Subcontractors =
        (
            SELECT
                s.SubcontractorId,
                s.SubcontractorName,
                s.DisciplineCode,
                s.DisciplineName,
                s.CategoryCode,
                s.CategoryName,
                s.StatusCode,
                s.StatusName,
                s.StatusOrder,
                s.StatusColor,
                s.PunchCount
            FROM warroom.PunchDashboardSnapshotSubcontractor s
            WHERE s.SnapshotRunId = @SnapshotRunId
            ORDER BY s.SubcontractorName, s.DisciplineCode, s.CategoryOrder, s.StatusOrder
            FOR JSON PATH
        );
    END;

    SELECT @Result =
    (
        SELECT
            success = CONVERT(BIT, 1),
            hasSnapshot = CONVERT(BIT, CASE WHEN @SnapshotRunId IS NULL THEN 0 ELSE 1 END),
            [message] = CASE
                WHEN @SnapshotRunId IS NULL
                    THEN N'No completed snapshot exists for the selected project and template.'
                ELSE N''
            END,
            snapshotInfo = JSON_QUERY(COALESCE(@SnapshotInfo, N'[]')),
            summary = JSON_QUERY(COALESCE(@Summary, N'[]')),
            matrix = JSON_QUERY(COALESCE(@Matrix, N'[]')),
            subsystems = JSON_QUERY(COALESCE(@Subsystems, N'[]')),
            subcontractors = JSON_QUERY(COALESCE(@Subcontractors, N'[]')),
            contractVersion = N'2.1'
        FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
    );

    SELECT result = @Result;
END;
GO
