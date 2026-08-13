# C17-D — Modern Custom Field Renderers

**Tipo:** `C — Component visual-functional evolution`  
**Componente:** `cmp_CustomFieldValuesPro`  
**Formato:** guía de implementación en Studio; no es un `.pa.yaml` completo.  
**Objetivo único:** modernizar los renderers de valores sin modificar backend, dirty state ni contrato público.

## Pre-gates aplicados

Antes de preparar esta guía se han revisado de nuevo:

- `docs/development/screens/punch-review/POWER_APPS_SOURCE_CODE_COMPATIBILITY.md`;
- `30-playbooks/power-platform/modular-power-apps-screen-construction.md`;
- baseline VF-03 del componente;
- `ModernCombobox@1.1.1` ya utilizado por la app activa en Punch Review.

---

# A. Number — corregir estilo y tipo

Target:

```text
cmp_CustomFieldValuesPro
→ conCFVPro_Root
→ conCFVPro_Body
→ galCFVPro_Values
→ conCFVPro_ValueRow
→ numCFVPro_Number
```

## `Appearance`

Establecer:

```powerfx
=Appearance.Outline
```

## `Default`

Sustituir la fórmula que convierte el número a texto por:

```powerfx
=If(
    IsBlank(ThisItem.ValueNumber),
    Blank(),
    ThisItem.ValueNumber
)
```

## Mantener

- `DisplayMode`;
- `OnChange`;
- `Visible`;
- `Width`;
- `X`;
- `Y`;
- dirty comparison y patch actuales.

Resultado esperado: `Impact Score` deja de parecer disabled y usa el mismo patrón Outline que Text y Date.

---

# B. Choice / MultiChoice — sustituir el ComboBox clásico

Target actual:

```text
cmbCFVPro_Choice
Control: Classic/ComboBox@2.4.0
```

## Operación

1. Dentro de `conCFVPro_ValueRow`, elimina únicamente `cmbCFVPro_Choice`.
2. Inserta un **Combo box moderno**.
3. Renómbralo exactamente:

```text
cmbCFVPro_Choice
```

4. Configura el control con las propiedades de esta sección.

No elimines ni recrees la Gallery, la fila ni las colecciones del componente.

## Tipo esperado

```text
ModernCombobox@1.1.1
```

Esta versión ya está presente en la app activa en `cmbPR_Template` y `cmbPR_QueueScope`.

## `Appearance`

```powerfx
=Appearance.Outline
```

## `Items`

Mantener el contrato actual de opciones:

```powerfx
=ForAll(
    Table(ParseJSON(Coalesce(ThisItem.OptionsJson, "[]"))),
    {Value: Text(Value)}
)
```

## `ItemDisplayText`

Añadir explícitamente:

```powerfx
=ThisItem.Value
```

Esta propiedad es crítica. El renderer no debe depender de inferencia automática de columnas.

## `DefaultSelectedItems`

Usar una selección derivada de las mismas opciones del control:

```powerfx
=With(
    {
        _type: Lower(Trim(ThisItem.FieldType)),
        _valueText: Coalesce(ThisItem.ValueText, ""),
        _valueJson: Coalesce(ThisItem.ValueJson, "[]"),
        _options:
            ForAll(
                Table(ParseJSON(Coalesce(ThisItem.OptionsJson, "[]"))),
                {Value: Text(Value)}
            )
    },
    Switch(
        _type,
        "choice",
            If(
                IsBlank(_valueText),
                Blank(),
                Filter(_options As opt, opt.Value = _valueText)
            ),
        "multichoice",
            With(
                {
                    _selected:
                        ForAll(
                            Table(ParseJSON(_valueJson)),
                            {Value: Text(Value)}
                        )
                },
                Filter(
                    _options As opt,
                    !IsBlank(
                        LookUp(
                            _selected As sel,
                            sel.Value = opt.Value
                        )
                    )
                )
            ),
        Blank()
    )
)
```

La selección inicial queda así ligada a registros que pertenecen al mismo contrato que `Items`.

## `InputTextPlaceholder`

```powerfx
=If(
    Lower(Trim(ThisItem.FieldType)) = "multichoice",
    "Select one or more...",
    "Select value..."
)
```

## `IsSearchable`

```powerfx
=true
```

## `SelectMultiple`

Mantener:

```powerfx
=Lower(Trim(ThisItem.FieldType)) = "multichoice"
```

## `Visible`

Mantener:

```powerfx
=Lower(Trim(ThisItem.FieldType)) = "choice" ||
 Lower(Trim(ThisItem.FieldType)) = "multichoice"
```

## `DisplayMode`

Conservar la misma fórmula que hoy gobierna `cmbCFVPro_Choice`: editable solo cuando `CanEdit=true`, el registro es editable y no hay Loading/Saving.

No cambies la semántica de permisos.

## `Height`

```powerfx
=34
```

## `Width`

Mantener:

```powerfx
=Parent.Width - lblCFVPro_FieldLabel.Width - 26
```

## `X`

Mantener:

```powerfx
=lblCFVPro_FieldLabel.Width + 12
```

## `Y`

Mantener:

```powerfx
=7
```

## `OnChange`

**Conservar íntegramente la fórmula vigente de VF-03.**

El ModernCombobox expone `Selected` / `SelectedItems`, y el contrato de item sigue teniendo columna `Value`, por lo que no se cambia:

- `Self.Selected.Value` para Choice;
- `Self.SelectedItems` para MultiChoice;
- construcción `ValueJson` mediante `JSON(Value, JSONFormat.Compact)`;
- patches de `colCFVPro_Working`;
- reconciliación contra `colCFVPro_Base`;
- `colCFVPro_Dirty`;
- `varCFVPro_LastChangedFieldKey`;
- evento `OnValueChanged()`.

No reescribir esa lógica durante C17-D.

---

# C. YesNo — mantener moderno, hacer coherente la paleta

Target:

```text
tglCFVPro_YesNo
Control: Toggle@1.1.5
```

Este control **ya es moderno**. No debe sustituirse por un Toggle clásico.

Si Studio expone `BasePaletteColor` para esta versión, establecer:

```powerfx
=cmp_CustomFieldValuesPro.AccentColor
```

Mantener:

- `Checked`;
- `DisplayMode`;
- `OnCheck` / `OnUncheck` o fórmula vigente equivalente;
- label Yes/No actual;
- dirty state.

No eliminar el indicador visible `Yes/No`: el estado no debe depender solo del color o de la posición del switch.

---

# D. Text y Date — no reconstruir

`txtCFVPro_Text` y `dpCFVPro_Date` ya utilizan `Appearance.Outline`.

No sustituirlos.

Solo confirmar visualmente que mantienen:

```text
Height = 34
Y      = 7
```

El objetivo es que Text / Number / Date / Choice / MultiChoice compartan la misma altura y patrón Outline.

---

# E. Qué NO tocar

No modificar en C17-D:

- `galCFVPro_Values.TemplateSize`;
- `lblCFVPro_FieldLabel.Width`;
- `conCFVPro_Header`;
- Status pill;
- Footer;
- Save / Cancel;
- Manage / Refresh;
- Empty / Loading / Error states;
- host `conPR_CustomFieldsHost`;
- Comments;
- Review Progress;
- Session Activity;
- backend host buttons;
- DF-05 / DF-06 definition management.

---

# Resultado esperado

Visualmente:

```text
Text         Outline Fluent
Number       Outline Fluent
Date         Outline Fluent
YesNo        Modern Toggle
Choice       Modern Fluent ComboBox
MultiChoice  Modern Fluent ComboBox
```

Funcionalmente:

```text
Choice options visible
MultiChoice options visible
initial values reconciled
scroll + return retains working state
DirtyItems unchanged
Save unchanged
Cancel unchanged
```

Después de aplicar esta guía, ejecutar `C17-D_GUIA_IMPLEMENTACION_Y_VALIDACION.md` antes de C17-E.