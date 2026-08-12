# C17-A — Target layout / geometry

**Tipo:** `S — Structural`  
**Pantalla:** `scr_PunchReview`  
**Objetivo único:** fijar la geometría macro de C17 antes de mover controles o modernizar renderers.

## Regla de este bloque

C17-A **no mueve todavía** Comments, Custom Fields, Review Progress ni Session Activity entre padres. Solo fija la relación geométrica que debe gobernar los siguientes bloques.

Por tanto, durante esta validación algunos paneles todavía estarán dentro de su padre antiguo y pueden verse temporalmente más estrechos de lo deseado. Eso **no es un defecto de C17-A**. C17-B y C17-C harán la reubicación real.

No modificar en este bloque:

- flows;
- `OnSelect` / `OnChange`;
- dirty guard;
- contratos de componentes;
- datos de Punch Overview;
- controles internos de Comments / Custom Fields / Review Progress / Session Activity.

---

# 1. `conPR_Workspace`

Target:

```text
scr_PunchReview
→ conPR_ScreenRoot
→ conPR_ContentShell
→ conPR_Body
→ conPR_Workspace
```

## `Height`

Sustituir por:

```powerfx
=If(
    App.Width < 1100,
    1080,
    Parent.Height
)
```

> Se mantiene el comportamiento actual. C17-A no cambia todavía el contrato responsive general del workspace.

## `LayoutOverflowY`

Mantener:

```powerfx
=LayoutOverflow.Scroll
```

---

# 2. `conPR_UpperGrid`

Target:

```text
conPR_Workspace
→ conPR_UpperGrid
```

## `Height`

**Sustituir completamente** la fórmula actual por:

```powerfx
=If(
    App.Width < 1320,
    1060,
    Parent.Height
)
```

### Motivo

`conPR_RelatedCard` ya no participa en el layout operativo (`Visible=false`). La fórmula anterior reservaba aproximadamente 200 px verticales para una zona que ya no debe condicionar la pantalla.

## `LayoutDirection`

Mantener:

```powerfx
=If(
    App.Width < 1320,
    LayoutDirection.Vertical,
    LayoutDirection.Horizontal
)
```

## `LayoutGap`

Mantener:

```powerfx
=10
```

## `LayoutMinHeight`

Mantener por ahora:

```powerfx
=If(
    App.Width < 1320,
    1060,
    660
)
```

---

# 3. `conPR_CenterColumn` — se convierte conceptualmente en Main Workspace

Target:

```text
conPR_UpperGrid
→ conPR_CenterColumn
```

No renombrar todavía el control. El rename estructural, si se decide, se hará en cleanup cuando C17 esté validado.

## `FillPortions`

Sustituir por:

```powerfx
=If(
    App.Width < 1320,
    0,
    1
)
```

### Motivo

El Main Workspace debe absorber todo el crecimiento horizontal restante después de Queue y Right Rail. No debe competir mediante proporciones simétricas con la columna contextual.

## `Width`

Mantener:

```powerfx
=Parent.Width
```

En desktop el `FillPortions=1` hará que este contenedor consuma el espacio restante porque el rail derecho quedará con `FillPortions=0` y anchura explícita.

## `Height`

Sustituir por:

```powerfx
=If(
    App.Width < 1320,
    680,
    Parent.Height
)
```

### Motivo

En la futura versión apilada este contenedor debe poder alojar Actions + Overview + Collaboration workspace. Los 390 px actuales son insuficientes para la geometría objetivo.

## `LayoutMinHeight`

Sustituir por:

```powerfx
=If(
    App.Width < 1320,
    640,
    520
)
```

## `LayoutMinWidth`

Mantener:

```powerfx
=300
```

---

# 4. `conPR_RightColumn` — rail contextual estrecho

Target:

```text
conPR_UpperGrid
→ conPR_RightColumn
```

## `FillPortions`

Sustituir por:

```powerfx
=0
```

### Motivo

El rail no debe crecer proporcionalmente con la pantalla. El crecimiento horizontal pertenece al Main Workspace.

## `Width`

Sustituir por:

```powerfx
=If(
    App.Width < 1320,
    Parent.Width,
    If(
        App.Width < 1500,
        260,
        280
    )
)
```

### Contrato

```text
1320–1499 px  → 260 px
>= 1500 px    → 280 px
< 1320 px     → apilado, ancho completo
```

No superar 300 px durante C17 salvo defecto real demostrado en Studio.

## `LayoutMinWidth`

Sustituir por:

```powerfx
=If(
    App.Width < 1320,
    300,
    260
)
```

## `Height`

Sustituir por:

```powerfx
=If(
    App.Width < 1320,
    370,
    Parent.Height
)
```

### Nota temporal

Los 370 px en modo apilado son únicamente un mínimo estructural de C17-A. C17-B recalculará la altura real del rail cuando contenga Review Progress + Session Activity.

## `LayoutMinHeight`

Sustituir por:

```powerfx
=If(
    App.Width < 1320,
    340,
    520
)
```

## `LayoutGap`

Mantener:

```powerfx
=10
```

---

# 5. `conPR_RelatedCard`

Mantener:

```powerfx
Visible = false
```

No eliminar físicamente todavía.

La eliminación se decide en C17-E después de validar la nueva composición completa.

---

# 6. Qué NO corregir todavía aunque se vea comprimido

Después de fijar el rail a 260/280 px, los siguientes controles todavía estarán temporalmente en su ubicación anterior:

- `conPR_CommentsCard`;
- `conPR_CustomFieldsHost`;
- `conPR_ReviewProgressCard`;
- `conPR_HistoryCard` todavía sigue dentro de `conPR_CenterColumn`.

No ajustar sus controles internos para compensar esta situación temporal.

El objetivo de C17-A es validar únicamente:

```text
QUEUE | MAIN DOMINANT | RIGHT RAIL COMPACT
```

C17-B moverá `Review Progress + Session Activity` al rail.
C17-C moverá `Comments + Custom Fields` al Main Workspace.

---

# 7. Geometría esperada después de C17-A

Desktop amplio:

```text
┌──────────────┬───────────────────────────────────────────┬────────────┐
│ Review Queue │ Main workspace                            │ Right rail │
│   ~330 px    │ flexible / absorbe todo el crecimiento    │   280 px   │
└──────────────┴───────────────────────────────────────────┴────────────┘
```

Desktop intermedio:

```text
Queue ~330 px | Main flexible | Rail 260 px
```

Por debajo de 1320 px:

```text
Queue / Workspace según layout existente
Main Workspace
Right Rail
```

---

# 8. Gate de validación C17-A

Power Apps Studio debe confirmar:

1. No aparecen errores de fórmula nuevos.
2. `conPR_UpperGrid` utiliza toda la altura disponible en desktop.
3. A `>=1500 px`, el Right Rail mide aproximadamente 280 px.
4. Entre `1320–1499 px`, el Right Rail mide aproximadamente 260 px.
5. El Main Workspace absorbe el espacio horizontal liberado.
6. Review Queue mantiene su ancho operativo aproximado de 330 px.
7. `conPR_RelatedCard` no reserva espacio visible.
8. A `<1320 px`, Main y Right Rail se apilan sin scroll horizontal causado por el rail.
9. No se realizan ajustes internos a Comments/Custom Fields para compensar su ubicación temporal.

## PASS esperado

```text
C17-A STRUCTURE      PASS
MAIN WIDTH           DOMINANT
RIGHT RAIL           COMPACT
CHILD RELOCATION     PENDING C17-B/C
FUNCTIONAL LOGIC     UNCHANGED
```
