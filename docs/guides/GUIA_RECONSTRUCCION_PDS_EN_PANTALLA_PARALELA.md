# Guía de Reconstrucción PDS en Pantalla Paralela

**Versión:** 1.0  
**Estado:** Activo  
**Ámbito:** PULSE / Canvas Power Apps / modernización de pantallas existentes  
**Caso de referencia:** `scr_Home` → `scr_Home_PDS`  

---

# 1. Finalidad

Esta guía define una estrategia segura para modernizar una pantalla Power Apps existente cuando el objetivo no es realizar un simple ajuste visual, sino introducir simultáneamente:

- un nuevo Design System;
- una arquitectura SaaS más avanzada;
- nuevos componentes reutilizables;
- una nueva jerarquía visual y de acciones;
- mejoras de estados loading / empty / error;
- cambios importantes de layout;
- una construcción modular por bloques YAML;
- una migración progresiva sin poner en riesgo la pantalla productiva actual.

La regla central es:

> **Cuando la modernización cambia la arquitectura de la pantalla, no se debe utilizar la pantalla estable como laboratorio. Se crea una implementación paralela desde cero, se valida por bloques y solo se realiza el cutover cuando la nueva versión ha demostrado equivalencia funcional y superioridad de experiencia.**

El caso inicial que motiva esta guía es:

```text
scr_Home
    → implementación actual estable
    → referencia funcional
    → fallback inmediato

scr_Home_PDS
    → nueva implementación
    → construida desde cero
    → PULSE Design System
    → Operational Control Tower
    → Data Explorer como patrón secundario
```

---

# 2. Por qué no refactorizar directamente la pantalla existente

Modificar progresivamente una pantalla madura parece inicialmente más rápido, pero cuando se combinan cambios estructurales, visuales y funcionales aparecen varios riesgos.

## 2.1. Regresiones difíciles de aislar

Si en una misma pantalla se modifican:

- header;
- layout;
- variables de tema;
- componentes;
- filtros;
- jerarquía de acciones;
- estados de selección;
- grids;
- gráficos;

un fallo posterior puede tener múltiples causas posibles.

En una reconstrucción modular paralela, el origen de una regresión queda acotado normalmente al último bloque integrado.

---

## 2.2. Arrastre de deuda estructural

Duplicar o modificar una pantalla existente tiende a conservar:

- radios históricos;
- colores hardcodeados;
- controles legacy;
- nombres inconsistentes;
- layouts difíciles de mantener;
- dependencias no deseadas;
- fórmulas acumuladas;
- workarounds temporales que terminaron siendo permanentes.

Una pantalla nueva permite reutilizar el conocimiento funcional sin heredar automáticamente esa deuda.

---

## 2.3. Ausencia de rollback real

Si `scr_Home` se modifica directamente y aparece un problema crítico, recuperar una versión estable puede requerir:

- revertir commits;
- importar otra solución;
- reconstruir cambios;
- perder mejoras válidas realizadas en paralelo.

Con una pantalla paralela:

```text
scr_Home      = versión estable
scr_Home_PDS  = versión candidata
```

el rollback consiste inicialmente en no cambiar la navegación.

---

## 2.4. Comparación visual y funcional directa

Mantener ambas pantallas permite comparar:

- densidad;
- jerarquía;
- legibilidad;
- tiempo para completar tareas;
- claridad de acciones;
- comportamiento con datos reales;
- estados vacíos y de error;
- responsive;
- percepción global de calidad.

Esta comparación es muy difícil si la versión anterior ha sido sustituida durante el desarrollo.

---

# 3. Cuándo utilizar esta estrategia

Debe considerarse una reconstrucción paralela cuando se cumplan varias de estas condiciones:

- la pantalla actual funciona y no debe ponerse en riesgo;
- el cambio afecta al layout principal;
- se adopta un nuevo Design System;
- cambia el arquetipo SaaS dominante;
- existen nuevos componentes estructurales;
- la pantalla actual contiene deuda visual o técnica significativa;
- se prevén muchos bloques de implementación;
- la pantalla tiene integraciones con flows, SQL o servicios externos;
- se necesita comparar nueva y antigua versión antes del cutover;
- el equipo necesita un rollback sencillo.

No es necesario crear una pantalla paralela para cambios pequeños como:

- corregir un label;
- modificar un tooltip;
- cambiar una propiedad aislada;
- resolver un bug local claramente identificado;
- aplicar una mejora cosmética que no altera arquitectura.

---

# 4. Documentos que gobiernan la reconstrucción

Toda reconstrucción PDS paralela debe utilizar conjuntamente:

```text
docs/development/PULSE_UI_DELIVERY_FRAMEWORK.md
docs/development/PROTOCOLO_CONSTRUCCION_MODULAR_PANTALLAS_POWER_APPS.md
docs/design-system/PULSE_DESIGN_SYSTEM.md
docs/design-system/SAAS_INTERFACE_ARCHETYPES.md
```

Y la especificación propia de la pantalla, por ejemplo:

```text
docs/specifications/home-pds/HOME_PDS_SCREEN_SPECIFICATION.md
```

La relación conceptual es:

> **Arquetipo = arquitectura de trabajo.**  
> **PDS = lenguaje visual.**  
> **Protocolo modular = método de construcción.**  
> **Esta guía = estrategia de migración segura desde una pantalla existente.**

---

# 5. Principio de aislamiento

La nueva pantalla debe ser técnicamente independiente mientras se construye.

Para Home:

```text
scr_Home
    NO se modifica para construir Home_PDS
    NO se reemplaza
    NO deja de ser StartScreen
    NO pierde su navegación

scr_Home_PDS
    se crea como pantalla nueva
    se integra progresivamente
    permanece fuera del flujo principal hasta el gate de cutover
```

Durante el desarrollo, cualquier acceso a `scr_Home_PDS` debe ser deliberado y controlado.

Ejemplos válidos:

- navegación temporal desde un control de desarrollo;
- ejecución directa desde Power Apps Studio;
- deep link temporal documentado;
- entrada desde un menú de test oculto a usuarios finales.

---

# 6. No duplicar la pantalla existente

La estrategia recomendada NO es:

```text
Duplicate scr_Home
Rename → scr_Home_PDS
Delete / rewrite progressively
```

Eso conserva desde el primer minuto la estructura y deuda que se intenta eliminar.

La estrategia recomendada es:

```text
New blank screen
    ↓
Name: scr_Home_PDS
    ↓
Block 01 — minimum shell
    ↓ validate
Block 02 — PDS header
    ↓ validate
Block 03 — workspace layout
    ↓ validate
...
```

La pantalla existente actúa como fuente de verdad funcional, no como plantilla estructural.

---

# 7. Qué reutilizar de la pantalla actual

Antes de construir, cada elemento de la pantalla original debe clasificarse explícitamente.

## 7.1. REUSE_AS_IS

Componente o contrato suficientemente bueno para incorporarse sin cambios relevantes.

Ejemplos posibles:

- `cmp_SidebarNav`;
- un componente gráfico ya validado;
- un flow cuyo contrato es correcto;
- una colección estable.

## 7.2. REUSE_WITH_PDS_INPUTS

La lógica o componente es válido, pero necesita recibir tokens PDS o normalizar propiedades visuales.

Ejemplo:

```text
cmp_KpiCardPro
    lógica válida
    estados válidos
    → normalizar radios, colores, tipografía y selección
```

## 7.3. REUSE_LOGIC_ONLY

La lógica es correcta, pero la interfaz debe reconstruirse.

Ejemplos:

- colección de KPIs;
- filtro de disciplina;
- construcción de contexto de heatmap;
- llamada a flow;
- cálculo de totales.

## 7.4. REIMPLEMENT

La responsabilidad sigue siendo necesaria, pero la implementación actual no debe migrarse.

Ejemplos:

- un header estructuralmente incompatible con PDS;
- barra de acciones sin jerarquía clara;
- panel construido con deuda significativa.

## 7.5. DO_NOT_REUSE

Elemento temporal, obsoleto o incompatible con la nueva arquitectura.

Ejemplos:

- scaffolding de desarrollo;
- test controls;
- hardcodes históricos;
- componentes deprecados;
- workarounds que ya no tienen justificación.

---

# 8. Requisito previo: sincronizar el repositorio

La auditoría de la nueva pantalla solo es fiable si el repositorio contiene el estado real de la aplicación.

Antes del Bloque 00 debe actualizarse, cuando aplique:

1. pantalla origen actual;
2. pantalla de referencia arquitectónica;
3. componentes premium utilizados;
4. componentes gráficos;
5. grid / table;
6. filter / action toolbar;
7. flows relevantes;
8. contratos SQL relevantes;
9. navegación actual;
10. App.OnStart o bootstrap de tema si ha cambiado.

Para `scr_Home_PDS`, las referencias mínimas son:

```text
scr_Home
scr_PunchReview
cmp_SidebarNav
cmp_KpiCardPro
heatmap actual
donut / discipline distribution
cmp_DataTablePro
barra de filtros / acciones
flows del dashboard de punches
```

No debe comenzar el Bloque 01 contra un repositorio desactualizado.

---

# 9. Bloque 00 — auditoría obligatoria

La reconstrucción paralela empieza con una auditoría, no con YAML.

El resultado mínimo debe incluir:

```text
A. Repository state
B. Current screen anatomy
C. Reference screen anatomy
D. PDS compatibility
E. Reusable components
F. Reusable business logic
G. Reusable data contracts
H. Legacy debt not to carry forward
I. Exact target control tree
J. Exact numbered block plan
K. Repository construction paths
L. Open risks
M. Do-not-invent list
```

El Bloque 00 debe responder claramente:

- qué hace hoy la pantalla;
- qué contratos son obligatorios conservar;
- qué puede reutilizarse;
- qué debe reconstruirse;
- qué arquitectura tendrá la nueva pantalla;
- cómo se dividirá el trabajo;
- qué riesgos existen antes de escribir código.

---

# 10. Arquitectura congelada antes del Bloque 01

No debe comenzar la construcción hasta aprobar el árbol objetivo.

Ejemplo para Home_PDS:

```text
scr_Home_PDS
└── conHPDS_Root
    ├── cmpHPDS_Sidebar
    └── conHPDS_Content
        ├── conHPDS_PageHeader
        │   ├── Identity
        │   ├── Project Context
        │   ├── Template Context
        │   ├── Refresh Context
        │   └── Page Actions
        │
        ├── conHPDS_KpiStrip
        │   ├── KPI Total
        │   ├── KPI Open
        │   ├── KPI Closed
        │   └── KPI Completion
        │
        ├── conHPDS_Analytics
        │   ├── Punch Concentration
        │   └── Discipline Distribution
        │
        ├── conHPDS_ActiveContext
        │   └── Action Toolbar
        │
        ├── conHPDS_DataExplorer
        │   ├── Grid
        │   └── Pagination
        │
        └── conHPDS_OverlayLayer
            └── Help / future drawers
```

La arquitectura puede evolucionar después, pero cualquier cambio estructural debe documentarse antes de afectar los bloques dependientes.

---

# 11. Construcción por bloques pequeños

La pantalla debe seguir el protocolo modular.

Una secuencia típica para `scr_Home_PDS` puede ser:

```text
00  Foundation audit
01  Screen shell
02  PDS page header
03  Main workspace layout
04  Runtime state
05  KPI strip shell
06  KPI real data
07  Analytics panel shell
08  Heatmap integration
09  Discipline distribution integration
10  Local analytic selection
11  Active context bar
12  Action hierarchy
13  Data Explorer shell
14  Data Explorer real data
15  Search / filters / density
16  Drill-through and Review
17  Refresh and loading states
18  Empty / error / retry hardening
19  Help / contextual guidance
20  Responsive and accessibility
21  Remove test scaffolding
22  Canonical consolidation
23  Navigation cutover
```

La lista definitiva debe salir del Bloque 00 y de la especificación real de la pantalla.

---

# 12. Regla de validación

Después de cada bloque:

```text
1. Integrate block
2. Save in Power Apps Studio
3. Wait for formula validation
4. Review App Checker
5. Navigate to scr_Home_PDS
6. Execute minimum test
7. Capture screenshot when visual evaluation matters
8. Mark block validated or failed
```

No se prepara el siguiente bloque funcional si el anterior está en `failed`.

Estados permitidos:

```text
planned
published
integrating
failed
corrected
validated
```

---

# 13. Gates visuales

La reconstrucción paralela permite revisar el diseño antes de acumular backend.

Gates recomendados:

## Gate V1 — Shell

Validar:

- sidebar;
- header;
- page background;
- dimensiones principales;
- responsive básico.

## Gate V2 — Arquitectura

Validar:

- KPIs;
- analytics;
- context bar;
- data explorer;
- proporciones;
- espacios muertos;
- scroll.

## Gate V3 — Primeros módulos reales

Validar:

- densidad;
- selección;
- interacción;
- jerarquía de acciones;
- legibilidad con datos reales.

## Gate V4 — Estados

Validar:

- loading;
- empty;
- no results;
- error;
- retry;
- disabled.

## Gate V5 — Comparación A/B

Comparar `scr_Home` y `scr_Home_PDS` con el mismo proyecto y contexto.

---

# 14. Equivalencia funcional antes del cutover

Una reconstrucción PDS no puede sustituir a la pantalla anterior solo porque sea visualmente mejor.

Debe existir una matriz de equivalencia.

Ejemplo:

| Capacidad | scr_Home | scr_Home_PDS | Estado |
|---|---|---|---|
| Selección proyecto | Sí | Sí | Validar |
| Template | Sí | Sí | Validar |
| Refresh | Sí | Sí | Validar |
| KPIs | Sí | Sí | Validar |
| Heatmap | Sí | Sí | Validar |
| Filtro por disciplina | Sí | Sí | Validar |
| DataGrid | Sí | Sí | Validar |
| Review | Sí | Sí | Validar |
| Export | Sí | Sí | Validar |
| Comments | Sí | Sí | Validar |

El cutover requiere que las capacidades obligatorias estén:

```text
validated
```

o que una diferencia esté documentada y aceptada explícitamente como cambio funcional.

---

# 15. Criterio de cutover

`StartScreen`, Home del sidebar o cualquier navegación principal solo debe cambiar a `scr_Home_PDS` cuando se cumpla:

- todos los bloques productivos validados;
- equivalencia funcional aceptada;
- no quedan placeholders;
- no quedan test seeds;
- App Checker no introduce errores atribuibles a la nueva pantalla;
- carga, error y vacío validados;
- navegación de ida y retorno validada;
- responsive revisado;
- accesibilidad revisada;
- manual actualizado;
- ayuda contextual actualizada;
- código canónico consolidado;
- repositorio limpio;
- rollback documentado.

El cutover debe ser un bloque separado y pequeño.

No debe mezclarse con cambios visuales o funcionales adicionales.

---

# 16. Rollback después del cutover

Incluso después de activar `scr_Home_PDS`, la versión anterior no debe eliminarse inmediatamente.

Durante un periodo de estabilización:

```text
scr_Home_PDS = primary
scr_Home     = fallback legacy
```

La pantalla legacy puede retirarse solo cuando:

- la nueva pantalla ha sido utilizada con datos reales;
- no existen regresiones críticas abiertas;
- no existen dependencias ocultas hacia la pantalla anterior;
- el equipo acepta formalmente su retirada.

La eliminación de la pantalla legacy debe ser una tarea independiente, no parte del mismo commit del cutover.

---

# 17. Qué NO debe hacerse

Durante una reconstrucción paralela no se debe:

- duplicar la pantalla antigua y llamarlo reconstrucción;
- cambiar `StartScreen` durante los primeros bloques;
- mantener lógica de test en producción;
- copiar fórmulas sin entender sus contratos;
- recrear flows por intuición;
- introducir colores o radios fuera del PDS;
- mezclar refactor de backend con cambios visuales innecesariamente;
- avanzar sobre errores de Studio;
- comparar pantallas usando datasets diferentes;
- eliminar la pantalla legacy antes de estabilizar la nueva;
- reconstruir el YAML final desde memoria en lugar de obtener el estado real validado.

---

# 18. Beneficios de esta estrategia

## Seguridad

La pantalla estable sigue disponible durante todo el desarrollo.

## Diagnóstico

Los errores quedan acotados a incrementos pequeños.

## Calidad

La arquitectura puede diseñarse correctamente desde el principio.

## Comparabilidad

Es posible realizar una revisión A/B real.

## Reutilización

Se conservan contratos y componentes buenos sin copiar deuda innecesaria.

## Velocidad sostenible

Aunque la primera fase parece más lenta, reduce el coste de debugging, rollback y retrabajo.

## Aprendizaje

Cada pantalla nueva genera bloques, documentación, compatibilidad y componentes que aceleran la siguiente.

---

# 19. Modelo generalizable a futuras pantallas

El patrón no es exclusivo de Home.

Puede utilizarse para modernizar:

```text
scr_Legacy
    ↓ reference + fallback
scr_New_PDS
    ↓ parallel modular implementation
validated
    ↓
controlled cutover
```

Ejemplos posibles:

- `scr_Punches` → `scr_Punches_PDS`;
- `scr_Config` → `scr_Config_PDS`;
- una pantalla de Asset 360 nueva frente a una ficha legacy;
- un nuevo Planning Board frente a un listado clásico;
- un nuevo Case Workspace frente a un formulario monolítico.

La decisión debe basarse en el alcance de la transformación, no en una preferencia automática por crear pantallas nuevas.

---

# 20. Encargo reutilizable para un agente de IA

```markdown
# ENCARGO — RECONSTRUCCIÓN PDS EN PANTALLA PARALELA

Debes modernizar `[LEGACY_SCREEN]` mediante una nueva pantalla `[NEW_SCREEN]`, sin modificar ni sustituir inicialmente la pantalla actual.

Documentos obligatorios:

- `docs/guides/GUIA_RECONSTRUCCION_PDS_EN_PANTALLA_PARALELA.md`
- `docs/development/PULSE_UI_DELIVERY_FRAMEWORK.md`
- `docs/development/PROTOCOLO_CONSTRUCCION_MODULAR_PANTALLAS_POWER_APPS.md`
- `docs/design-system/PULSE_DESIGN_SYSTEM.md`
- `docs/design-system/SAAS_INTERFACE_ARCHETYPES.md`
- `[SCREEN_SPECIFICATION]`

## Reglas

1. La pantalla legacy es referencia funcional y fallback.
2. No dupliques la pantalla legacy.
3. Crea la nueva pantalla desde cero.
4. No cambies StartScreen ni navegación principal durante la construcción.
5. Audita primero el estado real del repositorio.
6. Clasifica cada elemento legacy como REUSE_AS_IS, REUSE_WITH_PDS_INPUTS, REUSE_LOGIC_ONLY, REIMPLEMENT o DO_NOT_REUSE.
7. Define el arquetipo principal y patrones secundarios.
8. Congela el árbol objetivo antes del Bloque 01.
9. Construye por bloques pequeños y valida cada uno en Power Apps Studio.
10. No avances sobre errores abiertos.
11. Mantén matriz de equivalencia funcional.
12. Realiza revisión A/B antes del cutover.
13. El cutover debe ser un bloque separado.
14. Mantén la pantalla legacy como fallback durante estabilización.

## Primera entrega

No construyas todavía la pantalla completa.

Entrega únicamente:

- auditoría del repositorio;
- anatomía de la pantalla legacy;
- contratos funcionales que deben conservarse;
- clasificación de reutilización;
- deuda que no debe migrarse;
- arquetipo seleccionado;
- árbol objetivo;
- plan numerado de bloques;
- riesgos;
- Bloque 01 — shell mínimo.
```

---

# 21. Caso de referencia PULSE — Home_PDS

La primera aplicación formal de esta guía es:

```text
LEGACY_SCREEN: scr_Home
NEW_SCREEN: scr_Home_PDS
DISPLAY_TITLE: Punch Control Tower
PRIMARY_ARCHETYPE: Operational Control Tower
SECONDARY_PATTERNS: Data Explorer
```

Referencias obligatorias:

```text
docs/specifications/home-pds/HOME_PDS_SCREEN_SPECIFICATION.md
docs/design-system/PULSE_DESIGN_SYSTEM.md
docs/design-system/SAAS_INTERFACE_ARCHETYPES.md
docs/development/PULSE_UI_DELIVERY_FRAMEWORK.md
docs/development/PROTOCOLO_CONSTRUCCION_MODULAR_PANTALLAS_POWER_APPS.md
```

La construcción de `scr_Home_PDS` debe comenzar por el Bloque 00 de auditoría una vez que el repositorio remoto contenga el estado actualizado de Home, Punch Review y los componentes/contratos relevantes.

---

# 22. Regla final

> **Una pantalla estable no se sacrifica para demostrar una nueva arquitectura. La nueva arquitectura debe ganarse el derecho a sustituirla mediante construcción aislada, validación incremental, equivalencia funcional y cutover controlado.**
