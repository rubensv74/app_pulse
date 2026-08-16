# PULSE — Auditoría de Export e Import de Punches

**Fecha:** 2026-08-16  
**Pantallas de referencia:** `scr_Punches`, `scr_PunchReview`  
**Estado:** análisis realizado; implementación incremental pendiente de validación en Power Apps Studio.

## 1. Objetivo

Revisar la funcionalidad de exportación existente en `scr_Punches`, determinar qué puede reutilizarse con seguridad desde `scr_PunchReview`, identificar irregularidades y definir el módulo de importación de Excel con previsualización y aplicación gobernada de cambios.

## 2. Fuentes revisadas

- `power-apps/screens/Punches/scr_Punches_1.pa.yaml`
- `power-apps/screens/PunchReview/scr_PunchReview.pa.yaml`
- `power-apps/contracts/excel-import/export-columns.v3.json`
- `power-apps/contracts/excel-import/import-batch-summary.v1.json`
- `power-apps/mappings/excel-import/punch-columns.v3.json`
- `sql/export/usp_ExportProjectPunchesExtended_Pivoted.sql`
- `sql/export/002_register_punch_export_snapshot.sql`
- `sql/import/001_import_foundations.sql`
- `sql/import/003_seed_import_columns_v3.sql`
- `docs/architecture/integrations/excel-import/EXCEL_IMPORT_ARCHITECTURE.md`
- `power-automate/FLOW_COVERAGE.md`
- protocolo incremental y registro de compatibilidad Power Apps Source Code.

## 3. Estado real del módulo Export

### 3.1. Lo que ya está bien resuelto

La exportación actual no es solo una descarga visual. Existe una base gobernada formada por:

- llamada desde `scr_Punches` a `Warroom_ExportPunchesToExcel_Codex`;
- filtros de proyecto, subsystem, template, category, status, discipline, subcontractor y custom fields;
- perfiles `CLIENT` e `INTERNAL`;
- selección de columnas de negocio;
- snapshot de columnas permitidas;
- `ExportBatch` y `ExportBatchRow`;
- metadatos protegidos para reimportación en el contrato v3;
- checksum SHA-256 para detectar cambios concurrentes;
- límite de exportación de 50.000 filas;
- URL de archivo devuelta por el flow y apertura mediante `Launch()`.

El contrato v3 es una base válida para construir la importación futura. En particular, el workbook `INTERNAL` puede transportar `ExportBatchId`, `ProjectId`, `TemplateId`, `WorkItemId`, `ExportedAtUtc` y `RowChecksum` como metadatos técnicos no editables.

### 3.2. Irregularidades y riesgos encontrados

#### E-01 — Semántica inconsistente de `varPunchExportMode`

La UI trabaja con los modos `CLIENT` e `INTERNAL`, pero la normalización previa a ejecutar el flow usa `FILTERED` como fallback cuando el valor está vacío.

Esto mezcla dos conceptos distintos:

- **perfil de seguridad/salida:** `CLIENT` / `INTERNAL`;
- **scope o conjunto de registros:** filtrado, proyecto, queue, etc.

`FILTERED` no debe ser un valor del mismo campo que `CLIENT`/`INTERNAL`. Debe eliminarse ese fallback o separar explícitamente `ExportProfile` y `ExportScope`.

#### E-02 — Configuración de columnas demasiado acoplada a `scr_Punches`

La pantalla construye una lista local de columnas estándar y custom fields, incluyendo flags `IsRequired`, `IsSensitive` e `IsSelected`.

Sin embargo, el contrato de importación v3 declara que la autoridad de editabilidad de negocio es `warroom.usp_GetPunchExportColumnMap` / `IsEditableInExcel` y que el allowlist final se congela en `ExportBatch.AllowedColumnsJson`.

Riesgo: la UI puede divergir de la autoridad backend si ambas listas evolucionan por separado.

Decisión: Punch Review no debe crear una segunda lista independiente y divergente. El modal premium debe consumir la misma semántica y, cuando se reactive la conexión, evolucionar hacia un mapa de columnas gobernado por backend.

#### E-03 — El flow activo no está versionado en el repositorio

`Warroom_ExportPunchesToExcel_Codex` está confirmado como caller activo, pero su definición real figura como `DEFINITION_MISSING`.

Consecuencia: desde el repositorio puede auditarse el contrato del caller, SQL, Office Script y contratos JSON, pero no la implementación interna real del flow.

Antes de modificar parámetros del flow hay que capturar o revisar la definición activa en Power Automate.

#### E-04 — El backend actual no puede representar fielmente una Review Queue arbitraria

`usp_ExportProjectPunchesExtended_Pivoted` acepta filtros de proyecto/template/status/etc., pero no acepta una lista explícita de `PunchId`/`WorkItemId`.

`colPunchReviewQueue` puede llegar ya construida desde la pantalla origen. Por tanto, la queue real de Punch Review puede ser un subconjunto que no pueda reconstruirse exactamente con los filtros actuales del SP.

Consecuencia: llamar al flow actual desde Punch Review y etiquetar el resultado como “Current review queue” sería incorrecto.

Decisión de arquitectura:

- el modal visual puede construirse ya;
- la conexión funcional debe introducir un scope inequívoco;
- para soportar **Review Queue exacta**, la opción recomendada es añadir un parámetro opcional `WorkItemIdsJson`/`PunchIdsJson` al contrato de exportación y aplicar el filtro en SQL antes del snapshot;
- mientras ese contrato no exista, solo puede ofrecerse un scope que el backend pueda reconstruir de forma determinista, por ejemplo proyecto + template + filtros persistidos.

#### E-05 — Cambios locales no guardados en Punch Review

La exportación se genera desde servidor/SQL. Si el usuario tiene cambios locales sin guardar en Custom Fields o comentarios todavía no persistidos, el Excel no reflejará esos cambios.

Decisión UX: no ejecutar exportación mientras exista dirty state relevante. El modal debe mostrar una advertencia y exigir guardar o descartar antes de generar el snapshot.

#### E-06 — Nombres de controles heredados y lógica monolítica

El modal actual contiene controles con sufijos heredados (`_2`, etc.) y concentra apertura, selección de columnas, ejecución y resultado en fórmulas extensas de pantalla.

No es un fallo funcional por sí mismo, pero copiar esa estructura a Punch Review aumentaría deuda técnica.

Decisión: nuevo modal con nombres `conPRExport_*`, estados explícitos y un único punto de entrada desde la Action Toolbar.

## 4. Estado real de Import

La afirmación “no existe importación” es correcta a nivel de **funcionalidad usable**, pero el repositorio ya contiene una base importante que no debe descartarse.

### 4.1. Fundaciones ya existentes

Existen:

- contrato de workbook export v3;
- mapping de columnas import v3;
- contrato de resumen `PULSE.PunchExcelImportBatchSummary/v1`;
- tablas `ImportBatch`, `ImportBatchRow`, `ImportAudit`, `ImportColumnDefinition`;
- estados de lote: `CREATED`, `STAGED`, `VALIDATING`, `READY`, `BLOCKED`, `COMMITTING`, `COMMITTED`, `CANCELLED`, `FAILED`, `EXPIRED`;
- estados de fila: `PENDING`, `READY`, `UNCHANGED`, `WARNING`, `ERROR`, `CONFLICT`;
- persistencia de `IncomingValuesJson`, `OriginalValuesJson`, `CurrentValuesJson`, `ChangedColumnsJson`;
- checksum de concurrencia basado en snapshot de exportación;
- allowlist de columnas de negocio gobernada por backend.

### 4.2. Lo que todavía falta realmente

En `sql/import/` solo están las fundaciones y el seed de columnas técnicas. No están versionados todavía los procedimientos operativos para:

1. crear/stagear un lote desde el Excel;
2. validar metadatos y filas;
3. calcular el diff;
4. devolver preview paginado;
5. revalidar conflictos inmediatamente antes de commit;
6. aplicar cambios;
7. escribir auditoría;
8. cancelar/expirar lotes;
9. exponer el ciclo completo mediante Power Automate.

Tampoco existe todavía una pantalla Power Apps para upload → preview → apply.

### 4.3. Riesgo I-01 — Un solo `ImportBatch` por `ExportBatch`

La tabla `ImportBatch` declara `UNIQUE (ExportBatchId)`.

Esto significa que un mismo export solo puede estar asociado a un único lote de importación. Hay que decidir expresamente la semántica de reintento:

- reutilizar el mismo `ImportBatch` mientras no esté `COMMITTED`; o
- permitir múltiples intentos y retirar/cambiar esa restricción.

No debe descubrirse esta decisión cuando ya exista la UI.

### 4.4. Riesgo I-02 — “Columnas de comentarios” no están todavía cerradas como contrato

El mapping v3 no enumera estáticamente columnas de negocio editables. Delega en `usp_GetPunchExportColumnMap` y `IsEditableInExcel`.

Por tanto, antes de implementar Apply hay que fijar qué campos representan comentario editable. No debe asumirse que `LastCommentText` es editable: actualmente es una proyección/resumen del historial de comentarios.

Recomendación funcional:

- separar **historial de comentarios** de **campos de comentario importables**;
- definir explícitamente los `ColumnKey` autorizados para importación;
- mostrar en preview cada cambio como `OldValue → NewValue`;
- una celda vacía solo debe borrar contenido si el contrato lo define de forma inequívoca.

## 5. Arquitectura objetivo conjunta

```text
Punch Review
   │
   ├── Export
   │     ├── scope gobernado
   │     ├── CLIENT / INTERNAL
   │     ├── columnas permitidas
   │     └── snapshot + workbook v3
   │
   └── Import comments
         ├── upload INTERNAL workbook v3
         ├── stage
         ├── validate
         ├── diff
         ├── preview paginado
         ├── resolve/block conflicts
         ├── confirm
         ├── revalidate
         ├── apply transactionally
         └── audit + refresh Punch Review
```

## 6. Decisiones de UX

### Export

Se implementará como modal sobre `scr_PunchReview` porque es una operación breve y contextual.

Estados:

- `CONFIGURE`
- `GENERATING`
- `SUCCESS`
- `ERROR`

Contenido:

- proyecto y template;
- contexto de queue;
- perfil `CLIENT` / `INTERNAL`;
- selección/resumen de columnas;
- aviso de información sensible;
- aviso de dirty state;
- CTA único `Generate Excel`;
- enlace/acción de apertura al finalizar.

### Import

No debe ser un modal. La previsualización de cientos o miles de cambios necesita superficie, filtros y navegación.

Se propone una pantalla independiente `scr_PunchImport` con cuatro pasos:

1. **Upload**
2. **Validate & Preview**
3. **Confirm & Apply**
4. **Result**

## 7. Plan incremental recomendado

### Export Punch Review

- **PR-EXP-C01:** Action Toolbar + estado del modal.
- **PR-EXP-C02:** modal premium visual.
- **PR-EXP-C03:** contrato de scope exacto y captura/validación del flow activo.
- **PR-EXP-C04:** conexión real, loading, success/error, descarga.
- **PR-EXP-C05:** QA visual, dirty guard y regresión contra export de `scr_Punches`.

### Import comments

- **PR-IMP-C01:** contrato funcional de campos de comentario y semántica de blank/delete.
- **PR-IMP-C02:** backend stage + validation.
- **PR-IMP-C03:** backend preview paginado + conflictos.
- **PR-IMP-C04:** `scr_PunchImport` shell premium y upload.
- **PR-IMP-C05:** preview grid + filtros de estado.
- **PR-IMP-C06:** confirm + revalidate + commit + audit.
- **PR-IMP-C07:** integración Punch Review + refresh y QA.

## 8. Gate actual

Puede implementarse y validarse ya el modal premium de Export como superficie visual y punto de entrada.

No debe conectarse todavía el botón `Generate Excel` con una promesa falsa de “Current review queue” hasta resolver `E-03` y `E-04`.

La importación queda diseñada, pero el primer bloque funcional debe cerrar antes el contrato exacto de columnas de comentario.