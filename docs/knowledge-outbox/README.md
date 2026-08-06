# Knowledge Outbox

## Propósito

Esta carpeta actúa como bandeja de salida temporal para conocimiento reutilizable cuando el agente que trabaja en PULSE no puede escribir directamente en el repositorio central de conocimiento.

No sustituye al repositorio central y no debe convertirse en un archivo permanente de patrones duplicados.

## Cuándo utilizarla

Utilizar esta carpeta únicamente cuando se cumplan estas condiciones:

1. el desarrollo ha producido un aprendizaje potencialmente reutilizable;
2. el aprendizaje está respaldado por una implementación, prueba o incidente real;
3. el contenido puede sanitizarse;
4. el agente no tiene acceso de escritura al repositorio central;
5. el protocolo está configurado en modo `OUTBOX`.

## Contenido permitido

- patrones y anti-patrones;
- playbooks;
- reglas preventivas;
- técnicas de diagnóstico;
- consultas o fragmentos reutilizables;
- lecciones aprendidas;
- checklists y plantillas.

## Contenido prohibido

- secretos, credenciales o tokens;
- datos productivos;
- información personal;
- detalles de infraestructura no necesarios;
- documentación específica de PULSE que deba permanecer en su ubicación funcional;
- hipótesis no validadas presentadas como hechos;
- copias completas de documentos existentes.

## Convención de nombres

```text
YYYY-MM-DD-[type]-[short-title].md
```

Ejemplos:

```text
2026-08-06-pattern-contextual-cross-filtering.md
2026-08-06-lesson-unsupported-control-properties.md
2026-08-06-playbook-document-sql-schema.md
```

## Flujo de publicación

1. Crear el candidato a partir de `KNOWLEDGE_CANDIDATE_TEMPLATE.md`.
2. Marcarlo como `status: candidate`.
3. Indicar la ruta propuesta en el repositorio central.
4. Revisar sanitización y ausencia de duplicidades.
5. Trasladarlo mediante commit o Pull Request al repositorio central.
6. Sustituir el candidato por una referencia al documento publicado o eliminarlo cuando la trazabilidad quede registrada en otra ubicación.

## Regla de honestidad operativa

La existencia de un archivo en esta carpeta no significa que el conocimiento haya sido publicado en el repositorio central. El agente debe informar expresamente de que se trata de un candidato pendiente.
