# C16-FIX4 — Porcentajes y arco dinámico de Review Progress

## Clasificación

`C — Component / FIX`

## Problema confirmado en Studio

La integración productiva de `cmp_ReviewProgressPro` funciona y recibe correctamente los valores reales de la cola, pero quedan dos defectos visuales/funcionales:

1. Los porcentajes aparecen como `0%` y `1%` cuando deberían mostrar valores como `20%` y `80%`.
2. El donut puede mostrarse completamente azul aunque `ReviewedCount < TotalCount`.

La captura validada muestra, por ejemplo:

- Total = `5`
- Reviewed = `1`
- Remaining = `4`
- Current Position = `3 of 5`

Por tanto, el contrato de datos del host es correcto. El FIX se limita al componente.

## Alcance

Modificar únicamente tres propiedades dentro de `cmp_ReviewProgressPro`:

1. `lblRPP_ReviewedValue.Text`
2. `lblRPP_RemainingValue.Text`
3. `imgRPP_Donut.Image`

## No modificar

- `scr_PunchReview`
- `conPR_RightColumn`
- `cmpPR_ReviewProgress`
- `TotalCount`
- `ReviewedCount`
- `CurrentPosition`
- geometría del componente
- colores
- Comments
- Custom Fields
- backend

---

# 1. Corregir `lblRPP_ReviewedValue.Text`

Ruta:

`cmp_ReviewProgressPro → conRPP_Root → lblRPP_ReviewedValue`

Propiedad:

`Text`

Sustituir la fórmula actual por:

```powerfx
=Text(
    Min(
        Max(0, Coalesce(cmp_ReviewProgressPro.ReviewedCount, 0)),
        Max(0, Coalesce(cmp_ReviewProgressPro.TotalCount, 0))
    ),
    "[$-en-US]#,##0"
) &
"  (" &
Text(
    100 * cmp_ReviewProgressPro.ReviewedPercentage,
    "[$-en-US]0"
) &
"%)"
```

Resultado esperado con Total=5 y Reviewed=1:

`1  (20%)`

---

# 2. Corregir `lblRPP_RemainingValue.Text`

Ruta:

`cmp_ReviewProgressPro → conRPP_Root → lblRPP_RemainingValue`

Propiedad:

`Text`

Sustituir la fórmula actual por:

```powerfx
=Text(
    cmp_ReviewProgressPro.RemainingCount,
    "[$-en-US]#,##0"
) &
"  (" &
Text(
    100 * (1 - cmp_ReviewProgressPro.ReviewedPercentage),
    "[$-en-US]0"
) &
"%)"
```

Resultado esperado con Total=5 y Remaining=4:

`4  (80%)`

---

# 3. Corregir `imgRPP_Donut.Image`

Ruta:

`cmp_ReviewProgressPro → conRPP_Root → imgRPP_Donut`

Propiedad:

`Image`

Sustituir la fórmula completa por el contenido de:

`docs/development/components/review-progress-pro/fixes/C16-FIX4_imgRPP_Donut.Image.powerfx`

La corrección importante consiste en que el arco azul deja de recalcular el porcentaje directamente desde los inputs y consume la propiedad derivada ya estable:

`cmp_ReviewProgressPro.ReviewedPercentage`

El SVG usa entonces:

`100 * ReviewedPercentage`

para construir el `stroke-dasharray`.

---

# Validación mínima

Probar los siguientes estados en la instancia de Punch Review:

| Total | Reviewed | Esperado |
|---:|---:|---|
| 5 | 0 | 0% azul / 100% gris |
| 5 | 1 | 20% azul / 80% gris |
| 5 | 2 | 40% azul / 60% gris |
| 5 | 5 | 100% azul / 0% gris |

Comprobar también:

- `Remaining = Total - Reviewed`;
- los porcentajes suman 100%;
- `Mark Reviewed` actualiza el donut y los porcentajes inmediatamente;
- `Current Position` continúa funcionando;
- no cambia la geometría del panel.

## Estado esperado tras validación

`cmp_ReviewProgressPro = FINAL_FROZEN` para estructura y comportamiento.

La capa cromática continúa gobernada independientemente por el Design System.
