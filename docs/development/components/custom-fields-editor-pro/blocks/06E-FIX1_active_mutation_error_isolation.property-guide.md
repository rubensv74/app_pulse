# DF-06E-FIX1 — Active mutation error isolation

**Componente host:** `scr_PunchReview`  
**Control:** `btnPR_SetCustomFieldActive`  
**Propiedad:** `OnSelect`  
**Tipo:** FIX funcional aislado  
**Estado:** READY FOR STUDIO VALIDATION

## Problema confirmado

El `OnSelect` actual mezcla dentro del mismo `IfError(...)` la mutación `WarRoom_SetCustomFieldActive.Run(...)` y el posterior refresco `Select(btnPR_RefreshCustomFieldDefinitionContext)`. Un fallo de refresco puede terminar presentándose como si hubiera fallado la activación/desactivación.

## Operación

En Studio, seleccionar:

`btnPR_SetCustomFieldActive → OnSelect`

**Reemplazar la fórmula completa** por esta versión. No pegar solo una parte.

```powerfx
=Set(varPunchReviewFieldDefToggleLoading, true);
Set(varPunchReviewFieldDefToggleError, "");
Set(varPunchReviewFieldDefsLastMutationSucceeded, false);
Set(varPunchReviewFieldDefsRefreshWarning, "");
Set(varPunchReviewFieldDefMutationCallSucceeded, false);

If(
    IsBlank(varProjectId),

    Set(
        varPunchReviewFieldDefToggleError,
        "No active project is available for changing Custom Field definition status."
    ),

    Lower(Coalesce(varUserRole, "reader")) <> "manager",

    Set(
        varPunchReviewFieldDefToggleError,
        "Your current role does not allow Custom Field definition management."
    ),

    IsBlank(Trim(Coalesce(varPunchReviewFieldDefToggleKey, ""))),

    Set(
        varPunchReviewFieldDefToggleError,
        "Field key is required for changing definition status."
    ),

    IsBlank(
        LookUp(
            colPunchReviewFieldDefsAdmin,
            Lower(Trim(FieldKey)) = Lower(Trim(varPunchReviewFieldDefToggleKey))
        )
    ),

    Set(
        varPunchReviewFieldDefToggleError,
        "The selected Custom Field definition is not present in the loaded catalog. Refresh definitions and try again."
    ),

    Coalesce(
        LookUp(
            colPunchReviewFieldDefsAdmin,
            Lower(Trim(FieldKey)) = Lower(Trim(varPunchReviewFieldDefToggleKey)),
            IsActive
        ),
        false
    ) = Coalesce(varPunchReviewFieldDefToggleActive, false),

    Notify(
        If(
            Coalesce(varPunchReviewFieldDefToggleActive, false),
            "Custom Field definition is already active.",
            "Custom Field definition is already inactive."
        ),
        NotificationType.Information
    ),

    IfError(
        With(
            {
                resp:
                    WarRoom_SetCustomFieldActive.Run(
                        varProjectId,
                        "PUNCH",
                        Trim(varPunchReviewFieldDefToggleKey),
                        Coalesce(varPunchReviewFieldDefToggleActive, false),
                        Lower(User().Email)
                    )
            },
            Set(varPunchReviewFieldDefMutationCallSucceeded, true)
        ),
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

## Qué cambia

La llamada al Flow queda aislada de la fase posterior de refresco:

```text
FLOW FAILS
→ varPunchReviewFieldDefToggleError
→ no refresh
→ no success notification

FLOW SUCCEEDS
→ local state update
→ mutation SUCCESS
→ refresh separado
→ refresh warning independiente
```

## Qué no cambia

- `WarRoom_SetCustomFieldActive.Run` y sus 5 parámetros;
- validación de proyecto;
- validación de rol Manager;
- validación de FieldKey;
- validación contra `colPunchReviewFieldDefsAdmin`;
- invalidación de filtros dinámicos;
- `btnPR_RefreshCustomFieldDefinitionContext.OnSelect`;
- `btnPR_LoadCustomFieldDefs`;
- `btnPR_LoadCustomFields`;
- `cmpPR_CustomFieldsEditor.OnActiveChangeRequested`;
- save/upsert DF-05/DF-06;
- geometría y tipografía.

## Validación mínima

1. Abrir Manage.
2. Elegir una definición Active real.
3. Cambiar Active → Inactive.
4. Confirmar que persiste tras Refresh.
5. Cambiar Inactive → Active.
6. Confirmar que persiste tras Refresh.
7. Si aparece Error, copiar literalmente el mensaje: ahora corresponde a la fase de mutación y no al refresh posterior.

### PASS

```text
DEACTIVATE              PASS
REACTIVATE              PASS
PERSIST AFTER REFRESH   PASS
FALSE MUTATION ERROR    0
STUDIO FORMULA ERRORS   0
```

Después del PASS continuar con `DF-07B-FIX1 — Readability floor`.