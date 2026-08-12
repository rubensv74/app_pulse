# DF-07B — Visual Finish de `cmp_CustomFieldsEditorPro`

**Tipo:** `C — Component / Visual polish`  
**Artefacto:** guía de propiedades  
**Propósito único:** cerrar el acabado visual del editor después de DF-07A/DF-07A-FIX1, mejorando legibilidad de estados no editables, balance del Live Preview y empty states sin modificar backend, contratos ni geometría macro de tres columnas.

## Gate de entrada

- DF-05 backend permanece congelado.
- DF-06 modal integration permanece congelado.
- DF-07A ha corregido Internal Key, footer, contexto de proyecto y densidad general.
- DF-07A-FIX1 repara el clipping de `Filtering` y deja `Options` posicionado relativamente respecto a ese panel.
- Este bloque parte de esos valores; no volver a aplicar coordenadas antiguas del baseline previo.

## No modificar

- `WarRoom_*` flows;
- servicios host `btnPR_*`;
- `DraftDefinition`;
- `OnSaveRequested`;
- `OnActiveChangeRequested`;
- `OptionsJson` / serialización;
- ancho relativo Catalog / Editor / Preview;
- header del modal;
- `+ Add field`, `Refresh`, `Close`, `Save`, `Cancel`;
- colores globales / Design System;
- Comments, Review Progress, Custom Field Values y Dirty Guard.

---

# A. Diferenciar `Disabled` de `Read only` en Filtering

La captura de DF-07A mostró que `Filter mode` y `Filter order` quedaban excesivamente lavados cuando `Filterable=false`. El dato debe ser no editable, pero debe seguir siendo legible.

## A1. `ddCFDEPro_FilterMode.DisplayMode`

Target:

`cmp_CustomFieldsEditorPro → conCFDEPro_Editor → conCFDEPro_Form → conCFDEPro_FilteringPanel → ddCFDEPro_FilterMode`

Sustituir únicamente `DisplayMode` por:

```powerfx
=If(
    !cmp_CustomFieldsEditorPro.CanManage ||
    cmp_CustomFieldsEditorPro.IsLoading ||
    cmp_CustomFieldsEditorPro.IsSaving,
    DisplayMode.Disabled,
    !Coalesce(varCFDEPro_Draft_IsFilterable, false),
    DisplayMode.View,
    DisplayMode.Edit
)
```

## A2. `numCFDEPro_FilterOrder.DisplayMode`

Usar exactamente el mismo criterio:

```powerfx
=If(
    !cmp_CustomFieldsEditorPro.CanManage ||
    cmp_CustomFieldsEditorPro.IsLoading ||
    cmp_CustomFieldsEditorPro.IsSaving,
    DisplayMode.Disabled,
    !Coalesce(varCFDEPro_Draft_IsFilterable, false),
    DisplayMode.View,
    DisplayMode.Edit
)
```

### Resultado esperado

- `Filterable=false`: valores visibles/read-only, sin apariencia de error ni pérdida de legibilidad.
- loading/saving/usuario sin permisos: continúa utilizándose `Disabled`.
- `Filterable=true`: controles editables.

No cambiar `Items`, `DefaultSelectedItems`, `Default`, `OnChange`, `Width`, `X` o `Y`.

---

# B. Live Preview — geometría relativa y jerarquía final

No se añaden controles. Solo se eliminan dependencias innecesarias de coordenadas absolutas y se mejora la lectura.

## B1. `lblCFDEPro_PreviewSubtitle`

```text
Height = 34
Size   = 8
```

Conservar el texto y posición actuales.

## B2. `lblCFDEPro_PreviewFlags`

```text
Size = 6
```

No modificar fórmula ni alineación.

## B3. `conCFDEPro_PreviewMetadata.Y`

Sustituir la coordenada fija por:

```powerfx
=conCFDEPro_PreviewCard.Y + conCFDEPro_PreviewCard.Height + 12
```

Conservar `Width`, `Fill`, `BorderColor` y radios.

## B4. `conCFDEPro_PreviewMetadata.Height`

Usar:

```powerfx
=Min(
    132,
    Max(
        112,
        Parent.Height - Self.Y - 8
    )
)
```

Esto aprovecha el alto disponible sin convertir la tarjeta en una superficie excesivamente grande.

## B5. Jerarquía de metadata

Aplicar:

| Control | Propiedad | Valor |
|---|---|---:|
| `lblCFDEPro_PreviewMetaTitle` | `Size` | `7` |
| `lblCFDEPro_PreviewKey` | `Size` | `6` |
| `lblCFDEPro_PreviewFiltering` | `Size` | `6` |
| `lblCFDEPro_PreviewQuickFilter` | `Size` | `6` |

No modificar sus fórmulas.

---

# C. Live Preview — spacing interno

## C1. `lblCFDEPro_PreviewFieldLabel`

```text
Height = 26
Size   = 9
Y      = 12
```

## C2. `conCFDEPro_PreviewInput`

```text
Y = 48
Height = 42
```

Conservar el resto.

## C3. `lblCFDEPro_PreviewHelp`

```text
Y      = 100
Height = 46
Size   = 7
```

## C4. `lblCFDEPro_PreviewOptions`

```text
Y    = 154
Size = 6
```

## C5. `lblCFDEPro_PreviewAvailability`

```text
Y    = 182
Size = 6
```

Estos cambios mantienen la tarjeta dentro del mismo alto y mejoran la separación entre label, input simulado, help, options y availability.

---

# D. Empty states centrados respecto al alto real

La posición de los empty states no debe depender de una altura de diseño fija.

## D1. Preview empty state

`lblCFDEPro_PreviewEmptyTitle.Y`

```powerfx
=Max(56, (Parent.Height - 90) / 2)
```

`lblCFDEPro_PreviewEmptyBody.Y`

```powerfx
=lblCFDEPro_PreviewEmptyTitle.Y + 32
```

## D2. Editor empty state

Aplicar el mismo patrón:

`lblCFDEPro_EditorEmptyTitle.Y`

```powerfx
=Max(72, (Parent.Height - 100) / 2)
```

`lblCFDEPro_EditorEmptyBody.Y`

```powerfx
=lblCFDEPro_EditorEmptyTitle.Y + 34
```

No modificar texto, `Visible`, ancho ni lógica de selección.

---

# E. Estado visual de Loading / Saving / Error

No se añaden nuevos controles ni se cambia la lógica host. Solo se valida la jerarquía existente:

- `conCFDEPro_StatusPill` debe ser la señal primaria de estado remoto;
- los controles editables deben quedar bloqueados durante loading/saving;
- el contenido debe permanecer legible;
- `ErrorText` no debe producir clipping en el modal;
- `Save` no debe quedar activo mientras `IsSaving=true`.

No modificar color en DF-07B. Cualquier problema cromático se tratará después como capa independiente.

---

# F. Second-order clipping pass obligatorio

Después de aplicar DF-07B revisar expresamente:

1. `Filtering` OFF / ON.
2. `Quick filter` OFF / ON.
3. `Choice` con pocas opciones.
4. `MultiChoice` con muchas opciones.
5. Label corto y label largo.
6. Help vacío y help largo.
7. `ADD` y `EDIT`.
8. `Loading`, `Saving`, `Error` y usuario sin permisos de manager.
9. modal con el alto real actual de Punch Review.
10. footer y `Options` simultáneamente visibles.

## Estado esperado tras validación

```text
DF-07A / FIX1              FUNCTIONAL_FROZEN
FILTERING READABILITY      VISUAL_APPROVED
LIVE PREVIEW               VISUAL_APPROVED
EMPTY STATES               VISUAL_APPROVED
LOADING/SAVING/ERROR QA    PASS
SECOND-ORDER CLIPPING      PASS
BACKEND                    UNCHANGED / FROZEN
COLOR                      PENDING
COMPONENT                  READY FOR VISUAL APPROVAL
```
