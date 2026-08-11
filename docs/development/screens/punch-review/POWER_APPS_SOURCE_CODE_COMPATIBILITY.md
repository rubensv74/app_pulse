# Power Apps Source Code — Registro de compatibilidad y lecciones aprendidas

## Objetivo

Este documento es una lista operativa de errores, incompatibilidades y decisiones de implementación confirmadas al importar o pegar YAML con el esquema **Power Apps Source Code**.

No es un registro histórico pasivo. Cada error confirmado debe convertirse en una regla de diseño y en una comprobación preventiva para los siguientes bloques.

> **GATE OBLIGATORIO PRE-YAML:** antes de redactar, crear, corregir o publicar cualquier archivo `.pa.yaml`, el agente debe leer primero la versión actual de este documento y aplicar todas sus reglas. No es suficiente recordarlas de conversaciones anteriores. La consulta debe realizarse contra el archivo vigente del repositorio.

---

## Reglas obligatorias antes de entregar YAML

1. Consultar este archivo desde el repositorio inmediatamente antes de redactar cualquier YAML.
2. Confirmar el tipo y la versión exacta de cada control.
3. No trasladar propiedades entre controles por similitud visual.
4. Comparar propiedades con controles equivalentes ya utilizados en `main/screens` o `main/components`.
5. Buscar en el bloque patrones ya registrados como incompatibles.
6. No declarar `Radius*` directamente en `Label@2.5.1`.
7. No declarar `AccessibleLabel` en `Classic/Button@2.2.0` en el Source Code actual de PULSE.
8. No utilizar `Reset()` sobre un control sin haber confirmado que es reseteable.
9. Las variables numéricas nuevas deben recibir primero una asignación numérica inequívoca.
10. Antes de usar `Control: CanvasComponent`, confirmar dos cosas por separado: que la definición existe en el repositorio y que el componente está realmente presente en la app activa de Power Apps Studio.
11. Si un componente no está instalado en la app activa, su existencia en GitHub no permite instanciarlo desde un bloque de pantalla.
12. Los bloques de pantalla de PULSE no deben introducir SVG inline como sustituto improvisado de un componente visual cuando exista un componente validado o instalable para ese propósito. El rendering SVG directo en pantalla ha resultado poco fiable para este caso.
13. Tras cada error de importación, corregir el archivo fuente del repositorio; no limitarse a dar una corrección manual en Studio.
14. Registrar mensaje de error, causa, corrección, Session ID y regla preventiva.
15. Todo control o componente nuevo debe considerarse pendiente de validación hasta que Power Apps Studio lo acepte.
16. Para construir JSON desde valores Power Fx, evitar secuencias manuales de escape con barras invertidas y comillas. Preferir `JSON(valor, JSONFormat.Compact)` y componer estructuras mayores a partir de esos fragmentos serializados.
17. Un archivo `.pa.yaml` destinado a pegarse en el editor Source Code debe tener una raíz válida para el contexto (`ComponentDefinitions`, pantalla/módulo completo o lista de controles esperada). No publicar como `.pa.yaml` un mapa conceptual de parches con nombres de controles en la raíz; ese formato no es un `PaModule` válido.

---

## Matriz de incompatibilidades y decisiones confirmadas

| Control o patrón | Incompatibilidad / riesgo | Error | Alternativa segura |
|---|---|---|---|
| `Label@2.5.1` | `RadiusBottomLeft` | `PA2108` | Aplicar radios a `GroupContainer@1.5.0` |
| `Label@2.5.1` | `RadiusBottomRight` | `PA2108` | Aplicar radios a `GroupContainer@1.5.0` |
| `Label@2.5.1` | `RadiusTopLeft` | `PA2108` | Aplicar radios a `GroupContainer@1.5.0` |
| `Label@2.5.1` | `RadiusTopRight` | `PA2108` | Aplicar radios a `GroupContainer@1.5.0` |
| `Classic/Button@2.2.0` | `AccessibleLabel` | `PA2108` | No declarar la propiedad en esta versión |
| `TabList@2.2.30` | `Reset(tabListControl)` | Error de fórmula | Controlar selección mediante variable |
| Variable numérica nueva | Primera asignación solo con `Blank()` | Nombre/tipo no establecido | Inicializar con valor numérico, por ejemplo `0` |
| `CanvasComponent` | Componente presente solo en GitHub, no en la app | `PA2301` | Instalar el componente primero o no instanciarlo |
| SVG inline en bloque de pantalla | Renderizado visual poco fiable en este caso | Problema visual | Preferir componente premium instalado y validado |
| Construcción manual de JSON con `\"`/barras invertidas en Power Fx | El parser puede interpretar mal las comillas y romper la aridad de funciones | `Invalid number of arguments` | Serializar cada valor con `JSON(..., JSONFormat.Compact)` |
| Mapa de parches con `controlName:` en la raíz de un `.pa.yaml` pegado como módulo | La raíz no pertenece al esquema `PaModule`; el parser intenta tratar el nombre del control como una propiedad del módulo | `PA1001 / YamlInvalidSyntax` | Entregar módulo completo válido o una guía `.md` de cambios de propiedades; no pegar el mapa como Source Code |

---

## Incidente PR-SC-001 — Radios no soportados en `Label@2.5.1`

**Bloque afectado:** `05_review_queue.replace-control.pa.yaml`  
**Control:** `lblPR_RowStatus`  
**Session ID:** `b7041b18-005b-45b7-a530-b1fd350d1b11`

### Error

```text
PA2108 : Unknown property 'RadiusBottomLeft' for control type 'Label@2.5.1'.
PA2108 : Unknown property 'RadiusBottomRight' for control type 'Label@2.5.1'.
PA2108 : Unknown property 'RadiusTopLeft' for control type 'Label@2.5.1'.
PA2108 : Unknown property 'RadiusTopRight' for control type 'Label@2.5.1'.
```

### Regla preventiva

Para píldoras o badges redondeados:

```text
GroupContainer@1.5.0
└── Label@2.5.1
```

El contenedor gestiona los radios y la etiqueta únicamente el texto.

---

## Incidente PR-SC-002 — `AccessibleLabel` no soportado en botón clásico

### Error

```text
PA2108 : Unknown property 'AccessibleLabel' for control type 'Classic/Button@2.2.0'.
```

### Regla preventiva

No declarar `AccessibleLabel` en `Classic/Button@2.2.0` sin confirmar que una versión posterior del Source Code lo soporte.

---

## Incidente PR-SC-003 — `TabList@2.2.30` no admite `Reset()`

**Bloque afectado:** `08A_help_trigger.add-child.pa.yaml`  
**Control:** `tabPR_HelpLanguage`

### Error

```text
The function expects a resettable control as its input.
```

### Corrección

Se eliminó:

```powerfx
Reset(tabPR_HelpLanguage)
```

La selección de idioma se controla mediante variable.

### Regla preventiva

No asumir que un control moderno es reseteable por el mero hecho de tener estado seleccionable.

---

## Incidente PR-SC-004 — Variable numérica no reconocida al inicializarse con `Blank()`

**Bloque afectado:** `04_runtime_state.onvisible.pa.yaml`  
**Variable:** `varPunchReviewPendingIndex`

### Error

```text
Name isn't valid. 'varPunchReviewPendingIndex' isn't recognized.
```

### Corrección

```powerfx
Set(varPunchReviewPendingIndex, 0)
```

### Regla preventiva

Los índices, contadores e identificadores numéricos deben recibir primero una asignación numérica clara.

---

## Incidente PR-SC-005 — Componente presente en GitHub pero ausente de la app

**Fecha:** 2026-08-10  
**Bloque afectado:** `11_review_progress.replace-control.pa.yaml`  
**Línea reportada:** `(46,3)`  
**Componente:** `cmp_DonutPro`  
**Session ID:** `9e5d3ba4-0716-4059-a016-6842e8ebde1b`

### Error

```text
PA2301 : Could not find Canvas Component with name 'cmp_DonutPro'.
```

### Causa

La definición existía en:

```text
main/components/cmp_DonutPro.pa.yaml
```

pero el componente todavía no estaba añadido a la biblioteca de componentes de la app activa.

Una declaración como:

```yaml
Control: CanvasComponent
ComponentName: cmp_DonutPro
```

solo funciona cuando Studio conoce ya esa definición dentro de la propia app.

### Resolución definitiva

El componente `cmp_DonutPro` ha sido incorporado posteriormente a la biblioteca de componentes de la app activa.

Por tanto, desde este momento el Bloque 11 puede volver a utilizar:

```yaml
Control: CanvasComponent
ComponentName: cmp_DonutPro
```

La regla preventiva no cambia: para cualquier otro componente futuro hay que confirmar primero su presencia real en la app.

### Estado

```text
RESUELTO — cmp_DonutPro confirmado en la app activa.
```

---

## Incidente PR-SC-006 — Escape manual de JSON rompe la fórmula MultiChoice

**Fecha:** 2026-08-11  
**Bloque afectado:** `docs/development/components/custom-field-editor-pro/blocks/03_field_renderers.pa.yaml`  
**Control:** `cmbCFEPro_Choice`  
**Propiedad:** `OnChange`  
**Session ID:** no facilitado; error confirmado mediante captura de Power Apps Studio.

### Error

```text
Invalid number of arguments: received 1, expected 2.
```

Studio marcó la expresión usada para construir manualmente el JSON de `MultiChoice`, concretamente la combinación de `Concat` con cadenas de comillas y `Substitute` expresadas mediante secuencias con barras invertidas.

### Causa

Power Fx no debe tratarse como JavaScript/C# para escapar cadenas. La construcción manual con patrones del tipo `\"` dentro de YAML puede acabar alterando cómo el parser interpreta los delimitadores de texto y, como consecuencia, la aridad aparente de `Concat`, `Substitute` u otras funciones cercanas.

### Corrección

El bloque CF-03 deja de escapar las comillas manualmente. Cada valor seleccionado se serializa con:

```powerfx
JSON(Value, JSONFormat.Compact)
```

y `Concat` une esos fragmentos dentro de los corchetes del array.

Conceptualmente:

```powerfx
"[" &
Concat(
    Self.SelectedItems,
    JSON(Value, JSONFormat.Compact),
    ","
) &
"]"
```

Así, valores como `Material` y `Engineering` producen el contrato esperado:

```json
["Material","Engineering"]
```

sin gestionar manualmente las comillas ni caracteres de escape.

### Regla preventiva

Para cualquier YAML/Power Fx futuro:

- no trasladar sintaxis de escape de JavaScript, C#, JSON textual o lenguajes similares a una fórmula Power Fx;
- cuando el objetivo sea serializar un valor a JSON, usar la función `JSON` de Power Fx;
- construir manualmente solo la estructura mínima que `JSON` no proporcione en el contrato requerido;
- validar específicamente Choice/MultiChoice cuando exista serialización de colecciones.

### Estado

```text
CORREGIDO EN REPOSITORIO — pendiente de revalidación en Studio.
```

---

## Incidente PR-SC-007 — Un mapa de parches no es un módulo Source Code válido

**Fecha:** 2026-08-11  
**Bloque afectado:** `docs/development/components/custom-field-values-pro/blocks/05_visual_polish.incremental-patch.pa.yaml`  
**Primera clave reportada:** `conCFVPro_Header`  
**Línea reportada:** `(53,1)`  
**Session ID:** no facilitado; error confirmado mediante captura de Power Apps Studio.

### Error

```text
PA1001 : An error occurred while parsing PaYaml.
Error code: YamlInvalidSyntax.
Reason: Property 'conCFVPro_Header' not found on type
'Microsoft.PowerPlatform.PowerApps.Persistence.PaYaml.Models.SchemaV3.PaModule'.
```

### Causa

El archivo VF-05 fue publicado como un **mapa conceptual de cambios de propiedades**:

```text
conCFVPro_Header:
  Properties:
    ...
```

Ese formato es útil como documentación de diff, pero **no es una raíz válida de Power Apps Source Code**. Al pegarlo en el editor Source Code del componente, Studio intenta interpretar `conCFVPro_Header` como si fuera una propiedad de `PaModule`, por lo que falla antes de evaluar las propiedades internas.

### Corrección

- retirar el artefacto `.pa.yaml` de parche conceptual como archivo pegable;
- entregar estos ajustes como guía `.md` de cambios de propiedades o como un módulo/componente completo con raíz válida;
- no pedir al usuario que pegue un mapa de parches en Source Code.

### Regla preventiva

Antes de publicar cualquier `.pa.yaml`, clasificar explícitamente el artefacto como uno de estos formatos:

1. **módulo/componente completo pegable**, con raíz válida;
2. **control completo pegable** solo cuando el contexto de Studio acepte esa forma y haya sido validado;
3. **guía de modificación**, que debe usar `.md`/`.txt` y nunca presentarse como `.pa.yaml` pegable.

Si el contenido solo enumera `control -> Properties`, debe ser una guía, no un archivo Source Code.

### Estado

```text
CORREGIDO EN REPOSITORIO — VF-05 se reemite como guía de propiedades, pendiente de revalidación visual.
```

---

## Lección PR-UX-001 — Evitar SVG inline en bloques de pantalla

**Fecha:** 2026-08-10  
**Contexto:** corrección provisional del Bloque 11.

### Hallazgo

La alternativa autocontenida que generaba un donut mediante SVG en `Image@2.2.3` no ofrece un renderizado suficientemente fiable para esta pantalla.

### Decisión

En Punch Review y, por defecto, en nuevas pantallas PULSE:

- no introducir SVG inline en el YAML de pantalla para sustituir un componente visual disponible;
- preferir componentes premium instalados y validados;
- si un componente necesario todavía no está presente en la app, convertir su incorporación en un paso previo explícito;
- no degradar automáticamente a una solución SVG solo para evitar una dependencia de componente.

Esta regla se refiere al YAML de la pantalla. La implementación interna encapsulada de un componente reutilizable se trata como responsabilidad del propio componente.

---

## Control validado PR-SC-V001 — `TabList@2.2.30`

**Estado:** validado para las propiedades utilizadas en Punch Review; no reseteable mediante `Reset()`.

### Propiedades validadas

```text
Items
DefaultSelectedItems
Selected
OnChange
Height
Width
X
Y
```

---

## Componente confirmado PR-CMP-V001 — `cmp_DonutPro`

**Fecha de confirmación en la app activa:** 2026-08-10  
**Definición fuente:** `main/components/cmp_DonutPro.pa.yaml`

### Estado

```text
INSTALADO EN LA APP ACTIVA — puede instanciarse como CanvasComponent.
```

### Contrato relevante para Review Progress

```text
Items:
  SegmentKey
  SegmentLabel
  SegmentValue
  SegmentColor
  SegmentOrder

Inputs utilizados:
  AccentColor
  BackgroundColor
  BorderColor
  CenterFillColorHex
  CenterLabel
  CenterLabelColorHex
  CenterValueColorHex
  CenterValueText
  CompactMode
  DangerColor
  DonutThickness
  EmptyText
  EnableSelection
  ErrorText
  Items
  LoadingText
  MutedTextColor
  PercentageFormat
  SegmentGapPercent
  ShowLegend
  ShowPercentages
  ShowValues
  ShowZeroSegments
  State
  Subtitle
  SurfaceAltColor
  TextColor
  Title
  TrackColorHex
  ValueFormat
  ValueSuffix
```

---

## Patrón visual seguro para una etiqueta tipo píldora

```text
conStatusPill: GroupContainer@1.5.0
└── lblStatusText: Label@2.5.1
```

El contenedor gestiona:

```text
Fill
BorderColor
BorderThickness
RadiusBottomLeft
RadiusBottomRight
RadiusTopLeft
RadiusTopRight
```

La etiqueta gestiona:

```text
Text
Color
Align
Font
FontWeight
Size
Padding
```

---

## Checklist previo para nuevos bloques YAML

Antes de guardar cualquier `.pa.yaml`:

- [ ] He leído la versión actual de este archivo inmediatamente antes de redactar el YAML.
- [ ] He confirmado tipo y versión de cada control.
- [ ] He confirmado que la raíz del archivo corresponde al contexto Source Code real; no es un mapa conceptual de parches.
- [ ] No existe ninguna propiedad `Radius*` dentro de un `Label@2.5.1`.
- [ ] No existe `AccessibleLabel` dentro de un `Classic/Button@2.2.0`.
- [ ] No existe `Reset()` sobre un control no confirmado como reseteable.
- [ ] Las variables nuevas tienen una primera asignación que establece su tipo.
- [ ] Cada propiedad compleja aparece en un control equivalente ya validado o en el contrato fuente del componente.
- [ ] Toda instancia `CanvasComponent` corresponde a un componente confirmado dentro de la app activa.
- [ ] No se introduce SVG inline como sustituto de un componente visual instalado o instalable.
- [ ] La serialización JSON no usa cadenas de escape manuales cuando `JSON(..., JSONFormat.Compact)` resuelve el contrato.
- [ ] La operación de inserción o sustitución está documentada al principio del archivo.
- [ ] Existen prueba mínima y resultado esperado.

---

## Procedimiento cuando aparezca un nuevo error

1. Detener el siguiente bloque.
2. Registrar mensaje completo, líneas, control, versión y Session ID.
3. Corregir el archivo fuente en `main`.
4. Buscar el mismo patrón en bloques pendientes.
5. Convertir el error en una nueva regla preventiva.
6. Releer este documento antes de redactar el YAML corregido.
7. Solo continuar cuando Studio valide el bloque corregido.