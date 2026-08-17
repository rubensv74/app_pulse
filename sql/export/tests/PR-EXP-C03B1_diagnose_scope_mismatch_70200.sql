/*
    PULSE — PR-EXP-C03B1 DIAGNOSTIC
    Purpose: diagnose why the Review Queue payload resolves 0/15 in the
    SQL environment used for validation.

    READ ONLY. This script does not modify any data.

    Known Power Apps context from the validated Punch Review session:
      ProjectId  = 70200
      TemplateId = 20
      Queue size = 15
*/

SET NOCOUNT ON;

DECLARE @ProjectId  BIGINT = 70200;
DECLARE @TemplateId BIGINT = 20;

DECLARE @Requested TABLE
(
    Ordinal    INT    NOT NULL PRIMARY KEY,
    WorkItemId BIGINT NOT NULL UNIQUE
);

INSERT INTO @Requested (Ordinal, WorkItemId)
VALUES
    (1, 70381),
    (2, 653757),
    (3, 653765),
    (4, 653771),
    (5, 724141),
    (6, 760975),
    (7, 835783),
    (8, 967776),
    (9, 967856),
    (10, 1071084),
    (11, 1071086),
    (12, 1185186),
    (13, 1202830),
    (14, 1202843),
    (15, 1267968);

/* =====================================================================
   RESULT 1 — Environment fingerprint
   This is the first result to inspect. It proves which SQL server/database
   is actually being tested.
   ===================================================================== */
SELECT
    ServerName = CONVERT(NVARCHAR(256), SERVERPROPERTY('ServerName')),
    DatabaseName = DB_NAME(),
    LoginName = ORIGINAL_LOGIN(),
    CurrentUserName = USER_NAME(),
    TestedProjectId = @ProjectId,
    TestedTemplateId = @TemplateId,
    RequestedCount = (SELECT COUNT(*) FROM @Requested);

/* =====================================================================
   RESULT 2 — Project / template presence in this database
   ===================================================================== */
SELECT
    ProjectExists = CONVERT(BIT, CASE WHEN EXISTS
    (
        SELECT 1
        FROM dbo.Projects p
        WHERE p.Id = @ProjectId
    ) THEN 1 ELSE 0 END),

    TemplateExists = CONVERT(BIT, CASE WHEN EXISTS
    (
        SELECT 1
        FROM dbo.wap_Template t
        WHERE t.Id = @TemplateId
    ) THEN 1 ELSE 0 END),

    ProjectTemplateExists = CONVERT(BIT, CASE WHEN EXISTS
    (
        SELECT 1
        FROM dbo.wap_TemplateProject tp
        WHERE tp.ProjectId = @ProjectId
          AND tp.TemplateId = @TemplateId
    ) THEN 1 ELSE 0 END),

    PunchRowsForProjectTemplate =
    (
        SELECT COUNT_BIG(*)
        FROM dbo.wap_PunchPaged p
        WHERE p.ProjectId = @ProjectId
          AND p.TemplateID = @TemplateId
    );

/* =====================================================================
   RESULT 3 — Do the 15 requested values exist as wap_PunchPaged.Id?

   Important:
   - matching is deliberately NOT restricted by ProjectId/TemplateId here;
   - this reveals whether an ID exists but belongs to another context.
   ===================================================================== */
SELECT
    r.Ordinal,
    r.WorkItemId,
    FoundAsPunchId = CONVERT(BIT, CASE WHEN p.Id IS NULL THEN 0 ELSE 1 END),
    ActualProjectId = p.ProjectId,
    ActualTemplateId = p.TemplateID,
    PunchCode = p.Code,
    StatusCode = p.StatusCode,
    ContextMatches = CONVERT
    (
        BIT,
        CASE
            WHEN p.Id IS NOT NULL
             AND p.ProjectId = @ProjectId
             AND p.TemplateID = @TemplateId
            THEN 1
            ELSE 0
        END
    )
FROM @Requested r
LEFT JOIN dbo.wap_PunchPaged p
    ON CONVERT(BIGINT, p.Id) = r.WorkItemId
ORDER BY r.Ordinal;

/* =====================================================================
   RESULT 4 — Candidate identity check

   The repository currently treats wap_PunchPaged.Id as PunchId/WorkItemId.
   This probe checks whether the values accidentally correspond instead to
   PunchLogId or InspectionId in this database.
   ===================================================================== */
SELECT
    r.Ordinal,
    r.WorkItemId,
    MatchColumn = m.MatchColumn,
    ActualPunchId = m.PunchId,
    ActualProjectId = m.ProjectId,
    ActualTemplateId = m.TemplateId,
    PunchCode = m.PunchCode
FROM @Requested r
OUTER APPLY
(
    SELECT TOP (1)
        MatchColumn,
        PunchId,
        ProjectId,
        TemplateId,
        PunchCode
    FROM
    (
        SELECT
            MatchPriority = 1,
            MatchColumn = CONVERT(NVARCHAR(30), N'Id'),
            PunchId = CONVERT(BIGINT, p.Id),
            ProjectId = CONVERT(BIGINT, p.ProjectId),
            TemplateId = CONVERT(BIGINT, p.TemplateID),
            PunchCode = CONVERT(NVARCHAR(255), p.Code)
        FROM dbo.wap_PunchPaged p
        WHERE CONVERT(BIGINT, p.Id) = r.WorkItemId

        UNION ALL

        SELECT
            2,
            CONVERT(NVARCHAR(30), N'PunchLogId'),
            CONVERT(BIGINT, p.Id),
            CONVERT(BIGINT, p.ProjectId),
            CONVERT(BIGINT, p.TemplateID),
            CONVERT(NVARCHAR(255), p.Code)
        FROM dbo.wap_PunchPaged p
        WHERE TRY_CONVERT(BIGINT, p.PunchLogId) = r.WorkItemId

        UNION ALL

        SELECT
            3,
            CONVERT(NVARCHAR(30), N'InspectionId'),
            CONVERT(BIGINT, p.Id),
            CONVERT(BIGINT, p.ProjectId),
            CONVERT(BIGINT, p.TemplateID),
            CONVERT(NVARCHAR(255), p.Code)
        FROM dbo.wap_PunchPaged p
        WHERE TRY_CONVERT(BIGINT, p.InspectionId) = r.WorkItemId
    ) candidates
    ORDER BY MatchPriority
) m
ORDER BY r.Ordinal;

/* =====================================================================
   RESULT 5 — Stable-code probe using Punches visible in the supplied
   Punch Review screenshot. If these codes exist here with different Ids,
   that is strong evidence that Power Apps and this SSMS session are reading
   different data snapshots/environments.
   ===================================================================== */
DECLARE @VisibleCodes TABLE
(
    PunchCode NVARCHAR(255) NOT NULL PRIMARY KEY
);

INSERT INTO @VisibleCodes (PunchCode)
VALUES
    (N'MPL-000035'),
    (N'MPL-000868'),
    (N'MPL-000876'),
    (N'MPL-000882'),
    (N'MPL-001048'),
    (N'MPL-001125'),
    (N'MPL-001551');

SELECT
    vc.PunchCode AS RequestedVisibleCode,
    PunchId = CONVERT(BIGINT, p.Id),
    p.ProjectId,
    TemplateId = p.TemplateID,
    p.StatusCode,
    p.LastModifiedAt
FROM @VisibleCodes vc
LEFT JOIN dbo.wap_PunchPaged p
    ON p.Code = vc.PunchCode
ORDER BY vc.PunchCode, p.ProjectId, p.TemplateID, p.Id;

/* =====================================================================
   Interpretation

   A) PunchRowsForProjectTemplate = 0
      -> wrong database/environment OR wrong ProjectId/TemplateId for this DB.

   B) Requested IDs all FoundAsPunchId = 0, but visible MPL codes exist with
      different PunchId values
      -> Power Apps and SSMS are almost certainly reading different data
         snapshots/environments. Do NOT remap IDs; validate against the same DB.

   C) Requested IDs exist as Id but ContextMatches = 0
      -> project/template context mismatch; investigate upstream context.

   D) Requested IDs match only PunchLogId/InspectionId
      -> Punch Review queue identity mapping must be corrected before export.

   E) Requested IDs exist as Id and ContextMatches = 1, but validator still
      reports 0 resolved
      -> inspect status eligibility and wap_ElementHierarchyPunchView relation.
   ===================================================================== */
