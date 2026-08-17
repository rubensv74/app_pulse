# PR-EXP-C03B2 — Evidencia de validación

**Fecha:** 2026-08-17  
**Estado:** PASS

## Objetivo

Validar que el backend de exportación puede trabajar con una Review Queue exacta sin romper la ruta legacy de Punch List.

## Procedimiento activo confirmado

`warroom.usp_ExportProjectPunchesExtended`

La base `db-homeoffice-dev` no contiene `warroom.usp_ExportProjectPunchesExtended_Pivoted`.

## Evidencia ejecutada

### 1. Deployment

El deployment de `004_pr_exp_c03b2_extend_export_sp_exact_scope.sql` finalizó correctamente y devolvió:

- `WorkItemIdsParameterPresent = 1`
- `LegacyCallSignaturePreserved = 1`
- `ExactScopeGuardInstalled = 1`

### 2. Exact scope positivo

Contexto validado:

- ProjectCode visible: `70200`
- ProjectId SQL: `4049`
- TemplateId: `20`
- Review Queue solicitada: `15`

Resultado:

- se devolvieron exactamente 15 filas;
- los `PunchId` coincidieron con los 15 WorkItemId solicitados;
- no apareció ningún Punch ajeno a la Review Queue.

### 3. Exact scope negativo

Se sustituyó un WorkItemId válido por `999999999`.

Resultado observado:

```text
Msg 52116
Review Queue export scope mismatch.
Requested=15; Resolved=14;
Unresolved/Ineligible/Filtered WorkItemIds=999999999.
Partial export is forbidden.
```

PASS: no se devolvió un dataset parcial.

### 4. Smoke test legacy

Se ejecutó `warroom.usp_ExportProjectPunchesExtended` sin `@WorkItemIdsJson`.

Resultado:

- sin error de parámetros;
- sin error de REVIEW_QUEUE;
- dataset vacío aceptable por usar `StatusCode = HOLD` deliberadamente.

PASS: la firma anterior sigue siendo invocable.

## Conclusión

`PR-EXP-C03B2 = PASS`.

El backend SQL ya soporta dos rutas:

- legacy / filtered export cuando `@WorkItemIdsJson` es NULL;
- exact Review Queue cuando `@WorkItemIdsJson` contiene la lista solicitada.

## Siguiente gate

`PR-EXP-C03C — integración Power Automate`.

No habilitar todavía `Generate Excel` hasta capturar y validar la definición real del flow activo `Warroom_ExportPunchesToExcel_Codex`.