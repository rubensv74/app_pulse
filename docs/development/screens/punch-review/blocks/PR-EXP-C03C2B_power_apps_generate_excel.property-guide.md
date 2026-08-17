# PR-EXP-C03C2B — Conectar `Generate Excel` en Punch Review

**Responsabilidad única:** conectar el Premium Export Modal de `scr_PunchReview` con el flow dedicado `Warroom_ExportPunchReviewToExcel` ya preparado en Power Automate.

Este bloque **no modifica SQL**. El scope exacto ya está protegido por `warroom.usp_ExportProjectPunchesExtended_Pivoted` mediante `@WorkItemIdsJson`.

## Precondiciones

Antes de aplicar este bloque deben cumplirse estas condiciones:

- `PR-EXP-C03A` validado en Studio: `varPRExportWorkItemIdsJson` contiene exactamente la Review Queue.
- `PR-EXP-C03C1` validado en SQL: 15 solicitados -> 15 devueltos; mismatch parcial bloqueado; firma legacy preservada.
- Flow dedicado guardado como `Warroom_ExportPunchReviewToExcel`.
- Trigger Power Apps (V2) con `WorkItemIdsJson` como **último input**.
- Acción `SQL ExportPunchesPivoted` con su parámetro `WorkItemIdsJson` enlazado al input homónimo del trigger.
- El flow debe añadirse a la app PULSE para que Power Apps Studio reconozca `Warroom_ExportPunchReviewToExcel.Run(...)`.

## Contrato de llamada

Orden exacto de los 13 argumentos del flow:

1. `ProjectId` — ID interno de proyecto (`varProjectId`).
2. `SubsystemCode` — vacío; la Review Queue exacta gobierna el scope.
3. `TemplateId` — `varPunchReviewTemplateId`.
4. `CategoryCode` — vacío.
5. `StatusCode` — vacío.
6. `PunchDiscipline` — vacío.
7. `Subcontractor` — vacío.
8. `CustomFiltersJson` — `[]`.
9. `RequestedByEmail` — `User().Email`.
10. `RequestedByName` — `User().FullName`.
11. `ExportMode` — `CLIENT` o `INTERNAL` según `varPRExportProfile`.
12. `SelectedColumnsJson` — lista pública gobernada para CLIENT; `[]` para INTERNAL.
13. `WorkItemIdsJson` — `varPRExportWorkItemIdsJson`.

> En Punch Review no reenviamos los filtros históricos que originaron la cola. Los IDs exactos de `colPunchReviewQueue` son el contrato de scope. Esto evita que un cambio posterior de estado, disciplina o filtro reduzca silenciosamente el export.

---

# 1. Añadir el flow a PULSE

En Power Apps Studio, añade el flow **`Warroom_ExportPunchReviewToExcel`** a la app.

No sustituyas ni elimines `Warroom_ExportPunchesToExcel_Codex`; ese flow sigue siendo el consumidor productivo de `scr_Punches`.

Después de añadirlo, Studio debe reconocer:

```powerfx
Warroom_ExportPunchReviewToExcel.Run(
    ...
)
```

Si Studio mantiene en caché una firma anterior, elimina **solo la referencia del flow dedicado** de la app y vuelve a añadirla. No modifiques el flow productivo de Punch List.

---

# 2. `btnPRExport_Generate.DisplayMode`

**REEMPLAZA COMPLETAMENTE** la propiedad `DisplayMode` por:

```powerfx
=If(
    Coalesce(varPRExportLoading, false) ||
    !Coalesce(varPRExportScopeValid, false) ||
    IsBlank(varProjectId) ||
    IsBlank(varPunchReviewTemplateId) ||
    CountRows(colPunchReviewFieldsDirty) > 0,
    DisplayMode.Disabled,
    DisplayMode.Edit
)
```

### Comportamiento

`Generate Excel` queda habilitado únicamente cuando:

- existe proyecto interno;
- existe template;
- el scope exacto está validado;
- no hay Custom Fields sin guardar;
- no hay otra generación en curso.

Los Custom Fields dirty bloquean el botón porque el Excel se genera desde backend y no debe aparentar contener cambios que todavía solo existen en la UI.

---

# 3. `btnPRExport_Generate.Text`

**REEMPLAZA COMPLETAMENTE** la propiedad `Text` por:

```powerfx
=If(
    Coalesce(varPRExportLoading, false),
    "Generating...",
    "Generate Excel"
)
```

---

# 4. `btnPRExport_Generate.OnSelect`

**REEMPLAZA COMPLETAMENTE** la propiedad `OnSelect` por este bloque.

No insertes fragmentos dentro de otra fórmula.

```powerfx
=Set(varPRExportLoading, true);
Set(varPRExportState, "GENERATING");
Set(varPRExportError, "");
Set(varPRExportFileUrl, "");
Set(varPRExportFileName, "");
Set(varPRExportRowCount, 0);
Set(varPRExportSelectedColumnsJson, "[]");

If(
    Upper(Coalesce(varPRExportProfile, "CLIENT")) = "CLIENT",
    Set(
        varPRExportSelectedColumnsJson,
        JSON(
            Table(
                {ColumnKey: "AreaCode", ColumnLabel: "Area", SortOrder: 10},
                {ColumnKey: "UnitCode", ColumnLabel: "Unit", SortOrder: 20},
                {ColumnKey: "SystemCode", ColumnLabel: "System", SortOrder: 30},
                {ColumnKey: "SubsystemCode", ColumnLabel: "Subsystem", SortOrder: 40},
                {ColumnKey: "ElementCode", ColumnLabel: "Element", SortOrder: 50},
                {ColumnKey: "ElementDiscipline", ColumnLabel: "Element discipline", SortOrder: 60},
                {ColumnKey: "Code", ColumnLabel: "Punch code", SortOrder: 100},
                {ColumnKey: "Description", ColumnLabel: "Punch description", SortOrder: 110},
                {ColumnKey: "Category", ColumnLabel: "Category", SortOrder: 120},
                {ColumnKey: "Discipline", ColumnLabel: "Discipline", SortOrder: 130},
                {ColumnKey: "Status", ColumnLabel: "Status", SortOrder: 140},
                {ColumnKey: "InspectionCode", ColumnLabel: "Inspection code", SortOrder: 200},
                {ColumnKey: "InspectionName", ColumnLabel: "Inspection name", SortOrder: 210},
                {ColumnKey: "SubcontractorName", ColumnLabel: "Subcontractor", SortOrder: 220}
            ),
            JSONFormat.Compact
        )
    )
);

IfError(
    With(
        {
            flowResponse:
                Warroom_ExportPunchReviewToExcel.Run(
                    Value(varProjectId),
                    "",
                    Value(varPunchReviewTemplateId),
                    "",
                    "",
                    "",
                    "",
                    "[]",
                    Text(User().Email),
                    Text(User().FullName),
                    Upper(Coalesce(varPRExportProfile, "CLIENT")),
                    Text(varPRExportSelectedColumnsJson),
                    Text(varPRExportWorkItemIdsJson)
                )
        },

        Set(
            varPRExportFileUrl,
            Coalesce(Text(flowResponse.fileurl), "")
        );

        Set(
            varPRExportFileName,
            Coalesce(Text(flowResponse.filename), "")
        );

        Set(
            varPRExportRowCount,
            Coalesce(Value(flowResponse.rowcount), 0)
        );

        If(
            Coalesce(flowResponse.success, false),

            Set(varPRExportState, "SUCCESS");
            Set(varPRExportLoading, false);
            Set(varPRExportError, "");

            If(
                !IsBlank(varPRExportFileUrl),
                Launch(varPRExportFileUrl)
            ),

            Set(
                varPRExportError,
                Coalesce(
                    Text(flowResponse.message),
                    "Export failed before completion."
                )
            );
            Set(varPRExportState, "ERROR");
            Set(varPRExportLoading, false)
        )
    ),

    Set(
        varPRExportError,
        Coalesce(
            FirstError.Message,
            "Export failed before completion."
        )
    );
    Set(varPRExportState, "ERROR");
    Set(varPRExportLoading, false)
)
```

## Por qué `SelectedColumnsJson` funciona distinto según perfil

El Office Script `BuildPunchExport.ts` gobierna los perfiles de forma distinta:

- `CLIENT`: usa `selectedColumnsJson` para limitar explícitamente las columnas públicas.
- `INTERNAL`: ignora esa selección y construye el workbook completo/import-ready, incluyendo metadata y hojas técnicas gobernadas.

Por eso este bloque envía una allowlist explícita para CLIENT y `[]` para INTERNAL.

---

# 5. `lblPRExport_GateHint.Text`

**REEMPLAZA COMPLETAMENTE** la propiedad `Text` por:

```powerfx
=Switch(
    Upper(Coalesce(varPRExportState, "CONFIGURE")),

    "GENERATING",
        "Generating governed Excel package...",

    "SUCCESS",
        "Export ready  ·  " &
        Text(Coalesce(varPRExportRowCount, 0)) &
        " punches  ·  " &
        Coalesce(varPRExportFileName, "Excel generated"),

    "ERROR",
        "Export failed  ·  " &
        Coalesce(varPRExportError, "Review the Flow run for details."),

    If(
        Coalesce(varPRExportScopeValid, false),
        "Exact Review Queue scope ready  ·  " &
        Text(varPRExportScopeCount) &
        " WorkItems serialized.",
        If(
            IsBlank(varPRExportScopeError),
            "Preparing exact Review Queue scope...",
            "Scope blocked  ·  " & varPRExportScopeError
        )
    )
)
```

---

# Gate de validación en Studio — CLIENT primero

Usa la misma Review Queue real validada durante C03A/C03C1.

1. Abre `Export`.
2. Mantén `Client / external`.
3. Confirma que `Generate Excel` está habilitado.
4. Pulsa `Generate Excel` una sola vez.
5. Mientras corre, el botón debe mostrar `Generating...` y quedar deshabilitado.
6. El flow debe terminar `Succeeded`.
7. Debe abrirse el enlace del Excel.
8. El pie del modal debe indicar `Export ready` y el mismo número de Punches que la Review Queue.
9. El Excel CLIENT debe contener únicamente los Punches de la Review Queue y no debe exponer las hojas técnicas de importación.
10. App Checker no debe introducir errores nuevos.

## Resultado esperado para la cola de referencia

```text
Review Queue          = 15
Flow rowCount         = 15
Excel business rows   = 15
Scope                 = exact Review Queue
Profile               = CLIENT
```

---

# Gate posterior

Cuando el CLIENT pase end-to-end:

1. validar `INTERNAL / import-ready` con la misma cola;
2. comprobar que el workbook contiene metadata de importación y hojas técnicas gobernadas;
3. capturar/versionar la definición real del nuevo flow;
4. actualizar `power-automate/FLOW_COVERAGE.md`;
5. cerrar `PR-EXP-C03C2`;
6. pasar a `PR-EXP-C03D` para la selección premium/gobernada de columnas y estados finales del modal.
