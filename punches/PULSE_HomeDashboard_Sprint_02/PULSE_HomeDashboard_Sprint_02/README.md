# PULSE Home Dashboard — Sprint 02

## Implementado

- Lectura real del último snapshot por `ProjectId + TemplateId`.
- Carga de templates mediante el Flow existente `Warroom_GetProjectPunchTemplates`.
- Selección automática del primer template incluido.
- Nuevo Flow requerido: `Warroom_GetPunchDashboardBundle`.
- Parseo completo de:
  - información del snapshot;
  - KPIs dinámicos por estado;
  - matriz categoría × estado;
  - resumen por TOP Code;
  - resumen por subcontratista, disciplina y categoría.
- Estados sin proyecto, sin template, sin snapshot y error.
- El cambio de proyecto carga la pestaña Punches, que es la vista predeterminada.
- El Last Refresh cambia según Punches o Tasks.

## Orden de integración

1. Ejecutar los entregables SQL 01 y 02 si todavía no están desplegados.
2. Ejecutar `PULSE_PunchDashboard_Sprint_02_GetBundle.sql`.
3. Crear el Flow siguiendo `FLOW_Warroom_GetPunchDashboardBundle.md`.
4. Añadir el Flow a Power Apps con el nombre `Warroom_GetPunchDashboardBundle`.
5. Sustituir la pantalla Home por `scr_Home_PunchDashboard_Backend.pa.yaml`.
6. Publicar y probar con un proyecto/template que ya tenga snapshot.

## Validación mínima

- `colPunchTemplates_Filter` contiene solo templates incluidos.
- `colPunchDashboardSummary` contiene una fila por estado dinámico.
- `colPunchDashboardMatrix` contiene categoría × estado.
- `varPunchDashboardHasSnapshot` es `true` cuando existe snapshot.
- El dashboard no consulta directamente `dbo.wap_PunchPaged`.
