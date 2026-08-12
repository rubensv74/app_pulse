# DF-05D — Wiring de refresh posterior a Save y Active/Inactive

## Clasificación

`I — Integration`

## Propósito

Hacer que los servicios DF-05B y DF-05C utilicen un único servicio de refresh posterior a mutación:

`btnPR_RefreshCustomFieldDefinitionContext`

La finalidad es evitar lógica duplicada y distinguir correctamente entre:

- escritura backend correcta;
- refresh posterior correcto;
- escritura correcta con advertencia de refresh.

## Dependencias

Antes de aplicar esta guía deben existir:

- `btnPR_LoadCustomFieldDefs`;
- `btnPR_SaveCustomFieldDef`;
- `btnPR_SetCustomFieldActive`;
- `btnPR_RefreshCustomFieldDefinitionContext`;
- `varPunchReviewFieldDefsRefreshWarning`;
- `varPunchReviewFieldDefsLastMutationSucceeded`.

## No modificar

- geometría de Punch Review;
- `cmp_CustomFieldsEditorPro`;
- Comments;
- Review Progress;
- Dirty Guard;
- color / Design System.

---

# A. `btnPR_SaveCustomFieldDef.OnSelect`

## A1. Inicialización al principio

Después de:

```powerfx
Set(varPunchReviewFieldDefsSaving, true);
Set(varPunchReviewFieldDefsError, "");
```

añade:

```powerfx
Set(varPunchReviewFieldDefsLastMutationSucceeded, false);
Set(varPunchReviewFieldDefsRefreshWarning, "");
```

## A2. Sustituir únicamente el bloque posterior a `WarRoom_UpsertCustomFieldDef.Run(...)`

Dentro del `With(...)` de éxito, elimina este comportamiento anterior:

```text
Select(btnPR_LoadCustomFieldDefs)
+ reload current Punch fields
+ Set(varPunchDynamicFilters_NeedRefresh, true)
+ success notification
```

Y usa este bloque:

```powerfx
Set(varPunchReviewFieldDefsLastMutationSucceeded, true);
Select(btnPR_RefreshCustomFieldDefinitionContext);
Set(varPunchReviewDefDirty, false);

Notify(
    "Custom Field definition saved successfully.",
    NotificationType.Success
);

If(
    !IsBlank(varPunchReviewFieldDefsRefreshWarning),
    Notify(
        varPunchReviewFieldDefsRefreshWarning,
        NotificationType.Warning
    )
)
```

### Resultado

El Upsert sigue siendo responsabilidad de DF-05B, pero toda sincronización posterior queda centralizada en DF-05D.

---

# B. `btnPR_SetCustomFieldActive.OnSelect`

## B1. Inicialización al principio

Después de:

```powerfx
Set(varPunchReviewFieldDefToggleLoading, true);
Set(varPunchReviewFieldDefToggleError, "");
```

añade:

```powerfx
Set(varPunchReviewFieldDefsLastMutationSucceeded, false);
Set(varPunchReviewFieldDefsRefreshWarning, "");
```

## B2. Sustituir la sincronización posterior a `WarRoom_SetCustomFieldActive.Run(...)`

Dentro del `With(...)` de éxito, conserva la actualización local de `varPunchReviewDef_IsActive` cuando el draft actual corresponde al mismo `FieldKey`.

Después de esa actualización, elimina las llamadas directas duplicadas a:

```text
Set(varPunchDynamicFilters_NeedRefresh, true)
Select(btnPR_LoadCustomFieldDefs)
Select(btnPR_LoadCustomFields)
```

Y usa:

```powerfx
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
```

---

# C. Punch List — no modificar

No añadas ningún cambio a `scr_Punches` en DF-05D.

La pantalla Punch List ya consume `varPunchDynamicFilters_NeedRefresh` cuando el usuario abre `Project filters`:

```text
si NeedRefresh=true
→ btnPunches_LoadDynamicFilters_2
→ NeedRefresh=false
```

Por tanto, DF-05D solo debe dejar la bandera en `true` tras una mutación correcta. Punch List ya posee el mecanismo de consumo.

---

# Validación mínima

## Save / Upsert

1. Ejecutar una modificación válida.
2. `varPunchReviewFieldDefsLastMutationSucceeded = true`.
3. `colPunchReviewFieldDefsAdmin` refleja el valor servidor.
4. El Punch actual recarga sus Custom Fields si existe selección.
5. `varPunchDynamicFilters_NeedRefresh = true`.
6. Si todo refresca correctamente, `varPunchReviewFieldDefsRefreshWarning` queda vacío.

## Active / Inactive

1. Desactivar una definición.
2. Confirmar backend + recarga autoritativa.
3. Reactivarla.
4. Confirmar backend + recarga autoritativa.
5. En ambos casos `varPunchDynamicFilters_NeedRefresh = true`.

## Regreso a Punch List

1. Volver a Punch List.
2. Abrir `Project filters`.
3. Confirmar que se ejecuta la recarga de filtros dinámicos.
4. Confirmar que `varPunchDynamicFilters_NeedRefresh` vuelve a `false`.

## Estado esperado

`DF-05 POST-MUTATION CONSISTENCY = FUNCTIONAL_FROZEN`
