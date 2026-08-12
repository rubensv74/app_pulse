# DF-06E — Guía de implementación y validación

## Objetivo

Conectar `Active / Inactive` del editor premium con el servicio host real `btnPR_SetCustomFieldActive`, manteniendo el backend fuera del componente.

## Orden de implementación

### Paso 1 — Crear el contrato del componente

Aplica `06E_active_inactive_contract.property-guide.md` y crea en `cmp_CustomFieldsEditorPro`:

- `ActiveChangeFieldKey` — Output / Text;
- `ActiveChangeTarget` — Output / Boolean;
- `ActiveMutationSucceeded` — Input / Boolean;
- `OnActiveChangeRequested` — Event.

Guarda el componente antes de continuar.

### Paso 2 — Sustituir el OnChange de Availability

Target:

`cmp_CustomFieldsEditorPro → conCFDEPro_Editor → conCFDEPro_Form → conCFDEPro_BehaviorPanel → conCFDEPro_Availability → tglCFDEPro_Active`

Propiedad:

`OnChange`

Copia el contenido completo de:

`06E_tglCFDEPro_Active.OnChange.powerfx`

No modifiques Default, DisplayMode, geometría ni textos del Toggle.

### Paso 3 — Conectar la instancia modal

Target:

`conPR_CustomFieldsEditorModalLayer → cmpPR_CustomFieldsEditor`

Configura:

`ActiveMutationSucceeded`

con la fórmula indicada en `06E_active_inactive_contract.property-guide.md`.

Después configura:

`OnActiveChangeRequested`

con el contenido completo de:

`06E_cmpPR_CustomFieldsEditor.OnActiveChangeRequested.powerfx`

## Matriz de validación

### Caso A — Desactivar una definición existente sin otros cambios

1. Abre Manage.
2. Selecciona una definición Active.
3. Confirma `DraftDirty=false` antes de cambiar Availability.
4. Cambia Active → Inactive.
5. Debe ejecutarse `btnPR_SetCustomFieldActive`.
6. Debe aparecer la notificación de desactivación correcta del servicio DF-05C.
7. El catálogo recargado debe reflejar `IsActive=false`.
8. Si el toggle era el único cambio, `DraftDirty` debe volver a `false`.
9. `varPunchDynamicFilters_NeedRefresh=true`.
10. Si hay Punch seleccionado, sus Custom Fields se refrescan mediante DF-05D.

### Caso B — Reactivar

Repite el caso anterior Inactive → Active y confirma el estado servidor.

### Caso C — Otros cambios locales ya pendientes

1. Selecciona una definición existente.
2. Modifica `Label` o `HelpText`.
3. Confirma `DraftDirty=true`.
4. Cambia Active/Inactive.
5. El cambio de disponibilidad se persiste inmediatamente.
6. `DraftDirty` debe seguir en `true` porque Label/HelpText aún no se ha guardado.
7. Pulsa Save.
8. DF-06D debe guardar el resto del draft sobre la misma definición.
9. No debe crearse un duplicado.

### Caso D — Nueva definición

1. Pulsa `+ Add field`.
2. Configura Label, FieldKey y tipo.
3. Cambia Availability a Active o Inactive.
4. Confirma que **no** se ejecuta `btnPR_SetCustomFieldActive`.
5. Pulsa Save.
6. DF-06D debe crear la definición con el valor `IsActive` elegido.

### Caso E — Error backend

Si `WarRoom_SetCustomFieldActive` devuelve error:

1. El error debe quedar en `varPunchReviewFieldDefToggleError`.
2. `cmpPR_CustomFieldsEditor.ErrorText` debe reflejarlo.
3. `DraftDirty` debe permanecer `true`.
4. Close debe continuar protegido por DF-06C.
5. Cancel debe permitir recuperar el estado del catálogo cargado.

## No modificar durante esta validación

- Review Queue;
- Punch Overview;
- Session Activity;
- Comments;
- Custom Field Values;
- Review Progress;
- modal Help;
- geometría de tres columnas del editor;
- Design System / colores.

## Resultado esperado

```text
DF-06A  HOST CONTRACT             FUNCTIONAL_FROZEN
DF-06B  MODAL SHELL               FUNCTIONAL_FROZEN
DF-06C  OPEN / CLOSE / REFRESH    FUNCTIONAL_FROZEN
DF-06D  SAVE                      FUNCTIONAL_FROZEN
DF-06E  ACTIVE / INACTIVE         FUNCTIONAL_FROZEN
COLOR                              PENDING
```

Con esta matriz limpia en Power Apps Studio puede cerrarse DF-06 a nivel funcional.
