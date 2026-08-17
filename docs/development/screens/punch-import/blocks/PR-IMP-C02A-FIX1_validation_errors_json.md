# PR-IMP-C02A-FIX1 — ValidationErrorsJson non-null

Fecha: 2026-08-17

## Resultado del gate

Las dos primeras comprobaciones fueron correctas:

- `NewComment` quedó registrado en `ImportColumnDefinition` con `IsEditable = 1`, `IsRequired = 0`, `IsActive = 1`.
- `warroom.usp_StageValidatePunchCommentImport` existe y la verificación devuelve `WritesPunchComment = 0`.

La prueba positiva detectó un defecto localizado antes de cualquier escritura de producción:

`Cannot insert the value NULL into column 'ValidationErrorsJson', table 'warroom.ImportBatchRow'.`

## Causa

`ValidationErrorsJson` es `NOT NULL`. La primera versión de C02A podía propagar un `NULL` desde la expresión de validación cuando una fila no generaba errores. Ese valor se enviaba explícitamente al `INSERT`, por lo que el `DEFAULT ('[]')` de la tabla no podía actuar.

## Corrección

`005_stage_validate_punch_comment_import.sql` se ha actualizado para normalizar de forma defensiva todos los payloads de validación:

- `COALESCE(validation.ValidationErrorsJson, N'[]')` para clasificar la fila;
- `COALESCE(validation.ValidationErrorsJson, N'[]')` para insertar `ValidationErrorsJson`;
- la generación interna de errores usa también `COALESCE(..., N'[]')`;
- `ChangedColumnsJson` y `errorsJson` quedan igualmente normalizados a arrays JSON válidos.

No se ha añadido ninguna escritura sobre `warroom.PunchComment`.

## Revalidación requerida

1. Volver a ejecutar el archivo completo `sql/import/005_stage_validate_punch_comment_import.sql`.
2. Confirmar otra vez:
   - `ExistsAsProcedure = 1`
   - `WritesPunchComment = 0`
3. Repetir `sql/import/tests/PR-IMP-C02_positive_ready_latest_export_4049_template20.sql`.

Resultado esperado del test positivo:

- `Status = READY`
- `ChangedRows = 1`
- `ErrorRows = 0`
- una fila `READY`
- resto `UNCHANGED`
- `ProductionCommentDelta = 0`

No avanzar al test negativo ni a Commit hasta superar este gate.