# PULSE — Diseño del workspace de importación de comentarios

**Pantalla propuesta:** `scr_PunchImport`  
**Origen principal:** `scr_PunchReview`  
**Estado:** diseño funcional/técnico; backend operativo pendiente.

## 1. Propósito

Permitir que un usuario autorizado:

1. exporte un workbook `INTERNAL` gobernado;
2. edite únicamente columnas de comentario autorizadas;
3. vuelva a cargar el Excel;
4. vea exactamente qué cambiaría;
5. detecte errores y conflictos antes de tocar producción;
6. confirme la operación;
7. aplique los cambios de forma auditada;
8. regrese a Punch Review con los datos refrescados.

Principio principal:

> **Upload nunca significa Apply.**

El fichero cargado solo crea/stagea un lote. La escritura sobre Punches/comentarios requiere validación, preview, confirmación y una revalidación final.

---

## 2. Por qué debe ser una pantalla y no un modal

El usuario necesita comparar valores antiguos/nuevos, revisar potencialmente miles de filas, filtrar errores, inspeccionar conflictos y entender el resultado de un lote.

Un modal sería adecuado para elegir un archivo, pero no para gobernar el ciclo completo.

`scr_PunchImport` debe ser un workspace premium de cuatro etapas.

---

## 3. Flujo de usuario

```text
Punch Review
    │
    ├─ Export > Internal / import-ready
    │
    └─ Import comments
          │
          ▼
   [1 Upload]
          │
          ▼
   [2 Validate & Preview]
          │
          ▼
   [3 Confirm & Apply]
          │
          ▼
   [4 Result]
          │
          └─ Return to Punch Review + refresh
```

---

# 4. Shell visual premium

## 4.1. Header

Contenido:

- eyebrow: `PUNCH REVIEW / DATA EXCHANGE`;
- título: `Import comment updates`;
- subtítulo: `Validate every Excel change before applying it to PULSE.`;
- Project badge;
- Template badge;
- Batch status badge;
- acción `Back to Punch Review`.

## 4.2. Stepper horizontal

Cuatro pasos:

1. Upload
2. Preview
3. Confirm
4. Result

Estados visuales:

- completed;
- current;
- upcoming;
- blocked/error.

## 4.3. Cuerpo

El cuerpo cambia según `varPunchImportStep`.

No usar navegación entre cuatro pantallas diferentes: una única `scr_PunchImport` mantiene el contexto del batch y cambia superficies.

---

# 5. Paso 1 — Upload

## 5.1. Zona principal

Card grande de carga:

- icono/documento Excel;
- `Choose an import-ready Excel file`;
- texto de ayuda;
- nombre de archivo;
- tamaño;
- fecha local de selección;
- botón `Validate file`.

## 5.2. Reglas antes de enviar

Validación cliente mínima:

- extensión `.xlsx`;
- archivo presente;
- proyecto activo;
- usuario identificado;
- ninguna operación previa en curso.

La seguridad real nunca depende de estas comprobaciones cliente.

## 5.3. Reglas backend obligatorias

El backend debe rechazar el archivo si falla cualquiera de estas condiciones:

- `ExportBatchId` no existe;
- export batch expirado/revocado;
- `ProjectId` no coincide;
- `TemplateId` no coincide;
- `WorkItemId` no pertenece al batch exportado;
- columna técnica manipulada;
- columna de negocio fuera del allowlist congelado;
- columna actualmente desautorizada por backend;
- checksum original inválido;
- filas duplicadas;
- formato/tipo/longitud inválidos;
- número de filas por encima del límite vigente.

---

# 6. Paso 2 — Validate & Preview

Este es el núcleo del módulo.

## 6.1. KPI strip

Mostrar:

- Total rows
- Changed
- Unchanged
- Warnings
- Errors
- Conflicts

Los contadores se alimentan del contrato `PULSE.PunchExcelImportBatchSummary/v1`.

## 6.2. Filtros rápidos

Tabs/chips:

- All
- Changed
- Conflicts
- Errors
- Warnings
- Unchanged

Default: `Changed` si no existen blockers; `Conflicts` o `Errors` si existen.

## 6.3. Grid de preview

Columnas visuales mínimas:

- status;
- Punch code;
- description corta;
- comment field;
- current value;
- incoming value;
- validation message.

Cada fila representa un cambio de un work item. Si una fila modifica varias columnas autorizadas, el detalle expandido debe mostrar un diff por campo.

### Patrón visual del diff

```text
P-001245  READY
P6 Comment
Current   Waiting for vendor confirmation.
Incoming  Vendor confirmed closure on 15 Aug.
```

Para un borrado autorizado:

```text
Current   Obsolete note.
Incoming  [CLEAR]
```

No mostrar una celda vacía como “borrado” sin semántica explícita.

## 6.4. Preview paginado

No cargar miles de filas en una sola colección Power Apps.

Contrato recomendado:

```text
usp_GetPunchImportPreviewPaged
  @ImportBatchId
  @StatusFilter
  @SearchText
  @PageNumber
  @PageSize
```

La respuesta debe incluir `TotalRows` para pager y los datos estrictamente necesarios para el grid.

---

# 7. Semántica de comentarios

Antes de escribir el backend Apply hay que cerrar esta decisión funcional.

## 7.1. Historial vs campo importable

`LastCommentText` es una proyección del historial, no debe convertirse automáticamente en una columna editable.

Los campos importables deben tener `ColumnKey` propios y autorización explícita mediante el mapa backend.

## 7.2. Recomendación

Para la primera versión, habilitar **solo los campos de comentario expresamente acordados** y denegar todo lo demás por defecto.

Cada columna debe definir:

- `ColumnKey`;
- display name;
- max length;
- editable yes/no;
- permite clear yes/no;
- mecanismo de persistencia;
- regla de auditoría.

## 7.3. Celda vacía

Recomendación segura para v1:

- blank = **sin cambio**;
- borrado = valor explícito/controlado, no vacío ambiguo.

Alternativa si negocio exige que blank borre:

- declararlo en contrato por columna;
- resaltarlo como cambio destructivo en preview;
- exigir confirmación visible.

---

# 8. Conflictos y concurrencia

El contrato v3 usa `RowChecksum` sobre el snapshot original.

Flujo:

1. export guarda original + checksum;
2. usuario edita Excel;
3. import carga incoming values;
4. backend reconstruye estado actual;
5. recalcula checksum;
6. si current != original, fila = `CONFLICT`;
7. un lote con conflictos no puede hacer commit.

No habrá `force overwrite` en v1.

Antes del Apply debe ejecutarse una **segunda revalidación**, porque el estado puede cambiar entre Preview y Confirm.

---

# 9. Paso 3 — Confirm & Apply

## 9.1. Condición de entrada

El botón `Apply changes` solo se habilita cuando:

```text
status = READY
canCommit = true
errorRows = 0
conflictRows = 0
changedRows > 0
```

## 9.2. Surface de confirmación

Mostrar:

- `231 changes ready to apply`;
- proyecto/template;
- columnas afectadas;
- usuario;
- advertencia de auditoría;
- checkbox/confirmación explícita: `I reviewed the preview and want to apply these changes.`

Botones:

- `Back to preview`
- `Apply changes`

## 9.3. Apply backend

Secuencia mínima:

```text
BEGIN
  lock/mark batch COMMITTING
  revalidate batch
  reject if errors/conflicts
  apply authorised changed fields
  write ImportAudit per applied field
  update row ApplyStatus
  update batch counters/status
COMMIT
```

El proceso debe ser idempotente: volver a invocar Commit sobre un batch `COMMITTED` no debe aplicar cambios por segunda vez.

---

# 10. Paso 4 — Result

## Success

Surface verde/neutra:

- `Import completed`;
- Applied rows;
- unchanged/skipped;
- batch ID corto;
- timestamp;
- `Return to Punch Review`.

Al volver:

- refrescar comentarios/datos relevantes;
- reconstruir queue si el cambio afecta información mostrada;
- mantener contexto de proyecto/template;
- registrar evento de sesión si procede.

## Failed / blocked

No mezclar fallo técnico con error de datos.

### BLOCKED

El archivo fue procesado, pero existen errores/conflictos corregibles.

### FAILED

La operación técnica no pudo completarse.

Ambos estados deben conservar un `ImportBatchId` cuando el backend haya llegado a crear el batch.

---

# 11. Contratos backend propuestos

## 11.1. Stage / Validate

Flow lógico:

`Warroom_StagePunchCommentImport`

Entrada conceptual:

- ProjectId
- file
- RequestedByEmail
- RequestedByName

Salida:

- `PULSE.PunchExcelImportBatchSummary/v1`

## 11.2. Preview paginado

`Warroom_GetPunchImportPreviewPaged`

Entrada:

- ImportBatchId
- StatusFilter
- SearchText
- PageNumber
- PageSize

Salida conceptual por fila:

- ImportBatchRowId
- ExcelRowNumber
- WorkItemId
- PunchCode
- Description
- ValidationStatus
- ChangedColumnsJson
- ValidationErrorsJson
- ValidationWarningsJson

## 11.3. Commit

`Warroom_CommitPunchCommentImport`

Entrada:

- ImportBatchId
- RequestedByEmail
- RequestedByName

Salida:

- `PULSE.PunchExcelImportBatchSummary/v1`

---

# 12. Estados Power Apps propuestos

```text
varPunchImportStep          "UPLOAD" | "PREVIEW" | "CONFIRM" | "RESULT"
varPunchImportBusy          Boolean
varPunchImportBatchId       Text
varPunchImportBatchStatus   Text
varPunchImportFileName      Text
varPunchImportCanCommit     Boolean
varPunchImportFilter        Text
varPunchImportSearch        Text
varPunchImportPage          Number
varPunchImportPageSize      Number
varPunchImportError         Text
```

Colecciones:

```text
colPunchImportPreview
colPunchImportSummary
```

No usar una colección local como autoridad para el estado del batch. SQL es la fuente de verdad.

---

# 13. Riesgo pendiente — reintentos de un mismo export

`warroom.ImportBatch` tiene actualmente `UNIQUE(ExportBatchId)`.

Antes de PR-IMP-C02 hay que elegir una política:

### Opción A — batch reutilizable

Un export genera un único ImportBatch que puede restagearse mientras no esté `COMMITTED`.

Ventaja: modelo simple.  
Riesgo: hay que limpiar/reemplazar staging de forma transaccional y auditable.

### Opción B — múltiples intentos

Permitir varios ImportBatch por ExportBatch y mantener historial de intentos.

Ventaja: auditoría más clara y reintentos naturales.  
Riesgo: requiere cambiar la restricción actual y definir cuál es el intento activo.

**Recomendación:** Opción B. El export es un snapshot; los imports son intentos sobre ese snapshot y deben poder auditarse independientemente.

---

# 14. Incrementos de implementación

## PR-IMP-C01 — Comment import contract

Cerrar columnas editables, clear semantics y persistencia.

**Gate:** contrato aprobado, sin UI.

## PR-IMP-C02 — Stage + validate SQL

Crear procedimientos y pruebas SQL.

**Gate:** un workbook válido queda `READY`; uno inválido queda `BLOCKED` sin tocar producción.

## PR-IMP-C03 — Preview paginado

Crear query/SP y contrato de filas.

**Gate:** old/current/incoming y conflictos verificables.

## PR-IMP-C04 — Screen shell + upload

Crear `scr_PunchImport` desde pantalla vacía.

**Gate:** shell premium + selección/carga de archivo + estados sintéticos.

## PR-IMP-C05 — Preview workspace

KPI strip, filtros y grid de diff.

**Gate:** preview real paginado.

## PR-IMP-C06 — Confirm + commit

Conectar revalidation/apply/audit.

**Gate:** operación idempotente y auditable.

## PR-IMP-C07 — Punch Review integration

Acción `Import comments`, retorno y refresh.

**Gate:** ciclo export → edit → import → preview → apply → review validado end-to-end.

---

# 15. Criterio de éxito del módulo

El usuario nunca debe preguntarse:

- qué archivo está importando;
- qué proyecto/template afecta;
- qué filas cambiarán;
- qué valor había antes;
- qué valor quedará después;
- qué filas están bloqueadas;
- si el botón Apply ya escribió o todavía no;
- quién aplicó los cambios;
- si un cambio concurrente puede ser sobrescrito silenciosamente.

Si cualquiera de esas preguntas queda ambigua, el diseño no está listo para producción.