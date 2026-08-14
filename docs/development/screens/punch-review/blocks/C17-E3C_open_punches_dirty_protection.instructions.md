# C17-E3C — OPEN_PUNCHES Dirty Protection

## Objetivo
Evitar que `Open Punch List` pueda abandonar `scr_PunchReview` con Custom Fields sin guardar y mantener exactamente el modo actual de foco de un solo Punch en `scr_Punches`.

> `C17-E3B` no requiere cambios: el router actual ya tiene rutas explícitas para `CHANGE_CURRENT`, `BACK` y `OPEN_PUNCHES`, y su rama por defecto no navega.

---

# CAMBIO 1 — `cmpPR_Actions.OnAction`

## Ubicación
`scr_PunchReview` → `cmpPR_Actions` → `OnAction`

## Operación
**No tocar** las ramas actuales `MARK_REVIEWED` y `UNMARK_REVIEWED`.

Después de `UNMARK_REVIEWED`, el código actual cae directamente en el bloque que comienza por:

```powerfx
Set(varPunches_FilterSource, "PunchReview");
```

Ese bloque está actuando como `default` del `Switch`.

**Sustituir desde esa línea hasta el cierre final del `Switch` por el bloque siguiente:**

```powerfx
"OPEN_PUNCHES",

    If(
        IsBlank(varPunchReviewCurrentId),

        Notify(
            "Select a Punch before opening the Punch List.",
            NotificationType.Information
        ),

        If(
            varPunchReviewDirty,

            Set(varPunchReviewPendingAction, "OPEN_PUNCHES");
            Set(varPunchReviewPendingIndex, 0);
            Set(varPunchReviewShowDirtyDialog, true),

            Set(varPunches_FilterSource, "PunchReview");
            Set(varPunches_ReturnView, "PunchReview");
            Set(varPunches_FocusPunchId, varPunchReviewCurrentId);
            Set(varSelectedTaskId, varPunchReviewCurrentId);
            Set(varDrawerRecordId, varPunchReviewCurrentId);

            ClearCollect(
                colPunchesReviewFocus,
                With(
                    {p: varPunchReviewCurrent},
                    {
                        AreaCode: Coalesce(Text(p.AreaCode), ""),
                        UnitCode: Coalesce(Text(p.UnitCode), ""),
                        SystemCode: Coalesce(Text(p.SystemCode), ""),
                        SubsystemCode: Coalesce(Text(p.SubsystemCode), ""),
                        ElementCode: Coalesce(Text(p.ElementCode), ""),
                        ElementDiscipline: Coalesce(Text(p.Discipline), ""),
                        TypeCode: "",

                        ProjectId: varProjectId,
                        TemplateId: varPunchReviewTemplateId,

                        PunchId: Value(p.PunchIdNumber),
                        PunchCode: Coalesce(Text(p.PunchCode), Text(p.PunchIdNumber)),
                        PunchDescription: Coalesce(Text(p.Description), ""),

                        PunchCoordinator: "",
                        Originator: Coalesce(Text(p.Originator), ""),

                        CategoryCode: Coalesce(Text(p.Category), ""),
                        Category: Coalesce(Text(p.Category), ""),

                        PunchDiscipline: Coalesce(Text(p.Discipline), ""),
                        StatusCode: Coalesce(Text(p.StatusCode), ""),
                        PunchStatus: Coalesce(Text(p.StatusLabel), Text(p.StatusCode), ""),

                        InspectionCode: "",
                        InspectionName: Coalesce(Text(p.InspectionName), ""),
                        InspectionType: "",

                        EntryType: "",
                        EntryTypeColor: "",
                        Topic: "",
                        RejectCount: 0,
                        ElementCodeMapped: "",

                        SubcontractorId: Blank(),
                        SubcontractorCode: "",
                        SubcontractorName: Coalesce(Text(p.ResponsibleParty), ""),
                        SubcontractorShortName: "",
                        DepartmentAction: "",

                        CustomJson: "{}",
                        CustomFlag1: false,
                        CustomFlag2: false,
                        CustomText1: "",
                        CustomText2: "",
                        CustomDate1: Blank(),
                        CustomNumber1: Blank(),
                        CustomLastUpdatedByEmail: "",
                        CustomLastUpdatedOn: Blank(),

                        LastCommentOn: p.LastCommentOn,
                        LastCommentText: "",
                        LastCommentByEmail: "",
                        CommentCount: Coalesce(Value(p.CommentCount), 0),

                        TotalRows: 1,
                        TotalPages: 1,
                        PageNumber: 1,
                        PageSize: 1
                    }
                )
            );

            Set(varPunches_Page, 1);
            Set(varPunches_TotalRows, 1);
            Set(varPunches_TotalPages, 1);
            Set(varPunchesLoaded, true);
            Set(varPunches_HasSearched, true);
            Set(varAppView, "Punches");
            Navigate(scr_Punches, ScreenTransition.None)
        )
    ),

    Notify(
        "Unsupported Punch Review action: " &
        Coalesce(cmpPR_Actions.SelectedActionKey, "-"),
        NotificationType.Warning
    )
)
```

### Resultado esperado
- Estado limpio → abre Punch List en modo `PunchReview`, mostrando únicamente el Punch actual.
- Estado dirty → no navega; abre `conPR_DirtyGuardLayer`.
- Una acción desconocida ya no puede navegar accidentalmente a Punch List.

---

# CAMBIO 2 — `btnPR_ContinuePendingAction.OnSelect`

## Ubicación
`scr_PunchReview` → `conPR_DirtyGuardLayer` → `btnPR_ContinuePendingAction` → `OnSelect`

## Operación
Localizar únicamente la rama actual:

```powerfx
"OPEN_PUNCHES",
```

que actualmente termina navegando directamente a `scr_Punches` sin construir `colPunchesReviewFocus`.

**Sustituir solo esa rama por esta versión:**

```powerfx
"OPEN_PUNCHES",
    Set(varPunchReviewPendingAction, "");
    Set(varPunchReviewPendingIndex, 0);

    Set(varPunches_FilterSource, "PunchReview");
    Set(varPunches_ReturnView, "PunchReview");
    Set(varPunches_FocusPunchId, varPunchReviewCurrentId);
    Set(varSelectedTaskId, varPunchReviewCurrentId);
    Set(varDrawerRecordId, varPunchReviewCurrentId);

    ClearCollect(
        colPunchesReviewFocus,
        With(
            {p: varPunchReviewCurrent},
            {
                AreaCode: Coalesce(Text(p.AreaCode), ""),
                UnitCode: Coalesce(Text(p.UnitCode), ""),
                SystemCode: Coalesce(Text(p.SystemCode), ""),
                SubsystemCode: Coalesce(Text(p.SubsystemCode), ""),
                ElementCode: Coalesce(Text(p.ElementCode), ""),
                ElementDiscipline: Coalesce(Text(p.Discipline), ""),
                TypeCode: "",

                ProjectId: varProjectId,
                TemplateId: varPunchReviewTemplateId,

                PunchId: Value(p.PunchIdNumber),
                PunchCode: Coalesce(Text(p.PunchCode), Text(p.PunchIdNumber)),
                PunchDescription: Coalesce(Text(p.Description), ""),

                PunchCoordinator: "",
                Originator: Coalesce(Text(p.Originator), ""),

                CategoryCode: Coalesce(Text(p.Category), ""),
                Category: Coalesce(Text(p.Category), ""),

                PunchDiscipline: Coalesce(Text(p.Discipline), ""),
                StatusCode: Coalesce(Text(p.StatusCode), ""),
                PunchStatus: Coalesce(Text(p.StatusLabel), Text(p.StatusCode), ""),

                InspectionCode: "",
                InspectionName: Coalesce(Text(p.InspectionName), ""),
                InspectionType: "",

                EntryType: "",
                EntryTypeColor: "",
                Topic: "",
                RejectCount: 0,
                ElementCodeMapped: "",

                SubcontractorId: Blank(),
                SubcontractorCode: "",
                SubcontractorName: Coalesce(Text(p.ResponsibleParty), ""),
                SubcontractorShortName: "",
                DepartmentAction: "",

                CustomJson: "{}",
                CustomFlag1: false,
                CustomFlag2: false,
                CustomText1: "",
                CustomText2: "",
                CustomDate1: Blank(),
                CustomNumber1: Blank(),
                CustomLastUpdatedByEmail: "",
                CustomLastUpdatedOn: Blank(),

                LastCommentOn: p.LastCommentOn,
                LastCommentText: "",
                LastCommentByEmail: "",
                CommentCount: Coalesce(Value(p.CommentCount), 0),

                TotalRows: 1,
                TotalPages: 1,
                PageNumber: 1,
                PageSize: 1
            }
        )
    );

    Set(varPunches_Page, 1);
    Set(varPunches_TotalRows, 1);
    Set(varPunches_TotalPages, 1);
    Set(varPunchesLoaded, true);
    Set(varPunches_HasSearched, true);
    Set(varAppView, "Punches");
    Navigate(scr_Punches, ScreenTransition.None),
```

**No modificar** las ramas `CHANGE_CURRENT`, `BACK` ni el `default` del router.

---

# Validación mínima C17-E3C

1. **Clean → Open Punch List**
   - Abre `scr_Punches`.
   - Muestra el Punch actual en modo Review focus.
   - Back vuelve a la misma sesión de Punch Review.

2. **Dirty → Open Punch List → Cancel**
   - Aparece el modal de cambios sin guardar.
   - No navega.
   - Los cambios locales permanecen intactos.

3. **Dirty → Open Punch List → Discard and continue**
   - Descarta cambios.
   - Abre Punch List centrado en el Punch actual.
   - Back vuelve a Punch Review conservando posición de sesión.

4. **Dirty → Open Punch List → Save and continue**
   - Guarda mediante el servicio real existente.
   - Solo si el guardado termina correctamente abre Punch List.
   - Punch List queda en el mismo modo Review focus.

5. **Regresión**
   - Next / Previous siguen funcionando.
   - Mark Reviewed / Undo Review siguen funcionando.
   - Back sigue utilizando su ruta actual.
