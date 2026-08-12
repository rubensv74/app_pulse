# DF-05D — Estado host para refresh posterior a mutación

## Clasificación

`I — Integration`

## Propósito

Cerrar la integración backend de Custom Field Definitions con un estado host mínimo que permita distinguir entre:

- mutación backend correcta;
- recarga posterior correcta;
- mutación correcta pero refresh posterior incompleto.

Este bloque no cambia geometría, componentes visuales ni color.

## Target

Pantalla: `scr_PunchReview`  
Propiedad: `OnVisible`

## Dependencias

- DF-05A integrado (`btnPR_LoadCustomFieldDefs`).
- DF-05B integrado (`btnPR_SaveCustomFieldDef`).
- DF-05C integrado (`btnPR_SetCustomFieldActive`).
- `btnPR_LoadCustomFields` existente.

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

Añade al final de la inicialización de `scr_PunchReview.OnVisible`:

```powerfx
// =====================================================
// DF-05D — CUSTOM FIELD DEFINITIONS POST-MUTATION REFRESH
// =====================================================

If(
    IsBlank(varPunchReviewFieldDefsRefreshWarning),
    Set(varPunchReviewFieldDefsRefreshWarning, "")
);

If(
    IsBlank(varPunchReviewFieldDefsLastMutationSucceeded),
    Set(varPunchReviewFieldDefsLastMutationSucceeded, false)
);
```

## Contrato

- `varPunchReviewFieldDefsRefreshWarning`: advertencia no bloqueante si la mutación se completó pero la recarga posterior no pudo reconstruir completamente el contexto local.
- `varPunchReviewFieldDefsLastMutationSucceeded`: indica que la última llamada de escritura al backend terminó correctamente; no significa por sí sola que el refresh posterior también haya terminado correctamente.

## Validación

1. Guardar `scr_PunchReview`.
2. Confirmar que Studio reconoce ambas variables sin errores.
3. Confirmar que `varPunchReviewFieldDefsLastMutationSucceeded` queda tipada como Boolean.
4. Confirmar que no cambia ninguna zona visual.
5. Integrar después `05D_post_mutation_refresh.add-child.pa.yaml`.

## Estado esperado

`POST-MUTATION STATE = FUNCTIONAL_FROZEN`
