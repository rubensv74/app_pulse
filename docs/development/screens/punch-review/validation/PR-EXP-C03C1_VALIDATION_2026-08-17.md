# PR-EXP-C03C1 — Validación del scope exacto sobre el SP pivotado

**Fecha:** 2026-08-17  
**Estado:** PASS  
**Objeto validado:** `warroom.usp_ExportProjectPunchesExtended_Pivoted`

## Resultado

Se ha validado que el procedimiento pivotado utilizado por el Flow de exportación puede recibir un scope exacto de Punch Review mediante el parámetro opcional:

```sql
@WorkItemIdsJson NVARCHAR(MAX) = NULL
```

La compatibilidad legacy se conserva cuando el parámetro no se envía.

## Evidencia ejecutada

### 1. Deployment

Resultado observado:

```text
WorkItemIdsParameterPresent  = 1
LegacyCallSignaturePreserved = 1
ExactScopeGuardInstalled     = 1
```

### 2. Prueba positiva

Contexto:

```text
ProjectId interno = 4049
ProjectCode visible = 70200
TemplateId = 20
Review Queue = 15 WorkItems
```

Resultado observado:

- ejecución correcta;
- 15 filas devueltas;
- los 15 `PunchId` pertenecen al payload de Review Queue;
- no aparecen filas ajenas al scope solicitado.

### 3. Prueba negativa

Se reemplazó uno de los 15 IDs válidos por `999999999`.

Resultado observado:

```text
Error 52116
Requested=15
Resolved=14
Unresolved/Ineligible/Filtered WorkItemIds=999999999
Partial export is forbidden.
```

PASS: el procedimiento bloquea el export parcial.

### 4. Smoke test legacy

Se ejecutó la firma anterior sin `@WorkItemIdsJson` y con un filtro deliberadamente sin filas.

Resultado observado:

- sin error de parámetros;
- sin error REVIEW_QUEUE;
- 0 filas, esperado para el smoke test.

PASS: la firma legacy continúa operativa.

## Conclusión

`PR-EXP-C03C1 = PASS`.

SQL queda preparado para conectar un Flow específico de Punch Review sin modificar el caller actual de `scr_Punches`.

Siguiente capacidad autorizada:

`PR-EXP-C03C2A — dedicated Punch Review export Flow`.
