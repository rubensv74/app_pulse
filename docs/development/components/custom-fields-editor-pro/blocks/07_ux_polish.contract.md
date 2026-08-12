# DF-07 — Custom Fields Editor UX Polish

**Tipo:** `C/I — Component / Integration`  
**Estado:** IN PROGRESS — DF-07A aplicado; DF-07A-FIX1 continuado por el usuario sin error reportado; DF-07B publicado y pendiente de validación en Power Apps Studio.

## Objetivo

Cerrar el acabado UX de `cmp_CustomFieldsEditorPro` después de la integración funcional DF-05/DF-06, sin modificar backend ni contratos de persistencia.

## DF-07A — Editor UX Polish

Corrige:

- Internal Key automático y bloqueado;
- barra inferior visible en alturas reales;
- compactación vertical de General / Behavior / Filtering / Options;
- toggles más compactos;
- Active only más compacto;
- microtipografía crítica;
- contexto real de proyecto;
- `DangerColor` vacío en la instancia modal.

Artefactos:

- `07A_editor_ux_polish.property-guide.md`
- `07A_GUIA_IMPLEMENTACION_Y_VALIDACION.md`

### Evidencia Studio posterior a DF-07A

La captura de validación del 2026-08-12 confirma mejora clara en:

- Internal Key generado automáticamente y no editable;
- Save / Cancel completamente visibles;
- contexto real `ProjectCode · ProjectName`;
- reducción del peso visual de los switches;
- mejor balance general del modal.

También reveló un defecto de segundo orden en `Filtering`, tratado como FIX aislado.

**Estado:** FUNCTIONAL / VISUAL PARTIAL.

## DF-07A-FIX1 — Filtering clipping y toggle density

Artefactos:

- `07A-FIX1_filtering_toggle_density.property-guide.md`
- `07A-FIX1_GUIA_IMPLEMENTACION_Y_VALIDACION.md`

Responsabilidad:

- ampliar horizontalmente los dos toggles de Filtering sin recuperar su altura original;
- mantener su semántica en una sola línea;
- separar correctamente toggles, captions e inputs;
- posicionar Options de forma relativa al final real de Filtering;
- cerrar la escala tipográfica de los toggles compactos;
- no tocar lógica, backend ni geometría macro.

**Estado:** continuado por el usuario sin error reportado; Power Apps Studio sigue siendo la autoridad de validación visual final.

## DF-07B — Visual finish

Artefactos:

- `07B_visual_finish.property-guide.md`
- `07B_GUIA_IMPLEMENTACION_Y_VALIDACION.md`

Responsabilidad:

- diferenciar `read-only` de `disabled` para mantener legibilidad en Filtering;
- eliminar coordenadas innecesariamente absolutas en el Live Preview;
- mejorar jerarquía y spacing interno del Preview sin añadir controles;
- centrar empty states respecto al alto real del host;
- validar Loading / Saving / Error / no-manager;
- ejecutar el second-order clipping pass completo;
- no modificar backend, persistencia ni geometría macro.

**Estado:** PUBLISHED / PENDING STUDIO VALIDATION.

## Congelado

- DF-05 backend;
- DF-06 modal integration;
- Save;
- Active/Inactive;
- OptionsJson;
- Comments;
- Review Progress;
- Custom Field Values;
- Dirty Guard;
- geometría macro de tres columnas.

## Regla de cierre

Power Apps Studio es la autoridad final.

DF-07 se cerrará cuando DF-07B supere la matriz visual en el host real. Después del PASS esperado:

```text
STRUCTURE      FROZEN
BEHAVIOR       FROZEN
DATA CONTRACT  FROZEN
VISUAL QA      APPROVED
COLOR          PENDING
```

Los ajustes exclusivamente cromáticos no deben reabrir estructura ni comportamiento.
