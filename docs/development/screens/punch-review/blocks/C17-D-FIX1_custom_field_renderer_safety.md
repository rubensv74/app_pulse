# C17-D-FIX1 — Custom Field renderer safety

**Estado:** PENDING STUDIO VALIDATION  
**Componente:** `cmp_CustomFieldValuesPro`  
**Fuente:** Source Code completo exportado desde Studio el 2026-08-13.

## 1. `galCFVPro_Values.OnSelect`

Target:

`cmp_CustomFieldValuesPro → conCFVPro_Root → conCFVPro_Body → galCFVPro_Values → OnSelect`

**Borrar completamente la fórmula actual.** La Gallery no debe restaurar `colCFVPro_Base`, vaciar `colCFVPro_Dirty` ni disparar `OnCancelRequested` al hacer click sobre su superficie.

La cancelación explícita permanece únicamente en `btnCFVPro_Cancel.OnSelect`.

## 2. `cmbCFVPro_Choice.DisplayMode`

Target:

`cmp_CustomFieldValuesPro → conCFVPro_Root → conCFVPro_Body → galCFVPro_Values → conCFVPro_ValueRow → cmbCFVPro_Choice → DisplayMode`

Aplicar:

```powerfx
=If(
    cmp_CustomFieldValuesPro.CanEdit &&
    ThisItem.IsEditable &&
    !cmp_CustomFieldValuesPro.IsLoading &&
    !cmp_CustomFieldValuesPro.IsSaving,
    DisplayMode.Edit,
    DisplayMode.View
)
```

Esta es la misma política usada por Text, Number, Date y YesNo.

## 3. `cmbCFVPro_Choice.IsSearchable`

Establecer:

```powerfx
=true
```

## No tocar

No modificar `Items`, `ItemDisplayText`, `DefaultSelectedItems`, `OnChange`, `SelectMultiple`, JSON MultiChoice, `colCFVPro_Base`, `colCFVPro_Working`, `colCFVPro_Dirty`, Save/Cancel host ni geometría C17.

## Validación mínima

1. Editar un valor y confirmar `Unsaved`.
2. Hacer click en espacio vacío de la Gallery: el cambio y `DirtyCount` deben permanecer.
3. Reader: Text/Number/Date/YesNo/Choice/MultiChoice deben estar en View.
4. Manager: Choice/MultiChoice deben ser editables.
5. Validar dirty add/revert, Save y Cancel.
6. Cero errores de Studio.

Cuando este gate pase, C17-D queda `FUNCTIONAL_FROZEN` y puede continuar C17-E final.