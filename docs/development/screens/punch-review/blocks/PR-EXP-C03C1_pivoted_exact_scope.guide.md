# PR-EXP-C03C1 — Exact Review Queue scope en el SP pivotado

**Estado:** READY FOR SQL GATE  
**Fecha:** 2026-08-17  
**Rama:** `feature/pr-exp-c03-exact-review-queue`

## Qué cambia

El Flow real `Warroom_ExportPunchesToExcel_Codex` ejecuta:

```text
warroom.usp_ExportProjectPunchesExtended_Pivoted
```

Ese procedimiento ha sido recuperado en la base de datos. C03C1 añade un único parámetro opcional al final de su firma:

```sql
@WorkItemIdsJson NVARCHAR(MAX) = NULL
```

La regla es sencilla:

- si `@WorkItemIdsJson` no se envía, el export de `scr_Punches` conserva su comportamiento anterior;
- si se envía desde Punch Review, el procedimiento solo puede devolver exactamente esos Punches;
- si falta uno, el procedimiento bloquea todo el export;
- nunca se permite un Excel parcial silencioso.

## Importante: 70200 y 4049

PULSE muestra al usuario el código de proyecto `70200`.

En `dbo.wap_PunchPaged`, los Punches de ese proyecto usan el identificador interno:

```text
ProjectId = 4049
```

El Flow actual recibe el identificador interno de Power Apps. El usuario no necesita conocer `4049`.

## Paso 1 — desplegar el cambio

Abrir y ejecutar completo:

```text
sql/export/005_pr_exp_c03c1_extend_pivoted_export_exact_scope.sql
```

Resultado esperado:

```text
ProcedureName                    warroom.usp_ExportProjectPunchesExtended_Pivoted
WorkItemIdsParameterPresent      1
LegacyCallSignaturePreserved     1
ExactScopeGuardInstalled         1
```

Si aparece un error de `anchor was not found`, detenerse. El script está diseñado para no modificar el procedimiento si la definición recuperada difiere de la baseline esperada.

## Paso 2 — gate positivo

Solo después de que el Paso 1 devuelva los tres indicadores en `1`, ejecutar:

```text
sql/export/tests/PR-EXP-C03C1_pivoted_exact_scope_export_4049_template20.sql
```

Resultado esperado:

- exactamente 15 filas;
- los 15 `PunchId` coinciden con la Review Queue validada;
- `TotalRows = 15`;
- se mantiene la forma pivotada que consume el Flow/Office Script;
- ningún Punch extra.

## Paso 3 — gate negativo

Después de validar el positivo, ejecutar:

```text
sql/export/tests/PR-EXP-C03C1_pivoted_negative_scope_mismatch.sql
```

Resultado esperado:

```text
Error 52216
Requested=15
Resolved=14
```

El ID ficticio `999999999` debe aparecer como no resuelto. No deben devolverse 14 filas parciales.

## Paso 4 — compatibilidad con el Flow existente

Ejecutar:

```text
sql/export/tests/PR-EXP-C03C1_pivoted_legacy_signature_smoke.sql
```

Resultado esperado:

- sin error de parámetros;
- sin error de `REVIEW_QUEUE`;
- cero filas es aceptable;
- la ausencia de `@WorkItemIdsJson` mantiene el comportamiento legacy.

## Gate de cierre C03C1

C03C1 solo se considera `PASS` cuando se cumplen los cuatro puntos:

1. deployment = PASS;
2. exact queue 15/15 = PASS;
3. partial export blocked = PASS;
4. legacy signature = PASS.

## Qué NO hacer todavía

No modificar todavía:

- el trigger de Power Automate;
- `SQL_ExportPunchesPivoted` dentro del Flow;
- el botón `Generate Excel` del modal;
- el export actual de `scr_Punches`.

El siguiente incremento, una vez cerrado C03C1, será `PR-EXP-C03C2`: versionar la definición real del Flow, añadir `WorkItemIdsJson` de forma compatible y conectar el nuevo camino de Punch Review.
