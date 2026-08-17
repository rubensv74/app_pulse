# PR-EXP-C03C2B — CLIENT end-to-end validation

Fecha: 2026-08-17

Estado: PASS con dos ajustes visuales pendientes no bloqueantes.

## Evidencia validada

- `Generate Excel` se ejecuta desde `scr_PunchReview`.
- El modal pasa a estado SUCCESS.
- El pie muestra `Export ready - 3 punches`.
- El Flow dedicado `Warroom_ExportPunchReviewToExcel` genera correctamente el workbook.
- El Excel contiene exactamente los 3 Punches de la Review Queue.
- El perfil usado es `CLIENT`.
- El workbook CLIENT no muestra las hojas técnicas de importación.
- La dependencia visual del `GateHint` respecto a `rowCount` del Flow fue eliminada; el modal usa `varPRExportScopeCount` como contador de scope ya validado.

## Pendientes no bloqueantes antes del cierre final del módulo

1. La tarjeta TEMPLATE del modal sigue mostrando el ID técnico `20`; debe mostrar el `TemplateLabel` de usuario, por ejemplo `70200 - Master Punch List`.
2. El nombre generado del fichero sigue exponiendo el ProjectId interno (`4049`). Debe evolucionar para usar el ProjectCode visible (`70200`).

Estos dos puntos no invalidan la prueba funcional CLIENT.

## Gate siguiente

Validar el perfil `INTERNAL / import-ready` con la misma Review Queue y comprobar que el workbook conserva exactamente los 3 Punches y añade la metadata/hojas técnicas gobernadas necesarias para el futuro módulo de Import.
