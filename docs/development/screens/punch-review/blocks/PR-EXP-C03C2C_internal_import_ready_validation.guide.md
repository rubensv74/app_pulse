# PR-EXP-C03C2C — Validar perfil INTERNAL / import-ready

**Responsabilidad única:** validar end-to-end el perfil `INTERNAL / import-ready` del Premium Export Modal usando el mismo Flow dedicado y el mismo scope exacto ya validado para CLIENT.

Este bloque no modifica SQL ni Power Apps. No cambia el Flow. Es un gate funcional antes de cerrar PR-EXP-C03C2.

## Precondición

CLIENT ya debe estar validado end-to-end con Review Queue exacta.

## Prueba

1. Abre Punch Review con una Review Queue pequeña y conocida. La validación de referencia actual usa 3 Punches.
2. Abre `Export`.
3. Selecciona `Internal / import-ready · governed metadata`.
4. Confirma que `Generate Excel` permanece habilitado.
5. Pulsa `Generate Excel` una sola vez.
6. El Flow `Warroom_ExportPunchReviewToExcel` debe terminar en `Succeeded`.
7. El modal debe terminar en estado `Export ready`.
8. El Excel debe contener exactamente los Punches de la Review Queue; para la referencia actual, 3 filas de negocio.

## Comprobaciones específicas del workbook INTERNAL

A diferencia de CLIENT, INTERNAL debe conservar las superficies técnicas necesarias para un futuro round-trip gobernado.

Comprueba que existen las hojas:

- `Punches`
- `Export Information`
- `Column Map`
- `Validation Lists`
- `Import Log`

En la hoja `Punches`, además de las columnas de negocio, deben existir metadata técnica gobernada, entre ellas:

- `ExportBatchId`
- `WorkItemId`
- `RowVersion`
- `ExportedAtUtc`
- `RowChecksum`

No es necesario que todas estén visualmente destacadas; algunas pueden estar ocultas o tratadas como auxiliares por el Office Script.

## Resultado PASS

PR-EXP-C03C2C pasa si:

- Flow = Succeeded;
- scope exacto = 3 solicitados / 3 exportados;
- workbook INTERNAL contiene las hojas técnicas;
- el workbook conserva metadata de importación;
- no aparecen Punches fuera de la Review Queue;
- no aparece error nuevo en Power Apps.

## No corregir todavía durante esta prueba

Hay dos ajustes visuales conocidos que se tratarán en el incremento siguiente:

- tarjeta TEMPLATE todavía puede mostrar `20` en lugar de `70200 - Master Punch List`;
- nombre de fichero todavía puede incluir el ProjectId interno `4049`.

No mezclar esos cambios con esta validación INTERNAL.

## Gate posterior

Si INTERNAL pasa:

1. congelar PR-EXP-C03C2 como funcionalmente validado;
2. aplicar un pequeño incremento de presentation correctness para TemplateLabel + ProjectCode del filename;
3. versionar/capturar la definición real del Flow dedicado;
4. actualizar `FLOW_COVERAGE.md`;
5. pasar a PR-EXP-C03D / diseño final de selección gobernada de columnas;
6. después iniciar `scr_PunchImport`.
