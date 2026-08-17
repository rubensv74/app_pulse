# PR-EXP-C03 — Contrato de exportación exacta de Review Queue

**Estado:** diseño cerrado / pendiente de validación backend  
**Pantalla origen:** `scr_PunchReview`  
**Colección origen:** `colPunchReviewQueue`  
**Objetivo:** garantizar que el Excel generado desde Punch Review contiene exactamente el conjunto de Punches de la Review Queue activa.

## 1. Problema que resuelve

El export actual de `scr_Punches` trabaja con filtros funcionales y no recibe una lista explícita de Punches. Una Review Queue puede ser un subconjunto ya construido por la pantalla origen y, por tanto, reconstruirla únicamente a partir de filtros puede producir un Excel distinto de lo que el usuario está revisando.

PR-EXP-C03 introduce un **scope explícito por WorkItemId**.

La regla funcional es:

> Si Punch Review muestra N Punches en `colPunchReviewQueue`, el backend debe validar y exportar exactamente esos N Punches. No se permite una exportación parcial silenciosa ni una ampliación accidental del alcance.

## 2. Identificador canónico

En Power Apps el identificador está disponible como:

`colPunchReviewQueue.PunchIdNumber`

En el contrato de integración se denomina:

`WorkItemId`

En SQL sigue resolviendo contra:

`wap_PunchPaged.Id` / `PunchId`

Esto mantiene la compatibilidad con el contrato Excel v3, donde `WorkItemId` es el nombre técnico canónico del libro y `PunchId` permanece como columna legacy/compatibilidad.

## 3. Payload de scope

Nombre del parámetro propuesto:

`WorkItemIdsJson`

Formato v1:

```json
[
  { "WorkItemId": 100234 },
  { "WorkItemId": 100235 },
  { "WorkItemId": 100241 }
]
```

### Reglas obligatorias

- Debe ser un array JSON válido.
- No puede estar vacío cuando el export se ejecuta en modo `REVIEW_QUEUE`.
- Cada `WorkItemId` debe ser entero positivo.
- No se admiten duplicados.
- Todos los IDs deben pertenecer al `ProjectId` solicitado.
- Cuando exista `TemplateId`, todos los IDs deben pertenecer a ese template.
- Todos los IDs deben ser elegibles según las reglas ya existentes del export (`StatusCode` informado y no `HOLD`/`VOID`).
- La cardinalidad final debe coincidir exactamente con la cardinalidad solicitada.
- Si un solo ID no resuelve, el backend debe **bloquear la exportación completa** y devolver error; nunca generar un fichero parcial.

## 4. Separación de conceptos

A partir de este contrato no deben mezclarse:

### ExportScope

Valores previstos:

- `FILTERED_LIST` — export actual de `scr_Punches`.
- `REVIEW_QUEUE` — export exacto desde `scr_PunchReview`.

### ExportProfile

Valores previstos:

- `CLIENT` — campos aptos para distribución externa.
- `INTERNAL` — workbook gobernado/import-ready.

`FILTERED` no es un perfil y no debe volver a utilizarse como fallback de `ExportProfile`.

## 5. Contrato de flow recomendado

Para no introducir una regresión en el export productivo de Punch List, la opción preferida es crear un flow específico/versionado para Punch Review reutilizando las acciones internas del flow actual una vez que su definición real haya sido capturada.

Nombre propuesto:

`Warroom_ExportPunchReviewToExcel`

Entradas mínimas:

1. `ProjectId` — Number
2. `TemplateId` — Number
3. `WorkItemIdsJson` — Text
4. `RequestedByEmail` — Text
5. `RequestedByName` — Text
6. `ExportProfile` — Text (`CLIENT` / `INTERNAL`)
7. `SelectedColumnsJson` — Text

Salidas mínimas:

- `success` — Boolean
- `fileUrl` — Text
- `fileName` — Text
- `rowCount` — Number
- `exportBatchId` — Text/Number según contrato real del flow actual
- `errorCode` — Text
- `errorMessage` — Text

## 6. Cambio SQL previsto

El procedimiento existente:

`warroom.usp_ExportProjectPunchesExtended_Pivoted`

debe ampliarse de forma **retrocompatible** con un parámetro opcional final:

```sql
@WorkItemIdsJson NVARCHAR(MAX) = NULL
```

Cuando sea `NULL`, el comportamiento actual de `scr_Punches` debe permanecer intacto.

Cuando tenga valor:

1. validar JSON;
2. cargar IDs en una tabla temporal;
3. limitar `#BaseKey` a esos IDs;
4. aplicar las validaciones de contexto existentes;
5. comparar `requestedCount` frente a `resolvedCount`;
6. abortar si no coinciden;
7. continuar con comments, custom fields, checksum, snapshot y workbook usando únicamente el conjunto validado.

## 7. Orden de las filas

La versión v1 garantiza el **conjunto exacto**, no el orden visual de la Review Queue. El procedimiento mantiene el orden canónico del export actual (Subsystem / Discipline / Element / PunchId).

Si más adelante se considera necesario replicar también `ReviewOrder`, se versionará el payload sin romper este contrato.

## 8. Dirty state

La presencia de cambios sin guardar en `colPunchReviewFieldsDirty` no modifica el scope.

El modal debe advertir al usuario porque el export backend leerá los valores persistidos, no los cambios locales aún no guardados.

## 9. Gate de aceptación de C03

La validación funcional mínima será:

1. abrir Punch Review con una Review Queue conocida;
2. registrar N = `CountRows(colPunchReviewQueue)`;
3. ejecutar export;
4. comprobar que la respuesta del backend declara `rowCount = N`;
5. abrir el Excel y comprobar que contiene exactamente N filas de Punch;
6. verificar por muestreo y por IDs que no aparece ningún Punch fuera de la Review Queue;
7. eliminar temporalmente un ID válido del contexto esperado y confirmar que el backend bloquea el export en lugar de generar un fichero parcial;
8. confirmar que el export existente de `scr_Punches` sigue funcionando sin `WorkItemIdsJson`.

## 10. Gate real antes de conectar Generate Excel

El repositorio no contiene todavía la definición real de `Warroom_ExportPunchesToExcel_Codex`; `power-automate/FLOW_COVERAGE.md` lo mantiene como `DEFINITION_MISSING`.

Por tanto, antes de crear o clonar el flow de Punch Review hay que capturar la definición activa y verificar:

- parámetros reales y su orden;
- acciones SQL utilizadas;
- Office Script utilizado;
- construcción de `RowsJson`;
- registro de snapshot;
- contrato de respuesta y error.

Hasta completar esa captura, `Generate Excel` debe permanecer deshabilitado.