# DF-07A — Guía de implementación y validación

## Objetivo

Aplicar el refinamiento UX detectado en la validación visual del modal `cmp_CustomFieldsEditorPro` sin tocar backend ni reabrir DF-05/DF-06.

Documento de propiedades:

`07A_editor_ux_polish.property-guide.md`

## Orden recomendado

### Paso 1 — Internal Key

En `cmp_CustomFieldsEditorPro`:

1. modificar `txtCFDEPro_Label.OnChange`;
2. bloquear `txtCFDEPro_FieldKey.DisplayMode`;
3. actualizar `lblCFDEPro_KeyCaption.Text`.

Guardar el componente y comprobar primero que `ADD` genera el key automáticamente y `EDIT` no lo recalcula.

### Paso 2 — Barra inferior y compactación vertical

Aplicar en este orden:

1. posiciones del bloque General;
2. compactación de Behavior;
3. compactación de Filtering;
4. posición/altura responsive de Options;
5. anclaje inferior de `conCFDEPro_FormActions`.

Validar inmediatamente con un campo `Number` y después con `Choice`.

No continuar si `Options` y `Save/Cancel` se solapan.

### Paso 3 — Toggles

Reducir las dimensiones de:

- `tglCFDEPro_Required`;
- `tglCFDEPro_Pinned`;
- `tglCFDEPro_Active`;
- `tglCFDEPro_Filterable`;
- `tglCFDEPro_QuickFilter`;
- `tglCFDEPro_ShowInactive`.

No cambiar sus fórmulas de negocio.

### Paso 4 — Legibilidad

Aplicar únicamente los tamaños indicados en la tabla de DF-07A. No realizar un rediseño tipográfico general en este bloque.

### Paso 5 — Instancia modal

En:

`scr_PunchReview → conPR_CustomFieldsEditorModalLayer → cmpPR_CustomFieldsEditor`

cambiar:

- `ProjectLabel` para mostrar el proyecto real;
- `DangerColor` para eliminar el valor vacío de la instancia.

## Prueba funcional mínima

### Caso A — Alta Number

1. `+ Add field`.
2. Label: `Impact Score`.
3. Key esperado: `impact_score`.
4. El key no puede editarse.
5. Elegir `Number`.
6. Confirmar que `Save` y `Cancel` se ven completos.

### Caso B — Alta Choice

1. `+ Add field`.
2. Label: `Priority Test`.
3. Tipo: `Choice`.
4. Añadir tres opciones.
5. Confirmar que Options conserva espacio útil.
6. Confirmar que no existe solapamiento con `Save / Cancel`.

### Caso C — Edit

1. Seleccionar una definición existente.
2. Cambiar únicamente Label.
3. Confirmar que FieldKey no cambia.
4. Cancelar y confirmar restauración.

### Caso D — Toggles

1. Required on/off.
2. Pinned on/off.
3. Active on/off.
4. Filterable on/off.
5. Quick filter on/off cuando está habilitado.
6. Show inactive on/off.

Todos deben conservar el comportamiento funcional previo.

### Caso E — Contexto del proyecto

Con un proyecto seleccionado, el encabezado del componente debe mostrar:

`ProjectCode · ProjectName · PUNCH definitions`

Si no existe nombre pero sí `varProjectId`, debe utilizar el fallback `Project <id>`.

## Criterio de cierre

DF-07A puede cerrarse cuando:

- key automático funciona en ADD;
- key queda congelado en EDIT;
- barra inferior visible en la altura actual de Studio;
- Choice/MultiChoice no solapan Options con acciones;
- toggles son visualmente compactos y siguen funcionando;
- no aparecen nombres ni fórmulas en rojo;
- el proyecto real aparece en contexto;
- no hay regresión en Save ni Active/Inactive.

Tras este gate puede iniciarse `DF-07B — visual finish`, centrado en Preview, spacing y acabado final, sin cambios funcionales.
