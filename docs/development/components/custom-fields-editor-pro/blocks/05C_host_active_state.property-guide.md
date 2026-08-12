# DF-05C — Preparación del estado host Active / Inactive

## Clasificación

`I — Integration`

## Propósito

Preparar en `scr_PunchReview` el estado tipado que utilizará el servicio host `btnPR_SetCustomFieldActive` para activar o desactivar una definición mediante `WarRoom_SetCustomFieldActive`.

Este bloque no modifica geometría, componentes visuales ni la capa de color.

## Target

Pantalla:

`scr_PunchReview`

Propiedad:

`OnVisible`

## Dependencias

- DF-05A integrado: `btnPR_LoadCustomFieldDefs` disponible.
- DF-05B integrado: estado host `varPunchReviewDef_*` disponible.
- `varProjectId` y `varUserRole` existentes.
- `colPunchReviewFieldDefsAdmin` disponible.

## No modificar

- Review Queue.
- Comments.
- Custom Field Values.
- Review Progress.
- Dirty Guard.
- geometría de `conPR_RightColumn`.
- `cmp_CustomFieldsEditorPro`.
- capa de color.

## Cambio

Añade al final de la inicialización de estado de `scr_PunchReview.OnVisible`:

```powerfx
// =====================================================
// DF-05C — CUSTOM FIELD DEFINITION ACTIVE STATE
// =====================================================

If(IsBlank(varPunchReviewFieldDefToggleLoading), Set(varPunchReviewFieldDefToggleLoading, false));
If(IsBlank(varPunchReviewFieldDefToggleError), Set(varPunchReviewFieldDefToggleError, ""));
If(IsBlank(varPunchReviewFieldDefToggleKey), Set(varPunchReviewFieldDefToggleKey, ""));
If(IsBlank(varPunchReviewFieldDefToggleActive), Set(varPunchReviewFieldDefToggleActive, false));
```

## Contrato de estado

- `varPunchReviewFieldDefToggleKey`: `FieldKey` de la definición que debe cambiar de estado.
- `varPunchReviewFieldDefToggleActive`: estado objetivo (`true` = Active, `false` = Inactive).
- `varPunchReviewFieldDefToggleLoading`: indica que la mutación está en curso.
- `varPunchReviewFieldDefToggleError`: último error de la operación.

DF-06 copiará a estas variables la intención del usuario desde `cmp_CustomFieldsEditorPro` antes de ejecutar el servicio host.

## Validación

1. Guardar `scr_PunchReview`.
2. Confirmar que Studio reconoce las cuatro variables sin errores.
3. Confirmar que `varPunchReviewFieldDefToggleActive` queda tipada como Boolean.
4. Confirmar que no cambia ninguna zona visual.
5. Integrar después `05C_definition_active_toggle.add-child.pa.yaml`.

## Estado esperado

`HOST ACTIVE STATE = FUNCTIONAL_FROZEN`
