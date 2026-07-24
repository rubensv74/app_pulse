# PULSE Home Dashboard — Sprint 01

## Resultado

Pantalla completa `scr_Home` actualizada a partir del código fuente facilitado.

## Implementado

- Pestaña **Punches** predeterminada.
- Pestaña **Tasks** para conservar el Hive actual.
- Selector premium de vistas.
- Contenedor `conPunchDashboard`.
- Selector de Punch Template.
- Acción diferida `LOAD_PUNCH_DASHBOARD`.
- Refresh contextual según la pestaña activa.
- Reinicio del contexto Punch Dashboard al cambiar de proyecto.
- Colecciones preparadas para el contrato de snapshot.

## Colecciones nuevas

- `colPunchDashboardSnapshotInfo`
- `colPunchDashboardMatrix`
- `colPunchDashboardSubsystems`
- `colPunchDashboardSubcontractors`

## Integración

Sustituye la pantalla Home actual por `scr_Home_Punches_Tasks_Tabs.pa.yaml`.

Este sprint no inventa un Flow inexistente. El contenedor Punches queda preparado para conectar el backend real en el siguiente sprint.
