# C17-B — Guía de implementación y validación

## Objetivo

Convertir el rail derecho de Punch Review en un rail contextual compacto:

```text
Review Progress
Session Activity
```

sin mover todavía Comments ni Custom Fields al panel central.

## Orden obligatorio

1. Reubicar `cmpPR_ReviewProgress` como primer hijo de `conPR_RightColumn`.
2. Aplicar la compactación interna de `cmp_ReviewProgressPro`.
3. Reubicar `conPR_HistoryCard` debajo de Review Progress.
4. Validar geometría y comportamiento.
5. No iniciar C17-C hasta que este rail quede limpio.

Guía de propiedades:

`docs/development/screens/punch-review/blocks/C17-B_right_rail_integration.property-guide.md`

## Validación visual mínima

### A. Rail

En un ancho desktop amplio:

- el rail continúa en aproximadamente 260–280 px;
- el main workspace sigue siendo claramente dominante;
- Review Progress ocupa la parte superior;
- Session Activity queda inmediatamente debajo y absorbe el resto de la altura;
- el rail no aumenta su ancho para acomodar contenido.

### B. Review Progress

Probar al menos:

1. `0 / 7 reviewed`
2. `1 / 7 reviewed`
3. `4 / 7 reviewed`
4. `7 / 7 reviewed`

Comprobar:

- donut aproximado de 82 px;
- arco correcto según porcentaje;
- Total legible;
- Reviewed, Remaining y Position sin clipping;
- ningún texto invade los valores de la derecha;
- no aparece scroll horizontal.

### C. Session Activity

Probar:

- sin eventos;
- un evento;
- varios eventos;
- etiqueta de evento relativamente larga.

Comprobar:

- empty state centrado;
- la galería ocupa la anchura completa;
- no se corta el borde derecho;
- el rail no crece de ancho;
- el scroll es vertical e intencional.

## Estado transitorio esperado

Hasta C17-C, Comments y Custom Fields siguen perteneciendo al árbol antiguo del rail y pueden quedar por debajo de Session Activity o fuera del viewport inmediato.

Eso es temporal y **no debe corregirse** ensanchando `conPR_RightColumn` ni alterando los componentes.

## Gate

C17-B se considera validado cuando Power Apps Studio confirma:

```text
RIGHT RAIL WIDTH       APPROVED
REVIEW PROGRESS        VISIBLE / NO CLIPPING
DONUT                   CORRECT
SESSION ACTIVITY        VISIBLE / FUNCTIONAL
MAIN WORKSPACE WIDTH    PRESERVED
NO NEW FORMULA ERRORS
```

El siguiente bloque será:

`C17-C — Collaboration workspace`

que moverá Comments y Custom Fields al panel central en dos columnas.
