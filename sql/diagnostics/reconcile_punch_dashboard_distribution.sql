/*
    RC1-01 read-only diagnostic

    Supply @ProjectId and @TemplateId before execution.
    @SnapshotRunId may remain NULL to select the latest completed run.

    This script contains only metadata/session statements and SELECT queries.
    It does not change data or schema.
*/

SET NOCOUNT ON;

DECLARE @ProjectId BIGINT = NULL;
DECLARE @TemplateId BIGINT = NULL;
DECLARE @SnapshotRunId BIGINT = NULL;

IF @ProjectId IS NULL OR @ProjectId <= 0
    THROW 51001, 'Set @ProjectId to a positive value.', 1;

IF @TemplateId IS NULL OR @TemplateId <= 0
    THROW 51002, 'Set @TemplateId to a positive value.', 1;

IF @SnapshotRunId IS NULL
BEGIN
    SELECT TOP (1)
        @SnapshotRunId = r.SnapshotRunId
    FROM warroom.PunchDashboardSnapshotRun r
    WHERE r.ProjectId = @ProjectId
      AND r.TemplateId = @TemplateId
      AND r.Status = 'COMPLETED'
    ORDER BY r.SnapshotRunId DESC;
END;

IF @SnapshotRunId IS NULL
    THROW 51003, 'No completed snapshot exists for the supplied ProjectId and TemplateId.', 1;

IF NOT EXISTS
(
    SELECT 1
    FROM warroom.PunchDashboardSnapshotRun r
    WHERE r.SnapshotRunId = @SnapshotRunId
      AND r.ProjectId = @ProjectId
      AND r.TemplateId = @TemplateId
      AND r.Status = 'COMPLETED'
)
    THROW 51004, 'SnapshotRunId does not belong to the supplied completed ProjectId/TemplateId context.', 1;

/* 1. Snapshot identity and configuration coverage. */
SELECT
    Diagnostic = '01_SNAPSHOT_AND_CONFIG',
    r.SnapshotRunId,
    r.ProjectId,
    r.TemplateId,
    r.Status,
    r.RequestedOn,
    r.StartedOn,
    r.CompletedOn,
    r.SourcePunchCount,
    r.DurationMs,
    IncludedStatusCount =
    (
        SELECT COUNT_BIG(1)
        FROM warroom.PunchReportStatusConfig sc
        WHERE sc.ProjectId = @ProjectId
          AND sc.IsActive = 1
          AND sc.IsIncluded = 1
          AND NULLIF(LTRIM(RTRIM(sc.StatusCode)), '') IS NOT NULL
    ),
    ActiveCategoryCount =
    (
        SELECT COUNT_BIG(1)
        FROM dbo.wap_Category c
        WHERE c.TemplateId = @TemplateId
          AND c.IsActive = 1
    )
FROM warroom.PunchDashboardSnapshotRun r
WHERE r.SnapshotRunId = @SnapshotRunId;

/* 2. Base Punch population at raw, eligible and distinct-Punch grains. */
WITH RawBase AS
(
    SELECT
        p.Id,
        p.Code,
        p.ProjectId,
        p.TemplateID,
        p.CategoryCode,
        p.StatusCode,
        p.SubSystemCode,
        p.SubSystemDesc,
        p.LastModifiedAt,
        StatusIsIncluded =
            CASE WHEN EXISTS
            (
                SELECT 1
                FROM warroom.PunchReportStatusConfig sc
                WHERE sc.ProjectId = @ProjectId
                  AND sc.IsActive = 1
                  AND sc.IsIncluded = 1
                  AND UPPER(LTRIM(RTRIM(sc.StatusCode)))
                    = UPPER(LTRIM(RTRIM(p.StatusCode)))
            ) THEN 1 ELSE 0 END,
        CategoryIsActive =
            CASE WHEN EXISTS
            (
                SELECT 1
                FROM dbo.wap_Category c
                WHERE c.TemplateId = @TemplateId
                  AND c.IsActive = 1
                  AND UPPER(COALESCE(NULLIF(LTRIM(RTRIM(c.Code)), ''), 'NO_CATEGORY'))
                    = UPPER(COALESCE(NULLIF(LTRIM(RTRIM(p.CategoryCode)), ''), 'NO_CATEGORY'))
            ) THEN 1 ELSE 0 END
    FROM dbo.wap_PunchPaged p
    WHERE p.ProjectId = @ProjectId
      AND p.TemplateID = @TemplateId
),
Eligible AS
(
    SELECT
        *,
        rn = ROW_NUMBER() OVER
        (
            PARTITION BY Id
            ORDER BY LastModifiedAt DESC, Id DESC
        )
    FROM RawBase
    WHERE NULLIF(LTRIM(RTRIM(StatusCode)), '') IS NOT NULL
      AND StatusIsIncluded = 1
      AND CategoryIsActive = 1
)
SELECT
    Diagnostic = '02_BASE_POPULATION',
    RawRows = (SELECT COUNT_BIG(1) FROM RawBase),
    RawDistinctPunchIds = (SELECT CONVERT(BIGINT, COUNT(DISTINCT Id)) FROM RawBase),
    EligibleRowsBeforeDedup = (SELECT COUNT_BIG(1) FROM Eligible),
    EligibleDistinctPunchIds = (SELECT COUNT_BIG(1) FROM Eligible WHERE rn = 1),
    ExcludedRows = (SELECT COUNT_BIG(1) FROM RawBase WHERE NULLIF(LTRIM(RTRIM(StatusCode)), '') IS NULL OR StatusIsIncluded = 0 OR CategoryIsActive = 0),
    UnmappedSubsystemPunches = (SELECT COUNT_BIG(1) FROM Eligible WHERE rn = 1 AND NULLIF(LTRIM(RTRIM(SubSystemCode)), '') IS NULL);

/* 3. Aggregate populations and total Punch counts. */
SELECT
    Diagnostic = '03_AGGREGATE_POPULATIONS',
    r.SourcePunchCount,
    CategoryStatusRows = (SELECT COUNT_BIG(1) FROM warroom.PunchDashboardSnapshotCategoryStatus x WHERE x.SnapshotRunId = @SnapshotRunId),
    CategoryStatusPunchCount = (SELECT COALESCE(SUM(x.PunchCount), 0) FROM warroom.PunchDashboardSnapshotCategoryStatus x WHERE x.SnapshotRunId = @SnapshotRunId),
    SubsystemRows = (SELECT COUNT_BIG(1) FROM warroom.PunchDashboardSnapshotSubsystem x WHERE x.SnapshotRunId = @SnapshotRunId),
    SubsystemPunchCount = (SELECT COALESCE(SUM(x.PunchCount), 0) FROM warroom.PunchDashboardSnapshotSubsystem x WHERE x.SnapshotRunId = @SnapshotRunId),
    CategoryStatusDistinctPunchIds = CONVERT(BIGINT, NULL),
    SubsystemDistinctPunchIds = CONVERT(BIGINT, NULL),
    DistinctIdLimitation = 'Aggregate tables do not contain PunchId'
FROM warroom.PunchDashboardSnapshotRun r
WHERE r.SnapshotRunId = @SnapshotRunId;

/* 4. Duplicate source Punch identifiers. */
SELECT
    Diagnostic = '04_DUPLICATE_PUNCH_IDS',
    p.Id AS PunchId,
    SourceRows = COUNT_BIG(1),
    DistinctCodes = CONVERT(BIGINT, COUNT(DISTINCT p.Code)),
    LatestModifiedOn = MAX(p.LastModifiedAt)
FROM dbo.wap_PunchPaged p
WHERE p.ProjectId = @ProjectId
  AND p.TemplateID = @TemplateId
GROUP BY p.Id
HAVING COUNT_BIG(1) > 1
ORDER BY SourceRows DESC, p.Id;

/* 5. Duplicate nonblank business codes across distinct Punch identifiers. */
SELECT
    Diagnostic = '05_DUPLICATE_BUSINESS_CODES',
    NormalizedPunchCode = UPPER(LTRIM(RTRIM(p.Code))),
    DistinctPunchIds = CONVERT(BIGINT, COUNT(DISTINCT p.Id)),
    SourceRows = COUNT_BIG(1)
FROM dbo.wap_PunchPaged p
WHERE p.ProjectId = @ProjectId
  AND p.TemplateID = @TemplateId
  AND NULLIF(LTRIM(RTRIM(p.Code)), '') IS NOT NULL
GROUP BY UPPER(LTRIM(RTRIM(p.Code)))
HAVING COUNT_BIG(DISTINCT p.Id) > 1
ORDER BY DistinctPunchIds DESC, NormalizedPunchCode;

/* 6. Excluded or unmapped Punches; reasons remain separate. */
WITH Classified AS
(
    SELECT
        p.Id AS PunchId,
        p.Code AS PunchCode,
        p.StatusCode,
        p.CategoryCode,
        p.SubSystemCode,
        StatusBlank = CASE WHEN NULLIF(LTRIM(RTRIM(p.StatusCode)), '') IS NULL THEN 1 ELSE 0 END,
        StatusExcluded = CASE WHEN NULLIF(LTRIM(RTRIM(p.StatusCode)), '') IS NOT NULL AND NOT EXISTS
        (
            SELECT 1
            FROM warroom.PunchReportStatusConfig sc
            WHERE sc.ProjectId = @ProjectId
              AND sc.IsActive = 1
              AND sc.IsIncluded = 1
              AND UPPER(LTRIM(RTRIM(sc.StatusCode))) = UPPER(LTRIM(RTRIM(p.StatusCode)))
        ) THEN 1 ELSE 0 END,
        CategoryUnmapped = CASE WHEN NOT EXISTS
        (
            SELECT 1
            FROM dbo.wap_Category c
            WHERE c.TemplateId = @TemplateId
              AND c.IsActive = 1
              AND UPPER(COALESCE(NULLIF(LTRIM(RTRIM(c.Code)), ''), 'NO_CATEGORY'))
                = UPPER(COALESCE(NULLIF(LTRIM(RTRIM(p.CategoryCode)), ''), 'NO_CATEGORY'))
        ) THEN 1 ELSE 0 END,
        SubsystemUnmapped = CASE WHEN NULLIF(LTRIM(RTRIM(p.SubSystemCode)), '') IS NULL THEN 1 ELSE 0 END,
        rn = ROW_NUMBER() OVER (PARTITION BY p.Id ORDER BY p.LastModifiedAt DESC, p.Id DESC)
    FROM dbo.wap_PunchPaged p
    WHERE p.ProjectId = @ProjectId
      AND p.TemplateID = @TemplateId
)
SELECT
    Diagnostic = '06_EXCLUDED_OR_UNMAPPED_PUNCHES',
    PunchId,
    PunchCode,
    StatusCode,
    CategoryCode,
    SubSystemCode,
    StatusBlank,
    StatusExcluded,
    CategoryUnmapped,
    SubsystemUnmapped
FROM Classified
WHERE rn = 1
  AND (StatusBlank = 1 OR StatusExcluded = 1 OR CategoryUnmapped = 1 OR SubsystemUnmapped = 1)
ORDER BY PunchId;

/* 7. NULL and blank dimensions in source and both aggregate tables. */
SELECT
    Diagnostic = '07_NULL_AND_BLANK_DIMENSIONS',
    DatasetName,
    DimensionName,
    NullRows,
    BlankRows
FROM
(
    SELECT 'BASE', 'StatusCode', SUM(CASE WHEN p.StatusCode IS NULL THEN 1 ELSE 0 END), SUM(CASE WHEN p.StatusCode IS NOT NULL AND LTRIM(RTRIM(p.StatusCode)) = '' THEN 1 ELSE 0 END) FROM dbo.wap_PunchPaged p WHERE p.ProjectId = @ProjectId AND p.TemplateID = @TemplateId
    UNION ALL
    SELECT 'BASE', 'CategoryCode', SUM(CASE WHEN p.CategoryCode IS NULL THEN 1 ELSE 0 END), SUM(CASE WHEN p.CategoryCode IS NOT NULL AND LTRIM(RTRIM(p.CategoryCode)) = '' THEN 1 ELSE 0 END) FROM dbo.wap_PunchPaged p WHERE p.ProjectId = @ProjectId AND p.TemplateID = @TemplateId
    UNION ALL
    SELECT 'BASE', 'SubsystemCode', SUM(CASE WHEN p.SubSystemCode IS NULL THEN 1 ELSE 0 END), SUM(CASE WHEN p.SubSystemCode IS NOT NULL AND LTRIM(RTRIM(p.SubSystemCode)) = '' THEN 1 ELSE 0 END) FROM dbo.wap_PunchPaged p WHERE p.ProjectId = @ProjectId AND p.TemplateID = @TemplateId
    UNION ALL
    SELECT 'CATEGORY_STATUS', 'StatusCode', SUM(CASE WHEN x.StatusCode IS NULL THEN 1 ELSE 0 END), SUM(CASE WHEN x.StatusCode IS NOT NULL AND LTRIM(RTRIM(x.StatusCode)) = '' THEN 1 ELSE 0 END) FROM warroom.PunchDashboardSnapshotCategoryStatus x WHERE x.SnapshotRunId = @SnapshotRunId
    UNION ALL
    SELECT 'CATEGORY_STATUS', 'CategoryCode', SUM(CASE WHEN x.CategoryCode IS NULL THEN 1 ELSE 0 END), SUM(CASE WHEN x.CategoryCode IS NOT NULL AND LTRIM(RTRIM(x.CategoryCode)) = '' THEN 1 ELSE 0 END) FROM warroom.PunchDashboardSnapshotCategoryStatus x WHERE x.SnapshotRunId = @SnapshotRunId
    UNION ALL
    SELECT 'SUBSYSTEM', 'StatusCode', SUM(CASE WHEN x.StatusCode IS NULL THEN 1 ELSE 0 END), SUM(CASE WHEN x.StatusCode IS NOT NULL AND LTRIM(RTRIM(x.StatusCode)) = '' THEN 1 ELSE 0 END) FROM warroom.PunchDashboardSnapshotSubsystem x WHERE x.SnapshotRunId = @SnapshotRunId
    UNION ALL
    SELECT 'SUBSYSTEM', 'CategoryCode', SUM(CASE WHEN x.CategoryCode IS NULL THEN 1 ELSE 0 END), SUM(CASE WHEN x.CategoryCode IS NOT NULL AND LTRIM(RTRIM(x.CategoryCode)) = '' THEN 1 ELSE 0 END) FROM warroom.PunchDashboardSnapshotSubsystem x WHERE x.SnapshotRunId = @SnapshotRunId
    UNION ALL
    SELECT 'SUBSYSTEM', 'SubsystemCode', SUM(CASE WHEN x.SubsystemCode IS NULL THEN 1 ELSE 0 END), SUM(CASE WHEN x.SubsystemCode IS NOT NULL AND LTRIM(RTRIM(x.SubsystemCode)) = '' THEN 1 ELSE 0 END) FROM warroom.PunchDashboardSnapshotSubsystem x WHERE x.SnapshotRunId = @SnapshotRunId
) d(DatasetName, DimensionName, NullRows, BlankRows)
ORDER BY DatasetName, DimensionName;

/* 8. Zero or negative aggregate rows; no synthetic normalization. */
SELECT
    Diagnostic = '08_ZERO_OR_NEGATIVE_AGGREGATES',
    DatasetName,
    CategoryCode,
    SubsystemCode,
    StatusCode,
    PunchCount
FROM
(
    SELECT 'CATEGORY_STATUS', x.CategoryCode, CONVERT(VARCHAR(255), NULL), x.StatusCode, x.PunchCount
    FROM warroom.PunchDashboardSnapshotCategoryStatus x
    WHERE x.SnapshotRunId = @SnapshotRunId AND x.PunchCount <= 0
    UNION ALL
    SELECT 'SUBSYSTEM', x.CategoryCode, x.SubsystemCode, x.StatusCode, x.PunchCount
    FROM warroom.PunchDashboardSnapshotSubsystem x
    WHERE x.SnapshotRunId = @SnapshotRunId AND x.PunchCount <= 0
) z;

/* 9. Counts by status: base eligible distinct Punches versus A and B. */
WITH BaseStatus AS
(
    SELECT StatusCode, PunchCount = COUNT_BIG(1)
    FROM
    (
        SELECT
            StatusCode = UPPER(LTRIM(RTRIM(p.StatusCode))),
            rn = ROW_NUMBER() OVER (PARTITION BY p.Id ORDER BY p.LastModifiedAt DESC, p.Id DESC)
        FROM dbo.wap_PunchPaged p
        INNER JOIN warroom.PunchReportStatusConfig sc
            ON sc.ProjectId = @ProjectId
           AND sc.IsActive = 1
           AND sc.IsIncluded = 1
           AND UPPER(LTRIM(RTRIM(sc.StatusCode))) = UPPER(LTRIM(RTRIM(p.StatusCode)))
        INNER JOIN dbo.wap_Category c
            ON c.TemplateId = @TemplateId
           AND c.IsActive = 1
           AND UPPER(COALESCE(NULLIF(LTRIM(RTRIM(c.Code)), ''), 'NO_CATEGORY'))
             = UPPER(COALESCE(NULLIF(LTRIM(RTRIM(p.CategoryCode)), ''), 'NO_CATEGORY'))
        WHERE p.ProjectId = @ProjectId AND p.TemplateID = @TemplateId
    ) q
    WHERE rn = 1
    GROUP BY StatusCode
),
A AS
(
    SELECT StatusCode, PunchCount = SUM(PunchCount)
    FROM warroom.PunchDashboardSnapshotCategoryStatus
    WHERE SnapshotRunId = @SnapshotRunId
    GROUP BY StatusCode
),
B AS
(
    SELECT StatusCode, PunchCount = SUM(PunchCount)
    FROM warroom.PunchDashboardSnapshotSubsystem
    WHERE SnapshotRunId = @SnapshotRunId
    GROUP BY StatusCode
),
Keys AS
(
    SELECT StatusCode FROM BaseStatus
    UNION SELECT StatusCode FROM A
    UNION SELECT StatusCode FROM B
)
SELECT
    Diagnostic = '09_COUNTS_BY_STATUS',
    k.StatusCode,
    BasePunchCount = bs.PunchCount,
    DistributionPunchCount = a.PunchCount,
    SubsystemDerivedPunchCount = b.PunchCount,
    DistributionMinusBase = COALESCE(a.PunchCount, 0) - COALESCE(bs.PunchCount, 0),
    SubsystemMinusBase = COALESCE(b.PunchCount, 0) - COALESCE(bs.PunchCount, 0),
    SubsystemMinusDistribution = COALESCE(b.PunchCount, 0) - COALESCE(a.PunchCount, 0)
FROM Keys k
LEFT JOIN BaseStatus bs ON bs.StatusCode = k.StatusCode OR (bs.StatusCode IS NULL AND k.StatusCode IS NULL)
LEFT JOIN A a ON a.StatusCode = k.StatusCode OR (a.StatusCode IS NULL AND k.StatusCode IS NULL)
LEFT JOIN B b ON b.StatusCode = k.StatusCode OR (b.StatusCode IS NULL AND k.StatusCode IS NULL)
ORDER BY k.StatusCode;

/* 10. Counts by category: base versus A and subsystem roll-up. */
WITH BaseCategory AS
(
    SELECT CategoryCode, PunchCount = COUNT_BIG(1)
    FROM
    (
        SELECT
            CategoryCode = UPPER(COALESCE(NULLIF(LTRIM(RTRIM(p.CategoryCode)), ''), 'NO_CATEGORY')),
            rn = ROW_NUMBER() OVER (PARTITION BY p.Id ORDER BY p.LastModifiedAt DESC, p.Id DESC)
        FROM dbo.wap_PunchPaged p
        INNER JOIN warroom.PunchReportStatusConfig sc
            ON sc.ProjectId = @ProjectId AND sc.IsActive = 1 AND sc.IsIncluded = 1
           AND UPPER(LTRIM(RTRIM(sc.StatusCode))) = UPPER(LTRIM(RTRIM(p.StatusCode)))
        INNER JOIN dbo.wap_Category c
            ON c.TemplateId = @TemplateId AND c.IsActive = 1
           AND UPPER(COALESCE(NULLIF(LTRIM(RTRIM(c.Code)), ''), 'NO_CATEGORY'))
             = UPPER(COALESCE(NULLIF(LTRIM(RTRIM(p.CategoryCode)), ''), 'NO_CATEGORY'))
        WHERE p.ProjectId = @ProjectId AND p.TemplateID = @TemplateId
    ) q
    WHERE rn = 1
    GROUP BY CategoryCode
),
A AS
(
    SELECT CategoryCode, PunchCount = SUM(PunchCount)
    FROM warroom.PunchDashboardSnapshotCategoryStatus
    WHERE SnapshotRunId = @SnapshotRunId
    GROUP BY CategoryCode
),
B AS
(
    SELECT CategoryCode, PunchCount = SUM(PunchCount)
    FROM warroom.PunchDashboardSnapshotSubsystem
    WHERE SnapshotRunId = @SnapshotRunId
    GROUP BY CategoryCode
),
Keys AS
(
    SELECT CategoryCode FROM BaseCategory
    UNION SELECT CategoryCode FROM A
    UNION SELECT CategoryCode FROM B
)
SELECT
    Diagnostic = '10_COUNTS_BY_CATEGORY',
    k.CategoryCode,
    BasePunchCount = bc.PunchCount,
    DistributionPunchCount = a.PunchCount,
    SubsystemDerivedPunchCount = b.PunchCount,
    DistributionMinusBase = COALESCE(a.PunchCount, 0) - COALESCE(bc.PunchCount, 0),
    SubsystemMinusBase = COALESCE(b.PunchCount, 0) - COALESCE(bc.PunchCount, 0),
    SubsystemMinusDistribution = COALESCE(b.PunchCount, 0) - COALESCE(a.PunchCount, 0)
FROM Keys k
LEFT JOIN BaseCategory bc ON bc.CategoryCode = k.CategoryCode OR (bc.CategoryCode IS NULL AND k.CategoryCode IS NULL)
LEFT JOIN A a ON a.CategoryCode = k.CategoryCode OR (a.CategoryCode IS NULL AND k.CategoryCode IS NULL)
LEFT JOIN B b ON b.CategoryCode = k.CategoryCode OR (b.CategoryCode IS NULL AND k.CategoryCode IS NULL)
ORDER BY k.CategoryCode;

/* 11. Counts by subsystem and source unmapped normalization. */
WITH BaseSubsystem AS
(
    SELECT
        SubsystemCode,
        PunchCount = COUNT_BIG(1)
    FROM
    (
        SELECT
            SubsystemCode = UPPER(COALESCE(NULLIF(LTRIM(RTRIM(p.SubSystemCode)), ''), 'NO_SUBSYSTEM')),
            rn = ROW_NUMBER() OVER (PARTITION BY p.Id ORDER BY p.LastModifiedAt DESC, p.Id DESC)
        FROM dbo.wap_PunchPaged p
        INNER JOIN warroom.PunchReportStatusConfig sc
            ON sc.ProjectId = @ProjectId AND sc.IsActive = 1 AND sc.IsIncluded = 1
           AND UPPER(LTRIM(RTRIM(sc.StatusCode))) = UPPER(LTRIM(RTRIM(p.StatusCode)))
        INNER JOIN dbo.wap_Category c
            ON c.TemplateId = @TemplateId AND c.IsActive = 1
           AND UPPER(COALESCE(NULLIF(LTRIM(RTRIM(c.Code)), ''), 'NO_CATEGORY'))
             = UPPER(COALESCE(NULLIF(LTRIM(RTRIM(p.CategoryCode)), ''), 'NO_CATEGORY'))
        WHERE p.ProjectId = @ProjectId AND p.TemplateID = @TemplateId
    ) q
    WHERE rn = 1
    GROUP BY SubsystemCode
),
B AS
(
    SELECT SubsystemCode, PunchCount = SUM(PunchCount)
    FROM warroom.PunchDashboardSnapshotSubsystem
    WHERE SnapshotRunId = @SnapshotRunId
    GROUP BY SubsystemCode
),
Keys AS
(
    SELECT SubsystemCode FROM BaseSubsystem
    UNION SELECT SubsystemCode FROM B
)
SELECT
    Diagnostic = '11_COUNTS_BY_SUBSYSTEM',
    k.SubsystemCode,
    BaseDistinctPunchCount = bs.PunchCount,
    SnapshotPunchCount = b.PunchCount,
    Delta = COALESCE(b.PunchCount, 0) - COALESCE(bs.PunchCount, 0)
FROM Keys k
LEFT JOIN BaseSubsystem bs ON bs.SubsystemCode = k.SubsystemCode
LEFT JOIN B b ON b.SubsystemCode = k.SubsystemCode
ORDER BY k.SubsystemCode;

/* 12. Exact distribution versus subsystem-derived distribution differences. */
WITH A AS
(
    SELECT
        StatusCode,
        StatusNameMin = MIN(StatusName),
        StatusNameMax = MAX(StatusName),
        StatusOrderMin = MIN(StatusOrder),
        StatusOrderMax = MAX(StatusOrder),
        StatusColorMin = MIN(StatusColor),
        StatusColorMax = MAX(StatusColor),
        PunchCount = SUM(PunchCount)
    FROM warroom.PunchDashboardSnapshotCategoryStatus
    WHERE SnapshotRunId = @SnapshotRunId
    GROUP BY StatusCode
),
B AS
(
    SELECT
        StatusCode,
        StatusNameMin = MIN(StatusName),
        StatusNameMax = MAX(StatusName),
        StatusOrderMin = MIN(StatusOrder),
        StatusOrderMax = MAX(StatusOrder),
        StatusColorMin = MIN(StatusColor),
        StatusColorMax = MAX(StatusColor),
        PunchCount = SUM(PunchCount)
    FROM warroom.PunchDashboardSnapshotSubsystem
    WHERE SnapshotRunId = @SnapshotRunId
    GROUP BY StatusCode
),
Keys AS
(
    SELECT StatusCode FROM A
    UNION SELECT StatusCode FROM B
)
SELECT
    Diagnostic = '12_DISTRIBUTION_DIFFERENCES',
    k.StatusCode,
    DistributionPunchCount = a.PunchCount,
    SubsystemDerivedPunchCount = b.PunchCount,
    PunchCountDelta = COALESCE(b.PunchCount, 0) - COALESCE(a.PunchCount, 0),
    DistributionPercent = CONVERT(DECIMAL(18,6), 100.0 * COALESCE(a.PunchCount, 0) / NULLIF(SUM(COALESCE(a.PunchCount, 0)) OVER (), 0)),
    SubsystemDerivedPercent = CONVERT(DECIMAL(18,6), 100.0 * COALESCE(b.PunchCount, 0) / NULLIF(SUM(COALESCE(b.PunchCount, 0)) OVER (), 0)),
    StatusNameMismatch = CASE WHEN COALESCE(a.StatusNameMin, '') <> COALESCE(b.StatusNameMin, '') OR COALESCE(a.StatusNameMax, '') <> COALESCE(b.StatusNameMax, '') THEN 1 ELSE 0 END,
    StatusOrderMismatch = CASE WHEN COALESCE(a.StatusOrderMin, -2147483648) <> COALESCE(b.StatusOrderMin, -2147483648) OR COALESCE(a.StatusOrderMax, -2147483648) <> COALESCE(b.StatusOrderMax, -2147483648) THEN 1 ELSE 0 END,
    StatusColorMismatch = CASE WHEN COALESCE(a.StatusColorMin, '') <> COALESCE(b.StatusColorMin, '') OR COALESCE(a.StatusColorMax, '') <> COALESCE(b.StatusColorMax, '') THEN 1 ELSE 0 END
FROM Keys k
LEFT JOIN A a ON a.StatusCode = k.StatusCode OR (a.StatusCode IS NULL AND k.StatusCode IS NULL)
LEFT JOIN B b ON b.StatusCode = k.StatusCode OR (b.StatusCode IS NULL AND k.StatusCode IS NULL)
WHERE COALESCE(a.PunchCount, 0) <> COALESCE(b.PunchCount, 0)
   OR COALESCE(a.StatusNameMin, '') <> COALESCE(b.StatusNameMin, '')
   OR COALESCE(a.StatusNameMax, '') <> COALESCE(b.StatusNameMax, '')
   OR COALESCE(a.StatusOrderMin, -2147483648) <> COALESCE(b.StatusOrderMin, -2147483648)
   OR COALESCE(a.StatusOrderMax, -2147483648) <> COALESCE(b.StatusOrderMax, -2147483648)
   OR COALESCE(a.StatusColorMin, '') <> COALESCE(b.StatusColorMin, '')
   OR COALESCE(a.StatusColorMax, '') <> COALESCE(b.StatusColorMax, '')
ORDER BY k.StatusCode;

/* 13. Duplicate aggregate business keys, independently of physical constraints. */
SELECT
    Diagnostic = '13_DUPLICATE_AGGREGATE_KEYS',
    DatasetName,
    BusinessKey,
    DuplicateRows
FROM
(
    SELECT
        DatasetName = 'CATEGORY_STATUS',
        BusinessKey = CONCAT(COALESCE(CategoryCode, '<NULL>'), '|', COALESCE(StatusCode, '<NULL>')),
        DuplicateRows = COUNT_BIG(1)
    FROM warroom.PunchDashboardSnapshotCategoryStatus
    WHERE SnapshotRunId = @SnapshotRunId
    GROUP BY CategoryCode, StatusCode
    HAVING COUNT_BIG(1) > 1

    UNION ALL

    SELECT
        'SUBSYSTEM',
        CONCAT(COALESCE(SubsystemCode, '<NULL>'), '|', COALESCE(CategoryCode, '<NULL>'), '|', COALESCE(StatusCode, '<NULL>')),
        COUNT_BIG(1)
    FROM warroom.PunchDashboardSnapshotSubsystem
    WHERE SnapshotRunId = @SnapshotRunId
    GROUP BY SubsystemCode, CategoryCode, StatusCode
    HAVING COUNT_BIG(1) > 1
) d;
