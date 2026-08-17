# PR-IMP-C04D — Typed runtime state

**Responsabilidad única:** inicializar el estado cliente tipado de `scr_PunchImport` sin modificar todavía la superficie visual ni conectar Flow/SQL.

## Qué cambia

Solo cambia una propiedad:

```text
scr_PunchImport > OnVisible
```

No sustituyas el Source Code completo de la pantalla para este incremento.

## Aplicación

1. Selecciona `scr_PunchImport`.
2. En el selector de propiedad elige `OnVisible`.
3. Abre `PR-IMP-C04D_runtime_state.onvisible.pa.yaml`.
4. Copia **únicamente la fórmula que aparece debajo de `OnVisible: |-`**, empezando por `=`.
5. Sustituye completamente la fórmula OnVisible actual.
6. Guarda.
7. Sal de la pantalla y vuelve a entrar para forzar `OnVisible`.
8. Ejecuta App Checker.

## Variables tipadas que deben existir

Estado principal:

- `varPunchImportStep = 1`
- `varPunchImportBusy = false`
- `varPunchImportBatchId = ""`
- `varPunchImportBatchStatus = "NOT_STARTED"`
- `varPunchImportFileName = ""`
- `varPunchImportFileSize = 0`
- `varPunchImportHasFile = false`
- `varPunchImportCanCommit = false`
- `varPunchImportFilter = "ALL"`
- `varPunchImportSearch = ""`
- `varPunchImportPage = 1`
- `varPunchImportPageSize = 50`
- `varPunchImportError = ""`
- `varPunchImportMessage = ""`
- todos los counters = `0`
- `varPunchImportSelectedRowId = 0`
- `varPunchImportRuntimeReady = true`

## Colecciones

Deben existir, pero estar vacías:

```text
colPunchImportSummary
colPunchImportPreview
```

Se crean primero con un registro tipado y se limpian inmediatamente. Esto establece un esquema cliente estable sin convertir Power Apps en fuente de verdad.

## Gate

PASS cuando:

- la pantalla sigue renderizando C04C sin cambios visuales;
- `Upload` continúa como Current step;
- Batch status continúa `NOT STARTED`;
- las dos colecciones existen y tienen 0 filas;
- `varPunchImportRuntimeReady = true`;
- no hay error nuevo en App Checker.

## STOP

No avanzar a C04E si aparece cualquier error de fórmula o tipado.

## Siguiente incremento tras PASS

`PR-IMP-C04E — Upload surface + synthetic file-selection states`.
