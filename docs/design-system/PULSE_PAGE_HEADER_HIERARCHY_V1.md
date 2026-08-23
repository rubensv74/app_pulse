# PULSE — Page Header Hierarchy V1

**Estado:** `MANDATORY / PRODUCT-WIDE`

## Jerarquía

```text
L0 — Product navigation / shell
L1 — Page identity + governed context + utilities
L2 — Decision summary (optional)
L3 — Functional workspace
```

A diferencia de AssetPlan, PULSE integra normalmente el contexto de página dentro del Page Header mediante slots gobernados.

## L1 — Page Header

El patrón canónico se basa en `cmp_PageHeaderPro` y su especificación `docs/design-system/components/CMP_PAGE_HEADER_PRO.md`.

Contrato visual de referencia:

- altura: `80 px`;
- padding horizontal: `16 px`;
- gap interno: `12 px`;
- título: `20 px / Semibold`;
- subtítulo: `10 px / Normal`;
- hasta 3 context slots;
- utilities subordinadas a la acción operacional principal;
- bottom divider de 1 px;
- sin apariencia de card decorativa ni shadow normal.

El header responde a: **qué pantalla es**, **en qué contexto trabaja** y **qué utilidades globales están disponibles**. No debe absorber la acción de negocio principal del workspace.

## L2

KPI, alerts o summary solo cuando aporten decisión. No se integran artificialmente dentro del título.

## L3

El workspace adopta el arquetipo adecuado y puede variar en densidad/composición sin crear un segundo sistema visual.

## Regla de validación

La fuente de lifecycle del componente es `docs/design-system/COMPONENT_CATALOG.md`. Este documento congela la jerarquía; no eleva por sí solo el estado de validación de una RC concreta.