# C17-E — Cleanup + Responsive + Visual QA

Estado: READY FOR FINAL STUDIO PASS
Pantalla: scr_PunchReview
Fecha: 2026-08-13

## Evidencia visual ya confirmada

La última validación en Power Apps Studio confirma:

- el template de Punch Review hereda correctamente el contexto de Home;
- Queue Scope ya no ocupa espacio en el header;
- Comments y Custom Fields comparten el workspace central;
- Review Progress y Session Activity permanecen en el rail derecho;
- el rail derecho ya no presenta clipping;
- Choice y MultiChoice usan un selector moderno y muestran opciones reales;
- Number ha recuperado una apariencia coherente con el resto de inputs;
- el workspace central sigue siendo claramente dominante.

## Objetivo de C17-E

Cerrar C17 sin reabrir arquitectura ni backend. C17-E es un gate de limpieza y validación, no una fase de rediseño.

## 1. Source sync gate

Antes de eliminar controles o limpiar propiedades residuales, el Source Code de Studio debe volver a ser la fuente de verdad.

El archivo repository-owned `power-apps/screens/PunchReview/scr_PunchReview.pa.yaml` todavía conserva elementos anteriores a la última validación de Studio, como Queue Scope y el label fijo del botón Back. Por tanto, no debe usarse para un cleanup destructivo hasta sincronizarlo con el código actual de Studio.

Gate:

```text
STUDIO SOURCE CURRENT   required
REPO SOURCE CURRENT     required before destructive cleanup
```

## 2. Cleanup estructural pendiente

Después de sincronizar el Source Code actual:

- eliminar físicamente `conPR_RelatedCard` si sigue existiendo y `Visible=false`;
- eliminar `X/Y` residuales en hijos gobernados por AutoLayout cuando Studio los siga serializando sin efecto funcional;
- eliminar Width/Height redundantes solo cuando el parent AutoLayout ya gobierne correctamente la dimensión;
- conservar explícitamente cualquier `LayoutMinWidth/Height` que forme parte del width budget validado;
- no tocar controles de backend ocultos usados como servicios host.

## 3. Responsive QA

Validar al menos:

```text
1366 x 768
1600 x 900
1920 x 1080
```

En cada tamaño:

- Review Queue utilizable;
- main workspace dominante;
- rail derecho completo;
- no scroll horizontal global;
- Comments composer visible;
- Custom Fields footer visible;
- Review Progress legible;
- Session Activity sin clipping.

## 4. Custom Fields QA

Probar todos los tipos reales:

```text
Text
Number
Date
YesNo
Choice
MultiChoice
```

Casos:

- valor vacío;
- valor existente;
- editar;
- dirty state;
- revertir al baseline;
- Save;
- Cancel;
- scroll de Gallery y retorno a la fila;
- Choice/MultiChoice con opciones reales.

## 5. Review Progress QA

Probar:

```text
0% reviewed
porcentaje parcial
100% reviewed
```

El donut debe conservar la fórmula aprobada de arco y mantener Reviewed / Remaining / Position legibles dentro del rail de 260 px.

## 6. Session Activity QA

Probar:

- vacío;
- 1 evento;
- varios eventos;
- texto largo;
- scroll si aplica.

## 7. Queue QA

Probar:

- cola vacía;
- 1 punch;
- cola corta;
- cola larga con scroll;
- search;
- All / Remaining / Reviewed;
- selección del primer, intermedio y último punch.

## 8. Navigation QA

Validar entrada y salida desde:

- Home;
- Punch List.

El comportamiento Back debe volver al origen real y el texto visible debe describir ese origen.

## Gate de cierre C17

```text
STRUCTURE             PASS
SOURCE SYNC           PASS
MAIN WIDTH            PASS
RIGHT RAIL            PASS
COMMENTS              PASS
CUSTOM VALUES         PASS
REVIEW PROGRESS       PASS
SESSION ACTIVITY      PASS
QUEUE                  PASS
RESPONSIVE             PASS
WIDTH BUDGET           PASS
NO GLOBAL CLIPPING     PASS
NO NEW FORMULA ERRORS  PASS
```

Solo después de este gate C17 puede marcarse CLOSED y reanudarse DF-07B.