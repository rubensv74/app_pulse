# PR-EXP-C03B1 — Corrección: código visible de proyecto vs clave interna SQL

## Explicación sencilla

En esta prueba se estaban mezclando dos identificadores diferentes del mismo proyecto:

- `70200`: código/número de proyecto que conoce el usuario y que PULSE muestra en pantalla.
- `4049`: clave interna con la que los Punches aparecen almacenados/relacionados en el origen SQL diagnosticado.

Los Punches de la Review Queue no eran de otro proyecto. Los códigos visibles (`MPL-000035`, `MPL-000868`, etc.) resolvieron correctamente y seguían `OPEN`. El error estuvo en el validador de C03B1: se pasó `70200` a una comparación SQL que esperaba encontrar `4049` en `wap_PunchPaged.ProjectId`.

Por eso se obtuvo:

```text
Requested = 15
Resolved  = 0
```

No era una Review Queue obsoleta.

## Regla de arquitectura

PULSE debe seguir mostrando y trabajando de cara al usuario con el código de proyecto conocido (`70200`).

Cuando un servicio necesite consultar una fuente que utiliza una clave interna (`4049`), esa traducción debe hacerse de forma explícita y gobernada en la capa backend, o reutilizando el mismo mecanismo de resolución que ya emplean los servicios Punch existentes.

No se debe:

- mostrar `4049` al usuario;
- pedir al usuario que conozca la clave interna;
- comparar directamente `70200` con `4049` como si fueran el mismo tipo de identificador;
- cambiar la Review Queue basándonos solo en esa diferencia.

## Impacto sobre PR-CONTEXT-FIX1

La versión anterior de `PR-CONTEXT-FIX1_project_queue_integrity.property-guide.md` queda retractada.

Si FIX1-A, FIX1-B y FIX1-C se pegaron manualmente en Power Apps Studio, no deben publicarse. Hay que volver a las fórmulas anteriores antes de continuar.

## Siguiente paso de C03B1

1. Restaurar las tres fórmulas de Power Apps al estado previo a PR-CONTEXT-FIX1.
2. Confirmar cuál es el mecanismo oficial que traduce el proyecto visible de PULSE a la clave interna usada por `wap_PunchPaged`.
3. Adaptar el validador `warroom.usp_ValidatePunchReviewExportScope` para usar esa resolución.
4. Repetir la prueba con los mismos 15 WorkItemIds.
5. El gate esperado seguirá siendo:

```text
RequestedCount = 15
ResolvedCount  = 15
IsExactMatch   = 1
```

Solo después se continuará con PR-EXP-C03B2.
