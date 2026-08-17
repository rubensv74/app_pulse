# PR-EXP-C03C — Power Automate capture gate

## Estado

**GATED — falta definición real del flow activo**

## Objetivo

Conectar el Premium Export Modal de `scr_PunchReview` con la infraestructura real de Excel sin modificar a ciegas el export que ya utiliza `scr_Punches`.

## Evidencia disponible

El caller actual de Punch List invoca:

`Warroom_ExportPunchesToExcel_Codex`

El registro `power-automate/FLOW_COVERAGE.md` mantiene ese flow como:

`DEFINITION_MISSING`

Por tanto, el repositorio conoce la llamada desde Power Apps, pero todavía no contiene la definición real y desplegable del flow.

## Regla de seguridad

No modificar ni recrear `Warroom_ExportPunchesToExcel_Codex` por inferencia.

Antes de diseñar C03C se debe capturar la versión activa real y comprobar:

1. trigger Power Apps y parámetros de entrada;
2. orden y tipo de los parámetros;
3. SP SQL realmente ejecutado;
4. creación/inicio de `PunchExportLog`;
5. generación del workbook;
6. Office Script utilizado;
7. columnas CLIENT / INTERNAL;
8. snapshot `ExportBatch` / `ExportBatchRow`;
9. respuesta enviada de vuelta a Power Apps (`FileUrl`, estado, error, etc.);
10. manejo de errores y cleanup.

## Decisión arquitectónica pendiente

Tras capturar la definición real se elegirá una de estas dos rutas:

### Opción A — Extender el flow actual

Añadir `WorkItemIdsJson` como entrada opcional y mantener comportamiento legacy cuando esté vacío.

Solo es aceptable si la definición demuestra que el cambio puede hacerse sin alterar el caller de `scr_Punches`.

### Opción B — Flow específico de Punch Review

Crear un flow separado, por ejemplo:

`Warroom_ExportPunchReviewToExcel`

que reutilice las mismas piezas SQL / snapshot / Office Script, pero reciba obligatoriamente `WorkItemIdsJson`.

Esta opción es preferible si modificar el flow productivo añade riesgo innecesario.

## Gate que debe proporcionar el usuario

Capturar/exportar el flow activo `Warroom_ExportPunchesToExcel_Codex` desde el entorno donde funciona actualmente y añadir su definición al repositorio o adjuntarla para revisión.

No necesitamos todavía modificar nada en Power Apps.

## Después de capturar el flow

El siguiente incremento será muy concreto:

1. auditar la definición real;
2. decidir Opción A u Opción B;
3. implementar el parámetro exacto `WorkItemIdsJson`;
4. apuntar la consulta SQL a `warroom.usp_ExportProjectPunchesExtended` ya validado;
5. probar Review Queue 15 → Excel 15;
6. solo entonces habilitar `Generate Excel` en el modal.

## Estado de Generate Excel

Debe permanecer deshabilitado hasta superar este gate.