# C17-D — Auditoría de renderers de Custom Field Values

**Tipo:** `C/AUDIT — Component evolution / visual-functional audit`  
**Pantalla consumidora:** `scr_PunchReview`  
**Componente:** `cmp_CustomFieldValuesPro`  
**Fecha:** 2026-08-13  
**Estado:** READY FOR IMPLEMENTATION

## Objetivo

Cerrar los defectos visuales y funcionales observados en Studio dentro de la tarjeta **Custom Fields** antes del cierre C17-E.

Esta auditoría se basa en:

- la captura de Studio posterior a C17-C-FIX1;
- el Source Code completo vigente de `scr_PunchReview` facilitado desde Studio;
- el baseline `VF-03 — cmp_CustomFieldValuesPro EDITING + DIRTY STATE`;
- el polish VF-05 ya aplicado;
- la presencia demostrada de `ModernCombobox@1.1.1` en la pantalla activa (`cmbPR_Template`, `cmbPR_QueueScope`).

No se modifica backend, dirty state ni contrato público del componente.

---

## Hallazgo 1 — Choice/MultiChoice usa un control legacy

El renderer actual utiliza:

```text
Classic/ComboBox@2.4.0
```

mientras Text, Number, Date y YesNo ya utilizan controles modernos.

Esto produce una ruptura clara del lenguaje visual Fluent/PULSE:

- chevron y flyout con estética legacy;
- borde/foco visual distinto;
- densidad distinta al resto de inputs;
- dropdown demasiado pesado respecto al panel;
- comportamiento visual inconsistente con los ModernCombobox ya usados en la propia pantalla.

### Decisión

Sustituir `cmbCFVPro_Choice` por `ModernCombobox@1.1.1`, conservando el mismo nombre lógico para reducir impacto en fórmulas.

---

## Hallazgo 2 — El dropdown tiene filas, pero no muestra texto

La captura de Studio al abrir `Level Criticity` muestra un flyout con scrollbar y filas visualmente vacías. Esto demuestra que el control recibe una colección/lista con registros, pero el texto de presentación no está resuelto correctamente.

El source vigente confirma:

```text
Items -> tabla de registros {Value: ...}
SearchFields -> ["Value"]
DisplayFields -> no declarado
```

En un ComboBox clásico, `SearchFields` no define por sí solo qué campo se renderiza como texto principal. La visualización depende de la configuración de campos/DisplayFields.

### Decisión

No parchear el renderer legacy añadiendo únicamente `DisplayFields`. La modernización elimina el problema de raíz mediante:

```text
ModernCombobox@1.1.1
ItemDisplayText = ThisItem.Value
```

El contrato de opciones sigue siendo una tabla con columna `Value`.

---

## Hallazgo 3 — Number rompe la consistencia visual

`txtCFVPro_Text` y `dpCFVPro_Date` ya declaran:

```text
Appearance = Appearance.Outline
```

pero `numCFVPro_Number` no declara `Appearance`, por lo que usa el estilo filled/darker por defecto. En Studio aparece como una banda gris, visualmente similar a un campo disabled aunque el usuario tenga permisos de edición.

### Decisión

Establecer:

```text
numCFVPro_Number.Appearance = Appearance.Outline
```

Así Text / Number / Date / Choice / MultiChoice comparten el mismo patrón de superficie.

---

## Hallazgo 4 — Default del Number no respeta el tipo nativo

El baseline actual declara conceptualmente:

```text
Default = Text(ValueNumber)
```

El control moderno Number Input trabaja con un valor numérico nativo. La conversión a texto introduce coerción innecesaria y debilita el contrato de tipo.

### Decisión

El default debe conservar `Blank()` cuando no exista valor y, en caso contrario, pasar `ValueNumber` como número, no como texto.

No cambia `OnChange`, dirty comparison ni payload.

---

## Hallazgo 5 — El placeholder `Find items` es demasiado genérico

`Find items` transmite búsqueda, pero no la intención de negocio. Para un editor de propiedades es más apropiado:

```text
Choice       -> Select value...
MultiChoice  -> Select one or more...
```

La búsqueda seguirá habilitada; solo cambia la microcopia.

---

## Hallazgo 6 — ComboBox clásico dentro de Gallery añade riesgo funcional

`cmbCFVPro_Choice` vive dentro de `galCFVPro_Values`, una galería vertical con scroll. Este patrón merece validación específica porque el ComboBox clásico tiene limitaciones documentadas de persistencia de selección cuando se usa dentro de galerías desplazables.

### Decisión

La sustitución por ModernCombobox debe incluir un smoke test explícito:

1. cambiar Choice;
2. cambiar MultiChoice;
3. hacer scroll suficiente para reciclar filas;
4. volver a los campos;
5. confirmar que `EditedItems`, `DirtyItems` y la selección visual siguen sincronizados.

No asumir PASS solo porque la selección inicial funcione.

---

## Hallazgo 7 — No conviene rediseñar toda la tarjeta

La geometría general de `cmp_CustomFieldValuesPro` sí funciona:

- header compacto;
- Field Label a la izquierda;
- valor/editor a la derecha;
- gallery vertical;
- footer persistente;
- Manage / Refresh;
- Saved / Unsaved / Error.

Por tanto C17-D no debe convertir cada fila en una tarjeta ni aumentar artificialmente la altura. El problema es **consistencia de renderer**, no el patrón Field → Value.

---

# Alcance C17-D

## Modificar

- `cmbCFVPro_Choice` → ModernCombobox;
- visualización explícita de opciones mediante `ItemDisplayText`;
- placeholder contextual Choice/MultiChoice;
- `numCFVPro_Number.Appearance`;
- tipo correcto de `numCFVPro_Number.Default`;
- alineación/altura común de los renderers si existe una diferencia residual.

## Mantener congelado

- `colCFVPro_Base`;
- `colCFVPro_Working`;
- `colCFVPro_Dirty`;
- `EditedItems`;
- `DirtyItems`;
- `IsDirty`;
- `DirtyCount`;
- `OnValueChanged`;
- `OnSaveRequested`;
- `OnCancelRequested`;
- JSON MultiChoice mediante `JSON(..., JSONFormat.Compact)`;
- flows host;
- Dirty Guard;
- geometría C17 de Comments / Custom Fields / Right Rail.

---

# Gate visual-funcional

C17-D solo puede cerrarse cuando Studio demuestre:

```text
TEXT            OUTLINE / PASS
NUMBER          OUTLINE / NUMERIC DEFAULT / PASS
DATE            OUTLINE / PASS
YESNO           MODERN / PASS
CHOICE          MODERN COMBO / OPTIONS VISIBLE / PASS
MULTICHOICE     MODERN COMBO / OPTIONS VISIBLE / PASS
GALLERY SCROLL  SELECTION RETAINED / PASS
DIRTY STATE     UNCHANGED / PASS
SAVE/CANCEL     UNCHANGED / PASS
NO CLIPPING     PASS
PREMIUM VISUAL  PASS
```

C17-E no comienza hasta validar este gate.