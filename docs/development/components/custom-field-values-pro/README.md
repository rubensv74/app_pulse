# cmp_CustomFieldValuesPro — Especificación v1

**Estado:** construcción incremental activa  
**Primer consumidor:** Punch Review Workspace  
**Responsabilidad:** mostrar y editar los valores actuales de Custom Fields del Punch seleccionado

## 1. Propósito

`cmp_CustomFieldValuesPro` es el componente compacto de valores por registro.

No administra definiciones de Custom Fields. Esa responsabilidad pertenece a `cmp_CustomFieldsEditorPro`.

El primer consumidor es la columna derecha de Punch Review, entre Comments y Review Progress.

## 2. Responsabilidades

El componente debe:

- recibir el `bundle.merged` normalizado por el host;
- mostrar Field Label + valor actual en una lista compacta;
- soportar Text, Number, Date, YesNo, Choice y MultiChoice;
- permitir edición cuando `CanEdit=true`;
- mantener estado local dirty en la fase VF-03;
- exponer dirty payload al host;
- emitir Refresh, Save, Cancel/Reset y Manage Fields requested;
- representar Loading / Empty / Ready / Unsaved / Saving / Error;
- mantener apariencia PULSE premium y compacta.

El componente no debe:

- ejecutar `WarRoom_GetCustomBundle`;
- ejecutar `WarRoom_SaveCustomBulk`;
- administrar definiciones;
- navegar entre pantallas;
- decidir el Dirty Guard;
- registrar Session Activity.

## 3. Contrato Items

La entrada conserva el contrato ya normalizado en Punch Review:

- `FieldKey`
- `FieldLabel`
- `FieldType`
- `HelpText`
- `IsRequired`
- `IsPinned`
- `IsEditable`
- `SortOrder`
- `OptionsJson`
- `ValueText`
- `ValueNumber`
- `ValueDate`
- `ValueBool`
- `ValueJson`
- `LastUpdatedOn`
- `LastUpdatedByEmail`

La fuente autoritativa continúa siendo el bundle devuelto por servidor.

## 4. Diseño visual

Patrón objetivo: panel compacto de dos columnas.

```text
Custom Fields                              Manage
PUNCH-000001
────────────────────────────────────────────────
Vendor Package        PKG-07 · HVAC System
Walkdown Area         Area 2A · Mechanical Room
Inspection Required   Yes
Completion Note       Tag installed and verified...
────────────────────────────────────────────────
                                Cancel      Save
```

El diseño debe priorizar densidad legible, divisores sutiles y mínimo ruido de metadata.

## 5. Roadmap VF

- `VF-01` — shell + contrato inicial.
- `VF-02` — renderizadores y editores de los seis tipos.
- `VF-03` — working buffer, dirty tracking y eventos host completos.
- `VF-04` — integración real en Punch Review.
- `VF-05` — polish responsive de Comments + Values + Review Progress.

## 6. Integración posterior

Punch Review conservará durante VF-04:

- `btnPR_LoadCustomFields`;
- `btnPR_SaveCustomFields`;
- `colPunchReviewFieldsUI`;
- `colPunchReviewFieldsBase`;
- `colPunchReviewFieldsDirty`;
- `varPunchReviewDirty`;
- `varPunchReviewFieldsLoading`;
- `varPunchReviewFieldsSaving`;
- `varPunchReviewFieldsError`.

El Dirty Guard del Bloque 13 continúa siendo autoritativo.

## 7. Reglas de compatibilidad

Antes de cada `.pa.yaml` debe consultarse:

`docs/development/screens/punch-review/POWER_APPS_SOURCE_CODE_COMPATIBILITY.md`

VF-01 no introduce SVG, no depende de otro Canvas Component, no usa `AccessibleLabel` en botones clásicos y no coloca propiedades `Radius*` en `Label@2.5.1`.
