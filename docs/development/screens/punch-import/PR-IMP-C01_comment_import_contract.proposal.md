# PR-IMP-C01 — Comment import contract

Fecha de aprobación: 2026-08-17

Estado: **APPROVED / FROZEN — Comments only v1**

## 1. Decisión de producto congelada

La primera versión del Import de PULSE solo podrá escribir una única columna de negocio:

`NewComment`

Aunque el workbook INTERNAL actual muestra también Custom Fields editables, esos campos quedan **fuera del alcance de escritura de v1**. Una capacidad posterior podrá habilitarlos con su propio contrato de tipos, clear semantics, concurrencia y auditoría.

## 2. Semántica de `NewComment`

- celda vacía = sin cambio;
- texto informado = añadir un nuevo comentario al historial del Punch;
- nunca sustituye ni modifica `LastCommentText`;
- nunca borra comentarios existentes;
- no existe `CLEAR` para comentarios en v1;
- una fila puede añadir como máximo un nuevo comentario por intento de importación;
- el autor será el usuario que confirma el Import en PULSE, nunca un valor editable del Excel;
- `CommentType` de commit será `EXCEL_IMPORT` salvo cambio contractual posterior.

## 3. Persistencia

La escritura final será append-only sobre `warroom.PunchComment`.

El comportamiento debe ser equivalente al procedimiento existente `warroom.usp_AddPunchComment`:

- `@ProjectId`
- `@PunchId`
- `@CommentText`
- `@CommentType`
- `@CreatedByEmail`
- `@CreatedByName`

El Import no debe reutilizar `LastCommentText` como destino de escritura: ese campo es una proyección del historial.

## 4. Columnas que no producen escritura en v1

- `LastCommentText`
- `LastCommentOn`
- `CommentCount`
- columnas técnicas de export/import;
- columnas auxiliares;
- Custom Fields `CF__*`, aunque el workbook actual permita editarlos.

Stage/Validate debe bloquear cambios detectados en Custom Fields con `COLUMN_NOT_ALLOWED` para evitar que el usuario crea que esos cambios se aplicarán.

## 5. Integridad del workbook

Stage/Validate debe comprobar como mínimo:

- batch de exportación existente;
- batch de exportación en `READY` y no expirado/revocado;
- `ProjectId` y `TemplateId` coherentes;
- `WorkItemId` perteneciente a `warroom.ExportBatchRow`;
- `RowChecksum` idéntico al snapshot inmutable;
- ninguna fila duplicada;
- cardinalidad del fichero coherente con el snapshot;
- `NewComment` como única escritura autorizada;
- cambios en `CF__*` bloqueados en v1.

El campo físico del workbook llamado `ExportBatchId` conserva el contrato v3 existente: contiene el `PunchExportLogId` numérico y SQL lo resuelve al `ExportBatchId` UUID interno mediante `warroom.ExportBatch`.

## 6. Concurrencia

`NewComment` es append-only y no sobrescribe historia. Por ello, C02 valida la identidad y el checksum original del snapshot, pero no aplica todavía ninguna escritura ni fuerza un conflicto por nuevos comentarios concurrentes.

La revalidación inmediatamente anterior al commit se implementará en la capacidad de Commit.

## 7. Auditoría de commit

Al aplicar una fila:

- insertar una nueva fila en `warroom.PunchComment`;
- registrar `warroom.ImportAudit` con `ColumnName = 'NewComment'`;
- `OldValue = NULL`;
- `NewValue = comentario importado`;
- `ChangedBy = usuario que confirma`;
- conservar `ImportBatchId` y `WorkItemId`.

## 8. Política de celda vacía

**Blank = no change.**

No existe semántica implícita de borrado para Comments only v1.

## 9. Límite de C02

`PR-IMP-C02 — Stage + Validate SQL`:

- puede crear/actualizar `ImportBatch` e `ImportBatchRow`;
- puede clasificar el lote `READY` o `BLOCKED`;
- no puede insertar, actualizar ni borrar datos en `warroom.PunchComment`;
- no puede aplicar Custom Fields;
- no puede realizar el Commit.

## 10. Gate de C02

C02 se considerará validado cuando:

1. un snapshot INTERNAL válido pueda stagearse y quedar `READY`;
2. una fila con `NewComment` quede identificada como cambio;
3. filas sin comentario queden `UNCHANGED`;
4. un checksum manipulado o un Custom Field modificado bloquee el lote;
5. el número de filas de `warroom.PunchComment` no cambie durante ninguna prueba de Stage/Validate.

Esta decisión fue aprobada por el Product Owner el 2026-08-17.