# PULSE — Catálogo de encargos para IA

**Estado:** `ACTIVE / PRODUCT-WIDE`

Este catálogo permite iniciar trabajo con instrucciones cortas sin depender del contexto de un hilo anterior.

## Engineering Orchestrator — PILOT V1

Para trabajo material o transversal no hace falta que el usuario seleccione una plantilla, un agente, un modelo o una herramienta.

La entrada automática es:

- `PULSE_AGENT_REGISTRY_V1.yaml` — agentes disponibles y reglas de coordinación;
- `PULSE_RUNTIME_ROUTING_V1.yaml` — selección de fuente, profundidad de razonamiento, ejecución y modalidad;
- `prompts/RUN_ENGINEERING_ORCHESTRATOR.md` — procedimiento de orquestación.

Flujo esperado:

```text
petición natural
→ contexto real de PULSE
→ método incremental vigente
→ conjunto mínimo de agentes
→ runtime/model/tool adecuado
→ ejecución y validación
→ revisión adversarial cuando aplique
→ gate humano solo si es real
```

La política tecnológica local es:

```text
Power Apps      -> interfaz y experiencia de negocio
Power Automate  -> automatización e integración
SQL             -> datos, integridad, consultas y lógica pesada
```

`POWER_APPS_FIRST`, no `POWER_APPS_ONLY`.

Principio de routing:

```text
usar la capacidad más sencilla que pueda completar bien la tarea
→ escalar solo cuando aparezcan ambigüedad, riesgo, contradicción o dificultad real
→ volver a un nivel más sencillo después de cerrar la parte compleja
```

El equipo no reemplaza el protocolo incremental existente de PULSE. Trabaja dentro de él.

## Plantillas específicas

Antes de ejecutar cualquier plantilla solicitada expresamente:

1. leer `AGENTS.md`;
2. abrir la plantilla bajo `docs/ai/prompts/`;
3. revisar repositorio/artefacto real;
4. cargar PDS, contratos, gates y documentación aplicable;
5. trabajar de forma autónoma hasta un gate real;
6. no declarar validación sin evidencia real.

Para UI es obligatorio consultar `docs/design-system/COMPONENT_CATALOG.md`, `PULSE_PREMIUM_SCREEN_STANDARD_V1.md` y `PULSE_PAGE_HEADER_HIERARCHY_V1.md`.

Guía rápida bookmarkable:

`docs/ai/PULSE_AI_WORK_CATALOG_QUICK_REFERENCE.md`

Regla de componentes: `REUSE → EXTEND_SHARED → CREATE_SHARED → LOCAL_ONLY`.
