# C17-C-FIX1 — Right rail width budget reconciliation

**Tipo:** `S-FIX — Structural repair`  
**Pantalla:** `scr_PunchReview`  
**Fuente de verdad revisada:** pantalla completa facilitada desde Power Apps Studio el 2026-08-13.  
**Objetivo único:** eliminar el clipping del rail derecho reconciliando el ancho real del rail con los `LayoutMinWidth` y la geometría mínima validada de sus descendientes.

## Diagnóstico confirmado sobre el Source Code actual

La pantalla actual contiene simultáneamente estos contratos incompatibles:

```text
conPR_RightColumn.Width                  = 230 px en desktop
conPR_RightColumn.LayoutMinWidth         = 260 px
conPR_ReviewProgressCard.LayoutMinWidth  = 300 px
conPR_HistoryHeader.LayoutMinWidth       = 280 px
conPR_HistoryBody.LayoutMinWidth         = 280 px
```

Además, `cmp_ReviewProgressPro` fue compactado en C17-B para trabajar de forma segura en un host de **260–280 px**. Su geometría interna deja de disponer de separación suficiente entre labels y valores por debajo de ~260 px.

Por tanto, el rail de 230 px no es un rail más eficiente: es un host **por debajo de su presupuesto geométrico mínimo**, y Power Apps termina recortando contenido o forzando mínimos contradictorios.

## Decisión

El rail derecho queda fijado a **260 px en desktop**. Este es el mínimo seguro demostrado por la geometría actual de Review Progress y permite mantener el workspace central lo más ancho posible.

La regla anterior `280 px >=1500` queda sustituida para esta pantalla por:

```text
>= 1320 px  -> 260 px
< 1320 px   -> ancho completo / layout apilado
```

No reducir por debajo de 260 px mientras `cmp_ReviewProgressPro` conserve la geometría compacta de C17-B.

---

# Cambios exactos

## 1. `conPR_RightColumn`

Target:

```text
scr_PunchReview
→ conPR_ScreenRoot
→ conPR_ContentShell
→ conPR_Body
→ conPR_Workspace
→ conPR_UpperGrid
→ conPR_RightColumn
```

### `Width`

Sustituir la fórmula actual por:

```powerfx
=If(
    App.Width < 1320,
    Parent.Width,
    260
)
```

### `LayoutMinWidth`

Mantener/reemplazar por:

```powerfx
=If(
    App.Width < 1320,
    300,
    260
)
```

### `FillPortions`

Mantener:

```powerfx
=0
```

### `X`

No es necesario modificarlo en este FIX. `conPR_RightColumn` es hijo de un `AutoLayout`; la posición horizontal la gobierna el layout. La fórmula existente puede limpiarse más adelante en C17-E.

---

## 2. `conPR_ReviewProgressCard`

### `Height`

Añadir/establecer:

```powerfx
=140
```

### `LayoutMinHeight`

Sustituir:

```powerfx
=140
```

### `LayoutMinWidth`

Sustituir el valor actual `300` por:

```powerfx
=260
```

### `Width`

Mantener:

```powerfx
=Parent.Width
```

### Motivo

El wrapper no debe exigir 300 px cuando el componente interior está específicamente adaptado a 260 px. Tampoco debe reservar 200 px verticales para una instancia de 140 px.

---

## 3. `cmpPR_ReviewProgress`

No modificar contratos ni lógica.

Mantener:

```powerfx
Height = 140
Width  = Parent.Width
```

Mantener sin cambios:

- `TotalCount`
- `ReviewedCount`
- `CurrentPosition`
- `State`
- fórmula del arco C16-FIX5
- labels compactos de C17-B
- tokens de color

---

## 4. `conPR_HistoryCard`

### `FillPortions`

Establecer explícitamente:

```powerfx
=1
```

### `LayoutMinWidth`

Sustituir por:

```powerfx
=260
```

### `Width`

Mantener:

```powerfx
=Parent.Width
```

### `Height`

Puede mantenerse la fórmula actual:

```powerfx
=Parent.Height - 150
```

El `FillPortions=1` deja explícito que Session Activity absorbe la altura restante del rail después de Review Progress.

---

## 5. `conPR_HistoryHeader`

### `LayoutMinWidth`

Sustituir `280` por:

```powerfx
=260
```

### `Height`

Sustituir `48` por:

```powerfx
=58
```

### `LayoutMinHeight`

Sustituir `48` por:

```powerfx
=58
```

Esto permite separar correctamente título/badge de la línea descriptiva sin comprimir horizontalmente la segunda línea.

---

## 6. `lblPR_HistorySubtitle`

### `Width`

Sustituir el ancho fijo `260` por:

```powerfx
=Parent.Width - 28
```

### `Y`

Sustituir `28` por:

```powerfx
=35
```

### `Height`

Mantener:

```powerfx
=16
```

La línea deja de declarar un ancho mayor que su propio parent y se sitúa por debajo del badge.

---

## 7. `conPR_HistoryBody`

### `LayoutMinWidth`

Sustituir `280` por:

```powerfx
=260
```

### `Width`

Mantener:

```powerfx
=Parent.Width
```

---

# No tocar en este FIX

No modificar:

- `conPR_CenterColumn`;
- `conPR_CollaborationRow`;
- Comments;
- Custom Fields;
- Queue;
- Punch Overview;
- flows / SP / colecciones;
- dirty guard;
- definición funcional de `cmp_ReviewProgressPro`;
- `conPR_RelatedCard`.

Aunque `conPR_CustomFieldsHost` conserva `X=40` y `Y=40` como residuo de su antiguo host, está dentro de un `AutoLayout` y no es la causa del clipping actual. Se limpiará en C17-E.

---

# Validación mínima en Studio

Con una ventana desktop >=1320 px:

1. El borde derecho de `Review Progress` debe verse completo.
2. El borde derecho de `Session Activity` debe verse completo.
3. Ningún hijo del rail debe exigir más de 260 px mediante `LayoutMinWidth`.
4. El donut, Reviewed, Remaining y Position deben quedar íntegros y sin solapamiento.
5. El badge `events` de Session Activity debe quedar dentro de la tarjeta.
6. El subtitle de Session Activity no debe sobresalir del parent.
7. Comments y Custom Fields deben conservar su distribución actual.
8. El Main Workspace sigue siendo claramente dominante.
9. No aparecen errores de fórmula nuevos.
10. No aparece scroll horizontal provocado por el rail.

## PASS esperado

```text
C17-C-FIX1              PASS
RIGHT RAIL WIDTH        260 px desktop
DESCENDANT MIN WIDTHS   <= 260 px
REVIEW PROGRESS         NO CLIPPING
SESSION ACTIVITY        NO CLIPPING
MAIN WORKSPACE          DOMINANT
BUSINESS LOGIC          UNCHANGED
```

## Regla preventiva derivada

Antes de estrechar cualquier rail o panel AutoLayout, realizar un **width-budget audit**:

```text
host Width
>= host LayoutMinWidth
>= critical child LayoutMinWidth
>= minimum validated component width
```

Y, para controles internos con posición manual:

```text
X + Width <= Parent.Width
```

No aprobar una reducción de ancho si alguno de esos contratos queda por encima del nuevo host.