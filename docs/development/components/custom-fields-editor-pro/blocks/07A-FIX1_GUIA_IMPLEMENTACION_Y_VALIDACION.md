# DF-07A-FIX1 — Guía de implementación y validación

## Objetivo

Eliminar el clipping residual de `Filtering` detectado después de DF-07A y cerrar la densidad visual de los toggles sin tocar backend ni la arquitectura de tres columnas.

## Orden de implementación

### Paso 1 — Filtering panel

Seleccionar:

`cmp_CustomFieldsEditorPro → conCFDEPro_Editor → conCFDEPro_Form → conCFDEPro_FilteringPanel`

Aplicar primero `Y=236` y `Height=96` según `07A-FIX1_filtering_toggle_density.property-guide.md`.

### Paso 2 — Toggle Filterable

Seleccionar `tglCFDEPro_Filterable` y aplicar únicamente:

- `Height`
- `Width`
- `X`
- `Y`
- `Size`

No tocar su lógica.

Validar visualmente antes de continuar: `Not filterable` debe quedar en una sola línea.

### Paso 3 — Toggle Quick Filter

Aplicar el mismo criterio a `tglCFDEPro_QuickFilter`.

Validar OFF y ON:

- `More filters`
- `Quick filter`

Ambos deben aparecer completos.

### Paso 4 — Fila inferior

Ajustar captions `Filter mode` / `Filter order` y después sus dos inputs.

Comprobar que existe separación vertical entre la fila de toggles y la fila de configuración.

### Paso 5 — Options

Cambiar únicamente `conCFDEPro_OptionsEditor.Y` por la fórmula relativa al final real de `conCFDEPro_FilteringPanel`.

No modificar la serialización de opciones ni el `Height` responsive de DF-07A.

### Paso 6 — Densidad tipográfica de toggles

Aplicar `Size=8` a Requirement / Pinning / Availability / Active only y `Size=6` a sus captions según la guía principal.

### Paso 7 — Hint inferior

Aplicar `Size=6` a `lblCFDEPro_FormActionsHint`.

No mover Save / Cancel.

## Smoke test obligatorio

Probar como mínimo estas combinaciones:

1. `Text` + Not filterable.
2. `Text` + Filterable + More filters.
3. `Text` + Filterable + Quick filter.
4. `Choice` + Filterable + al menos tres Options.
5. `MultiChoice` + Filterable + Quick filter.
6. Definition existing en `EDIT` con `Active` ON y OFF.

## Gate visual

No avanzar a DF-07B hasta que se cumplan simultáneamente:

- cero clipping en Filtering;
- cero solapamiento con Filter mode / Filter order;
- cero solapamiento Options / footer;
- Save / Cancel completamente visibles;
- todos los toggles legibles en una línea;
- ninguna regresión funcional.

## Estado tras PASS

`DF-07A-FIX1 = VISUAL_APPROVED` y se puede iniciar `DF-07B — Visual Finish`.
