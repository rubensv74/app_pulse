# PULSE — Guía ejecutable para Home y Punch Review Workspace

**Fecha:** 2026-08-05  
**Repositorio:** `rubensv74/app_pulse`  
**Base auditada:** rama `main`, commit `0e4bcefcbaa9a4179bd36835317c188fbc807be1`  
**Auditoría asociada:** `docs/analysis/punch-review-workspace/REPOSITORY_AUDIT_2026-08-05.md`

## 1. Objetivo

Corregir la navegación y el dashboard Home, conectar los componentes ya existentes y construir un Punch Review Workspace reutilizable desde Home y Punches sin atribuir al sistema capacidades persistentes que todavía no existen.

## 2. Orden de ejecución

1. Corregir el bloqueo de navegación.
2. Reconstruir el header responsive.
3. Reparar el anillo de `cmp_DonutPro`.
4. Insertar `cmp_SmartFilterBarPro_Stable`.
5. Sustituir el dataset de ejemplo de `cmp_DataTableProV2_1` por las colecciones reales.
6. Incorporar analítica completa de la celda seleccionada.
7. Crear `scr_PunchReview` como workspace dedicado.
8. Corregir el contrato de comentarios del drawer heredado.
9. Añadir persistencia de revisión y concurrencia en una fase separada.

---

# Fase 1 — Navegación

## Controles

```text
scr_Home > cmp_NavApp_2 > OnSelectItem
scr_Punches > cmp_NavApp_Punches_2 > OnSelectItem
```

La fórmula actual bloquea todas las pantallas mediante `_hasConfig`. Sustituir la barrera global por validaciones por destino. Punches, Tasks, Config, Briefing y Skyline requieren proyecto, pero no una configuración publicada de reporting. Overview puede mantener su prerrequisito específico.

```powerfx
With(
    {
        _key: Lower(Trim(Self.SelectedItemKey)),
        _hasProject: !IsBlank(varProjectId),
        _hasReportConfig:
            Coalesce(varProjectHasReportConfig, false) ||
            Coalesce(varHomeHiveLoaded, false) ||
            Coalesce(varProjectHasPHRData, false)
    },
    If(
        _key = "superadmin",
        Set(varAppView, "SuperAdmin");
        Set(varPageKey, "SUPERADMIN");
        Set(varPageTitle, "Administration");
        Set(varPageSubtitle, "Platform configuration and governance");
        Navigate(scr_SuperAdmin, ScreenTransition.None),
        If(
            _key <> "home" && !_hasProject,
            Notify("Please select a project first.", NotificationType.Warning),
            Switch(
                _key,
                "home",
                    Set(varAppView, "Home");
                    Set(varPageKey, "HOME");
                    Set(varPageTitle, "Home");
                    Set(varPageSubtitle, "Project command center");
                    Set(varHomeViewMode, "DASHBOARD");
                    Navigate(scr_Home, ScreenTransition.None),
                "overview",
                    If(
                        !_hasReportConfig,
                        Notify(
                            "This project has no published report configuration yet.",
                            NotificationType.Warning
                        ),
                        Set(varAppView, "Overview");
                        Set(varPageKey, "OVERVIEW");
                        Set(varPageTitle, "Overview");
                        Set(varOps_ViewMode, "OVERVIEW");
                        Navigate(scr_Overview, ScreenTransition.None)
                    ),
                "tasks",
                    Set(varAppView, "Tasks");
                    Navigate(scr_Tasks, ScreenTransition.None),
                "punches",
                    Set(varAppView, "Punches");
                    Navigate(scr_Punches, ScreenTransition.None),
                "briefing",
                    Set(varAppView, "Briefing");
                    Navigate(scr_Briefing, ScreenTransition.None),
                "config",
                    Set(varAppView, "Config");
                    Navigate(scr_Config_NEW, ScreenTransition.None),
                "skyline",
                    Set(varAppView, "Skyline");
                    Navigate(scr_Skyline, ScreenTransition.None),
                Notify("Key not mapped: [" & _key & "]", NotificationType.Error)
            )
        )
    )
)
```

---

# Fase 2 — Header de Home

## Control

```text
conExecutiveHeader_2
```

Aplicar:

```powerfx
Height = If(App.Width < 1450, 104, 68)
LayoutDirection = If(App.Width < 1450, LayoutDirection.Vertical, LayoutDirection.Horizontal)
LayoutAlignItems = LayoutAlignItems.Stretch
LayoutJustifyContent = LayoutJustifyContent.SpaceBetween
LayoutGap = 8
PaddingLeft = 14
PaddingRight = 14
PaddingTop = 8
PaddingBottom = 8
```

Separar el header en:

```text
conHomeExecutiveIdentity
conHomeExecutiveActions
```

Eliminar `LayoutMinWidth = 390` del bloque de título y utilizar `260`. El bloque de acciones debe ocupar el ancho restante y contener proyecto, plantilla y refresh en una sola fila interna.

---

# Fase 3 — `cmp_DonutPro`

## Diagnóstico

La leyenda y los valores aparecen, por lo que `Items` es válido. El anillo depende de un SVG directo dentro de `HtmlViewer@2.1.0`. Sustituir únicamente la capa gráfica por `Image@2.2.3` usando una URI SVG codificada.

## Cambio

```text
htmlDNP_Donut: HtmlViewer@2.1.0
```

por:

```text
imgDNP_Donut: Image@2.2.3
```

Propiedades:

```powerfx
Height = Parent.Height - 52
Width = If(cmp_DonutPro.CompactMode, Parent.Width * 0.46, Parent.Width * 0.58)
X = 8
Y = 48
ImagePosition = ImagePosition.Fit
```

La fórmula completa del SVG, junto con el cálculo acumulado de segmentos, se conserva en la versión descargable de esta guía. En Home usar:

```powerfx
Items = colHomePunchDonutItems
EnableSelection = false
CompactMode = true
ShowLegend = true
ShowPercentages = true
ShowValues = true
```

`EnableSelection=false` evita que dos donuts compartan accidentalmente `varDNP_SelectedSegmentKey`, que actualmente es global.

---

# Fase 4 — SmartBar

## Nombre real

```text
Archivo: cmp_SmartFilterBarPro.pa.yaml
ComponentName: cmp_SmartFilterBarPro_Stable
Instancia: cmpHomePunchSmartFilterBar
```

Insertar dentro de `conPunchExecutiveGridWorkspace`, entre el header del grid y la tabla. El nombre de instancia es obligatorio porque Home ya ejecuta `Reset(cmpHomePunchSmartFilterBar)`.

```powerfx
SearchTextIn = varHomePunchSearchText
SelectedQuickFilterIn = varHomePunchQuickFilter
DensityIn = varHomePunchGridDensity
ShowAdvancedFilters = false
ShowDensity = true
ShowClearAll = true
```

Eventos:

```powerfx
OnSearch =
Set(varHomePunchSearchText, Coalesce(Self.SearchText, ""));
Set(varPunchExecutiveGridPage, 1);
Select(btnHome_RebuildPunchGridView)
```

```powerfx
OnQuickFilterSelected =
Set(varHomePunchQuickFilter, Coalesce(Self.SelectedQuickFilterKey, "ALL"));
Set(varPunchExecutiveGridPage, 1);
Select(btnHome_RebuildPunchGridView)
```

```powerfx
OnDensityChanged =
Set(varHomePunchGridDensity, Coalesce(Self.Density, "Compact"))
```

```powerfx
OnClearAll =
Set(varHomePunchSearchText, "");
Set(varHomePunchQuickFilter, "ALL");
Set(varHomePunchGridSelectedKey, "");
Set(varPunchExecutiveGridPage, 1);
Reset(cmpHomePunchSmartFilterBar);
Select(btnHome_RebuildPunchGridView)
```

---

# Fase 5 — Grid real

## Control

```text
cmp_DataTableProV2_1
```

Eliminar las filas `PULSE-02457`, `PULSE-02459`, `TotalCount=248`, `TotalPages=10` y `Width=1380`.

```powerfx
Rows = colHomePunchGridView
Columns = colHomePunchGridColumns
CurrentPage = varPunchExecutiveGridPage
RowsPerPage = varPunchExecutiveGridPageSize
TotalCount = varPunchExecutiveGridTotalRows
TotalPages = varPunchExecutiveGridTotalPages
DensityIn = varHomePunchGridDensity
SortKeyIn = varHomePunchGridSortKey
SortDirectionIn = varHomePunchGridSortDirection
SelectedRowKeyIn = varHomePunchGridSelectedKey
IsLoading = varPunchExecutiveGridLoading
Width = Parent.Width - 24
X = 12
Y = cmpHomePunchSmartFilterBar.Y + cmpHomePunchSmartFilterBar.Height + 8
Height = Parent.Height - Self.Y - 12
```

```powerfx
OnRowSelect =
Set(varHomePunchGridSelectedKey, Self.SelectedRowKeyOut)
```

```powerfx
OnSort =
Set(varHomePunchGridSortKey, Self.SortKeyOut);
Set(varHomePunchGridSortDirection, Self.SortDirectionOut);
Select(btnHome_RebuildPunchGridView)
```

```powerfx
OnPageChange =
Set(varPunchExecutiveGridPage, Max(1, Self.PageRequestedOut));
Select(btnPunchExecutiveLoadCellDetails)
```

La SmartBar filtra la página cargada mientras esos criterios no se trasladen al SP. No presentar sus conteos como totales globales.

---

# Fase 6 — Analítica de la celda seleccionada

`conPunchExecutiveDetailSlot` no contiene gráficos. Incorporar:

```text
cmpHomePunchPriorityDonut
 galHomePunchDisciplineBars
```

La celda devuelve Punches abiertos; por eso un donut de status sería prácticamente monocolor. La propuesta funcional es:

```text
Donut: prioridad
Barras: disciplina
```

No calcular las distribuciones sobre `colPunchExecutiveGridFiltered` si la celda tiene más de una página. `usp_GetPunchDashboardCellDetailsPaged` debe compartir su base de selección con un endpoint que devuelva:

```json
{
  "priorityDistribution": [],
  "disciplineDistribution": []
}
```

La suma de ambas distribuciones debe coincidir con el total completo de la celda, no con las filas visibles.

---

# Fase 7 — Punch Review Workspace

## Decisión

Crear una pantalla dedicada:

```text
scr_PunchReview
```

No ampliar `cmp_DetailDrawer_old` como workspace principal. El drawer está acoplado a variables globales, mezcla Tasks y Punches, limita el ancho y no implementa historial.

## Estado común

```text
colPunchReviewQueue
colPunchReviewComments
colPunchReviewCustomFields
colPunchReviewHistory
varPunchReviewSource
varPunchReviewReturnScreen
varPunchReviewCurrentIndex
varPunchReviewCurrentId
varPunchReviewCurrent
varPunchReviewDirty
varPunchReviewIsLoading
varPunchReviewError
```

## MVP

- Abrir desde una fila de Home o Punches.
- Construir una cola con las filas cargadas.
- Previous/Next.
- Overview.
- Comments.
- Custom fields.
- Estado local `IsReviewedInSession`.
- Volver al origen.

La etiqueta visible debe decir **Reviewed in this session** hasta implementar SQL.

## Apertura desde Home

```powerfx
With(
    {
        _selected: LookUp(
            colHomePunchGridNormalized,
            RowKey = varHomePunchGridSelectedKey
        )
    },
    If(
        IsBlank(_selected.RowKey),
        Notify("Select a Punch before opening the review workspace.", NotificationType.Warning),
        ClearCollect(
            colPunchReviewQueue,
            AddColumns(
                colHomePunchGridNormalized,
                ReviewOrder,
                RowIndex,
                IsReviewedInSession,
                false
            )
        );
        Set(varPunchReviewSource, "HOME");
        Set(varPunchReviewReturnScreen, "HOME");
        Set(varPunchReviewCurrentIndex, Max(1, Coalesce(_selected.RowIndex, 1)));
        Set(varPunchReviewCurrentId, Value(_selected.RowKey));
        Set(varPunchReviewCurrent, LookUp(colPunchReviewQueue, RowKey = _selected.RowKey));
        Set(varPunchReviewDirty, false);
        Navigate(scr_PunchReview, ScreenTransition.Fade)
    )
)
```

## Carga de comentarios

Usar siempre:

```powerfx
Warroom_GetTaskCommentsPaged.Run(
    Value(varProjectId),
    Value(varPunchReviewCurrentId),
    1,
    20,
    "PUNCH"
)
```

## Carga de custom fields

```powerfx
WarRoom_GetCustomBundle.Run(
    Value(varProjectId),
    "PUNCH",
    Value(varPunchReviewCurrentId)
)
```

---

# Fase 8 — Drawer heredado

En `cmp_DetailDrawer_old.pa.yaml`, los botones siguiente y anterior cambian el orden de parámetros. Todas las llamadas deben usar:

```powerfx
Warroom_GetTaskCommentsPaged.Run(
    cmp_DetailDrawer_old.ProjectId,
    cmp_DetailDrawer_old.RecordId,
    varCommentsPage,
    varCommentsPageSize,
    cmp_DetailDrawer_old.EntityType
)
```

---

# Fase 9 — Persistencia y concurrencia

El esquema actual no contiene un estado de revisión de Punches. Añadir en una entrega separada:

```text
warroom.PunchReviewState
warroom.PunchReviewHistory
warroom.usp_PunchReview_Upsert
```

`PunchReviewState` debe incluir `ProjectId`, `PunchId`, `ReviewStatus`, revisor, fecha, nota y `RowVersion`. El SP debe comparar `@ExpectedRowVersion` antes de actualizar y registrar cada transición en History.

No ejecutar esta fase hasta validar autorización backend y relación con el origen real de Punches.

---

# Criterios de aceptación

- Punches abre con proyecto aunque falte configuración publicada.
- Header correcto a 1366, 1600 y 1920 px.
- Donut muestra anillo, total y leyenda.
- SmartBar existe y responde a búsqueda, quick filter, density y clear.
- Grid no contiene datos ficticios y ocupa el ancho del contenedor.
- Distribuciones de prioridad y disciplina representan el conjunto completo.
- Workspace abre desde Home y Punches y conserva la cola.
- Comentarios usan un único orden contractual.
- Custom fields cargan con `EntityType=PUNCH`.
- El estado local no se presenta como persistente.
- No se borran pantallas o componentes heredados.

La versión descargable entregada junto a esta documentación contiene fórmulas y SQL completos para cada fase.