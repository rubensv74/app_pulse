# DF-07C — Accesibilidad, teclado y foco visible

**Tipo:** `C — Component / Quality`  
**Artefacto:** guía de propiedades  
**Propósito único:** cerrar la navegación por teclado y la visibilidad del foco de `cmp_CustomFieldsEditorPro` sin modificar backend, persistencia, geometría macro ni contratos públicos.

## Gate de entrada

- DF-05 backend congelado.
- DF-06 integración modal congelada.
- DF-07A / FIX1 / DF-07B continuados sin nuevos errores reportados.
- La geometría de tres columnas no se reabre.
- Power Apps Studio sigue siendo la autoridad de validación.

## Restricción de compatibilidad PULSE

El registro vigente de compatibilidad confirma que `Classic/Button@2.2.0` no acepta `AccessibleLabel` en el Source Code actual de PULSE (`PR-SC-002`).

Por tanto:

- **NO** añadir `AccessibleLabel` a los botones clásicos mediante Source Code;
- conservar textos visibles claros en `Refresh`, `Close`, `+ Add field`, `Cancel` y `Save`;
- aplicar foco visible y orden de teclado mediante propiedades soportadas;
- para Toggle, usar `AccessibleLabel` solo desde Studio si la propiedad está expuesta en la instancia/control exacto. No forzarla mediante un bloque Source Code no validado.

---

# A. Botones clásicos — navegación y foco visible

Aplicar a:

- `btnCFDEPro_Refresh`
- `btnCFDEPro_Close`
- `btnCFDEPro_AddField`
- `btnCFDEPro_CancelDraft`
- `btnCFDEPro_SaveDraft`

Propiedades:

```powerfx
TabIndex = 0
FocusedBorderColor = cmp_CustomFieldsEditorPro.AccentColor
FocusedBorderThickness = 2
```

No modificar:

- `Text`;
- `OnSelect`;
- `DisplayMode`;
- `Fill` / `HoverFill`;
- geometría.

Criterio: el foco debe ser claramente visible sin alterar el tamaño del botón ni provocar clipping.

---

# B. Toggles clásicos — navegación, foco y nombre accesible

Aplicar a:

- `tglCFDEPro_ShowInactive`
- `tglCFDEPro_Required`
- `tglCFDEPro_Pinned`
- `tglCFDEPro_Active`
- `tglCFDEPro_Filterable`
- `tglCFDEPro_QuickFilter`

Propiedades comunes:

```powerfx
TabIndex = 0
FocusedBorderColor = cmp_CustomFieldsEditorPro.AccentColor
FocusedBorderThickness = 2
```

Conservar `TrueText` y `FalseText` visibles.

## AccessibleLabel — solo si Studio expone la propiedad en el Toggle exacto

Usar:

| Control | AccessibleLabel |
|---|---|
| `tglCFDEPro_ShowInactive` | `="Show inactive Custom Field definitions"` |
| `tglCFDEPro_Required` | `="Required Custom Field"` |
| `tglCFDEPro_Pinned` | `="Pinned Custom Field"` |
| `tglCFDEPro_Active` | `="Active Custom Field definition"` |
| `tglCFDEPro_Filterable` | `="Filterable Custom Field"` |
| `tglCFDEPro_QuickFilter` | `="Show Custom Field in quick filters"` |

Si una de estas propiedades no aparece en Studio para `Classic/Toggle@2.1.0`, no crearla manualmente en Source Code. Registrar el caso y continuar con el texto visible + foco + TabIndex.

---

# C. Controles modernos — participación en teclado

Power Apps usa `AcceptsFocus` para controles modernos.

## C1. Siempre interactivo

`txtCFDEPro_Search`

```powerfx
AcceptsFocus = true
```

## C2. Participar solo cuando realmente son editables

Para:

- `txtCFDEPro_Label`
- `ddCFDEPro_FieldType`
- `numCFDEPro_SortOrder`
- `txtCFDEPro_HelpText`
- `ddCFDEPro_FilterMode`
- `numCFDEPro_FilterOrder`
- `txtCFDEPro_OptionsLines`

usar, **solo si Studio expone `AcceptsFocus` para la versión exacta del control**:

```powerfx
=Self.DisplayMode = DisplayMode.Edit
```

Así un control en `View` o `Disabled` no introduce un tab stop inútil.

## C3. Internal Key

`txtCFDEPro_FieldKey` es un identificador técnico bloqueado por DF-07A.

Usar, si la propiedad existe en Studio:

```powerfx
AcceptsFocus = false
```

El usuario puede leer el key visualmente, pero no necesita detenerse en él durante la edición secuencial por teclado.

---

# D. Orden esperado de teclado

Con el modal abierto y una definición en edición, la secuencia debe seguir el flujo visual sin `TabIndex > 0`:

```text
Refresh
→ Close
→ + Add field
→ Search
→ Show inactive
→ Field label
→ Field type (solo ADD)
→ Sort order
→ Help text
→ Required
→ Pinned
→ Active
→ Filterable
→ Quick filter (cuando aplique)
→ Filter mode (cuando aplique)
→ Filter order (cuando aplique)
→ Options (Choice / MultiChoice)
→ Cancel
→ Save
```

No introducir valores `TabIndex` 1, 2, 3... para forzar artificialmente el orden. Si el orden observado no coincide, revisar primero el árbol y la estructura del componente.

---

# E. Estados disabled / view

Validar expresamente:

- `FieldType` en EDIT;
- `FilterMode` y `FilterOrder` con `Filterable=false`;
- `QuickFilter` con `Filterable=false`;
- controles durante `IsLoading=true`;
- controles durante `IsSaving=true`;
- instancia con `CanManage=false`.

Los elementos no interactivos no deben convertirse en paradas de teclado innecesarias.

---

# F. Limitación conocida del modal overlay

`conPR_CustomFieldsEditorModalLayer` es una superposición construida con controles Canvas estándar.

No se debe afirmar que este patrón proporciona semántica completa de diálogo accesible o focus trap. En Power Apps Canvas existen limitaciones conocidas para overlays respecto a administración de foco, ocultación del fondo a lectores de pantalla y semántica de diálogo.

Decisión PULSE para esta fase:

- conservar el modal actual porque ya está integrado funcionalmente;
- garantizar navegación por teclado razonable dentro del editor;
- no introducir hacks de foco ni dependencias experimentales;
- registrar la limitación;
- si en el futuro se exige conformidad estricta de diálogo, evaluar pantalla dedicada o componente de código accesible como cambio arquitectónico separado.

---

# G. No modificar

- `OnSaveRequested`;
- `OnActiveChangeRequested`;
- servicios `btnPR_*`;
- Flows / SP;
- `DraftDefinition`;
- `OptionsJson`;
- geometría macro Catalog / Editor / Preview;
- Help modal de Punch Review;
- Design System / paleta global.

---

# Estado esperado tras validación

```text
KEYBOARD NAVIGATION        VALIDATED
FOCUS VISIBILITY           VISUAL_APPROVED
CLASSIC INTERACTIVE TAB    VALIDATED
MODERN INTERACTIVE FOCUS   VALIDATED WHERE SUPPORTED
MODAL OVERLAY A11Y         KNOWN LIMITATION DOCUMENTED
BACKEND                    UNCHANGED / FROZEN
DF-07D HELP + DOCS         READY
```
