# PR-IMP-C02A — Stage + Validate SQL / primera gate real

Fecha: 2026-08-17  
Rama: `feature/pr-exp-c03-exact-review-queue`  
Estado: PREPARED — requiere ejecución en `db-homeoffice-dev`.

## Objetivo

Construir la primera mitad de `PR-IMP-C02` para **Comments only v1** sin conectar todavía Power Automate ni Power Apps.

Esta capacidad:

- registra `NewComment` como columna de importación gobernada;
- crea `warroom.usp_StageValidatePunchCommentImport`;
- resuelve el `Export Batch ID` numérico del Excel como `PunchExportLogId` y desde ahí obtiene el `ExportBatchId` UUID real;
- valida Project, Template, WorkItem, cardinalidad y checksum contra el snapshot inmutable;
- clasifica `New Comment` vacío como `UNCHANGED`;
- clasifica `New Comment` informado como `READY`;
- crea/reutiliza `ImportBatch` e `ImportBatchRow`;
- devuelve el contrato `PULSE.PunchExcelImportBatchSummary/v1`;
- **no escribe absolutamente nada en `warroom.PunchComment`**.

## Por qué el Excel llama `ExportBatchId` a un número

El contrato v3 ya congelado define que la columna física `ExportBatchId` del workbook contiene el `PunchExportLogId` numérico. SQL usa ese valor para encontrar el verdadero `warroom.ExportBatch.ExportBatchId`, que es un UUID.

No hay que cambiar ahora el workbook para C02A.

## Orden de ejecución

### Paso 1 — Seed Comments only

Ejecutar completo:

`sql/import/004_seed_comment_only_v1.sql`

Resultado esperado:

- una fila `NewComment`;
- `ContractVersion = 3`;
- `IsEditable = 1`;
- `IsRequired = 0`;
- `IsActive = 1`.

### Paso 2 — Deploy Stage + Validate

Ejecutar completo:

`sql/import/005_stage_validate_punch_comment_import.sql`

Resultado esperado al final:

- `ExistsAsProcedure = 1`;
- `WritesPunchComment = 0`.

`WritesPunchComment = 0` es obligatorio.

### Paso 3 — Test positivo

Ejecutar completo:

`sql/import/tests/PR-IMP-C02_positive_ready_latest_export_4049_template20.sql`

El test busca automáticamente el export snapshot READY más reciente de:

- ProjectId interno `4049`;
- TemplateId `20`.

Construye un workbook JSON sintético a partir del snapshot, añade un único `New Comment` de validación y llama al procedimiento.

Resultado esperado:

- `status = READY`;
- `ChangedRows = 1`;
- `ErrorRows = 0`;
- exactamente una fila `READY`;
- el resto `UNCHANGED`;
- `ProductionCommentDelta = 0`.

El texto usado en la prueba queda solo en staging. **No se inserta como comentario real.**

## Test negativo ya preparado, pero no ejecutar todavía

Después del PASS positivo existe:

`sql/import/tests/PR-IMP-C02_negative_checksum_block_latest_export_4049_template20.sql`

Corrompe deliberadamente un checksum y debe dejar el batch `BLOCKED` sin tocar `PunchComment`.

Se ejecutará solo después de validar el test positivo.

## Límite conocido de C02A

El workbook INTERNAL actual todavía presenta Custom Fields en azul como editables. El contrato de producto ya ha congelado que **v1 solo aplica `NewComment`**.

C02A no interpreta ni aplica ningún valor de Custom Field. Antes de conectar el Import a usuarios reales se hará una de estas dos cosas dentro del mismo workstream:

1. producir un perfil INTERNAL `Comment import` donde esos campos no sean editables; y/o
2. añadir detección de tampering normalizada para esos campos cuando tengamos la serialización real del Excel connector.

Esto no afecta a la seguridad de escritura de C02A porque el procedimiento no contiene ninguna ruta de persistencia para Custom Fields ni PunchComment.

## Gate

No avanzar a Power Automate de Import hasta tener evidencia del Paso 3 con:

`READY / ChangedRows=1 / ErrorRows=0 / ProductionCommentDelta=0`.
