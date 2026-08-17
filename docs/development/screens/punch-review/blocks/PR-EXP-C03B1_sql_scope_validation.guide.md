# PR-EXP-C03B1 — Validación SQL del scope exacto de Punch Review

**Objetivo del incremento:** comprobar en SQL que el payload generado por Punch Review resuelve exactamente el mismo número de Punches que contiene la Review Queue.

Este bloque **no modifica el export actual de `scr_Punches`**, **no genera Excel** y **no toca Power Automate**.

El procedimiento creado es:

```text
warroom.usp_ValidatePunchReviewExportScope
```

Archivo SQL:

```text
sql/export/003_validate_punch_review_export_scope.sql
```

---

## 1. Qué ya está validado

La captura de Power Apps Studio confirma que C03A llega al estado:

```text
Exact Review Queue scope ready · 15 WorkItems serialized · backend connection pending.
```

Por tanto, para la prueba actual:

```text
ProjectId = 70200
TemplateId = 20
Expected Review Queue Count = 15
```

Antes de continuar, si App Checker muestra un error nuevo asociado a C03A, detener el bloque y corregirlo.

---

## 2. Ejecutar el script de instalación

Abre en SQL Server / SSMS / Azure Data Studio el archivo:

```text
sql/export/003_validate_punch_review_export_scope.sql
```

Ejecuta el archivo completo.

Resultado esperado:

```text
Commands completed successfully.
```

Esto crea o actualiza únicamente:

```text
warroom.usp_ValidatePunchReviewExportScope
```

No se actualiza ninguna tabla productiva.

---

## 3. Copiar el payload real desde Power Apps Studio

En Power Apps Studio abre:

```text
Variables > Global variables
```

Busca:

```text
varPRExportWorkItemIdsJson
```

Copia el valor completo. Debe tener 15 objetos para la cola que estás utilizando ahora.

Ejemplo de forma, no utilizar estos IDs ficticios:

```json
[{"WorkItemId":100234},{"WorkItemId":100235},{"WorkItemId":100241}]
```

---

## 4. Prueba positiva

Ejecuta esta consulta sustituyendo **SOLO** el contenido de `@WorkItemIdsJson` por el valor real copiado desde Power Apps:

```sql
DECLARE @WorkItemIdsJson NVARCHAR(MAX) = N'PEGAR_AQUI_EL_JSON_REAL';

EXEC [warroom].[usp_ValidatePunchReviewExportScope]
    @ProjectId = 70200,
    @TemplateId = 20,
    @WorkItemIdsJson = @WorkItemIdsJson;
```

### Resultado esperado — Result set 1

Debe devolver:

```text
ProjectId       70200
TemplateId      20
ExportScope     REVIEW_QUEUE
RequestedCount  15
ResolvedCount   15
IsExactMatch    1
```

### Resultado esperado — Result set 2

Debe devolver exactamente 15 filas, una por cada WorkItem de la Review Queue, con:

- `RequestedOrdinal`;
- `WorkItemId`;
- `PunchCode`;
- `TemplateId`;
- `StatusCode`;
- `PunchDiscipline`;
- `ResolutionStatus = READY`.

El orden de este segundo resultado conserva el orden del payload recibido desde Power Apps y sirve únicamente para inspección de este gate.

---

## 5. Prueba negativa obligatoria — ID inexistente

No cambies la colección de Power Apps.

Haz una copia del JSON en SQL y añade al final un ID claramente inexistente, por ejemplo:

```json
{"WorkItemId":999999999}
```

Ejemplo de ejecución:

```sql
DECLARE @WorkItemIdsJson NVARCHAR(MAX) =
N'[
  {"WorkItemId":ID_REAL_1},
  {"WorkItemId":ID_REAL_2},
  {"WorkItemId":999999999}
]';

EXEC [warroom].[usp_ValidatePunchReviewExportScope]
    @ProjectId = 70200,
    @TemplateId = 20,
    @WorkItemIdsJson = @WorkItemIdsJson;
```

Resultado esperado:

```text
Error 52007
Review Queue export scope mismatch...
Partial export is forbidden.
```

La operación debe fallar completamente. No debe devolver un subconjunto como si fuera válido.

---

## 6. Prueba negativa recomendada — duplicado

Duplica uno de los objetos reales dentro del JSON.

Resultado esperado:

```text
Error 52006
WorkItemIdsJson contains duplicate WorkItemId values.
```

---

## 7. Qué valida exactamente este gate

Si la prueba positiva devuelve `15 / 15 / IsExactMatch = 1`, queda confirmado que:

1. Power Apps está entregando una lista técnicamente válida;
2. los 15 IDs existen para el proyecto 70200;
3. pertenecen al Template 20;
4. cumplen la elegibilidad base del export actual;
5. tienen relación en `wap_ElementHierarchyPunchView`, igual que exige el export actual;
6. un ID no resoluble bloquea la operación completa;
7. no se permiten duplicados.

---

# Qué NO hacer todavía

No modificar todavía:

- `Warroom_ExportPunchesToExcel_Codex`;
- el botón `Generate Excel`;
- `scr_Punches`;
- `warroom.usp_ExportProjectPunchesExtended_Pivoted` en el entorno real.

El procedimiento de este bloque es un validador aislado precisamente para reducir el riesgo antes de alterar el export que ya funciona.

---

# Gate siguiente

Cuando la prueba real SQL sea correcta, continuaremos con:

## PR-EXP-C03B2 — integración exacta en el SP de export

Entonces sí:

- se añadirá `@WorkItemIdsJson NVARCHAR(MAX) = NULL` al final de `warroom.usp_ExportProjectPunchesExtended_Pivoted`;
- `NULL` conservará el comportamiento legacy de Punch List;
- un payload informado limitará `#BaseKey` al conjunto exacto;
- se comprobará `requestedCount = resolvedCount` antes de comentarios, custom fields, hash y snapshot;
- se hará una prueba de regresión del export existente.

Después de B2 seguirá pendiente la captura del flow real antes de conectar `Generate Excel`.
