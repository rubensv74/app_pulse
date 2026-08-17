# PULSE — PR-IMP-C03 Concurrency validation

**Fecha:** 2026-08-17  
**Estado:** PASS  
**Ámbito:** Comments-only v1 import

## Objetivo

Confirmar que el módulo de importación detecta cambios concurrentes en PULSE entre el momento del export INTERNAL y el momento de aplicar un comentario importado.

El mecanismo debe impedir cualquier overwrite silencioso.

## Evidencia validada

### Deployment

`warroom.usp_RevalidatePunchCommentImportConflicts`

- `ExistsAsProcedure = 1`
- `WritesPunchComment = 0`

`warroom.usp_GetPunchCommentImportPreview`

- `ExistsAsProcedure = 1`
- `WritesPunchComment = 0`
- `ExposesCurrentValues = 1`

### Caso positivo — current state sin cambios

Resultado observado:

- `Status = READY`
- `TotalRows = 3`
- `ChangedRows = 1`
- `UnchangedRows = 2`
- `ValidRows = 3`
- `ErrorRows = 0`
- `ConflictRows = 0`
- `CanCommit = 1`
- `ProductionCommentDelta = 0`

La fila READY mostró `SnapshotChecksum = CurrentChecksum`.

### Caso negativo — conflicto simulado

Resultado observado:

- staging inicial `READY`
- tras simular un cambio concurrente: `BLOCKED`
- `ChangedRows = 1`
- `ConflictRows = 1`
- `CanCommit = 0`
- fila afectada `ValidationStatus = CONFLICT`
- `ValidationWarningsJson` contiene `CURRENT_STATE_CHANGED`
- `ProductionCommentDelta = 0`
- `IsRestored = 1` tras rollback del test

## Conclusión

PR-IMP-C03 queda cerrado.

El backend ya diferencia tres situaciones antes de cualquier Apply:

1. workbook válido y estado actual intacto → `READY`;
2. workbook manipulado → `ERROR/BLOCKED`;
3. workbook auténtico pero Punch modificado después del export → `CONFLICT/BLOCKED`.

No existe ruta de force overwrite en v1.

## Siguiente incremento

`PR-IMP-C04A — scr_PunchImport premium shell + synthetic state`.

Este siguiente bloque será exclusivamente visual y de estado cliente. No conectará todavía carga de archivos, Flow, preview SQL ni Commit.