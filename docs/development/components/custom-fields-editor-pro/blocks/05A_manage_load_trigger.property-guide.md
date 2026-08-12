# DF-05A — Manage → carga de definiciones para validación

**Tipo:** `I — Integration`  
**Artefacto:** guía de propiedades  
**Propósito:** conectar temporalmente la acción existente **Manage** de Punch Review con el nuevo servicio host de carga de definiciones, de modo que DF-05A pueda validarse antes de que DF-06 introduzca el modal real.

## Objetivo

`cmpPR_CustomFieldValues.OnManageFieldsRequested`

Ubicación:

`conPR_RightColumn → conPR_CustomFieldsHost → cmpPR_CustomFieldValues`

## Sustituir únicamente esta propiedad

Reemplaza la fórmula informativa actual de `OnManageFieldsRequested` por:

```powerfx
=Select(btnPR_LoadCustomFieldDefs);
If(
    IsBlank(varPunchReviewFieldDefsError),
    Notify(
        Text(CountRows(colPunchReviewFieldDefsAdmin)) &
        " Custom Field definitions loaded.",
        NotificationType.Success
    ),
    Notify(
        varPunchReviewFieldDefsError,
        NotificationType.Error
    )
)
```

## No modificar

- geometría del componente;
- definición de `cmp_CustomFieldValuesPro`;
- comportamiento actual de carga/guardado de valores Custom Field;
- Comments;
- Review Progress;
- Dirty Guard;
- propiedades de theme/color.

## Validación

1. Selecciona un proyecto real.
2. Abre un Punch en Punch Review.
3. Pulsa **Manage** dentro de Custom Fields.
4. Confirma que la notificación de éxito muestra el número de definiciones cargadas.
5. Si es necesario, inspecciona `colPunchReviewFieldDefsAdmin` y confirma que contiene definiciones activas e inactivas.
6. Confirma que `varPunchReviewFieldDefsError` queda vacío.
7. Confirma que no se produce ningún cambio de geometría visual.
8. Prueba también sin proyecto seleccionado: la acción debe mostrar el error del host en lugar de completar correctamente la llamada al Flow.

## Ciclo de vida

Este hook de notificación es deliberadamente temporal. DF-06 lo sustituirá por el ciclo real de apertura del modal, conservando `Select(btnPR_LoadCustomFieldDefs)` como servicio de lectura propiedad del host.
