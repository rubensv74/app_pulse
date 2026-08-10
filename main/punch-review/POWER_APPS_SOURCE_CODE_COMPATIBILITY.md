# Power Apps Source Code — Registro de compatibilidad y errores conocidos

## Objetivo

Este documento es una lista operativa de errores ya detectados al importar o pegar YAML con el esquema **Power Apps Source Code**. Debe consultarse antes de crear o modificar cualquier bloque de pantalla o componente.

No es un registro histórico pasivo. Cada error confirmado debe convertirse en una regla de diseño y en una comprobación previa obligatoria para los siguientes bloques.

> **GATE OBLIGATORIO PRE-YAML:** antes de redactar, crear, corregir o publicar cualquier archivo `.pa.yaml`, el agente debe leer primero la versión actual de este documento y aplicar todas sus reglas. No es suficiente recordarlas de conversaciones anteriores. La consulta debe realizarse contra el archivo vigente del repositorio.

---

## Reglas obligatorias antes de entregar YAML

1. Consultar este archivo desde el repositorio inmediatamente antes de redactar cualquier YAML.
2. Confirmar el tipo y la versión exacta de cada control, por ejemplo `Label@2.5.1` o `Classic/Button@2.2.0`.
3. No trasladar propiedades entre controles por similitud visual.
4. Comparar las propiedades utilizadas con controles del mismo tipo que ya estén funcionando en `main/screens` o `main/components`.
5. Buscar en el bloque propiedades ya registradas como incompatibles.
6. Mantener separados los radios visuales del contenedor y el texto interior: cuando una etiqueta necesite aspecto de píldora, usar un `GroupContainer` o un botón compatible como fondo y colocar la etiqueta dentro.
7. Tras cada error de importación, corregir el bloque fuente del repositorio; no limitarse a dar una corrección manual en Studio.
8. Anotar el error, su causa, la corrección y una regla preventiva en este documento.
9. Todo tipo de control que aparezca por primera vez en Punch Review debe considerarse **pendiente de validación en Studio** hasta completar una importación real sin errores.
10. No utilizar `Reset()` sobre un control sin confirmar que implementa el contrato de control reseteable.
11. Las variables reservadas para valores numéricos no deben inicializarse únicamente con `Blank()` si todavía no existe otra asignación que establezca su tipo.
12. Antes de usar `Control: CanvasComponent`, confirmar que el componente existe realmente dentro de la app abierta en Power Apps Studio. La existencia de un archivo del componente en GitHub no demuestra que ese componente esté instalado en la app.
13. Si no puede demostrarse la presencia del componente en la app activa, usar controles nativos/autocontenidos o convertir la instalación del componente en un bloque previo independiente y validarlo antes de crear su instancia.

---

## Matriz de propiedades y patrones confirmados como incompatibles

| Control o patrón | Incompatibilidad | Error | Alternativa segura |
|---|---|---|---|
| `Label@2.5.1` | `RadiusBottomLeft` | `PA2108` | Aplicar el radio a un `GroupContainer@1.5.0` o a un botón de fondo |
| `Label@2.5.1` | `RadiusBottomRight` | `PA2108` | Aplicar el radio a un `GroupContainer@1.5.0` o a un botón de fondo |
| `Label@2.5.1` | `RadiusTopLeft` | `PA2108` | Aplicar el radio a un `GroupContainer@1.5.0` o a un botón de fondo |
| `Label@2.5.1` | `RadiusTopRight` | `PA2108` | Aplicar el radio a un `GroupContainer@1.5.0` o a un botón de fondo |
| `Classic/Button@2.2.0` | `AccessibleLabel` | `PA2108` | No declarar la propiedad en este tipo de control; verificar alternativas soportadas en Studio |
| `TabList@2.2.30` | `Reset(tabListControl)` | Error de fórmula: el control no es reseteable | Controlar idioma mediante variable y conservar la selección durante la sesión |
| Variable numérica nueva | Leerla con `IsBlank()` y asignarle solo `Blank()` | Nombre no reconocido / tipo no establecido | Inicializar directamente con un valor numérico centinela, por ejemplo `0` |
| `CanvasComponent` | Instanciar un componente que solo existe como archivo en GitHub pero no en la app activa | `PA2301` | Verificar que el componente está instalado en Studio o usar una implementación autocontenida con controles nativos |

---

## Incidente PR-SC-001 — Radios no soportados en `Label@2.5.1`

**Fecha:** 2026-08-06  
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

### Causa

Se trató una etiqueta clásica como si admitiera las propiedades de radio disponibles en otros controles. El hecho de que una propiedad exista en `ModernText`, botones o contenedores no implica que forme parte del contrato de `Label@2.5.1`.

### Corrección aplicada

Se eliminaron las cuatro propiedades de radio de `lblPR_RowStatus`. La etiqueta conserva `Fill`, `Color`, alineación y tamaño. Cuando sea necesario recuperar una píldora perfectamente redondeada, se debe introducir un contenedor de fondo compatible en un bloque posterior.

### Regla preventiva

Nunca declarar propiedades `Radius*` directamente en `Label@2.5.1`.

---

## Incidente PR-SC-002 — `AccessibleLabel` no soportado en botón clásico

**Origen:** corrección anterior de `cmp_KpiCardPro`.

### Error

```text
PA2108 : Unknown property 'AccessibleLabel' for control type 'Classic/Button@2.2.0'.
```

### Regla preventiva

No declarar `AccessibleLabel` en `Classic/Button@2.2.0` sin comprobar antes que la versión concreta del control lo soporte en Source Code.

---

## Incidente PR-SC-003 — `TabList@2.2.30` no admite `Reset()`

**Fecha:** 2026-08-06  
**Bloque afectado:** `08A_help_trigger.add-child.pa.yaml`  
**Control origen:** `icoPR_OpenHelp`  
**Control pasado a Reset:** `tabPR_HelpLanguage`  
**Session ID:** no disponible; error detectado mediante validación inline de Studio.

### Error

```text
The function expects a resettable control as its input.
```

### Causa

El control moderno `TabList@2.2.30` acepta las propiedades empleadas para mostrar y cambiar las pestañas, pero no implementa el contrato requerido por la función `Reset()`.

### Corrección aplicada

Se eliminó:

```powerfx
Reset(tabPR_HelpLanguage)
```

El trigger ahora ejecuta únicamente:

```powerfx
Set(varPunchReviewHelpVisible, true)
```

`OnVisible` inicializa el idioma en español cuando se entra en la pantalla. Mientras el usuario permanece en ella, el modal conserva la última pestaña seleccionada al cerrarse y volver a abrirse.

### Regla preventiva

No asumir que todos los controles modernos son reseteables. Antes de usar `Reset(control)`, comprobar el comportamiento real en Studio.

---

## Incidente PR-SC-004 — Variable numérica no reconocida al inicializarse con `Blank()`

**Fecha:** 2026-08-06  
**Bloque afectado:** `04_runtime_state.onvisible.pa.yaml`  
**Variable:** `varPunchReviewPendingIndex`  
**Session ID:** no disponible; error detectado mediante validación inline de Studio.

### Error

```text
Name isn't valid. 'varPunchReviewPendingIndex' isn't recognized.
```

### Causa

La variable estaba reservada para almacenar un índice numérico futuro, pero su primera aparición era:

```powerfx
If(
    IsBlank(varPunchReviewPendingIndex),
    Set(varPunchReviewPendingIndex, Blank())
)
```

La lectura se producía antes de disponer de una asignación numérica inequívoca y `Blank()` no establecía por sí solo el tipo esperado.

### Corrección aplicada

Se sustituyó por una inicialización directa y tipada:

```powerfx
Set(varPunchReviewPendingIndex, 0)
```

El valor `0` funciona como centinela y significa que no existe todavía una navegación pendiente.

### Regla preventiva

Para una variable nueva que representa un índice, contador o identificador numérico:

- establecer primero un valor numérico;
- utilizar `0` como centinela cuando sea compatible con el dominio;
- no leer la variable con `IsBlank()` antes de que exista una asignación tipada.

---

## Incidente PR-SC-005 — Un componente en GitHub no implica que exista en la app activa

**Fecha:** 2026-08-10  
**Bloque afectado:** `11_review_progress.replace-control.pa.yaml`  
**Línea reportada:** `(46,3)`  
**Componente solicitado:** `cmp_DonutPro`  
**Session ID:** `9e5d3ba4-0716-4059-a016-6842e8ebde1b`

### Error

```text
PA2301 : Could not find Canvas Component with name 'cmp_DonutPro'.
```

Studio añadió además:

```text
Make sure to use the Source Code schema, which is the only supported format.
```

### Causa

El repositorio contiene la definición fuente:

```text
main/components/cmp_DonutPro.pa.yaml
```

pero el Bloque 11 asumió incorrectamente que esa existencia en GitHub demostraba que `cmp_DonutPro` también estaba instalado en la app actualmente abierta en Power Apps Studio.

Una instancia declarada como:

```yaml
Control: CanvasComponent
ComponentName: cmp_DonutPro
```

solo puede resolverse si Power Apps Studio conoce ya esa definición de componente dentro de la propia app. Source Code no importa automáticamente un componente externo solo porque exista un archivo con ese nombre en el repositorio.

### Corrección aplicada

El Bloque 11 se corrige para no depender de `cmp_DonutPro`. Review Progress pasa a ser un bloque autocontenido compuesto únicamente por controles nativos ya utilizados en la app:

```text
GroupContainer@1.5.0
Image@2.2.3
Label@2.5.1
Rectangle@2.3.0
```

El donut se genera mediante SVG en un `Image`, conservando el resultado visual y eliminando la dependencia de un componente no instalado.

### Regla preventiva

Antes de declarar cualquier `CanvasComponent`:

1. comprobar que el componente existe en el repositorio;
2. comprobar además que está realmente presente en la app activa o que ya ha sido validado mediante una instancia funcional en esa misma app;
3. si no puede demostrarse el punto 2, no instanciarlo directamente;
4. usar controles nativos/autocontenidos o crear primero un bloque independiente de instalación/importación del componente y validarlo;
5. registrar en la documentación cuáles componentes están **presentes en repositorio** y cuáles están **presentes y validados en la app**.

---

## Control validado PR-SC-V001 — `TabList@2.2.30`

**Fecha de introducción:** 2026-08-06  
**Bloque:** `08B_bilingual_help_modal.add-screen-child.pa.yaml`  
**Estado:** validado para las propiedades listadas; no reseteable mediante `Reset()`.

### Propiedades validadas en Studio

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

### Regla de uso

- utilizarlo como conjunto real de pestañas;
- controlar el contenido mediante `Selected` y una variable de idioma o sección;
- no llamar a `Reset()` sobre el control;
- no añadir propiedades no verificadas sin una nueva validación.

---

## Patrón visual seguro para una etiqueta tipo píldora

Cuando se necesite una etiqueta redondeada:

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

## Checklist previo para nuevos bloques

Antes de guardar un nuevo archivo `.pa.yaml`:

- [ ] He leído la versión actual de este archivo inmediatamente antes de redactar el YAML.
- [ ] No existe ninguna propiedad `Radius*` dentro de un `Label@2.5.1`.
- [ ] No existe `AccessibleLabel` dentro de un `Classic/Button@2.2.0`.
- [ ] No existe `Reset()` sobre un control que no haya sido confirmado como reseteable.
- [ ] Las variables nuevas tienen una primera asignación que establece su tipo.
- [ ] Los índices y contadores usan un valor numérico centinela cuando corresponde.
- [ ] Cada propiedad compleja aparece en al menos un control equivalente ya validado en el repositorio.
- [ ] Los placeholders usan propiedades mínimas y conocidas.
- [ ] Los bloques no mezclan propiedades de controles modernos, clásicos y canvas sin verificación.
- [ ] Todo control nuevo está registrado como pendiente de validación.
- [ ] Toda instancia `CanvasComponent` corresponde a un componente confirmado dentro de la app activa, no solo en GitHub.
- [ ] La operación de inserción o sustitución está documentada al principio del archivo.
- [ ] Existe una prueba mínima y un resultado esperado.

---

## Procedimiento cuando aparezca un nuevo error

1. Detener el siguiente bloque.
2. Registrar el mensaje completo, líneas, control, versión y Session ID cuando esté disponible.
3. Corregir el archivo fuente en `main`.
4. Buscar el mismo patrón en el resto de bloques pendientes.
5. Añadir la propiedad o patrón a la matriz de incompatibilidades.
6. Releer este documento antes de redactar el YAML corregido.
7. Solo continuar cuando el bloque corregido haya sido validado en Studio.
