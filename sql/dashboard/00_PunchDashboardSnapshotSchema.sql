
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
