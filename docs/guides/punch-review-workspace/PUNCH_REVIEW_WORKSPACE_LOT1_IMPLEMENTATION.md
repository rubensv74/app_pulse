# Punch Review Workspace — Lote 1

## Alcance entregado

Este lote materializa la estructura principal del Punch Review Workspace sin fingir todavía persistencia SQL ni colaboración completa.

Archivos:

```text
main/components/cmp_PunchReviewHeaderPro.pa.yaml
main/components/cmp_PunchReviewQueuePro.pa.yaml
main/components/cmp_PunchReviewOverviewPro.pa.yaml
main/components/cmp_PunchReviewActionsPro.pa.yaml
main/screens/PunchReview/scr_PunchReview.pa.yaml
```

## Contrato canónico de `colPunchReviewQueue`

Todas las pantallas host deben construir la misma colección:

```powerfx
{
    ReviewOrder: Number,
    RowKey: Text,
    PunchId: Number,
    PunchCode: Text,
    PunchDescription: Text,
    Title: Text,
    Description: Text,
    Category: Text,
    Subsystem: Text,
    Discipline: Text,
    Priority: Text,
    Status: Text,
    ResponsibleParty: Text,
    DueDateText: Text,
    IsReviewedInSession: Boolean
}
```

No pasar records heterogéneos de Home y Punches directamente a la pantalla.

## Apertura desde Home

Crear el botón oculto:

```text
btnHome_OpenPunchReview
```

Usar esta fórmula completa:

```powerfx
With(
    {
        _selected:
            LookUp(
                colHomePunchGridNormalized,
                RowKey = varHomePunchGridSelectedKey
            )
    },
    If(
        IsBlank(_selected.RowKey),
        Notify(
            "Select a Punch before opening the review workspace.",
            NotificationType.Warning
        ),
        ClearCollect(
            colPunchReviewQueue,
            ForAll(
                Sequence(CountRows(colHomePunchGridNormalized)),
                With(
                    {
                        _row:
                            Last(
                                FirstN(
                                    colHomePunchGridNormalized,
                                    Value
                                )
                            )
                    },
                    {
                        ReviewOrder: Value,
                        RowKey: Text(_row.RowKey),
                        PunchId: Value(_row.RowKey),
                        PunchCode: Coalesce(_row.PunchId, Text(_row.RowKey)),
                        PunchDescription: Coalesce(_row.Title, ""),
                        Title: Coalesce(_row.Title, ""),
                        Description: Coalesce(_row.Title, ""),
                        Category: "",
                        Subsystem: Coalesce(_row.Subsystem, ""),
                        Discipline: Coalesce(_row.Discipline, ""),
                        Priority: Coalesce(_row.Priority, ""),
                        Status: Coalesce(_row.Status, ""),
                        ResponsibleParty: Coalesce(_row.OwnerName, ""),
                        DueDateText: Coalesce(_row.DueDateText, ""),
                        IsReviewedInSession: false
                    }
                )
            )
        );

        Set(varPunchReviewSource, "HOME");
        Set(varPunchReviewReturnScreen, "HOME");
        Set(
            varPunchReviewCurrentIndex,
            Coalesce(
                LookUp(
                    colPunchReviewQueue,
                    RowKey = Text(_selected.RowKey),
                    ReviewOrder
                ),
                1
            )
        );
        Set(varPunchReviewCurrentId, Value(_selected.RowKey));
        Navigate(scr_PunchReview, ScreenTransition.Fade)
    )
)
```

## Apertura desde Punches

Crear:

```text
btnPunches_OpenPunchReview
```

Fórmula completa:

```powerfx
If(
    IsBlank(varDrawerRecordId),
    Notify(
        "Select a Punch before opening the review workspace.",
        NotificationType.Warning
    ),
    ClearCollect(
        colPunchReviewQueue,
        ForAll(
            Sequence(CountRows(colPunches)),
            With(
                {
                    _row:
                        Last(
                            FirstN(
                                colPunches,
                                Value
                            )
                        )
                },
                {
                    ReviewOrder: Value,
                    RowKey: Text(_row.PunchId),
                    PunchId: Value(_row.PunchId),
                    PunchCode: Coalesce(_row.PunchCode, Text(_row.PunchId)),
                    PunchDescription: Coalesce(_row.PunchDescription, ""),
                    Title: Coalesce(_row.PunchDescription, ""),
                    Description: Coalesce(_row.PunchDescription, ""),
                    Category: Coalesce(_row.CategoryName, _row.CategoryCode, ""),
                    Subsystem: Coalesce(_row.SubsystemCode, ""),
                    Discipline: Coalesce(_row.DisciplineName, _row.Discipline, ""),
                    Priority: Coalesce(_row.PriorityName, _row.Priority, ""),
                    Status: Coalesce(_row.StatusName, _row.Status, ""),
                    ResponsibleParty: Coalesce(_row.ResponsiblePerson, _row.ResponsibleCompany, ""),
                    DueDateText: Coalesce(Text(_row.DueDate), ""),
                    IsReviewedInSession: false
                }
            )
        )
    );

    Set(varPunchReviewSource, "PUNCHES");
    Set(varPunchReviewReturnScreen, "PUNCHES");
    Set(
        varPunchReviewCurrentIndex,
        Coalesce(
            LookUp(
                colPunchReviewQueue,
                Value(RowKey) = Value(varDrawerRecordId),
                ReviewOrder
            ),
            1
        )
    );
    Set(varPunchReviewCurrentId, Value(varDrawerRecordId));
    Navigate(scr_PunchReview, ScreenTransition.Fade)
)
```

## Componentes que no llaman a flows

Los cuatro componentes de Lote 1 son presentacionales. No contienen:

- llamadas SQL;
- llamadas Power Automate;
- navegación entre pantallas;
- variables de negocio persistentes.

La orquestación queda en `scr_PunchReview`.

## Funcionalidad disponible

- cola secuencial;
- búsqueda local de la cola;
- selección de Punch;
- navegación Previous/Next;
- Overview normalizado;
- Mark Reviewed en sesión;
- retorno a Home o Punches;
- Open in Punch List;
- placeholders explícitos de Comments, Custom Fields, History, Progress y Related Grid.

## Limitaciones deliberadas

- `Reviewed` es solo de sesión.
- La cola contiene únicamente el conjunto que entregue la pantalla de origen.
- Comments y Custom Fields llegan en Lote 2.
- History real requiere `ActivityLog`.
- El grid relacionado se conectará tras validar el layout.
- No se incorpora SQL nuevo en este lote.

## Validación manual obligatoria

1. Importar los cuatro componentes.
2. Crear o pegar `scr_PunchReview`.
3. Confirmar que la pantalla abre con una cola vacía sin errores.
4. Construir una cola desde Home.
5. Validar selección, Previous y Next.
6. Marcar revisado y confirmar que cambia la fila y el contador.
7. Volver a Home.
8. Repetir desde Punches.
9. Probar 1366, 1600 y 1920 px.
10. Comparar contra la imagen canónica antes de iniciar Lote 2.
