/****** Object:  StoredProcedure [warroom].[usp_GetLatestPunchDashboardSnapshot]    Script Date: 7/31/2026 5:27:48 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/* ============================================================
   8. SP PARA LEER EL ÚLTIMO SNAPSHOT VÁLIDO
   ============================================================ */

CREATE OR ALTER PROCEDURE [warroom].[usp_GetLatestPunchDashboardSnapshot]
(
    @ProjectId   BIGINT,
    @TemplateId  BIGINT
)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @SnapshotRunId BIGINT;

    SELECT TOP (1)
        @SnapshotRunId = r.SnapshotRunId
    FROM warroom.PunchDashboardSnapshotRun r
    WHERE r.ProjectId = @ProjectId
      AND r.TemplateId = @TemplateId
      AND r.Status = 'COMPLETED'
    ORDER BY r.SnapshotRunId DESC;

    SELECT
        SnapshotRunId      = r.SnapshotRunId,
        ProjectId          = r.ProjectId,
        TemplateId         = r.TemplateId,
        SnapshotStatus     = r.Status,
        RequestedOn        = r.RequestedOn,
        StartedOn          = r.StartedOn,
        CompletedOn        = r.CompletedOn,
        RequestedBy        = r.RequestedBy,
        SourcePunchCount   = r.SourcePunchCount,
        DurationMs         = r.DurationMs
    FROM warroom.PunchDashboardSnapshotRun r
    WHERE r.SnapshotRunId = @SnapshotRunId;

    SELECT
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
    FROM warroom.PunchDashboardSnapshotCategoryStatus
    WHERE SnapshotRunId = @SnapshotRunId
    ORDER BY CategoryOrder, CategoryCode, StatusOrder, StatusCode;

    SELECT
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
    FROM warroom.PunchDashboardSnapshotSubsystem
    WHERE SnapshotRunId = @SnapshotRunId
    ORDER BY SubsystemCode, CategoryOrder, CategoryCode, StatusOrder, StatusCode;

    SELECT
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
    FROM warroom.PunchDashboardSnapshotSubcontractor
    WHERE SnapshotRunId = @SnapshotRunId
    ORDER BY
        SubcontractorName,
        DisciplineCode,
        CategoryOrder,
        CategoryCode,
        StatusOrder,
        StatusCode;
END;
