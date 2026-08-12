# C17-A — Guía de implementación y validación

## Objetivo

Aplicar únicamente la geometría macro de C17 para comprobar que el workspace central gana anchura y el rail contextual derecho queda reducido a una banda estrecha y estable.

No se mueven todavía controles entre padres.

## Artefacto principal

Aplicar las propiedades descritas en:

`C17-A_target_layout_geometry.property-guide.md`

## Orden exacto

### Paso 1 — UpperGrid

Seleccionar:

`conPR_Workspace → conPR_UpperGrid`

Cambiar únicamente `Height` según la guía.

Guardar y comprobar que el bloque superior usa toda la altura que antes quedaba parcialmente reservada para Related.

### Paso 2 — Main Workspace

Seleccionar:

`conPR_UpperGrid → conPR_CenterColumn`

Cambiar:

- `FillPortions`;
- `Height`;
- `LayoutMinHeight`.

No cambiar todavía sus hijos.

### Paso 3 — Right Rail

Seleccionar:

`conPR_UpperGrid → conPR_RightColumn`

Cambiar:

- `FillPortions`;
- `Width`;
- `LayoutMinWidth`;
- `Height`;
- `LayoutMinHeight`.

No tocar todavía Comments, Custom Fields ni Review Progress internamente.

### Paso 4 — Related

Confirmar:

`conPR_RelatedCard.Visible = false`

No borrar todavía el control.

## Qué es normal durante esta fase

C17-A reduce deliberadamente el rail derecho antes de mover sus contenidos.

Por ello puede observarse temporalmente:

- Comments demasiado estrecho;
- Custom Fields demasiado estrecho;
- Review Progress con ancho insuficiente;
- Session Activity aún ocupando el centro.

No reparar esos síntomas en C17-A. Son consecuencia esperada de que la reubicación se realiza en C17-B y C17-C.

## Validación desktop nominal

Usar preferentemente una resolución de trabajo equivalente a 1600×900 o superior.

Comprobar visualmente:

```text
Review Queue ~330 px
Main Workspace claramente dominante
Right Rail ~280 px
```

El área liberada por el rail debe beneficiar al centro.

## Validación 1320–1499 px

Comprobar:

```text
Right Rail ~260 px
Main sigue siendo la zona dominante
sin scroll horizontal provocado por el rail
```

## Validación <1320 px

El `conPR_UpperGrid` cambia a vertical.

Comprobar:

- `conPR_CenterColumn` usa ancho completo;
- `conPR_RightColumn` usa ancho completo;
- no aparece clipping horizontal estructural;
- el scroll vertical es intencional.

## Criterio de PASS

C17-A queda validado solo cuando Studio confirma:

- cero errores nuevos;
- main width dominante;
- rail 260/280 según breakpoint;
- Related fuera del layout;
- responsive estructural sin clipping horizontal.

No evaluar todavía el acabado de los controles que siguen en sus padres antiguos.

## Próximo bloque tras PASS

`C17-B — Right rail integration`

Moverá:

```text
Review Progress
Session Activity
```

al rail derecho, en ese orden, y adaptará Review Progress a la banda de 260–280 px sin cambiar su contrato funcional.
