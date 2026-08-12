# DF-06C — Guía de implementación y validación

## Objetivo

Hacer operativo el modal de administración de Custom Fields creado en DF-06B mediante tres acciones host:

`Manage → Open`

`Close`

`Refresh`

DF-06C no conecta todavía el guardado real ni Active/Inactive.

## Clasificación

`I — Integration`

## Dependencias

- DF-06A aplicado;
- DF-06B insertado;
- `cmp_CustomFieldsEditorPro` presente en la app activa;
- servicios DF-05 presentes;
- `btnPR_LoadCustomFieldDefs` reconocido por Studio.

## Orden exacto

### Paso 1 — Manage

Selecciona:

`conPR_RightColumn → conPR_CustomFieldsHost → cmpPR_CustomFieldValues`

Abre `OnManageFieldsRequested` y sustituye la fórmula por la indicada en:

`06C_open_close_refresh.property-guide.md`

Guarda antes de continuar.

### Paso 2 — Close

Selecciona:

`scr_PunchReview → conPR_CustomFieldsEditorModalLayer → cmpPR_CustomFieldsEditor`

Abre la propiedad personalizada `OnClose` y aplica la fórmula indicada en la guía.

Guarda.

### Paso 3 — Refresh

En la misma instancia `cmpPR_CustomFieldsEditor`, abre `OnRefresh` y aplica la fórmula indicada.

Guarda.

## Resultado funcional esperado

### Apertura

Al pulsar **Manage** con proyecto y permiso manager:

1. `varPunchReviewFieldDefsModalVisible=true`;
2. aparece el backdrop;
3. aparece `cmpPR_CustomFieldsEditor`;
4. se ejecuta `btnPR_LoadCustomFieldDefs`;
5. el catálogo utiliza `colPunchReviewFieldDefsAdmin`.

### Cierre

- draft limpio → Close cierra;
- draft modificado → Close muestra warning y no cierra.

### Refresh

- draft limpio → recarga el catálogo desde backend;
- draft modificado → warning y no recarga.

## Qué no debes hacer

- no añadas un Flow al componente;
- no cambies `Definitions`;
- no sustituyas la instancia modal;
- no toques `btnPR_SaveCustomFieldDef`;
- no conectes todavía `OnSaveRequested`;
- no modifiques Active/Inactive;
- no cambies dimensiones o posiciones del modal;
- no aproveches este bloque para ajustar colores.

## Prueba recomendada

Usa un proyecto real que tenga definiciones PUNCH.

1. Abre Punch Review.
2. Pulsa **Manage**.
3. Verifica que aparecen definiciones reales.
4. Usa **Refresh** sin editar.
5. Selecciona un campo y modifica su Label.
6. Comprueba estado `Modified`.
7. Prueba **Refresh**: debe bloquearse con aviso.
8. Prueba **Close**: debe bloquearse con aviso.
9. Usa **Cancel**.
10. Prueba **Close** de nuevo: debe cerrar.

## Gate de salida

No avanzar a DF-06D si existe cualquiera de estos síntomas:

- Manage no abre;
- el modal abre sin catálogo cuando el backend responde correctamente;
- Close ignora un draft modificado;
- Refresh provoca errores de nombres;
- Studio marca `cmpPR_CustomFieldsEditor.DraftDirty` como no reconocido;
- aparecen regresiones en Punch Review.

## Estado esperado

`DF-06C = FUNCTIONAL_FROZEN`

Después de validar, el siguiente incremento es:

`DF-06D — I · Save real`
