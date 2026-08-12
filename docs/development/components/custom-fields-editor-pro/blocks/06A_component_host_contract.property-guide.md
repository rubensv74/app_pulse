# DF-06A — Contrato host de `cmp_CustomFieldsEditorPro`

## Clasificación

`C — Component`

## Propósito único

Exponer al host el draft interno ya funcional de `cmp_CustomFieldsEditorPro` sin mover geometría, sin llamar a Flows desde el componente y sin alterar la capa de color.

DF-06A prepara el contrato que utilizará posteriormente la instancia modal de Punch Review para guardar una definición mediante los servicios host ya congelados en DF-05.

## Dependencias

- DF-05A/B/C/D integrados sin errores pendientes.
- `cmp_CustomFieldsEditorPro` actual validado en Studio y considerado baseline funcional.
- El baseline vigente está archivado en:
  `docs/development/components/custom-fields-editor-pro/baselines/2026-08-11_current-working-component.pa.yaml`.

## No modificar

- geometría de las tres columnas;
- catálogo;
- formulario General / Behavior / Filtering / Options;
- Live Preview;
- colores;
- Flows;
- `scr_PunchReview`;
- servicios `btnPR_*`.

---

# 1. Añadir propiedades personalizadas al componente

En `cmp_CustomFieldsEditorPro`, crea exactamente estas propiedades nuevas.

## 1.1 `DraftDefinition`

- Tipo de propiedad: **Output**
- Tipo de dato: **Table**
- Descripción: `Single-row table containing the current local definition draft`

Fórmula de salida:

```powerfx
Table(
    {
        FieldDefId: Coalesce(varCFDEPro_Draft_FieldDefId, 0),
        ProjectId: Coalesce(cmp_CustomFieldsEditorPro.ProjectId, 0),
        EntityType: Upper(Coalesce(cmp_CustomFieldsEditorPro.EntityType, "PUNCH")),
        FieldKey: Coalesce(varCFDEPro_Draft_FieldKey, ""),
        Label: Coalesce(varCFDEPro_Draft_Label, ""),
        FieldType: Coalesce(varCFDEPro_Draft_FieldType, "Text"),
        HelpText: Coalesce(varCFDEPro_Draft_HelpText, ""),
        IsRequired: Coalesce(varCFDEPro_Draft_IsRequired, false),
        IsPinned: Coalesce(varCFDEPro_Draft_IsPinned, false),
        IsActive: Coalesce(varCFDEPro_Draft_IsActive, true),
        SortOrder: Coalesce(varCFDEPro_Draft_SortOrder, 100),
        OptionsJson: Coalesce(varCFDEPro_Draft_OptionsJson, "[]"),
        IsFilterable: Coalesce(varCFDEPro_Draft_IsFilterable, false),
        ShowInQuickFilters: Coalesce(varCFDEPro_Draft_ShowInQuickFilters, false),
        FilterOrder: Coalesce(varCFDEPro_Draft_FilterOrder, 100),
        FilterMode: Coalesce(varCFDEPro_Draft_FilterMode, "Equals")
    }
)
```

## 1.2 `DraftDirty`

- Tipo de propiedad: **Output**
- Tipo de dato: **Boolean**
- Descripción: `True when the local definition draft has unsaved changes`

Fórmula:

```powerfx
Coalesce(varCFDEPro_DraftDirty, false)
```

## 1.3 `EditMode`

- Tipo de propiedad: **Output**
- Tipo de dato: **Text**
- Descripción: `Current local editor mode: ADD, EDIT or blank`

Fórmula:

```powerfx
Coalesce(varCFDEPro_EditMode, "")
```

## 1.4 `OnSaveRequested`

- Tipo de propiedad: **Event**
- Return type: **None**
- Descripción: `Raised when the user requests persistence of the current definition draft`

No añadas lógica backend dentro del componente.

## 1.5 `OnCancelRequested`

- Tipo de propiedad: **Event**
- Return type: **None**
- Descripción: `Raised after the local draft has been cancelled or restored`

No añadas lógica backend dentro del componente.

---

# 2. Validación antes de continuar

Después de crear las cinco propiedades:

1. Guarda `cmp_CustomFieldsEditorPro`.
2. Confirma que Studio no muestra errores de fórmula.
3. Inserta o utiliza una instancia temporal.
4. Selecciona una definición existente y modifica `Label`.
5. Confirma `DraftDirty = true`.
6. Confirma que `First(<instancia>.DraftDefinition).Label` devuelve el valor editado.
7. Pulsa `+ Add field` y confirma `EditMode = "ADD"`.
8. Selecciona una definición existente y confirma `EditMode = "EDIT"`.

## Estado esperado

`COMPONENT HOST CONTRACT = FUNCTIONAL_FROZEN`

Cuando este contrato esté limpio, aplica `06A_form_actions.replace-control.pa.yaml`.
