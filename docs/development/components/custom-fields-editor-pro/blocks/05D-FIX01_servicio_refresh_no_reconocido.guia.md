# DF-05D-FIX01 — `btnPR_RefreshCustomFieldDefinitionContext` no reconocido

## Clasificación

`FIX — Integration`

## Síntoma

Power Apps Studio muestra el mismo error en dos fórmulas:

```text
Name isn't valid. 'btnPR_RefreshCustomFieldDefinitionContext' isn't recognized.
```

El error aparece en:

- `btnPR_SaveCustomFieldDef.OnSelect`;
- `btnPR_SetCustomFieldActive.OnSelect`.

## Diagnóstico

No son dos errores distintos.

Ambos servicios llaman al mismo control host de DF-05D:

`btnPR_RefreshCustomFieldDefinitionContext`

Por tanto, si ese control todavía no existe en `scr_PunchReview`, no se ha guardado correctamente, se insertó en otro contexto o Power Apps lo renombró, las dos fórmulas quedan en rojo al mismo tiempo.

## Solución

### 1. Verificar el árbol

En `scr_PunchReview`, localizar:

```text
conPR_RightColumn
└── conPR_CustomFieldsHost
```

Dentro de `conPR_CustomFieldsHost` debe existir exactamente este control:

```text
btnPR_RefreshCustomFieldDefinitionContext
```

Debe estar al mismo nivel que los otros servicios host:

```text
conPR_CustomFieldsHost
├── btnPR_LoadCustomFields
├── btnPR_SaveCustomFields
├── btnPR_LoadCustomFieldDefs
├── btnPR_SaveCustomFieldDef
├── btnPR_SetCustomFieldActive
└── btnPR_RefreshCustomFieldDefinitionContext
```

### 2. Si no existe

Insertar como nuevo hijo de `conPR_CustomFieldsHost` el bloque:

`05D_post_mutation_refresh.add-child.pa.yaml`

No reemplazar `conPR_CustomFieldsHost` completo.

### 3. Si existe con otro nombre

Power Apps puede renombrar un control al pegarlo si detecta una colisión.

Si el árbol muestra, por ejemplo:

```text
btnPR_RefreshCustomFieldDefinitionContext_1
```

renombrarlo manualmente a:

```text
btnPR_RefreshCustomFieldDefinitionContext
```

Antes de renombrar, comprobar que no existe otro control con el nombre objetivo.

### 4. Guardar antes de revisar las fórmulas dependientes

Después de insertar o renombrar el servicio:

1. guardar `scr_PunchReview`;
2. volver a `btnPR_SaveCustomFieldDef.OnSelect`;
3. volver a `btnPR_SetCustomFieldActive.OnSelect`;
4. confirmar que las dos referencias `Select(btnPR_RefreshCustomFieldDefinitionContext)` dejan de aparecer en rojo.

## No modificar

Este FIX no requiere cambiar:

- las fórmulas de Save;
- las fórmulas de Active/Inactive;
- `cmp_CustomFieldsEditorPro`;
- geometría de Punch Review;
- Comments;
- Review Progress;
- Punch List;
- backend o flows.

## Validación mínima

El FIX queda resuelto cuando:

- `btnPR_RefreshCustomFieldDefinitionContext` aparece en el árbol bajo `conPR_CustomFieldsHost`;
- Studio reconoce su nombre;
- desaparecen los dos errores duplicados;
- no aparecen nuevos errores de fórmula.

## Estado esperado

`DF-05D DEPENDENCY RESOLUTION = VALIDATED`
