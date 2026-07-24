# PULSE -- Entregable 03

# Contrato de datos del Dashboard de Punches

## Contexto

Todas las llamadas utilizan obligatoriamente:

-   ProjectId
-   TemplateId

No existe ningún procedimiento del Dashboard que funcione únicamente por
ProjectId.

------------------------------------------------------------------------

# Flujo de carga

``` text
Seleccionar Proyecto
        ↓
Cargar Templates
        ↓
Seleccionar Template
        ↓
Obtener último Snapshot
        ↓
Mostrar Dashboard
        ↓
Refresh (opcional)
        ↓
Regenerar Snapshot
        ↓
Recargar Dashboard
```

------------------------------------------------------------------------

# Procedimientos

## usp_GetLatestPunchDashboardSnapshot

Entrada

  Parámetro    Tipo
  ------------ --------
  ProjectId    bigint
  TemplateId   bigint

Salida:

### ResultSet 1

Información del snapshot

-   SnapshotRunId
-   GeneratedOn
-   SourcePunchCount
-   DurationMs

### ResultSet 2

Category × Status

-   CategoryCode
-   CategoryName
-   CategoryOrder
-   StatusCode
-   StatusName
-   StatusOrder
-   StatusColor
-   PunchCount

### ResultSet 3

TOP Code (Subsystem)

-   SubsystemCode
-   SubsystemName
-   CategoryCode
-   CategoryName
-   StatusCode
-   StatusName
-   PunchCount

### ResultSet 4

Subcontractor

-   SubcontractorId
-   SubcontractorName
-   DisciplineCode
-   DisciplineName
-   CategoryCode
-   CategoryName
-   StatusCode
-   StatusName
-   PunchCount

------------------------------------------------------------------------

# Navegación

El Dashboard nunca muestra el detalle.

Siempre navega a Punch List.

## Variables

-   varPunchDashboardProjectId
-   varPunchDashboardTemplateId
-   varPunchListCategoryCode
-   varPunchListStatusCode
-   varPunchListSubsystemCode
-   varPunchListSubcontractorId
-   varPunchListDisciplineCode

------------------------------------------------------------------------

# Acciones

## KPI

Click

↓

Punch List filtrada por StatusCode

## Matriz

Click en una celda

↓

Punch List filtrada por:

-   CategoryCode
-   StatusCode

## TOP Code

↓

Punch List filtrada por:

-   SubsystemCode
-   StatusCode

## Subcontractor

↓

Punch List filtrada por:

-   SubcontractorId
-   DisciplineCode
-   StatusCode

------------------------------------------------------------------------

# Principios

-   Estados completamente dinámicos.
-   Categorías dinámicas por template.
-   Templates dinámicos por proyecto.
-   Dashboard basado en snapshot.
-   Punch List en tiempo real.
-   Configuración de columnas desacoplada del modelo físico SQL.
