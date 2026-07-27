# PULSE -- Entregable 05

# Diseño técnico Power Apps -- Home \> Punch Dashboard

## Árbol de controles

    scrHome
    └── conHome
        ├── cmpHeader
        ├── cmpHomeTabs
        ├── conPunchDashboard
        │   ├── cmpTemplateSelector
        │   ├── cmpSnapshotBanner
        │   ├── btnRefreshSnapshot
        │   ├── galStatusKPI
        │   ├── cmpStatusMatrix
        │   ├── galTopCode
        │   └── galSubcontractor
        └── conTasksDashboard

------------------------------------------------------------------------

## Origen de datos

  Control             Colección
  ------------------- -----------------------
  Selector Template   colPunchTemplates
  Banner              colPunchSnapshotInfo
  KPI                 colPunchMatrix
  Matrix              colPunchMatrix
  TOP Code            colPunchSubsystem
  Subcontractor       colPunchSubcontractor

------------------------------------------------------------------------

## Flujo Power Fx

### Home.OnVisible

1.  Reset variables.
2.  Cargar `colPunchTemplates`.
3.  Si existe un único template activo:
    -   establecer `varPunchDashboardTemplateId`.
    -   lanzar la carga del snapshot.

### Selector.OnChange

1.  `Set(varPunchDashboardTemplateId, Self.Selected.TemplateId)`
2.  `Set(varPunchDashboardLoading,true)`
3.  Ejecutar Flow **GetLatestPunchDashboardSnapshot**.
4.  Poblar:
    -   colPunchSnapshotInfo
    -   colPunchMatrix
    -   colPunchSubsystem
    -   colPunchSubcontractor
5.  `Set(varPunchDashboardLoading,false)`

### Refresh.OnSelect

1.  Mostrar overlay.
2.  Ejecutar Flow **GeneratePunchDashboardSnapshot**.
3.  Esperar respuesta correcta.
4.  Volver a cargar el snapshot.
5.  Ocultar overlay.

------------------------------------------------------------------------

## Navegación

### KPI

Variables:

-   varPunchListStatusCode

Navigate:

    scrPunchList

### Matrix

Variables:

-   varPunchListCategoryCode
-   varPunchListStatusCode

Navigate.

### TOP Code

Variables:

-   varPunchListSubsystemCode
-   varPunchListStatusCode

Navigate.

### Subcontractor

Variables:

-   varPunchListSubcontractorId
-   varPunchListDisciplineCode
-   varPunchListStatusCode

Navigate.

------------------------------------------------------------------------

## Flows

### flow_GetLatestPunchDashboardSnapshot

Entrada

-   ProjectId
-   TemplateId

Salida

-   SnapshotInfo
-   Matrix
-   TopCode
-   Subcontractor

### flow_GeneratePunchDashboardSnapshot

Entrada

-   ProjectId
-   TemplateId

Salida

-   Success
-   SnapshotRunId
-   GeneratedOn
-   DurationMs
-   SourcePunchCount

------------------------------------------------------------------------

## Variables de estado

-   varPunchDashboardLoading
-   varPunchDashboardLoaded
-   varPunchDashboardSnapshotId
-   varPunchDashboardHasSnapshot
-   varPunchDashboardLastRefresh

------------------------------------------------------------------------

## Reglas

-   Nunca consultar dbo.wap_PunchPaged desde Power Apps.
-   Toda la pantalla consume únicamente snapshots.
-   Punch List mantiene su SP paginado actual.
-   Estados, categorías y templates siempre dinámicos.
-   Ningún control contiene listas codificadas.
