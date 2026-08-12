# DF-05A — Orden correcto de implementación

## Problema observado

En `cmpPR_CustomFieldValues.OnManageFieldsRequested` aparecen errores de nombre no reconocido para:

- `btnPR_LoadCustomFieldDefs`;
- `colPunchReviewFieldDefsAdmin`;
- `varPunchReviewFieldDefsError`.

Esto ocurre cuando se aplica primero la fórmula de `OnManageFieldsRequested` pero todavía no se ha insertado el control host `btnPR_LoadCustomFieldDefs`.

Ese botón oculto es el bloque que introduce en la app:

- el servicio de carga;
- la colección `colPunchReviewFieldDefsAdmin`;
- las variables `varPunchReviewFieldDefsLoading` y `varPunchReviewFieldDefsError`.

Por tanto, el orden de aplicación es obligatorio.

## Paso 1 — Insertar el servicio host

Dentro de:

`conPR_RightColumn → conPR_CustomFieldsHost`

agregar como nuevo hijo el contenido completo de:

`05A_definition_load.add-child.pa.yaml`

Enlace directo:

https://github.com/rubensv74/app_pulse/blob/main/docs/development/components/custom-fields-editor-pro/blocks/05A_definition_load.add-child.pa.yaml

Después de pegarlo, comprobar en el árbol que existe:

`btnPR_LoadCustomFieldDefs`

No debe ser visible en runtime; es un control de servicio host.

## Paso 2 — Guardar y dejar que Studio reconozca los nombres

Guardar la pantalla/componente.

Antes de tocar `OnManageFieldsRequested`, comprobar que Power Apps ya reconoce al menos:

`btnPR_LoadCustomFieldDefs`

Si Studio todavía muestra el nombre como no reconocido, no avanzar al paso 3.

## Paso 3 — Conectar Manage

Solo después de completar los pasos 1 y 2, modificar:

`cmpPR_CustomFieldValues.OnManageFieldsRequested`

siguiendo:

`05A_manage_load_trigger.property-guide.md`

Enlace directo:

https://github.com/rubensv74/app_pulse/blob/main/docs/development/components/custom-fields-editor-pro/blocks/05A_manage_load_trigger.property-guide.md

Una vez insertado el botón host, Studio debe reconocer también:

- `colPunchReviewFieldDefsAdmin`;
- `varPunchReviewFieldDefsError`.

## Paso 4 — Validación funcional

Para probar la carga real es necesario disponer de un proyecto activo.

Con `No project selected`, el resultado esperado es un mensaje de error controlado indicando que no existe un proyecto activo. No es posible validar la carga real del catálogo en ese estado.

Con proyecto seleccionado:

1. pulsar `Manage`;
2. `btnPR_LoadCustomFieldDefs` debe ejecutar `WarRoom_ListCustomFieldDefs`;
3. `varPunchReviewFieldDefsLoading` debe volver a `false`;
4. `varPunchReviewFieldDefsError` debe quedar vacío;
5. `colPunchReviewFieldDefsAdmin` debe contener definiciones PUNCH activas e inactivas.

## No modificar

- geometría de Punch Review;
- `cmp_CustomFieldsEditorPro`;
- Review Progress;
- Comments;
- carga/guardado de valores Custom Fields;
- Dirty Guard;
- colores.

## Regla preventiva

En integraciones host mediante controles ocultos, siempre debe aplicarse este orden:

`crear servicio host → guardar/validar nombres → conectar evento consumidor`

Nunca conectar primero el evento a un control o colección que todavía no existe en la app.