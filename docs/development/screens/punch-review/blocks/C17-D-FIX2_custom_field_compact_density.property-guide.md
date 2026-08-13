# C17-D-FIX2 — Custom Field Values compact density

**Estado:** PENDING STUDIO VALIDATION  
**Componente:** `cmp_CustomFieldValuesPro`  
**Tipo:** property-only visual density adjustment  
**Objetivo único:** reducir la escala visual de los renderers de Custom Fields para alinearlos con la densidad real de Punch Review, sin tocar backend, dirty state ni contratos.

## Diagnóstico

El Source Code actual usa filas de `48 px` y controles de `34 px`. Además, los controles modernos no fijan tamaño tipográfico, por lo que heredan el tamaño Fluent por defecto, claramente mayor que los labels de fila (`Size = 8`). Esto hace que Text, Number, Date y especialmente Choice/MultiChoice dominen visualmente la tarjeta.

La pantalla Punch Review utiliza una densidad visual claramente menor en botones, badges, header selectors y metadata. El panel de Custom Fields debe comportarse como un editor compacto integrado, no como un formulario independiente de gran tamaño.

## Principio de diseño

Target visual:

```text
Row height        42 px
Input height      30 px
Input text size    9 pt
Label size         8 pt  (se mantiene)
Vertical offset    6 px
```

No reducir por debajo de estos valores en este bloque. Primero validar legibilidad y hit targets reales en Studio.

---

## 1. Gallery density

Target:

`cmp_CustomFieldValuesPro → conCFVPro_Root → conCFVPro_Body → galCFVPro_Values`

### `TemplateSize`

Cambiar de:

```powerfx
=48
```

A:

```powerfx
=42
```

No modificar `TemplatePadding`.

---

## 2. Text renderer

Target: `txtCFVPro_Text`

### `Height`

```powerfx
=30
```

### `Y`

```powerfx
=6
```

### `Size`

```powerfx
=9
```

Mantener `Appearance = Appearance.Outline`.

---

## 3. Number renderer

Target: `numCFVPro_Number`

### `Height`

```powerfx
=30
```

### `Y`

```powerfx
=6
```

### `Size`

```powerfx
=9
```

Mantener `Appearance = Appearance.Outline` y el `Default` numérico actual.

---

## 4. Date renderer

Target: `dpCFVPro_Date`

### `Height`

```powerfx
=30
```

### `Y`

```powerfx
=6
```

### `Size`

```powerfx
=9
```

Mantener `Appearance = Appearance.Outline`.

Si Studio no expone `Size` para la versión exacta `ModernDatePicker@1.0.1`, no forzar la propiedad desde Source Code: aplicar solo `Height = 30` y `Y = 6`, y registrar el resultado visual antes de cualquier sustitución de control.

---

## 5. Choice / MultiChoice renderer

Target: `cmbCFVPro_Choice`

### `Height`

```powerfx
=30
```

### `Y`

```powerfx
=6
```

### `Size`

```powerfx
=9
```

Mantener:

- `Appearance = Appearance.Outline`;
- `Items`;
- `ItemDisplayText`;
- `DefaultSelectedItems`;
- `DisplayMode` de C17-D-FIX1;
- `OnChange`;
- `SelectMultiple`;
- `IsSearchable`.

---

## 6. Yes/No renderer

Target: `tglCFVPro_YesNo`

### `Height`

```powerfx
=30
```

### `Y`

```powerfx
=6
```

### `Width`

Cambiar el ancho full-row actual por:

```powerfx
=120
```

El Toggle no necesita ocupar todo el ancho de la columna de valores. Mantener visible `Yes / No` para no depender únicamente de la posición del switch.

No introducir propiedades tipográficas adicionales en `Toggle@1.1.5` durante este FIX salvo que Studio las exponga explícitamente.

---

## 7. Width de inputs

No estrechar todavía Text / Number / Date / Choice / MultiChoice. El problema principal observado es de altura y tipografía, no de contrato horizontal.

Mantener:

```powerfx
=Parent.Width - lblCFVPro_FieldLabel.Width - 26
```

Así aislamos el efecto de densidad y evitamos mezclar dos variables visuales en el mismo FIX.

---

## No tocar

No modificar:

- `lblCFVPro_FieldLabel.Size`;
- `lblCFVPro_FieldLabel.Width`;
- header;
- footer;
- Save / Cancel;
- Manage / Refresh;
- `colCFVPro_Base`;
- `colCFVPro_Working`;
- `colCFVPro_Dirty`;
- `OnChange` de ningún renderer;
- host `conPR_CustomFieldsHost`;
- Comments;
- Review Progress;
- Session Activity;
- backend.

---

## Validación Studio

Validar con un Punch que tenga los seis tipos:

1. Text, Number, Date, YesNo, Choice y MultiChoice deben verse visualmente pertenecientes al mismo sistema.
2. Los inputs no deben dominar sobre labels, Punch Overview o Comments.
3. Choice/MultiChoice deben seguir mostrando opciones completas.
4. Date icon y Number steppers no deben quedar recortados.
5. Toggle debe seguir siendo claramente clicable y legible.
6. Focus visible debe seguir siendo perceptible.
7. Dirty / Save / Cancel deben comportarse exactamente igual.
8. Gallery scroll debe seguir estable.
9. Cero clipping y cero errores nuevos.

## Criterio de aprobación

El componente pasa este FIX cuando se percibe como un panel de propiedades compacto integrado en Punch Review, no como un formulario de gran tamaño embebido dentro de la pantalla.