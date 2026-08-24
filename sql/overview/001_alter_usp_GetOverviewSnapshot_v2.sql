SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO

/*
    OPDS-C02
    Extiende el contrato de lectura de Overview sin cambiar sus parámetros.

    Estados de negocio devueltos:
      NO_CONFIGURATION  No existe una configuración publicada.
      SNAPSHOT_REQUIRED Existe configuración publicada, pero no snapshot.
      NO_DATA           Existe snapshot, pero no hay cabeceras o subsistemas utilizables.
      READY             Existe snapshot con cabeceras y subsistemas utilizables.

    Rollback funcional:
      volver a ejecutar la versión anterior documentada en
      sql/schema/warroom/schema_warroom.csv.
*/
CREATE OR ALTER PROCEDURE [warroom].[usp_GetOverviewSnapshot]
(
    @ProjectId       BIGINT,
    @SearchSubsystem NVARCHAR(50) = NULL,
    @PageNumber      INT = 1,
    @PageSize        INT = 50
)
AS
BEGIN
    SET NOCOUNT ON;

    IF @PageNumber < 1 SET @PageNumber = 1;
    IF @PageSize   < 1 SET @PageSize   = 50;

    DECLARE @Search NVARCHAR(50) = NULLIF(LTRIM(RTRIM(@SearchSubsystem)), '');
    DECLARE @PublishedVersionId BIGINT = NULL;
    DECLARE @PublishedVersionNo INT = NULL;
    DECLARE @HasSnapshot BIT = 0;
    DECLARE @HasHeaders BIT = 0;
    DECLARE @TotalUnfilteredCount INT = 0;
    DECLARE @StatusCode NVARCHAR(50);

    SELECT TOP (1)
        @PublishedVersionId = VersionId,
        @PublishedVersionNo = VersionNo
    FROM warroom.ReportConfigVersion
    WHERE ProjectId = @ProjectId
      AND Status = N'Published'
    ORDER BY VersionNo DESC, VersionId DESC;

    SET @HasSnapshot = CASE WHEN EXISTS
    (
        SELECT 1
        FROM warroom.OverviewSnapshot
        WHERE ProjectId = @ProjectId
    ) THEN 1 ELSE 0 END;

    SET @HasHeaders = CASE WHEN EXISTS
    (
        SELECT 1
        FROM warroom.OverviewSnapshotHeader
        WHERE ProjectId = @ProjectId
    ) THEN 1 ELSE 0 END;

    SELECT @TotalUnfilteredCount = COUNT_BIG(1)
    FROM
    (
        SELECT DISTINCT SubsystemCode
        FROM warroom.OverviewSnapshotMetric
        WHERE ProjectId = @ProjectId
    ) AS AvailableSubsystems;

    SET @StatusCode =
        CASE
            WHEN @PublishedVersionId IS NULL THEN N'NO_CONFIGURATION'
            WHEN @HasSnapshot = 0 THEN N'SNAPSHOT_REQUIRED'
            WHEN @HasHeaders = 0 OR @TotalUnfilteredCount = 0 THEN N'NO_DATA'
            ELSE N'READY'
        END;

    ;WITH S AS
    (
        SELECT DISTINCT SubsystemCode
        FROM warroom.OverviewSnapshotMetric
        WHERE ProjectId = @ProjectId
          AND (@Search IS NULL OR SubsystemCode LIKE N'%' + @Search + N'%')
    ),
    N AS
    (
        SELECT
            SubsystemCode,
            RN = ROW_NUMBER() OVER (ORDER BY SubsystemCode)
        FROM S
    ),
    P AS
    (
        SELECT SubsystemCode
        FROM N
        WHERE RN BETWEEN ((@PageNumber - 1) * @PageSize + 1)
                    AND (@PageNumber * @PageSize)
    )
    SELECT
        StatusCode = @StatusCode,
        HasPublishedConfig = CAST(CASE WHEN @PublishedVersionId IS NULL THEN 0 ELSE 1 END AS BIT),
        PublishedVersionId = @PublishedVersionId,
        PublishedVersionNo = @PublishedVersionNo,
        HasSnapshot = @HasSnapshot,
        SubsystemsJson = ISNULL
        (
            (
                SELECT SubsystemCode
                FROM P
                ORDER BY SubsystemCode
                FOR JSON PATH
            ),
            '[]'
        ),
        HeadersJson = ISNULL
        (
            (
                SELECT
                    TemplateId,
                    L1NodeId,
                    L1Label,
                    L1SortOrder,
                    L2NodeId,
                    L2Label,
                    L2SortOrder,
                    L3NodeId,
                    L3Label,
                    L3SortOrder,
                    MetricKey,
                    MetricSqlKey,
                    MetricLabel,
                    MetricSortOrder
                FROM warroom.OverviewSnapshotHeader
                WHERE ProjectId = @ProjectId
                ORDER BY
                    L1SortOrder,
                    L1Label,
                    L2SortOrder,
                    L2Label,
                    L3SortOrder,
                    L3Label,
                    MetricSortOrder,
                    MetricKey
                FOR JSON PATH
            ),
            '[]'
        ),
        MetricsJson = ISNULL
        (
            (
                SELECT
                    m.SubsystemCode,
                    m.MetricKey,
                    m.MetricValue
                FROM warroom.OverviewSnapshotMetric AS m
                INNER JOIN P
                    ON P.SubsystemCode = m.SubsystemCode
                WHERE m.ProjectId = @ProjectId
                ORDER BY m.SubsystemCode, m.MetricKey
                FOR JSON PATH
            ),
            '[]'
        ),
        TotalCount =
        (
            SELECT COUNT(1)
            FROM S
        ),
        GeneratedOn =
        (
            SELECT GeneratedOn
            FROM warroom.OverviewSnapshot
            WHERE ProjectId = @ProjectId
        );
END;
GO

