
/*
    PULSE - Punch Dashboard
    Entregable 01
    Modelo de datos para snapshot analítico y configuración de columnas

    Principios:
    - Contexto obligatorio: ProjectId + TemplateId.
    - StatusCode dinámico por proyecto. No se codifican estados fijos.
    - El Dashboard consume snapshots locales.
    - Punch List permanece en tiempo real y paginada.
    - Los nombres visibles de columnas quedan desacoplados de los nombres físicos.
*/

SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

/* ============================================================
   1. EJECUCIONES DE SNAPSHOT
   ============================================================ */

IF OBJECT_ID(N'warroom.PunchDashboardSnapshotRun', N'U') IS NULL
BEGIN
    CREATE TABLE warroom.PunchDashboardSnapshotRun
    (
        SnapshotRunId       BIGINT IDENTITY(1,1) NOT NULL,
        ProjectId           BIGINT NOT NULL,
        TemplateId          BIGINT NOT NULL,

        Status              VARCHAR(20) NOT NULL,
        RequestedOn         DATETIME2(7) NOT NULL,
        StartedOn           DATETIME2(7) NULL,
        CompletedOn         DATETIME2(7) NULL,

        RequestedBy         NVARCHAR(450) NULL,
        ErrorMessage        NVARCHAR(4000) NULL,

        SourcePunchCount    BIGINT NULL,
        DurationMs          BIGINT NULL,

        CONSTRAINT PK_PunchDashboardSnapshotRun
            PRIMARY KEY CLUSTERED (SnapshotRunId),

        CONSTRAINT CK_PunchDashboardSnapshotRun_Status
            CHECK (Status IN ('PENDING', 'RUNNING', 'COMPLETED', 'FAILED'))
    );

    ALTER TABLE warroom.PunchDashboardSnapshotRun
        ADD CONSTRAINT DF_PunchDashboardSnapshotRun_Status
        DEFAULT ('PENDING') FOR Status;

    ALTER TABLE warroom.PunchDashboardSnapshotRun
        ADD CONSTRAINT DF_PunchDashboardSnapshotRun_RequestedOn
        DEFAULT (SYSUTCDATETIME()) FOR RequestedOn;
END;
GO

IF NOT EXISTS
(
    SELECT 1
    FROM sys.indexes
    WHERE object_id = OBJECT_ID(N'warroom.PunchDashboardSnapshotRun')
      AND name = N'IX_PunchDashboardSnapshotRun_Context'
)
BEGIN
    CREATE NONCLUSTERED INDEX IX_PunchDashboardSnapshotRun_Context
    ON warroom.PunchDashboardSnapshotRun
    (
        ProjectId,
        TemplateId,
        Status,
        SnapshotRunId DESC
    )
    INCLUDE
    (
        RequestedOn,
        CompletedOn,
        SourcePunchCount,
        DurationMs
    );
END;
GO

/* ============================================================
   2. SNAPSHOT GENERAL POR CATEGORÍA Y ESTADO
   ============================================================ */

IF OBJECT_ID(N'warroom.PunchDashboardSnapshotCategoryStatus', N'U') IS NULL
BEGIN
    CREATE TABLE warroom.PunchDashboardSnapshotCategoryStatus
    (
        SnapshotRunId       BIGINT NOT NULL,
        ProjectId           BIGINT NOT NULL,
        TemplateId          BIGINT NOT NULL,

        CategoryCode        VARCHAR(20) NOT NULL,
        CategoryName        VARCHAR(450) NULL,
        CategoryOrder       INT NULL,

        StatusCode          VARCHAR(20) NOT NULL,
        StatusName          VARCHAR(100) NULL,
        StatusOrder         INT NULL,
        StatusColor         VARCHAR(20) NULL,

        PunchCount          BIGINT NOT NULL,

        CONSTRAINT PK_PunchDashboardSnapshotCategoryStatus
            PRIMARY KEY CLUSTERED
            (
                SnapshotRunId,
                CategoryCode,
                StatusCode
            ),

        CONSTRAINT FK_PunchDashboardSnapshotCategoryStatus_Run
            FOREIGN KEY (SnapshotRunId)
            REFERENCES warroom.PunchDashboardSnapshotRun(SnapshotRunId)
            ON DELETE CASCADE
    );
END;
GO

IF NOT EXISTS
(
    SELECT 1
    FROM sys.indexes
    WHERE object_id = OBJECT_ID(N'warroom.PunchDashboardSnapshotCategoryStatus')
      AND name = N'IX_PunchDashboardSnapshotCategoryStatus_Context'
)
BEGIN
    CREATE NONCLUSTERED INDEX IX_PunchDashboardSnapshotCategoryStatus_Context
    ON warroom.PunchDashboardSnapshotCategoryStatus
    (
        ProjectId,
        TemplateId,
        StatusOrder,
        CategoryOrder
    )
    INCLUDE
    (
        SnapshotRunId,
        CategoryName,
        StatusName,
        StatusColor,
        PunchCount
    );
END;
GO

/* ============================================================
   3. SNAPSHOT POR TOP CODE / SUBSYSTEM
   ============================================================ */

IF OBJECT_ID(N'warroom.PunchDashboardSnapshotSubsystem', N'U') IS NULL
BEGIN
    CREATE TABLE warroom.PunchDashboardSnapshotSubsystem
    (
        SnapshotRunId       BIGINT NOT NULL,
        ProjectId           BIGINT NOT NULL,
        TemplateId          BIGINT NOT NULL,

        SubsystemCode       VARCHAR(255) NOT NULL,
        SubsystemName       VARCHAR(255) NULL,

        CategoryCode        VARCHAR(20) NOT NULL,
        CategoryName        VARCHAR(450) NULL,
        CategoryOrder       INT NULL,

        StatusCode          VARCHAR(20) NOT NULL,
        StatusName          VARCHAR(100) NULL,
        StatusOrder         INT NULL,
        StatusColor         VARCHAR(20) NULL,

        PunchCount          BIGINT NOT NULL,

        CONSTRAINT PK_PunchDashboardSnapshotSubsystem
            PRIMARY KEY CLUSTERED
            (
                SnapshotRunId,
                SubsystemCode,
                CategoryCode,
                StatusCode
            ),

        CONSTRAINT FK_PunchDashboardSnapshotSubsystem_Run
            FOREIGN KEY (SnapshotRunId)
            REFERENCES warroom.PunchDashboardSnapshotRun(SnapshotRunId)
            ON DELETE CASCADE
    );
END;
GO

IF NOT EXISTS
(
    SELECT 1
    FROM sys.indexes
    WHERE object_id = OBJECT_ID(N'warroom.PunchDashboardSnapshotSubsystem')
      AND name = N'IX_PunchDashboardSnapshotSubsystem_Context'
)
BEGIN
    CREATE NONCLUSTERED INDEX IX_PunchDashboardSnapshotSubsystem_Context
    ON warroom.PunchDashboardSnapshotSubsystem
    (
        ProjectId,
        TemplateId,
        StatusCode,
        SubsystemCode
    )
    INCLUDE
    (
        SnapshotRunId,
        SubsystemName,
        CategoryCode,
        CategoryName,
        CategoryOrder,
        StatusName,
        StatusOrder,
        StatusColor,
        PunchCount
    );
END;
GO

/* ============================================================
   4. SNAPSHOT POR SUBCONTRATISTA, DISCIPLINA Y CATEGORÍA
   ============================================================ */

IF OBJECT_ID(N'warroom.PunchDashboardSnapshotSubcontractor', N'U') IS NULL
BEGIN
    CREATE TABLE warroom.PunchDashboardSnapshotSubcontractor
    (
        SnapshotRunId             BIGINT NOT NULL,
        ProjectId                 BIGINT NOT NULL,
        TemplateId                BIGINT NOT NULL,

        SubcontractorId           BIGINT NOT NULL,
        SubcontractorCode         NVARCHAR(50) NULL,
        SubcontractorName         NVARCHAR(255) NULL,
        SubcontractorShortName    NVARCHAR(100) NULL,

        DisciplineCode            VARCHAR(20) NOT NULL,
        DisciplineName            VARCHAR(100) NULL,

        CategoryCode              VARCHAR(20) NOT NULL,
        CategoryName              VARCHAR(450) NULL,
        CategoryOrder             INT NULL,

        StatusCode                VARCHAR(20) NOT NULL,
        StatusName                VARCHAR(100) NULL,
        StatusOrder               INT NULL,
        StatusColor               VARCHAR(20) NULL,

        PunchCount                BIGINT NOT NULL,

        CONSTRAINT PK_PunchDashboardSnapshotSubcontractor
            PRIMARY KEY CLUSTERED
            (
                SnapshotRunId,
                SubcontractorId,
                DisciplineCode,
                CategoryCode,
                StatusCode
            ),

        CONSTRAINT FK_PunchDashboardSnapshotSubcontractor_Run
            FOREIGN KEY (SnapshotRunId)
            REFERENCES warroom.PunchDashboardSnapshotRun(SnapshotRunId)
            ON DELETE CASCADE
    );
END;
GO

IF NOT EXISTS
(
    SELECT 1
    FROM sys.indexes
    WHERE object_id = OBJECT_ID(N'warroom.PunchDashboardSnapshotSubcontractor')
      AND name = N'IX_PunchDashboardSnapshotSubcontractor_Context'
)
BEGIN
    CREATE NONCLUSTERED INDEX IX_PunchDashboardSnapshotSubcontractor_Context
    ON warroom.PunchDashboardSnapshotSubcontractor
    (
        ProjectId,
        TemplateId,
        StatusCode,
        SubcontractorName,
        DisciplineCode
    )
    INCLUDE
    (
        SnapshotRunId,
        SubcontractorId,
        SubcontractorCode,
        SubcontractorShortName,
        DisciplineName,
        CategoryCode,
        CategoryName,
        CategoryOrder,
        StatusName,
        StatusOrder,
        StatusColor,
        PunchCount
    );
END;
GO

/* ============================================================
   5. CONFIGURACIÓN DE COLUMNAS DE INFORME
   ============================================================ */

IF OBJECT_ID(N'warroom.ReportColumnConfig', N'U') IS NULL
BEGIN
    CREATE TABLE warroom.ReportColumnConfig
    (
        ReportColumnConfigId    BIGINT IDENTITY(1,1) NOT NULL,

        ProjectId               BIGINT NOT NULL,
        TemplateId              BIGINT NULL,
        ReportCode              NVARCHAR(100) NOT NULL,

        ColumnKey               NVARCHAR(100) NOT NULL,
        SourceField             NVARCHAR(128) NOT NULL,

        DisplayName             NVARCHAR(255) NOT NULL,
        ShortDisplayName        NVARCHAR(100) NULL,
        ExportName              NVARCHAR(255) NULL,

        DisplayOrder            INT NOT NULL,
        IsVisible               BIT NOT NULL,
        IsRequired              BIT NOT NULL,
        IsExportable            BIT NOT NULL,

        InternalVisible         BIT NOT NULL,
        ExternalVisible         BIT NOT NULL,

        DataType                NVARCHAR(30) NULL,
        TextAlign               NVARCHAR(20) NULL,
        ColumnWidth             INT NULL,

        IsSortable              BIT NOT NULL,
        IsFilterable            BIT NOT NULL,

        IsActive                BIT NOT NULL,

        CreatedOn               DATETIME2(7) NOT NULL,
        CreatedBy               NVARCHAR(450) NULL,
        ModifiedOn              DATETIME2(7) NULL,
        ModifiedBy              NVARCHAR(450) NULL,

        CONSTRAINT PK_ReportColumnConfig
            PRIMARY KEY CLUSTERED (ReportColumnConfigId),

        CONSTRAINT UQ_ReportColumnConfig
            UNIQUE
            (
                ProjectId,
                TemplateId,
                ReportCode,
                ColumnKey
            ),

        CONSTRAINT CK_ReportColumnConfig_TextAlign
            CHECK
            (
                TextAlign IS NULL
                OR TextAlign IN ('LEFT', 'CENTER', 'RIGHT')
            ),

        CONSTRAINT CK_ReportColumnConfig_ColumnWidth
            CHECK
            (
                ColumnWidth IS NULL
                OR ColumnWidth BETWEEN 40 AND 1000
            )
    );

    ALTER TABLE warroom.ReportColumnConfig
        ADD CONSTRAINT DF_ReportColumnConfig_IsVisible
        DEFAULT (1) FOR IsVisible;

    ALTER TABLE warroom.ReportColumnConfig
        ADD CONSTRAINT DF_ReportColumnConfig_IsRequired
        DEFAULT (0) FOR IsRequired;

    ALTER TABLE warroom.ReportColumnConfig
        ADD CONSTRAINT DF_ReportColumnConfig_IsExportable
        DEFAULT (1) FOR IsExportable;

    ALTER TABLE warroom.ReportColumnConfig
        ADD CONSTRAINT DF_ReportColumnConfig_InternalVisible
        DEFAULT (1) FOR InternalVisible;

    ALTER TABLE warroom.ReportColumnConfig
        ADD CONSTRAINT DF_ReportColumnConfig_ExternalVisible
        DEFAULT (1) FOR ExternalVisible;

    ALTER TABLE warroom.ReportColumnConfig
        ADD CONSTRAINT DF_ReportColumnConfig_IsSortable
        DEFAULT (1) FOR IsSortable;

    ALTER TABLE warroom.ReportColumnConfig
        ADD CONSTRAINT DF_ReportColumnConfig_IsFilterable
        DEFAULT (1) FOR IsFilterable;

    ALTER TABLE warroom.ReportColumnConfig
        ADD CONSTRAINT DF_ReportColumnConfig_IsActive
        DEFAULT (1) FOR IsActive;

    ALTER TABLE warroom.ReportColumnConfig
        ADD CONSTRAINT DF_ReportColumnConfig_CreatedOn
        DEFAULT (SYSUTCDATETIME()) FOR CreatedOn;
END;
GO

IF NOT EXISTS
(
    SELECT 1
    FROM sys.indexes
    WHERE object_id = OBJECT_ID(N'warroom.ReportColumnConfig')
      AND name = N'IX_ReportColumnConfig_Resolve'
)
BEGIN
    CREATE NONCLUSTERED INDEX IX_ReportColumnConfig_Resolve
    ON warroom.ReportColumnConfig
    (
        ReportCode,
        ColumnKey,
        ProjectId,
        TemplateId,
        IsActive
    )
    INCLUDE
    (
        SourceField,
        DisplayName,
        ShortDisplayName,
        ExportName,
        DisplayOrder,
        IsVisible,
        IsRequired,
        IsExportable,
        InternalVisible,
        ExternalVisible,
        DataType,
        TextAlign,
        ColumnWidth,
        IsSortable,
        IsFilterable
    );
END;
GO

/* ============================================================
   6. CONFIGURACIÓN BASE DE COLUMNAS
   ProjectId = 0 y TemplateId = NULL representan la configuración global.
   ============================================================ */

IF NOT EXISTS
(
    SELECT 1
    FROM warroom.ReportColumnConfig
    WHERE ProjectId = 0
      AND TemplateId IS NULL
      AND ReportCode = N'PUNCH_LIST'
)
BEGIN
    INSERT INTO warroom.ReportColumnConfig
    (
        ProjectId,
        TemplateId,
        ReportCode,
        ColumnKey,
        SourceField,
        DisplayName,
        ShortDisplayName,
        ExportName,
        DisplayOrder,
        IsVisible,
        IsRequired,
        IsExportable,
        InternalVisible,
        ExternalVisible,
        DataType,
        TextAlign,
        ColumnWidth,
        IsSortable,
        IsFilterable,
        IsActive,
        CreatedBy
    )
    VALUES
    (0, NULL, N'PUNCH_LIST', N'SUBCONTRACTOR',              N'SubcontractorName',          N'Subcontractor',                    N'Subcontractor',          N'Subcontractor',                    10, 1, 1, 1, 1, 1, N'TEXT', N'LEFT',   180, 1, 1, 1, N'SYSTEM'),
    (0, NULL, N'PUNCH_LIST', N'TOP_CODE',                   N'SubsystemCode',              N'TOP Code',                         N'TOP Code',               N'TOP Code',                         20, 1, 1, 1, 1, 1, N'TEXT', N'LEFT',   110, 1, 1, 1, N'SYSTEM'),
    (0, NULL, N'PUNCH_LIST', N'PUNCH_CODE',                 N'Code',                       N'Code',                             N'Code',                   N'Code',                             30, 1, 1, 1, 1, 1, N'TEXT', N'LEFT',   130, 1, 1, 1, N'SYSTEM'),
    (0, NULL, N'PUNCH_LIST', N'DISCIPLINE',                 N'Discipline',                 N'Discipline',                       N'Discipline',             N'Discipline',                       40, 1, 1, 1, 1, 1, N'TEXT', N'LEFT',   130, 1, 1, 1, N'SYSTEM'),
    (0, NULL, N'PUNCH_LIST', N'CATEGORY',                   N'Category',                   N'Category',                         N'Category',               N'Category',                         50, 1, 1, 1, 1, 1, N'TEXT', N'LEFT',   130, 1, 1, 1, N'SYSTEM'),
    (0, NULL, N'PUNCH_LIST', N'DESCRIPTION',                N'Description',                N'Description',                      N'Description',            N'Description',                      60, 1, 1, 1, 1, 1, N'TEXT', N'LEFT',   320, 1, 1, 1, N'SYSTEM'),
    (0, NULL, N'PUNCH_LIST', N'RESP_SUBCONTRACTOR',         N'SubcontractorResponsible',   N'Responsible person (SC)',          N'SC Responsible',         N'Responsible person (SC)',          70, 1, 0, 1, 1, 1, N'TEXT', N'LEFT',   190, 1, 1, 1, N'SYSTEM'),
    (0, NULL, N'PUNCH_LIST', N'RESP_TRGE',                  N'PunchCoordinator',           N'Responsible person (TR/GE)',       N'TR/GE Responsible',      N'Responsible person (TR/GE)',       80, 1, 0, 1, 1, 1, N'TEXT', N'LEFT',   190, 1, 1, 1, N'SYSTEM'),
    (0, NULL, N'PUNCH_LIST', N'ACTION_BY',                  N'DepartmentAction',           N'Action by',                        N'Action by',              N'Action by',                        90, 1, 0, 1, 1, 1, N'TEXT', N'LEFT',   140, 1, 1, 1, N'SYSTEM'),
    (0, NULL, N'PUNCH_LIST', N'ORIGINATOR',                 N'Originator',                 N'Originator',                       N'Originator',             N'Originator',                      100, 1, 0, 1, 1, 1, N'TEXT', N'LEFT',   140, 1, 1, 1, N'SYSTEM'),
    (0, NULL, N'PUNCH_LIST', N'STATUS',                     N'Status',                     N'Status',                           N'Status',                 N'Status',                          110, 1, 1, 1, 1, 1, N'TEXT', N'CENTER', 120, 1, 1, 1, N'SYSTEM');
END;
GO

/* ============================================================
   7. SP PARA RESOLVER CONFIGURACIÓN DE COLUMNAS
   Prioridad:
   1) Proyecto + Template
   2) Proyecto
   3) Global + Template
   4) Global
   ============================================================ */

CREATE OR ALTER PROCEDURE warroom.usp_GetReportColumnConfig
(
    @ProjectId   BIGINT,
    @ReportCode  NVARCHAR(100),
    @TemplateId  BIGINT = NULL
)
AS
BEGIN
    SET NOCOUNT ON;

    SET @ReportCode = NULLIF(LTRIM(RTRIM(@ReportCode)), N'');

    IF @ReportCode IS NULL
    BEGIN
        THROW 50001, 'ReportCode is required.', 1;
    END;

    ;WITH Candidate AS
    (
        SELECT
            c.ReportColumnConfigId,
            c.ProjectId,
            c.TemplateId,
            c.ReportCode,
            c.ColumnKey,
            c.SourceField,
            c.DisplayName,
            c.ShortDisplayName,
            c.ExportName,
            c.DisplayOrder,
            c.IsVisible,
            c.IsRequired,
            c.IsExportable,
            c.InternalVisible,
            c.ExternalVisible,
            c.DataType,
            c.TextAlign,
            c.ColumnWidth,
            c.IsSortable,
            c.IsFilterable,
            Priority =
                CASE
                    WHEN c.ProjectId = @ProjectId
                     AND c.TemplateId = @TemplateId
                     AND @TemplateId IS NOT NULL THEN 1

                    WHEN c.ProjectId = @ProjectId
                     AND c.TemplateId IS NULL THEN 2

                    WHEN c.ProjectId = 0
                     AND c.TemplateId = @TemplateId
                     AND @TemplateId IS NOT NULL THEN 3

                    WHEN c.ProjectId = 0
                     AND c.TemplateId IS NULL THEN 4

                    ELSE 99
                END
        FROM warroom.ReportColumnConfig c
        WHERE c.ReportCode = @ReportCode
          AND c.IsActive = 1
          AND c.ProjectId IN (0, @ProjectId)
          AND
          (
              c.TemplateId IS NULL
              OR c.TemplateId = @TemplateId
          )
    ),
    Ranked AS
    (
        SELECT
            *,
            rn = ROW_NUMBER() OVER
            (
                PARTITION BY ColumnKey
                ORDER BY Priority, ReportColumnConfigId DESC
            )
        FROM Candidate
        WHERE Priority < 99
    )
    SELECT
        ColumnKey,
        SourceField,
        DisplayName,
        ShortDisplayName,
        ExportName,
        DisplayOrder,
        IsVisible,
        IsRequired,
        IsExportable,
        InternalVisible,
        ExternalVisible,
        DataType,
        TextAlign,
        ColumnWidth,
        IsSortable,
        IsFilterable
    FROM Ranked
    WHERE rn = 1
    ORDER BY DisplayOrder, ColumnKey;
END;
GO

/* ============================================================
   8. SP PARA LEER EL ÚLTIMO SNAPSHOT VÁLIDO
   ============================================================ */

CREATE OR ALTER PROCEDURE warroom.usp_GetLatestPunchDashboardSnapshot
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
GO
