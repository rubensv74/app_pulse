# DF-07B-FIX1 — Readability floor

**Componente:** `cmp_CustomFieldsEditorPro`  
**Estado:** READY FOR STUDIO VALIDATION  
**Tipo:** FIX visual aislado · property-only  
**Objetivo:** elevar la legibilidad del modal sin volver a inflar controles ni reabrir la geometría aprobada.

## Diagnóstico

La versión actual del componente contiene múltiples textos de `Size = 5`, `6` y `7`. En el modal real de Punch Review, y especialmente en pantallas 1366×768 / escalado Windows, varios captions, metadatos y textos auxiliares quedan demasiado pequeños respecto al resto de PULSE.

La solución no es aumentar el tamaño de los inputs ni del modal. Se establece una jerarquía tipográfica mínima:

```text
15 pt  título modal
10 pt  títulos de panel
9 pt   nombre de campo / elementos prioritarios
8 pt   body, captions, metadata normal, botones
7 pt   únicamente micro-badges / metadata muy secundaria
<7 pt  no permitido en este componente
```

No se modifican backend, eventos, DraftDefinition, Active/Inactive, Save, filtros ni arquitectura de tres columnas.

---

# A. Header

Mantener:

```text
lblCFDEPro_Title.Size = 15
lblCFDEPro_Context.Size = 8
```

Cambiar:

```text
lblCFDEPro_Status.Size       7 → 8
btnCFDEPro_Refresh.Size      8 → 8   (sin cambio)
btnCFDEPro_Close.Size        8 → 8   (sin cambio)
```

No cambiar alturas del header.

---

# B. Field catalog

Mantener:

```text
lblCFDEPro_CatalogTitle.Size = 10
lblCFDEPro_DefLabel.Size     = 8
```

Cambiar:

```text
lblCFDEPro_CatalogCount.Size      7 → 8
lblCFDEPro_DefKey.Size            7 → 8
lblCFDEPro_DefMeta.Size           7 → 8
lblCFDEPro_DefStatus.Size         6 → 7
lblCFDEPro_CatalogEmptyTitle.Size 8 → 9
lblCFDEPro_CatalogEmptyBody.Size  7 → 8
lblCFDEPro_CatalogLoading.Size    8 → 8   (sin cambio)
lblCFDEPro_CatalogErrorTitle.Size 8 → 9
lblCFDEPro_CatalogErrorBody.Size  7 → 8
```

Ajuste de seguridad para evitar clipping:

```text
lblCFDEPro_DefKey.Height   17 → 18
lblCFDEPro_DefMeta.Height  18 → 19
```

No cambiar `galCFDEPro_Definitions.TemplateSize = 84` en este bloque.

---

# C. Field configuration — cabecera y captions

Mantener:

```text
lblCFDEPro_EditorTitle.Size = 10
```

Cambiar:

```text
lblCFDEPro_DraftStatus.Size    6 → 7
lblCFDEPro_EditorSubtitle.Size 7 → 8
lblCFDEPro_GeneralTitle.Size   7 → 8

lblCFDEPro_LabelCaption.Size   6 → 8
lblCFDEPro_KeyCaption.Size     6 → 8
lblCFDEPro_TypeCaption.Size    6 → 8
lblCFDEPro_SortCaption.Size    6 → 8
lblCFDEPro_HelpCaption.Size    6 → 8
```

Aumentar solo la altura de captions donde el texto pueda quedar justo:

```text
lblCFDEPro_LabelCaption.Height 16 → 18
lblCFDEPro_KeyCaption.Height   16 → 18
lblCFDEPro_TypeCaption.Height  16 → 18
lblCFDEPro_SortCaption.Height  16 → 18
lblCFDEPro_HelpCaption.Height  16 → 18
```

No mover los inputs todavía. Si Studio muestra solape vertical tras este cambio, abrir `DF-07B-FIX2` específico de spacing; no compensar reduciendo la fuente.

---

# D. Behavior

Cambiar:

```text
lblCFDEPro_BehaviorTitle.Size      6 → 8
lblCFDEPro_RequirementCaption.Size 6 → 7
lblCFDEPro_PinningCaption.Size     6 → 7
lblCFDEPro_AvailabilityCaption.Size 6 → 7
```

Mantener los toggles en `Size = 8`.

Ajustar captions:

```text
lblCFDEPro_RequirementCaption.Height 12 → 14
lblCFDEPro_PinningCaption.Height     12 → 14
lblCFDEPro_AvailabilityCaption.Height 12 → 14
```

No aumentar el tamaño físico de los toggles.

---

# E. Filtering

Cambiar:

```text
lblCFDEPro_FilterTitle.Size        6 → 8
lblCFDEPro_FilterModeCaption.Size  6 → 7
lblCFDEPro_FilterOrderCaption.Size 6 → 7
numCFDEPro_FilterOrder.Size        6 → 8
```

Mantener:

```text
tglCFDEPro_Filterable.Size  = 8
tglCFDEPro_QuickFilter.Size = 8
```

Ajustar captions:

```text
lblCFDEPro_FilterModeCaption.Height  12 → 14
lblCFDEPro_FilterOrderCaption.Height 12 → 14
```

No tocar todavía `conCFDEPro_FilteringPanel.Height = 96`.

---

# F. Options editor

Cambiar:

```text
lblCFDEPro_OptionsTitle.Size  6 → 8
lblCFDEPro_OptionsHint.Size   5 → 7
lblCFDEPro_OptionsCount.Size  5 → 7
```

Mantener geometría actual del Options editor.

---

# G. Form actions

Cambiar:

```text
lblCFDEPro_FormActionsHint.Size 6 → 8
btnCFDEPro_CancelDraft.Size     7 → 8
btnCFDEPro_SaveDraft.Size       7 → 8
```

No cambiar altura 28 de los botones en este bloque.

---

# H. Live preview

Mantener:

```text
lblCFDEPro_PreviewTitle.Size      = 10
lblCFDEPro_PreviewSubtitle.Size   = 8
lblCFDEPro_PreviewFieldLabel.Size = 9
lblCFDEPro_PreviewInputText.Size  = 7
lblCFDEPro_PreviewHelp.Size       = 7
```

Cambiar:

```text
lblCFDEPro_PreviewType.Size         6 → 7
lblCFDEPro_PreviewFlags.Size        5 → 7
lblCFDEPro_PreviewOptions.Size      6 → 7
lblCFDEPro_PreviewAvailability.Size 6 → 7
lblCFDEPro_PreviewMetaTitle.Size    7 → 8
lblCFDEPro_PreviewKey.Size          6 → 7
lblCFDEPro_PreviewFiltering.Size    6 → 7
lblCFDEPro_PreviewQuickFilter.Size  6 → 7
lblCFDEPro_PreviewEmptyTitle.Size   8 → 9
lblCFDEPro_PreviewEmptyBody.Size    7 → 8
```

No modificar el ancho de Live Preview ni el tamaño de sus cards.

---

# I. Error banner

Cambiar:

```text
lblCFDEPro_ErrorBanner.Size 7 → 8
```

Mantener `Height = 30`.

---

# Controles que NO deben tocarse

No modificar en DF-07B-FIX1:

- `cmp_CustomFieldsEditorPro` Width/Height;
- anchos de Catalog / Editor / Preview;
- `galCFDEPro_Definitions.TemplateSize`;
- altura de Behavior / Filtering / Options panels;
- tamaños de TextInput / NumberInput / Dropdown / Toggle;
- `tglCFDEPro_Active.OnChange`;
- `DraftDefinition`;
- `ActiveChange*`;
- host events;
- flows;
- Save / Cancel logic;
- color palette.

---

# Validación Studio

## Vista sin selección

Confirmar:

- `Field catalog` y sus cards siguen compactos;
- FieldKey / Type / Pinned son legibles sin dominar el row;
- textos `Select a field` / `Nothing to preview` son claramente legibles;
- header y botones no crecen.

## Vista con una definición seleccionada

Confirmar:

- captions de General son legibles;
- Behavior y Filtering no presentan clipping;
- `Internal key`, `Field type`, `Sort order`, `Help text` se leen sin zoom;
- Live Preview ya no contiene microtexto ilegible;
- botones Save/Cancel conservan densidad.

## Escenario mínimo

Validar al menos una vez a 1366×768 o equivalente de host real.

## PASS

```text
TEXT < 7 PT                 0
PRIMARY PANEL TITLES        PASS
FORM CAPTIONS               PASS
CATALOG METADATA            PASS
BEHAVIOR CAPTIONS           PASS
FILTERING CAPTIONS          PASS
LIVE PREVIEW METADATA       PASS
NO NEW CLIPPING             PASS
NO GEOMETRY REGRESSION      PASS
NO FORMULA ERRORS           PASS
```

Si el aumento de captions produce solape vertical, no revertir a 5/6 pt. Abrir un FIX de spacing específico.