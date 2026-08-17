# PR-CONTEXT-ROLLBACK1 — Restaurar el estado anterior al FIX1 retractado

## Objetivo

El anterior `PR-CONTEXT-FIX1` se basó en una interpretación incorrecta de los identificadores de proyecto:

- `4049` es el **ProjectId interno** utilizado por SQL;
- `70200` es el **ProjectCode visible** que conoce el usuario.

Por tanto, las tres fórmulas aplicadas con FIX1 deben restaurarse al estado inmediatamente anterior.

## Regla de aplicación

En los tres casos:

> **REPLACE FORMULA COMPLETELY**

No insertes parches. Selecciona el control y la propiedad indicados, borra la fórmula actual completa y pega el bloque correspondiente.

Orden recomendado: A → B → C.

---

# ROLLBACK-A — `scr_Home` / `cmpHomePunchActionToolbar.OnAction`

Este es el bloque validado de entrada a Punch Review desde Home antes del FIX1.

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

---

# ROLLBACK-B — `scr_Punches` / `btnPunches_OpenPunchReview_2.OnSelect`

Este es el bloque validado de entrada desde Punch List antes del FIX1.

```powerfx
If(
    CountRows(colPunches) = 0,

    Notify(
        "Load a Punch page before starting Review Workspace.",
        NotificationType.Information
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
    Set(varPunchReviewTemplateId, varFilter_PunchTemplateId);
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
```

---

# ROLLBACK-C — `scr_Home` / `btnHome_ProjectChange_Commit_2.OnSelect`

Este bloque restaura el commit de cambio de proyecto existente antes de introducir la invalidación adicional del FIX1.

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

---

# Gate de restauración

Después de pegar A, B y C:

1. App Checker no debe mostrar nuevos errores.
2. Abrir Punch Review desde Home debe volver a funcionar como antes del FIX1.
3. Abrir Punch Review desde Punch List debe volver a funcionar como antes del FIX1.
4. No publiques todavía.
5. Después de confirmar este gate se repite PR-EXP-C03B1 con el identificador correcto: `ProjectId interno = 4049`, `ProjectCode visible = 70200`, `TemplateId = 20`.
