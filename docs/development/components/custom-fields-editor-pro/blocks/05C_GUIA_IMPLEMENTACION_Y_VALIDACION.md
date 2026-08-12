# DF-05C — Guía de implementación y validación Active / Inactive

## Clasificación

`I — Integration`

## Objetivo

Incorporar al host de Punch Review el servicio que activa o desactiva una definición PUNCH mediante `WarRoom_SetCustomFieldActive`, manteniendo Power Automate fuera de `cmp_CustomFieldsEditorPro`.

DF-05C no modifica el diseño del editor ni añade todavía el wiring definitivo del modal. Ese enlace llegará en DF-06.

---

## Orden obligatorio

### Paso 1 — Preparar el estado host

Aplicar:

`05C_host_active_state.property-guide.md`

Target:

`scr_PunchReview.OnVisible`

Después de guardar, Studio debe reconocer:

- `varPunchReviewFieldDefToggleKey`
- `varPunchReviewFieldDefToggleActive`
- `varPunchReviewFieldDefToggleLoading`
- `varPunchReviewFieldDefToggleError`

### Paso 2 — Añadir el servicio invisible

En:

`conPR_CustomFieldsHost`

agregar como nuevo hijo:

`05C_definition_active_toggle.add-child.pa.yaml`

No reemplazar `conPR_CustomFieldsHost`.

El árbol de servicios deberá incluir:

```text
conPR_CustomFieldsHost
├─ btnPR_LoadCustomFields
├─ btnPR_SaveCustomFields
├─ btnPR_LoadCustomFieldDefs
├─ btnPR_SaveCustomFieldDef
└─ btnPR_SetCustomFieldActive
```

---

## Qué hace el servicio

`btnPR_SetCustomFieldActive` recibe su intención mediante dos variables:

```text
varPunchReviewFieldDefToggleKey
varPunchReviewFieldDefToggleActive
```

Después valida:

1. proyecto activo;
2. permiso `manager`;
3. `FieldKey` informado;
4. definición presente en el catálogo cargado;
5. que el estado solicitado sea realmente distinto del actual.

Si existe una mutación real llama a:

```text
WarRoom_SetCustomFieldActive(
  ProjectId,
  "PUNCH",
  FieldKey,
  IsActive,
  UserEmail
)
```

Tras éxito:

- marca `varPunchDynamicFilters_NeedRefresh=true`;
- recarga `colPunchReviewFieldDefsAdmin` desde servidor mediante `btnPR_LoadCustomFieldDefs`;
- recarga los Custom Fields del Punch actual mediante `btnPR_LoadCustomFields`;
- sincroniza `varPunchReviewDef_IsActive` cuando el draft host corresponde al mismo `FieldKey`;
- muestra feedback al usuario.

---

## Validación mínima en Studio

### A. Validación de compilación

1. Guardar la pantalla.
2. Confirmar que `btnPR_SetCustomFieldActive` aparece en el árbol.
3. Abrir su propiedad `OnSelect`.
4. Confirmar que no existen nombres o fórmulas en rojo.
5. Confirmar que no cambia la geometría de Punch Review.

### B. Validación funcional temporal

Hasta DF-06 todavía no existe el wiring definitivo desde `cmp_CustomFieldsEditorPro`. Para validar ahora el backend, utiliza **una definición de prueba/no crítica** que ya aparezca en `colPunchReviewFieldDefsAdmin`.

Crea temporalmente un botón de prueba en una pantalla de test o en una superficie no productiva y usa como `OnSelect`:

```powerfx
Set(varPunchReviewFieldDefToggleKey, "<FIELD_KEY_DE_PRUEBA>");
Set(varPunchReviewFieldDefToggleActive, false);
Select(btnPR_SetCustomFieldActive)
```

Comprueba que:

- la definición pasa a `Inactive` después de la recarga;
- desaparece del panel de valores si el contrato backend excluye campos inactivos;
- `varPunchDynamicFilters_NeedRefresh = true`.

Después reactívala:

```powerfx
Set(varPunchReviewFieldDefToggleKey, "<FIELD_KEY_DE_PRUEBA>");
Set(varPunchReviewFieldDefToggleActive, true);
Select(btnPR_SetCustomFieldActive)
```

Comprueba que vuelve a `Active` tras la recarga autoritativa.

El botón de prueba debe eliminarse al terminar. No forma parte de la arquitectura de Punch Review.

---

## Casos que deben fallar de forma controlada

- sin proyecto activo;
- usuario distinto de `manager`;
- `FieldKey` vacío;
- `FieldKey` no presente en `colPunchReviewFieldDefsAdmin`;
- error del Flow.

En todos ellos debe quedar un mensaje en `varPunchReviewFieldDefToggleError` y mostrarse una notificación de error.

---

## Fuera de alcance

DF-05C no debe:

- modificar `cmp_CustomFieldsEditorPro`;
- alterar sus toggles visuales;
- abrir el modal;
- cambiar el layout de Punch Review;
- modificar Comments, Review Progress o Review Queue;
- cambiar colores;
- introducir propiedades de definición no soportadas por el backend.

---

## Estado esperado después de validar

```text
DF-05A READ SERVICE          FUNCTIONAL_FROZEN
DF-05B UPSERT SERVICE        FUNCTIONAL_FROZEN
DF-05C ACTIVE/INACTIVE       FUNCTIONAL_FROZEN
COMPONENT STRUCTURE          FUNCTIONAL_FROZEN
COLOR                        PENDING
```

El siguiente incremento es `DF-05D`, dedicado exclusivamente a cerrar la invalidación/refresh de dependencias y verificar el contrato backend completo antes de montar el modal en DF-06.
