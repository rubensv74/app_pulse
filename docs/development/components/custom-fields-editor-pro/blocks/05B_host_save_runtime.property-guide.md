# DF-05B — Preparación del estado host para guardar definiciones

## Clasificación

`I — Integration`

## Propósito

Preparar en `scr_PunchReview` el estado tipado que utilizará el servicio host `btnPR_SaveCustomFieldDef` para persistir una definición mediante `WarRoom_UpsertCustomFieldDef`.

Este bloque **no modifica la geometría** de Punch Review ni el componente `cmp_CustomFieldsEditorPro`.

## Target

Pantalla:

`scr_PunchReview`

Propiedad:

`OnVisible`

## Dependencias

- DF-05A integrado y validado.
- `colPunchReviewFieldDefsAdmin` disponible.
- `btnPR_LoadCustomFieldDefs` existente.
- `btnPR_LoadCustomFields` existente.
- `varProjectId` existente.
- `varUserRole` existente.

## No modificar

- Review Queue.
- Comments.
- Custom Field Values.
- Review Progress.
- Dirty Guard.
- geometría de `conPR_RightColumn`.
- geometría o controles internos de `cmp_CustomFieldsEditorPro`.
- capa de color.

## Cambio

Añade al final de la inicialización de estado de `scr_PunchReview.OnVisible` el siguiente bloque:

```powerfx
// =====================================================
// DF-05B — CUSTOM FIELD DEFINITION HOST SAVE STATE
// =====================================================

If(IsBlank(varPunchReviewFieldDefsSaving), Set(varPunchReviewFieldDefsSaving, false));

// Draft host tipado. DF-06 copiará aquí los outputs de cmp_CustomFieldsEditorPro
// inmediatamente antes de ejecutar btnPR_SaveCustomFieldDef.
Set(varPunchReviewDef_FieldDefId, 0);
If(IsBlank(varPunchReviewDef_FieldKey), Set(varPunchReviewDef_FieldKey, ""));
If(IsBlank(varPunchReviewDef_Label), Set(varPunchReviewDef_Label, ""));
If(IsBlank(varPunchReviewDef_FieldType), Set(varPunchReviewDef_FieldType, "Text"));
If(IsBlank(varPunchReviewDef_HelpText), Set(varPunchReviewDef_HelpText, ""));
If(IsBlank(varPunchReviewDef_IsRequired), Set(varPunchReviewDef_IsRequired, false));
If(IsBlank(varPunchReviewDef_IsPinned), Set(varPunchReviewDef_IsPinned, true));
If(IsBlank(varPunchReviewDef_IsActive), Set(varPunchReviewDef_IsActive, true));
Set(varPunchReviewDef_SortOrder, 100);
If(IsBlank(varPunchReviewDef_OptionsJson), Set(varPunchReviewDef_OptionsJson, "[]"));
If(IsBlank(varPunchReviewDef_IsFilterable), Set(varPunchReviewDef_IsFilterable, false));
If(IsBlank(varPunchReviewDef_ShowInQuickFilters), Set(varPunchReviewDef_ShowInQuickFilters, false));
Set(varPunchReviewDef_FilterOrder, 100);
If(IsBlank(varPunchReviewDef_FilterMode), Set(varPunchReviewDef_FilterMode, "Equals"));
If(IsBlank(varPunchReviewDefDirty), Set(varPunchReviewDefDirty, false));
```

## Nota importante sobre tipos

`FieldDefId`, `SortOrder` y `FilterOrder` reciben una asignación numérica inequívoca. Esto aplica la regla preventiva del registro de compatibilidad de PULSE para evitar variables numéricas no reconocidas por Power Apps Studio.

## Qué hace DF-05B con estas variables

El host utilizará exactamente este contrato:

- `varPunchReviewDef_FieldDefId`
- `varPunchReviewDef_FieldKey`
- `varPunchReviewDef_Label`
- `varPunchReviewDef_FieldType`
- `varPunchReviewDef_HelpText`
- `varPunchReviewDef_IsRequired`
- `varPunchReviewDef_IsPinned`
- `varPunchReviewDef_IsActive`
- `varPunchReviewDef_SortOrder`
- `varPunchReviewDef_OptionsJson`
- `varPunchReviewDef_IsFilterable`
- `varPunchReviewDef_ShowInQuickFilters`
- `varPunchReviewDef_FilterOrder`
- `varPunchReviewDef_FilterMode`

DF-06 conectará estos valores con el draft interno de `cmp_CustomFieldsEditorPro`. DF-05B se limita a crear el servicio de persistencia host.

## Validación

1. Guardar `scr_PunchReview`.
2. Confirmar que Studio no muestra nombres no reconocidos para las variables anteriores.
3. Confirmar que `varPunchReviewDef_FieldDefId`, `varPunchReviewDef_SortOrder` y `varPunchReviewDef_FilterOrder` son numéricas.
4. Confirmar que no cambia ninguna zona visual de la pantalla.
5. Después integrar `05B_definition_upsert.add-child.pa.yaml`.

## Estado esperado

`HOST SAVE STATE = FUNCTIONAL_FROZEN`
