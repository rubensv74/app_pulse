# C17-E2 — Responsive + Final Visual QA

**Pantalla:** `scr_PunchReview`  
**Tipo:** QA / cierre de fase  
**Estado inicial:** READY FOR STUDIO VALIDATION  
**Objetivo único:** validar que la recomposición C17 se mantiene estable y premium en los tamaños objetivo sin reabrir arquitectura, backend ni componentes ya aprobados.

> Este bloque no introduce cambios por defecto. Si una prueba falla, se abrirá un `C17-E2-FIX[n]` aislado para esa causa concreta.

---

## 1. Precondiciones

Antes de ejecutar este gate deben estar aplicados:

- C17-A — geometría del workspace;
- C17-B — Review Progress + Session Activity en right rail;
- C17-C — Comments + Custom Fields en workspace central;
- C17-C-FIX1 — width budget del right rail;
- C17-D — renderers modernos de Custom Fields;
- C17-D-FIX1 — seguridad del renderer/Gallery;
- C17-D-FIX2 — densidad compacta de Custom Fields;
- C17-E1 — cleanup estructural/navegación/Help.

No continuar si Studio muestra errores de fórmula o Source Code.

---

# 2. Matriz de resoluciones

Validar como mínimo:

```text
A — 1366 × 768
B — 1600 × 900
C — 1920 × 1080
```

La validación debe hacerse sobre la pantalla real, con proyecto, template y cola cargados.

---

# 3. Contrato de layout esperado

## >= 1320 px

La composición objetivo permanece:

```text
Review Queue | Main Workspace                     | Right Rail
             | Actions                            | Review Progress
             | Punch Overview                     | Session Activity
             | Comments       | Custom Fields     |
```

Reglas:

- `Review Queue` permanece utilizable y no invade el workspace;
- `Main Workspace` es la zona dominante;
- `Right Rail` mantiene el width budget aprobado de aproximadamente 260 px;
- no existe scroll horizontal global;
- Comments y Custom Fields permanecen en paralelo;
- Review Progress no empuja Session Activity fuera del viewport.

## < 1320 px

No es objetivo primario de C17-E2, pero debe comprobarse que el layout no falla de forma catastrófica. Si el breakpoint actual apila el rail, aceptar esa conducta siempre que no exista clipping o solapamiento.

---

# 4. QA por zona

## 4.1 Header

Comprobar:

- título y subtítulo sin clipping;
- Project visible;
- Punch template visible como contexto heredado, no como selector operativo;
- Queue Scope ausente;
- `Back to Home` cuando el origen sea Home;
- `Back to Punch List` cuando el origen sea Punch List;
- Help visible y accesible;
- banner `Session review only` completo.

## 4.2 Review Queue

Probar:

- 0 rows;
- 1 row;
- 2–5 rows;
- >20 rows;
- búsqueda;
- All / Remaining / Reviewed;
- first / middle / last selected;
- textos largos;
- scroll vertical.

PASS si:

- no se corta el status pill;
- la descripción no invade metadata;
- el scrollbar no tapa contenido;
- selección y reviewed state siguen legibles.

## 4.3 Actions + Punch Overview

Probar estados:

- OPEN;
- IN PROGRESS;
- Reviewed / Not reviewed.

PASS si:

- botones no se solapan;
- `Open Punch List` sigue visible;
- los campos Overview mantienen separación horizontal;
- Status no invade Discipline/Description;
- Overview no crece de forma que quite espacio operativo al workspace inferior.

## 4.4 Comments

Probar:

- 0 comments;
- 1 comment;
- varias páginas;
- texto largo;
- composer vacío;
- composer con texto;
- Add comment disabled/enabled;
- loading/error si puede simularse sin alterar backend.

PASS si:

- header/pager no se recortan;
- body utiliza el espacio restante;
- composer permanece visible en la parte inferior;
- no aparece scroll horizontal.

## 4.5 Custom Fields

Probar todos los tipos:

```text
Text
Number
Date
YesNo
Choice
MultiChoice
```

Estados:

- Saved;
- Unsaved;
- Saving;
- Error;
- Empty;
- Reader/View;
- Manager/Edit.

PASS si:

- density compacta se conserva;
- row height uniforme;
- Text/Number/Date/Choice/MultiChoice mantienen altura coherente;
- YesNo no ocupa ancho excesivo;
- Choice/MultiChoice muestran opciones reales;
- dropdown/flyout no se recorta por el contenedor;
- footer Save/Cancel permanece visible;
- `3 changes`, `1 change`, etc. no invade botones;
- Gallery scroll no pierde working state.

## 4.6 Review Progress

Probar:

```text
0 / N reviewed
1 / N reviewed
porcentaje parcial
N / N reviewed
```

PASS si:

- donut completo dentro del rail;
- arco azul representa correctamente el porcentaje;
- Reviewed / Remaining / Position legibles;
- 100% no muestra residuos grises incorrectos;
- 0% no muestra arco azul residual.

## 4.7 Session Activity

Probar:

- vacío;
- mark reviewed;
- unmark reviewed;
- Custom Fields saved;
- varios eventos;
- texto largo.

PASS si:

- `FIELDS_SAVED` usa el estilo previsto;
- eventos anteriores `CUSTOM_FIELDS_SAVED` siguen siendo visualmente compatibles durante la sesión;
- el rail hace scroll vertical cuando procede;
- no existe clipping lateral.

---

# 5. Dirty Guard regression

Este gate es obligatorio porque C17 ha cambiado la geometría alrededor de Custom Fields.

Secuencia:

1. editar un Custom Field;
2. confirmar `Unsaved`;
3. intentar seleccionar otro Punch;
4. verificar Dirty Guard;
5. cancelar el cambio de Punch;
6. comprobar que el borrador sigue intacto;
7. repetir y elegir Discard;
8. repetir y elegir Save;
9. repetir intentando salir mediante Back.

PASS si ningún camino pierde cambios sin una decisión explícita.

---

# 6. Navigation regression

## Entrada desde Home

- cargar proyecto/template en Home;
- abrir Punch Review;
- confirmar contexto heredado;
- botón: `Back to Home`;
- retorno: Home.

## Entrada desde Punch List

- abrir Punch Review desde Punch List;
- confirmar contexto heredado;
- botón: `Back to Punch List`;
- retorno: Punch List.

No aceptar un label fijo que contradiga el origen real.

---

# 7. Second-order clipping pass

Después de completar todas las pruebas anteriores, repetir una inspección visual sin interactuar con la lógica.

Buscar específicamente:

- bordes cortados;
- flyouts truncados;
- pills recortadas;
- iconos invadiendo texto;
- labels demasiado próximos a inputs;
- scrollbars superpuestos;
- footer fuera de viewport;
- rail derecho cortado;
- controles modernos con tamaño diferente al resto;
- estados disabled con contraste insuficiente;
- elementos invisibles que todavía reservan espacio.

Este segundo pase es obligatorio aunque la primera validación funcional sea correcta.

---

# 8. Resultado por resolución

Registrar en Studio:

```text
1366 × 768
STRUCTURE        PASS / FAIL
QUEUE            PASS / FAIL
OVERVIEW         PASS / FAIL
COMMENTS         PASS / FAIL
CUSTOM FIELDS    PASS / FAIL
RIGHT RAIL       PASS / FAIL
NO CLIPPING      PASS / FAIL

1600 × 900
...

1920 × 1080
...
```

No corregir dos causas distintas dentro del mismo FIX.

---

# 9. Gate de cierre C17

C17 puede cerrarse solo con:

```text
STUDIO ERRORS             0
C17-E1 CLEANUP             PASS
1366 × 768                 PASS
1600 × 900                 PASS
1920 × 1080                PASS
HEADER                     PASS
QUEUE                      PASS
ACTIONS                    PASS
OVERVIEW                   PASS
COMMENTS                   PASS
CUSTOM FIELDS              PASS
REVIEW PROGRESS            PASS
SESSION ACTIVITY           PASS
DIRTY GUARD                PASS
HOME NAVIGATION            PASS
PUNCH LIST NAVIGATION      PASS
NO GLOBAL HORIZONTAL SCROLL PASS
SECOND-ORDER CLIPPING      PASS
```

Resultado esperado después de confirmación en Studio:

```text
C17 — FINAL_FROZEN
```

Después de C17 se puede retomar `DF-07B` sin volver a modificar la arquitectura del Punch Review Workspace.