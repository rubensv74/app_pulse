/*
    OPDS-C02 - validación no destructiva del contrato.

    Sustituir únicamente los cinco identificadores de proyecto indicados abajo.
    La prueba de ERROR se realiza desde Power Apps/Power Automate y no se provoca
    deliberadamente en SQL compartido.
*/

DECLARE @ProjectNoConfiguration BIGINT = 0;  -- proyecto real sin versión Published
DECLARE @ProjectSnapshotRequired BIGINT = 0; -- Published, sin OverviewSnapshot
DECLARE @ProjectNoData BIGINT = 0;           -- Published + snapshot, sin filas utilizables
DECLARE @ProjectReady BIGINT = 0;            -- Published + snapshot con datos
DECLARE @ProjectFilteredNoResults BIGINT = 0;-- READY, pero el filtro no encuentra subsistemas

EXEC warroom.usp_GetOverviewSnapshot
    @ProjectId = @ProjectNoConfiguration,
    @SearchSubsystem = NULL,
    @PageNumber = 1,
    @PageSize = 50;

EXEC warroom.usp_GetOverviewSnapshot
    @ProjectId = @ProjectSnapshotRequired,
    @SearchSubsystem = NULL,
    @PageNumber = 1,
    @PageSize = 50;

EXEC warroom.usp_GetOverviewSnapshot
    @ProjectId = @ProjectNoData,
    @SearchSubsystem = NULL,
    @PageNumber = 1,
    @PageSize = 50;

EXEC warroom.usp_GetOverviewSnapshot
    @ProjectId = @ProjectReady,
    @SearchSubsystem = NULL,
    @PageNumber = 1,
    @PageSize = 50;

EXEC warroom.usp_GetOverviewSnapshot
    @ProjectId = @ProjectFilteredNoResults,
    @SearchSubsystem = N'__OPDS_FILTER_WITHOUT_MATCH__',
    @PageNumber = 1,
    @PageSize = 50;

