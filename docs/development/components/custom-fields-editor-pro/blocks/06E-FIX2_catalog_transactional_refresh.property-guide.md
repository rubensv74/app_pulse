# DF-06E-FIX2 — Catálogo transaccional + autorrecuperación antes de Active/Inactive

**Pantalla host:** `scr_PunchReview`  
**Controles:** `btnPR_LoadCustomFieldDefs`, `btnPR_SetCustomFieldActive`  
**Estado:** READY FOR STUDIO VALIDATION  
**Tipo:** FIX funcional aislado

## Diagnóstico confirmado

El error visible:

> The selected Custom Field definition is not present in the loaded catalog. Refresh definitions and try again.

se produce **antes** de llamar a `WarRoom_SetCustomFieldActive.Run(...)`.

La pantalla actual tiene dos comportamientos que juntos explican el fallo:

1. `btnPR_LoadCustomFieldDefs.OnSelect` ejecuta `Clear(colPunchReviewFieldDefsAdmin)` **antes** de llamar al servicio.
2. `btnPR_SetCustomFieldActive.OnSelect` bloquea la mutación si el `FieldKey` no está en `colPunchReviewFieldDefsAdmin`.

Si un refresh posterior a una mutación falla o devuelve una respuesta no parseable, el último catálogo bueno se pierde. El componente puede conservar su borrador/selección local, pero el host ya no tiene la definición y la siguiente petición Active/Inactive queda bloqueada.

## Objetivo

- no destruir el último catálogo válido antes de haber cargado uno nuevo;
- reintentar automáticamente la carga si la definición solicitada no está en el host;
- solo declarar `definition not present` después de un refresh válido;
- mantener intacto el Flow `WarRoom_SetCustomFieldActive` y su contrato.

---

# A. `btnPR_LoadCustomFieldDefs.OnSelect` — REEMPLAZAR COMPLETAMENTE

```powerfx
=Set(varPunchReviewFieldDefsLoading, true);
Set(varPunchReviewFieldDefsError, "");
Clear(colPunchReviewFieldDefsAdminNext);

If(
    IsBlank(varProjectId),

    Set(
        varPunchReviewFieldDefsError,
        "No active project is available for loading Custom Field definitions."
    ),

    IfError(
        With(
            {
                resp:
                    WarRoom_ListCustomFieldDefs.Run(
                        varProjectId,
                        "PUNCH",
                        1
                    )
            },
            With(
                {
                    outer:
                        Table(
                            ParseJSON(
                                Coalesce(
                                    resp.result,
                                    "[]"
                                )
                            )
                        )
                },
                If(
                    CountRows(outer) = 0,

                    Set(
                        varPunchReviewFieldDefsError,
                        "The definition service returned no data."
                    ),

                    With(
                        {
                            bundle:
                                ParseJSON(
                                    Text(
                                        First(outer).Value.result
                                    )
                                )
                        },

                        ClearCollect(
                            colPunchReviewFieldDefsAdminNext,
                            ForAll(
                                Table(bundle.defs),
                                With(
                                    {r: ThisRecord.Value},
                                    {
                                        FieldDefId:
                                            If(
                                                IsBlank(Text(r.FieldDefId)) ||
                                                Text(r.FieldDefId) = "null",
                                                0,
                                                Value(Text(r.FieldDefId))
                                            ),
                                        ProjectId:
                                            If(
                                                IsBlank(Text(r.ProjectId)) ||
                                                Text(r.ProjectId) = "null",
                                                Value(varProjectId),
                                                Value(Text(r.ProjectId))
                                            ),
                                        EntityType:
                                            Coalesce(Text(r.EntityType), "PUNCH"),
                                        FieldKey:
                                            Coalesce(Text(r.FieldKey), ""),
                                        Label:
                                            Coalesce(Text(r.Label), Text(r.FieldKey), ""),
                                        FieldType:
                                            Coalesce(Text(r.FieldType), "Text"),
                                        HelpText:
                                            Coalesce(Text(r.HelpText), ""),
                                        IsRequired:
                                            Boolean(r.IsRequired),
                                        IsPinned:
                                            Boolean(r.IsPinned),
                                        IsActive:
                                            Boolean(r.IsActive),
                                        SortOrder:
                                            If(
                                                IsBlank(Text(r.SortOrder)) ||
                                                Text(r.SortOrder) = "null",
                                                1000,
                                                Value(Text(r.SortOrder))
                                            ),
                                        OptionsJson:
                                            Coalesce(Text(r.OptionsJson), "[]"),
                                        IsFilterable:
                                            Boolean(r.IsFilterable),
                                        ShowInQuickFilters:
                                            Boolean(r.ShowInQuickFilters),
                                        FilterOrder:
                                            If(
                                                IsBlank(Text(r.FilterOrder)) ||
                                                Text(r.FilterOrder) = "null",
                                                If(
                                                    IsBlank(Text(r.SortOrder)) ||
                                                    Text(r.SortOrder) = "null",
                                                    1000,
                                                    Value(Text(r.SortOrder))
                                                ),
                                                Value(Text(r.FilterOrder))
                                            ),
                                        FilterMode:
                                            Coalesce(Text(r.FilterMode), "Equals")
                                    }
                                )
                            )
                        );

                        ClearCollect(
                            colPunchReviewFieldDefsAdmin,
                            colPunchReviewFieldDefsAdminNext
                        )
                    )
                )
            )
        ),

        Set(
            varPunchReviewFieldDefsError,
            Coalesce(
                FirstError.Message,
                "Custom Field definitions could not be loaded."
            )
        )
    )
);

Clear(colPunchReviewFieldDefsAdminNext);
Set(varPunchReviewFieldDefsLoading, false)
```

## Resultado de A

Si el servicio o el parseo falla, `colPunchReviewFieldDefsAdmin` conserva el último catálogo válido.

---

# B. `btnPR_SetCustomFieldActive.OnSelect` — REEMPLAZAR COMPLETAMENTE

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

    With(
        {
            requestedKey:
                Lower(Trim(varPunchReviewFieldDefToggleKey))
        },

        If(
            IsBlank(
                LookUp(
                    colPunchReviewFieldDefsAdmin,
                    Lower(Trim(FieldKey)) = requestedKey
                )
            ),
            Select(btnPR_LoadCustomFieldDefs)
        );

        If(
            !IsBlank(varPunchReviewFieldDefsError),

            Set(
                varPunchReviewFieldDefToggleError,
                "The Custom Field catalog could not be refreshed: " &
                varPunchReviewFieldDefsError
            ),

            IsBlank(
                LookUp(
                    colPunchReviewFieldDefsAdmin,
                    Lower(Trim(FieldKey)) = requestedKey
                )
            ),

            Set(
                varPunchReviewFieldDefToggleError,
                "The selected Custom Field definition is not present in the loaded catalog after refresh."
            ),

            Coalesce(
                LookUp(
                    colPunchReviewFieldDefsAdmin,
                    Lower(Trim(FieldKey)) = requestedKey,
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
                    Lower(Trim(Coalesce(varPunchReviewDef_FieldKey, ""))) = requestedKey,
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

---

# Validación

1. Abrir Manage y pulsar `Refresh` una vez.
2. Confirmar que el catálogo vuelve a mostrar definiciones.
3. Seleccionar `Impact Score`.
4. Active → Inactive.
5. Confirmar persistencia después del refresh automático.
6. Inactive → Active.
7. Confirmar persistencia.
8. Simular un refresh fallido si es posible: el último catálogo bueno no debe desaparecer.

## PASS

```text
CATALOG PRESERVED ON LOAD ERROR   PASS
AUTO-RECOVERY IF KEY MISSING      PASS
DEACTIVATE                         PASS
REACTIVATE                         PASS
PERSIST AFTER REFRESH              PASS
FALSE "NOT PRESENT" ERROR         0
STUDIO FORMULA ERRORS              0
```

No continuar con DF-07B-FIX1 hasta cerrar este gate.