# Instrucciones para agentes

La documentación de desarrollo, protocolos y lecciones aprendidas del repositorio siguen siendo la fuente de verdad para el método incremental de PULSE.

## Equipo de agentes IA — PILOT V1

Para cualquier trabajo material o transversal, aplicar automáticamente:

- `docs/ai/PULSE_AGENT_REGISTRY_V1.yaml`;
- `docs/ai/PULSE_RUNTIME_ROUTING_V1.yaml`;
- `docs/ai/prompts/RUN_ENGINEERING_ORCHESTRATOR.md`.

El usuario no tiene que elegir qué agente, modelo o herramienta utilizar.

El Orchestrator debe:

1. resolver primero el contexto real del repositorio;
2. conservar el protocolo incremental vigente de PULSE;
3. seleccionar el conjunto mínimo de especialistas;
4. seleccionar la capacidad de runtime más sencilla que pueda completar correctamente la tarea;
5. escalar razonamiento solo cuando aparezcan ambigüedad, riesgo, contradicción o dificultad real;
6. separar construcción de revisión adversarial;
7. continuar autónomamente hasta un gate real;
8. distinguir siempre repositorio de runtime real;
9. explicar el resultado de forma sencilla de asimilar.

No sustituir silenciosamente el método incremental de PULSE por un método externo. El equipo de agentes trabaja **dentro** del protocolo actual.

Los contratos transversales del Agent Team y del runtime routing viven en `rubensv74/functional-engineering-knowledge-base`; PULSE mantiene únicamente su configuración local.

## Preferencia tecnológica

Para las aplicaciones de negocio de PULSE, la opción inicial preferente es:

```text
Power Apps      -> interfaz y experiencia de usuario
Power Automate  -> automatización e integración
SQL             -> datos, integridad, consultas y lógica pesada
```

Regla: `POWER_APPS_FIRST`, no `POWER_APPS_ONLY`.

Si una capability necesita otra tecnología, el Architecture Agent debe justificar la excepción con una necesidad o limitación material antes de abrir esa línea técnica.

## Gobernanza visual y catálogo de encargos — obligatorio

Para cualquier trabajo que cree, continúe, revise o prepare para gate una pantalla PULSE, y para cualquier incremento Power Apps que modifique UI, aplicar obligatoriamente:

- `docs/design-system/PULSE_DESIGN_SYSTEM.md`;
- `docs/design-system/PULSE_PREMIUM_SCREEN_STANDARD_V1.md`;
- `docs/design-system/PULSE_PAGE_HEADER_HIERARCHY_V1.md`;
- `docs/design-system/POWER_APPS_VISUAL_QA_GUARDRAILS.md`;
- `docs/design-system/COMPONENT_CATALOG.md`.

La decisión de componentes es siempre:

```text
REUSE → EXTEND_SHARED → CREATE_SHARED → LOCAL_ONLY
```

Antes de crear una pieza visual nueva se debe revisar el catálogo y la implementación real bajo `power-apps/components/`.

- Si existe un componente compatible y con lifecycle apto, reutilizarlo.
- Si el cambio es reusable, evolucionar el componente compartido.
- Si existe un gap reusable real, crear un nuevo componente compartido, añadir su fuente canónica, especificación y lifecycle al catálogo, y validarlo según sus gates.
- Una pieza local solo es válida cuando la necesidad es deliberadamente específica y está justificada.
- `LEGACY_SUPPORTED` no es candidato para trabajo nuevo salvo migración explícita.

Ninguna pantalla puede considerarse visualmente aprobada si recrea localmente una capacidad ya cubierta por un componente compartido compatible.

El catálogo de encargos para IA vive en:

```text
docs/ai/README.md
```

La guía rápida para invocar encargos desde un hilo nuevo es:

```text
docs/ai/PULSE_AI_WORK_CATALOG_QUICK_REFERENCE.md
```

Cuando el usuario invoque una plantilla por nombre, el agente debe abrir la plantilla correspondiente bajo `docs/ai/prompts/`, resolver sus referencias canónicas, revisar el estado real del repositorio y avanzar de forma autónoma hasta un gate real.

## GitHub Actions — Local First / Remote Gate

- No utilizar GitHub Actions como bucle de desarrollo ni añadir ejecución automática por cada `push` salvo necesidad técnica documentada.
- Validar primero en el entorno local y, para Power Platform, en las herramientas reales que correspondan.
- Reservar Actions para Pull Requests, releases, despliegues, comprobaciones que requieran infraestructura remota o ejecución manual deliberada.
- Aplicar filtros por rutas, `concurrency` y cancelación de ejecuciones obsoletas cuando se creen workflows automáticos.
- No generar artifacts, matrices o jobs costosos si no existe un consumidor o riesgo concreto que los justifique.
- Antes de ampliar CI, justificar qué riesgo cubre, por qué no basta la validación local y cuál es el momento mínimo en el que debe ejecutarse.

Principio obligatorio: **validar localmente primero; ejecutar GitHub Actions solo como gate remoto necesario.**
