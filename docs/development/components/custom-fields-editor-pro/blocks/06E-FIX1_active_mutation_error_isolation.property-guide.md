# DF-06E-FIX1 — Active mutation error isolation

**Componente host:** `scr_PunchReview`  
**Control:** `btnPR_SetCustomFieldActive`  
**Propiedad:** `OnSelect`  
**Tipo:** FIX funcional aislado  
**Estado:** READY FOR STUDIO VALIDATION

## Problema confirmado

El `OnSelect` actual de `btnPR_SetCustomFieldActive` ejecuta dentro del mismo `IfError(...)`:

1. `WarRoom_SetCustomFieldActive.Run(...)`;
2. actualización de variables locales;
3. `Select(btnPR_RefreshCustomFieldDefinitionContext)`;
4. notificación de éxito;
5. comprobación de `varPunchReviewFieldDefsRefreshWarning`.

Esto mezcla **mutación** y **refresco posterior** dentro del mismo bloque de error. Si el refresh del catálogo o de los valores del Punch falla después de una mutación válida, el error puede terminar mostrándose como si hubiera fallado la activación/desactivación.

## Objetivo

Separar inequívocamente:

- **Mutation error** → `varPunchReviewFieldDefToggleError` + `NotificationType.Error`;
- **Refresh error después de mutation correcta** → `varPunchReviewFieldDefsRefreshWarning` + `NotificationType.Warning`.

No se cambia la firma del Flow ni los parámetros existentes.

---

## Operación

En `btnPR_SetCustomFieldActive.OnSelect` conservar intactas todas las validaciones iniciales existentes:

- `varProjectId`;
- role manager;
- FieldKey obligatorio;
- definición presente en `colPunchReviewFieldDefsAdmin`;
- estado actual distinto del target.

Sustituir únicamente el bloque final actual que comienza en el `IfError(` que envuelve `WarRoom_SetCustomFieldActive.Run(...)` por el siguiente patrón.

```powerfx
Set(varPunchReviewFieldDefMutationCallSucceeded, false);

IfError(
    WarRoom_SetCustomFieldActive.Run(
        varProjectId,
        "PUNCH",
        Trim(varPunchReviewFieldDefToggleKey),
        Coalesce(varPunchReviewFieldDefToggleActive, false),
        Lower(User().Email)
    );
    Set(varPunchReviewFieldDefMutationCallSucceeded, true),

    Set(
        varPunchReviewFieldDefToggleError,
        Coalesce(
            FirstError.Message,
            "Custom Field definition status could not be changed."
        )
    )
);

If(
    varPunchReviewFieldDefMutationCallSucceeded,

    Set(varPunchDynamicFilters_NeedRefresh, true);

    If(
        Lower(Trim(Coalesce(varPunchReviewDef_FieldKey, ""))) =
        Lower(Trim(varPunchReviewFieldDefToggleKey)),
        Set(
            varPunchReviewDef_IsActive,
            Coalesce(varPunchReviewFieldDefToggleActive, false)
        )
    );

    Set(varPunchReviewFieldDefsLastMutationSucceeded, true);

    Select(btnPR_RefreshCustomFieldDefinitionContext);

    Notify(
        If(
            Coalesce(varPunchReviewFieldDefToggleActive, false),
            "Custom Field definition activated successfully.",
            "Custom Field definition deactivated successfully."
        ),
        NotificationType.Success
    );

    If(
        !IsBlank(varPunchReviewFieldDefsRefreshWarning),
        Notify(
            varPunchReviewFieldDefsRefreshWarning,
            NotificationType.Warning
        )
    )
);

Set(varPunchReviewFieldDefToggleLoading, false);

If(
    !IsBlank(varPunchReviewFieldDefToggleError),
    Notify(
        varPunchReviewFieldDefToggleError,
        NotificationType.Error
    )
)
```

## Importante

`Select(btnPR_RefreshCustomFieldDefinitionContext)` queda **fuera** del `IfError` que protege la llamada al Flow.

De esta forma:

```text
FLOW FAILS
→ Error real de mutation
→ no refresh
→ no success notification

FLOW SUCCEEDS + REFRESH FAILS
→ mutation sigue marcada SUCCESS
→ success notification
→ refresh warning independiente
```

## No tocar

- `WarRoom_SetCustomFieldActive.Run` ni sus 5 parámetros;
- `btnPR_RefreshCustomFieldDefinitionContext.OnSelect`;
- `btnPR_LoadCustomFieldDefs`;
- `btnPR_LoadCustomFields`;
- `cmpPR_CustomFieldsEditor.OnActiveChangeRequested`;
- DF-05/DF-06 save/upsert;
- dynamic filter invalidation;
- modal geometry;
- typography en este FIX.

## Validación mínima en Studio

### Test A — Deactivate

1. Abrir Manage.
2. Seleccionar una definición Active real.
3. Cambiar `Active` → OFF.
4. Confirmar que no aparece error genérico falso.
5. Confirmar que el editor refleja `Inactive`.
6. Cerrar/reabrir o Refresh y confirmar persistencia.

### Test B — Reactivate

1. Activar la misma definición.
2. Confirmar `Active` después del refresh.
3. Confirmar que Custom Fields del Punch vuelve a reflejarla cuando corresponda.

### Test C — Diagnóstico

Si vuelve a fallar:

- copiar el texto exacto del `NotificationType.Error`;
- no modificar todavía el Flow;
- ese mensaje será considerado el error real de `WarRoom_SetCustomFieldActive.Run(...)`.

### PASS

```text
DEACTIVATE              PASS
REACTIVATE               PASS
PERSIST AFTER REFRESH    PASS
FALSE MUTATION ERROR     0
STUDIO FORMULA ERRORS    0
```

Solo después de este PASS continuar con `DF-07B-FIX1 — Readability floor`.