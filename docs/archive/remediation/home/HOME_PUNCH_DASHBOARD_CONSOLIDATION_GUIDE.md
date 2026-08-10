# Guía ejecutable — consolidación de `scr_Home` con componentes premium

## 1. Objetivo cerrado

Consolidar el dashboard de Punches de `scr_Home` sustituyendo los bloques visuales actuales por estos componentes:

- `cmp_KpiCardPro`
- `cmp_DonutPro`
- `cmp_SmartFilterBarPro`
- `cmp_DataTableProV2`

El componente `cmp_HeatMapPro` se conserva sin rediseñarlo.

### Decisiones funcionales confirmadas

1. Se mostrarán cuatro KPI:
   - Total Punches
   - Open Punches
   - Closed Punches
   - Completion
2. El donut mostrará la distribución global por estado del proyecto y plantilla.
3. El grid permanecerá vacío hasta seleccionar una celda del Heat Map.
4. Se conserva `Priority`.
5. No se implementan filtros avanzados en esta entrega.
6. No se utilizarán como conceptos de la pantalla:
   - Overdue
   - Risk
   - Due Date
   - Critical como KPI o filtro
7. No se cambia el contrato de los flows en esta consolidación.

> Nota funcional importante: el flow `warroom_GetPunchDashboardCellDetails` pagina en servidor, pero no recibe búsqueda, estado ni ordenación. Por tanto, la búsqueda, los quick filters `All/Open/Closed` y la ordenación de esta primera entrega actúan sobre la página actualmente cargada. Para evitar una promesa falsa, el placeholder será **“Search current page...”**.

---

## 2. Archivos de partida

| Elemento | Archivo |
|---|---|
| Pantalla actual | `Pasted text(49).txt` |
| KPI | `cmp_KpiCardPro.pa(2).yaml` |
| Donut | `cmp_DonutPro.pa(1).yaml` |
| Filter bar | `cmp_SmartFilterBarPro.pa(1).yaml` |
| Data table | `cmp_DataTablePro.pa.yaml` |

### Bloqueo previo detectado en DataTable

El archivo recibido todavía contiene ocho usos de:

```powerfx
Char(8593)
Char(8595)
```

Power Apps solo admite valores de 1 a 255 en `Char()`. Deben utilizarse:

```powerfx
UniChar(8593)
UniChar(8595)
```

Usar como base el archivo corregido:

```text
cmp_DataTablePro_HomeReady.pa.yaml
```

No continuar con la integración si el componente todavía muestra errores en las flechas de ordenación.

---

## 3. Arquitectura final de controles

La jerarquía final del bloque Punches debe quedar así:

```text
conPunchDashboardBody_1
│
├── conPunchExecutiveKpiStrip
│   ├── cmpHomePunchKpiTotal
│   ├── cmpHomePunchKpiOpen
│   ├── cmpHomePunchKpiClosed
│   └── cmpHomePunchKpiCompletion
│
├── conPunchExecutiveAnalyticsWorkspace
│   ├── cmpPunchExecutiveHeatmapPro              [SIN REDISEÑO]
│   └── conPunchExecutiveRightColumn
│       ├── conPunchExecutiveDonutSlot
│       │   └── cmpHomePunchStatusDonut
│       └── conPunchExecutiveDetailSlot          [SE CONSERVA]
│
├── cmpHomePunchSmartFilterBar
├── cmpHomePunchDataTablePro
│
└── conPunchExecutiveGridWorkspace               [LEGACY: oculto durante validación]
```

Controles auxiliares nuevos, invisibles y situados como hijos directos de `scr_Home`:

```text
btnHome_BuildPunchPresentationModel
btnHome_RebuildPunchGridView
btnHome_ClearPunchGridUi
btnHome_ExportPunchGrid
```

---

## 4. Estrategia de implementación segura

No borrar inmediatamente los bloques anteriores.

### Primera pasada

- Ocultar los bloques legacy.
- Añadir los componentes nuevos.
- Validar carga, selección y navegación.

### Segunda pasada

Cuando todos los criterios de aceptación estén superados:

- eliminar los controles visuales legacy;
- conservar únicamente los controles auxiliares cuya fórmula siga siendo necesaria;
- ejecutar una nueva importación de prueba.

Esto permite volver atrás sin reconstruir manualmente la pantalla.

---

# FASE 1 — Estado y colecciones de presentación

## 5. Variables nuevas en `scr_Home.OnVisible`

Añadir al final de la sección de defaults de Punch Dashboard:

```powerfx
// =====================================================
// PREMIUM PUNCH DASHBOARD UI STATE
// =====================================================

If(
    IsBlank(varHomePunchQuickFilter),
    Set(varHomePunchQuickFilter, "ALL")
);

If(
    IsBlank(varHomePunchSearchText),
    Set(varHomePunchSearchText, "")
);

If(
    IsBlank(varHomePunchGridDensity),
    Set(varHomePunchGridDensity, "Compact")
);

If(
    IsBlank(varHomePunchGridSortKey),
    Set(varHomePunchGridSortKey, "PunchId")
);

If(
    IsBlank(varHomePunchGridSortDirection),
    Set(varHomePunchGridSortDirection, "asc")
);

If(
    IsBlank(varHomePunchGridSelectedKey),
    Set(varHomePunchGridSelectedKey, "")
);

If(
    IsBlank(varHomePunchKpiTotal),
    Set(varHomePunchKpiTotal, 0)
);

If(
    IsBlank(varHomePunchKpiOpen),
    Set(varHomePunchKpiOpen, 0)
);

If(
    IsBlank(varHomePunchKpiClosed),
    Set(varHomePunchKpiClosed, 0)
);

If(
    IsBlank(varHomePunchKpiCompletion),
    Set(varHomePunchKpiCompletion, 0)
);

If(
    IsBlank(varHomePunchKpiHasPreviousSnapshot),
    Set(varHomePunchKpiHasPreviousSnapshot, false)
);

If(
    CountRows(colHomePunchGridColumns) = 0,

    ClearCollect(
        colHomePunchGridColumns,

        {
            Key: "PunchId",
            Label: "Punch",
            IsVisible: true,
            IsLocked: true,
            Width: 116,
            Sortable: true,
            Order: 1
        },

        {
            Key: "Title",
            Label: "Description",
            IsVisible: true,
            IsLocked: true,
            Width: 360,
            Sortable: true,
            Order: 2
        },

        {
            Key: "Subsystem",
            Label: "Category / Subsystem / Discipline",
            IsVisible: true,
            IsLocked: false,
            Width: 300,
            Sortable: true,
            Order: 3
        },

        {
            Key: "Discipline",
            Label: "Discipline",
            IsVisible: false,
            IsLocked: false,
            Width: 110,
            Sortable: true,
            Order: 4
        },

        {
            Key: "Priority",
            Label: "Priority",
            IsVisible: true,
            IsLocked: false,
            Width: 108,
            Sortable: true,
            Order: 5
        },

        {
            Key: "Status",
            Label: "Status",
            IsVisible: true,
            IsLocked: false,
            Width: 100,
            Sortable: true,
            Order: 6
        },

        {
            Key: "DueDateText",
            Label: "Due Date",
            IsVisible: false,
            IsLocked: false,
            Width: 108,
            Sortable: false,
            Order: 7
        },

        {
            Key: "OwnerName",
            Label: "Responsible",
            IsVisible: true,
            IsLocked: false,
            Width: 240,
            Sortable: true,
            Order: 8
        },

        {
            Key: "ProgressPct",
            Label: "Progress",
            IsVisible: false,
            IsLocked: false,
            Width: 116,
            Sortable: false,
            Order: 9
        }
    )
);
```

### Colecciones nuevas

No es necesario inicializarlas con registros ficticios. Se crearán durante la carga:

```text
colHomePunchTimelineSorted
colHomePunchKpiTrendTotal
colHomePunchKpiTrendOpen
colHomePunchKpiTrendClosed
colHomePunchKpiTrendCompletion
colHomePunchDonutItems
colHomePunchGridNormalized
colHomePunchGridView
```

---

# FASE 2 — Adaptador de KPI y donut

## 6. Crear `btnHome_BuildPunchPresentationModel`

Crear un control invisible:

```yaml
- btnHome_BuildPunchPresentationModel:
    Control: Button@0.0.45
    Properties:
      Visible: =false
      Width: =1
      Height: =1
      X: =20
      Y: =20
```

### Propiedad afectada

```text
btnHome_BuildPunchPresentationModel.OnSelect
```

### Fórmula completa

```powerfx
// =====================================================
// KPI CURRENT VALUES
// =====================================================

Set(
    varHomePunchKpiTotal,
    Sum(
        colPunchDashboardSummary,
        Coalesce(PunchCount, 0)
    )
);

Set(
    varHomePunchKpiOpen,
    Sum(
        Filter(
            colPunchDashboardSummary,
            Upper(Trim(Coalesce(StatusCode, ""))) in ["OPEN", "O"] ||
            Upper(Trim(Coalesce(StatusName, ""))) = "OPEN"
        ),
        Coalesce(PunchCount, 0)
    )
);

Set(
    varHomePunchKpiClosed,
    Sum(
        Filter(
            colPunchDashboardSummary,
            Upper(Trim(Coalesce(StatusCode, ""))) in ["CLOSED", "CLOSE", "CL"] ||
            Upper(Trim(Coalesce(StatusName, ""))) = "CLOSED"
        ),
        Coalesce(PunchCount, 0)
    )
);

Set(
    varHomePunchKpiCompletion,
    Round(
        100 *
        varHomePunchKpiClosed /
        Max(1, varHomePunchKpiTotal),
        1
    )
);


// =====================================================
// NORMALIZED TIMELINE
// =====================================================

ClearCollect(
    colHomePunchTimelineSorted,
    SortByColumns(
        colPunchDashboardTimeline,
        "SnapshotSequence",
        SortOrder.Ascending
    )
);

ClearCollect(
    colHomePunchKpiTrendTotal,
    ForAll(
        Sequence(CountRows(colHomePunchTimelineSorted)) As _point,
        With(
            {
                _row:
                    Last(
                        FirstN(
                            colHomePunchTimelineSorted,
                            _point.Value
                        )
                    )
            },
            {
                PointIndex: _point.Value,
                PointValue: Coalesce(_row.TotalCount, 0)
            }
        )
    )
);

ClearCollect(
    colHomePunchKpiTrendOpen,
    ForAll(
        Sequence(CountRows(colHomePunchTimelineSorted)) As _point,
        With(
            {
                _row:
                    Last(
                        FirstN(
                            colHomePunchTimelineSorted,
                            _point.Value
                        )
                    )
            },
            {
                PointIndex: _point.Value,
                PointValue: Coalesce(_row.OpenCount, 0)
            }
        )
    )
);

ClearCollect(
    colHomePunchKpiTrendClosed,
    ForAll(
        Sequence(CountRows(colHomePunchTimelineSorted)) As _point,
        With(
            {
                _row:
                    Last(
                        FirstN(
                            colHomePunchTimelineSorted,
                            _point.Value
                        )
                    )
            },
            {
                PointIndex: _point.Value,
                PointValue: Coalesce(_row.ClosedCount, 0)
            }
        )
    )
);

ClearCollect(
    colHomePunchKpiTrendCompletion,
    ForAll(
        Sequence(CountRows(colHomePunchTimelineSorted)) As _point,
        With(
            {
                _row:
                    Last(
                        FirstN(
                            colHomePunchTimelineSorted,
                            _point.Value
                        )
                    )
            },
            {
                PointIndex: _point.Value,
                PointValue:
                    Round(
                        100 *
                        Coalesce(_row.ClosedCount, 0) /
                        Max(1, Coalesce(_row.TotalCount, 0)),
                        1
                    )
            }
        )
    )
);


// =====================================================
// DELTAS BETWEEN THE LAST TWO SNAPSHOTS
// =====================================================

Set(
    varHomePunchKpiHasPreviousSnapshot,
    CountRows(colHomePunchTimelineSorted) >= 2
);

If(
    varHomePunchKpiHasPreviousSnapshot,

    With(
        {
            _current:
                Last(colHomePunchTimelineSorted),

            _previous:
                Last(
                    FirstN(
                        colHomePunchTimelineSorted,
                        CountRows(colHomePunchTimelineSorted) - 1
                    )
                )
        },

        Set(
            varHomePunchKpiTotalDelta,
            Coalesce(_current.TotalCount, 0) -
            Coalesce(_previous.TotalCount, 0)
        );

        Set(
            varHomePunchKpiOpenDelta,
            Coalesce(_current.OpenCount, 0) -
            Coalesce(_previous.OpenCount, 0)
        );

        Set(
            varHomePunchKpiClosedDelta,
            Coalesce(_current.ClosedCount, 0) -
            Coalesce(_previous.ClosedCount, 0)
        );

        Set(
            varHomePunchKpiCompletionDelta,
            Round(
                100 * Coalesce(_current.ClosedCount, 0) /
                    Max(1, Coalesce(_current.TotalCount, 0)) -
                100 * Coalesce(_previous.ClosedCount, 0) /
                    Max(1, Coalesce(_previous.TotalCount, 0)),
                1
            )
        )
    ),

    Set(varHomePunchKpiTotalDelta, 0);
    Set(varHomePunchKpiOpenDelta, 0);
    Set(varHomePunchKpiClosedDelta, 0);
    Set(varHomePunchKpiCompletionDelta, 0)
);


// =====================================================
// GLOBAL DONUT MODEL
// =====================================================

ClearCollect(
    colHomePunchDonutItems,

    ForAll(
        SortByColumns(
            colPunchDashboardSummary,
            "StatusOrder",
            SortOrder.Ascending
        ) As _status,

        {
            SegmentKey:
                Coalesce(
                    _status.StatusCode,
                    _status.StatusName,
                    "UNKNOWN"
                ),

            SegmentLabel:
                Coalesce(
                    _status.StatusName,
                    _status.StatusCode,
                    "Unknown"
                ),

            SegmentValue:
                Coalesce(_status.PunchCount, 0),

            SegmentColor:
                Coalesce(_status.StatusColor, "#64748B"),

            SegmentOrder:
                Coalesce(_status.StatusOrder, 9999)
        }
    )
)
```

## 7. Conectar el adaptador a la carga del dashboard

Control afectado:

```text
btnHome_LoadPunchDashboard_1.OnSelect
```

Dentro del bloque exitoso de `warroom_GetPunchDashboardBundle`, localizar el final de la creación de:

```text
colPunchExecutiveSelection
```

Justo después del último `ClearCollect(colPunchExecutiveSelection, ...)` y antes de cerrar el bloque exitoso, añadir:

```powerfx
Select(btnHome_BuildPunchPresentationModel)
```

### También limpiar el modelo al comenzar una nueva carga

En la sección inicial de limpieza de `btnHome_LoadPunchDashboard_1.OnSelect`, añadir:

```powerfx
Clear(colHomePunchTimelineSorted);
Clear(colHomePunchKpiTrendTotal);
Clear(colHomePunchKpiTrendOpen);
Clear(colHomePunchKpiTrendClosed);
Clear(colHomePunchKpiTrendCompletion);
Clear(colHomePunchDonutItems);

Set(varHomePunchKpiTotal, 0);
Set(varHomePunchKpiOpen, 0);
Set(varHomePunchKpiClosed, 0);
Set(varHomePunchKpiCompletion, 0);
```

---

# FASE 3 — Sustitución del strip de KPI

## 8. Ajustar `conPunchExecutiveKpiStrip`

Propiedades afectadas:

```powerfx
conPunchExecutiveKpiStrip.Height = 96
conPunchExecutiveKpiStrip.LayoutMinHeight = 96
conPunchExecutiveKpiStrip.Fill = Color.Transparent
conPunchExecutiveKpiStrip.BorderThickness = 0
```

### Controles legacy que se ocultan

```text
conPunchExecutiveKpiTotal.Visible = false
conPunchExecutiveKpiOpen.Visible = false
conPunchExecutiveKpiClosed.Visible = false
```

No borrarlos hasta terminar la validación.

---

## 9. Nueva instancia `cmpHomePunchKpiTotal`

```yaml
- cmpHomePunchKpiTotal:
    Control: CanvasComponent
    ComponentName: cmp_KpiCardPro
    Properties:
      Width: =(Parent.Width - 36) / 4
      Height: =Parent.Height
      X: =0
      Y: =0
      CardKey: ="TOTAL"
      Title: ="Total Punches"
      ValueText: =Text(varHomePunchKpiTotal, "[$-en-US]#,##0")
      TrendText: |-
        =If(
            varHomePunchKpiHasPreviousSnapshot,
            Text(Abs(varHomePunchKpiTotalDelta), "[$-en-US]#,##0") & " vs previous snapshot",
            "No previous snapshot"
        )
      TrendDirection: |-
        =If(
            varHomePunchKpiTotalDelta > 0,
            "up",
            If(varHomePunchKpiTotalDelta < 0, "down", "neutral")
        )
      TrendTone: =If(varHomePunchKpiTotalDelta <= 0, "success", "danger")
      TrendSeries: =colHomePunchKpiTrendTotal
      VisualMode: ="icon"
      IconType: ="progress"
      AccentColor: =ColorValue("#2563EB")
      AccentHex: ="#2563EB"
      AccentSoftColor: =ColorValue("#EFF6FF")
      CardFill: =varTheme_Surface
      BorderColor: =varTheme_Border
      TextColor: =varTheme_Text
      MutedTextColor: =varTheme_TextMuted
      SuccessColor: =varTheme_Green
      WarningColor: =varTheme_Amber
      DangerColor: =varTheme_Red
      ShowSparkline: =true
      ShowTrend: =true
      ShowInfo: =true
      InfoTooltip: ="All punches included in the selected project and Punch template."
      IsLoading: =varPunchDashboardLoading
      IsError: =!IsBlank(varPunchDashboardError)
      EnableClick: =true
      OnCardSelect: |-
        =
        Set(varPunchDrillStatusCode, "");
        Set(varPunchDrillCategoryCode, "");
        Set(varPunchDrillSubsystemCode, "");
        Set(varPunchDrillSubcontractorId, Blank());
        Set(varPunchDrillSubcontractorName, "");

        Set(varPunches_ReturnView, "Home");
        Set(varPunches_ContextSource, "DashboardKpiTotal");
        Set(varPunches_FilterSource, "Dashboard");
        Set(varPunchCustomFiltersJson, "[]");
        Set(varFilter_PunchTemplateId, Value(varPunchDashboardTemplateId));
        Set(varFilter_PunchStatusCode, "");
        Set(varFilter_PunchCategoryCode, "");
        Set(varFilter_SubsystemsCsv, "");
        Set(varFilter_Subsystem, Blank());
        Set(varFilter_Subcontractor, Blank());
        Set(varFilter_PunchDiscipline, "");
        Set(varPunches_Page, 1);
        Set(varPunches_HasSearched, true);
        Set(varPunches_AutoLoad, true);
        Clear(colPunches);
        Set(varAppView, "Punches");
        Navigate(scr_Punches, ScreenTransition.None)
```

---

## 10. Nueva instancia `cmpHomePunchKpiOpen`

```yaml
- cmpHomePunchKpiOpen:
    Control: CanvasComponent
    ComponentName: cmp_KpiCardPro
    Properties:
      Width: =(Parent.Width - 36) / 4
      Height: =Parent.Height
      X: =cmpHomePunchKpiTotal.X + cmpHomePunchKpiTotal.Width + 12
      Y: =0
      CardKey: ="OPEN"
      Title: ="Open Punches"
      ValueText: =Text(varHomePunchKpiOpen, "[$-en-US]#,##0")
      TrendText: |-
        =If(
            varHomePunchKpiHasPreviousSnapshot,
            Text(Abs(varHomePunchKpiOpenDelta), "[$-en-US]#,##0") & " vs previous snapshot",
            "No previous snapshot"
        )
      TrendDirection: |-
        =If(
            varHomePunchKpiOpenDelta > 0,
            "up",
            If(varHomePunchKpiOpenDelta < 0, "down", "neutral")
        )
      TrendTone: =If(varHomePunchKpiOpenDelta <= 0, "success", "danger")
      TrendSeries: =colHomePunchKpiTrendOpen
      VisualMode: ="icon"
      IconType: ="alert"
      AccentColor: =ColorValue("#F97316")
      AccentHex: ="#F97316"
      AccentSoftColor: =ColorValue("#FFF7ED")
      CardFill: =varTheme_Surface
      BorderColor: =varTheme_Border
      TextColor: =varTheme_Text
      MutedTextColor: =varTheme_TextMuted
      SuccessColor: =varTheme_Green
      WarningColor: =varTheme_Amber
      DangerColor: =varTheme_Red
      ShowSparkline: =true
      ShowTrend: =true
      ShowInfo: =true
      InfoTooltip: ="Punches currently classified as Open."
      IsLoading: =varPunchDashboardLoading
      IsError: =!IsBlank(varPunchDashboardError)
      EnableClick: =true
      OnCardSelect: |-
        =
        Set(varPunchDrillStatusCode, "OPEN");
        Set(varPunchDrillCategoryCode, "");
        Set(varPunchDrillSubsystemCode, "");
        Set(varPunchDrillSubcontractorId, Blank());
        Set(varPunchDrillSubcontractorName, "");
        Set(varPunches_ReturnView, "Home");
        Set(varPunches_ContextSource, "DashboardKpiOpen");
        Set(varPunches_FilterSource, "Dashboard");
        Set(varPunchCustomFiltersJson, "[]");
        Set(varFilter_PunchTemplateId, Value(varPunchDashboardTemplateId));
        Set(varFilter_PunchStatusCode, "OPEN");
        Set(varFilter_PunchCategoryCode, "");
        Set(varFilter_SubsystemsCsv, "");
        Set(varFilter_Subsystem, Blank());
        Set(varFilter_Subcontractor, Blank());
        Set(varFilter_PunchDiscipline, "");
        Set(varPunches_Page, 1);
        Set(varPunches_HasSearched, true);
        Set(varPunches_AutoLoad, true);
        Clear(colPunches);
        Set(varAppView, "Punches");
        Navigate(scr_Punches, ScreenTransition.None)
```

---

## 11. Nueva instancia `cmpHomePunchKpiClosed`

```yaml
- cmpHomePunchKpiClosed:
    Control: CanvasComponent
    ComponentName: cmp_KpiCardPro
    Properties:
      Width: =(Parent.Width - 36) / 4
      Height: =Parent.Height
      X: =cmpHomePunchKpiOpen.X + cmpHomePunchKpiOpen.Width + 12
      Y: =0
      CardKey: ="CLOSED"
      Title: ="Closed Punches"
      ValueText: =Text(varHomePunchKpiClosed, "[$-en-US]#,##0")
      TrendText: |-
        =If(
            varHomePunchKpiHasPreviousSnapshot,
            Text(Abs(varHomePunchKpiClosedDelta), "[$-en-US]#,##0") & " vs previous snapshot",
            "No previous snapshot"
        )
      TrendDirection: |-
        =If(
            varHomePunchKpiClosedDelta > 0,
            "up",
            If(varHomePunchKpiClosedDelta < 0, "down", "neutral")
        )
      TrendTone: =If(varHomePunchKpiClosedDelta >= 0, "success", "danger")
      TrendSeries: =colHomePunchKpiTrendClosed
      VisualMode: ="icon"
      IconType: ="check"
      AccentColor: =ColorValue("#16A34A")
      AccentHex: ="#16A34A"
      AccentSoftColor: =ColorValue("#F0FDF4")
      CardFill: =varTheme_Surface
      BorderColor: =varTheme_Border
      TextColor: =varTheme_Text
      MutedTextColor: =varTheme_TextMuted
      SuccessColor: =varTheme_Green
      WarningColor: =varTheme_Amber
      DangerColor: =varTheme_Red
      ShowSparkline: =true
      ShowTrend: =true
      ShowInfo: =true
      InfoTooltip: ="Punches currently classified as Closed."
      IsLoading: =varPunchDashboardLoading
      IsError: =!IsBlank(varPunchDashboardError)
      EnableClick: =true
      OnCardSelect: |-
        =
        Set(varPunchDrillStatusCode, "CLOSED");
        Set(varPunchDrillCategoryCode, "");
        Set(varPunchDrillSubsystemCode, "");
        Set(varPunchDrillSubcontractorId, Blank());
        Set(varPunchDrillSubcontractorName, "");
        Set(varPunches_ReturnView, "Home");
        Set(varPunches_ContextSource, "DashboardKpiClosed");
        Set(varPunches_FilterSource, "Dashboard");
        Set(varPunchCustomFiltersJson, "[]");
        Set(varFilter_PunchTemplateId, Value(varPunchDashboardTemplateId));
        Set(varFilter_PunchStatusCode, "CLOSED");
        Set(varFilter_PunchCategoryCode, "");
        Set(varFilter_SubsystemsCsv, "");
        Set(varFilter_Subsystem, Blank());
        Set(varFilter_Subcontractor, Blank());
        Set(varFilter_PunchDiscipline, "");
        Set(varPunches_Page, 1);
        Set(varPunches_HasSearched, true);
        Set(varPunches_AutoLoad, true);
        Clear(colPunches);
        Set(varAppView, "Punches");
        Navigate(scr_Punches, ScreenTransition.None)
```

---

## 12. Nueva instancia `cmpHomePunchKpiCompletion`

```yaml
- cmpHomePunchKpiCompletion:
    Control: CanvasComponent
    ComponentName: cmp_KpiCardPro
    Properties:
      Width: =(Parent.Width - 36) / 4
      Height: =Parent.Height
      X: =cmpHomePunchKpiClosed.X + cmpHomePunchKpiClosed.Width + 12
      Y: =0
      CardKey: ="COMPLETION"
      Title: ="Completion"
      ValueText: =Text(varHomePunchKpiCompletion, "0.0") & "%"
      ProgressValue: =varHomePunchKpiCompletion
      TrendText: |-
        =If(
            varHomePunchKpiHasPreviousSnapshot,
            Text(Abs(varHomePunchKpiCompletionDelta), "0.0") & " pp vs previous snapshot",
            "No previous snapshot"
        )
      TrendDirection: |-
        =If(
            varHomePunchKpiCompletionDelta > 0,
            "up",
            If(varHomePunchKpiCompletionDelta < 0, "down", "neutral")
        )
      TrendTone: =If(varHomePunchKpiCompletionDelta >= 0, "success", "danger")
      TrendSeries: =colHomePunchKpiTrendCompletion
      VisualMode: ="donut"
      IconType: ="progress"
      AccentColor: =ColorValue("#14B8A6")
      AccentHex: ="#14B8A6"
      AccentSoftColor: =ColorValue("#F0FDFA")
      CardFill: =varTheme_Surface
      BorderColor: =varTheme_Border
      TextColor: =varTheme_Text
      MutedTextColor: =varTheme_TextMuted
      SuccessColor: =varTheme_Green
      WarningColor: =varTheme_Amber
      DangerColor: =varTheme_Red
      ShowSparkline: =true
      ShowTrend: =true
      ShowInfo: =true
      InfoTooltip: ="Closed punches divided by total punches."
      IsLoading: =varPunchDashboardLoading
      IsError: =!IsBlank(varPunchDashboardError)
      EnableClick: =false
```

---

# FASE 4 — Sustitución del donut

## 13. Mantener el alcance global

El nuevo donut no debe usar:

```text
colPunchExecutiveDistribution
```

porque esa colección cambia al seleccionar una celda del Heat Map.

Debe usar exclusivamente:

```text
colHomePunchDonutItems
```

que se construye desde `colPunchDashboardSummary`.

Así se garantiza que la selección del Heat Map no modifica el donut.

## 14. Sustituir el contenido de `conPunchExecutiveDonutSlot`

Ocultar temporalmente estos controles legacy:

```text
lblPunchExecutiveDonutSlotTitle
lblPunchExecutiveDonutSlotState
htmlPunchExecutiveDonut
lblPunchExecutiveDonutTotal
galPunchExecutiveDonutLegend
lblPunchExecutiveDonutEmpty
```

Añadir:

```yaml
- cmpHomePunchStatusDonut:
    Control: CanvasComponent
    ComponentName: cmp_DonutPro
    Properties:
      Width: =Parent.Width
      Height: =Parent.Height
      X: =0
      Y: =0
      Title: ="Punches by Status"
      Subtitle: ="Global project and template distribution"
      Items: =colHomePunchDonutItems
      State: |-
        =If(
            varPunchDashboardLoading,
            "loading",
            !IsBlank(varPunchDashboardError),
            "error",
            CountRows(colHomePunchDonutItems) = 0,
            "empty",
            "ready"
        )
      LoadingText: ="Loading status distribution..."
      ErrorText: =Coalesce(varPunchDashboardError, "Distribution unavailable.")
      EmptyText: ="No status distribution is available."
      CenterLabel: ="TOTAL"
      CenterValueText: =Text(varHomePunchKpiTotal, "[$-en-US]#,##0")
      AccentColor: =varTheme_PulseBlueDark
      BackgroundColor: =varTheme_Surface
      BorderColor: =varTheme_Border
      SurfaceAltColor: =varTheme_SurfaceAlt
      TextColor: =varTheme_Text
      MutedTextColor: =varTheme_TextMuted
      DangerColor: =varTheme_Red
      CenterFillColorHex: ="#FFFFFF"
      CenterValueColorHex: ="#0F172A"
      CenterLabelColorHex: ="#64748B"
      TrackColorHex: ="#E2E8F0"
      CompactMode: =true
      DonutThickness: =14
      SegmentGapPercent: =0.65
      ShowLegend: =true
      ShowValues: =true
      ShowPercentages: =true
      ShowZeroSegments: =false
      EnableSelection: =false
      ValueFormat: ="[$-en-US]#,##0"
      PercentageFormat: ="[$-en-US]0.0%"
```

### Altura

Mantener por ahora:

```powerfx
conPunchExecutiveDonutSlot.Height = 148
```

El componente se adapta a esa altura en modo compacto. No modificar el tamaño del Heat Map durante esta entrega.

---

# FASE 5 — Adaptador del nuevo grid

## 15. Crear `btnHome_RebuildPunchGridView`

```yaml
- btnHome_RebuildPunchGridView:
    Control: Button@0.0.45
    Properties:
      Visible: =false
      Width: =1
      Height: =1
      X: =24
      Y: =24
```

### `btnHome_RebuildPunchGridView.OnSelect`

```powerfx
// =====================================================
// NORMALIZE THE CURRENT SERVER PAGE
// =====================================================

ClearCollect(
    colHomePunchGridNormalized,

    ForAll(
        colPunchExecutiveGridFiltered As _row,

        {
            RowIndex:
                Coalesce(_row.SourceOrder, 0),

            RowKey:
                Text(_row.PunchId),

            PunchId:
                Coalesce(_row.PunchCode, Text(_row.PunchId)),

            Title:
                Coalesce(_row.PunchDescription, ""),

            Subsystem:
                Coalesce(_row.CategoryName, _row.CategoryCode, "No category") &
                " · " &
                Coalesce(_row.SubsystemCode, _row.SubsystemName, "No subsystem") &
                " · " &
                Coalesce(_row.DisciplineCode, _row.DisciplineName, "No discipline"),

            Discipline:
                Coalesce(_row.DisciplineName, _row.DisciplineCode, ""),

            Priority:
                Coalesce(_row.PriorityName, _row.PriorityCode, "—"),

            Status:
                Coalesce(_row.PunchStatus, _row.StatusName, _row.StatusCode, ""),

            DueDateText:
                "",

            IsOverdue:
                false,

            OwnerInitials:
                Upper(
                    Left(
                        Trim(
                            Coalesce(
                                _row.ResponsiblePerson,
                                _row.ResponsibleCompany,
                                "—"
                            )
                        ),
                        2
                    )
                ),

            OwnerName:
                Coalesce(_row.ResponsibleCompany, "") &
                If(
                    !IsBlank(_row.ResponsiblePerson),
                    " · " & _row.ResponsiblePerson,
                    ""
                ),

            ProgressPct:
                0
        }
    )
);


// =====================================================
// PAGE-LOCAL SEARCH AND QUICK FILTERS
// =====================================================

With(
    {
        _filtered:
            Filter(
                colHomePunchGridNormalized,

                (
                    IsBlank(Trim(varHomePunchSearchText)) ||

                    Lower(Trim(varHomePunchSearchText)) in Lower(Coalesce(PunchId, "")) ||
                    Lower(Trim(varHomePunchSearchText)) in Lower(Coalesce(Title, "")) ||
                    Lower(Trim(varHomePunchSearchText)) in Lower(Coalesce(Subsystem, "")) ||
                    Lower(Trim(varHomePunchSearchText)) in Lower(Coalesce(Priority, "")) ||
                    Lower(Trim(varHomePunchSearchText)) in Lower(Coalesce(Status, "")) ||
                    Lower(Trim(varHomePunchSearchText)) in Lower(Coalesce(OwnerName, ""))
                ) &&

                Switch(
                    Upper(Coalesce(varHomePunchQuickFilter, "ALL")),

                    "OPEN",
                        Upper(Trim(Coalesce(Status, ""))) in ["OPEN", "O"],

                    "CLOSED",
                        Upper(Trim(Coalesce(Status, ""))) in ["CLOSED", "CLOSE", "CL"],

                    true
                )
            )
    },

    With(
        {
            _sorted:
                SortByColumns(
                    _filtered,
                    Coalesce(varHomePunchGridSortKey, "PunchId"),
                    If(
                        Lower(Coalesce(varHomePunchGridSortDirection, "asc")) = "desc",
                        SortOrder.Descending,
                        SortOrder.Ascending
                    )
                )
        },

        ClearCollect(
            colHomePunchGridView,

            ForAll(
                Sequence(CountRows(_sorted)) As _position,

                Patch(
                    Last(
                        FirstN(
                            _sorted,
                            _position.Value
                        )
                    ),

                    {
                        RowIndex: _position.Value
                    }
                )
            )
        )
    )
);

If(
    !IsBlank(varHomePunchGridSelectedKey) &&
    IsBlank(
        LookUp(
            colHomePunchGridView,
            RowKey = varHomePunchGridSelectedKey
        )
    ),

    Set(varHomePunchGridSelectedKey, "")
)
```

---

## 16. Ejecutar el adaptador después del flow de detalle

Control afectado:

```text
btnPunchExecutiveLoadCellDetails.OnSelect
```

Después de completar correctamente:

```text
ClearCollect(colPunchExecutiveGridFiltered, ...)
```

Añadir:

```powerfx
Select(btnHome_RebuildPunchGridView)
```

En las ramas de error y de respuesta vacía, añadir:

```powerfx
Clear(colHomePunchGridNormalized);
Clear(colHomePunchGridView)
```

---

## 17. Crear `btnHome_ClearPunchGridUi`

```yaml
- btnHome_ClearPunchGridUi:
    Control: Button@0.0.45
    Properties:
      Visible: =false
      Width: =1
      Height: =1
      X: =28
      Y: =28
```

### `OnSelect`

```powerfx
Clear(colPunchExecutiveGridFiltered);
Clear(colHomePunchGridNormalized);
Clear(colHomePunchGridView);

Set(varHomePunchSearchText, "");
Set(varHomePunchQuickFilter, "ALL");
Set(varHomePunchGridSelectedKey, "");
Set(varHomePunchGridSortKey, "PunchId");
Set(varHomePunchGridSortDirection, "asc");
Set(varPunchExecutiveGridPage, 1);

Reset(cmpHomePunchSmartFilterBar)
```

### Conexiones

Añadir al final de estas fórmulas existentes:

```text
cmpPunchExecutiveHeatmapPro.OnClearSelection
btnPunchExecutiveClearSelection.OnSelect
```

esta llamada:

```powerfx
Select(btnHome_ClearPunchGridUi)
```

Añadir también al inicio de `cmpPunchExecutiveHeatmapPro.OnCellSelect`, antes de activar la nueva carga:

```powerfx
Set(varHomePunchSearchText, "");
Set(varHomePunchQuickFilter, "ALL");
Set(varHomePunchGridSelectedKey, "");
Clear(colHomePunchGridNormalized);
Clear(colHomePunchGridView);
Reset(cmpHomePunchSmartFilterBar)
```

El Heat Map no cambia visualmente; solo limpia el estado del grid cuando cambia la celda activa.

---

# FASE 6 — Smart Filter Bar

## 18. Añadir `cmpHomePunchSmartFilterBar`

Añadir como hijo directo de `conPunchDashboardBody_1`, inmediatamente después de `conPunchExecutiveAnalyticsWorkspace`.

```yaml
- cmpHomePunchSmartFilterBar:
    Control: CanvasComponent
    ComponentName: cmp_SmartFilterBarPro
    Properties:
      Width: =Parent.Width
      Height: =118
      AccentColor: =varTheme_PulseBlueDark
      BackgroundColor: =varTheme_Surface
      SurfaceAltColor: =varTheme_SurfaceAlt
      BorderColor: =varTheme_Border
      TextColor: =varTheme_Text
      MutedTextColor: =varTheme_TextMuted
      DangerColor: =varTheme_Red
      SearchTextIn: =varHomePunchSearchText
      SearchPlaceholder: ="Search current page..."
      SelectedQuickFilterIn: =varHomePunchQuickFilter
      DensityIn: =varHomePunchGridDensity
      IsLoading: =varPunchExecutiveGridLoading
      QuickFilters: |-
        =Table(
            {
                Key: "ALL",
                Label: "All",
                Count: CountRows(colHomePunchGridNormalized),
                Tone: "neutral"
            },
            {
                Key: "OPEN",
                Label: "Open",
                Count:
                    CountIf(
                        colHomePunchGridNormalized,
                        Upper(Trim(Coalesce(Status, ""))) in ["OPEN", "O"]
                    ),
                Tone: "info"
            },
            {
                Key: "CLOSED",
                Label: "Closed",
                Count:
                    CountIf(
                        colHomePunchGridNormalized,
                        Upper(Trim(Coalesce(Status, ""))) in ["CLOSED", "CLOSE", "CL"]
                    ),
                Tone: "success"
            }
        )
      ActiveFilters: |-
        =Filter(
            Table(
                {
                    Key: "SUBCONTRACTOR",
                    Label: "Subcontractor",
                    Value:
                        If(
                            CountRows(colPunchExecutiveSelection) > 0 &&
                            First(colPunchExecutiveSelection).IsSelection,
                            Coalesce(varPunchDrillSubcontractorName, ""),
                            ""
                        ),
                    DisplayText:
                        "Subcontractor: " &
                        Coalesce(varPunchDrillSubcontractorName, "")
                },
                {
                    Key: "CATEGORY",
                    Label: "Category",
                    Value:
                        If(
                            CountRows(colPunchExecutiveSelection) > 0 &&
                            First(colPunchExecutiveSelection).IsSelection,
                            Coalesce(varPunchDrillCategoryCode, ""),
                            ""
                        ),
                    DisplayText:
                        "Category: " &
                        Coalesce(varPunchDrillCategoryCode, "")
                }
            ),
            !IsBlank(Value)
        )
      ResultCount: =CountRows(colHomePunchGridView)
      TotalCount: =CountRows(colHomePunchGridNormalized)
      NoFiltersText: ="Select a heatmap cell to load punches"
      ShowSearch: =true
      ShowQuickFilters: =true
      ShowActiveFilters: =true
      ShowFiltersButton: =false
      ShowSavedViews: =false
      ShowRefresh: =true
      ShowExport: =true
      ShowColumnSelector: =false
      ShowDensity: =true
      OnSearchChanged: |-
        =
        Set(
            varHomePunchSearchText,
            cmpHomePunchSmartFilterBar.SearchText
        );
        Select(btnHome_RebuildPunchGridView)
      OnQuickFilterSelected: |-
        =
        Set(
            varHomePunchQuickFilter,
            cmpHomePunchSmartFilterBar.SelectedQuickFilterKey
        );
        Select(btnHome_RebuildPunchGridView)
      OnRemoveFilter: |-
        =
        If(
            cmpHomePunchSmartFilterBar.FilterKeyToRemove in ["SUBCONTRACTOR", "CATEGORY"],
            Select(btnPunchExecutiveClearSelection)
        )
      OnClearAll: |-
        =
        Set(varHomePunchSearchText, "");
        Set(varHomePunchQuickFilter, "ALL");
        Select(btnPunchExecutiveClearSelection)
      OnRefresh: |-
        =
        Set(varPunchDashboardForceRefresh, true);
        Select(btnHome_RequestDashboardLoad_1)
      OnExport: =Select(btnHome_ExportPunchGrid)
      OnDensityChanged: |-
        =Set(
            varHomePunchGridDensity,
            cmpHomePunchSmartFilterBar.Density
        )
```

### Decisión de selector de columnas

En esta entrega:

```powerfx
cmpHomePunchSmartFilterBar.ShowColumnSelector = false
```

El selector de columnas que se utiliza es el integrado dentro de `cmp_DataTableProV2`. Mantener ambos produciría dos botones distintos para la misma función y el botón del FilterBar no puede abrir directamente el panel interno del DataTable.

---

# FASE 7 — DataTable Pro V2

## 19. Ocultar el grid legacy

Control afectado:

```text
conPunchExecutiveGridWorkspace
```

Propiedades provisionales:

```powerfx
Visible = false
Height = 0
LayoutMinHeight = 0
```

No borrarlo hasta terminar la validación.

## 20. Añadir `cmpHomePunchDataTablePro`

Añadir como hijo directo de `conPunchDashboardBody_1`, inmediatamente después de `cmpHomePunchSmartFilterBar`.

```yaml
- cmpHomePunchDataTablePro:
    Control: CanvasComponent
    ComponentName: cmp_DataTableProV2
    Properties:
      Width: =Parent.Width
      Height: =408
      Rows: =colHomePunchGridView
      Columns: =colHomePunchGridColumns
      SelectedKeys: =FirstN(Table({RowKey: ""}), 0)
      SelectedRowKeyIn: =varHomePunchGridSelectedKey
      AllMatchingSelectedIn: =false
      SortKeyIn: =varHomePunchGridSortKey
      SortDirectionIn: =varHomePunchGridSortDirection
      CurrentPage: =Max(1, Coalesce(varPunchExecutiveGridPage, 1))
      TotalPages: =Max(0, Coalesce(varPunchExecutiveGridTotalPages, 0))
      TotalCount: =Max(0, Coalesce(varPunchExecutiveGridTotalRows, 0))
      RowsPerPage: =Max(1, Coalesce(varPunchExecutiveGridPageSize, 25))
      VisibleStart: |-
        =If(
            Coalesce(varPunchExecutiveGridTotalRows, 0) = 0,
            0,
            ((Max(1, varPunchExecutiveGridPage) - 1) * varPunchExecutiveGridPageSize) + 1
        )
      VisibleEnd: |-
        =Min(
            Coalesce(varPunchExecutiveGridTotalRows, 0),
            Max(1, varPunchExecutiveGridPage) * varPunchExecutiveGridPageSize
        )
      DensityIn: =varHomePunchGridDensity
      IsLoading: =varPunchExecutiveGridLoading
      LoadingText: =Coalesce(varPunchExecutiveGridMessage, "Loading punches...")
      EmptyTitle: |-
        =If(
            CountRows(colPunchExecutiveSelection) = 0 ||
            !First(colPunchExecutiveSelection).IsSelection,
            "Select a heatmap cell",
            "No punches found"
        )
      EmptyText: |-
        =If(
            CountRows(colPunchExecutiveSelection) = 0 ||
            !First(colPunchExecutiveSelection).IsSelection,
            "Select a subcontractor and category cell to load its punches.",
            Coalesce(
                varPunchExecutiveGridError,
                varPunchExecutiveGridMessage,
                "No punches match the current page filters."
            )
        )
      AccentColor: =varTheme_PulseBlueDark
      BackgroundColor: =varTheme_Surface
      SurfaceAltColor: =varTheme_SurfaceAlt
      BorderColor: =varTheme_Border
      TextColor: =varTheme_Text
      MutedTextColor: =varTheme_TextMuted
      SuccessColor: =varTheme_Green
      WarningColor: =varTheme_Amber
      DangerColor: =varTheme_Red
      ShowCheckboxes: =false
      ShowBulkActions: =false
      ShowSelectAllMatching: =false
      ShowColumnSelector: =true
      ShowRowActions: =true
      ShowPagination: =true
      ContextActions: |-
        =Table(
            {
                Key: "OPEN",
                Label: "Open details",
                Tone: "primary",
                IsVisible: true,
                Order: 1
            },
            {
                Key: "COMMENT",
                Label: "Open comments",
                Tone: "neutral",
                IsVisible: true,
                Order: 2
            },
            {
                Key: "HISTORY",
                Label: "View history",
                Tone: "neutral",
                IsVisible: true,
                Order: 3
            },
            {
                Key: "EXPORT",
                Label: "Export row",
                Tone: "neutral",
                IsVisible: true,
                Order: 4
            }
        )
      OnRowSelect: |-
        =Set(
            varHomePunchGridSelectedKey,
            cmpHomePunchDataTablePro.SelectedRowKeyOut
        )
      OnSort: |-
        =
        Set(
            varHomePunchGridSortKey,
            cmpHomePunchDataTablePro.SortKeyOut
        );
        Set(
            varHomePunchGridSortDirection,
            cmpHomePunchDataTablePro.SortDirectionOut
        );
        Select(btnHome_RebuildPunchGridView)
      OnPageChange: |-
        =
        Set(
            varPunchExecutiveGridPage,
            cmpHomePunchDataTablePro.PageRequestedOut
        );
        Select(btnPunchExecutiveLoadCellDetails)
      OnRowsPerPage: |-
        =
        Set(
            varPunchExecutiveGridPageSize,
            Switch(
                Max(1, Coalesce(varPunchExecutiveGridPageSize, 25)),
                25, 50,
                50, 100,
                100, 25,
                25
            )
        );
        Set(varPunchExecutiveGridPage, 1);
        Select(btnPunchExecutiveLoadCellDetails)
      OnColumnToggle: |-
        =
        With(
            {
                _column:
                    LookUp(
                        colHomePunchGridColumns,
                        Key = cmpHomePunchDataTablePro.ColumnToggleKeyOut
                    )
            },
            If(
                !IsBlank(_column) && !_column.IsLocked,
                Patch(
                    colHomePunchGridColumns,
                    _column,
                    {
                        IsVisible: !_column.IsVisible
                    }
                )
            )
        )
      OnColumnAction: |-
        =
        If(
            cmpHomePunchDataTablePro.ColumnActionOut = "RESET",

            ClearCollect(
                colHomePunchGridColumns,
                {Key:"PunchId", Label:"Punch", IsVisible:true, IsLocked:true, Width:116, Sortable:true, Order:1},
                {Key:"Title", Label:"Description", IsVisible:true, IsLocked:true, Width:360, Sortable:true, Order:2},
                {Key:"Subsystem", Label:"Category / Subsystem / Discipline", IsVisible:true, IsLocked:false, Width:300, Sortable:true, Order:3},
                {Key:"Discipline", Label:"Discipline", IsVisible:false, IsLocked:false, Width:110, Sortable:true, Order:4},
                {Key:"Priority", Label:"Priority", IsVisible:true, IsLocked:false, Width:108, Sortable:true, Order:5},
                {Key:"Status", Label:"Status", IsVisible:true, IsLocked:false, Width:100, Sortable:true, Order:6},
                {Key:"DueDateText", Label:"Due Date", IsVisible:false, IsLocked:false, Width:108, Sortable:false, Order:7},
                {Key:"OwnerName", Label:"Responsible", IsVisible:true, IsLocked:false, Width:240, Sortable:true, Order:8},
                {Key:"ProgressPct", Label:"Progress", IsVisible:false, IsLocked:false, Width:116, Sortable:false, Order:9}
            )
        )
      OnContextAction: |-
        =
        With(
            {
                _row:
                    LookUp(
                        colPunchExecutiveGridFiltered,
                        Text(PunchId) = cmpHomePunchDataTablePro.ContextRowKeyOut
                    ),
                _action:
                    cmpHomePunchDataTablePro.ContextActionKeyOut
            },

            If(
                IsBlank(_row),

                Notify(
                    "The selected Punch row is no longer available.",
                    NotificationType.Warning
                ),

                If(
                    _action = "EXPORT",

                    Download(
                        "data:text/csv;charset=utf-8," &
                        EncodeUrl(
                            "Punch Code,Description,Status,Category,Subsystem,Discipline,Responsible Company,Responsible Person,Priority" &
                            Char(10) &
                            Char(34) & Substitute(Coalesce(_row.PunchCode, ""), Char(34), Char(34) & Char(34)) & Char(34) & "," &
                            Char(34) & Substitute(Coalesce(_row.PunchDescription, ""), Char(34), Char(34) & Char(34)) & Char(34) & "," &
                            Coalesce(_row.PunchStatus, "") & "," &
                            Coalesce(_row.CategoryName, "") & "," &
                            Coalesce(_row.SubsystemCode, "") & "," &
                            Coalesce(_row.DisciplineCode, "") & "," &
                            Char(34) & Substitute(Coalesce(_row.ResponsibleCompany, ""), Char(34), Char(34) & Char(34)) & Char(34) & "," &
                            Char(34) & Substitute(Coalesce(_row.ResponsiblePerson, ""), Char(34), Char(34) & Char(34)) & Char(34) & "," &
                            Coalesce(_row.PriorityCode, "")
                        )
                    ),

                    Set(varDrawerRecordId, _row.PunchId);
                    Set(varDrawerEntityType, "PUNCH");
                    Set(varDrawerSelectedRecord, _row);

                    Set(
                        varDrawerTab,
                        Switch(
                            _action,
                            "COMMENT", "Comments",
                            "HISTORY", "History",
                            "Overview"
                        )
                    );

                    Set(varShowDetailDrawer, true);
                    Select(btnDrawerLoad_2)
                )
            )
        )
```

### Por qué se desactiva el multi-select en esta entrega

El componente lo soporta, pero Home no tiene todavía un contrato consolidado para operaciones masivas sobre selección multirregistro. Activarlo ahora mostraría acciones no funcionales como `Mark reviewed`.

Configuración temporal:

```powerfx
ShowCheckboxes = false
ShowBulkActions = false
ShowSelectAllMatching = false
```

Cuando se integre el Punch Review Workspace podrá habilitarse sin sustituir el grid.

---

# FASE 8 — Exportación desde FilterBar

## 21. Crear `btnHome_ExportPunchGrid`

```yaml
- btnHome_ExportPunchGrid:
    Control: Button@0.0.45
    Properties:
      Visible: =false
      Width: =1
      Height: =1
      X: =32
      Y: =32
```

### `OnSelect`

Esta fórmula conserva el enfoque de exportación local actual, elimina Due Date y exporta los registros del bundle que coinciden con la celda seleccionada:

```powerfx
With(
    {
        _rows:
            Filter(
                colPunchDashboardPunches,

                (
                    IsBlank(varPunchDrillCategoryCode) ||
                    CategoryCode = varPunchDrillCategoryCode
                ) &&

                (
                    Coalesce(varPunchDrillSubcontractorId, -1) < 0 ||

                    Value(Coalesce(SubcontractorId, -1)) =
                        Value(varPunchDrillSubcontractorId) ||

                    Lower(
                        Trim(
                            Coalesce(
                                SubcontractorName,
                                ResponsibleCompany,
                                ""
                            )
                        )
                    ) =
                    Lower(
                        Trim(
                            Coalesce(varPunchDrillSubcontractorName, "")
                        )
                    )
                )
            )
    },

    If(
        CountRows(_rows) = 0,

        Notify(
            "There are no Punch rows available to export for the selected cell.",
            NotificationType.Information
        ),

        Download(
            "data:text/csv;charset=utf-8," &
            EncodeUrl(
                "Punch Code,Description,Status,Category,Subsystem,Discipline,Responsible Company,Responsible Person,Priority" &
                Char(10) &

                Concat(
                    _rows,

                    Char(34) & Substitute(Coalesce(PunchCode, ""), Char(34), Char(34) & Char(34)) & Char(34) & "," &
                    Char(34) & Substitute(Coalesce(PunchDescription, ""), Char(34), Char(34) & Char(34)) & Char(34) & "," &
                    Coalesce(PunchStatus, "") & "," &
                    Coalesce(CategoryName, "") & "," &
                    Coalesce(SubsystemCode, "") & "," &
                    Coalesce(DisciplineCode, "") & "," &
                    Char(34) & Substitute(Coalesce(ResponsibleCompany, ""), Char(34), Char(34) & Char(34)) & Char(34) & "," &
                    Char(34) & Substitute(Coalesce(ResponsiblePerson, ""), Char(34), Char(34) & Char(34)) & Char(34) & "," &
                    Coalesce(PriorityCode, "") &
                    Char(10)
                )
            )
        )
    )
)
```

---

# FASE 9 — Resets por proyecto y plantilla

## 22. `cmbHomePunchTemplateHeader_1.OnChange`

Después de limpiar las colecciones actuales, añadir:

```powerfx
Clear(colHomePunchGridNormalized);
Clear(colHomePunchGridView);
Clear(colHomePunchDonutItems);

Set(varHomePunchSearchText, "");
Set(varHomePunchQuickFilter, "ALL");
Set(varHomePunchGridSelectedKey, "");
Set(varHomePunchGridSortKey, "PunchId");
Set(varHomePunchGridSortDirection, "asc")
```

## 23. `btnHome_ProjectChange_Commit_2.OnSelect`

En la sección `PUNCH DASHBOARD RESET`, añadir:

```powerfx
Clear(colHomePunchGridNormalized);
Clear(colHomePunchGridView);
Clear(colHomePunchDonutItems);
Clear(colHomePunchKpiTrendTotal);
Clear(colHomePunchKpiTrendOpen);
Clear(colHomePunchKpiTrendClosed);
Clear(colHomePunchKpiTrendCompletion);

Set(varHomePunchSearchText, "");
Set(varHomePunchQuickFilter, "ALL");
Set(varHomePunchGridSelectedKey, "");
Set(varHomePunchGridSortKey, "PunchId");
Set(varHomePunchGridSortDirection, "asc")
```

No resetear `varHomePunchGridDensity` ni `colHomePunchGridColumns`; son preferencias visuales que conviene conservar al cambiar de proyecto.

---

# FASE 10 — Layout final

## 24. Propiedades de layout

| Control | Propiedad | Valor |
|---|---|---:|
| `conPunchExecutiveKpiStrip` | `Height` | `96` |
| `conPunchExecutiveKpiStrip` | `LayoutMinHeight` | `96` |
| `conPunchExecutiveAnalyticsWorkspace` | `Height` | `320` — sin cambio |
| `cmpPunchExecutiveHeatmapPro` | dimensiones | sin cambio |
| `conPunchExecutiveDonutSlot` | `Height` | `148` — sin cambio |
| `cmpHomePunchSmartFilterBar` | `Height` | `118` |
| `cmpHomePunchDataTablePro` | `Height` | `408` |
| `conPunchExecutiveGridWorkspace` | `Visible` | `false` |
| `conPunchExecutiveGridWorkspace` | `Height` | `0` |
| `conPunchExecutiveGridWorkspace` | `LayoutMinHeight` | `0` |
| `conPunchDashboardBody_1` | `LayoutGap` | `10` o `12` |
| `conPunchDashboardBody_1` | `LayoutOverflowY` | `LayoutOverflow.Scroll` |

La pantalla tendrá scroll vertical. Es preferible a comprimir el Heat Map o reducir el grid hasta perder legibilidad.

---

# FASE 11 — Controles legacy que se eliminan después de validar

## 25. KPI legacy

```text
conPunchExecutiveKpiTotal
conPunchExecutiveKpiOpen
conPunchExecutiveKpiClosed
```

## 26. Donut legacy

```text
lblPunchExecutiveDonutSlotTitle
lblPunchExecutiveDonutSlotState
htmlPunchExecutiveDonut
lblPunchExecutiveDonutTotal
galPunchExecutiveDonutLegend
lblPunchExecutiveDonutEmpty
```

## 27. Grid legacy

Eliminar el contenido visual de:

```text
conPunchExecutiveGridWorkspace
```

solo cuando se haya confirmado que ya no se utiliza ninguna fórmula de sus botones.

No eliminar:

```text
btnPunchExecutiveLoadCellDetails
tmrPunchExecutiveGridLoadDelay
```

porque siguen siendo el mecanismo de carga paginada del nuevo DataTable.

---

# FASE 12 — Matriz de pruebas

## 28. Carga general

1. Abrir Home sin proyecto.
   - No debe aparecer información residual.
2. Seleccionar proyecto.
3. Seleccionar plantilla.
4. Verificar que aparecen cuatro KPI.
5. Verificar que el donut representa todos los estados globales.
6. Confirmar que el grid permanece vacío hasta seleccionar una celda.

## 29. KPI

| Prueba | Resultado esperado |
|---|---|
| Total | suma de `colPunchDashboardSummary.PunchCount` |
| Open | solo estados `OPEN/O` |
| Closed | `CLOSED/CLOSE/CL` |
| Completion | `Closed / Total × 100` |
| Sin timeline anterior | texto `No previous snapshot` |
| Open baja | flecha abajo, tono verde |
| Closed sube | flecha arriba, tono verde |
| Completion sube | flecha arriba, tono verde |

## 30. Donut

1. Debe mostrar distribución global al cargar.
2. Seleccionar una celda del Heat Map.
3. El donut debe permanecer sin cambios.
4. No debe permitir selección interactiva.
5. No debe mostrar segmentos con valor cero.

## 31. Heat Map y detalle

1. Seleccionar una celda.
2. Deben aparecer chips de Subcontractor y Category.
3. Debe ejecutarse `warroom_GetPunchDashboardCellDetails`.
4. El panel `Selected Cell Details` debe seguir funcionando.
5. `Clear Selection` debe limpiar grid y FilterBar.

## 32. FilterBar

1. Quick filters permitidos:
   - All
   - Open
   - Closed
2. No deben existir:
   - Critical
   - Overdue
   - Risk
   - Due Date
3. `Search current page...` debe buscar sobre:
   - Punch
   - Description
   - Contexto Category/Subsystem/Discipline
   - Priority
   - Status
   - Responsible
4. `Refresh` debe recargar el bundle.
5. `Export` no debe incluir Due Date.
6. `Density` debe cambiar la altura de filas.
7. No debe aparecer botón de filtros avanzados.
8. No debe aparecer Saved Views.
9. No debe aparecer el selector de columnas en FilterBar.

## 33. DataTable

Columnas visibles por defecto:

```text
Punch
Description
Category / Subsystem / Discipline
Priority
Status
Responsible
```

Columnas ocultas:

```text
Discipline independiente
Due Date
Progress
```

Pruebas:

1. Ordenación local de la página.
2. Primera página.
3. Página anterior.
4. Ventana numérica de páginas.
5. Página siguiente.
6. Última página.
7. Ciclo de tamaño 25 → 50 → 100 → 25.
8. Selector de columnas.
9. Restaurar columnas.
10. Menú contextual.
11. Abrir detalle.
12. Abrir Comments.
13. Abrir History.
14. Exportar una fila.

## 34. Búsqueda textual de conceptos prohibidos

Antes de cerrar la implementación, buscar en el bloque visible nuevo:

```text
Overdue
Risk
Due Date
Critical
```

Resultados permitidos:

- `DueDateText` puede existir únicamente como campo técnico oculto requerido por el contrato del componente.
- `Critical` puede existir únicamente como valor real de `Priority` si la fuente de datos lo devuelve; no como KPI, quick filter, chip ni regla de Home.
- No debe aparecer ninguno de esos conceptos como control visible nuevo.

---

# FASE 13 — Criterio de cierre

La consolidación se considera terminada cuando:

1. Home carga sin errores de Source Code schema.
2. No hay errores `PA1001`, `PA1003` ni `PA2108` en los cuatro componentes.
3. No queda ningún `Char()` con códigos superiores a 255.
4. Los cuatro KPI utilizan el bundle actual, sin flow nuevo.
5. El donut permanece global después de seleccionar el Heat Map.
6. El Heat Map conserva su comportamiento y diseño.
7. El grid solo carga al seleccionar una celda.
8. La paginación sigue usando `warroom_GetPunchDashboardCellDetails`.
9. Search, quick filters y sort se identifican como operaciones de página actual.
10. Priority es visible.
11. Due Date, Risk, Overdue y Critical no aparecen como elementos funcionales de Home.
12. Los controles legacy permanecen disponibles durante la prueba y se eliminan solo después de validar.

---

# Orden de ejecución recomendado

1. Importar o actualizar los cuatro componentes.
2. Usar `cmp_DataTablePro_HomeReady.pa.yaml`.
3. Añadir variables y colecciones de `OnVisible`.
4. Crear `btnHome_BuildPunchPresentationModel`.
5. Conectarlo al final del bundle.
6. Sustituir el strip de KPI.
7. Sustituir el donut.
8. Crear `btnHome_RebuildPunchGridView`.
9. Conectarlo al flow de detalle.
10. Crear `btnHome_ClearPunchGridUi`.
11. Añadir SmartFilterBar.
12. Añadir DataTableProV2.
13. Crear exportación.
14. Ocultar el grid legacy.
15. Ejecutar la matriz de pruebas.
16. Eliminar controles legacy.
17. Exportar la solución y validar importación en un entorno controlado.
