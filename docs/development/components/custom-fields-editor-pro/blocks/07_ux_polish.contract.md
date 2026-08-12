# DF-07 — Custom Fields Editor UX Polish

**Tipo:** `C/I — Component / Integration`  
**Estado:** IN PROGRESS — DF-07A publicado, pendiente de validación en Power Apps Studio.

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

**Estado:** PUBLISHED / PENDING STUDIO VALIDATION.

## DF-07B — Visual finish

Bloque posterior, condicionado a la validación de DF-07A.

Alcance previsto:

- aprovechar mejor el espacio de Live Preview;
- revisar spacing fino;
- revisar balance vertical del catálogo;
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

Power Apps Studio es la autoridad final. DF-07A solo se declara validado después de confirmar visual y funcionalmente los casos de la guía.
