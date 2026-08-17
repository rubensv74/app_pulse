# PR-CONTEXT-FIX1 — Integridad Project / Template de Punch Review

## Motivo

Durante PR-EXP-C03B1 se confirmó un defecto de contexto más importante que el propio export:

- la pantalla Punch Review mostraba `Project = 70200`;
- la Review Queue contenía Punches cuyo `ProjectId` real era `4049`;
- los Punches diagnosticados seguían en `OPEN`;
- por tanto el fallo no estaba causado por un cambio de estado;
- el backend bloqueó correctamente el export porque `requestedCount = 15` y `resolvedCount = 0` para Project 70200.

La causa funcional es que una colección de Punches cargada previamente puede sobrevivir a un cambio de proyecto y ser utilizada para construir `colPunchReviewQueue` sin comprobar que sus filas pertenecen al proyecto/template activos.

Este defecto afecta no solo a Export. También puede provocar que Comments y Custom Fields se consulten con un `varProjectId` distinto del proyecto real del Punch seleccionado.

---

# Regla nueva obligatoria

**Punch Review nunca puede abrir una sesión si el dataset que sirve de origen no pertenece íntegramente al `varProjectId` y al template activos.**

El control se debe realizar antes de `ClearCollect(colPunchReviewQueue, ...)` y antes de `Navigate(scr_PunchReview, ...)`.

No se corrige el problema cambiando el ProjectId del export. La Review Queue debe ser coherente antes de existir.

---

## A. Entrada desde Home — `cmpHomePunchActionToolbar.OnAction`

Archivo de referencia:

`docs/development/screens/punch-review/blocks/15_home_entry.replace-formula.powerfx`

Dentro del caso `REVIEW`, una vez calculado `_seedRows` y antes de construir `colPunchReviewQueue`, calcula el número de filas cuyo registro raw no pertenece al contexto actual.

### Comprobación

```powerfx
With(
    {
        _foreignContextRows:
            CountRows(
                Filter(
                    _seedRows As _gridRow,
                    With(
                        {
                            _raw:
                                LookUp(
                                    colPunchExecutiveGridFiltered,
                                    Text(PunchId) = Text(_gridRow.RowKey)
                                )
                        },
                        IsBlank(_raw) ||
                        Value(_raw.ProjectId) <> Value(varProjectId) ||
                        Value(_raw.TemplateId) <> Value(varPunchDashboardTemplateId)
                    )
                )
            )
    },

    If(
        _foreignContextRows > 0,

        Clear(colHomePunchGridSelectedKeys);
        Set(varHomePunchGridSelectedKey, "");

        Notify(
            "The loaded Punch grid belongs to a previous project or template. Refresh the Punch dashboard before starting Review Workspace.",
            NotificationType.Warning
        ),

        /* Solo aquí continúa el ClearCollect(colPunchReviewQueue, ...) existente */
        ...
    )
)
```

### Resultado requerido

Si Home muestra Project 70200 pero el grid contiene filas de Project 4049:

- no se crea una nueva Review Queue;
- no se navega a `scr_PunchReview`;
- se informa al usuario de que debe recargar el dashboard;
- la selección del grid se limpia.

---

## B. Entrada desde Punch List — `btnPunches_OpenPunchReview_2.OnSelect`

La misma defensa debe existir en la entrada desde `scr_Punches`.

Antes de construir la cola:

```powerfx
With(
    {
        _foreignContextRows:
            CountRows(
                Filter(
                    colPunches,
                    Value(ProjectId) <> Value(varProjectId) ||
                    (
                        !IsBlank(varFilter_PunchTemplateId) &&
                        Value(TemplateId) <> Value(varFilter_PunchTemplateId)
                    )
                )
            )
    },

    If(
        _foreignContextRows > 0,

        Notify(
            "The loaded Punch page belongs to a previous project or template. Reload Punch List before starting Review Workspace.",
            NotificationType.Warning
        ),

        /* Solo aquí continúa el ClearCollect(colPunchReviewQueue, ...) existente */
        ...
    )
)
```

---

## C. Cambio de proyecto — invalidación de drilldown

Como segunda línea de defensa, el commit de cambio de proyecto en Home debe invalidar cualquier grid Punch cargado anteriormente.

Cuando el nuevo `varProjectId` queda confirmado, limpiar como mínimo:

```powerfx
Clear(colPunchExecutiveGridFiltered);
Clear(colHomePunchGridNormalized);
Clear(colHomePunchGridView);
Clear(colHomePunchGridSelectedKeys);

Set(varHomePunchGridSelectedKey, "");
Set(varPunchExecutiveGridSelectedId, Blank());
Set(varPunchExecutiveGridPage, 1);
Set(varPunchExecutiveGridTotalRows, 0);
Set(varPunchExecutiveGridTotalPages, 0);
Set(varPunchExecutiveGridHasPreviousPage, false);
Set(varPunchExecutiveGridHasNextPage, false)
```

El dashboard general puede recargarse normalmente después, pero ningún drilldown de Punches del proyecto anterior debe sobrevivir al cambio.

---

# Gate de validación

Usar el caso que reveló el defecto.

1. Cargar Punches del Project 4049 en Home.
2. Cambiar el proyecto activo a otro proyecto.
3. Sin recargar un nuevo drilldown, intentar abrir Punch Review.
4. Resultado esperado: navegación bloqueada y warning de contexto obsoleto.
5. Recargar el dashboard/drilldown del nuevo proyecto.
6. Abrir Punch Review.
7. Resultado esperado: Review Queue creada solo con filas del proyecto/template activos.
8. Abrir Export.
9. C03A debe volver a serializar la cola correcta.
10. Repetir PR-EXP-C03B1 con el ProjectId/template de esa sesión.

---

# Impacto en PR-EXP-C03

PR-EXP-C03B1 permanece **bloqueado** hasta validar este fix.

No se debe modificar todavía:

- `warroom.usp_ExportProjectPunchesExtended_Pivoted`;
- Power Automate;
- `Generate Excel`.

El validador SQL `warroom.usp_ValidatePunchReviewExportScope` se considera correcto: detectó y bloqueó una Review Queue incoherente en vez de producir una exportación incorrecta.
