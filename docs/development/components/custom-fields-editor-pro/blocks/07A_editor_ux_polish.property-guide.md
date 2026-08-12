# DF-07A — Custom Fields Editor UX Polish

**Tipo:** `C/I — Component / Integration`  
**Artefacto:** guía de propiedades  
**Propósito único:** corregir los problemas visuales y de interacción detectados en Studio sin alterar el contrato backend ya cerrado en DF-05/DF-06.

## Gate

- DF-06A/B/C/D/E integrados sin error pendiente reportado.
- `cmp_CustomFieldsEditorPro` funciona como modal real dentro de Punch Review.
- La geometría de las tres columnas se conserva.
- No se modifican Flows, SP, servicios `btnPR_*`, Comments, Review Progress ni Custom Field Values.

## Problemas que corrige

1. `Internal key` no debe editarse manualmente.
2. La barra inferior `Cancel / Save` queda recortada con alturas reales de Studio inferiores a 700 px.
3. Los toggles ocupan demasiado espacio visual.
4. `Active only` tiene demasiado peso en el catálogo.
5. Microtipografía demasiado pequeña en catálogo y preview.
6. El modal muestra `Current project` en vez del proyecto real.
7. La instancia aportada tiene `DangerColor` sin valor explícito.

---

# A. Internal Key automático y bloqueado

## A1. `txtCFDEPro_Label.OnChange`

Target:

`cmp_CustomFieldsEditorPro → conCFDEPro_Editor → conCFDEPro_Form → txtCFDEPro_Label → OnChange`

Sustituir la fórmula completa por:

```powerfx
=Set(varCFDEPro_Draft_Label, Self.Text);
If(
    varCFDEPro_EditMode = "ADD",
    Set(
        varCFDEPro_Draft_FieldKey,
        Lower(
            Substitute(
                Trim(Self.Text),
                " ",
                "_"
            )
        )
    )
);
Set(varCFDEPro_DraftDirty, true)
```

Resultado:

- `ADD`: el key sigue al label automáticamente;
- `EDIT`: el key permanece estable aunque cambie el label.

## A2. `txtCFDEPro_FieldKey.DisplayMode`

Usar:

```powerfx
=DisplayMode.View
```

El `FieldKey` nunca vuelve a ser un campo editable desde este componente.

## A3. `lblCFDEPro_KeyCaption.Text`

Usar:

```powerfx
=If(
    varCFDEPro_EditMode = "ADD",
    "Internal key · generated automatically",
    "Internal key · locked"
)
```

No modificar el contrato backend ni el nombre `FieldKey`.

---

# B. Compactar el formulario para que Save / Cancel siempre sean visibles

No se cambia la anchura de las tres columnas. Solo se compacta la distribución vertical de `conCFDEPro_Form`.

## B1. General

Aplicar estas posiciones:

| Control | Propiedad | Valor |
|---|---|---|
| `lblCFDEPro_LabelCaption` | `Y` | `18` |
| `txtCFDEPro_Label` | `Y` | `34` |
| `lblCFDEPro_KeyCaption` | `Y` | `68` |
| `txtCFDEPro_FieldKey` | `Y` | `84` |
| `lblCFDEPro_TypeCaption` | `Y` | `68` |
| `ddCFDEPro_FieldType` | `Y` | `84` |
| `lblCFDEPro_SortCaption` | `Y` | `68` |
| `numCFDEPro_SortOrder` | `Y` | `84` |
| `lblCFDEPro_HelpCaption` | `Y` | `118` |
| `txtCFDEPro_HelpText` | `Y` | `132` |
| `txtCFDEPro_HelpText` | `Height` | `34` |

## B2. Behavior

`conCFDEPro_BehaviorPanel`

```text
Y = 174
Height = 54
```

Para:

- `conCFDEPro_Requirement`
- `conCFDEPro_Pinning`
- `conCFDEPro_Availability`

usar:

```text
Y = 18
Height = 32
```

Para sus captions (`lblCFDEPro_RequirementCaption`, `lblCFDEPro_PinningCaption`, `lblCFDEPro_AvailabilityCaption`):

```text
Height = 12
```

Para los tres toggles (`tglCFDEPro_Required`, `tglCFDEPro_Pinned`, `tglCFDEPro_Active`):

```text
Height = 20
Y = 12
Width = Min(96, Parent.Width)
```

Conservar `TrueText` / `FalseText` actuales y toda la lógica `OnChange` ya integrada.

## B3. Filtering

`conCFDEPro_FilteringPanel`

```text
Y = 236
Height = 86
```

`tglCFDEPro_Filterable`

```text
Height = 20
Width = 118
Y = 20
```

`tglCFDEPro_QuickFilter`

```text
Height = 20
Width = 118
X = Parent.Width - 126
Y = 20
```

`lblCFDEPro_FilterModeCaption` y `lblCFDEPro_FilterOrderCaption`

```text
Height = 12
Y = 46
```

`ddCFDEPro_FilterMode`

```text
Height = 26
Y = 58
```

`numCFDEPro_FilterOrder`

```text
Height = 26
Y = 58
```

Conservar la lógica actual de DisplayMode y OnChange.

## B4. Options responsive

`conCFDEPro_OptionsEditor`

```powerfx
Y = 330
```

```powerfx
Height = Max(
    54,
    conCFDEPro_FormActions.Y - Self.Y - 6
)
```

`txtCFDEPro_OptionsLines`

```powerfx
Y = 20
```

```powerfx
Height = Max(28, Parent.Height - 26)
```

No cambiar la fórmula de serialización JSON ya validada.

## B5. Barra inferior anclada al fondo

`conCFDEPro_FormActions`

```powerfx
Height = 34
```

```powerfx
Y = Parent.Height - Self.Height - 2
```

`lblCFDEPro_FormActionsHint`

```text
Height = 28
Y = 3
```

`btnCFDEPro_CancelDraft` y `btnCFDEPro_SaveDraft`

```text
Height = 28
Y = 3
```

No modificar sus eventos `OnSelect` de DF-06D.

---

# C. Catalog toggle más compacto

Target:

`tglCFDEPro_ShowInactive`

Usar:

```text
Height = 22
Width = 132
```

Conservar:

```text
FalseText = "Active only"
TrueText  = "Show inactive"
```

No modificar su función de filtrado del catálogo.

---

# D. Legibilidad mínima

Incrementar únicamente la microtipografía más pequeña:

| Control | `Size` |
|---|---:|
| `lblCFDEPro_DefKey` | `7` |
| `lblCFDEPro_DefMeta` | `7` |
| `lblCFDEPro_DefStatus` | `6` |
| `lblCFDEPro_PreviewSubtitle` | `8` |
| `lblCFDEPro_PreviewHelp` | `7` |
| `lblCFDEPro_PreviewKey` | `6` |
| `lblCFDEPro_PreviewFiltering` | `6` |
| `lblCFDEPro_PreviewQuickFilter` | `6` |

No cambiar todavía títulos principales ni la escala global del componente.

---

# E. Contexto real del proyecto en la instancia modal

Target:

`scr_PunchReview → conPR_CustomFieldsEditorModalLayer → cmpPR_CustomFieldsEditor → ProjectLabel`

Sustituir `Current project` por:

```powerfx
=If(
    IsBlank(varProjectId),
    "No project selected",
    Coalesce(
        varSelectedProject.ProjectCode,
        "Project " & Text(varProjectId)
    ) &
    If(
        !IsBlank(Coalesce(varSelectedProject.ProjectName, "")),
        " · " & varSelectedProject.ProjectName,
        ""
    )
)
```

`varSelectedProject.ProjectCode` y `varSelectedProject.ProjectName` ya forman parte del contexto de Punch Review y alimentan `cmpPR_Sidebar`.

---

# F. DangerColor explícito en la instancia

En la instancia aportada por el usuario aparece:

```text
DangerColor: =
```

Target:

`scr_PunchReview → conPR_CustomFieldsEditorModalLayer → cmpPR_CustomFieldsEditor → DangerColor`

Usar:

```powerfx
=ColorValue("#DC2626")
```

Esto no constituye una revisión cromática general; solo evita dejar vacío el rol semántico de error que el propio componente ya usa por defecto.

---

# No modificar en DF-07A

- ancho relativo Catalog / Editor / Preview;
- Header;
- botón `+ Add field`;
- `Refresh` / `Close`;
- backend;
- `DraftDefinition`;
- Save real;
- Active/Inactive real;
- OptionsJson;
- Comments;
- Review Progress;
- Custom Field Values;
- Dirty Guard;
- paleta global.

# Validación mínima

1. Abrir el modal con un proyecto real.
2. Pulsar `+ Add field`.
3. Escribir `Impact Score` en `Field label`.
4. Confirmar que `Internal key` muestra automáticamente `impact_score` y no es editable.
5. Confirmar que `Save` y `Cancel` se ven completos en la altura actual de Studio.
6. Validar lo mismo con tipo `Choice` y `MultiChoice`; `Options` no debe solaparse con la barra inferior.
7. Confirmar que los toggles tienen menor peso visual y siguen operativos.
8. Cambiar `Active only / Show inactive` y confirmar que el catálogo filtra igual que antes.
9. Seleccionar una definición existente y confirmar que el key permanece bloqueado al cambiar Label.
10. Confirmar que el subtítulo superior muestra `ProjectCode · ProjectName` cuando exista contexto real.
11. Confirmar que no aparecen errores de nombre o fórmula.

## Estado esperado tras validación

```text
INTERNAL KEY UX          FUNCTIONAL_FROZEN
FORM VERTICAL LAYOUT     VISUAL_APPROVED
TOGGLE DENSITY           VISUAL_APPROVED
CATALOG DENSITY          VISUAL_APPROVED
READABILITY              VISUAL_APPROVED
PROJECT CONTEXT          FUNCTIONAL_FROZEN
BACKEND                   UNCHANGED / FROZEN
COLOR                     PENDING
```
