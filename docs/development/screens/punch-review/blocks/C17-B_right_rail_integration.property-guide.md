# C17-B — Right rail integration

**Tipo:** `S/C — Structural + component visual adaptation`  
**Pantalla:** `scr_PunchReview`  
**Objetivo único:** convertir `conPR_RightColumn` en rail contextual estrecho con `Review Progress` arriba y `Session Activity` debajo.

> Este bloque no mueve todavía Comments ni Custom Fields al área central. Esa operación pertenece a C17-C.

## Pre-gates aplicados

Antes de preparar este bloque se han revisado de nuevo:

- `docs/development/screens/punch-review/POWER_APPS_SOURCE_CODE_COMPATIBILITY.md`
- `30-playbooks/power-platform/modular-power-apps-screen-construction.md`

No se introduce YAML nuevo en C17-B; la implementación se hace mediante reparenting en el árbol y ajustes de propiedades.

---

# 1. Árbol objetivo de C17-B

Al terminar este bloque, el rail derecho debe comenzar así:

```text
conPR_RightColumn
├── cmpPR_ReviewProgress
├── conPR_HistoryCard
├── conPR_CommentsCard          [temporal — se moverá en C17-C]
└── conPR_CustomFieldsHost      [temporal — se moverá en C17-C]
```

Si en tu árbol `cmpPR_ReviewProgress` está todavía envuelto por `conPR_ReviewProgressCard`, mueve la unidad visual aprobada completa y conserva ese wrapper. No reconstruyas el componente.

---

# 2. Reubicar Review Progress

## Operación

En el árbol de Power Apps Studio:

1. Localiza `cmpPR_ReviewProgress`.
2. Córtalo desde su parent actual.
3. Selecciona `conPR_RightColumn`.
4. Pégalo como hijo.
5. Muévelo hasta la **primera posición** del rail.

## Propiedades de la instancia `cmpPR_ReviewProgress`

Aplicar:

```text
Height = 140
Width  = Parent.Width
ReviewedLabel = "Reviewed"
RemainingLabel = "Remaining"
CurrentPositionLabel = "Position"
```

Mantener sin cambios:

- `TotalCount`
- `ReviewedCount`
- `CurrentPosition`
- `State`
- colores / tokens
- fórmula del arco aprobada en C16-FIX5

---

# 3. Compactar la definición `cmp_ReviewProgressPro`

La instancia va a vivir en un rail de 260–280 px. El componente original fue diseñado aproximadamente para 354 px, por lo que hay que ajustar solo su geometría interna.

## Root

### `cmp_ReviewProgressPro`

```text
Height = 140
Width  = 280
```

### `conRPP_Root`

Mantener:

```text
Height = Parent.Height
Width  = Parent.Width
```

---

## Header

### `lblRPP_Title`

```text
Height = 22
Size   = 10
X      = 12
Y      = 8
Width  = Parent.Width - 24
```

### `rectRPP_HeaderDivider`

```text
X      = 12
Y      = 34
Width  = Parent.Width - 24
```

---

## Donut

### `imgRPP_Donut`

No modificar `Image`.

Cambiar únicamente:

```text
Height = 82
Width  = 82
X      = 12
Y      = 43
```

El donut conserva la fórmula de C16-FIX5; solo cambia su superficie de renderizado.

---

# 4. Métricas compactas

La geometría siguiente está pensada para funcionar tanto en 260 px como en 280 px.

## Reviewed

### `btnRPP_ReviewedDot`

```text
Height = 8
Width  = 8
X      = 104
Y      = 50
```

### `lblRPP_ReviewedLabel`

```text
Height = 18
Size   = 7
X      = 118
Y      = 45
Width  = Max(52, Parent.Width - 205)
Wrap   = false
```

### `lblRPP_ReviewedValue`

```text
Height = 18
Size   = 7
Width  = 68
X      = Parent.Width - 78
Y      = 45
```

## Remaining

### `btnRPP_RemainingDot`

```text
Height = 8
Width  = 8
X      = 104
Y      = 79
```

### `lblRPP_RemainingLabel`

```text
Height = 18
Size   = 7
X      = 118
Y      = 74
Width  = Max(52, Parent.Width - 205)
Wrap   = false
```

### `lblRPP_RemainingValue`

```text
Height = 18
Size   = 7
Width  = 68
X      = Parent.Width - 78
Y      = 74
```

## Current Position

### `icoRPP_CurrentPosition`

```text
Height = 11
Width  = 11
X      = 103
Y      = 107
```

### `lblRPP_CurrentPositionLabel`

```text
Height = 18
Size   = 7
X      = 118
Y      = 102
Width  = Max(52, Parent.Width - 205)
Wrap   = false
```

### `lblRPP_CurrentPositionValue`

```text
Height = 18
Size   = 7
Width  = 68
X      = Parent.Width - 78
Y      = 102
```

---

# 5. Estados no READY

### `lblRPP_State`

Aplicar:

```text
Height = 64
Width  = Parent.Width - 32
X      = 16
Y      = 48
Size   = 8
```

No cambiar la fórmula `Text` ni la lógica `Visible`.

---

# 6. Reubicar Session Activity

## Operación

1. Localiza `conPR_HistoryCard` en el main/center workspace actual.
2. Córtalo.
3. Pégalo dentro de `conPR_RightColumn`.
4. Sitúalo inmediatamente **debajo de `cmpPR_ReviewProgress`**.

## Propiedades `conPR_HistoryCard`

Aplicar:

```text
FillPortions    = 1
Height          = Parent.Height - 150
LayoutMinHeight = 220
LayoutMinWidth  = 240
Width           = Parent.Width
```

No tocar:

- `Items` de la galería;
- filtros por `PunchIdNumber`;
- textos de eventos;
- `EventType`;
- colores por tipo;
- empty state.

---

# 7. No modificar en C17-B

No mover todavía:

- `conPR_CommentsCard`
- `conPR_CustomFieldsHost`

No modificar:

- Comments flows;
- Custom Fields load/save;
- Dirty Guard;
- `cmp_CustomFieldValuesPro`;
- `cmp_CustomFieldsEditorPro`;
- Action toolbar;
- Punch Overview;
- queue;
- `conPR_RightColumn.Width` fijado en C17-A.

---

# Resultado esperado

En desktop amplio:

```text
MAIN WORKSPACE             RIGHT RAIL 260–280
                           ┌─────────────────────┐
                           │ Review Progress     │ ~140
                           │ donut ~82 px        │
                           ├─────────────────────┤
                           │ Session Activity    │
                           │                     │
                           │ fills remaining     │
                           └─────────────────────┘
```

Comments y Custom Fields pueden seguir apareciendo temporalmente más abajo en el rail hasta C17-C. No compensar eso aumentando el ancho del rail.
