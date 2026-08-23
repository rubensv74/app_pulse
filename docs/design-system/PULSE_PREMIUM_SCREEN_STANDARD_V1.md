# PULSE — Premium Screen Standard V1

**Estado:** `MANDATORY / PRODUCT-WIDE`  
**Fecha:** 2026-08-23

## Regla de producto

Toda pantalla presente o futura de PULSE debe pertenecer al mismo lenguaje visual premium. Los arquetipos pueden variar, pero shell, tipografía, spacing, geometría, interacción, estados y componentes compartidos deben proceder del PULSE Design System.

Fuentes canónicas:

- `docs/design-system/PULSE_DESIGN_SYSTEM.md`;
- `docs/design-system/SAAS_INTERFACE_ARCHETYPES.md`;
- `docs/design-system/COMPONENT_CATALOG.md`;
- `docs/design-system/POWER_APPS_VISUAL_QA_GUARDRAILS.md`;
- `docs/design-system/PULSE_PAGE_HEADER_HIERARCHY_V1.md`.

## Anatomía premium

```text
PULSE Shell
  ├─ Sidebar / global navigation
  └─ Workspace
      ├─ Page Header: identity + governed context + utilities
      ├─ Summary / KPI / alerts when decision-relevant
      └─ Functional workspace selected by archetype
```

No se fuerza el mismo layout a `Operational Control Tower`, `Data Explorer`, `Operational Review Workspace` o `Configuration Studio`; sí se fuerza la misma gramática visual.

## Componentes

Antes de implementar UI revisar `docs/design-system/COMPONENT_CATALOG.md` y la fuente real bajo `power-apps/components/`.

Orden obligatorio:

`REUSE → EXTEND_SHARED → CREATE_SHARED → LOCAL_ONLY`

Un gap reusable debe resolverse como componente compartido, con fuente canónica, especificación y lifecycle actualizado. Un componente `LEGACY_SUPPORTED` no se selecciona para trabajo nuevo salvo migración explícita.

## Estados e interacción

Aplicar los estados definidos por PDS: `Default / Hover / Focus / Pressed / Selected / Disabled / Loading / Empty / No results / Error / Success` cuando correspondan. Las acciones asíncronas o no repetibles deben aplicar Async Action Guard / single-flight proporcional al riesgo.

## Gate

Una pantalla no es premium por parecer atractiva. Debe superar revisión visual en Power Apps Studio con datos representativos y cumplir PDS, QA guardrails, Page Header Hierarchy y catálogo de componentes. No puede aprobarse si duplica localmente una capacidad compartida compatible o si presenta datos/acciones ficticios como reales.