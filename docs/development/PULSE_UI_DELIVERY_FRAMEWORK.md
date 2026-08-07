# PULSE UI Delivery Framework

**Versión:** 1.0  
**Estado:** Activo  
**Ámbito:** PULSE y nuevas aplicaciones SaaS empresariales construidas con Power Apps  

---

# 1. Finalidad

Este documento unifica tres piezas que deben utilizarse conjuntamente para diseñar y construir interfaces SaaS de alta calidad:

1. **Protocolo de Construcción Modular** — define cómo construir sin romper.
2. **PULSE Design System (PDS)** — define el lenguaje visual y de interacción.
3. **Especificación de Arquetipos SaaS** — define qué arquitectura de interfaz corresponde a cada tipo de trabajo.

La combinación constituye el **marco de entrega de interfaces PULSE**.

> **Arquetipo = arquitectura de trabajo. PDS = lenguaje visual. Protocolo = método de construcción.**

No deben utilizarse de forma aislada en nuevas pantallas complejas.

---

# 2. Documentos normativos

Todo agente humano o IA debe consultar, como mínimo:

```text
docs/development/PROTOCOLO_CONSTRUCCION_MODULAR_PANTALLAS_POWER_APPS.md
docs/design-system/PULSE_DESIGN_SYSTEM.md
docs/design-system/SAAS_INTERFACE_ARCHETYPES.md
```

Y, cuando corresponda:

```text
docs/development/PROTOCOLO_IMPLEMENTACION_INCREMENTAL_ASISTIDA.md
```

La pantalla o módulo puede disponer además de su propia especificación funcional y arquitectónica.

---

# 3. Orden obligatorio de trabajo

## Paso 1 — Entender el problema

Antes de diseñar la pantalla se documenta:

```text
USER
PRIMARY_JOB
DECISIONS
FREQUENCY
DATA_VOLUME
COLLABORATION_NEEDS
AUDIT_NEEDS
SUCCESS_CRITERION
```

## Paso 2 — Seleccionar arquetipo

Se declara:

```text
PRIMARY_ARCHETYPE
SECONDARY_PATTERNS
```

No se empieza por tarjetas, controles o gráficos.

## Paso 3 — Aplicar PDS

Se definen desde el principio:

- shell;
- page header;
- panel grammar;
- color semantics;
- typography;
- spacing;
- radius;
- action hierarchy;
- selected state;
- loading/empty/error.

No se inventa un estilo local si existe un token o patrón PDS.

## Paso 4 — Congelar arquitectura

Se crea el árbol objetivo de controles y la distribución principal.

## Paso 5 — Dividir en bloques

Se aplica el Protocolo de Construcción Modular.

Cada bloque:

- resuelve una responsabilidad;
- se guarda en repositorio;
- se integra en Studio;
- se valida;
- se corrige antes de avanzar.

## Paso 6 — Integrar backend progresivamente

Primero interacción local, después lectura remota, después escritura, después integración con otras pantallas.

## Paso 7 — Consolidar y documentar

La pantalla validada se consolida en el archivo canónico y se actualizan manuales, especificaciones y catálogo de componentes.

---

# 4. Modelo de capas

```text
┌──────────────────────────────────────────────┐
│ BUSINESS INTENT                              │
│ Qué trabajo necesita completar el usuario   │
├──────────────────────────────────────────────┤
│ SAAS ARCHETYPE                              │
│ Cómo se organiza ese trabajo en pantalla    │
├──────────────────────────────────────────────┤
│ PULSE DESIGN SYSTEM                         │
│ Cómo se ve y se comporta la interfaz        │
├──────────────────────────────────────────────┤
│ MODULAR CONSTRUCTION PROTOCOL               │
│ Cómo se implementa de forma segura          │
├──────────────────────────────────────────────┤
│ POWER APPS / FLOWS / SQL                    │
│ Implementación tecnológica                  │
└──────────────────────────────────────────────┘
```

El error habitual que este framework pretende evitar es empezar en la última capa y construir controles antes de haber cerrado las capas superiores.

---

# 5. Artefactos obligatorios de una pantalla nueva

Para una pantalla compleja debe existir una carpeta de trabajo con:

```text
[SCREEN_WORK_PATH]/
├── README.md
├── SCREEN_SPECIFICATION.md
├── SCREEN_ARCHITECTURE.md
├── DESIGN_DECISIONS.md
├── POWER_APPS_SOURCE_CODE_COMPATIBILITY.md
├── blocks/
│   ├── 01_...
│   ├── 02_...
│   └── ...
└── user-guide/
    └── MANUAL_USUARIO_[SCREEN].md
```

La especificación debe declarar además:

```text
PRIMARY_ARCHETYPE
SECONDARY_PATTERNS
PDS_VERSION
REFERENCE_SCREEN
CANONICAL_SCREEN_PATH
```

---

# 6. Política de reutilización

La reutilización se decide en este orden:

1. **Reutilizar contratos de datos** cuando sean válidos.
2. **Reutilizar componentes PDS** cuando su contrato encaje.
3. **Reutilizar comportamiento probado** cuando esté documentado.
4. **No reutilizar layout legacy** solo porque ya exista.
5. **No copiar hardcodes** visuales de una pantalla antigua.

Una nueva pantalla puede reutilizar lógica del backend de una pantalla anterior sin heredar su deuda visual o estructural.

---

# 7. Política de modernización segura

Cuando exista una pantalla legacy funcional y se quiera migrar al PDS, se recomienda crear una pantalla paralela nueva cuando concurran varias de estas condiciones:

- alto riesgo de regresión;
- pantalla crítica;
- layout actual muy acoplado;
- gran cantidad de controles;
- nueva arquitectura SaaS distinta;
- necesidad de comparar la versión antigua y la nueva;
- disponibilidad de una integración progresiva.

Patrón recomendado:

```text
scr_Home        = referencia funcional estable
scr_Home_PDS    = nueva construcción PDS
```

Durante la construcción:

- `scr_Home` no se modifica para acomodar `scr_Home_PDS`;
- ambas pueden coexistir;
- la nueva pantalla reutiliza contratos/componentes verificados;
- el cambio de navegación solo se realiza después del gate final;
- el rollback consiste en mantener la ruta antigua.

Este patrón es preferible a una sustitución masiva cuando la pantalla existente ya tiene valor operativo.

---

# 8. Quality gates

## Gate A — Architecture

Debe estar cerrado:

- objetivo;
- arquetipo;
- secondary patterns;
- control tree;
- data contracts;
- block plan.

## Gate B — Visual Foundation

Se valida:

- PDS;
- shell;
- header;
- density;
- proportions;
- selection;
- action hierarchy.

## Gate C — Local Interaction

Se valida sin backend:

- filters;
- selection;
- navigation;
- tabs;
- modals;
- local states.

## Gate D — Remote Read

Se validan:

- data loading;
- empty;
- error;
- retry;
- performance perceived.

## Gate E — Write / Business Action

Se validan:

- save/update;
- confirmation;
- dirty guard;
- backend response;
- audit/feedback.

## Gate F — Integration

Se valida:

- source navigation;
- return context;
- permissions;
- responsive;
- accessibility;
- App Checker;
- final documentation.

---

# 9. Definition of Ready para Bloque 01

No debe crearse el primer YAML hasta disponer de:

```text
[ ] Repositorio y rama confirmados
[ ] Estado real de la app inspeccionado
[ ] Pantallas de referencia inspeccionadas
[ ] PDS consultado
[ ] Arquetipo seleccionado
[ ] Árbol objetivo definido
[ ] Componentes reutilizables identificados
[ ] Contratos de datos identificados
[ ] Riesgos documentados
[ ] Secuencia de bloques definida
[ ] Ruta de trabajo creada
```

---

# 10. Definition of Done UI

Además de la Definition of Done técnica del protocolo, una pantalla PDS debe cumplir:

```text
[ ] Un arquetipo dominante reconocible
[ ] Page header consistente con el producto
[ ] Acción primaria inequívoca
[ ] Selection language PDS
[ ] Sin nuevos colores primarios hardcodeados
[ ] Sin nuevos radios arbitrarios
[ ] Tipografía dentro de escala PDS
[ ] Normal panels sin sombras decorativas
[ ] Loading / Empty / Error resueltos
[ ] Estados accesibles sin depender solo del color
[ ] Scroll y densidad revisados con datos reales
[ ] No quedan placeholders de bloques
[ ] Ayuda/manual actualizados si aplica
```

---

# 11. Paquete mínimo para futuros encargos

Cuando se encargue una nueva pantalla o aplicación, el prompt debe proporcionar o señalar:

```text
1. Protocolo modular
2. PDS
3. Especificación de arquetipos
4. Contexto funcional
5. Rutas del repositorio
6. Fuentes de verdad de datos
7. Pantallas/componentes de referencia
```

Si alguno no existe, el agente debe declarar la carencia antes de programar.

---

# 12. Regla para nuevas aplicaciones

Este framework puede reutilizarse fuera de PULSE.

Para otra app:

- se conserva el Protocolo Modular;
- se conserva la Especificación de Arquetipos;
- se sustituye PULSE Design System por el design system específico del producto;
- se conservan los mismos quality gates.

Por tanto, el conocimiento adquirido en PULSE pasa de ser código local a convertirse en una **metodología portable de desarrollo de producto SaaS**.

---

# 13. Regla final

> **No construir una interfaz hasta saber qué trabajo representa, qué arquetipo lo soporta, qué design system la gobierna y cómo se validará cada incremento.**

Cuando estas cuatro respuestas estén cerradas, la implementación puede avanzar con velocidad sin sacrificar control.