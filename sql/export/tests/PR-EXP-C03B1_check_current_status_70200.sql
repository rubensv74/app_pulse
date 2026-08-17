/*
    PULSE — PR-EXP-C03B1 diagnostic
    Comprueba el estado ACTUAL de los 15 WorkItemId enviados por Punch Review.

    Solo lectura. No modifica datos.
*/

DECLARE @Requested TABLE
(
    WorkItemId BIGINT NOT NULL PRIMARY KEY
);

INSERT INTO @Requested (WorkItemId)
VALUES
    (70381),
    (653757),
    (653765),
    (653771),
    (724141),
    (760975),
    (835783),
    (967776),
    (967856),
    (1071084),
    (1071086),
    (1185186),
    (1202830),
    (1202843),
    (1267968);

SELECT
    r.WorkItemId,
    ExistsAsPunchId = CASE WHEN p.Id IS NULL THEN 0 ELSE 1 END,
    p.ProjectId,
    p.TemplateID AS TemplateId,
    p.Code AS PunchCode,
    p.StatusCode,
    p.[Status] AS StatusLabel,
    IsEligibleByCurrentExportRule =
        CASE
            WHEN p.Id IS NOT NULL
             AND p.ProjectId = 70200
             AND p.TemplateID = 20
             AND NULLIF(LTRIM(RTRIM(p.StatusCode)), '') IS NOT NULL
             AND UPPER(LTRIM(RTRIM(p.StatusCode))) NOT IN ('HOLD', 'VOID')
            THEN 1
            ELSE 0
        END
FROM @Requested r
LEFT JOIN dbo.wap_PunchPaged p
    ON p.Id = r.WorkItemId
ORDER BY r.WorkItemId;

SELECT
    TotalRequested = COUNT(1),
    FoundById = SUM(CASE WHEN p.Id IS NOT NULL THEN 1 ELSE 0 END),
    OpenCount = SUM(CASE WHEN UPPER(LTRIM(RTRIM(p.StatusCode))) = 'OPEN' THEN 1 ELSE 0 END),
    NonOpenButEligible = SUM
    (
        CASE
            WHEN p.Id IS NOT NULL
             AND UPPER(LTRIM(RTRIM(p.StatusCode))) <> 'OPEN'
             AND NULLIF(LTRIM(RTRIM(p.StatusCode)), '') IS NOT NULL
             AND UPPER(LTRIM(RTRIM(p.StatusCode))) NOT IN ('HOLD', 'VOID')
            THEN 1 ELSE 0
        END
    ),
    HoldOrVoid = SUM
    (
        CASE
            WHEN UPPER(LTRIM(RTRIM(p.StatusCode))) IN ('HOLD', 'VOID')
            THEN 1 ELSE 0
        END
    )
FROM @Requested r
LEFT JOIN dbo.wap_PunchPaged p
    ON p.Id = r.WorkItemId;
