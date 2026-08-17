# PR-IMP-C03 — Current State + Conflict Validation

## Objetivo

Antes de permitir `Apply`, comprobar si el Punch ha cambiado en PULSE desde que se generó el workbook INTERNAL.

Regla v1:

- fila sin `New Comment` -> `UNCHANGED`;
- fila con `New Comment` y estado actual igual al snapshot -> `READY`;
- fila con `New Comment` y estado actual distinto -> `CONFLICT`;
- cualquier `ERROR` previo permanece `ERROR`;
- un lote con `ERROR` o `CONFLICT` queda `BLOCKED`;
- no existe force overwrite;
- ningún script de este bloque escribe en `warroom.PunchComment`.

La comparación usa el mismo snapshot canónico y SHA-256 que el export INTERNAL: Punch, jerarquía, subcontractor, resumen de comentarios y Custom Fields exportables.

## Orden de ejecución

### 1. Desplegar revalidación de concurrencia

Ejecutar completo:

`sql/import/007_revalidate_punch_comment_import_conflicts.sql`

Resultado esperado:

```text
ExistsAsProcedure = 1
WritesPunchComment = 0
```

### 2. Actualizar Preview para exponer Original / Current / Incoming

Ejecutar completo:

`sql/import/006_get_punch_comment_import_preview.sql`

Resultado esperado:

```text
ExistsAsProcedure = 1
WritesPunchComment = 0
ExposesCurrentValues = 1
```

### 3. Test positivo

Ejecutar completo:

`sql/import/tests/PR-IMP-C03_positive_current_state_ready_4049_template20.sql`

Esperado:

```text
Status                  READY
ChangedRows             1
ConflictRows            0
ErrorRows               0
CanCommit               1
ProductionCommentDelta  0
```

Detalle:

- una fila `READY`;
- restantes `UNCHANGED`;
- `CurrentValuesJson` informado;
- `CurrentChecksum` = `SnapshotChecksum` para la fila READY.

### 4. Test negativo de conflicto simulado

Solo después de pasar el positivo.

Ejecutar completo:

`sql/import/tests/PR-IMP-C03_negative_simulated_current_state_conflict_4049_template20.sql`

El test modifica temporalmente el checksum del snapshot dentro de una transacción y ejecuta `ROLLBACK` al final.

Esperado antes del rollback:

```text
Status                  BLOCKED
ChangedRows             1
ConflictRows            1
ErrorRows               0
CanCommit               0
ProductionCommentDelta  0
```

La fila afectada debe mostrar:

```text
ValidationStatus = CONFLICT
ConflictCode     = CURRENT_STATE_CHANGED
```

Después del rollback:

```text
IsRestored = 1
```

## Gate

PR-IMP-C03 se cierra únicamente si:

1. ambos SP de este bloque permanecen sin escritura a `PunchComment`;
2. el caso sin cambios queda `READY`;
3. el caso simulado queda `BLOCKED / CONFLICT`;
4. `canCommit = 0` ante conflicto;
5. el snapshot temporal se restaura tras el test;
6. `ProductionCommentDelta = 0` en ambos tests.

## Siguiente capacidad tras el gate

Con C03 cerrado, backend ya puede distinguir:

- lo que venía del export (`OriginalValuesJson`),
- lo que existe ahora en PULSE (`CurrentValuesJson`),
- lo que quiere añadir el usuario (`New Comment`).

El siguiente incremento será `PR-IMP-C04 — scr_PunchImport shell + upload`, todavía sin Commit real.