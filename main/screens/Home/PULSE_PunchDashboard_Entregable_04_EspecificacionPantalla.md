# PULSE -- Entregable 04

# Especificación funcional -- Home \> Punch Dashboard

## Objetivo

El Dashboard de Punches es una pantalla analítica. Nunca muestra el
detalle de los punches; cualquier interacción navega a **Punch List**
con los filtros correspondientes.

------------------------------------------------------------------------

# Estructura

    Home
     ├── Header
     ├── Tabs
     │    ├── Punch Dashboard
     │    └── Tasks Dashboard
     └── Punch Dashboard
          ├── Template selector
          ├── Last snapshot banner
          ├── Refresh button
          ├── KPI ribbon
          ├── Category × Status matrix
          ├── TOP Code analysis
          └── Subcontractor analysis

------------------------------------------------------------------------

# Variables globales

## Contexto

-   varProjectId
-   varPunchDashboardTemplateId
-   varPunchDashboardLoaded
-   varPunchDashboardLoading
-   varPunchDashboardSnapshotId

## Navegación

-   varPunchListSource
-   varPunchListStatusCode
-   varPunchListCategoryCode
-   varPunchListSubsystemCode
-   varPunchListSubcontractorId
-   varPunchListDisciplineCode

------------------------------------------------------------------------

# Colecciones

## Configuración

-   colPunchTemplates
-   colPunchStatuses
-   colPunchColumns

## Dashboard

-   colPunchSnapshotInfo
-   colPunchMatrix
-   colPunchSubsystem
-   colPunchSubcontractor

------------------------------------------------------------------------

# Eventos

## Home.OnVisible

1.  Cargar templates del proyecto.
2.  Limpiar contexto anterior.
3.  Si existe un único template incluido, seleccionarlo automáticamente.

## Selector Template.OnChange

1.  Guardar TemplateId.
2.  Mostrar overlay.
3.  Obtener último snapshot.
4.  Poblar colecciones.
5.  Ocultar overlay.

## Refresh.OnSelect

1.  Ejecutar Flow.
2.  Flow llama a usp_GeneratePunchDashboardSnapshot.
3.  Esperar respuesta.
4.  Recargar snapshot.
5.  Actualizar banner.

------------------------------------------------------------------------

# KPI

Cada tarjeta representa un StatusCode configurado.

OnSelect:

-   Guardar StatusCode.
-   Limpiar resto de filtros.
-   Navigate(Punch List).

------------------------------------------------------------------------

# Matrix

Filas

-   Category

Columnas

-   StatusCode (dinámico)

OnSelect

-   CategoryCode
-   StatusCode

↓

Navigate(Punch List)

------------------------------------------------------------------------

# TOP Code

Agrupación:

TOP Code + Category + Status

OnSelect

-   SubsystemCode
-   StatusCode

↓

Navigate(Punch List)

------------------------------------------------------------------------

# Subcontractor

Agrupación:

Subcontractor + Discipline + Category + Status

OnSelect

-   SubcontractorId
-   DisciplineCode
-   StatusCode

↓

Navigate(Punch List)

------------------------------------------------------------------------

# Estados visuales

## Sin template

Mostrar mensaje:

"Select a punch template to load the dashboard."

## Cargando

Overlay + spinner.

## Sin snapshot

Mostrar:

"No snapshot available."

Botón:

Generate snapshot.

------------------------------------------------------------------------

# Rendimiento

-   Nunca consultar directamente cientos de miles de punches desde Home.
-   Leer exclusivamente snapshots.
-   Punch List mantiene consulta paginada en tiempo real.

------------------------------------------------------------------------

# Componentes reutilizables

-   cmpDashboardHeader
-   cmpTemplateSelector
-   cmpSnapshotBanner
-   cmpKpiCard
-   cmpStatusMatrix
-   cmpTopAnalysis
-   cmpSubcontractorAnalysis

------------------------------------------------------------------------

# Criterios de aceptación

-   Cambio de proyecto limpia el contexto.
-   Cambio de template recarga únicamente el Dashboard.
-   Estados dinámicos.
-   Categorías dinámicas.
-   Navegación siempre a Punch List.
-   Tiempo de carga limitado al acceso al snapshot.
