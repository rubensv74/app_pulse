# PULSE Design & SaaS Architecture

Esta carpeta contiene las referencias normativas para diseñar interfaces coherentes en PULSE.

## Documentos

### 1. `PULSE_DESIGN_SYSTEM.md`

Define el lenguaje visual y de interacción:

- colores;
- tipografía;
- spacing;
- geometry;
- borders/shadows;
- action hierarchy;
- selection language;
- estados de componentes.

### 2. `SAAS_INTERFACE_ARCHETYPES.md`

Define las arquitecturas de interfaz según el trabajo del usuario:

- Operational Review Workspace;
- Agent / Case Workspace;
- Data Explorer;
- Object 360;
- Operational Control Tower;
- Planning Board;
- Workflow Builder;
- Configuration Studio;
- Import & Mapping Wizard;
- Audit Timeline;
- Exception Resolution Queue.

### 3. `POWER_APPS_VISUAL_QA_GUARDRAILS.md`

Registra defectos visuales detectados durante validaciones reales en Power Apps Studio y los convierte en reglas preventivas reutilizables.

Incluye, entre otros controles:

- estrategia explícita de `AutoHeight` / `Wrap` para texto;
- prohibición de scrollbars no intencionadas en texto estático;
- prevención de clipping y overflow;
- validación con contenido dinámico y zoom;
- registro incremental de lessons learned visuales.

Este documento es normativo para cualquier pantalla o componente nuevo/modificado y debe consultarse antes de cerrar un gate visual.

## Método de aplicación

Estos documentos deben utilizarse junto con:

```text
docs/development/PULSE_UI_DELIVERY_FRAMEWORK.md
docs/development/PROTOCOLO_CONSTRUCCION_MODULAR_PANTALLAS_POWER_APPS.md
```

Regla resumida:

> **El arquetipo define la arquitectura. El PDS define el lenguaje visual. Los Visual QA Guardrails evitan defectos visibles recurrentes. El protocolo modular define cómo construir y validar.**
