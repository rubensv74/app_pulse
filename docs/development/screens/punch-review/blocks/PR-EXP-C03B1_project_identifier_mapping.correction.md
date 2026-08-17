# PR-EXP-C03B1 — Corrección: ProjectCode visible vs ProjectId interno

## Explicación sencilla

En esta prueba se mezclaron dos identificadores diferentes del mismo proyecto:

- `70200`: `ProjectCode`, el número de proyecto que conoce el usuario y que PULSE muestra en pantalla.
- `4049`: `ProjectId`, la clave interna que usa SQL y que PULSE ya mantiene en `varProjectId`.

Los Punches de la Review Queue no eran de otro proyecto. Los códigos visibles (`MPL-000035`, `MPL-000868`, etc.) resolvieron correctamente y seguían `OPEN`.

El error estuvo únicamente en la prueba C03B1: se utilizó manualmente `70200` como parámetro `@ProjectId`, cuando el procedimiento esperaba el identificador interno `4049`.

Por eso se obtuvo:

```text
Requested = 15
Resolved  = 0
```

## Cómo lo resuelve ya PULSE

PULSE ya separa correctamente ambos valores cuando el usuario selecciona un proyecto:

```powerfx
Set(
    varProjectId,
    Value(varSelectedProject.ProjectId)
);

Set(
    varProjectCode,
    Text(varSelectedProject.ProjectCode)
);
```

Por tanto, para el proyecto que el usuario conoce como `70200`:

```text
varProjectCode = 70200
varProjectId   = 4049
```

No necesitamos añadir una nueva traducción 70200 → 4049 al export. La traducción ya está resuelta por el catálogo de proyectos cuando se selecciona el proyecto.

## Por qué el modal mostraba 70200

El Premium Export Modal muestra deliberadamente el código visible:

```powerfx
Coalesce(
    varSelectedProject.ProjectCode,
    Text(varProjectId)
)
```

Por eso la tarjeta `PROJECT` mostraba `70200`. Esa presentación es correcta y debe mantenerse.

La cifra mostrada en el modal no debe utilizarse manualmente como `ProjectId` SQL.

## Regla para PR-EXP-C03

- UI / usuario: usar `ProjectCode` (`70200`).
- SQL / Flow: usar `ProjectId` interno (`Value(varProjectId)`, en este caso `4049`).
- No mostrar `4049` al usuario.
- No comparar `ProjectCode` con `wap_PunchPaged.ProjectId`.
- No introducir un resolver backend nuevo mientras `varProjectId` ya proporcione la clave interna correcta.

## Impacto sobre PR-CONTEXT-FIX1

`PR-CONTEXT-FIX1_project_queue_integrity.property-guide.md` permanece **RETRACTADO**.

Si sus tres fórmulas se pegaron en Power Apps Studio, deben restaurarse antes de continuar. El rollback completo está en:

`PR-CONTEXT-ROLLBACK1_restore_pre_fix.complete-formulas.md`

## Siguiente paso de C03B1

1. Restaurar las tres fórmulas de Power Apps.
2. No cambiar C03A: la serialización de `WorkItemId` era correcta.
3. Mantener `warroom.usp_ValidatePunchReviewExportScope`: su lógica era correcta para un `ProjectId` interno.
4. Repetir la misma prueba con:

```text
ProjectCode visible = 70200
ProjectId interno   = 4049
TemplateId          = 20
RequestedCount      = 15
```

5. El gate esperado es:

```text
RequestedCount = 15
ResolvedCount  = 15
IsExactMatch   = 1
```

Solo después se continuará con PR-EXP-C03B2.
