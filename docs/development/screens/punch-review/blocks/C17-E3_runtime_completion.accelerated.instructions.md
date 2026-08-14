# C17-E3 — Runtime Completion (accelerated execution package)

**Modo de ejecución:** acelerado / un único gate funcional  
**Pantalla principal:** `scr_PunchReview`  
**Estado de entrada:** C17-E3A ya forma parte de la secuencia; C17-E3B fue auditado y no requiere cambios; C17-E3C queda absorbido en este paquete y **no se valida de forma aislada**.

## Objetivo

Cerrar de una sola vez el runtime de sesión relacionado con:

- hidratación inicial del Punch ya incorporada por C17-E3A;
- apertura de Punch List desde Punch Review;
- preservación del foco del Punch actual;
- protección de cambios Custom Fields sin guardar;
- retorno a la misma sesión de Punch Review;
- regresión de Next / Previous / Mark Reviewed / Undo Review.

## Regla de ejecución acelerada

1. Aplicar los **2 cambios** de este archivo.
2. Guardar la app.
3. Si Power Apps no introduce errores de fórmula nuevos, **no hacer una validación intermedia**.
4. Ejecutar directamente el **Gate único C17-E3** al final.
5. Solo abrir un FIX separado si aparece un defecto bloqueante o una regresión reproducible.

---

# CAMBIO 1 — `cmpPR_Actions.OnAction`

## Ubicación

`scr_PunchReview` → `cmpPR_Actions` → `OnAction`

## Operación

No modificar las ramas actuales `MARK_REVIEWED` y `UNMARK_REVIEWED`.

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

### Resultado de este cambio

- Clean → abre Punch List en modo `PunchReview` y mantiene foco de un único Punch.
- Dirty → no navega y abre `conPR_DirtyGuardLayer`.
- Una acción desconocida ya no puede caer accidentalmente en navegación a Punch List.

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

# GATE ÚNICO C17-E3

No validar los cambios uno por uno. Ejecutar esta secuencia completa una sola vez.

## A. Nueva sesión

1. Entrar desde Home a Punch Review.
2. Confirmar que el primer Punch carga Comments + Custom Fields automáticamente.
3. Confirmar que no aparece Dirty Guard al entrar.

## B. Clean → Punch List → Back

1. Sin modificar Custom Fields, pulsar `Open Punch List`.
2. Debe abrir `scr_Punches` mostrando únicamente el Punch actual en review focus.
3. Back debe volver a la misma sesión y al mismo Punch.
4. El retorno no debe disparar una nueva hidratación destructiva.

## C. Dirty → Cancel

1. Modificar un Custom Field sin guardar.
2. Pulsar `Open Punch List`.
3. Debe aparecer Dirty Guard y no navegar.
4. Pulsar Cancel.
5. El valor local editado debe seguir intacto.

## D. Dirty → Discard and continue

1. Volver a solicitar `Open Punch List` con cambios dirty.
2. Elegir descartar y continuar.
3. Debe abrir Punch List centrado en el Punch actual.
4. Back debe volver a Punch Review conservando posición de sesión.

## E. Dirty → Save and continue

1. Modificar otro Custom Field.
2. Solicitar `Open Punch List`.
3. Elegir guardar y continuar.
4. Solo después de un guardado correcto debe abrir Punch List.
5. Back debe volver a la misma sesión y el valor guardado debe mantenerse.

## F. Regresión funcional

En Punch Review confirmar sin salir del mismo gate:

- Next funciona.
- Previous funciona.
- Mark Reviewed funciona.
- Undo Review funciona.
- Back continúa usando su ruta vigente.
- Comments siguen cargando al cambiar de Punch.
- Custom Fields siguen cargando al cambiar de Punch.
- No aparecen errores de fórmula nuevos.

---

# Criterio de cierre

C17-E3 se considera **PASS** únicamente si A–F son correctos.

Si el gate pasa, no crear `E3C-FIX`, `E3D` ni microbloques adicionales: continuar directamente con el siguiente incremento funcional.

## Trazabilidad

Este paquete consolida y sustituye como unidad de ejecución a:

- `C17-E3A_initial_punch_hydration.instructions.md` — ya incorporado en la secuencia y validado dentro de este gate.
- `C17-E3B` — auditoría sin cambios.
- `C17-E3C_open_punches_dirty_protection.instructions.md` — código pendiente absorbido íntegramente aquí.

El archivo E3C original se conserva únicamente como evidencia histórica del análisis previo.
