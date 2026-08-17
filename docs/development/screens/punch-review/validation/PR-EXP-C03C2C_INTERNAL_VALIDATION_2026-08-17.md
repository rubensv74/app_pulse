# PR-EXP-C03C2C — INTERNAL / import-ready validation

Fecha: 2026-08-17

Estado: PASS funcional para el perfil INTERNAL, con polish visual pendiente no bloqueante.

## Evidencia validada

- `scr_PunchReview` genera un workbook desde el perfil `Internal / import-ready · governed metadata`.
- El modal termina en estado SUCCESS y muestra `Export ready - 3 punches`.
- El workbook contiene exactamente los 3 Punches de la Review Queue.
- La hoja visible de negocio es `Punches`.
- `New Comment` aparece como columna editable gobernada y con tratamiento visual específico.
- Los Custom Fields autorizados por el mapa aparecen como columnas editables.
- `OriginalValuesJson` está presente en el dataset interno.
- El workbook contiene columnas técnicas y auxiliares ocultas; el salto de letras de columna observado en Excel es consistente con ese comportamiento.

## Verificación contra Office Script

`office-scripts/BuildPunchExport.ts` confirma que en modo INTERNAL:

- se añaden `ExportBatchId`, `WorkItemId`, `RowVersion`, `ExportedAtUtc` y `RowChecksum`;
- `NewComment` se incorpora al orden final del workbook;
- columnas técnicas y auxiliares se ocultan en `Punches`;
- `Export Information`, `Column Map`, `Validation Lists` e `Import Log` se generan y se ocultan mediante `finalizeWorkbookSheets(...)`;
- las celdas de `New Comment` se desbloquean y se muestran en verde;
- los Custom Fields con `IsEditableInExcel = true` se desbloquean y se muestran en azul.

Por tanto, que solo se vea la pestaña `Punches` en Excel es el comportamiento previsto del workbook INTERNAL, no una pérdida de hojas técnicas.

## Pendientes no bloqueantes

1. La tarjeta TEMPLATE del modal continúa mostrando el ID técnico `20` en lugar del label de usuario `70200 - Master Punch List`.
2. El nombre del archivo continúa exponiendo el ProjectId interno (`4049`) en lugar del ProjectCode visible (`70200`).

Estos pendientes se mueven a polish de Export y no bloquean el inicio del módulo de Import.

## Gate siguiente

Abrir `PR-IMP-C01 — Comment import contract` y congelar qué columnas pueden producir escrituras reales durante el primer release de Import.