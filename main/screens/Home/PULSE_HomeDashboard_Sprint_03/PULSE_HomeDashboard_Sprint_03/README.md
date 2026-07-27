# PULSE Home Dashboard — Sprint 03

## Implementado

- KPIs dinámicos por estado.
- Matriz Category × Status.
- Resumen por TOP Code.
- Resumen por Subcontractor / Discipline / Category.
- Información del snapshot.
- Estados sin datos y de error.
- Drill-through a `scr_Punches` desde todos los bloques.

## Integración

Sustituye la pantalla del Sprint 02.1 por:

` scr_Home_PunchDashboard_Visuals.pa.yaml `

Mantén desplegados el SQL y el Flow del Sprint 02.

## Variables de navegación usadas

- `varPunches_Filter_TemplateId`
- `varPunches_Filter_StatusCode`
- `varPunches_Filter_CategoryCode`
- `varPunches_Filter_Subsystem`
- `varPunches_Filter_SubcontractorId`
- `varPunches_Filter_Discipline`

Si `scr_Punches` utiliza otros nombres, mapea estas variables en su `OnVisible` o en el botón de carga.
