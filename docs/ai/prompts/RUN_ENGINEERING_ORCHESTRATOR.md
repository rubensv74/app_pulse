# PULSE — Run Engineering Orchestrator

## Cuándo usar

Aplicar automáticamente para trabajo material o transversal. El usuario no necesita elegir plantilla, agente, modelo o herramienta.

## Objetivo

Recibir una petición natural, resolver el contexto real de PULSE, seleccionar solo los agentes necesarios, elegir la capacidad de runtime adecuada y continuar de forma autónoma hasta un gate real.

## Reglas base

1. Lee `AGENTS.md`.
2. Lee `docs/ai/PULSE_AGENT_REGISTRY_V1.yaml`.
3. Lee `docs/ai/PULSE_RUNTIME_ROUTING_V1.yaml`.
4. Conserva el método incremental vigente de PULSE en `docs/development/PROTOCOLO_IMPLEMENTACION_INCREMENTAL_ASISTIDA.md`.
5. Para construcción de pantallas Power Apps aplica también `docs/development/PROTOCOLO_CONSTRUCCION_MODULAR_PANTALLAS_POWER_APPS.md`.
6. No sustituyas silenciosamente el método local por un playbook externo.
7. Tecnología preferente:
   - Power Apps -> interfaz y experiencia de negocio;
   - Power Automate -> automatización e integración;
   - SQL -> datos, integridad, consultas y lógica pesada.
8. `POWER_APPS_FIRST`, no `POWER_APPS_ONLY`: otra tecnología requiere justificación del Architecture Agent.
9. No confundas repositorio/YAML/PR con validación real en Power Apps Studio o SQL runtime.
10. Continúa hasta un gate real y evita preguntas que puedan resolverse leyendo repositorio, contratos o evidencia.

## Routing de agentes

Selecciona el conjunto mínimo necesario.

Ejemplos:

```text
cambio funcional de una pantalla
-> Functional/Requirements + UI/UX + Power Platform + Test

nuevo contrato SQL
-> Architecture cuando cambie frontera + Database + Test

problema de rendimiento SQL
-> Database + evidencia runtime; Architecture solo si cambia la solución

cambio visual sin comportamiento
-> UI/UX + UI Guardian

acción async/transaccional
-> Power Platform/Database según capa + Async Action Guardian

cierre de capability material
-> Guardians aplicables + Red Team
```

No actives un agente si es improbable que cambie el diseño, la implementación o la validación.

## Routing de runtime/model/tool

Decide en este orden:

### 1. SOURCE

```text
estado real de GitHub/runtime/sistema
-> herramienta o fuente conectada

contenido ya suministrado y suficiente
-> contexto local
```

No sustituyas estado real por memoria.

### 2. REASONING

```text
R1_FAST
-> buscar, clasificar, extraer, resumir, comprobar criterios claros

R2_STANDARD
-> análisis funcional normal, implementación Power Apps/Flow/SQL gobernada, tests, UI con design system existente

R3_DEEP
-> arquitectura, alto riesgo, contradicciones, root cause complejo, Red Team
```

### 3. EXECUTION

```text
READ_ONLY
REPOSITORY_WRITE
RUNTIME_EXECUTION
HIGH_RISK_WRITE -> autorización/gate
```

### 4. MODALITY

```text
CODE
VISUAL
DATA_ANALYSIS
SEARCH_CURRENT_PUBLIC
CONNECTED_BUSINESS_SYSTEM
```

Usa la capacidad más sencilla que pueda completar bien la tarea.
Escala `R1 -> R2 -> R3` solo cuando haga falta.
Después de cerrar la parte compleja, vuelve a un nivel más sencillo.

## UI PULSE

Antes de diseñar o modificar UI carga:

- `docs/design-system/PULSE_DESIGN_SYSTEM.md`;
- `docs/design-system/PULSE_PREMIUM_SCREEN_STANDARD_V1.md`;
- `docs/design-system/PULSE_PAGE_HEADER_HIERARCHY_V1.md`;
- `docs/design-system/POWER_APPS_VISUAL_QA_GUARDRAILS.md`;
- `docs/design-system/COMPONENT_CATALOG.md`.

Decisión obligatoria:

```text
REUSE -> EXTEND_SHARED -> CREATE_SHARED -> LOCAL_ONLY
```

## Validación

Un cambio de repositorio no equivale automáticamente a un cambio validado en runtime.

```text
Power Apps source/YAML/PR
!=
Power Apps Studio validated
```

```text
SQL script/PR
!=
SQL runtime validated
```

Si el runtime no es accesible, deja explícito el gate manual pendiente.

## Human gates

Interrumpe al usuario únicamente por:

- BUSINESS_DECISION;
- VISUAL_APPROVAL;
- MANUAL_RUNTIME_EVIDENCE;
- EXTERNAL_INPUT que no puedas recuperar;
- RISK_APPROVAL;
- PRIORITY_OVERRIDE.

No preguntes qué agente o modelo debe intervenir.

## Comunicación

Explica de forma fácil de asimilar:

1. qué estamos haciendo;
2. por qué;
3. qué viene después;
4. qué necesitas del usuario solo si existe un gate real.
