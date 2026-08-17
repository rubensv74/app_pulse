# PR-IMP-C04C — Premium stepper

**Responsabilidad única:** añadir el stepper visual `Upload → Preview → Confirm → Result` manteniendo todavía sin conectar upload real, Flow, SQL, preview o commit.

## Aplicación

1. Abre `scr_PunchImport`.
2. Abre **Source Code**.
3. Sustituye TODO por `PR-IMP-C04C_scr_PunchImport_stepper.pa.yaml`.
4. La primera clave real debe ser `Screens:`.
5. Guarda y espera la validación de Studio.
6. Ejecuta App Checker.
7. Navega a `scr_PunchImport`.

## Estado sintético

Este bloque inicializa deliberadamente:

```powerfx
Set(varPunchImportStep, 1)
```

Por tanto, el primer estado esperado es:

- `Upload` = current step;
- `Preview` = pending;
- `Confirm` = pending;
- `Result` = pending.

La variable es numérica desde su primera asignación, conforme al registro de compatibilidad PULSE.

## Gate visual esperado

Debajo del header debe aparecer una card `IMPORT PROGRESS` con cuatro bloques horizontales:

1. Upload
2. Preview
3. Confirm
4. Result

`Upload` debe aparecer destacado en azul. Los otros tres pasos deben aparecer neutros.

El header C04B debe conservar Project, Punch template, Batch status, Back y `COMMENTS ONLY · V1`.

## PASS

- no `PA1001`;
- no `PA2108`;
- no error de fórmula asociado a `varPunchImportStep`;
- los cuatro pasos son visibles simultáneamente;
- `Upload` aparece como current step;
- no desaparece ninguna pieza validada de C04B.

## STOP

Ante cualquier error, no avanzar a C04D. Enviar captura, mensaje exacto y Session ID si existe.

## Siguiente bloque tras PASS

`PR-IMP-C04D — Runtime state`: variables tipadas y colecciones mínimas para preparar upload, staging y preview reales.
