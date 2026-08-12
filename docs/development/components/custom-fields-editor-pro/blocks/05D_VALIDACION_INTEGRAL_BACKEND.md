# DF-05D — Validación integral del backend de Custom Field Definitions

## Clasificación

`I — Integration`

## Objetivo

Cerrar DF-05 demostrando en Power Apps Studio que lectura, guardado, Active/Inactive y propagación de refresh funcionan de forma consistente sin modificar la geometría ni el contrato visual de `cmp_CustomFieldsEditorPro`.

## Alcance

Servicios host:

- `btnPR_LoadCustomFieldDefs` — DF-05A;
- `btnPR_SaveCustomFieldDef` — DF-05B;
- `btnPR_SetCustomFieldActive` — DF-05C;
- `btnPR_RefreshCustomFieldDefinitionContext` — DF-05D.

Flows:

- `WarRoom_ListCustomFieldDefs`;
- `WarRoom_UpsertCustomFieldDef`;
- `WarRoom_SetCustomFieldActive`.

## Precondiciones

- proyecto real seleccionado;
- rol `manager`;
- al menos una definición PUNCH existente;
- una definición Choice o MultiChoice disponible para comprobar `OptionsJson`;
- un Punch real seleccionado para validar el refresh del bundle actual.

## Matriz de validación

### 1. Lectura autoritativa

- ejecutar `btnPR_LoadCustomFieldDefs`;
- `varPunchReviewFieldDefsError` vacío;
- `colPunchReviewFieldDefsAdmin` contiene activas e inactivas;
- comprobar `FieldKey`, `Label`, `FieldType`, `OptionsJson`, `IsActive`, `IsFilterable`, `ShowInQuickFilters`, `FilterOrder`, `FilterMode`.

Resultado esperado: `PASS`.

### 2. Guardado de una definición existente

- cargar una definición real en las variables `varPunchReviewDef_*`;
- modificar una propiedad no estructural, por ejemplo Label o HelpText;
- ejecutar `btnPR_SaveCustomFieldDef`;
- `varPunchReviewFieldDefsLastMutationSucceeded = true`;
- recarga del catálogo refleja el valor servidor;
- `varPunchReviewDefDirty = false`;
- `varPunchDynamicFilters_NeedRefresh = true`;
- `varPunchReviewFieldDefsRefreshWarning` vacío si el refresh termina correctamente.

Resultado esperado: `PASS`.

### 3. Crear una definición nueva

- `FieldDefId = 0`;
- usar `FieldKey` nuevo;
- guardar;
- confirmar aparición tras recarga autoritativa;
- comprobar que una segunda definición con el mismo FieldKey queda bloqueada por validación host.

Resultado esperado: `PASS`.

### 4. Choice / MultiChoice

- guardar opciones válidas;
- recargar catálogo;
- verificar que `OptionsJson` hace round-trip sin pérdida ni JSON visible al usuario;
- comprobar que Choice/MultiChoice sin opciones válidas queda bloqueado antes del Flow.

Resultado esperado: `PASS`.

### 5. Active → Inactive

- seleccionar una definición activa;
- establecer `varPunchReviewFieldDefToggleKey`;
- establecer `varPunchReviewFieldDefToggleActive = false`;
- ejecutar `btnPR_SetCustomFieldActive`;
- recargar;
- confirmar `IsActive = false` desde servidor;
- confirmar refresh del Punch actual;
- confirmar `varPunchDynamicFilters_NeedRefresh = true`.

Resultado esperado: `PASS`.

### 6. Inactive → Active

Repetir la prueba anterior con `varPunchReviewFieldDefToggleActive = true`.

Resultado esperado: `PASS`.

### 7. No-op Active/Inactive

Solicitar el mismo estado que ya tiene la definición.

Resultado esperado:

- no mutación backend innecesaria;
- notificación informativa;
- sin error.

### 8. Sin proyecto

Repetir Load, Save y Active/Inactive con `varProjectId` vacío.

Resultado esperado:

- Flow no debe ejecutarse correctamente como si existiera contexto;
- mensaje host claro;
- pantalla estable.

### 9. Sin permisos

Repetir Save y Active/Inactive con rol diferente de `manager`.

Resultado esperado:

- operación bloqueada en host;
- backend no modificado;
- error accionable.

### 10. Propagación a Punch List

Después de una mutación válida:

- `varPunchDynamicFilters_NeedRefresh = true`;
- volver a Punch List;
- abrir `Project filters`;
- comprobar ejecución de `btnPunches_LoadDynamicFilters_2`;
- comprobar que la bandera vuelve a `false`.

Resultado esperado: `PASS`.

### 11. Regresión visual

Confirmar que no han cambiado:

- Review Queue;
- Punch Overview;
- Session Activity;
- Comments;
- Custom Field Values;
- Review Progress;
- geometría de `conPR_RightColumn`;
- colores del Design System.

Resultado esperado: `PASS`.

## Gate de cierre DF-05

DF-05 puede cerrarse cuando las pruebas aplicables anteriores resulten correctas en Studio.

Estado objetivo:

```text
DEFINITION READ          FUNCTIONAL_FROZEN
DEFINITION UPSERT        FUNCTIONAL_FROZEN
ACTIVE / INACTIVE        FUNCTIONAL_FROZEN
POST-MUTATION REFRESH    FUNCTIONAL_FROZEN
DYNAMIC FILTER INVALID.  FUNCTIONAL_FROZEN
COMPONENT GEOMETRY       FUNCTIONAL_FROZEN
COLOR                    PENDING
```

Una vez cerrado DF-05, el siguiente incremento es DF-06: integración modal real de `cmp_CustomFieldsEditorPro` en Punch Review.
