# PR-EXP-C03B2 — Backend exacto para Review Queue

## Estado de entrada

PR-EXP-C03B1 ha quedado validado con el payload real de Punch Review:

- ProjectCode visible en PULSE: `70200`;
- ProjectId interno SQL: `4049`;
- TemplateId: `20`;
- RequestedCount: `15`;
- ResolvedCount: `15`;
- IsExactMatch: `1`;
- las 15 filas quedaron en `READY`.

Esto confirma que `colPunchReviewQueue.PunchIdNumber` / `WorkItemId` es el identificador correcto para construir el scope exacto.

---

# Descubrimiento real del 2026-08-17

El primer deployment C03B2 se detuvo correctamente con:

```text
PR-EXP-C03B2: target export procedure was not found.
```

La consulta de descubrimiento ejecutada en `db-homeoffice-dev` confirmó que el procedimiento activo es:

```text
warroom.usp_ExportProjectPunchesExtended
```

y que actualmente **no existe** en esa base:

```text
warroom.usp_ExportProjectPunchesExtended_Pivoted
```

La búsqueda sobre `sys.sql_modules` confirmó además que el procedimiento activo:

- consulta `dbo.wap_PunchPaged`;
- está relacionado con `PunchExportLog`;
- genera `RowHash`;
- expone `LastCommentText`;
- expone `NewComment`.

Por tanto, C03B2 debe extender el procedimiento activo no-pivotado. No se debe crear ni desplegar el procedimiento `_Pivoted` para resolver este gate.

Existe una irregularidad documental relevante: el snapshot de esquema del repositorio contiene definiciones para ambos procedimientos, mientras que la base real de desarrollo solo conserva el procedimiento no-pivotado. La base real prevalece para este incremento.

---

# Responsabilidad de este incremento

Extender el procedimiento real de exportación para que pueda trabajar en dos modos sin romper el comportamiento existente:

- **legacy / FILTERED_LIST**: `@WorkItemIdsJson = NULL`;
- **Punch Review / REVIEW_QUEUE**: `@WorkItemIdsJson` contiene la lista exacta de Punches.

Todavía **no se modifica Power Automate** y `Generate Excel` continúa deshabilitado.

---

# Regla de identificadores

En pantalla el usuario sigue viendo el código de proyecto `70200`.

El procedimiento SQL recibe el `ProjectId` interno que ya utiliza `dbo.wap_PunchPaged.ProjectId`. Para la sesión validada:

```text
ProjectCode visible = 70200
ProjectId SQL       = 4049
```

No se muestra `4049` al usuario.

---

# Qué cambia en el SP

Se añade un único parámetro opcional al final de:

```text
warroom.usp_ExportProjectPunchesExtended
```

Parámetro:

```sql
@WorkItemIdsJson NVARCHAR(MAX) = NULL
```

Al ser opcional y estar al final, los callers anteriores pueden seguir invocando el procedimiento sin enviarlo.

Cuando tiene valor, el procedimiento:

1. valida que sea un array JSON;
2. admite el contrato validado `[{"WorkItemId":123}, ...]` y también valores escalares numéricos;
3. valida IDs positivos;
4. rechaza duplicados;
5. exige `TemplateId`;
6. restringe el dataset a los IDs solicitados;
7. conserva las reglas existentes de proyecto, template, estado, jerarquía y demás filtros;
8. después de todos los filtros comprueba `RequestedCount = ResolvedCount`;
9. si falta un solo Punch, aborta toda la exportación;
10. si todo coincide, continúa con comments, custom fields, hash y dataset final exactamente como antes.

No existe exportación parcial silenciosa.

El deployment también corrige una irregularidad detectada en el primer borrador: `sys.sql_modules.definition` devuelve una definición `CREATE PROCEDURE`; antes de ejecutarla sobre el objeto existente, el script la transforma explícitamente en `ALTER PROCEDURE`.

---

# Archivos de este gate

## 1. Deployment corregido

`sql/export/004_pr_exp_c03b2_extend_export_sp_exact_scope.sql`

Este archivo modifica **solo la definición** de:

`warroom.usp_ExportProjectPunchesExtended`

No modifica Punches, Comments ni Custom Fields.

El script comprueba primero que la versión real del SP contiene los anchors conocidos. Si no los encuentra, se detiene antes de ejecutar `ALTER PROCEDURE`.

## 2. Test positivo real

`sql/export/tests/PR-EXP-C03B2_exact_scope_export_4049_template20.sql`

Usa los 15 WorkItemIds ya validados en C03B1.

Resultado esperado:

- ejecución sin error;
- exactamente 15 filas;
- los 15 `PunchId` coinciden con la Review Queue;
- `TotalRows = 15`;
- ningún Punch adicional.

## 3. Test negativo

`sql/export/tests/PR-EXP-C03B2_negative_scope_mismatch.sql`

Sustituye un ID por `999999999`.

Resultado esperado:

```text
Error 52116
Requested=15
Resolved=14
Partial export is forbidden
```

No debe devolver un dataset parcial.

## 4. Smoke test legacy

`sql/export/tests/PR-EXP-C03B2_legacy_signature_smoke.sql`

Invoca el procedimiento activo **sin** `@WorkItemIdsJson`.

Resultado esperado:

- no aparece error de parámetros;
- no aparece error de REVIEW_QUEUE;
- confirma que la ruta legacy continúa siendo invocable.

---

# Orden exacto de ejecución en SSMS

1. Cerrar o descartar la pestaña que contiene la versión anterior del deployment.

2. Abrir de nuevo desde GitHub la versión corregida:

   `sql/export/004_pr_exp_c03b2_extend_export_sp_exact_scope.sql`

3. Ejecutar el archivo completo.

4. Confirmar que el resultado final indica:

```text
ProcedureName = warroom.usp_ExportProjectPunchesExtended
WorkItemIdsParameterPresent = 1
LegacyCallSignaturePreserved = 1
ExactScopeGuardInstalled = 1
```

5. Ejecutar:
   `PR-EXP-C03B2_exact_scope_export_4049_template20.sql`

6. Verificar exactamente 15 filas y `TotalRows = 15`.

7. Ejecutar:
   `PR-EXP-C03B2_negative_scope_mismatch.sql`

8. Confirmar error `52116` y ausencia de resultado parcial.

9. Ejecutar:
   `PR-EXP-C03B2_legacy_signature_smoke.sql`

10. Confirmar que el SP sigue aceptando la firma anterior.

---

# Gate

PR-EXP-C03B2 solo queda aprobado si pasan las tres comprobaciones:

- exact scope positivo;
- mismatch negativo bloqueado;
- caller legacy sigue siendo invocable.

Después de este gate se actualizará/congelará la fuente canónica del SP y se abrirá **PR-EXP-C03C — integración Power Automate**, donde primero habrá que capturar o clonar de forma segura la definición real del flow de export actual.

Hasta entonces:

- no modificar `scr_Punches`;
- no modificar el flow productivo;
- no habilitar `Generate Excel`.
