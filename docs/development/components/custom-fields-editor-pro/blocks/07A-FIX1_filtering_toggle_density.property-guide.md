# DF-07A-FIX1 — Filtering clipping y densidad de toggles

**Tipo:** `C — Component / FIX`  
**Artefacto:** guía de propiedades  
**Propósito único:** reparar el clipping introducido al compactar DF-07A y cerrar la densidad visual de los toggles sin tocar backend, contratos ni geometría macro.

## Por qué es un FIX y no DF-07B

La captura validada después de DF-07A demuestra una mejora clara del editor, pero también revela un efecto de segundo orden de la compactación: `Not filterable` y `More filters` no disponen de ancho suficiente y el texto se envuelve/recorta dentro de `conCFDEPro_FilteringPanel`.

Según el playbook modular, un defecto causado por el bloque actual debe repararse como `FIX` del mismo bloque antes de avanzar al siguiente incremento visual.

## Evidencia observada en Studio

- `Internal key` ya aparece generado y bloqueado.
- `Save / Cancel` ya son visibles.
- el contexto real del proyecto ya se muestra correctamente.
- los switches han reducido su track, pero el texto asociado sigue teniendo demasiado peso.
- `Filtering` presenta clipping/solapamiento por ancho insuficiente de los toggles compactados.

## No modificar

- DF-05 backend;
- DF-06 modal integration;
- `OnSaveRequested`;
- `OnActiveChangeRequested`;
- `OptionsJson`;
- ancho relativo Catalog / Editor / Preview;
- Header;
- Live Preview en este FIX;
- paleta global.

---

# A. Reparar la fila superior de Filtering

## A1. `conCFDEPro_FilteringPanel`

Target:

`cmp_CustomFieldsEditorPro → conCFDEPro_Editor → conCFDEPro_Form → conCFDEPro_FilteringPanel`

Usar:

```text
Y      = 236
Height = 96
```

No modificar `Width`, `Fill`, `BorderColor` ni radios.

## A2. `tglCFDEPro_Filterable`

Usar:

```powerfx
Height = 22
Width  = (Parent.Width - 24) / 2
X      = 8
Y      = 20
Size   = 8
```

Conservar:

```text
FalseText = "Not filterable"
TrueText  = "Filterable"
```

Conservar íntegramente `Default`, `DisplayMode` y `OnChange`.

## A3. `tglCFDEPro_QuickFilter`

Usar:

```powerfx
Height = 22
Width  = (Parent.Width - 24) / 2
X      = 16 + (Parent.Width - 24) / 2
Y      = 20
Size   = 8
```

Conservar:

```text
FalseText = "More filters"
TrueText  = "Quick filter"
```

Conservar íntegramente `Default`, `DisplayMode` y `OnChange`.

### Resultado esperado

Los dos toggles recuperan el ancho horizontal necesario para mantener su semántica en una sola línea, pero conservan el track compacto introducido en DF-07A.

---

# B. Separar correctamente captions e inputs inferiores

## B1. Captions

Para:

- `lblCFDEPro_FilterModeCaption`
- `lblCFDEPro_FilterOrderCaption`

usar:

```text
Height = 12
Y      = 50
Size   = 6
```

No modificar `Text`, `Width` ni `X`.

## B2. Inputs

Para `ddCFDEPro_FilterMode`:

```text
Height = 28
Y      = 64
```

Para `numCFDEPro_FilterOrder`:

```text
Height = 28
Y      = 64
```

Conservar íntegramente su `DisplayMode`, selección/valor y `OnChange`.

Con esta distribución el borde inferior de los inputs termina en `Y=92`, dejando 4 px de margen dentro del panel de 96 px.

---

# C. Mantener Options debajo del panel reparado

Target:

`conCFDEPro_OptionsEditor`

Sustituir únicamente `Y` por:

```powerfx
=conCFDEPro_FilteringPanel.Y + conCFDEPro_FilteringPanel.Height + 8
```

Conservar el `Height` responsive aplicado en DF-07A:

```powerfx
=Max(
    54,
    conCFDEPro_FormActions.Y - Self.Y - 6
)
```

Esto evita volver a introducir coordenadas absolutas que puedan provocar otro solapamiento después de modificar Filtering.

---

# D. Cerrar la densidad de los demás toggles

La captura demuestra que el track ya es correcto, pero el texto sigue visualmente sobredimensionado frente a captions e inputs.

Aplicar `Size = 8` a:

- `tglCFDEPro_Required`
- `tglCFDEPro_Pinned`
- `tglCFDEPro_Active`
- `tglCFDEPro_ShowInactive`

No modificar tamaños, posición, `TrueText`, `FalseText`, `Default`, `DisplayMode` ni eventos.

Para los captions:

- `lblCFDEPro_RequirementCaption`
- `lblCFDEPro_PinningCaption`
- `lblCFDEPro_AvailabilityCaption`

usar:

```text
Size = 6
```

Esto establece una jerarquía legible:

```text
caption contextual  <  estado del toggle  <  inputs principales
```

sin aumentar la altura total del formulario.

---

# E. Hint de acciones

Target:

`conCFDEPro_FormActions → lblCFDEPro_FormActionsHint`

Usar:

```text
Size = 6
```

No modificar su `Text`, `Width`, `X`, `Y` ni la geometría de los botones.

---

# Validación mínima en Studio

1. Abrir una definición `Text` no filterable.
2. Confirmar que `Not filterable` aparece en una sola línea y no invade `Filter mode`.
3. Activar `Filterable`.
4. Confirmar que `Filterable` aparece completo.
5. Comprobar `More filters` y `Quick filter` en estado OFF/ON.
6. Confirmar que `Filter mode` y `Filter order` no se solapan con los toggles.
7. Cambiar a `Choice` y confirmar que `Options` comienza 8 px debajo de Filtering.
8. Confirmar que `Options` no invade `Save / Cancel`.
9. Confirmar que Requirement / Pinning / Availability siguen funcionando con texto más compacto.
10. Confirmar que `Active only / Show inactive` sigue funcionando y mantiene una sola línea.
11. Confirmar que no hay errores de fórmula ni cambios de backend.

## Estado esperado tras validación

```text
DF-07A COMPACT LAYOUT       FUNCTIONAL_FROZEN
FILTERING CLIPPING          RESOLVED
TOGGLE DENSITY              VISUAL_APPROVED
OPTIONS / FOOTER CLEARANCE  VISUAL_APPROVED
BACKEND                     UNCHANGED / FROZEN
DF-07B VISUAL FINISH        READY TO START
```
