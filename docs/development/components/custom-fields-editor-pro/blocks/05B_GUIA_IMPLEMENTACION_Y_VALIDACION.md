# DF-05B — Guía de implementación y validación del guardado de definiciones

## Objetivo

Incorporar en `scr_PunchReview` el servicio host que persistirá las definiciones del futuro modal `cmp_CustomFieldsEditorPro` mediante `WarRoom_UpsertCustomFieldDef`.

DF-05B **no abre todavía el modal** y **no modifica el componente visual**. Su responsabilidad única es preparar y validar la escritura backend desde el host.

## Orden obligatorio

### Paso 1 — Inicializar el estado host

Aplica primero:

`05B_host_save_runtime.property-guide.md`

Target:

`scr_PunchReview.OnVisible`

Este paso crea con tipos inequívocos las variables `varPunchReviewDef_*` que utilizará el servicio de guardado.

Guarda la pantalla antes de continuar.

### Paso 2 — Añadir el servicio de guardado

Target parent:

`conPR_CustomFieldsHost`

Añade como nuevo hijo:

`05B_definition_upsert.add-child.pa.yaml`

No reemplaces `conPR_CustomFieldsHost` y no elimines los servicios existentes.

El árbol debe contener como mínimo los servicios:

```text
conPR_CustomFieldsHost
├─ btnPR_LoadCustomFields
├─ btnPR_SaveCustomFields
├─ btnPR_LoadCustomFieldDefs
└─ btnPR_SaveCustomFieldDef   ← DF-05B
```

`btnPR_SaveCustomFieldDef` es invisible de forma intencionada.

## Qué valida antes de llamar al Flow

El servicio bloquea el guardado cuando:

- no existe proyecto activo;
- el rol no es `manager`;
- falta Label;
- falta FieldKey;
- el FieldKey ya existe en otra definición;
- SortOrder no es mayor que cero;
- Choice/MultiChoice no contienen al menos una opción JSON válida.

## Contrato backend utilizado

El orden de parámetros se mantiene exactamente igual que en la implementación legacy validada de PULSE:

```text
WarRoom_UpsertCustomFieldDef.Run(
    FieldDefId,
    ProjectId,
    EntityType,
    Label,
    FieldType,
    HelpText,
    SortOrder,
    OptionsJson,
    UserEmail,
    FieldKey,
    IsRequired,
    IsPinned,
    IsActive,
    IsFilterable,
    ShowInQuickFilters,
    FilterOrder,
    FilterMode
)
```

Para tipos distintos de Choice/MultiChoice se conserva el comportamiento existente y se envía `" "` en el parámetro OptionsJson.

## Qué ocurre después de un guardado correcto

El host ejecuta automáticamente:

1. `Select(btnPR_LoadCustomFieldDefs)` para reconstruir el catálogo desde servidor;
2. `Select(btnPR_LoadCustomFields)` si existe un Punch actual, de modo que una nueva definición pueda aparecer en el panel de valores;
3. `Set(varPunchDynamicFilters_NeedRefresh, true)` para invalidar los filtros dinámicos derivados de definiciones;
4. limpia `varPunchReviewDefDirty`;
5. muestra confirmación de guardado.

El servidor vuelve a ser la fuente autoritativa tras la mutación.

## Validación en Studio

En DF-05B hay dos niveles de validación.

### Validación inmediata

Antes de DF-06 debes comprobar:

1. Studio acepta el bloque sin errores de Source Code.
2. `btnPR_SaveCustomFieldDef` aparece bajo `conPR_CustomFieldsHost`.
3. Las variables `varPunchReviewDef_*` son reconocidas.
4. `WarRoom_UpsertCustomFieldDef` no aparece como nombre inválido.
5. No cambia la geometría de Punch Review.
6. Comments, Custom Field Values y Review Progress permanecen intactos.

### Validación funcional del write

La prueba natural del guardado se completará cuando DF-06 conecte los outputs del draft de `cmp_CustomFieldsEditorPro` con las variables host y ejecute `Select(btnPR_SaveCustomFieldDef)`.

No crear un registro ficticio únicamente para probar el Flow. La validación funcional se hará con una definición real controlada desde el editor.

## Gate

Mientras Studio muestre un error en `btnPR_SaveCustomFieldDef`, no continuar a DF-05C.

Si el bloque queda limpio pero todavía no se ha ejecutado un guardado real, el estado es:

```text
DF-05B HOST WRITE SERVICE = FUNCTIONAL
BACKEND WRITE E2E          = PENDING DF-06 WIRING
```
