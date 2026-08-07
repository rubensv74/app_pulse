# Especificación de Arquetipos de Interfaz SaaS Premium

**Versión:** 1.0  
**Estado:** Activo  
**Ámbito:** PULSE y futuras aplicaciones SaaS/enterprise  
**Relación obligatoria:** `PULSE_DESIGN_SYSTEM.md` + `PROTOCOLO_CONSTRUCCION_MODULAR_PANTALLAS_POWER_APPS.md`

---

# 1. Finalidad

Este documento define una taxonomía reutilizable de **arquetipos de interfaz SaaS empresarial**. Su objetivo es evitar que una nueva pantalla se diseñe empezando por controles, tarjetas o gráficos. Primero se identifica el tipo de trabajo que debe realizar el usuario; después se selecciona el arquetipo que mejor soporta ese trabajo.

Un arquetipo no es un tema visual. Es una **arquitectura de interacción** con una estructura, jerarquía, densidad, acciones y estados característicos.

La regla principal es:

> **Primero se diseña el trabajo del usuario. Después se diseña la pantalla.**

El PULSE Design System define **cómo se ve y se comporta visualmente** la aplicación. Este documento define **qué arquitectura de interfaz utilizar**. El protocolo modular define **cómo construirla sin romperla**.

---

# 2. Regla de selección

Toda pantalla nueva debe declarar antes del Bloque 01:

```text
PRIMARY_ARCHETYPE: [uno]
SECONDARY_PATTERNS: [cero o varios]
PRIMARY_USER_TASK: [tarea principal]
SUCCESS_CRITERION: [cómo sabemos que el usuario completó la tarea]
```

Solo debe existir **un arquetipo dominante** salvo justificación explícita. Los patrones secundarios pueden aparecer como drawers, paneles, tabs, modales o zonas subordinadas.

---

# 3. Matriz rápida de decisión

| Si el usuario necesita principalmente... | Arquetipo recomendado |
|---|---|
| revisar muchos registros uno a uno y tomar una decisión | Operational Review Workspace |
| investigar y resolver un caso complejo | Agent / Case Workspace |
| encontrar, filtrar, comparar y editar datos rápidamente | Data Explorer |
| comprender un objeto completo y sus relaciones | Object 360 |
| detectar desviaciones, prioridades y cuellos de botella | Operational Control Tower |
| asignar o programar trabajo en tiempo/estado | Planning Board |
| definir automatizaciones y reglas visualmente | Workflow Builder |
| gobernar catálogos, permisos y configuración | Configuration Studio |
| importar datos con mapeo y validación | Import & Mapping Wizard |
| reconstruir cronológicamente qué ocurrió | Audit Timeline |
| resolver anomalías o excepciones priorizadas | Exception Resolution Queue |

---

# 4. Operational Review Workspace

## Propósito

Permitir revisar un conjunto de registros de forma secuencial, tomar decisiones, comentar y conservar el progreso de una sesión sin perder contexto.

## Usar cuando

- existe una cola de registros;
- el usuario debe revisar uno tras otro;
- el progreso completado/restante importa;
- existe una decisión explícita por registro;
- los comentarios, custom fields o evidencias deben permanecer accesibles.

## Evitar cuando

- el caso requiere investigación prolongada y no lineal;
- el usuario trabaja principalmente con comparación masiva;
- no existe concepto real de cola o revisión.

## Anatomía obligatoria

```text
Page Header / Session Context

┌──────────────┬──────────────────────┬──────────────────┐
│ Review Queue │ Current Record       │ Inspector        │
│ Search       │ Overview             │ Comments         │
│ Filters      │ Primary Actions      │ Fields / Related │
│ Progress     │ Session Activity     │ Context          │
└──────────────┴──────────────────────┴──────────────────┘
```

## Interacciones clave

- previous / next;
- mark reviewed / undo;
- review and next cuando proceda;
- filtros All / Remaining / Reviewed;
- feedback inmediato;
- persistencia o trazabilidad de la sesión;
- dirty guard si existe edición.

## PULSE

Referencia principal: `scr_PunchReview`.

Casos de uso:

- Punch Review;
- revisión AMEF/RCM;
- validación de Job Plans;
- revisión de entregables de handover;
- aprobación de incidencias de calidad.

---

# 5. Agent / Case Workspace

## Propósito

Resolver un caso complejo que requiere conversación, investigación, SLA, múltiples registros relacionados y colaboración.

## Usar cuando

- un caso puede durar horas o días;
- participan varias personas;
- existe SLA o prioridad;
- la conversación es parte central del trabajo;
- se consultan documentos, inspecciones, WO u objetos relacionados.

## Anatomía

```text
Case Header: status · priority · SLA · owner

┌───────────────────────────────────┬────────────────┐
│ Conversation / Notes / Activity   │ Case Details   │
│ Investigation                     │ Related Data   │
│ Resolution composer               │ Context        │
└───────────────────────────────────┴────────────────┘

Escalate · Reassign · Request Info · Resolve
```

## PULSE / CMMS

- issue resolution;
- coating-quality investigation;
- open operational issues;
- complex punch escalation;
- support cases.

---

# 6. Data Explorer

## Propósito

Permitir localizar, filtrar, ordenar, comparar y actuar sobre grandes conjuntos de registros con mínima navegación.

## Usar cuando

- existen cientos o miles de registros;
- búsqueda y filtros son esenciales;
- se necesita selección múltiple;
- el usuario alterna entre inspección rápida y acciones masivas.

## Anatomía

```text
Search · Saved Views · Filters · View Controls · Bulk Actions

┌──────────────┬─────────────────────────────────────────┐
│ Filter Rail  │ Dense Data Grid                         │
│              │                                         │
│              ├─────────────────────────────────────────┤
│              │ Quick Preview / Peek                    │
└──────────────┴─────────────────────────────────────────┘
```

## Capacidades premium

- búsqueda inmediata;
- filtros persistentes;
- columnas configurables;
- densidad;
- sorting;
- preview sin abandonar la lista;
- selección múltiple;
- bulk actions;
- keyboard-first cuando la plataforma lo permita.

## PULSE

- Punch Data Explorer;
- Tasks;
- asset catalogue;
- work orders;
- engineering-data explorer.

---

# 7. Object 360

## Propósito

Concentrar la identidad, salud, relaciones, actividad y acciones de un único objeto de negocio.

## Usar cuando

el usuario piensa primero en una entidad: Asset, Subsystem, Work Order, Punch, Project, Job Plan.

## Anatomía

```text
Object Identity + Status + Primary Actions
KPI / Health Strip
Tabs: Overview · Activity · Documents · Related · History

Overview modules
Relationships
Risk / Health
Recent Activity
```

## PULSE / CMMS

- Asset 360;
- Subsystem 360;
- Work Order 360;
- Punch 360;
- Project 360.

---

# 8. Operational Control Tower

## Propósito

Detectar rápidamente qué requiere atención y permitir llegar desde la visión agregada hasta la acción operativa.

## Regla crítica

Un Control Tower no se limita a responder **qué ocurre**. Debe responder también:

- qué necesita atención;
- dónde está el problema;
- qué impacto tiene;
- quién debe actuar;
- cómo llegar al detalle.

## Anatomía

```text
Page Context
KPI Strip

Operational Analytics
┌──────────────────────────┬────────────────────────┐
│ Hotspot / Heatmap        │ Distribution / Trend   │
└──────────────────────────┴────────────────────────┘

Active Context + Actions

Operational Data Explorer / Exception List
```

## PULSE

Destino propuesto para `scr_Home_PDS`: **Punch Control Tower**.

Casos de uso:

- punch concentration;
- project readiness;
- handover control tower;
- maintenance control tower;
- commissioning readiness.

---

# 9. Planning Board

## Propósito

Asignar, programar y mover trabajo entre estados, recursos o periodos temporales.

## Variantes

- Kanban;
- timeline;
- weekly board;
- swimlanes;
- resource planning;
- scheduling matrix.

## Capacidades premium

- drag and drop con validación;
- conflictos visibles;
- capacidad / sobreasignación;
- undo;
- bulk move;
- zoom temporal;
- filtros persistentes.

## Usar Kanban solo cuando

mover el objeto entre columnas represente una transición real del negocio.

## PULSE / CMMS

- WO weekly scheduling;
- punch assignment;
- inspection plan;
- weekly maintenance plan.

---

# 10. Workflow Builder

## Propósito

Configurar visualmente automatizaciones, decisiones y reglas de negocio.

## Anatomía

```text
Component Palette | Visual Canvas | Properties Inspector

Trigger
  ↓
Condition / Branch
  ↓
Action
  ↓
Wait / Escalation / Notification
```

## Requisitos enterprise

- draft vs published;
- validation;
- test/simulation;
- versioning;
- execution history;
- explicit input/output contracts;
- retry/error semantics;
- impact analysis before publish.

## Casos

- punch escalation;
- approvals;
- auto-assignment;
- WO creation;
- notifications;
- Effective Policy rules.

---

# 11. Configuration Studio

## Propósito

Gobernar configuración estructurada sin convertir la pantalla en un formulario gigante.

## Arquitectura

```text
Configuration Tree | Editor / Details | Validation / Publish
```

## Flujo mental

1. localizar;
2. editar;
3. validar;
4. evaluar impacto;
5. publicar;
6. auditar.

## Casos

- punch templates;
- custom fields;
- statuses;
- roles;
- permissions;
- FLH;
- ADR;
- project settings;
- maintenance rules.

---

# 12. Import & Mapping Wizard

## Propósito

Guiar una carga masiva desde fuente externa hasta datos válidos y auditables.

## Secuencia recomendada

```text
1 Source
2 Select Data
3 Map Columns
4 Validate
5 Confirm
6 Result
```

## Requisitos

- preview;
- saved mappings;
- transform rules;
- valid/warning/error classification;
- downloadable error report;
- partial import policy explícita;
- idempotency / duplicate strategy cuando aplique;
- summary final.

## Casos

- FLH;
- assets;
- ADR;
- punches;
- Job Plans;
- engineering data.

---

# 13. Audit Timeline

## Propósito

Reconstruir qué ocurrió, cuándo, quién lo hizo y qué cambió.

## Anatomía

```text
Object Context
Filters by event type
Chronological event stream
Before / After values
Related events / evidence
```

## Evento mínimo

```text
Timestamp
Actor
Event type
Object
Previous value
New value
Context / source
```

## Casos

- punch history;
- WO history;
- configuration changes;
- import history;
- workflow execution history;
- review-session traceability.

---

# 14. Exception Resolution Queue

## Propósito

Transformar anomalías técnicas o funcionales en trabajo operativo priorizado y resoluble.

## Anatomía

```text
Priority / Severity Filters

Exception Queue | Exception Detail | Resolution Panel
```

## Capacidades

- severity;
- business impact;
- root-cause hint;
- recommended action;
- assignment;
- resolve;
- snooze with reason;
- escalation;
- bulk resolution when safe;
- recurrence metrics.

## PULSE

- missing discipline;
- invalid subsystem;
- duplicate punch;
- failed flow;
- incomplete engineering data;
- invalid configuration;
- blocked WO.

---

# 15. Patrones secundarios reutilizables

Los siguientes no necesitan convertirse siempre en arquetipos dominantes:

- Inspector lateral;
- contextual drawer;
- Peek Preview;
- Activity Stream;
- filter rail;
- KPI strip;
- quick actions toolbar;
- contextual tabs;
- command palette;
- help modal;
- dirty guard;
- saved views;
- empty/error/loading state panel.

---

# 16. Calidad visual común

Independientemente del arquetipo, toda pantalla debe respetar `PULSE_DESIGN_SYSTEM.md` o el design system equivalente del producto.

Mínimos:

- una jerarquía tipográfica coherente;
- un sistema único de selección;
- color semántico, no decorativo;
- una acción primaria por contexto;
- geometría consistente;
- estados loading/empty/error;
- responsive definido;
- accesibilidad básica;
- feedback inmediato;
- conservación de contexto cuando el usuario navega entre registros.

---

# 17. Criterios de aceptación por arquetipo

Antes de cerrar la arquitectura de una nueva pantalla deben poder responderse estas preguntas:

1. ¿Cuál es la tarea principal?
2. ¿Cuál es el arquetipo dominante?
3. ¿Qué información debe permanecer visible durante toda la tarea?
4. ¿Cuál es la acción primaria?
5. ¿Qué significa completar el trabajo?
6. ¿Qué estados del objeto y del proceso deben diferenciarse?
7. ¿Qué se puede cargar de forma independiente?
8. ¿Qué contexto debe sobrevivir a la navegación?
9. ¿Qué excepciones requieren un patrón específico?
10. ¿Qué elementos son realmente secundarios y deben ir en drawer/tab/modal?

Si estas respuestas no están cerradas, no debe empezar el Bloque 01.

---

# 18. Bloque para adjuntar a futuros encargos

```markdown
## Arquitectura de interfaz SaaS

Antes de construir la pantalla debes consultar:

- `docs/design-system/PULSE_DESIGN_SYSTEM.md`
- `docs/design-system/SAAS_INTERFACE_ARCHETYPES.md`
- `docs/development/PROTOCOLO_CONSTRUCCION_MODULAR_PANTALLAS_POWER_APPS.md`

Debes identificar explícitamente:

PRIMARY_ARCHETYPE: [arquetipo]
SECONDARY_PATTERNS: [patrones]
PRIMARY_USER_TASK: [tarea]
SUCCESS_CRITERION: [resultado]

No diseñes primero componentes o tarjetas. Define primero el flujo de trabajo, selecciona el arquetipo adecuado, congela la arquitectura y después construye la pantalla por bloques pequeños verificables.
```

---

# 19. Regla final

> **PDS define el lenguaje visual. El arquetipo define la arquitectura de trabajo. El protocolo modular define el método de construcción.**

La combinación de las tres capas debe considerarse la base de cualquier nueva interfaz compleja en PULSE y una plantilla reutilizable para futuras aplicaciones SaaS empresariales.