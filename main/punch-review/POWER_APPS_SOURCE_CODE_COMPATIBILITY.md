# Power Apps Source Code — Registro de compatibilidad y errores conocidos

## Objetivo

Este documento es una lista operativa de errores ya detectados al importar o pegar YAML con el esquema **Power Apps Source Code**. Debe consultarse antes de crear o modificar cualquier bloque de pantalla o componente.

No es un registro histórico pasivo. Cada error confirmado debe convertirse en una regla de diseño y en una comprobación previa obligatoria para los siguientes bloques.

---

## Reglas obligatorias antes de entregar YAML

1. Confirmar el tipo y la versión exacta de cada control, por ejemplo `Label@2.5.1` o `Classic/Button@2.2.0`.
2. No trasladar propiedades entre controles por similitud visual.
3. Comparar las propiedades utilizadas con controles del mismo tipo que ya estén funcionando en `main/screens` o `main/components`.
4. Buscar en el bloque propiedades ya registradas como incompatibles.
5. Mantener separados los radios visuales del contenedor y el texto interior: cuando una etiqueta necesite aspecto de píldora, usar un `GroupContainer` o un botón compatible como fondo y colocar la etiqueta dentro.
6. Tras cada error de importación, corregir el bloque fuente del repositorio; no limitarse a dar una corrección manual en Studio.
7. Anotar el error, su causa, la corrección y una regla preventiva en este documento.

---

## Matriz de propiedades confirmadas como incompatibles

| Control | Propiedad incompatible | Error | Alternativa segura |
|---|---|---|---|
| `Label@2.5.1` | `RadiusBottomLeft` | `PA2108` | Aplicar el radio a un `GroupContainer@1.5.0` o a un botón de fondo |
| `Label@2.5.1` | `RadiusBottomRight` | `PA2108` | Aplicar el radio a un `GroupContainer@1.5.0` o a un botón de fondo |
| `Label@2.5.1` | `RadiusTopLeft` | `PA2108` | Aplicar el radio a un `GroupContainer@1.5.0` o a un botón de fondo |
| `Label@2.5.1` | `RadiusTopRight` | `PA2108` | Aplicar el radio a un `GroupContainer@1.5.0` o a un botón de fondo |
| `Classic/Button@2.2.0` | `AccessibleLabel` | `PA2108` | No declarar la propiedad en este tipo de control; verificar alternativas soportadas en Studio |

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

- [ ] No existe ninguna propiedad `Radius*` dentro de un `Label@2.5.1`.
- [ ] No existe `AccessibleLabel` dentro de un `Classic/Button@2.2.0`.
- [ ] Cada propiedad compleja aparece en al menos un control equivalente ya validado en el repositorio.
- [ ] Los placeholders usan propiedades mínimas y conocidas.
- [ ] Los bloques no mezclan propiedades de controles modernos, clásicos y canvas sin verificación.
- [ ] La operación de inserción o sustitución está documentada al principio del archivo.
- [ ] Existe una prueba mínima y un resultado esperado.

---

## Procedimiento cuando aparezca un nuevo error

1. Detener el siguiente bloque.
2. Registrar el mensaje completo, líneas, control, versión y Session ID.
3. Corregir el archivo fuente en `main`.
4. Buscar el mismo patrón en el resto de bloques pendientes.
5. Añadir la propiedad o patrón a la matriz de incompatibilidades.
6. Solo continuar cuando el bloque corregido haya sido validado en Studio.
