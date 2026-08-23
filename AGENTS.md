# Instrucciones para agentes

La documentación de desarrollo, protocolos y lecciones aprendidas del repositorio siguen siendo la fuente de verdad para el método incremental de PULSE.

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
