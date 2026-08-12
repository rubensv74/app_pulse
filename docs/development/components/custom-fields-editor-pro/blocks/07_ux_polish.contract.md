# DF-07 — Custom Fields Editor UX Polish

**Tipo:** `C/I — Component / Integration`  
**Estado:** IN PROGRESS — DF-07A aplicado en Studio; mejora confirmada visualmente; DF-07A-FIX1 publicado para resolver clipping residual de Filtering antes de DF-07B.

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

También revela un defecto residual producido por la compactación:

- `Not filterable` / `More filters` disponen de ancho insuficiente;
- el texto se envuelve o recorta y se aproxima a la fila `Filter mode / Filter order`.

**Estado:** FUNCTIONAL / VISUAL PARTIAL — requiere FIX antes de congelar.

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

**Estado:** PUBLISHED / PENDING STUDIO VALIDATION.

## DF-07B — Visual finish

Bloque posterior, condicionado al PASS de DF-07A-FIX1.

Alcance previsto:

- revisar spacing fino de Preview y Catalog;
- confirmar balance vertical y uso del espacio sin llenar superficies de forma artificial;
- comprobar estados loading / saving / error / disabled;
- ejecutar second-order clipping pass sobre todos los tipos de campo;
- acabado visual final;
- sin cambios de backend ni comportamiento.

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

No se declara DF-07A `VISUAL_APPROVED` mientras el clipping residual siga presente. El protocolo exige resolverlo mediante DF-07A-FIX1 antes de iniciar DF-07B.
