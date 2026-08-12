# DF-07 — Custom Fields Editor UX Polish

**Tipo:** `C/I — Component / Integration`  
**Estado:** PAUSED FOR HOST RECOMPOSITION — DF-07A aplicado; DF-07A-FIX1 y DF-07B continuados sin nuevo error reportado; DF-07C publicado. El cierre visual/documental se pausa hasta completar `C17 — Punch Review Workspace Recomposition`.

## Objetivo

Cerrar el acabado UX de `cmp_CustomFieldsEditorPro` después de la integración funcional DF-05/DF-06, sin modificar backend ni contratos de persistencia.

## Motivo de la pausa

La validación del host real ha generado una decisión estructural posterior: Punch Review va a redistribuir Comments, Custom Fields, Session Activity y Review Progress, además de modernizar `cmp_CustomFieldValuesPro`.

No es eficiente declarar el cierre visual definitivo de DF-07 mientras la geometría del workspace donde se consume todavía va a cambiar.

Contrato de la recomposición:

`docs/development/screens/punch-review/blocks/C17_workspace_recomposition.contract.md`

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

Artefactos ya publicados:

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

**Estado:** PUBLICADO / CIERRE VISUAL APLAZADO HASTA C17.

## DF-07C — Accessibility / keyboard / focus

Artefactos:

- `07C_accessibility_keyboard_focus.property-guide.md`
- `07C_GUIA_IMPLEMENTACION_Y_VALIDACION.md`

Responsabilidad:

- asegurar participación coherente de controles interactivos en la navegación por teclado;
- usar `TabIndex=0` para controles clásicos interactivos y foco visible;
- usar `AcceptsFocus` en controles modernos cuando la versión exacta lo exponga en Studio;
- evitar tab stops inútiles en controles read-only, especialmente Internal Key;
- validar estados ADD/EDIT, Filterable, Choice/MultiChoice, Loading, Saving y Reader;
- no introducir `AccessibleLabel` en `Classic/Button@2.2.0` por incompatibilidad PULSE ya confirmada;
- documentar la limitación de accesibilidad inherente al modal overlay Canvas sin intentar construir un focus trap manual.

**Estado:** PUBLISHED / PENDING STUDIO VALIDATION.

## DF-07D — Help + documentación

Pendiente después de estabilizar C17 y completar el gate DF-07C.

Alcance previsto:

- actualizar la ayuda bilingüe de Punch Review para explicar Manage / Definitions;
- actualizar `MANUAL_USUARIO_PUNCH_REVIEW.md` con Review Progress, Dirty Guard y administración de definiciones;
- retirar limitaciones ya superadas del manual;
- consolidar documentación reutilizable de `cmp_CustomFieldsEditorPro`;
- decidir qué fuente se considera canonical después de la última copia validada desde Studio.

## Congelado durante C17

- DF-05 backend;
- DF-06 modal integration;
- Save;
- Active/Inactive;
- OptionsJson;
- Dirty Guard;
- definición funcional del modal `cmp_CustomFieldsEditorPro`.

La geometría macro del **host Punch Review** deja de estar congelada únicamente para el alcance declarado en C17.

## Regla de cierre

Power Apps Studio es la autoridad final.

DF-07 se reanudará sobre el host estabilizado por C17. El estado objetivo sigue siendo:

```text
STRUCTURE      FROZEN
BEHAVIOR       FROZEN
DATA CONTRACT  FROZEN
VISUAL QA      APPROVED
KEYBOARD QA    APPROVED
HELP / DOCS    CURRENT
COLOR          PENDING
```

Los ajustes exclusivamente cromáticos no deben reabrir estructura ni comportamiento.