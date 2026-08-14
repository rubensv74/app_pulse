# C17-E2A-FIX3 — Punch Review → Punch List: foco exacto y retorno

**Estado:** PENDIENTE DE VALIDACIÓN EN POWER APPS STUDIO  
**Tipo:** FIX funcional / contrato de navegación  
**Ámbito:** `scr_PunchReview` + `scr_Punches`  
**No tocar:** cola de Review, Session Activity, Dirty Guard fuera de `OPEN_PUNCHES`, filtros normales de Punch List, backend de paginación.

## 1. Problema confirmado

La navegación desde Punch Review ya alcanza `scr_Punches`, pero el identificador seleccionado (`varSelectedTaskId`) no es consumido por la vista de Punch List: `galPunches_3.Items` sigue mostrando `colPunches`. Además, `backPunchesBackToOperations_2.OnSelect` no contempla `varPunches_ReturnView = "PunchReview"`, por lo que cae en el fallback de Overview.

El Flow `Warroom_Punches_Filtered_Paged` no recibe `PunchId`, por lo que este FIX no intenta fabricar un filtro servidor inexistente. Se usa un contexto local de drill-through de una sola fila, independiente de `colPunches`, para no destruir la página/los filtros que el usuario tuviera antes.

## 2. Contrato funcional

Al ejecutar `OPEN_PUNCHES` desde Punch Review:

- `varPunches_FilterSource = "PunchReview"`.
- `varPunches_ReturnView = "PunchReview"`.
- `varPunches_FocusPunchId = varPunchReviewCurrentId`.
- `colPunchesReviewFocus` contiene únicamente el Punch actual con el esquema necesario para `galPunches_3` y el drawer.
- Punch List muestra esa colección en lugar de `colPunches`.
- Back desde Punch List vuelve explícitamente a `scr_PunchReview` y limpia únicamente el contexto temporal de foco.
- `colPunches` original queda intacta.

---

# CAMBIO A — Punch Review / acción `OPEN_PUNCHES`

## Target

`scr_PunchReview` → `cmpPR_Actions` → `OnAction` → rama `"OPEN_PUNCHES"`.

En la rama en la que **no hay cambios pendientes**, reemplazar el bloque actual que solo asigna `varPunches_ReturnView`, `varSelectedTaskId`, `varDrawerRecordId` y navega a Punches por este bloque:

```powerfx
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
```

---

# CAMBIO B — Dirty Guard / `OPEN_PUNCHES`

## Target

`scr_PunchReview` → `conPR_DirtyGuardLayer` → `btnPR_ContinuePendingAction` → `OnSelect` → rama `"OPEN_PUNCHES"`.

Después de limpiar `varPunchReviewPendingAction` y `varPunchReviewPendingIndex`, aplicar **el mismo contrato de foco** del CAMBIO A antes de navegar. La rama debe usar la misma construcción de `colPunchesReviewFocus`; no mantener una segunda semántica de navegación.

> Regla: las dos rutas —acción directa y continuación tras Dirty Guard— deben producir exactamente el mismo contexto de Punch List.

---

# CAMBIO C — Punch List / Items de la galería

## Target

`scr_Punches` → `galPunches_3` → `Items`.

Sustituir:

```powerfx
colPunches
```

por:

```powerfx
If(
    Upper(Coalesce(varPunches_FilterSource, "")) = "PUNCHREVIEW" &&
    CountRows(colPunchesReviewFocus) > 0,
    colPunchesReviewFocus,
    colPunches
)
```

Esto hace que el drill-through muestre **solo el Punch seleccionado** sin modificar `colPunches`.

---

# CAMBIO D — Punch List / botón Back

## Target

`scr_Punches` → `backPunchesBackToOperations_2` → `OnSelect`.

Añadir una rama explícita `"PunchReview"` al `Switch`, antes del fallback:

```powerfx
"PunchReview",
    Set(varPunches_FilterSource, "Manual");
    Set(varPunches_FocusPunchId, Blank());
    Clear(colPunchesReviewFocus);
    Set(varAppView, "PunchReview");
    Navigate(scr_PunchReview, ScreenTransition.None),
```

Conservar las ramas actuales `Home` y `Overview`.

**No usar `Back()`** para esta ruta. El retorno debe depender del contrato `varPunches_ReturnView`.

---

# CAMBIO E — App.OnStart

El refactor `APP-START-01` inicializa de forma tipada el contexto del drill-through:

- `varPunches_FilterSource`
- `varPunches_FocusPunchId`
- `colPunchesReviewFocus`

No es obligatorio ejecutar primero el refactor completo para probar este FIX si la colección se crea desde CAMBIO A, pero sí debe quedar incorporado cuando se aplique la versión organizada de `App.OnStart`.

---

## Validación mínima en Studio

1. Entrar en Punch Review desde Home o Punch List.
2. Seleccionar un Punch concreto, por ejemplo `MPL-000868`.
3. Ejecutar **Open Punch List**.
4. Confirmar que Punch List muestra **una sola fila** y que corresponde exactamente al Punch seleccionado.
5. Pulsar Back en Punch List.
6. Confirmar retorno a **Punch Review**, no a Overview.
7. Confirmar que el Punch actual, cola, reviewed state y Session Activity siguen intactos.
8. Entrar después en Punch List por una ruta normal y confirmar que vuelve a usar `colPunches` y sus filtros/paginación habituales.
9. Repetir el recorrido con Dirty Guard activo para verificar que la rama pendiente produce el mismo resultado.

## Criterio de cierre

Marcar C17-E2A-FIX3 como validado únicamente después de confirmar los nueve puntos anteriores en Power Apps Studio.
