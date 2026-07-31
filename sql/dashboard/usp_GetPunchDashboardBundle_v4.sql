

ALTER   PROCEDURE [warroom].[usp_GetPunchDashboardBundle]
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
    DECLARE @Timeline NVARCHAR(MAX) = N'[]';
    DECLARE @Subsystems NVARCHAR(MAX) = N'[]';
    DECLARE @Subcontractors NVARCHAR(MAX) = N'[]';
    DECLARE @Insights NVARCHAR(MAX) = N'[]';
    DECLARE @Punches NVARCHAR(MAX) = N'[]';
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
                DataVersion = N'3.0'
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

        ;WITH MatrixBase AS
        (
            SELECT
                cs.CategoryCode,
                cs.CategoryName,
                cs.CategoryOrder,
                cs.StatusCode,
                cs.StatusName,
                cs.StatusOrder,
                cs.StatusColor,
                cs.PunchCount,
                MaxPunchCount = MAX(cs.PunchCount) OVER ()
            FROM warroom.PunchDashboardSnapshotCategoryStatus cs
            WHERE cs.SnapshotRunId = @SnapshotRunId
        )
        SELECT @Matrix =
        (
            SELECT
                m.CategoryCode,
                m.CategoryName,
                m.CategoryOrder,
                m.StatusCode,
                m.StatusName,
                m.StatusOrder,
                m.StatusColor,
                m.PunchCount,
                Intensity = CONVERT(INT, CASE WHEN COALESCE(m.MaxPunchCount, 0) = 0 THEN 0 ELSE ROUND((m.PunchCount * 100.0) / NULLIF(m.MaxPunchCount, 0), 0) END),
                IntensityBand =
                    CASE
                        WHEN m.PunchCount = 0 THEN N'NONE'
                        WHEN (m.PunchCount * 100.0) / NULLIF(m.MaxPunchCount, 0) <= 25 THEN N'LOW'
                        WHEN (m.PunchCount * 100.0) / NULLIF(m.MaxPunchCount, 0) <= 50 THEN N'MEDIUM'
                        WHEN (m.PunchCount * 100.0) / NULLIF(m.MaxPunchCount, 0) <= 75 THEN N'HIGH'
                        ELSE N'CRITICAL'
                    END
            FROM MatrixBase m
            ORDER BY m.CategoryOrder, m.CategoryCode, m.StatusOrder, m.StatusCode
            FOR JSON PATH
        );


        ;WITH LatestSnapshots AS
        (
            SELECT TOP (7)
                r.SnapshotRunId,
                SnapshotDate = r.CompletedOn,
                SnapshotSequence =
                    ROW_NUMBER() OVER (ORDER BY r.SnapshotRunId ASC)
            FROM warroom.PunchDashboardSnapshotRun r
            WHERE r.ProjectId = @ProjectId
              AND r.TemplateId = @TemplateId
              AND r.Status = 'COMPLETED'
            ORDER BY r.SnapshotRunId DESC
        ),
        TimelineBase AS
        (
            SELECT
                ls.SnapshotRunId,
                ls.SnapshotDate,
                ls.SnapshotSequence,
                OpenCount =
                    SUM(
                        CASE
                            WHEN UPPER(cs.StatusCode) IN ('OPEN', 'O')
                              OR UPPER(cs.StatusName) = 'OPEN'
                            THEN cs.PunchCount ELSE 0
                        END
                    ),
                ClearedCount =
                    SUM(
                        CASE
                            WHEN UPPER(cs.StatusCode) IN ('CLEARED', 'CLEAR', 'C')
                              OR UPPER(cs.StatusName) = 'CLEARED'
                            THEN cs.PunchCount ELSE 0
                        END
                    ),
                ClosedCount =
                    SUM(
                        CASE
                            WHEN UPPER(cs.StatusCode) IN ('CLOSED', 'CLOSE', 'CL')
                              OR UPPER(cs.StatusName) = 'CLOSED'
                            THEN cs.PunchCount ELSE 0
                        END
                    )
            FROM LatestSnapshots ls
            LEFT JOIN warroom.PunchDashboardSnapshotCategoryStatus cs
                ON cs.SnapshotRunId = ls.SnapshotRunId
            GROUP BY
                ls.SnapshotRunId,
                ls.SnapshotDate,
                ls.SnapshotSequence
        )
        SELECT @Timeline =
        (
            SELECT
                t.SnapshotRunId,
                t.SnapshotDate,
                t.SnapshotSequence,
                [Open] = COALESCE(t.OpenCount, 0),
                Cleared = COALESCE(t.ClearedCount, 0),
                Closed = COALESCE(t.ClosedCount, 0),
                Total =
                    COALESCE(t.OpenCount, 0) +
                    COALESCE(t.ClearedCount, 0) +
                    COALESCE(t.ClosedCount, 0),
                OpenDelta =
                    COALESCE(t.OpenCount, 0) -
                    COALESCE(
                        LAG(t.OpenCount) OVER (ORDER BY t.SnapshotDate, t.SnapshotRunId),
                        t.OpenCount,
                        0
                    ),
                OpenDeltaPercent =
                    CONVERT(
                        DECIMAL(10,2),
                        CASE
                            WHEN COALESCE(
                                LAG(t.OpenCount) OVER (ORDER BY t.SnapshotDate, t.SnapshotRunId),
                                0
                            ) = 0
                            THEN 0
                            ELSE
                                (
                                    (
                                        COALESCE(t.OpenCount, 0) -
                                        LAG(t.OpenCount) OVER (ORDER BY t.SnapshotDate, t.SnapshotRunId)
                                    ) * 100.0
                                )
                                / NULLIF(
                                    LAG(t.OpenCount) OVER (ORDER BY t.SnapshotDate, t.SnapshotRunId),
                                    0
                                )
                        END
                    )
            FROM TimelineBase t
            ORDER BY t.SnapshotDate, t.SnapshotRunId
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

        /*
            Executive insights are intentionally deterministic and derived only
            from the snapshot contract already consumed by Power Apps.
        */
        ;WITH CurrentStatus AS
        (
            SELECT
                cs.StatusCode,
                StatusName = MAX(cs.StatusName),
                PunchCount = SUM(cs.PunchCount)
            FROM warroom.PunchDashboardSnapshotCategoryStatus cs
            WHERE cs.SnapshotRunId = @SnapshotRunId
            GROUP BY cs.StatusCode
        ),
        PreviousStatus AS
        (
            SELECT
                cs.StatusCode,
                PunchCount = SUM(cs.PunchCount)
            FROM warroom.PunchDashboardSnapshotCategoryStatus cs
            WHERE cs.SnapshotRunId = @PreviousSnapshotRunId
            GROUP BY cs.StatusCode
        ),
        OpenTrend AS
        (
            SELECT TOP (1)
                c.StatusCode,
                c.StatusName,
                CurrentCount = c.PunchCount,
                PreviousCount = COALESCE(p.PunchCount, c.PunchCount),
                Delta = c.PunchCount - COALESCE(p.PunchCount, c.PunchCount),
                DeltaPercent = CONVERT(DECIMAL(10,2),
                    CASE WHEN COALESCE(p.PunchCount, 0) = 0 THEN 0
                         ELSE ((c.PunchCount - p.PunchCount) * 100.0) / NULLIF(p.PunchCount, 0) END)
            FROM CurrentStatus c
            LEFT JOIN PreviousStatus p ON p.StatusCode = c.StatusCode
            WHERE UPPER(c.StatusCode) IN ('OPEN','O') OR UPPER(c.StatusName) = 'OPEN'
        ),
        ClosedTrend AS
        (
            SELECT TOP (1)
                c.StatusCode,
                c.StatusName,
                CurrentCount = c.PunchCount,
                PreviousCount = COALESCE(p.PunchCount, c.PunchCount),
                Delta = c.PunchCount - COALESCE(p.PunchCount, c.PunchCount),
                DeltaPercent = CONVERT(DECIMAL(10,2),
                    CASE WHEN COALESCE(p.PunchCount, 0) = 0 THEN 0
                         ELSE ((c.PunchCount - p.PunchCount) * 100.0) / NULLIF(p.PunchCount, 0) END)
            FROM CurrentStatus c
            LEFT JOIN PreviousStatus p ON p.StatusCode = c.StatusCode
            WHERE UPPER(c.StatusCode) IN ('CLOSED','CLOSE','CL') OR UPPER(c.StatusName) = 'CLOSED'
        ),
        TopHotspot AS
        (
            SELECT TOP (1)
                cs.CategoryCode, cs.CategoryName, cs.StatusCode, cs.StatusName, cs.PunchCount
            FROM warroom.PunchDashboardSnapshotCategoryStatus cs
            WHERE cs.SnapshotRunId = @SnapshotRunId
              AND cs.PunchCount > 0
            ORDER BY cs.PunchCount DESC, cs.CategoryOrder, cs.StatusOrder
        ),
        TopSubsystem AS
        (
            SELECT TOP (1)
                s.SubsystemCode, s.SubsystemName, s.CategoryCode, s.CategoryName,
                s.StatusCode, s.StatusName, s.PunchCount
            FROM warroom.PunchDashboardSnapshotSubsystem s
            WHERE s.SnapshotRunId = @SnapshotRunId
              AND s.PunchCount > 0
            ORDER BY s.PunchCount DESC, s.SubsystemCode, s.CategoryOrder, s.StatusOrder
        ),
        TopSubcontractor AS
        (
            SELECT TOP (1)
                s.SubcontractorId, s.SubcontractorName, s.DisciplineCode, s.DisciplineName,
                s.CategoryCode, s.CategoryName, s.StatusCode, s.StatusName, s.PunchCount
            FROM warroom.PunchDashboardSnapshotSubcontractor s
            WHERE s.SnapshotRunId = @SnapshotRunId
              AND s.PunchCount > 0
            ORDER BY s.PunchCount DESC, s.SubcontractorName, s.DisciplineCode, s.CategoryOrder, s.StatusOrder
        ),
        InsightRows AS
        (
            SELECT
                InsightId = 1,
                Priority = CASE WHEN o.Delta > 0 THEN 1 WHEN o.Delta < 0 THEN 3 ELSE 8 END,
                Severity = CASE WHEN o.Delta > 0 THEN N'CRITICAL' WHEN o.Delta < 0 THEN N'SUCCESS' ELSE N'INFO' END,
                InsightType = N'OPEN_TREND',
                Title = CASE WHEN o.Delta > 0 THEN N'Open punches are increasing'
                             WHEN o.Delta < 0 THEN N'Open punch backlog is reducing'
                             ELSE N'Open punch backlog is stable' END,
                [Message] = N'Latest snapshot contains ' + FORMAT(o.CurrentCount, 'N0', 'en-US') +
                    N' open punches; change versus the previous snapshot: ' +
                    CASE WHEN o.Delta > 0 THEN N'+' ELSE N'' END + FORMAT(o.Delta, 'N0', 'en-US') + N'.',
                MetricValue = CONVERT(DECIMAL(18,2), o.DeltaPercent),
                MetricLabel = N'%',
                StatusCode = o.StatusCode,
                CategoryCode = CONVERT(NVARCHAR(100), N''),
                SubsystemCode = CONVERT(NVARCHAR(100), N''),
                SubcontractorId = CONVERT(BIGINT, -1),
                DisciplineCode = CONVERT(NVARCHAR(100), N'')
            FROM OpenTrend o

            UNION ALL

            SELECT
                2, 2, N'WARNING', N'HOTSPOT',
                N'Largest category/status hotspot',
                COALESCE(h.CategoryName, h.CategoryCode) + N' / ' + COALESCE(h.StatusName, h.StatusCode) +
                    N' is the largest matrix cell with ' + FORMAT(h.PunchCount, 'N0', 'en-US') + N' punches.',
                CONVERT(DECIMAL(18,2), h.PunchCount), N'punches', h.StatusCode, h.CategoryCode, N'', -1, N''
            FROM TopHotspot h

            UNION ALL

            SELECT
                3, 4, N'WARNING', N'SUBSYSTEM',
                N'Highest-volume TOP Code',
                COALESCE(s.SubsystemCode, N'Unassigned') + N' carries ' + FORMAT(s.PunchCount, 'N0', 'en-US') +
                    N' punches in ' + COALESCE(s.CategoryName, s.CategoryCode) + N' / ' + COALESCE(s.StatusName, s.StatusCode) + N'.',
                CONVERT(DECIMAL(18,2), s.PunchCount), N'punches', s.StatusCode, s.CategoryCode, s.SubsystemCode, -1, N''
            FROM TopSubsystem s

            UNION ALL

            SELECT
                4, 5, N'INFO', N'SUBCONTRACTOR',
                N'Highest subcontractor workload',
                COALESCE(NULLIF(s.SubcontractorName, N''), N'Unassigned') + N' has the largest visible workload with ' +
                    FORMAT(s.PunchCount, 'N0', 'en-US') + N' punches.',
                CONVERT(DECIMAL(18,2), s.PunchCount), N'punches', s.StatusCode, s.CategoryCode, N'',
                COALESCE(s.SubcontractorId, -1), COALESCE(s.DisciplineCode, N'')
            FROM TopSubcontractor s

            UNION ALL

            SELECT
                5, CASE WHEN c.Delta > 0 THEN 3 ELSE 7 END,
                CASE WHEN c.Delta > 0 THEN N'SUCCESS' ELSE N'INFO' END, N'CLOSED_TREND',
                CASE WHEN c.Delta > 0 THEN N'Closure output improved' ELSE N'Closure output is stable' END,
                N'Closed punches changed by ' + CASE WHEN c.Delta > 0 THEN N'+' ELSE N'' END +
                    FORMAT(c.Delta, 'N0', 'en-US') + N' versus the previous snapshot.',
                CONVERT(DECIMAL(18,2), c.DeltaPercent), N'%', c.StatusCode, N'', N'', -1, N''
            FROM ClosedTrend c
        )
        SELECT @Insights =
        (
            SELECT TOP (5)
                InsightId, Priority, Severity, InsightType, Title, [Message],
                MetricValue, MetricLabel, StatusCode, CategoryCode, SubsystemCode,
                SubcontractorId, DisciplineCode
            FROM InsightRows
            ORDER BY Priority, InsightId
            FOR JSON PATH
        );
    END;

    IF @SnapshotRunId IS NOT NULL
    BEGIN
        /* EPIC 05 bounded executive subset; returned in the existing Bundle. */
        ;WITH ExecutivePunches AS
        (
            SELECT
                PunchId = CONVERT(BIGINT, p.Id), PunchCode = p.Code,
                PunchDescription = p.[Description], p.StatusCode,
                PunchStatus = p.[Status], p.CategoryCode, CategoryName = p.Category,
                SubsystemCode = COALESCE(NULLIF(LTRIM(RTRIM(h.SubsystemCode)), N''), N'NO SUBSYSTEM'),
                DisciplineCode = p.Discipline,
                ResponsibleCompany = COALESCE(NULLIF(mc.DS_SHORT_COMPANY, N''), NULLIF(mc.DS_COMPANY, N''), N'Unassigned'),
                ResponsiblePerson = COALESCE(NULLIF(p.PunchCoordinator, N''), N'Unassigned'),
                DueDate = p.ClosingDate,
                PriorityCode = COALESCE(NULLIF(p.EntryType, N''), N'Normal'),
                PriorityColor = COALESCE(NULLIF(p.EntryTypeColor, N''), N'#64748B'),
                DuplicateOrder = ROW_NUMBER() OVER (PARTITION BY p.Id ORDER BY h.SubsystemCode, h.ItemCode)
            FROM dbo.wap_PunchPaged p
            INNER JOIN dbo.wap_ElementHierarchyPunchView h
                ON h.ProjectId = p.ProjectId AND h.PunchId = p.Id
            LEFT JOIN dbo.DIM_MASTER_COMPANIES_LH mc
                ON mc.ID_COMPANY = TRY_CONVERT(INT, p.SubcontractorId)
            WHERE p.ProjectId = @ProjectId AND p.TemplateID = @TemplateId
              AND NULLIF(LTRIM(RTRIM(p.StatusCode)), N'') IS NOT NULL
              AND UPPER(LTRIM(RTRIM(p.StatusCode))) NOT IN (N'HOLD', N'VOID')
        )
        SELECT @Punches =
        (
            SELECT TOP (100)
                PunchId, PunchCode, PunchDescription, StatusCode, PunchStatus,
                CategoryCode, CategoryName, SubsystemCode, DisciplineCode,
                ResponsibleCompany, ResponsiblePerson, DueDate, PriorityCode,
                PriorityColor,
                SourceOrder = ROW_NUMBER() OVER (ORDER BY CASE WHEN DueDate IS NULL THEN 1 ELSE 0 END, DueDate, PunchId)
            FROM ExecutivePunches WHERE DuplicateOrder = 1
            ORDER BY CASE WHEN DueDate IS NULL THEN 1 ELSE 0 END, DueDate, PunchId
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
            kpis = JSON_QUERY(COALESCE(@Summary, N'[]')),
            distribution = JSON_QUERY(COALESCE(@Summary, N'[]')),
            detail = JSON_QUERY(COALESCE(@SnapshotInfo, N'[]')),
            snapshotInfo = JSON_QUERY(COALESCE(@SnapshotInfo, N'[]')),
            summary = JSON_QUERY(COALESCE(@Summary, N'[]')),
            matrix = JSON_QUERY(COALESCE(@Matrix, N'[]')),
            timeline = JSON_QUERY(COALESCE(@Timeline, N'[]')),
            insights = JSON_QUERY(COALESCE(@Insights, N'[]')),
            subsystems = JSON_QUERY(COALESCE(@Subsystems, N'[]')),
            subcontractors = JSON_QUERY(COALESCE(@Subcontractors, N'[]')),
            punches = JSON_QUERY(COALESCE(@Punches, N'[]')),
            contractVersion = N'4.0'
        FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
    );

    SELECT result = @Result;
END;
