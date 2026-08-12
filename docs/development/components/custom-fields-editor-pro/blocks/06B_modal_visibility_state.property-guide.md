# DF-06B — Estado de visibilidad del modal de Custom Fields

## Clasificación

`S/I — Structural / Integration`

## Propósito único

Crear el estado host mínimo que permite mostrar u ocultar la capa modal de `cmp_CustomFieldsEditorPro` sin modificar la geometría ya congelada de Punch Review.

Este bloque **no abre todavía el modal desde Manage**. DF-06C realizará ese wiring.

## Target

Pantalla:

`scr_PunchReview`

Propiedad:

`OnVisible`

## Dependencias

- DF-06A validado en Studio.
- `cmp_CustomFieldsEditorPro` presente realmente en la app activa.
- DF-05A/B/C/D integrados.

## No modificar

- Review Queue.
- Punch Overview.
- Session Activity.
- Comments.
- Custom Field Values.
- Review Progress.
- Dirty Guard.
- Help modal.
- geometría de `conPR_RightColumn`.
- capa cromática global.

## Cambio

Añade al final de `scr_PunchReview.OnVisible`:

```powerfx
// =====================================================
// DF-06B — CUSTOM FIELD DEFINITIONS MODAL STATE
// =====================================================
Set(varPunchReviewFieldDefsModalVisible, false);
```

## Motivo

La asignación directa garantiza que Power Apps tipa `varPunchReviewFieldDefsModalVisible` inequívocamente como Boolean y que Punch Review siempre entra con el editor de definiciones cerrado.

No se inicializan más variables en DF-06B.

## Validación

1. Guarda `scr_PunchReview`.
2. Confirma que Studio reconoce `varPunchReviewFieldDefsModalVisible` sin errores.
3. Confirma que su valor inicial es `false`.
4. No debe producirse ningún cambio visual mientras no se añada la capa modal.

## Estado esperado

`MODAL VISIBILITY STATE = FUNCTIONAL_FROZEN`
