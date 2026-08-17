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

No se corrige el problema cambiando el ProjectId del export. La Review Queue debe ser coherente antes de existir.

---

# Cómo implementar este fix

Para evitar parches difíciles de ubicar, este documento contiene los **tres bloques completos**.

En los tres casos la operación es:

> **REPLACE FORMULA COMPLETELY**

No hay que insertar fragmentos dentro del código existente. Abre el control indicado, selecciona la propiedad indicada, elimina la fórmula completa actual y pega el bloque completo de este documento.

Implementar en este orden:

1. `FIX1-A` — entrada desde Home.
2. `FIX1-B` — entrada desde Punch List.
3. `FIX1-C` — invalidación completa al cambiar de proyecto.

---

# FIX1-A — Entrada desde Home

## Dónde pegarlo

- Screen: `scr_Home`
- Control: `cmpHomePunchActionToolbar`
- Property: `OnAction`
- Operation: **REPLACE FORMULA COMPLETELY**

## Código completo

```powerfx
Switch(
    Self.SelectedActionKey,

    "REVIEW",
        If(
            CountRows(colHomePunchGridView) = 0,

            Notify(
                "Load Punches in the Home grid before starting Review Workspace.",
                NotificationType.Information
            ),

            With(
                {
                    _useSelectedRows:
                        CountRows(colHomePunchGridSelectedKeys) > 0
                },

                With(
                    {
                        _seedRows:
                            If(
                                _useSelectedRows,
                                Filter(
                                    colHomePunchGridView As _gridRow,
                                    !IsBlank(
                                        LookUp(
                                            colHomePunchGridSelectedKeys,
                                            RowKey = Text(_gridRow.RowKey)
                                        )
                                    )
                                ),
                                colHomePunchGridView
                            )
                    },

                    If(
                        CountRows(_seedRows) = 0,

                        Notify(
                            "No loaded Home rows are available for review.",
                            NotificationType.Information
                        ),

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
                                                IsBlank(varProjectId) ||
                                                IsBlank(varPunchDashboardTemplateId) ||
                                                Value(_raw.ProjectId) <> Value(varProjectId) ||
                                                Value(_raw.TemplateId) <> Value(varPunchDashboardTemplateId)
                                            )
                                        )
                                    )
                            },

                            If(
                                _foreignContextRows > 0,

                                Clear(colPunchReviewQueue);
                                Clear(colPunchReviewQueueView);
                                Clear(colHomePunchGridSelectedKeys);
                                Set(varHomePunchGridSelectedKey, "");
                                Set(varHomePunchGridAllMatchingSelected, false);

                                Notify(
                                    "The loaded Punch grid belongs to a previous project or template. Refresh the Punch dashboard before starting Review Workspace.",
                                    NotificationType.Warning
                                ),

                                ClearCollect(
                                    colPunchReviewQueue,

                                    ForAll(
                                        Sequence(CountRows(_seedRows)) As _position,

                                        With(
                                            {
                                                _gridRow:
                                                    Last(
                                                        FirstN(
                                                            _seedRows,
                                                            _position.Value
                                                        )
                                                    )
                                            },

                                            With(
                                                {
                                                    _raw:
                                                        LookUp(
                                                            colPunchExecutiveGridFiltered,
                                                            Text(PunchId) = Text(_gridRow.RowKey)
                                                        )
                                                },

                                                {
                                                    ReviewOrder: _position.Value,
                                                    RowKey: Text(_raw.PunchId),
                                                    PunchIdNumber: Value(_raw.PunchId),
                                                    PunchCode:
                                                        Coalesce(
                                                            Text(_raw.PunchCode),
                                                            Text(_raw.PunchId)
                                                        ),
                                                    Description:
                                                        Coalesce(
                                                            Text(_raw.PunchDescription),
                                                            ""
                                                        ),
                                                    AreaCode: "",
                                                    UnitCode: "",
                                                    SystemCode: "",
                                                    SubsystemCode:
                                                        Coalesce(
                                                            Text(_raw.SubsystemCode),
                                                            ""
                                                        ),
                                                    ElementCode: "",
                                                    Discipline:
                                                        Coalesce(
                                                            Text(_raw.DisciplineName),
                                                            Text(_raw.DisciplineCode),
                                                            ""
                                                        ),
                                                    Category:
                                                        Coalesce(
                                                            Text(_raw.CategoryCode),
                                                            Text(_raw.CategoryName),
                                                            ""
                                                        ),
                                                    StatusCode:
                                                        Coalesce(
                                                            Text(_raw.StatusCode),
                                                            "OPEN"
                                                        ),
                                                    StatusLabel:
                                                        Coalesce(
                                                            Text(_raw.StatusName),
                                                            Text(_raw.PunchStatus),
                                                            Text(_raw.StatusCode),
                                                            "OPEN"
                                                        ),
                                                    ResponsibleParty:
                                                        Coalesce(
                                                            Text(_raw.ResponsibleCompany),
                                                            Text(_raw.ResponsiblePerson),
                                                            ""
                                                        ),
                                                    InspectionName:
                                                        Coalesce(
                                                            Text(_raw.InspectionName),
                                                            ""
                                                        ),
                                                    Originator:
                                                        Coalesce(
                                                            Text(_raw.Originator),
                                                            ""
                                                        ),
                                                    CommentCount: 0,
                                                    LastCommentOn: Blank(),
                                                    IsReviewedInSession: false,
                                                    IsDirty: false
                                                }
                                            )
                                        )
                                    )
                                );

                                Clear(colPunchReviewQueueView);
                                Clear(colPunchReviewComments);
                                Clear(colPunchReviewFieldsUI);
                                Clear(colPunchReviewFieldsBase);
                                Clear(colPunchReviewFieldsDirty);
                                Clear(colPunchReviewSessionEvents);

                                Set(varPunchReviewSearch, "");
                                Set(varPunchReviewQuickFilter, "ALL");
                                Set(varPunchReviewSource, "HOME");
                                Set(varPunchReviewReturnScreen, "HOME");
                                Set(
                                    varPunchReviewQueueScope,
                                    If(
                                        _useSelectedRows,
                                        "SELECTED",
                                        "HOME_CONTEXT"
                                    )
                                );
                                Set(
                                    varPunchReviewTemplateId,
                                    varPunchDashboardTemplateId
                                );
                                Set(varPunchReviewDirty, false);
                                Set(varPunchReviewIsLoading, false);
                                Set(varPunchReviewError, "");
                                Set(varPunchReviewCommentsPage, 1);
                                Set(varPunchReviewCommentsError, "");
                                Set(varPunchReviewFieldsError, "");
                                Set(varPunchReviewShowDirtyDialog, false);
                                Set(varPunchReviewPendingAction, "");
                                Set(varPunchReviewPendingIndex, 0);

                                Set(
                                    varPunchReviewCurrentIndex,
                                    Coalesce(
                                        LookUp(
                                            colPunchReviewQueue,
                                            RowKey = Text(varHomePunchGridSelectedKey),
                                            ReviewOrder
                                        ),
                                        1
                                    )
                                );

                                Set(
                                    varPunchReviewRequestedIndex,
                                    varPunchReviewCurrentIndex
                                );

                                Set(
                                    varPunchReviewCurrent,
                                    LookUp(
                                        colPunchReviewQueue,
                                        ReviewOrder = varPunchReviewCurrentIndex
                                    )
                                );

                                Set(
                                    varPunchReviewCurrentId,
                                    varPunchReviewCurrent.PunchIdNumber
                                );

                                Set(varAppView, "PunchReview");

                                Navigate(
                                    scr_PunchReview,
                                    ScreenTransition.None
                                )
                            )
                        )
                    )
                )
            )
        ),

    "OPEN_PUNCHES",
        Select(
            btnPunchExecutiveOpenInPunchList
        ),

    "REFRESH",
        Select(btnPunchExecutiveLoadCellDetails),

    "EXPORT",
        Select(btnPunchExecutiveGridExport),

    "COMMENTS",
        If(
            IsBlank(varHomePunchGridSelectedKey),
            Notify(
                "Select a Punch first.",
                NotificationType.Warning
            ),
            Notify(
                "The selected Punch will open in the review workspace.",
                NotificationType.Information
            )
        ),

    "COLUMNS",
        Notify(
            "Use the grid gear while the column selector remains inside DataTableProV2.",
            NotificationType.Information
        ),

    "DENSITY",
        Set(
            varHomePunchGridDensity,
            Switch(
                Lower(varHomePunchGridDensity),
                "compact", "Comfortable",
                "comfortable", "Spacious",
                "Compact"
            )
        ),

    "SELECT_VISIBLE",
        ClearCollect(
            colHomePunchGridSelectedKeys,
            ForAll(
                colHomePunchGridView,
                {
                    RowKey: Text(RowKey)
                }
            )
        ),

    "CLEAR_FILTERS",
        Set(
            varHomePunchSelectedDisciplineCode,
            ""
        );

        Set(
            varPunchDrillDisciplineCode,
            ""
        );

        Set(
            varPunchExecutiveGridPage,
            1
        );

        Set(
            varPunchExecutiveGridSelectedId,
            Blank()
        );

        Set(
            varHomePunchGridSelectedKey,
            ""
        );

        Clear(
            colHomePunchGridSelectedKeys
        );

        Set(
            varHomePunchGridAllMatchingSelected,
            false
        );

        Set(
            varPunchExecutiveGridLoading,
            true
        );

        Set(
            varPunchExecutiveGridError,
            ""
        );

        Set(
            varPunchExecutiveGridMessage,
            "Loading all disciplines for the selected cell..."
        );

        Set(
            varPunchExecutiveGridLoadPending,
            false
        );

        Set(
            varPunchExecutiveGridLoadPending,
            true
        ),

    "MORE",
        Notify(
            "Additional actions will be added here.",
            NotificationType.Information
        )
)
```

## Qué cambia

Antes de crear la Review Queue se comprueba cada fila contra:

- `varProjectId`;
- `varPunchDashboardTemplateId`.

Si una sola fila pertenece a otro contexto, no se navega a Punch Review y la selección obsoleta se elimina.

---

# FIX1-B — Entrada desde Punch List

## Dónde pegarlo

- Screen: `scr_Punches`
- Control: `btnPunches_OpenPunchReview_2`
- Property: `OnSelect`
- Operation: **REPLACE FORMULA COMPLETELY**

## Código completo

```powerfx
If(
    CountRows(colPunches) = 0,

    Notify(
        "Load a Punch page before starting Review Workspace.",
        NotificationType.Information
    ),

    With(
        {
            _queueTemplateId:
                If(
                    !IsBlank(varFilter_PunchTemplateId),
                    Value(varFilter_PunchTemplateId),
                    If(
                        CountRows(
                            Filter(
                                colPunches,
                                Value(TemplateId) <> Value(First(colPunches).TemplateId)
                            )
                        ) = 0,
                        Value(First(colPunches).TemplateId),
                        Blank()
                    )
                )
        },

        With(
            {
                _foreignContextRows:
                    CountRows(
                        Filter(
                            colPunches,
                            IsBlank(ProjectId) ||
                            IsBlank(TemplateId) ||
                            IsBlank(varProjectId) ||
                            IsBlank(_queueTemplateId) ||
                            Value(ProjectId) <> Value(varProjectId) ||
                            Value(TemplateId) <> Value(_queueTemplateId)
                        )
                    )
            },

            If(
                _foreignContextRows > 0,

                Clear(colPunchReviewQueue);
                Clear(colPunchReviewQueueView);

                Notify(
                    "The loaded Punch page belongs to a previous project or template, or contains more than one template. Reload Punch List before starting Review Workspace.",
                    NotificationType.Warning
                ),

                ClearCollect(
                    colPunchReviewQueue,
                    ForAll(
                        Sequence(CountRows(colPunches)),
                        With(
                            {
                                prOrder: Value,
                                p: Last(FirstN(colPunches, Value))
                            },
                            {
                                ReviewOrder: prOrder,
                                RowKey: Text(p.PunchId),
                                PunchIdNumber: Value(p.PunchId),
                                PunchCode: Coalesce(Text(p.PunchCode), Text(p.PunchId)),
                                Description: Coalesce(Text(p.PunchDescription), ""),
                                AreaCode: Coalesce(Text(p.AreaCode), ""),
                                UnitCode: Coalesce(Text(p.UnitCode), ""),
                                SystemCode: Coalesce(Text(p.SystemCode), ""),
                                SubsystemCode: Coalesce(Text(p.SubsystemCode), ""),
                                ElementCode: Coalesce(Text(p.ElementCode), ""),
                                Discipline: Coalesce(Text(p.PunchDiscipline), ""),
                                Category: Coalesce(Text(p.CategoryCode), Text(p.Category), ""),
                                StatusCode: Coalesce(Text(p.StatusCode), ""),
                                StatusLabel: Coalesce(Text(p.PunchStatus), Text(p.StatusCode), ""),
                                ResponsibleParty:
                                    Coalesce(
                                        Text(p.SubcontractorName),
                                        Text(p.PunchCoordinator),
                                        ""
                                    ),
                                InspectionName: Coalesce(Text(p.InspectionName), ""),
                                Originator: Coalesce(Text(p.Originator), ""),
                                CommentCount: Coalesce(Value(p.CommentCount), 0),
                                LastCommentOn: p.LastCommentOn,
                                IsReviewedInSession: false,
                                IsDirty: false
                            }
                        )
                    )
                );

                Clear(colPunchReviewQueueView);
                Clear(colPunchReviewComments);
                Clear(colPunchReviewFieldsUI);
                Clear(colPunchReviewFieldsBase);
                Clear(colPunchReviewFieldsDirty);
                Clear(colPunchReviewSessionEvents);

                Set(varPunchReviewSearch, "");
                Set(varPunchReviewQuickFilter, "ALL");
                Set(varPunchReviewSource, "PUNCHES");
                Set(varPunchReviewReturnScreen, "PUNCHES");
                Set(varPunchReviewQueueScope, "CURRENT_PAGE");
                Set(varPunchReviewTemplateId, _queueTemplateId);
                Set(varPunchReviewDirty, false);
                Set(varPunchReviewIsLoading, false);
                Set(varPunchReviewError, "");
                Set(varPunchReviewCommentsPage, 1);
                Set(varPunchReviewCommentsError, "");
                Set(varPunchReviewFieldsError, "");
                Set(varPunchReviewShowDirtyDialog, false);
                Set(varPunchReviewPendingAction, "");
                Set(varPunchReviewPendingIndex, 0);

                Set(
                    varPunchReviewCurrentIndex,
                    Coalesce(
                        LookUp(
                            colPunchReviewQueue,
                            PunchIdNumber = varSelectedTaskId,
                            ReviewOrder
                        ),
                        1
                    )
                );

                Set(
                    varPunchReviewRequestedIndex,
                    varPunchReviewCurrentIndex
                );

                Set(
                    varPunchReviewCurrent,
                    LookUp(
                        colPunchReviewQueue,
                        ReviewOrder = varPunchReviewCurrentIndex
                    )
                );

                Set(
                    varPunchReviewCurrentId,
                    varPunchReviewCurrent.PunchIdNumber
                );

                Set(varAppView, "PunchReview");

                Navigate(
                    scr_PunchReview,
                    ScreenTransition.None
                )
            )
        )
    )
)
```

## Qué cambia

La entrada desde Punch List comprueba ahora dos cosas antes de crear la cola:

1. todas las filas pertenecen al `varProjectId` activo;
2. todas las filas pertenecen a un único Template.

Si existe `varFilter_PunchTemplateId`, ese es el template obligatorio. Si no existe un filtro de template pero toda la página pertenece al mismo template, ese template se adopta automáticamente para la sesión de Punch Review.

Si la página mezcla templates, la navegación se bloquea.

---

# FIX1-C — Cambio de proyecto

## Dónde pegarlo

- Screen: `scr_Home`
- Control: `btnHome_ProjectChange_Commit_2`
- Property: `OnSelect`
- Operation: **REPLACE FORMULA COMPLETELY**

## Código completo

```powerfx
If(
    IsBlank(varPendingProjectId),

    Notify(
        "No pending project selected.",
        NotificationType.Warning
    );

    Set(varProjectSwitching, false);
    Set(varHomeLoading, false);
    Set(varPunchDashboardLoading, false);

    Set(varGlobalLoading, false);
    Set(varGlobalLoadingMsg, "");
    Set(varGlobalLoadingSubMsg, "");
    Set(varGlobalLoadingScope, "");
    Set(varGlobalLoadAction, "");
    Set(varGlobalLoadPending, false)
);


// Preserve the dashboard selected by the user.
Set(
    varHomeDashboardTarget,
    If(
        varHomeDashboard in ["PUNCHES", "TASKS"],
        varHomeDashboard,
        "PUNCHES"
    )
);


// Resolve project.
Set(
    varSelectedProject,
    LookUp(
        colEnabledProjectsUI,
        Value(ProjectId) = Value(varPendingProjectId)
    )
);


If(
    IsBlank(varSelectedProject) ||
    IsBlank(varSelectedProject.ProjectId),

    Notify(
        "Selected project was not found in the enabled projects list.",
        NotificationType.Error
    );

    Set(varProjectLoaded, false);
    Set(varProjectId, Blank());
    Set(varPendingProjectId, Blank());

    Set(varProjectSwitching, false);
    Set(varHomeLoading, false);
    Set(varPunchDashboardLoading, false);

    Set(varGlobalLoading, false);
    Set(varGlobalLoadingMsg, "");
    Set(varGlobalLoadingSubMsg, "");
    Set(varGlobalLoadingScope, "");
    Set(varGlobalLoadAction, "");
    Set(varGlobalLoadPending, false)
);


// =====================================================
// PROJECT CONTEXT
// =====================================================

Set(
    varProjectId,
    Value(varSelectedProject.ProjectId)
);

Set(
    varProjectCode,
    Text(varSelectedProject.ProjectCode)
);

Set(
    varProjectName,
    Text(varSelectedProject.ProjectName)
);

Set(
    varProjectDescription,
    Text(varSelectedProject.ProjectDescription)
);

Set(varProjectLoaded, true);
Set(varPendingProjectId, Blank());


// =====================================================
// NAVIGATION
// =====================================================

Set(varAppView, "Home");
Set(varPageKey, "HOME");
Set(varPageTitle, "Home");
Set(varPageSubtitle, "Project command center");
Set(varHomeViewMode, "DASHBOARD");

Set(
    varHomeDashboard,
    varHomeDashboardTarget
);


// =====================================================
// ERROR RESET
// =====================================================

Set(varAppError, "");
Set(varAppWarning, "");
Set(varHomeError, "");
Set(varOps_Error, "");
Set(varCfg_Error, "");
Set(varHomePendingError, "");

Set(varExecutiveDashboardError, "");
Set(varExecutiveDashboardStatus, "LOADING");
Set(varExecutiveDashboardRequestedAt, Now());
Set(varExecutiveAlertDismissed, false);


// =====================================================
// HOME / TASK DASHBOARD RESET
// =====================================================

Set(varProjectHasHomeData, false);
Set(varProjectHasReportConfig, false);
Set(varHomeHiveLoaded, false);
Set(varHomeNoData, false);

Set(varHomeShowOverview, false);
Set(varHomeShowCards, false);
Set(varHomeShowRightPanel, false);

Set(
    varSelectedHiveNode,
    {
        NodeId: "",
        NodeNo: "",
        NodeTitle: "",
        NodeSubtitle: "",
        Discipline: "",
        SubsystemCode: "",
        Total: 0,
        Done: 0,
        Remaining: 0,
        Progress: 0,
        ProgressStatus: "",
        ProgressColor: "",
        SortOrder: 0
    }
);

Set(
    varSelectedHiveSubsystem,
    {
        SubsystemCode: "",
        Discipline: "",
        Total: 0,
        Done: 0,
        Remaining: 0,
        Progress: 0,
        ProgressStatus: "",
        ProgressColor: ""
    }
);

Clear(colHomeHiveNodes);
Clear(colHomeHiveNodesSorted);
Clear(colHomeLowestProgress);
Clear(colHomePendingSubsystems);
Clear(colHomePendingSubsystems_Staging);


// =====================================================
// DEPENDENT SCREEN COLLECTIONS
// =====================================================

Clear(colTasks);
Clear(colTasks_Staging);
Clear(colPunches);
Clear(colPunches_Staging);


// =====================================================
// PUNCH DASHBOARD RESET
// =====================================================

Set(varPunchDashboardTemplateId, Blank());
Set(varPunchDashboardLoaded, false);
Set(varPunchDashboardLoading, false);
Set(varPunchDashboardError, "");
Set(varPunchDashboardMessage, "");
Set(varPunchDashboardHasSnapshot, false);
Set(varPunchDashboardSnapshotId, Blank());
Set(varPunchDashboardLastRefresh, Blank());

Set(varPunchDrillStatusCode, "");
Set(varPunchDrillCategoryCode, "");
Set(varPunchDrillSubsystemCode, "");
Set(varPunchDrillSubcontractorId, -1);
Set(varPunchDrillSubcontractorName, "");
Set(varPunchDrillDisciplineCode, "");

Set(varPunchExecutiveGridPage, 1);
Set(varPunchExecutiveGridSelectedId, Blank());
Set(varPunchExecutiveGridTotalRows, 0);
Set(varPunchExecutiveGridTotalPages, 0);
Set(varPunchExecutiveGridHasPreviousPage, false);
Set(varPunchExecutiveGridHasNextPage, false);
Set(varPunchExecutiveGridLoading, false);
Set(varPunchExecutiveGridError, "");
Set(varPunchExecutiveGridMessage, "");
Set(varPunchExecutiveGridLoadPending, false);

Set(varHomePunchGridSelectedKey, "");
Set(varHomePunchGridAllMatchingSelected, false);
Set(varHomePunchSelectedDisciplineCode, "");

Clear(colPunchDashboardSnapshotInfo);
Clear(colPunchDashboardSummary);
Clear(colPunchDashboardMatrix);
Clear(colPunchDashboardTimeline);
Clear(colPunchDashboardInsights);
Clear(colPunchDashboardSubsystems);
Clear(colPunchDashboardSubcontractors);
Clear(colPunchDashboardPunches);

Clear(colPunchExecutiveHeatmapRows);
Clear(colPunchExecutiveHeatmapColumns);
Clear(colPunchExecutiveHeatmapCells);
Clear(colPunchExecutiveDistribution);
Clear(colPunchExecutiveSelection);
Clear(colPunchExecutiveGridFiltered);
Clear(colPunchExecutiveDisciplineDistribution);
Clear(colPunchExecutiveDonutItems);

Clear(colHomePunchGridNormalized);
Clear(colHomePunchGridView);
Clear(colHomePunchGridSelectedKeys);


// =====================================================
// PUNCH REVIEW SESSION RESET
// Critical: a Review Queue can never survive a project change.
// =====================================================

Clear(colPunchReviewQueue);
Clear(colPunchReviewQueueView);
Clear(colPunchReviewComments);
Clear(colPunchReviewFieldsUI);
Clear(colPunchReviewFieldsBase);
Clear(colPunchReviewFieldsDirty);
Clear(colPunchReviewSessionEvents);

Set(varPunchReviewTemplateId, Blank());
Set(varPunchReviewCurrentId, Blank());
Set(varPunchReviewCurrent, Blank());
Set(varPunchReviewCurrentIndex, 1);
Set(varPunchReviewRequestedIndex, Blank());
Set(varPunchReviewSearch, "");
Set(varPunchReviewQuickFilter, "ALL");
Set(varPunchReviewDirty, false);
Set(varPunchReviewShowDirtyDialog, false);
Set(varPunchReviewPendingAction, "");
Set(varPunchReviewPendingIndex, 0);
Set(varPunchReviewSource, "NAVIGATION");
Set(varPunchReviewReturnScreen, "HOME");
Set(varPunchReviewQueueScope, "NAVIGATION");

Set(varPRExportOpen, false);
Set(varPRExportScopeValid, false);
Set(varPRExportWorkItemIdsJson, "[]");
Set(varPRExportQueueCount, 0);


// =====================================================
// PUNCH FILTER CATALOG RESET
// =====================================================

Set(varPunchCatalogs_ProjectId, Blank());

Clear(colPunchSubsystems_Filter);
Clear(colPunchTemplates_Filter);
Clear(colPunchCategories_Filter);
Clear(colPunchStatuses_Filter);
Clear(colPunchDisciplines_Filter);
Clear(colPunchSubcontractors_Filter);

Set(varPunchesLoaded, false);
Set(varPunches_HasSearched, false);
Set(varPunches_Page, 1);
Set(varPunches_TotalPages, 0);
Set(varPunches_TotalRows, 0);


// =====================================================
// SCHEDULE THE ACTIVE DASHBOARD
// =====================================================

Set(varProjectSwitching, true);
Set(varHomeLoading, false);
Set(varPunchDashboardLoading, false);

Set(varGlobalLoading, true);

Set(
    varGlobalLoadingMsg,
    If(
        varHomeDashboardTarget = "PUNCHES",
        "Loading Punch Dashboard...",
        "Loading Tasks Dashboard..."
    )
);

Set(
    varGlobalLoadingSubMsg,
    If(
        varHomeDashboardTarget = "PUNCHES",
        "Loading selected project punch analytics",
        "Loading selected project task overview"
    )
);

Set(varGlobalLoadingScope, "HOME");

Set(
    varGlobalLoadAction,
    If(
        varHomeDashboardTarget = "PUNCHES",
        "LOAD_PUNCH_DASHBOARD",
        "LOAD_TASK_DASHBOARD"
    )
);

Set(varGlobalLoadPending, false);
Set(varGlobalLoadPending, true)
```

## Qué cambia

Este tercer bloque es la defensa estructural. Cuando se confirma un proyecto nuevo:

- se elimina el drilldown Punch del proyecto anterior;
- se elimina la selección y paginación anterior;
- se eliminan los modelos visuales derivados de ese drilldown;
- se elimina cualquier `colPunchReviewQueue` anterior;
- se eliminan Comments, Custom Fields y Session Events de la sesión anterior;
- se invalida cualquier payload de Export ya preparado.

De este modo, incluso aunque el usuario navegue directamente a Punch Review después de cambiar de proyecto, no existe una cola anterior que pueda reutilizarse accidentalmente.

---

# Gate de validación

## Prueba 1 — reproducción del defecto original

1. Seleccionar Project `4049`.
2. Cargar un drilldown de Punches en Home.
3. Confirmar que aparecen Punches de 4049.
4. Cambiar el proyecto activo a `70200`.
5. Después del cambio, comprobar que el grid/drilldown anterior ha desaparecido.
6. Intentar abrir Punch Review sin cargar nuevos Punches.
7. Resultado esperado: no debe reaparecer la Review Queue de 4049.

## Prueba 2 — nueva sesión válida

1. Con Project `70200` activo, cargar el Punch Dashboard y un drilldown válido.
2. Pulsar `Review`.
3. Punch Review debe abrir con filas que pertenezcan exclusivamente a 70200 y al template activo.
4. Abrir `Export`.
5. C03A debe serializar únicamente esa nueva Review Queue.

## Prueba 3 — Punch List

1. Abrir Punch List con un proyecto activo.
2. Cargar una página.
3. Pulsar `Review page`.
4. Si todas las filas pertenecen al proyecto y a un único template, Punch Review debe abrir normalmente.
5. Si el contexto no es coherente, debe aparecer el warning y no debe navegar.

---

# Impacto en PR-EXP-C03

PR-EXP-C03B1 permanece **bloqueado** hasta validar este fix.

No se debe modificar todavía:

- `warroom.usp_ExportProjectPunchesExtended_Pivoted`;
- Power Automate;
- `Generate Excel`.

El validador SQL `warroom.usp_ValidatePunchReviewExportScope` se considera correcto: detectó y bloqueó una Review Queue incoherente en vez de producir una exportación incorrecta.

Una vez superado este gate, se repetirá C03B1 usando el ProjectId, TemplateId y los WorkItemIds de la nueva sesión válida.