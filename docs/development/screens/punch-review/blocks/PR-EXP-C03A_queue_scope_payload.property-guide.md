# PR-EXP-C03A — Construcción local del scope exacto de Review Queue

**Responsabilidad única:** construir y validar en Power Apps el payload `WorkItemIdsJson` a partir de `colPunchReviewQueue`.  
**No llama a ningún flow.**  
**No modifica SQL.**  
**No habilita todavía la generación del Excel.**

## Precondición

Los bloques `18A` y `18B` deben estar ya implementados y validados en `scr_PunchReview`.

El contrato asociado es:

`PR-EXP-C03_exact_review_queue.contract.md`

---

## 1. `scr_PunchReview.OnVisible`

Añade estas inicializaciones junto al estado de export ya creado por 18A:

```powerfx
Set(varPRExportWorkItemIdsJson, "[]");
Set(varPRExportScopeCount, 0);
Set(varPRExportScopeValid, false);
Set(varPRExportScopeError, "")
```

`varPRExportScopeCount` queda tipada desde el principio como numérica y `varPRExportScopeValid` como booleana.

---

## 2. Acción `EXPORT` de `cmpPR_Actions.OnAction`

En el `Switch` donde ya existe el caso `"EXPORT"`, sustituye únicamente el cuerpo de ese caso por el siguiente bloque completo:

```powerfx
Set(varPRExportOpen, false);
Set(varPRExportProfile, "CLIENT");
Set(varPRExportState, "CONFIGURE");
Set(varPRExportError, "");
Set(varPRExportFileUrl, "");
Set(varPRExportLoading, false);
Set(varPRExportWorkItemIdsJson, "[]");
Set(varPRExportScopeCount, 0);
Set(varPRExportScopeValid, false);
Set(varPRExportScopeError, "");

With(
    {
        _queue:
            SortByColumns(
                Filter(
                    colPunchReviewQueue,
                    Value(PunchIdNumber) > 0
                ),
                "ReviewOrder",
                SortOrder.Ascending
            )
    },

    Set(varPRExportScopeCount, CountRows(_queue));

    If(
        CountRows(_queue) = 0,

        Set(varPRExportScopeError, "The Review Queue does not contain valid Punch identifiers."),

        CountRows(Distinct(_queue, PunchIdNumber)) <> CountRows(_queue),

        Set(varPRExportScopeError, "The Review Queue contains duplicate Punch identifiers."),

        Set(
            varPRExportWorkItemIdsJson,
            JSON(
                ShowColumns(
                    AddColumns(
                        _queue,
                        WorkItemId,
                        Value(PunchIdNumber)
                    ),
                    WorkItemId
                ),
                JSONFormat.Compact
            )
        );

        If(
            CountRows(Table(ParseJSON(varPRExportWorkItemIdsJson))) <> CountRows(_queue),
            Set(varPRExportScopeError, "The Review Queue export scope could not be serialized completely."),
            Set(varPRExportScopeValid, true)
        )
    )
);

Set(varPRExportOpen, true)
```

### Resultado esperado

Para una cola de tres Punches el valor debe adoptar esta forma:

```json
[{"WorkItemId":100234},{"WorkItemId":100235},{"WorkItemId":100241}]
```

No construyas el JSON concatenando comillas manualmente. Se usa `JSON(..., JSONFormat.Compact)` de forma deliberada por las reglas del registro de compatibilidad de PULSE.

---

## 3. `lblPRExport_GateHint.Text`

Sustituye únicamente la propiedad `Text` por:

```powerfx
=If(
    varPRExportScopeValid,
    "Exact Review Queue scope ready  ·  " & Text(varPRExportScopeCount) & " WorkItems serialized  ·  backend connection pending.",
    If(
        IsBlank(varPRExportScopeError),
        "Preparing exact Review Queue scope...",
        "Scope blocked  ·  " & varPRExportScopeError
    )
)
```

Esto convierte el pie del modal en una comprobación visual del contrato sin simular que el Excel ya puede generarse.

---

## 4. `btnPRExport_Generate.DisplayMode`

**No cambiar.**

Debe seguir siendo:

```powerfx
=DisplayMode.Disabled
```

El botón no se habilita hasta que estén validados SQL + flow.

---

# Gate de validación en Power Apps Studio

Usa una Review Queue real como la que ya has validado visualmente.

Comprueba:

1. abre `Export`;
2. el modal sigue abriendo y cerrando normalmente;
3. el pie muestra `Exact Review Queue scope ready`;
4. el número mostrado coincide con `CountRows(colPunchReviewQueue)`;
5. en **Variables > Global variables**, `varPRExportWorkItemIdsJson` empieza por `[{"WorkItemId":` y contiene un objeto por Punch;
6. `varPRExportScopeValid = true`;
7. `varPRExportScopeError` está vacío;
8. `Generate Excel` continúa deshabilitado;
9. App Checker no introduce errores nuevos.

## Prueba negativa opcional

No alteres la cola productiva. Si quieres comprobar la defensa contra duplicados, hazlo únicamente sobre una copia temporal de la colección en Studio. El resultado esperado es:

- `varPRExportScopeValid = false`;
- `varPRExportScopeError = "The Review Queue contains duplicate Punch identifiers."`.

---

# Gate posterior

Cuando C03A pase Studio, el siguiente incremento será **PR-EXP-C03B — backend exact scope**:

- parámetro SQL opcional `@WorkItemIdsJson`;
- validación de JSON e IDs;
- filtro exacto de `#BaseKey`;
- bloqueo por mismatch de cardinalidad;
- preservación del comportamiento legacy cuando el parámetro sea `NULL`.

La conexión al flow seguirá pendiente hasta capturar su definición real.